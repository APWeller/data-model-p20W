"""Build all generated deliverables from the routing spec.

    python3 scripts/build.py

Outputs (relative to p20w_target_model/):
  lineage/model_{A,B,C}_column_lineage.csv    target column x source inventory row crosswalk
  lineage/model_{A,B,C}_table_catalog.csv     table type, grain, key, SCD, family, source tables
  lineage/inventory_row_coverage.csv          every in-scope inventory row -> targets in A, B, C
  lineage/model_C_inventory_table_assignment.csv  every inventory table -> family / satellite
  lineage/validation_report.md                coverage, exclusions, CEDS checks, conformance points
  governance/model_{A,B,C}_column_classification.csv  column -> governance tier (UC tag values)
  governance/model_{A,B,C}_uc_tags.sql        ALTER TABLE ... SET TAGS statements
  ddl/model_{A,B,C}_gold.sql                  Delta CREATE TABLE statements
"""
import collections
import csv
import os
import re

from common import ROOT, GOV_LADDER, GOV_RANK, load_inventory, most_restrictive, snake
from routing_core import MODELS, M
from resolver import resolve
import catalog
import routes_k12, routes_ps, routes_other

SOURCES = routes_k12.SOURCES + routes_ps.SOURCES + routes_other.SOURCES
SRC = {s.key: s for s in SOURCES}
DW_COLS = os.path.join(ROOT, "reference", "ceds_v14", "dw_cols.txt")
CATALOG_NAME = {"A": "p20w_gold_ceds", "B": "p20w_gold_custom", "C": "p20w_gold_conformed"}


def load_ceds_dw():
    cols = {}
    for line in open(DW_COLS):
        if ":" not in line:
            continue
        t, c = line.split(":", 1)
        if t.startswith("RDS."):
            cols[t[4:]] = {x.strip() for x in c.split(",") if x.strip()}
    return cols


def main():
    rows = load_inventory()
    by_src = collections.defaultdict(list)
    for r in rows:
        by_src[r["src"]].append(r)
    assert not [k for k in by_src if k not in SRC], "unrouted inventory tables"

    maps = []  # (row, M)
    for key, rs in by_src.items():
        for r in rs:
            for x in resolve(SRC[key], r, rs):
                maps.append((r, x))

    # ---------------------------------------------------- Model A CEDS check
    dw = load_ceds_dw()
    rerouted, missing_tables = [], set()
    for r, x in maps:
        if x.model == "A" and x.table.startswith("ceds_rds."):
            t = x.table.split(".", 1)[1]
            if t not in dw:
                missing_tables.add(t)
                continue
            if x.column not in dw[t]:
                rerouted.append((x.table, x.column))
                x.logic = f"Not a CEDS DW v14.1 column on {t}; carried on WA extension. " + (x.logic or "")
                x.table = f"ceds_ext.{t}_WaExt"
    assert not missing_tables, f"ceds_rds tables not in CEDS DW: {missing_tables}"

    # ---------------------------------------------------- per-model columns
    out = os.path.join(ROOT, "lineage")
    os.makedirs(out, exist_ok=True)
    report = []
    all_tables = {}
    for model in MODELS:
        cols = collections.OrderedDict()   # (table, column) -> list[(row, M)]
        for r, x in maps:
            if x.model == model and x.kind != "EXCLUDED":
                cols.setdefault((x.table, x.column), []).append((r, x))
        tables = collections.OrderedDict()
        for (t, c), lst in cols.items():
            tables.setdefault(t, collections.OrderedDict())[c] = lst
        for t in catalog.REQUIRED_TABLES[model]:
            tables.setdefault(t, collections.OrderedDict())
        all_tables[model] = tables
        write_lineage(model, tables, maps)
        write_catalog(model, tables)
        write_governance_and_ddl(model, tables)

    write_coverage(rows, maps)
    write_c_assignment(by_src)
    write_report(rows, maps, all_tables, rerouted)
    print("done")


# ---------------------------------------------------------------------------
LINEAGE_HDR = ["model", "target_catalog", "target_schema", "target_table", "target_column", "data_type", "column_origin",
               "derivation_type", "derivation_logic", "ceds_element_id", "ceds_element_label", "column_governance_tier",
               "source_row_number", "source_sector", "source_agency", "source_or_program", "source_table_name",
               "source_data_element_name", "source_first_year", "source_most_recent_year", "source_governance_requirement"]


def column_type(lst):
    col = lst[0][1].column if lst else ""
    if re.search(r"(^|_)(org_id|person_id|academic_period_id|program_id|course_id|course_section_id|instrument_id|participation_id)$|OrganizationId$|PersonId$", col):
        if all(x.kind == "DERIVED" for _, x in lst) or col.endswith(("org_id", "person_id", "period_id")):
            return "BIGINT"
    types = collections.Counter(x.dtype for _, x in lst if x.dtype)
    for pref in ("BIGINT", "DATE", "TIMESTAMP", "BOOLEAN"):
        if any(x.kind == "DERIVED" and x.dtype == pref for _, x in lst):
            return pref
    return types.most_common(1)[0][0] if types else "STRING"


def column_gov(lst):
    return most_restrictive([r["gov_code"] for r, _ in lst])


def ceds_id(label):
    from common import ceds
    hit = ceds(label) if label else None
    return hit[0] if hit else ""


def write_lineage(model, tables, maps):
    path = os.path.join(ROOT, "lineage", f"model_{model}_column_lineage.csv")
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(LINEAGE_HDR)
        for t, cols in tables.items():
            schema, name = t.split(".", 1)
            meta = catalog.classify(model, t)
            ttype = meta[0]
            seen = set(cols)
            for c, ctype, logic in catalog.structural_columns(model, t, ttype, meta[4]) + catalog.mastered_for(model, t):
                if c in seen:
                    continue
                seen.add(c)
                w.writerow([model, CATALOG_NAME[model], schema, name, c, ctype, "STRUCTURAL", "SYSTEM" if logic.startswith("SYSTEM") else "DERIVED",
                            logic, "", "", "", "", "", "", "", "", "", "", "", ""])
            for c, lst in cols.items():
                dtype = column_type(lst)
                gov = column_gov(lst)
                for r, x in lst:
                    w.writerow([model, CATALOG_NAME[model], schema, name, c, dtype, "INVENTORY", x.kind, x.logic or "direct",
                                ceds_id(x.ceds_label), x.ceds_label, gov, r["row"], r["Sector Name"], r["Agency Name"],
                                r["Source or Program"], r["Table Name"], r["elem"], r["First Year Available"],
                                r["Most Recent Year Available"], r["Governance Requirements"]])
        for r, x in maps:
            if x.model == model and x.kind == "EXCLUDED":
                w.writerow([model, CATALOG_NAME[model], "(bronze)", f"{r['Source or Program']}.{r['Table Name']}", r["elem"], "", "INVENTORY", "EXCLUDED",
                            x.logic, "", "", r["gov_code"], r["row"], r["Sector Name"], r["Agency Name"], r["Source or Program"],
                            r["Table Name"], r["elem"], r["First Year Available"], r["Most Recent Year Available"], r["Governance Requirements"]])


def write_catalog(model, tables):
    src_tables = collections.defaultdict(set)
    for t, cols in tables.items():
        for c, lst in cols.items():
            for r, _ in lst:
                src_tables[t].add(f"{r['Source or Program']}.{r['Table Name']}".strip("."))
    grains = {}
    for s in SOURCES:
        for m in MODELS:
            h = s.host.get(m)
            if m == model and h and h not in grains:
                grains[h] = s.grain
    path = os.path.join(ROOT, "lineage", f"model_{model}_table_catalog.csv")
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["model", "schema", "table", "table_type", "family_or_role", "grain", "primary_key", "scd_treatment", "description",
                    "inventory_columns", "source_tables"])
        for t in sorted(tables):
            ttype, fam, grain, pk, scd, desc = catalog.classify(model, t)
            schema, name = t.split(".", 1)
            w.writerow([model, schema, name, ttype, fam, grain or grains.get(t, ""), pk, scd, desc, len(tables[t]),
                        "; ".join(sorted(src_tables[t]))])


def write_governance_and_ddl(model, tables):
    gdir = os.path.join(ROOT, "governance")
    ddir = os.path.join(ROOT, "ddl")
    os.makedirs(gdir, exist_ok=True)
    os.makedirs(ddir, exist_ok=True)
    cat = CATALOG_NAME[model]
    with open(os.path.join(gdir, f"model_{model}_column_classification.csv"), "w", newline="") as fc, \
            open(os.path.join(gdir, f"model_{model}_uc_tags.sql"), "w") as ft, \
            open(os.path.join(ddir, f"model_{model}_gold.sql"), "w") as fd:
        wc = csv.writer(fc)
        wc.writerow(["catalog", "schema", "table", "column", "governance_tier", "governance_tier_label", "contains_restricted_identity",
                     "research_id_substitution", "contributing_inventory_rows"])
        ft.write(f"-- Unity Catalog governed tags for model {model}. Tag values come from the inventory's Governance Requirements\n"
                 f"-- (most restrictive contributing row wins). Pair with ABAC row filters / column masks keyed on these tags.\n\n")
        fd.write(f"-- Gold-layer Delta DDL for model {model} (generated). Types marked inferred in the lineage file should be\n"
                 f"-- confirmed during silver profiling.\n\n")
        schemas = sorted({t.split('.')[0] for t in tables})
        for s in schemas:
            fd.write(f"CREATE SCHEMA IF NOT EXISTS {cat}.{s};\n")
        fd.write("\n")
        for t in sorted(tables):
            schema, name = t.split(".", 1)
            ttype, fam, grain, pk, scd, desc = catalog.classify(model, t)
            cols = tables[t]
            lines = []
            seen = set()
            for c, ctype, logic in catalog.structural_columns(model, t, ttype, scd) + catalog.mastered_for(model, t):
                if c in seen or c in cols:
                    continue
                seen.add(c)
                lines.append(f"  {c} {ctype} COMMENT '{_q(logic)}'")
            placeholders = []
            identity_zone = schema == "identity"
            for c, lst in cols.items():
                gov = column_gov(lst)
                rows = sorted({r["row"] for r, _ in lst})
                ri = any(r["gov_code"] == "RI" for r, _ in lst)
                if "{" in c:
                    placeholders.append(f"  -- {c}: one BOOLEAN column per source question id (generated from ELMS BooleanQuestion lookup); inventory rows {rows}")
                    wc.writerow([cat, schema, name, c, gov, GOV_LADDER[gov], identity_zone, ri, ";".join(map(str, rows))])
                    continue
                elems = sorted({r["elem"] for r, _ in lst})
                lines.append(f"  {c} {column_type(lst)} COMMENT 'src rows {_rows(rows)}; {_q(', '.join(elems)[:180])}'")
                wc.writerow([cat, schema, name, c, gov, GOV_LADDER[gov], identity_zone or gov == "NA", ri, ";".join(map(str, rows))])
                ft.write(f"ALTER TABLE {cat}.{schema}.{name} ALTER COLUMN {c} SET TAGS ('p20w_governance_tier' = '{gov}'"
                         f"{', ' + chr(39) + 'p20w_research_id' + chr(39) + ' = ' + chr(39) + 'true' + chr(39) if ri else ''}"
                         f"{', ' + chr(39) + 'p20w_restricted_identity' + chr(39) + ' = ' + chr(39) + 'true' + chr(39) if identity_zone or gov == 'NA' else ''});\n")
            table_gov = most_restrictive([r["gov_code"] for lst in cols.values() for r, _ in lst]) if cols else "NONE"
            ft.write(f"ALTER TABLE {cat}.{schema}.{name} SET TAGS ('p20w_governance_tier_max' = '{table_gov}', 'p20w_table_type' = '{ttype}');\n\n")
            cluster = [c for c in ("person_id", "PersonId", "K12StudentId", "PsStudentId", "academic_period_id") if c in cols or c in seen]
            fd.write(f"CREATE TABLE IF NOT EXISTS {cat}.{schema}.{name} (\n" + ",\n".join(lines) +
                     ("\n" + "\n".join(placeholders) if placeholders else "") + "\n)\nUSING DELTA\n")
            if cluster and ttype not in ("REFERENCE",):
                fd.write(f"CLUSTER BY ({', '.join(cluster[:2])})\n")
            fd.write(f"COMMENT '{_q((desc or '') + ' | Grain: ' + (grain or ''))}'\n"
                     f"TBLPROPERTIES ('p20w.table_type' = '{ttype}', 'p20w.scd' = '{_q(scd)}', 'delta.enableChangeDataFeed' = 'true');\n\n")


def _q(s):
    return (s or "").replace("'", "''")


def _rows(rows):
    return ",".join(map(str, rows[:12])) + ("..." if len(rows) > 12 else "")


def write_coverage(rows, maps):
    idx = collections.defaultdict(lambda: collections.defaultdict(list))
    for r, x in maps:
        idx[r["row"]][x.model].append("EXCLUDED: " + x.logic if x.kind == "EXCLUDED" else f"{x.table}.{x.column}")
    with open(os.path.join(ROOT, "lineage", "inventory_row_coverage.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["source_row_number", "sector", "agency", "source_or_program", "table_name", "data_element_name", "first_year", "most_recent_year",
                    "governance", "model_A_targets", "model_B_targets", "model_C_targets"])
        for r in sorted(rows, key=lambda r: r["row"]):
            w.writerow([r["row"], r["Sector Name"], r["Agency Name"], r["Source or Program"], r["Table Name"], r["elem"], r["First Year Available"],
                        r["Most Recent Year Available"], r["Governance Requirements"]] +
                       [" | ".join(dict.fromkeys(idx[r["row"]][m])) for m in MODELS])


def write_c_assignment(by_src):
    with open(os.path.join(ROOT, "lineage", "model_C_inventory_table_assignment.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["sector", "agency", "source_or_program", "table_name", "inventory_rows", "first_year", "most_recent_year", "source_grain",
                    "model_C_family", "model_C_table", "person_or_definitional", "assignment_note"])
        for key, rs in by_src.items():
            s = SRC[key]
            tbls = collections.OrderedDict()
            for r in rs:
                tbls.setdefault((r["Sector Name"], r["Agency Name"], r["Source or Program"], r["Table Name"]), []).append(r)
            for (sec, ag, prog, tbl), lst in tbls.items():
                fy = sorted({x["First Year Available"] for x in lst if x["First Year Available"]})
                my = sorted({x["Most Recent Year Available"] for x in lst if x["Most Recent Year Available"]})
                for fam, table, note in s.c_assign:
                    kind = ("Definitional (keyed by organization/offering)" if table.startswith("conformed.") and fam in ("CourseSection", "Program", "(Additional table) COURSE")
                            else "Conformed dimension / identity" if fam.startswith("(") and not fam.startswith("(Additional") else "Person-level event/fact"
                            if table.startswith("fact.") and not any(k in table for k in ("PROFILE", "EMPLOYER_QUARTER")) else "Organization-level")
                    w.writerow([sec, ag, prog, tbl, len(lst), "; ".join(fy), "; ".join(my), s.grain, fam, table, kind, note])


def write_report(rows, maps, all_tables, rerouted):
    lines = ["# Lineage build validation report", ""]
    n = len(rows)
    for m in MODELS:
        covered = {r["row"] for r, x in maps if x.model == m}
        excluded = {r["row"] for r, x in maps if x.model == m and x.kind == "EXCLUDED"}
        tables = all_tables[m]
        ncols = sum(len(v) for v in tables.values())
        lines.append(f"- Model {m}: {len(covered)}/{n} in-scope inventory rows mapped ({len(excluded)} explicitly excluded to bronze-only with reasons); "
                     f"{len(tables)} gold tables; {ncols} inventory-derived columns")
    lines += ["", "## Explicit exclusions (identical in all models)", "", "| Row | Source | Table | Element | Reason |", "|---|---|---|---|---|"]
    for r, x in maps:
        if x.model == "A" and x.kind == "EXCLUDED":
            lines.append(f"| {r['row']} | {r['Source or Program']} | {r['Table Name']} | {r['elem']} | {x.logic} |")
    lines += ["", "## Model A: CEDS DW v14.1 conformance check", "",
              f"Every `ceds_rds.*` target was checked against the published CEDS-Data-Warehouse DDL. {len(set(rerouted))} proposed native columns "
              "were not present on the CEDS table and were automatically re-homed to the `_WaExt` extension:", ""]
    for t, c in sorted(set(rerouted)):
        lines.append(f"- `{t}.{c}`")
    lines += ["", "## EAV scan", ""]
    bad = [(m, t, c) for m in MODELS for t, cols in all_tables[m].items() for c in cols
           if re.search(r"(^|_)(attribute_name|attribute_value|key_name|value_text|generic_value)($|_)", c.lower())]
    lines.append("No generic attribute/value columns found." if not bad else "\n".join(map(str, bad)))
    lines += ["", "## Conformance points (Model C columns fed by more than one distinct source element)", "",
              "| Table.Column | Contributing elements (row numbers) |", "|---|---|"]
    tables = all_tables["C"]
    for t, cols in tables.items():
        for c, lst in cols.items():
            elems = collections.OrderedDict()
            for r, _ in lst:
                elems.setdefault(f"{r['Source or Program']}.{r['Table Name']}.{r['elem']}", []).append(r["row"])
            if len({k.split('.')[-1] for k in elems}) > 1 and not t.startswith(("identity.", "conformed.ORGANIZATION", "conformed.ACADEMIC_PERIOD_XWALK")) \
                    and c not in ("person_id", "academic_period_id", "federal_race_ethnicity_rollup", "birth_year", "birth_month", "organization_name") \
                    and not c.endswith("_org_id") and not c.startswith("source_"):
                lines.append(f"| {t}.{c} | " + "; ".join(f"{k} ({','.join(map(str, v))})" for k, v in list(elems.items())[:8]) + (" ..." if len(elems) > 8 else "") + " |")
    open(os.path.join(ROOT, "lineage", "validation_report.md"), "w").write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
