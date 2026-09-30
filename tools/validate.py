"""Phase 6: repository validator (runs in CI).

Usage:  python tools/validate.py        exit 0 = all checks pass

Checks (CLAUDE.md phase 6), independent of the generators:
  1. mapping    every mapped element exists in catalog/elements.csv; every active element is mapped or
                EXCLUDED (with a reason); inactive elements and File P are listed as INACTIVE
  2. targets    every mapping target table and column exists in the DDL
  3. fks        every foreign key in the gold DDL references an existing table and its primary key
  4. code_sets  every element with an appendix reference or inline valid values has a registered code set;
                every extracted code set has a seed file
  5. bridges    every active multi-valued element maps to a gold bridge table
  6. sql        all SQL parses under sqlglot's Databricks dialect
Also: catalog name parameterized as ${catalog}; every silver and gold column has a COMMENT.
"""

from __future__ import annotations

import csv
import re
import sys
from collections import defaultdict
from pathlib import Path

import sqlglot
from sqlglot import exp

REPO = Path(__file__).resolve().parents[1]
SQL = REPO / "sql"


def load(path):
    with open(REPO / path, newline="") as fh:
        return list(csv.DictReader(fh))


class Report:
    def __init__(self):
        self.results: list[tuple[str, list[str]]] = []

    def check(self, name, errors):
        self.results.append((name, errors))

    def print(self) -> int:
        failed = 0
        for name, errors in self.results:
            status = "PASS" if not errors else f"FAIL ({len(errors)})"
            print(f"[{status:>9}] {name}")
            for e in errors[:25]:
                print(f"            - {e}")
            if len(errors) > 25:
                print(f"            ... {len(errors) - 25} more")
            failed += bool(errors)
        print(f"\n{len(self.results) - failed}/{len(self.results)} checks passed")
        return 1 if failed else 0


# --------------------------------------------------------------------------------------
# SQL model
# --------------------------------------------------------------------------------------

def rel(f: Path) -> str:
    try:
        return str(f.relative_to(REPO))
    except ValueError:
        return str(f)


def parse_sql():
    """Returns (errors, tables) where tables = {'schema.table': {'cols': {name: coldef}, 'stmt': stmt}}."""
    errors, tables, views = [], {}, set()
    files = sorted(SQL.rglob("*.sql"))
    if not files:
        errors.append("no SQL files under sql/")
    for f in files:
        text = f.read_text()
        try:
            stmts = [s for s in sqlglot.parse(text.replace("${catalog}", "cedars"), read="databricks") if s]
        except sqlglot.errors.ParseError as ex:
            errors.append(f"{rel(f)}: {str(ex).splitlines()[0]}")
            continue
        if not stmts:
            errors.append(f"{rel(f)}: no statements")
        for s in stmts:
            if isinstance(s, exp.Command):  # sqlglot's fallback for text it could not parse
                errors.append(f"{rel(f)}: statement not understood by the parser: {s.sql()[:60]}")
                continue
            if isinstance(s, exp.Create) and s.kind in ("TABLE", "VIEW"):
                tbl = s.this.this if s.kind == "TABLE" else s.this
                key = f"{tbl.args['db'].name}.{tbl.name}"
                if s.kind == "VIEW":
                    views.add(key)
                    continue
                tables[key] = {"cols": {c.name: c for c in s.find_all(exp.ColumnDef)}, "stmt": s,
                               "file": rel(f)}
    return errors, tables, views


def primary_key(stmt):
    pk = stmt.find(exp.PrimaryKey)
    return [k.name for k in pk.expressions] if pk else []


# --------------------------------------------------------------------------------------
# Checks
# --------------------------------------------------------------------------------------

def check_mapping(elements, mapping):
    errs = []
    by_el = defaultdict(list)
    for i, r in enumerate(mapping, 2):
        if r["element_id"] not in elements:
            errs.append(f"row {i}: element {r['element_id']} not in catalog/elements.csv")
        by_el[r["element_id"]].append(r)
    for eid, e in elements.items():
        rows = by_el.get(eid, [])
        targets = {r["target_table"] for r in rows}
        if e["is_active"] == "Y" and e["file_code"] != "P":
            if not rows:
                errs.append(f"{eid}: active element not mapped")
            elif "INACTIVE" in targets:
                errs.append(f"{eid}: active element marked INACTIVE")
            elif "EXCLUDED" in targets:
                if len(targets) > 1:
                    errs.append(f"{eid}: EXCLUDED and also mapped")
                if not all(r["notes"].strip() for r in rows):
                    errs.append(f"{eid}: EXCLUDED without a reason in notes")
        else:
            if targets != {"INACTIVE"}:
                errs.append(f"{eid}: inactive element must be listed only as INACTIVE (found {sorted(targets)})")
    return errs


def check_targets(mapping, tables):
    errs = []
    for r in mapping:
        t = r["target_table"]
        if t in ("INACTIVE", "EXCLUDED"):
            continue
        if t not in tables:
            errs.append(f"{r['element_id']}: target table {t} not in DDL")
        elif r["target_column"] not in tables[t]["cols"]:
            errs.append(f"{r['element_id']}: column {t}.{r['target_column']} not in DDL")
    return errs


def check_fks(tables):
    errs = []
    for name, t in tables.items():
        if not name.startswith("gold."):
            continue
        for fk in t["stmt"].find_all(exp.ForeignKey):
            ref = fk.args["reference"].this
            target = f"{ref.this.args['db'].name}.{ref.this.name}"
            ref_cols = [c.name for c in ref.expressions]
            local = [c.name for c in fk.expressions]
            if target not in tables:
                errs.append(f"{name}: FK {local} -> missing table {target}")
                continue
            pk = primary_key(tables[target]["stmt"])
            if ref_cols != pk:
                errs.append(f"{name}: FK {local} -> {target}{ref_cols} is not its primary key {pk}")
            for c in local:
                if c not in t["cols"]:
                    errs.append(f"{name}: FK column {c} not defined")
            for lc, rc in zip(local, ref_cols):
                if lc in t["cols"] and rc in tables[target]["cols"]:
                    lt = t["cols"][lc].args["kind"].sql("databricks")
                    rt = tables[target]["cols"][rc].args["kind"].sql("databricks")
                    if lt != rt:
                        errs.append(f"{name}.{lc} ({lt}) -> {target}.{rc} ({rt}): type mismatch")
    return errs


def check_code_sets(elements, code_sets):
    errs = []
    covered = defaultdict(set)
    appendices = {r["appendix"] for r in code_sets if r["appendix"]}
    for r in code_sets:
        for e in filter(None, (r["used_by"] + "," + r["referenced_by"]).split(",")):
            covered[e].add(r["code_set"])
        if r["status"] not in ("extracted", "external", "partial", "retired"):
            errs.append(f"{r['code_set']}: invalid status {r['status']}")
        seed = REPO / "seeds" / "ref" / f"{r['code_set']}.csv"
        if r["status"] in ("extracted", "partial") and not seed.exists():
            errs.append(f"{r['code_set']}: status {r['status']} but {seed.relative_to(REPO)} missing")
    for eid, e in elements.items():
        if e["is_active"] != "Y":
            continue
        refs = [a for a in e["appendix_refs"].split(",") if a]
        if (refs or e["inline_valid_values"]) and not covered.get(eid):
            errs.append(f"{eid}: has appendix refs {refs} / inline values but no registered code set")
        for a in refs:
            if a not in appendices:
                errs.append(f"{eid}: references Appendix {a}, which is not registered")
    return errs


def check_bridges(elements, mapping):
    errs = []
    bridged = {r["element_id"] for r in mapping if r["target_table"].startswith("gold.bridge_")}
    for eid, e in elements.items():
        if e["is_active"] == "Y" and e["is_multi_valued"] == "Y" and eid not in bridged:
            errs.append(f"{eid}: multi-valued element does not map to a gold bridge table")
    return errs


def check_conventions(tables):
    errs = []
    for f in SQL.rglob("*.sql"):
        for fqn in re.findall(r"(?:TABLE IF NOT EXISTS|SCHEMA IF NOT EXISTS|REFERENCES|INSERT INTO|VIEW)\s+([\w${}.]+)",
                              f.read_text()):
            if not fqn.startswith("${catalog}."):
                errs.append(f"{rel(f)}: {fqn} is not parameterized with ${{catalog}}")
    for name, t in tables.items():
        if name.split(".")[0] not in ("silver", "gold"):
            continue
        for c, cd in t["cols"].items():
            if cd.find(exp.CommentColumnConstraint) is None:
                errs.append(f"{name}.{c}: missing COMMENT")
    return errs


def main() -> int:
    elements = {r["element_id"]: r for r in load("catalog/elements.csv")}
    mapping = load("mapping/source_to_target.csv")
    code_sets = load("catalog/code_sets.csv")
    sql_errors, tables, _ = parse_sql()

    rep = Report()
    rep.check("1. mapping: elements exist; active mapped or EXCLUDED; inactive/File P listed INACTIVE",
              check_mapping(elements, mapping))
    rep.check("2. targets: every mapping table/column exists in the DDL", check_targets(mapping, tables))
    rep.check("3. fks: every gold FK references an existing table and its primary key", check_fks(tables))
    rep.check("4. code sets: every coded element has a registered code set", check_code_sets(elements, code_sets))
    rep.check("5. bridges: every multi-valued element maps to a gold bridge", check_bridges(elements, mapping))
    rep.check("6. sql: all SQL parses under sqlglot (databricks)", sql_errors)
    rep.check("conventions: ${catalog} parameterized; silver/gold columns commented", check_conventions(tables))
    print(f"\n{len(tables)} tables parsed from {len(list(SQL.rglob('*.sql')))} SQL files; "
          f"{len(mapping)} mapping rows; {len(elements)} elements")
    return rep.print()


if __name__ == "__main__":
    sys.exit(main())
