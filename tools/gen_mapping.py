"""Phase 5: generate mapping/source_to_target.csv.

Usage:  .venv/bin/python tools/gen_mapping.py   (run after tools/gen_ddl.py)

Rows
  - one per (active element, gold column) from catalog/gold_columns.csv
  - silver-only targets for elements consumed by crosswalks and never surfaced in gold
    (District Student ID, A04 Location ID)
  - EXCLUDED rows (with reason) for active elements deliberately not modeled
  - INACTIVE rows for every inactive element, including File P
target_table is schema-qualified (gold.<table> / silver.<table>).
"""

from __future__ import annotations

import csv
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from gold_spec import TABLES as GOLD  # noqa: E402

REPO = Path(__file__).resolve().parents[1]


def load(path):
    with open(path, newline="") as fh:
        return list(csv.DictReader(fh))


ELEMENTS = {r["element_id"]: r for r in load(REPO / "catalog" / "elements.csv")}
SILVER = defaultdict(list)
for r in load(REPO / "catalog" / "silver_columns.csv"):
    SILVER[r["element_id"]].append(r)
CODE_SET_OF = defaultdict(list)
for r in load(REPO / "catalog" / "code_sets.csv"):
    for e in filter(None, r["used_by"].split(",")):
        CODE_SET_OF[e].append(r["code_set"])

# Natural key each dimension is looked up by.
LOOKUP = {
    "dim_date": "calendar date -> date_sk YYYYMMDD",
    "dim_school_year": "school year (ending year)",
    "dim_student": "SSID, SCD2 row current at the fact's effective date",
    "dim_district": "county_district_code, SCD2 row current for the school year",
    "dim_school": "county_district_code + OSPI school code (silver school_code); H26 9999 -> -3",
    "dim_course": "school year + district + school + course ID (catalog_source D, else H/T-inferred member)",
    "dim_section": "school year + district + school + course ID + section ID + term",
    "dim_staff": "county_district_code + staff_id",
    "dim_program": "program_family + program_code",
    "dim_grade_level": "grade_level_code",
    "dim_state_course": "state_course_code",
    "dim_student_profile": "combination of profile flags for the period",
}

# Silver-only targets: elements used for resolution, not surfaced in gold.
SILVER_ONLY = {
    "District Student ID": ("silver.xref_student", "district_student_id",
                           "Collected with the SSID into xref_student; not carried into gold (SSID is the durable key)"),
    "A04": ("silver.xref_location", "location_id",
            "Resolves every file's Location ID to the OSPI school code; gold uses school_sk"),
}

# Active elements deliberately not modeled (none at present; kept for the validator contract).
EXCLUDED: dict[str, str] = {}


def silver_source(eid: str) -> str:
    rows = [r for r in SILVER.get(eid, []) if not r["silver_column"].endswith("_raw")]
    return ", ".join(f"silver.{r['silver_table']}.{r['silver_column']}" for r in rows[:2])


def transformation(t, c, eid) -> str:
    src = silver_source(eid)
    if c.fk:
        target = c.fk[0]
        if target == "dim_date":
            return f"{src}: date -> INT YYYYMMDD; NULL -> -2 (not applicable)"
        if target == "dim_school_year":
            return f"{src}: school year (ending year) -> school_year_sk"
        if target.endswith("_group"):
            return f"{src}: sort + de-duplicate members -> lookup {target} by group_codes; none -> -2"
        if GOLD[target].kind == "junk":
            return f"{src}: lookup {target} by the combination of its codes (insert new combinations)"
        key = LOOKUP.get(target) or (f"code_set + code" if "code_set" in [x.name for x in GOLD[target].cols]
                                     else "code (row valid for the school year)")
        return f"{src}: lookup {target} by {key}; unmatched -> -1, NULL -> -2"
    if t.kind == "bridge":
        return f"{src}: one row per member"
    if c.name == "group_codes":
        return f"{src}: distinct member codes, sorted, joined with ','"
    if c.name == "member_count":
        return f"{src}: number of distinct member codes"
    if c.desc.startswith("Derived"):
        return c.desc
    if t.kind in ("dim", "junk", "outrigger") and t.name in GOLD:
        extra = " (SCD2)" if t.scd2 and c.name not in ("county_district_code", "school_code", "ssid", "staff_id") else ""
        via = "ref.ref_code" if t.extra.get("code_sets") else src
        return f"{via} -> {c.name}{extra}"
    return f"{src} -> {c.type}" if src else c.desc


def notes(eid, c) -> str:
    e = ELEMENTS[eid]
    parts = []
    if CODE_SET_OF.get(eid):
        parts.append(f"code set: {', '.join(CODE_SET_OF[eid])}")
    if e["is_multi_valued"] == "Y":
        parts.append(f"multi-valued ({e['multi_value_encoding']})")
    for tag in ("C-001", "C-003", "C-005", "C-006", "C-007", "D-023", "D-033"):
        if tag in c.desc:
            parts.append(f"see decisions {tag}")
    return "; ".join(parts)


def main() -> int:
    rows = []
    covered = set()
    for r in load(REPO / "catalog" / "gold_columns.csv"):
        t = GOLD[r["gold_table"]]
        c = next(x for x in t.cols if x.name == r["gold_column"])
        for eid in filter(None, r["element_ids"].split(",")):
            if eid.startswith("*") or eid not in ELEMENTS or ELEMENTS[eid]["is_active"] != "Y":
                continue  # inactive seams (B31, D18, D19, E12-E14) are listed as INACTIVE below
            rows.append({"element_id": eid, "target_table": f"gold.{t.name}", "target_column": c.name,
                         "transformation": transformation(t, c, eid), "notes": notes(eid, c)})
            covered.add(eid)

    for eid, e in ELEMENTS.items():
        if e["is_active"] != "Y":
            continue
        key = e["element_name"] if e["element_name"] in SILVER_ONLY else eid
        if key in SILVER_ONLY and eid not in covered:
            table, column, why = SILVER_ONLY[key]
            rows.append({"element_id": eid, "target_table": table, "target_column": column,
                         "transformation": f"{silver_source(eid)} -> {table}.{column}", "notes": why})
            covered.add(eid)
        elif eid in EXCLUDED:
            rows.append({"element_id": eid, "target_table": "EXCLUDED", "target_column": "",
                         "transformation": "", "notes": EXCLUDED[eid]})
            covered.add(eid)

    seams = defaultdict(list)
    for r in load(REPO / "catalog" / "gold_columns.csv"):
        for eid in filter(None, r["element_ids"].split(",")):
            if eid in ELEMENTS and ELEMENTS[eid]["is_active"] != "Y":
                seams[eid].append(f"{r['gold_table']}.{r['gold_column']}")
    for eid, e in ELEMENTS.items():
        if e["is_active"] == "Y":
            continue
        why = "File P retired 2018-19" if e["file_code"] == "P" else "Element inactive in manual v19.0"
        if seams.get(eid):
            why += f"; NULL seam column kept for backload: {', '.join(seams[eid])}"
        rows.append({"element_id": eid, "target_table": "INACTIVE", "target_column": "", "transformation": "",
                     "notes": why})

    missing = [e for e, r in ELEMENTS.items() if r["is_active"] == "Y" and e not in covered]
    rows.sort(key=lambda r: (r["element_id"], r["target_table"], r["target_column"]))
    out = REPO / "mapping" / "source_to_target.csv"
    out.parent.mkdir(exist_ok=True)
    with open(out, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=["element_id", "target_table", "target_column", "transformation", "notes"])
        w.writeheader()
        w.writerows(rows)
    by = defaultdict(int)
    for r in rows:
        by[r["target_table"].split(".")[0]] += 1
    print(f"mapping rows: {len(rows)} {dict(by)}; active elements mapped: {len(covered)}")
    if missing:
        print("UNMAPPED active elements:", missing)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
