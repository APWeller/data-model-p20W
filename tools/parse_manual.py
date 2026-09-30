"""Phase 1: parse the CEDARS data manual into catalog/elements.csv and catalog/files.csv.

Usage:  .venv/bin/python tools/parse_manual.py

Sources of truth, in order of precedence:
  1. Element definitions in the body ("DATA FILE AND ELEMENT DEFINITIONS" up to
     "PUBLICATION HISTORY"). A heading `Element X99 – Name` counts only when a
     `Field Name:` line follows within a few lines.
  2. The table of contents, for names of inactive elements whose body heading reads
     "No Longer An Active Data Element".
  3. The Data Element Summary (pp. 25-37), for key-column flags and inactive flags.
  4. The publication history, for File P element IDs and names (File P has no body
     definitions in v19).
"""

from __future__ import annotations

import csv
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pdf_text import REPO, extract_pages, lines_with_pages  # noqa: E402

MANUAL = REPO / "sources" / "2026-27_cedars_manual_v19.pdf"
MANUAL_VERSION = "19.0"
SCHOOL_YEAR = "2026-27"
OUT = REPO / "catalog"

HEADER_RE = re.compile(r"^2026-27 CEDARS Data Manual Page \| \d+$")
DASH = r"[–—-]"
ELEMENT_HEAD = re.compile(rf"^Element ([A-Z]\d{{2}})\s*{DASH}\s*(.*)$")
FILE_HEAD = re.compile(r"^(.+?) (?:File )?\(([A-V])\)(?: \(No longer an active data file\))?$")

EXPECTED = dict(A=8, B=45, C=14, D=21, E=16, F=9, G=12, H=32, I=10, J=23, K=27, L=6, M=6,
                N=7, P=24, Q=17, R=27, S=14, T=20, U=13, V=10)

LABELS = [
    ("field_name", "Field Name:"),
    ("data_type", "Data Type:"),
    ("size", "Size:"),
    ("nullable", "Allow NULL?"),
    ("description", "Description:"),
    ("business_rules", "Business Rules:"),
    ("business_rules", "Business Rule:"),
    ("example", "Example:"),
    ("valid_values", "Valid Values:"),
    ("validations", "Validations:"),
    ("last_updated", "Last Updated:"),
]

# Multi-valued elements: CLAUDE.md candidates, each verified by a verbatim quote from the
# element's own text (checked at build time). encoding = how values are packed in the field.
MULTI_VALUED = {
    "B43": ("comma", "Must be a valid value(s) from the Language Codes"),
    "D07": ("concatenated", "may also be reported with T – CTE Dual Credit (Tech Prep) in Element D07"),
    "D17": ("comma", "more than one valid value may be used (separated by a comma)"),
    "D20": ("comma", "More than one valid value may be used (separated by a comma)"),
    "D21": ("comma", "multiple valid values may be submitted (separated by a comma)"),
    "H13": ("concatenated", "may also be reported with T – CTE Dual Credit (Tech Prep) in Element H13"),
    "H31": ("comma", "more than one valid value may be used (separated by a comma)"),
    "H32": ("comma", "More than one valid value may be used (separated by a comma)"),
    "T10": ("concatenated", "may also be reported with T – CTE Dual Credit (Tech Prep) in Element T10"),
    "R09": ("comma", "reported as a string with commas separating the valid values"),
    "V10": ("comma", "identify all of the interventions offered from the list of valid values"),
}
# CLAUDE.md candidates that the v19 text cannot confirm (inactive, no business rules).
MULTI_UNVERIFIABLE = {"E15", "E16"}
# Generic signals used only to flag elements *not* in MULTI_VALUED for human review.
MULTI_PATTERNS = [
    r"separated by (?:a )?comma", r"commas? separating", r"comma[\s-]*(?:separated|delimited)",
    r"multiple (?:valid )?values? may be", r"more than one valid value may",
]

# Names for inactive elements whose body heading reads "No Longer An Active Data Element".
# Taken from the manual's publication history; each is verified against the manual text.
INACTIVE_NAMES = {
    "B11": "CSRS Ethnicity Code",
    "B19": "Social Security Number",
    "B25": "Is Student in Foster Care",
    "C07": "School Entry Code",
    "C13": "Cumulative Number of Unexcused Absences Enrollment Period",
    "D11": "Is Direct Transcription Available",
    "H05": "Location ID",
    "H06": "Staff ID",
    "H20": "Is the Student a Career and Technical Education (CTE) Program Completer",
    "H21": "Did student receive a state or nationally recognized industry certification",
    "H22": "Is Direct Transcription Available",
    "H28": "CTE Course Equivalency Identification",
    "H29": "CTE Credit Equivalency",
    "J10": "Placement Test Scale Score",
    "J11": "Placement Test Level Score",
    "J12": "Placement Test Date",
    "J14": "Initial USA School Enrollment",
    "J15": "Number of Months US Attendance",
    "J16": "Number of Months Non US Formal Education",
    "K10": "Referral Date",
    "K11": "Initial Eligibility Date",
    "K12": "Last IEP Review Date",
    "K13": "Last Evaluation Date",
}


def norm(s: str) -> str:
    s = s.replace("–", "–").replace("—", "–").replace("’", "'").replace("‘", "'")
    s = s.replace("“", '"').replace("”", '"').replace(" ", " ")
    return re.sub(r"[ \t]+", " ", s).strip()


def join_wrapped(a: str, b: str) -> str:
    """Join two wrapped PDF lines; 'in-' + 'person' -> 'in-person'."""
    if re.search(r"[A-Za-z]-$", a) and re.match(r"^[a-z]", b):
        return a + b
    return a + " " + b


def join_text(lines: list[str]) -> str:
    """Join wrapped PDF lines. Bullets and list items keep their own line."""
    out: list[str] = []
    for ln in lines:
        ln = norm(ln)
        if not ln:
            continue
        if out and not re.match(r"^(?:[•o▪\-]\s|\d+\.\s|[A-Z0-9]{1,5} – )", ln):
            out[-1] = join_wrapped(out[-1], ln)
        else:
            out.append(ln)
    return "\n".join(out)


# --------------------------------------------------------------------------------------
# Regions
# --------------------------------------------------------------------------------------

def find_regions(lines: list[tuple[int, str]]) -> dict[str, tuple[int, int]]:
    idx = {name: [i for i, (_, l) in enumerate(lines) if l.strip() == name]
           for name in ("DATA FILE AND ELEMENT DEFINITIONS", "DATA ELEMENT SUMMARY",
                        "PUBLICATION HISTORY", "TABLE OF CONTENTS")}
    body_start = idx["DATA FILE AND ELEMENT DEFINITIONS"][-1]
    body_end = idx["PUBLICATION HISTORY"][-1]
    summ_start = idx["DATA ELEMENT SUMMARY"][-1]
    toc_start = idx["TABLE OF CONTENTS"][-1]
    intro = next(i for i, (_, l) in enumerate(lines) if l.strip() == "Introduction to CEDARS")
    return {"toc": (toc_start, intro), "summary": (summ_start, body_start),
            "body": (body_start, body_end), "history": (body_end, len(lines))}


# --------------------------------------------------------------------------------------
# Table of contents: element names (used for inactive elements)
# --------------------------------------------------------------------------------------

def parse_toc(lines: list[str]) -> dict[str, str]:
    names: dict[str, str] = {}
    buf: str | None = None
    for raw in lines:
        l = norm(raw)
        m = ELEMENT_HEAD.match(l)
        if m:
            buf = l
        elif buf is not None:
            buf += " " + l
        else:
            continue
        m2 = re.match(rf"^Element ([A-Z]\d{{2}})\s*{DASH}\s*(.*?)\s*\.{{3,}}\s*\d+$", buf)
        if m2:
            names[m2.group(1)] = norm(m2.group(2))
            buf = None
        elif buf.count(" ") > 40:
            buf = None
    return names


# --------------------------------------------------------------------------------------
# Data Element Summary: key flags and inactive flags
# --------------------------------------------------------------------------------------

SUMMARY_TYPE = re.compile(r"\b(char|varchar|int|numeric|date)\b\s*(?:\(\s*([\d,\s]+)\))?", re.I)


def parse_summary_types(lines: list[str]) -> dict[str, tuple[str, str]]:
    """Data type and size per element from the Data Element Summary (fallback/cross-check only)."""
    joined = [norm(l) for l in lines]
    out: dict[str, tuple[str, str]] = {}
    for i, l in enumerate(joined):
        m = re.match(r"^(?:Yes )?([A-V]\d{2})\b(.*)$", l)
        if not m:
            continue
        own = m.group(2)
        seg = own
        for nxt in joined[i + 1:i + 5]:
            if re.match(r"^(?:Yes )?[A-V]\d{2}\b", nxt) or nxt.startswith("Key Column"):
                break
            seg += " " + nxt
        # Element names and rule text contain words like "Date"; prefer a type with an explicit
        # size, else the last type word on the element's own line.
        sized = [t for t in SUMMARY_TYPE.finditer(seg) if t.group(2)]
        bare = list(SUMMARY_TYPE.finditer(own))
        t = sized[0] if sized else (bare[-1] if bare else None)
        if t:
            out[m.group(1)] = (t.group(1).lower(), (t.group(2) or "").replace(" ", ""))
    return out


def parse_summary(lines: list[str]) -> tuple[set[str], set[str]]:
    keys: set[str] = set()
    inactive: set[str] = set()
    joined = [norm(l) for l in lines]
    for i, l in enumerate(joined):
        m = re.match(r"^Yes ([A-V]\d{2})\b", l)
        if m:
            keys.add(m.group(1))
        for eid in re.findall(r"\b([A-V]\d{2})\b", l):
            window = " ".join(joined[i:i + 4])
            # The inactive note sits on the element's own row or wraps onto the next lines
            # before the following element ID begins.
            seg = window.split(eid, 1)[1]
            nxt = re.search(r"\b[A-V]\d{2}\b", seg)
            if nxt:
                seg = seg[:nxt.start()]
            if re.search(r"Element is inactive", seg, re.I):
                inactive.add(eid)
    return keys, inactive


# --------------------------------------------------------------------------------------
# Body: file sections and element definitions
# --------------------------------------------------------------------------------------

def parse_body(lines: list[tuple[int, str]]):
    files: dict[str, dict] = {}
    elements: list[dict] = []
    n = len(lines)
    i = 0
    current_file: str | None = None
    while i < n:
        pno, raw = lines[i]
        l = norm(raw)
        # File section header: "<Name> File (X)" followed by "File Name:"
        fm = FILE_HEAD.match(l)
        if fm and i + 1 < n and norm(lines[i + 1][1]).startswith("File Name:"):
            code = fm.group(2)
            current_file = code
            block, j = collect_until(lines, i + 1, stop=lambda s: bool(ELEMENT_HEAD.match(s)))
            fields = split_labels(block, [("file_name", "File Name:"), ("description", "Description:"),
                                          ("sample_file_name", "Sample File Name:")])
            files[code] = dict(file_code=code, file_title=norm(fm.group(1)) + f" File ({code})",
                               page=pno, **{k: v for k, v in fields.items()})
            i = j
            continue
        em = ELEMENT_HEAD.match(l)
        if em and any(norm(lines[k][1]).startswith("Field Name:") for k in range(i + 1, min(i + 4, n))):
            eid = em.group(1)
            name_parts = [em.group(2)]
            k = i + 1
            while not norm(lines[k][1]).startswith("Field Name:"):
                name_parts.append(norm(lines[k][1]))
                k += 1
            block, j = collect_until(
                lines, k,
                stop=lambda s: bool(ELEMENT_HEAD.match(s)) or bool(FILE_HEAD.match(s)))
            # A FILE_HEAD match inside prose is rare; only stop on a real file section.
            fields = split_labels(block, LABELS)
            elements.append(dict(element_id=eid, heading_name=norm(" ".join(name_parts)),
                                 page=pno, body_file=current_file, **fields))
            i = j
            continue
        i += 1
    return files, elements


def collect_until(lines, start, stop):
    out = []
    j = start
    while j < len(lines):
        s = norm(lines[j][1])
        if j > start and stop(s):
            # Element heading must be real (followed by Field Name) to stop a block;
            # file headings must be followed by File Name.
            if ELEMENT_HEAD.match(s):
                if any(norm(lines[k][1]).startswith("Field Name:")
                       for k in range(j + 1, min(j + 4, len(lines)))):
                    break
            elif FILE_HEAD.match(s):
                if j + 1 < len(lines) and norm(lines[j + 1][1]).startswith("File Name:"):
                    break
                # Stub file section (File P) has no "File Name:" line.
                if "No longer an active data file" in s:
                    break
        out.append(lines[j][1])
        j += 1
    return out, j


def split_labels(block: list[str], labels) -> dict[str, str]:
    buckets: dict[str, list[str]] = defaultdict(list)
    cur = None
    for raw in block:
        l = norm(raw)
        for key, lab in labels:
            if l.startswith(lab):
                cur = key
                l = l[len(lab):].strip()
                break
        if cur is not None:
            buckets[cur].append(l)
    out = {k: join_text(v) for k, v in buckets.items()}
    if "valid_values" in buckets:
        # Keep line structure: value lists are often two-column tables without dashes.
        out["valid_values_raw"] = "\n".join(x for x in buckets["valid_values"] if x)
    return out


# --------------------------------------------------------------------------------------
# Publication history: File P elements
# --------------------------------------------------------------------------------------

def parse_file_p(lines: list[str]) -> dict[str, str]:
    names: dict[str, str] = {}
    buf = None
    for raw in lines:
        l = norm(raw)
        if l.startswith("Element P") and ELEMENT_HEAD.match(l):
            buf = l
        elif buf is not None:
            buf += " " + l
        if buf and "(no longer an active data element)" in buf:
            m = ELEMENT_HEAD.match(buf)
            names[m.group(1)] = norm(m.group(2).replace("(no longer an active data element)", ""))
            buf = None
    return names


# --------------------------------------------------------------------------------------
# Derivations
# --------------------------------------------------------------------------------------

def normalize_nullable(s: str) -> str:
    s0 = (s or "").lower()
    if not s0:
        return ""
    if "conditional" in s0:
        return "conditional"
    if s0.startswith("no"):
        return "no"
    if s0.startswith("yes"):
        return "yes"
    return s0


APPX_RE = re.compile(r"\bAppendi(?:x|ces)\s+((?:[A-Z]{1,2}\b(?:\s*(?:,|and|&)\s*)?)+)")


def appendix_refs(*texts: str) -> list[str]:
    refs: list[str] = []
    for t in texts:
        for m in APPX_RE.finditer(t or ""):
            for code in re.findall(r"\b([A-Z]{1,2})\b", m.group(1)):
                if code not in refs:
                    refs.append(code)
    return refs


CODE = r"-?[A-Za-z0-9]{1,6}(?:\.\d+)?[+–]?"
DASH_ITEM = re.compile(rf"^({CODE})\s+[–-]\s+(.+)$")
# Source defect: "P RWT – Recruiting Washington Teachers" (no dash after the code P).
DASHLESS_ITEM = re.compile(r"^([A-Z])\s+([A-Z]{2,5}\s+–\s+.+)$")
PLAIN_ITEM = re.compile(rf"^({CODE})(?:\s+(.+))?$")
NOT_A_LIST = re.compile(r"^(?:Refer|See|Appendix|CEDARS (?:Data Manual )?Appendix)|^[\d.,]+\s+to\s+[\d.,]+$|^\d{4}$|^[\d.]+\s*-\s*[\d.]+$")
# Group headings inside value lists that carry no trailing colon (verified by eye against the PDF).
GROUP_HEADINGS = {
    "S09": {"Physical Restraint", "Mechanical Restraint", "Isolation"},
    "U10": {"Develop IEP", "Process Complete, No IEP to Develop"},
}


def inline_values(eid: str, raw: str) -> tuple[list[tuple[str, str]], list[tuple[str, str]]]:
    """Parse an inline valid-value list.

    Returns (items, groups): items = [(code, description)], groups = [(heading, codes-or-pointer)].
    Appendix pointers, ranges and constants yield no items.
    """
    if not raw or NOT_A_LIST.search(raw.split("\n")[0]):
        return [], []
    lines = raw.split("\n")
    items: list[tuple[str, str]] = []
    groups: list[list] = []
    headings = GROUP_HEADINGS.get(eid, set())
    if any(DASH_ITEM.match(l) for l in lines):
        last_was_item = False
        for ln in lines:
            if ln in headings or ln.endswith(":"):
                groups.append([ln.rstrip(":"), []])
                last_was_item = False
                continue
            if ln == "NULL":  # "NULL" listed as a permitted value (D06, T09)
                groups.append(["NULL permitted", []])
                continue
            if groups and not last_was_item and ln.startswith("Refer to"):
                groups[-1][1].append("appendix " + ",".join(appendix_refs(ln)))
                continue
            m = DASH_ITEM.match(ln) or DASHLESS_ITEM.match(ln)
            if m:
                items.append((m.group(1), m.group(2).strip()))
                if groups:
                    groups[-1][1].append(m.group(1))
                last_was_item = True
            elif items and last_was_item:
                items[-1] = (items[-1][0], join_wrapped(items[-1][1], ln))
        return items, [(g, ",".join(c)) for g, c in groups]
    # Two-column table (e.g. letter grade + grade points) or a bare code list.
    if len(lines) > 1 and all(PLAIN_ITEM.match(l) for l in lines):
        return [(m.group(1), (m.group(2) or "").strip()) for m in map(PLAIN_ITEM.match, lines)], []
    return [], []


def element_text(el: dict) -> str:
    return " ".join(el.get(k, "") or "" for k in ("business_rules", "description", "valid_values", "example"))


def multi_signal(el: dict) -> str:
    text = element_text(el)
    for pat in MULTI_PATTERNS:
        m = re.search(pat, text, re.I)
        if m:
            return m.group(0)
    return ""


def type_and_size(dtype: str, size: str) -> tuple[str, str]:
    """Normalize e.g. 'numeric(6,2)', 'varchar size 2', '4,2 (Five characters ...)', 'See Data Type Definitions'."""
    dtype = (dtype or "").strip().lower()
    m = re.match(r"^(\w+)\s*(?:\(\s*([\d,\s]+)\)|size\s+(\d+))$", dtype)
    if m:
        dtype, size = m.group(1), (m.group(2) or m.group(3)).replace(" ", "")
    m = re.match(r"^(\d+(?:\s*,\s*\d+)?)", (size or "").strip())
    size = str(int(m.group(1))) if m and "," not in m.group(1) else (m.group(1).replace(" ", "") if m else "")
    return dtype, size


def validations(s: str) -> str:
    ids = re.findall(r"\d+", s or "")
    return ",".join(ids)


# --------------------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------------------

def main() -> int:
    pages = extract_pages(MANUAL)
    lines = lines_with_pages(pages, HEADER_RE)
    reg = find_regions(lines)

    def region(name):
        a, b = reg[name]
        return lines[a:b]

    toc_names = parse_toc([l for _, l in region("toc")])
    summary_keys, summary_inactive = parse_summary([l for _, l in region("summary")])
    summary_types = parse_summary_types([l for _, l in region("summary")])
    files, body = parse_body(region("body"))
    p_names = parse_file_p([l for _, l in region("history")])

    problems: list[str] = []
    notes: list[str] = []
    flat_text = norm(" ".join(l for _, l in lines)).lower()
    seen = Counter(e["element_id"] for e in body)
    for eid, c in seen.items():
        if c > 1:
            problems.append(f"duplicate body definition for {eid}")

    rows: list[dict] = []
    for el in body:
        eid = el["element_id"]
        heading = el["heading_name"]
        body_inactive = bool(re.search(r"no longer an active", heading, re.I)) or bool(
            re.search(r"no longer (?:collected|used)", el.get("description", ""), re.I))
        inactive = body_inactive or eid in summary_inactive
        if body_inactive != (eid in summary_inactive):
            notes.append(f"{eid}: inactive flag disagrees (body={body_inactive}, summary={eid in summary_inactive})")
        name = heading
        if re.search(r"no longer an active", heading, re.I):
            name = toc_names.get(eid, "")
            if not name or re.search(r"no longer an active", name, re.I):
                name = INACTIVE_NAMES.get(eid, "")
                if not name or name.lower() not in flat_text:
                    problems.append(f"{eid}: inactive element name not found/verified")
        if eid[0] != el["body_file"]:
            problems.append(f"{eid}: defined under file {el['body_file']}")
        vv = el.get("valid_values", "")
        inl, grp = inline_values(eid, el.get("valid_values_raw", ""))
        refs = appendix_refs(el.get("business_rules", ""), vv, el.get("description", ""))
        ev, enc = "", ""
        if eid in MULTI_VALUED:
            enc, quote = MULTI_VALUED[eid]
            if norm(quote) not in element_text(el):
                problems.append(f"{eid}: multi-valued evidence quote not found in element text")
            ev = quote
        elif multi_signal(el):
            problems.append(f"{eid}: text suggests multi-valued ('{multi_signal(el)}') but not curated")
        dtype, size = type_and_size(el.get("data_type", ""), el.get("size", ""))
        s_type, s_size = summary_types.get(eid, ("", ""))
        if not inactive:
            if not s_type:
                notes.append(f"{eid}: not typed in Data Element Summary")
            elif dtype and s_type != dtype:
                notes.append(f"{eid}: type differs body={dtype}({size}) summary={s_type}({s_size}); body kept")
            elif dtype and s_size and size and s_size != size:
                notes.append(f"{eid}: size differs body={size} summary={s_size}; body kept")
            if dtype and not size and dtype == s_type and s_size:
                size = s_size
                notes.append(f"{eid}: size {s_size} taken from Data Element Summary")
        rows.append(dict(
            manual_version=MANUAL_VERSION,
            file_code=eid[0],
            element_id=eid,
            element_name=name,
            field_name=el.get("field_name", ""),
            data_type=dtype,
            size=size,
            nullable=normalize_nullable(el.get("nullable", "")),
            is_key="Y" if eid in summary_keys else "N",
            description=el.get("description", ""),
            business_rules=el.get("business_rules", ""),
            example=el.get("example", ""),
            valid_values_text=el.get("valid_values_raw", ""),
            inline_valid_values="|".join(f"{c}={d}" if d else c for c, d in inl),
            inline_value_groups="|".join(f"{g}:{c}" for g, c in grp),
            appendix_refs=",".join(refs),
            validations=validations(el.get("validations", "")),
            last_updated=el.get("last_updated", ""),
            is_active="N" if inactive else "Y",
            is_multi_valued="Y" if ev else "N",
            multi_value_encoding=enc,
            multi_valued_evidence=ev,
            source_page=el["page"],
        ))

    for eid, nm in sorted(p_names.items()):
        rows.append(dict(manual_version=MANUAL_VERSION, file_code="P", element_id=eid, element_name=nm,
                         field_name="", data_type="", size="", nullable="", is_key="N",
                         description="File P is no longer an active data file (retired 2018-19). "
                                     "Element listed in the manual's publication history only.",
                         business_rules="", example="", valid_values_text="", inline_valid_values="", inline_value_groups="",
                         appendix_refs="", validations="", last_updated="", is_active="N",
                         is_multi_valued="N", multi_value_encoding="", multi_valued_evidence="",
                         source_page=""))

    rows.sort(key=lambda r: (r["file_code"], r["element_id"]))

    # ---- count validation ------------------------------------------------------------
    counts = Counter(r["file_code"] for r in rows)
    for f, exp in EXPECTED.items():
        if counts.get(f, 0) != exp:
            problems.append(f"file {f}: expected {exp} elements, found {counts.get(f, 0)}")
    for f in counts:
        ids = sorted(int(r["element_id"][1:]) for r in rows if r["file_code"] == f)
        if ids != list(range(1, len(ids) + 1)):
            problems.append(f"file {f}: element numbering not contiguous: {ids}")
    if len(rows) != 361:
        problems.append(f"total elements {len(rows)} != 361")

    mv = {r["element_id"] for r in rows if r["is_multi_valued"] == "Y"}
    for c in sorted(MULTI_UNVERIFIABLE):
        notes.append(f"{c}: multi-valued candidate not verifiable in v19 (inactive, no business rules)")

    OUT.mkdir(exist_ok=True)
    cols = list(rows[0].keys())
    with open(OUT / "elements.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=cols)
        w.writeheader()
        w.writerows(rows)

    # ---- files.csv ------------------------------------------------------------------
    problems += write_files_csv(files, rows, flat_text)

    print(f"elements: {len(rows)}  ({', '.join(f'{k}={v}' for k, v in sorted(counts.items()))})")
    print(f"active: {sum(r['is_active'] == 'Y' for r in rows)}  multi-valued: {sorted(mv)}")
    for n_ in notes:
        print("  note:", n_)
    if problems:
        print("\nPROBLEMS:")
        for p in problems:
            print("  -", p)
        return 1
    return 0


def write_files_csv(files: dict, rows: list[dict], flat_text: str) -> list[str]:
    from file_grain import FILE_GRAIN  # hand-curated grain statements, quote-verified

    keys_by_file: dict[str, list[str]] = defaultdict(list)
    for r in rows:
        if r["is_key"] == "Y":
            keys_by_file[r["file_code"]].append(r["element_id"])
    out = []
    problems = []
    for code in sorted(EXPECTED):
        f = files.get(code, {})
        g = FILE_GRAIN[code]
        if norm(g["stated_grain"]).lower() not in flat_text:
            problems.append(f"file {code}: stated_grain quote not found in manual")
        out.append(dict(
            manual_version=MANUAL_VERSION,
            file_code=code,
            file_title=f.get("file_title", g.get("title", "")),
            file_name=f.get("file_name", ""),
            description=f.get("description", g.get("description", "")),
            stated_grain=g["stated_grain"],
            grain_source=g["source"],
            key_elements=",".join(keys_by_file.get(code, [])),
            sample_file_name=f.get("sample_file_name", ""),
            element_count=sum(r["file_code"] == code for r in rows),
            is_active="N" if code == "P" else "Y",
            source_page=f.get("page", g.get("page", "")),
        ))
    with open(OUT / "files.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(out[0].keys()))
        w.writeheader()
        w.writerows(out)
    return problems


if __name__ == "__main__":
    sys.exit(main())
