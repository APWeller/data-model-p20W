"""Phase 2: extract every CEDARS code set into seeds/ref/<code_set>.csv and register them in
catalog/code_sets.csv.

Usage:  .venv/bin/python tools/extract_code_sets.py

Sources
  - sources/2026-27_cedars_appendices.pdf           (appendix tables)
  - sources/appendix_{f,k,q,r}_*.xlsx                 (authoritative for F, K, Q, R)
  - catalog/elements.csv                              (inline valid values, from phase 1)

Seed layout: code, description, <rollup/attribute columns>, source_order, valid_from_year,
valid_to_year. Years are CEDARS school years expressed as the 4-digit ending year
(2026-27 -> 2027), matching element A01. Blank = open / not stated by the source.
"""

from __future__ import annotations

import csv
import re
import sys
import warnings
from collections import defaultdict
from pathlib import Path

import openpyxl
import pdfplumber

sys.path.insert(0, str(Path(__file__).resolve().parent))
from parse_manual import MANUAL_VERSION, norm  # noqa: E402

REPO = Path(__file__).resolve().parents[1]
SRC = REPO / "sources"
APPX_PDF = SRC / "2026-27_cedars_appendices.pdf"
SEEDS = REPO / "seeds" / "ref"
CATALOG = REPO / "catalog"
XLSX = {
    "F": SRC / "appendix_f_student_attributes_programs_2026-27.xlsx",
    "K": SRC / "appendix_k_language_codes_2026-27_v190.xlsx",
    "Q": SRC / "appendix_q_advplacement_intlbaccalaureate_cambridge_2026-27_v191.xlsx",
    "R": SRC / "appendix_r_reengagement_codes_2026-27_v190.xlsx",
    "S": SRC / "appendix_s_cipcodes_2026-27_v190.xlsx",
    "V": SRC / "appendix_v_state_course_codes_2026-27_v190.xlsx",
    "AA_AB": SRC / "appendix_aa_ab_onlineprovider_onlineprograms_2026-27_v190.xlsx",
    "AK": SRC / "appendix_ak_industry_recognized_certifications_2026-27_v190.xlsx",
}
CURRENT_YEAR = 2027  # 2026-27, manual v19.0

warnings.filterwarnings("ignore", module="openpyxl")

REGISTRY: list[dict] = []   # rows for catalog/code_sets.csv
PROBLEMS: list[str] = []
REUSED: list[str] = []      # codes that are active and also carry an archived earlier row


# --------------------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------------------

def clean(s) -> str:
    """Join wrapped cell lines; re-join words hyphenated across a line break."""
    if s is None:
        return ""
    s = str(s).replace("\r", "")
    s = re.sub(r"(\w)-\n(?=[a-z0-9])", r"\1-", s)
    return norm(s.replace("\n", " "))


def year_end(sy: str) -> str:
    """'2016-17' / '2020–21' -> '2017' / '2021'."""
    m = re.match(r"^\s*(\d{4})\s*[-–]\s*(\d{2,4})\s*$", str(sy or ""))
    if not m:
        return ""
    start = int(m.group(1))
    return str(start + 1)


def write_seed(code_set: str, rows: list[dict], extra_cols: list[str]) -> Path:
    cols = ["code", "description", *extra_cols, "source_order", "valid_from_year", "valid_to_year"]
    for i, r in enumerate(rows, 1):
        r.setdefault("source_order", i)
        r.setdefault("valid_from_year", "")
        r.setdefault("valid_to_year", "")
    keys = [(r["code"], r["valid_from_year"], r.get("status", "")) for r in rows]
    dupes = {k for k in keys if keys.count(k) > 1}
    if dupes:
        PROBLEMS.append(f"{code_set}: duplicate codes {sorted(dupes)[:5]}")
    SEEDS.mkdir(parents=True, exist_ok=True)
    path = SEEDS / f"{code_set}.csv"
    with open(path, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=cols, extrasaction="raise")
        w.writeheader()
        for r in rows:
            w.writerow({c: r.get(c, "") for c in cols})
    return path


def register(code_set, source, appendix, status, used_by, *, title="", rows=None, notes=""):
    REGISTRY.append(dict(
        manual_version=MANUAL_VERSION, code_set=code_set, title=title, source=source, appendix=appendix,
        status=status, used_by=",".join(used_by), referenced_by="",
        seed_file=f"seeds/ref/{code_set}.csv" if rows is not None else "",
        row_count=len(rows) if rows is not None else 0, notes=notes))


# --------------------------------------------------------------------------------------
# PDF appendix tables
# --------------------------------------------------------------------------------------

_PDF_TABLES: dict[int, list] = {}
_PDF_TEXT: dict[int, str] = {}


def load_pdf():
    with pdfplumber.open(APPX_PDF) as pdf:
        for i, p in enumerate(pdf.pages, 1):
            _PDF_TABLES[i] = p.extract_tables()
            _PDF_TEXT[i] = p.extract_text() or ""


def table_rows(pages, key_col, code_re, *, header_lines=1, header_mode="fixed", tables=None, header_test=None,
               collapse_from=None):
    """Merge PDF table rows into records keyed by the code column.

    - Rows whose key cell is empty continue the previous record (also across pages).
    - An empty-key row directly before a code row is prepended to that code when it fills a
      column the code row leaves empty (label wrapped above the code, e.g. Appendix Z N24).
    - header_mode 'fixed' skips `header_lines` rows at the top of a table whose first row is a
      header (header_test; default: key cell is non-empty and not a code); 'until_code' skips
      everything before the first code row of each table.
    - collapse_from=N joins cells N.. of each physical row first, so text that the PDF split
      across trailing columns stays in reading order.
    Returns a list of (record_cells, table_ref) where record_cells is a list of cell lists.
    """
    code_re = re.compile(code_re)
    if header_test is None:
        def header_test(r):
            k = clean(r[key_col])
            return bool(k) and not code_re.match(k)
    records: list[list[list[str]]] = []
    refs: list[tuple[int, int]] = []
    for p in pages:
        for ti, t in enumerate(_PDF_TABLES[p]):
            if tables is not None and (p, ti) not in tables:
                continue
            rows = [[(c or "") for c in r] for r in t]
            if collapse_from is not None:
                rows = [r[:collapse_from] + [" ".join(c for c in r[collapse_from:] if c.strip())] for r in rows]
            rows = [r for r in rows if any(c.strip() for c in r)]
            if not rows:
                continue
            if header_mode == "until_code":
                while rows and not code_re.match(clean(rows[0][key_col])):
                    rows.pop(0)
            elif header_test(rows[0]):
                rows = rows[header_lines:]
            pending: list[list[str]] | None = None
            for r in rows:
                key = clean(r[key_col])
                if key and code_re.match(key):
                    cells = [[c] if c.strip() else [] for c in r]
                    if pending is not None:
                        empty_here = [i for i, c in enumerate(r) if not c.strip() and i != key_col]
                        if any(pending[i] for i in empty_here if i < len(pending)):
                            cells = [pending[i] + cells[i] if i < len(pending) else cells[i]
                                     for i in range(len(cells))]
                        elif records:
                            merge_into(records[-1], pending)
                        pending = None
                    records.append(cells)
                    refs.append((p, ti))
                elif not key:
                    cont = [[c] if c.strip() else [] for c in r]
                    if pending is not None and records:
                        merge_into(records[-1], pending)
                    pending = cont
                else:
                    pending = None  # non-code, non-empty key: a stray header line
            if pending is not None and records:
                merge_into(records[-1], pending)
    return [([clean("\n".join(c)) for c in rec], ref) for rec, ref in zip(records, refs)]


def merge_into(rec, cont):
    for i, c in enumerate(cont):
        if i < len(rec):
            rec[i].extend(c)
        elif c:
            rec[-1].extend(c)


def join_cols(cells, start):
    return clean(" ".join(c for c in cells[start:] if c))


def page_lines(pages):
    for p in pages:
        for ln in _PDF_TEXT[p].splitlines():
            ln = norm(ln)
            if ln and not re.match(r"^Page \|", ln):
                yield p, ln


# --------------------------------------------------------------------------------------
# Appendix extractors (PDF)
# --------------------------------------------------------------------------------------

def appx_simple(code_set, appx, title, pages, key_col, code_re, cols, used_by, *,
                header_lines=1, header_mode="fixed", header_test=None, notes="", post=None, extra_cols=()):
    """cols: list of (column_name, cell_index or 'rest:N'). First named column is 'description'."""
    rest = [int(i[5:]) for _, i in cols if isinstance(i, str)]
    recs = table_rows(pages, key_col, code_re, header_lines=header_lines, header_mode=header_mode,
                      header_test=header_test, collapse_from=rest[0] if rest else None)
    rows = []
    for cells, _ in recs:
        r = {"code": cells[key_col]}
        for name, idx in cols:
            r[name] = join_cols(cells, int(idx[5:])) if isinstance(idx, str) else (cells[idx] if idx < len(cells) else "")
        rows.append(r)
    if post:
        rows = post(rows)
    extra = [n for n, _ in cols if n != "description"] + list(extra_cols)
    write_seed(code_set, rows, extra)
    register(code_set, APPX_PDF.name, appx, "extracted", used_by, title=title, rows=rows, notes=notes)
    return rows


def appx_n_placement_status():
    """Appendix N is a placement test x status matrix (rotated header text). Transcribed from p37
    and mapped to J18 Placement Test codes by name; each status label is verified on the page."""
    NA = "Not Applicable"
    TNQ = "Tested But Did Not Qualify"
    legacy = [NA, "Beginning/Advanced Beginning", "Intermediate", "Advanced", TNQ, TNQ, NA]
    matrix = [
        ("1", "LASO", legacy), ("2", "LPTS", legacy), ("3", "PLAS", legacy), ("4", "WLPT", legacy),
        ("5", "WELPA", legacy),
        ("6", "ELPA21* (WA)", ["Proficiency Not Demonstrated", "Emerging", "Progressing", "Proficient", NA, NA, NA]),
        ("7", "ELPA21 (Not WA)", [NA, "Emerging", "Progressing", "Proficient", NA, NA, NA]),
        ("8", "WIDA ACCESS (Not WA)", [NA, "Entering", "Emerging", "Developing", "Expanding", "Bridging", "Reaching"]),
        ("9", "WIDA Alt ACCESS (Not WA)", [NA, "Initiating", "Exploring", "Engaging", "Entering", "Emerging", "Developing"]),
        ("10", "WIDA Screener (WA)", [NA, NA, NA, NA, NA, "Tested and Qualified", "Tested but did not Qualify"]),
        ("11", "WIDA Alt Screener (WA)", [NA, NA, NA, NA, NA, "Tested and Qualified", "Tested but did not Qualify"]),
    ]
    page = norm(_PDF_TEXT[37].replace("\n", " ")).lower()
    for _, test, labels in matrix:
        for w in {x for l in labels for x in re.split(r"[ /]", l)}:
            if w and w.lower() not in page:
                PROBLEMS.append(f"appendix N: word '{w}' ({test}) not on p37")
    rows = []
    for tcode, test, labels in matrix:
        for s, label in enumerate(labels):
            rows.append({"code": str(s), "description": label, "placement_test_code": tcode,
                         "placement_test": test})
    # Composite key (placement_test_code, code); write_seed's duplicate check is per code, so skip it.
    path = SEEDS / "el_placement_status.csv"
    SEEDS.mkdir(parents=True, exist_ok=True)
    cols = ["code", "description", "placement_test_code", "placement_test", "source_order",
            "valid_from_year", "valid_to_year"]
    with open(path, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=cols)
        w.writeheader()
        for i, r in enumerate(rows, 1):
            w.writerow({**r, "source_order": i, "valid_from_year": "", "valid_to_year": ""})
    register("el_placement_status", APPX_PDF.name, "N", "extracted", ["J21"],
             title="English Learners Placement Status", rows=rows,
             notes="Composite key (placement_test_code, code): meaning of J21 depends on J18. "
                   "Transcribed from a rotated-header matrix; test rows mapped to J18 codes by name.")


def appx_o_content_area():
    new = table_rows([38], 0, r"^(\d{1,3}|ZZZ)$", header_lines=2, tables={(38, 0)})
    old = table_rows([38, 39], 0, r"^(\d{1,3}|ZZZ)$", header_lines=2, tables={(38, 1), (39, 0)})
    rows = []
    new_codes = {c[0] for c, _ in new}
    for cells, _ in new:
        rows.append({"code": cells[0], "description": cells[1], "core_content_educator_equity": cells[2]})
    for cells, _ in old:
        if cells[0] in new_codes:
            continue  # 123 and ZZZ are valid in both eras
        rows.append({"code": cells[0], "description": cells[1], "core_content_educator_equity": cells[2],
                     "valid_to_year": "2015"})
    write_seed("content_area", rows, ["core_content_educator_equity"])
    register("content_area", APPX_PDF.name, "O", "extracted", ["D06", "H14", "T09"], title="Content Area Codes",
             rows=rows, notes="Codes 1-122 apply to courses taken 2014-15 and earlier (valid_to_year 2015); "
                              "123 and ZZZ apply to all years. D06/T09 accept only 123/ZZZ.")


def appx_u_staff_type():
    recs = table_rows([44], 0, r"^\d{2}[xy0-9]$")
    suffix = {"0": "Certificated base contracts and all classified employment assignments except as noted below.",
              "1": "Certificated supplemental contract for additional responsibility and incentive but no for additional time.",
              "2": "Certificated supplemental contracts for extended, extra, or optional days and hours which are available to the employee.",
              "3": "Certain classified employment or payments not related to time."}
    for s in suffix.values():
        if norm(s).lower() not in norm(_PDF_TEXT[44].replace("\n", " ")).lower():
            PROBLEMS.append(f"appendix U suffix text not verified: {s[:40]}")
    expand = {"x": "012", "y": "03"}
    rows = []
    for cells, _ in recs:
        base, desc = cells[0], cells[1]
        if base[-1] in expand:
            for d in expand[base[-1]]:
                rows.append({"code": base[:2] + d, "description": desc, "staff_type_group": base,
                             "suffix": d, "suffix_description": suffix[d]})
        else:
            rows.append({"code": base, "description": desc, "staff_type_group": base, "suffix": "",
                         "suffix_description": ""})
    write_seed("staff_type", rows, ["staff_type_group", "suffix", "suffix_description"])
    register("staff_type", APPX_PDF.name, "U", "extracted", ["F04"], title="Staff Type Codes", rows=rows,
             notes="Appendix lists 21x..99y patterns; expanded to concrete codes per the stated suffix rule "
                   "(x = 0,1,2; y = 0,3). staff_type_group keeps the published pattern.")


def appx_w_lre():
    def is_header(r):
        return clean(r[0]) == "Code" or clean(r[1]).startswith(("Students with IEPs", "Children with IFSPs"))
    groups, group = {}, ""
    for p in range(46, 55):
        for ti, t in enumerate(_PDF_TABLES[p]):
            trs = [[(c or "") for c in r] for r in t if any((c or "").strip() for c in r)]
            if trs and is_header(trs[0]):
                group = f"{clean(trs[0][1]) or 'Students with IEPs'} – {clean(trs[1][1])}"
            groups[(p, ti)] = group
    titles = {}
    for p in range(46, 55):
        for t in _PDF_TABLES[p]:
            for r in t:
                code = clean(r[0] or "")
                if re.match(r"^\d{1,2}$", code) and r[1]:
                    titles[code] = norm(r[1].split("\n")[0])
    rows = []
    for cells, ref in table_rows(range(46, 55), 0, r"^\d{1,2}$", header_lines=2, header_test=is_header):
        title = titles[cells[0]]
        raw = cells[1]
        rows.append({"code": cells[0], "description": title, "age_group": groups[ref],
                     "definition": raw[len(title):].strip() if raw.startswith(title) else raw})
    write_seed("lre", rows, ["age_group", "definition"])
    register("lre", APPX_PDF.name, "W", "extracted", ["K06"], title="Special Education LRE Codes", rows=rows,
             notes="description = setting name (first line of the cell); age_group from the table section headers.")


def appx_ah_interventions():
    rows, group = [], ""
    for p, ln in page_lines([77, 78]):
        if ln.startswith(("APPENDIX AH", "(Used by", "Code Intervention")):
            continue
        m = re.match(r"^(\d{1,2}) (.+)$", ln)
        if m:
            rows.append({"code": m.group(1), "description": m.group(2), "intervention_group": group})
        else:
            group = ln
    write_seed("intervention", rows, ["intervention_group"])
    register("intervention", APPX_PDF.name, "AH", "extracted", ["V10"], title="Interventions Used", rows=rows)


def appx_am_higher_ed():
    rows = []
    for p, ln in page_lines([83, 84]):
        m = re.match(r"^(\d{8}) (.+) (Washington|Oregon|Idaho|TBD)$", ln)
        if m:
            rows.append({"code": m.group(1), "description": m.group(2), "state": m.group(3)})
    write_seed("higher_ed_institution", rows, ["state"])
    register("higher_ed_institution", APPX_PDF.name, "AM", "extracted", ["D21"],
             title="Higher Education Institution", rows=rows)


def appx_ac_non_public_agency():
    rows = []
    for p in range(68, 72):
        for ti, t in enumerate(_PDF_TABLES[p]):
            status = "closed" if clean(t[0][0]).startswith("Closed Agency") else "active"
            for cells, _ in table_rows([p], 1, r"^\d{1,3}$", tables={(p, ti)}):
                rows.append({"code": cells[1], "description": cells[0], "status": status})
    write_seed("non_public_agency", rows, ["status"])
    register("non_public_agency", APPX_PDF.name, "AC", "extracted", ["K15"], title="Non-Public Agency", rows=rows,
             notes="status = closed for the 'Closed Agency' table. Code 63 is published for both an active "
                   "agency (Cinnamon Hills Youth Crisis Center) and a closed one (Family House Academy).")


def pdf_appendices():
    code_2 = r"^\d{1,2}$"
    appx_simple("behavior", "B", "Behavior", range(10, 16), 0, r"^\d{2}$",
                [("description", 1), ("definition", "rest:2")], ["R08", "R09"])
    appx_simple("country", "C", "National Origin Country Codes", range(16, 23), 1, r"^[A-Z]{3}$",
                [("description", 0)], ["B10"], header_lines=2)
    appx_simple("weapon", "D", "Weapons", range(23, 26), 0, r"^[A-Z]{2}$",
                [("description", 1), ("definition", "rest:2")], ["R10"], header_lines=2)

    def split_star(rows):
        for r in rows:
            r["description"] = r["description"].replace("*", "").strip()
        return rows
    appx_simple("grade_level", "E", "Grade Level Codes", [26], 0, r"^(PK|TK|K1|K2|\d{1,2})$",
                [("description", 1)], ["B13", "H09", "J19"], post=split_star,
                notes="PK: used for students aged 0-5 served by the district but not yet enrolled in TK or K.")

    def split_k(rows):
        out = []
        for r in rows:
            for c in [x.strip() for x in r["code"].split(",")]:
                out.append({**r, "code": c})
        return out
    appx_simple("grade_level_age_assignment", "G", "Grade Level Assignment by Age", [28], 0,
                r"^(PK|TK|K1, K2|K1|K2|\d{1,2})$", [("description", 1)], ["B13"], post=split_k,
                notes="Suggested assignment only (manual B13). 'K1, K2' split into two rows.")
    appx_simple("disability", "I", "Primary Disability Codes", [30], 0, code_2, [("description", 1)], ["I10"])
    appx_simple("student_growth_assessment", "J", "Student Growth Assessments", [31, 32], 1, r"^\d{1,2}$",
                [("description", 0), ("valid_for_q08", 2), ("valid_for_q10", 3), ("lap_literacy_ela", 4),
                 ("lap_math", 5), ("lap_academic_readiness", 6), ("lap_behavior", 7), ("wrc", 8)],
                ["Q08", "Q10"], header_mode="until_code",
                notes="Columns give applicability to Q08/Q10 and to each LAP/WRC program (Q06).")
    appx_simple("school_withdrawal", "M", "School Withdrawal Codes", [34, 35, 36], 0, r"^[A-Z][0-9A-Z]$",
                [("description", 1), ("status_group", 2), ("reporting_guidance", 3)], ["C09"], header_lines=2)
    appx_n_placement_status()
    appx_o_content_area()

    def term_notes(rows):
        for r in rows:
            if r["code"].endswith("*"):
                r["code"] = r["code"].rstrip("*")
                r["valid_elements"] = "H19"
            else:
                r["valid_elements"] = "E08,G07,H19"
        return rows
    appx_simple("term", "P", "Term", [40], 0, r"^[A-Za-z0-9]+\*?$", [("description", 1)],
                ["E08", "G07", "H19"], post=term_notes, extra_cols=["valid_elements"],
                header_test=lambda r: clean(r[0]) == "Term",
                notes="SUM1/SUM2 are valid only in H19 (appendix footnote).")

    appx_u_staff_type()
    appx_w_lre()
    appx_simple("frl_qualification", "X", "Free/Reduced-Price Meal Eligibility Status or Low Income", [55], 0,
                code_2, [("description", 1), ("frl_type", 2)], ["I10"])
    appx_simple("ethnicity", "Y", "Ethnicity Codes", [56, 57], 0, r"^H\d{2}$",
                [("description", 1), ("aggregate", 2)], ["L05"],
                notes="Federal rollup: Hispanic if aggregate = Hispanic/Latino (appendix narrative).")
    appx_simple("race", "Z", "Race Codes", range(58, 67), 0, r"^[A-Z]\d{2}$",
                [("description", 1), ("aggregate", 2), ("race_category", 3)], ["M05"],
                notes="race_category is the federal race rollup; two or more categories => Two or More Races.")
    appx_ac_non_public_agency()
    appx_simple("prek_outcome_entry_exit", "AD", "Special Education Pre-K Early Childhood Entry and Exit Outcomes",
                [72, 73], 0, code_2, [("description", 1), ("definition", "rest:2")],
                ["K16", "K17", "K18", "K19", "K21", "K23"])
    appx_simple("prek_outcome_progress", "AE", "Special Education Pre-K Early Childhood Progress Outcomes",
                [74], 0, code_2, [("description", 1), ("definition", "rest:2")], ["K20", "K22", "K24"])
    def allowable(rows):
        # Footnote: "* These exceptions are considered allowable per state and federal guidance."
        for r in rows:
            r["is_allowable_exception"] = "Y" if "*" in r["description"] else "N"
            r["description"] = re.sub(r"\s*\*\s*", " ", r["description"]).strip()
        return rows
    note = "is_allowable_exception from the appendix footnote marker (*)."
    appx_simple("late_evaluation_reason", "AF", "Reason for Late Initial Evaluation/Eligibility", [75], 0,
                code_2, [("description", 1)], ["U09"], post=allowable, extra_cols=["is_allowable_exception"],
                notes=note)
    appx_simple("late_part_c_transition_reason", "AG", "Reason for Late Transition from Part C", [76], 0,
                code_2, [("description", 1)], ["U12"], post=allowable, extra_cols=["is_allowable_exception"],
                notes=note)
    appx_ah_interventions()
    appx_simple("career_launch_program", "AJ", "Career Launch Program Type", [80, 81], 0, r"^K[0-9A-Z]+$",
                [("description", 3), ("district", 1), ("school", 2)], ["I10"], header_lines=2)
    appx_simple("sensory_disability", "AL", "Student Sensory Disability", [83], 0, r"^\d$",
                [("description", 1)], ["I10"])
    appx_am_higher_ed()

    # Not code lists in this document
    for code_set, appx, title, status, used_by, note in [
        ("county_district", "A", "County District Codes", "external", [],
         "Refer to the Education Directory in EDS."),
        ("avid_school", "H", "Advanced Via Individual Determination (AVID) Schools", "external", ["D08", "H15"],
         "No list: AVID courses report state course code WA0005. Program site is external."),
        ("seal_of_biliteracy_test_result", "L", "WA Seal of Biliteracy / World Language Competency Test Results",
         "retired", [], "Data no longer collected beginning with 2024-25."),
        ("appendix_t", "T", "Intentionally Left Blank", "retired", [], "Appendix T is intentionally blank."),
        ("district_issued_device", "AI", "District-Issued Learning Devices", "retired", ["I10"],
         "Data no longer collected beginning with 2023-24."),
    ]:
        register(code_set, APPX_PDF.name, appx, status, used_by, title=title, notes=note)
    # EDS-sourced elements (not an appendix list, but a registered external domain)
    register("school", "EDS Education Directory", "", "external", [], title="OSPI School Codes",
             notes="A05/H26 valid values come from EDS. H26 also accepts 9999 (out-of-district).")


# --------------------------------------------------------------------------------------
# xlsx appendices (authoritative for F, K, Q, R)
# --------------------------------------------------------------------------------------

def sheet_rows(path, sheet, header_first):
    ws = openpyxl.load_workbook(path, data_only=True)[sheet]
    rows = list(ws.iter_rows(values_only=False))
    for i, r in enumerate(rows):
        vals = [clean(c.value) for c in r]
        if header_first in vals:
            start = vals.index(header_first)
            header = vals[start:]
            out = []
            for rr in rows[i + 1:]:
                cells = rr[start:start + len(header)]
                if all(c.value in (None, "") for c in cells):
                    continue
                out.append(cells)
            return header, out
    raise ValueError(f"{path.name}:{sheet}: header {header_first!r} not found")


def struck(cells) -> bool:
    """Strikethrough on the active sheet marks a removed (archived) code."""
    return any(c.font is not None and c.font.strike for c in cells)


def cell_code(c, decimals=None) -> str:
    v = c.value
    if isinstance(v, float) and decimals is not None:
        return f"{v:.{decimals}f}"
    if isinstance(v, int) and re.fullmatch(r"0+", c.number_format or ""):
        return str(v).zfill(len(c.number_format))  # displayed with leading zeros, e.g. 00000
    if isinstance(v, float) and v.is_integer():
        return str(int(v))
    return clean(v)


def xlsx_f():
    path = XLSX["F"]
    header, active = sheet_rows(path, "Attribute & Program Codes", "Code")
    _, archive = sheet_rows(path, "Archive", "Code")
    _, changes = sheet_rows(path, "Summary of Changes", "Version")
    new_in_v19 = {cell_code(r[1]) for r in changes if cell_code(r[0]) == "19" and clean(r[2].value) == "New"}
    arch = {cell_code(r[0]): r for r in archive if cell_code(r[0])}
    rows = []
    for r in active:
        code = cell_code(r[0])
        if not code:
            continue
        if struck(r[:3]):
            continue  # removed code; taken from the Archive sheet below
        guidance = clean(r[4].value)
        rows.append({"code": code, "description": clean(r[1].value), "record_type": clean(r[2].value),
                     "definition": clean(r[3].value), "status": "active",
                     "valid_from_year": str(CURRENT_YEAR) if code in new_in_v19 else ""})
    active_codes = {r["code"] for r in rows}
    for code, r in arch.items():
        if code in active_codes:
            PROBLEMS.append(f"appendix F: code {code} is active (not struck) and archived")
            continue
        rows.append({"code": code, "description": clean(r[1].value), "record_type": clean(r[2].value),
                     "definition": "", "status": "archived",
                     "valid_to_year": year_end(clean(r[3].value))})
    write_seed("attribute_program", rows, ["record_type", "definition", "status"])
    write_i10_map({clean(r[0].value) and cell_code(r[0]): (clean(r[1].value), clean(r[4].value)) for r in active})
    register("attribute_program", path.name, "F", "extracted", ["I06", "Q06"],
             title="Student Attributes and Programs", rows=rows,
             notes="xlsx is authoritative. Struck-through rows on the active sheet are archived; archived "
                   "codes carry valid_to_year from 'Last Active School Year'. "
                   "valid_from_year set only for codes marked New in v19. Q06 values are a subset "
                   "(6, 7, 37, 38, 44). I06 -> I10 code set map: catalog/i10_qualification_map.csv.")


# I06 program -> code set that governs I10 Qualification Code (decisions log D-008).
# guidance_quote rows are verified against the Appendix F reporting guidance for that code;
# name_match rows pair the I10 sub-list heading with the program name and need confirmation.
I10_MAP = [
    ("36", "disability", "guidance_quote", "age-specific disability qualification code (code 1 or 15) in Element I10"),
    ("40", "reengagement_program", "guidance_quote", "If Element I06 contains a valid value of 40, data must also be submitted in Elements I07 – Start Date and Element I10 – Qualification Code."),
    ("41", "language", "guidance_quote", "Element I10 – Qualification Code is the language in which the student earned the Seal of Biliteracy"),
    ("42", "language", "guidance_quote", "Element I10 – Qualification Code is the language in which the student is identified as Biliteracy Proficient"),
    ("80", "sensory_disability", "guidance_quote", "a valid value from Appendix AL – Student Sensory Disability"),
    ("81", "language", "guidance_quote", "Element I10 – Qualification Code is the language in which the student earned the Intermediate Seal of Biliteracy"),
    ("82", "language", "guidance_quote", "Element I10 – Qualification Code is the language in which the student is identified as Intermediate Proficient"),
    ("83", "language", "guidance_quote", "Element I10 – Qualification Code is the language in which the student earned the Advanced Seal of Biliteracy"),
    ("84", "language", "guidance_quote", "Element I10 – Qualification Code is the language in which the student is identified as Advanced Proficient"),
    ("19", "frl_qualification", "name_match", "I10 group 'Free and Reduced Meal Qualification Codes' ~ program 'Free/Reduced Meals Participation/Eligibility'"),
    ("30", "i10_grads_qualification", "name_match", "I10 group 'GRADS Program Qualification Codes' ~ program 'GRADS (Graduation, Reality and Dual-Role Skills)'"),
    ("32", "i10_gifted_referral", "name_match", "I10 group 'Gifted Program Referral Codes' ~ program 'Gifted – ...'"),
    ("33", "i10_gifted_referral", "name_match", "I10 group 'Gifted Program Referral Codes' ~ program 'Gifted – ...'"),
    ("34", "i10_gifted_referral", "name_match", "I10 group 'Gifted Program Referral Codes' ~ program 'Gifted – ...'"),
    ("35", "i10_gifted_referral", "name_match", "I10 group 'Gifted Program Referral Codes' ~ program 'Gifted – ...'"),
    ("69", "career_launch_program", "name_match", "I10 group 'Career Launch Program Type Codes' ~ program 'Career Launch'"),
]


def write_i10_map(programs: dict[str, tuple[str, str]]):
    out = []
    for code, cs, kind, evidence in I10_MAP:
        name, guidance = programs.get(code, ("", ""))
        if not name:
            PROBLEMS.append(f"I10 map: I06 code {code} not an active Appendix F code")
        if kind == "guidance_quote" and norm(evidence) not in norm(guidance):
            PROBLEMS.append(f"I10 map: quote for I06 {code} not found in its Appendix F guidance")
        out.append({"manual_version": MANUAL_VERSION, "i06_code": code, "i06_program": name, "i10_code_set": cs,
                    "evidence_type": kind, "evidence": evidence})
    with open(CATALOG / "i10_qualification_map.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(out[0].keys()))
        w.writeheader()
        w.writerows(out)


def xlsx_k():
    path = XLSX["K"]
    _, active = sheet_rows(path, "Active Language Codes", "Language Code")
    _, archived = sheet_rows(path, "Archived Language Codes", "Language Code")
    _, changes = sheet_rows(path, "Summary of Changes", "Version")
    new_year = {cell_code(r[1]): year_end(clean(r[4].value)) for r in changes if "New" in clean(r[3].value)}
    arch = {cell_code(r[0]): (clean(r[2].value), clean(r[3].value)) for r in archived if cell_code(r[0])}
    def last_valid(archived_sy):
        # Archived in school year Y (struck on that year's active list) => last valid year is Y-1.
        y = year_end(archived_sy)
        return str(int(y) - 1) if y else ""
    rows = []
    for r in active:
        code = cell_code(r[0])
        if not code:
            continue
        gone = struck(r[:2])
        if gone != (clean(r[2].value) == "Archived"):
            PROBLEMS.append(f"appendix K: code {code} strike/change-status mismatch")
        ay = arch.get(code, ("", ""))[0]
        rows.append({"code": code, "description": clean(r[1].value), "change_status": clean(r[2].value),
                     "notes": clean(r[3].value), "recommended_language": clean(r[4].value),
                     "archived_school_year": ay, "status": "archived" if gone else "active",
                     "valid_from_year": new_year.get(code, ""), "valid_to_year": last_valid(ay) if gone else ""})
    listed = {r["code"] for r in rows}
    for code, (yr, note) in arch.items():
        if code in listed:
            continue
        name = next(clean(r[1].value) for r in archived if cell_code(r[0]) == code)
        rows.append({"code": code, "description": name, "change_status": "Archived", "notes": note,
                     "recommended_language": "", "archived_school_year": yr, "status": "archived",
                     "valid_to_year": last_valid(yr)})
    write_seed("language", rows, ["change_status", "notes", "recommended_language", "archived_school_year",
                                  "status"])
    register("language", path.name, "K", "extracted", ["B17", "B18", "B43", "D15", "I10"], title="Language Codes",
             rows=rows, notes="xlsx is authoritative. Archived codes are struck through on the Active sheet; "
                              "archived in school year Y => valid_to_year = Y-1 (last valid year). "
                              "'Future Archive' codes remain active.")


def xlsx_q():
    path = XLSX["Q"]
    _, active = sheet_rows(path, "AP, IB & Cambridge Codes", "Program")
    _, changes = sheet_rows(path, "Summary of Changes", "Version")
    new_titles = {clean(r[2].value) for r in changes if clean(r[3].value) == "New Code"}
    rows = []
    for r in active:
        code = cell_code(r[4], decimals=2)
        if not code:
            continue
        title = clean(r[2].value)
        rows.append({"code": code, "description": title, "program": clean(r[0].value),
                     "subject": clean(r[1].value), "abbreviation": clean(r[3].value),
                     "valid_from_year": str(CURRENT_YEAR) if title in new_titles else ""})
    write_seed("ap_ib_cambridge_course", rows, ["program", "subject", "abbreviation"])
    register("ap_ib_cambridge_course", path.name, "Q", "extracted", ["D09", "H16"],
             title="AP, IB & Cambridge International Course Codes", rows=rows,
             notes="xlsx v19.1 (June 2026) is authoritative. Codes are numeric(4,2) rendered with 2 decimals. "
                   "Archived sheet is empty. valid_from_year from v19 'New Code' entries matched by title.")


def xlsx_r():
    path = XLSX["R"]
    _, active = sheet_rows(path, "Reengagement Codes", "Qualification Code")
    _, archive = sheet_rows(path, "Archive", "Qualification Code")
    arch = {}
    for r in archive:
        if cell_code(r[0]):
            arch.setdefault(cell_code(r[0]), []).append(r)
    rows = []
    for r in active:
        code = cell_code(r[0])
        if not code:
            continue
        gone = struck(r[:3])
        provider, site = clean(r[2].value), clean(r[3].value)
        rows.append({"code": code, "description": " – ".join(x for x in (provider, site) if x),
                     "resident_district": clean(r[1].value), "provider_program": provider, "site": site,
                     "consortium_member": clean(r[4].value), "path_ged": clean(r[5].value),
                     "path_hs_diploma": clean(r[6].value), "path_college": clean(r[7].value),
                     "path_career": clean(r[8].value), "change_status": clean(r[9].value),
                     "status": "archived" if gone else "active",
                     "valid_from_year": str(CURRENT_YEAR) if clean(r[9].value) == "New" else "",
                     "valid_to_year": year_end(clean(arch[code][0][3].value)) if gone and code in arch else ""})
        if gone and code in arch:
            arch[code].pop(0)
    for code, rs in arch.items():
        for r in rs:
            # Archive-only codes, and earlier meanings of reused codes (e.g. 23).
            provider = clean(r[2].value)
            rows.append({"code": code, "description": provider, "resident_district": clean(r[1].value),
                         "provider_program": provider, "status": "archived",
                         "valid_to_year": year_end(clean(r[3].value))})
    write_seed("reengagement_program", rows, ["resident_district", "provider_program", "site", "consortium_member",
                                              "path_ged", "path_hs_diploma", "path_college", "path_career",
                                              "change_status", "status"])
    register("reengagement_program", path.name, "R", "extracted", ["I10"],
             title="Open Doors Youth Reengagement Program Codes", rows=rows,
             notes="xlsx is authoritative. Struck-through rows on the active sheet are archived; valid_to_year "
                   "from 'Last Valid School Year'. Code 23 was reused (Atlantic Education to 2017-18, now "
                   "Chimacum), so it has two rows.")


def new_in_v19(path, sheet, code_idx, change_idx) -> set[str]:
    _, changes = sheet_rows(path, sheet, "Version")
    return {cell_code(r[code_idx]) for r in changes
            if cell_code(r[0]).startswith("19") and "new" in clean(r[change_idx].value).lower()}


def xlsx_active_archive(code_set, appx, path, title, used_by, *, active, cols, archive, archive_cols,
                        strike_n=2, new_codes=frozenset(), code_fn=None, notes=""):
    """Generic reader for the OSPI appendix workbooks: an active sheet plus an Archive sheet
    with a last-active school year. Struck-through active rows are archived (D-016).

    active / archive: (sheet name, header token). cols / archive_cols: [(column, index)], the
    first being 'description'; archive_cols must include ('_year', idx) for the last active year.
    """
    _, act = sheet_rows(path, *active)
    _, arc = sheet_rows(path, *archive)
    arch: dict[str, list] = {}
    for r in arc:
        c = cell_code(r[0])
        if c:
            arch.setdefault(c, []).append(r)
    rows = []
    for r in act:
        raw = cell_code(r[0])
        if not raw:
            continue
        code, extra = code_fn(raw) if code_fn else (raw, {})
        gone = struck(r[:strike_n])
        row = {"code": code, **{n: clean(r[i].value) for n, i in cols}, **extra,
               "status": "archived" if gone else "active",
               "valid_from_year": str(CURRENT_YEAR) if code in new_codes else ""}
        if gone and arch.get(code):
            a = arch[code].pop(0)
            row["valid_to_year"] = year_end(clean(a[dict(archive_cols)["_year"]].value))
        rows.append(row)
    # Remaining archive entries. Same code + same name as an existing row => same meaning:
    # merge (latest last-active year wins; an unstruck active row wins and is reported).
    # A different name => the code was reused, so the earlier meaning is kept as its own row.
    by_code: dict[str, list[dict]] = {}
    for r in rows:
        by_code.setdefault(r["code"], []).append(r)
    ac = dict(archive_cols)
    for code, rs in arch.items():
        for a in rs:
            desc, yr = clean(a[ac["description"]].value), year_end(clean(a[ac["_year"]].value))
            same = [r for r in by_code.get(code, []) if same_text(r["description"]) == same_text(desc)]
            if same:
                r = same[0]
                if r["status"] == "active":
                    REUSED.append(f"{code_set} {code} (active, also archived {yr})")
                elif yr > r.get("valid_to_year", ""):
                    r["valid_to_year"] = yr
                continue
            if code in by_code:
                REUSED.append(f"{code_set} {code} (reused; earlier meaning to {yr})")
            row = {"code": code, "status": "archived"}
            for n, i in archive_cols:
                row["valid_to_year" if n == "_year" else n] = yr if n == "_year" else clean(a[i].value)
            rows.append(row)
            by_code.setdefault(code, []).append(row)
    extra_cols = [n for n, _ in cols if n != "description"] + \
        [k for k in (code_fn(rows[0]["code"])[1] if code_fn else {})] + \
        [n for n, _ in archive_cols if n not in ("description", "_year") and n not in dict(cols)] + ["status"]
    write_seed(code_set, rows, extra_cols)
    register(code_set, path.name, appx, "extracted", used_by, title=title, rows=rows,
             notes=("xlsx is authoritative. Struck-through active rows and Archive-sheet codes are archived, "
                    "valid_to_year from 'Last Active School Year'. " + notes).strip())
    return rows


def xlsx_external_appendices():
    aa_ab = XLSX["AA_AB"]
    xlsx_active_archive(
        "online_provider", "AA", aa_ab, "Approved Online Provider Codes", ["E10", "T13"],
        active=("AA - Online Provider Codes", "Code"), cols=[("description", 1)],
        archive=("AA - Archive", "Code"), archive_cols=[("description", 1), ("_year", 2)],
        new_codes=new_in_v19(aa_ab, "AA - Summary of Changes", 1, 2))
    xlsx_active_archive(
        "online_program", "AB", aa_ab, "Approved Online Program Codes", ["E11", "T14"],
        active=("AB - Online Program Codes", "Code"), cols=[("description", 2), ("resident_district", 1)],
        archive=("AB - Archive", "Code"), archive_cols=[("description", 1), ("_year", 2)], strike_n=3,
        new_codes=new_in_v19(aa_ab, "AB - Summary of Changes", 1, 2))
    ak = XLSX["AK"]
    xlsx_active_archive(
        "industry_certification", "AK", ak, "Industry Recognized Certifications", ["D17", "E15", "H31"],
        active=("IRC Codes", "VALID VALUE**"),
        cols=[("description", 1), ("career_cluster", 2), ("cte_program_area", 3), ("source_information", 4)],
        archive=("Archived", "Code"), archive_cols=[("description", 1), ("_year", 2)],
        new_codes=new_in_v19(ak, "Summary of Changes", 1, 2),
        notes="Codes 1-3 are the 'no certification offered/earned' and 'other' sentinels used by D17/H31 rules.")
    cip = XLSX["S"]
    xlsx_active_archive(
        "cip", "S", cip, "CIP Code Numbers and Course Titles for Approved CTE Courses", ["D10", "H17"],
        active=("CIP Codes", "CIP Code"),
        cols=[("description", 3), ("definition", 4), ("suggested_state_course_codes", 1),
              ("teacher_cert_v_codes", 2), ("nontraditional_gender", 5), ("exploratory_or_preparatory", 6),
              ("career_cluster", 7), ("cluster_pathway", 8), ("ctso", 9), ("program_area", 10),
              ("change_status", 11)],
        archive=("Archive", "CIP Code"), archive_cols=[("description", 1), ("_year", 2), ("cip_changed_to", 3)],
        strike_n=4, new_codes=new_in_v19(cip, "Summary of Changes", 1, 2),
        notes="Multi-valued attributes (suggested state course codes, V-codes) kept as published text. "
              "H17 accepts CIP codes approved in the course's own year, so archived codes are retained.")
    v = XLSX["V"]

    def v_code(raw):
        # One row publishes '03206 21063' (IB Design Technology, "New, Recoded from 03206").
        parts = raw.split()
        return parts[-1], {"recoded_from": parts[0] if len(parts) > 1 else ""}
    rows = xlsx_active_archive(
        "state_course", "V", v, "State Course Codes", ["D08", "H15", "T11"],
        active=("State Course Codes", "State Course Code"),
        cols=[("description", 1), ("definition", 2), ("ap_ib_type", 3), ("computer_science", 4),
              ("subject_area_code", 5), ("subject_area_name", 6), ("wa_state_only", 7), ("change_status", 8)],
        archive=("Archive", "State Course Code"), archive_cols=[("description", 1), ("_year", 2), ("notes", 3)],
        strike_n=2, code_fn=v_code, new_codes=new_in_v19(v, "Summary of Changes", 1, 3),
        notes="Integer codes are zero-padded per the sheet's 00000 display format (SCED codes are 5 digits). "
              "subject_area_code zero-padded to 2 digits to match the Course Subject Areas sheet. "
              "WA00xx are Washington-only codes (AVID = WA0005, Appendix H).")
    # normalize subject area code padding in the written seed
    seed_path = SEEDS / "state_course.csv"
    with open(seed_path, newline="") as fh:
        data = list(csv.DictReader(fh))
    for r in data:
        if r["subject_area_code"].isdigit():
            r["subject_area_code"] = r["subject_area_code"].zfill(2)
    with open(seed_path, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(data[0].keys()))
        w.writeheader()
        w.writerows(data)
    _, subj = sheet_rows(v, "Course Subject Areas", "Code")
    srows = [{"code": clean(r[0].value).zfill(2), "description": clean(r[1].value)} for r in subj if clean(r[0].value)]
    write_seed("course_subject_area", srows, [])
    register("course_subject_area", v.name, "V", "extracted", [], title="Course Subject Areas (SCED)", rows=srows,
             notes="Rollup for state_course.subject_area_code. Sheet header still reads 2025-26 v18.0.")


# --------------------------------------------------------------------------------------
# Inline code sets (manual valid values)
# --------------------------------------------------------------------------------------

# element(s) -> code set name. Elements sharing a set must have identical inline lists
# (checked), except where noted. Elements whose inline list duplicates an appendix set are
# registered against that appendix set instead (INLINE_TO_APPENDIX).
INLINE_SETS = {
    "gender": ["B12"], "homeless_status": ["B21"], "private_school_part_time": ["B22"],
    "home_school_part_time": ["B23"], "exchange_status": ["B24"], "military_parent": ["B35"],
    "asvab_status": ["B39"], "credit_waiver": ["B42"], "transition_consent": ["K27"], "yes_no": ["C10", "Q17", "S10"], "school_choice": ["C11"],
    "confirmed_transfer_in": ["C14"], "course_designation": ["D07", "H13", "T10"],
    "cte_equivalency_identification": ["D12"], "cte_equivalency": ["D13"], "dual_language_type": ["D14"],
    "course_level": ["D16", "T18"], "work_based_learning_offered": ["D20"], "ale_course_type": ["E09", "H27", "T12"],
    "teacher_indicator": ["G10"], "letter_grade": ["H10", "T15"], "cte_assessment": ["H24"],
    "work_based_learning_activity": ["H32"], "program_exit_reason": ["I09"],
    "el_instructional_model": ["J06"], "el_exit_reason": ["J09"], "el_program_designation": ["J17"],
    "el_placement_test": ["J18"], "el_placement_level_score": ["J23"], "sped_exit_reason": ["K09"],
    "interpreter_annual_iep": ["K26"], "absence_code": ["N07"], "academic_growth": ["Q09"],
    "extended_learning_intervention": ["Q15"], "regular_day_intervention": ["Q16"],
    "exclusionary_action": ["R11"], "iaes": ["R15"], "academic_services": ["R16"], "behavior_services": ["R17"],
    "expulsion_extension_petition": ["R20"], "reengagement_plan": ["R21"], "appeal_code": ["R23"],
    "safety_staff_involvement": ["R24", "S12"], "safety_staff_force": ["R25"], "student_arrested": ["R26"],
    "interpreter_reengagement_meeting": ["R27"], "restraint_isolation_type": ["S09"],
    "initial_eval_outcome": ["U10"], "interpreter_initial_iep": ["U13"], "support_code": ["V06"],
    "support_identification_assessment": ["V07"], "support_determination": ["V09"],
}
INLINE_TO_APPENDIX = {
    "D06": "content_area", "T09": "content_area", "J21": "el_placement_status", "R10": "weapon",
    "Q06": "attribute_program",
}
# I10's inline sub-lists (groups keyed by the I06 program family).
I10_GROUPS = {"Gifted Program Referral Codes": "gifted_referral", "GRADS Program Qualification Codes":
              "grads_qualification"}


def parse_inline(s: str) -> list[tuple[str, str]]:
    out = []
    for part in s.split("|"):
        code, _, desc = part.partition("=")
        out.append((code, desc))
    return out


def same_text(s: str) -> str:
    """Comparison key: case-insensitive, ignores the source's stray 'in- person' spacing."""
    return re.sub(r"(\w)- (\w)", r"\1-\2", s).lower()


PRIOR_TO = re.compile(r"\(only applicable for school years prior to (\d{4})-\d{2}\)")


def inline_sets(elements: dict[str, dict]):
    for code_set, eids in INLINE_SETS.items():
        # Union of the elements' lists, in first-seen order. Codes not valid for every element
        # carry valid_elements; descriptions come from the first element that lists the code.
        merged: dict[str, dict] = {}
        for e in eids:
            for code, desc in parse_inline(elements[e]["inline_valid_values"]):
                if code not in merged:
                    merged[code] = {"desc": desc, "elements": []}
                elif same_text(merged[code]["desc"]) != same_text(desc):
                    PROBLEMS.append(f"inline set {code_set}: {e} describes {code} differently")
                merged[code]["elements"].append(e)
        partial = any(len(m["elements"]) != len(eids) for m in merged.values())
        groups = elements[eids[0]]["inline_value_groups"]
        gmap = {}
        for g in filter(None, groups.split("|")):
            name, _, codes = g.partition(":")
            for c in filter(None, codes.split(",")):
                gmap[c] = name
        rows = []
        for code, m in merged.items():
            desc = m["desc"]
            r = {"code": code, "description": desc or code}
            pm = PRIOR_TO.search(desc)
            if pm:
                r["valid_to_year"] = pm.group(1)  # prior to 2014-15 => last valid year ends 2014
            if code_set == "letter_grade":
                # "A 4.0" rows carry grade points; "P Pass" rows carry a label.
                r["grade_points"] = desc if re.match(r"^\d\.\d$", desc) else ""
                r["description"] = code if r["grade_points"] else desc
            if gmap:
                r["value_group"] = gmap.get(code, "")
            if partial:
                r["valid_elements"] = ",".join(m["elements"])
            rows.append(r)
        extra = (["grade_points"] if code_set == "letter_grade" else []) + (["value_group"] if gmap else []) \
            + (["valid_elements"] if partial else [])
        write_seed(code_set, rows, extra)
        note = "Inline valid values from the manual."
        if code_set == "letter_grade":
            note = "Manual lists letter grades with grade points (e.g. A 4.0); grade_points blank for non-graded marks (P, CR, ...)."
        if code_set == "course_designation":
            note = "D07/H13 pack several single-letter codes without a delimiter (e.g. 'IC')."
        if partial:
            note += " valid_elements marks codes not valid for every element."
        register(code_set, "2026-27_cedars_manual_v19.pdf", "", "extracted", eids,
                 title=elements[eids[0]]["element_name"], rows=rows, notes=note)

    # I10 inline sub-lists
    i10 = elements["I10"]
    items = parse_inline(i10["inline_valid_values"])
    pos = 0
    for g in i10["inline_value_groups"].split("|"):
        name, _, codes = g.partition(":")
        if name not in I10_GROUPS:
            continue
        codes = codes.split(",")
        rows = [{"code": c, "description": items[pos + i][1]} for i, c in enumerate(codes)]
        # items are in document order; advance past this group's items
        assert all(items[pos + i][0] == c for i, c in enumerate(codes)), name
        pos += len(codes)
        cs = f"i10_{I10_GROUPS[name]}"
        write_seed(cs, rows, [])
        register(cs, "2026-27_cedars_manual_v19.pdf", "", "extracted", ["I10"], title=f"I10 {name}", rows=rows,
                 notes="I10 sub-list; applies when I06 is the corresponding program (see decisions log D-008).")


# --------------------------------------------------------------------------------------
# Registry: referenced_by / coverage
# --------------------------------------------------------------------------------------

def finalize_registry(elements: dict[str, dict]):
    by_appx = {r["appendix"]: r for r in REGISTRY if r["appendix"]}
    by_name = {r["code_set"]: r for r in REGISTRY}
    refs: dict[str, set[str]] = defaultdict(set)
    for eid, e in elements.items():
        for a in filter(None, e["appendix_refs"].split(",")):
            if a in by_appx:
                refs[by_appx[a]["code_set"]].add(eid)
            else:
                PROBLEMS.append(f"{eid}: references unregistered Appendix {a}")
        if e["inline_valid_values"] and eid in INLINE_TO_APPENDIX:
            refs[INLINE_TO_APPENDIX[eid]].add(eid)
            used = set(filter(None, by_name[INLINE_TO_APPENDIX[eid]]["used_by"].split(",")))
            if eid not in used:
                PROBLEMS.append(f"{eid}: inline values mapped to {INLINE_TO_APPENDIX[eid]} but not in its used_by")
        vv = e["valid_values_text"]
        if "eds.ospi.k12.wa.us" in vv or "Refer to EDS" in vv:
            # EDS-sourced domains. A03 (district name) only points at EDS; it takes no code.
            target = "school" if eid in ("A05", "H26") else "county_district"
            refs[target].add(eid)
            if eid != "A03":
                u = set(filter(None, by_name[target]["used_by"].split(",")))
                by_name[target]["used_by"] = ",".join(sorted(u | {eid}))
    for r in REGISTRY:
        used = set(filter(None, r["used_by"].split(",")))
        r["referenced_by"] = ",".join(sorted(refs.get(r["code_set"], set()) | used))

    # Coverage: every element with appendix refs or inline values maps to a registered set.
    covered = defaultdict(set)
    for r in REGISTRY:
        for e in filter(None, r["referenced_by"].split(",")):
            covered[e].add(r["code_set"])
    for eid, e in elements.items():
        if (e["appendix_refs"] or e["inline_valid_values"]) and not covered.get(eid):
            PROBLEMS.append(f"{eid}: has appendix refs/inline values but no registered code set")


def main() -> int:
    with open(CATALOG / "elements.csv", newline="") as fh:
        elements = {r["element_id"]: r for r in csv.DictReader(fh)}
    for old in SEEDS.glob("*.csv"):
        old.unlink()
    load_pdf()
    pdf_appendices()
    xlsx_f()
    xlsx_k()
    xlsx_q()
    xlsx_r()
    xlsx_external_appendices()
    inline_sets(elements)
    finalize_registry(elements)

    REGISTRY.sort(key=lambda r: (r["appendix"] == "", len(r["appendix"]), r["appendix"], r["code_set"]))
    with open(CATALOG / "code_sets.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(REGISTRY[0].keys()))
        w.writeheader()
        w.writerows(REGISTRY)
    if REUSED:
        print(f"codes with an archived earlier row and an active row: {', '.join(REUSED)}")
    by_status = defaultdict(int)
    for r in REGISTRY:
        by_status[r["status"]] += 1
    print(f"code sets: {len(REGISTRY)} {dict(by_status)}; seed files: {len(list(SEEDS.glob('*.csv')))}")
    if PROBLEMS:
        print("\nPROBLEMS:")
        for p in PROBLEMS:
            print("  -", p)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
