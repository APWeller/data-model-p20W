"""Shared helpers: inventory loading, element role detection, naming, typing,
CEDS v14 element lookup, and the governance classification ladder.

Everything here is deterministic so the lineage crosswalks can be regenerated
whenever the inventory or the routing spec changes.
"""
import csv
import os
import re
from collections import OrderedDict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT = os.path.dirname(ROOT)
INVENTORY = os.path.join(PROJECT, "allDataElements.csv")
CEDS_PROPS = os.path.join(ROOT, "reference", "ceds_v14", "ceds_properties.csv")

OUT_OF_SCOPE_SECTORS = {"Justice", "Special Populations and Programs"}
OUT_OF_SCOPE_AGENCIES = {"IPEDS"}


# --------------------------------------------------------------------------
# Inventory
# --------------------------------------------------------------------------
def clean(s):
    return re.sub(r"\s+", " ", (s or "")).strip()


def load_inventory():
    rows = []
    with open(INVENTORY, encoding="utf-8-sig") as f:
        for r in csv.DictReader(f):
            if r["Sector Name"] in OUT_OF_SCOPE_SECTORS:
                continue
            if r["Agency Name"] in OUT_OF_SCOPE_AGENCIES:
                continue
            r = {k: clean(v) for k, v in r.items()}
            r["row"] = int(r["Row #"])
            r["elem"] = r["Data Element Name"]
            r["desc"] = r["Description/Definition"]
            r["prog"] = r["Source or Program"]
            r["tbl"] = r["Table Name"]
            r["gov_code"] = governance_code(r["Governance Requirements"])
            r["src"] = source_key(r)
            rows.append(r)
    return rows


# Several inventory tables are fragments of one physical source extract
# (e.g. ELMS "child" vs "Child", the two TSGold stacked files). They are
# grouped under one source key for routing, but lineage always cites the
# original Source or Program + Table Name + Data Element Name + Row #.
SOURCE_ALIASES = {
    ("ELMS", "child"): "ELMS.Child",
    ("ELMS", "Child"): "ELMS.Child",
    ("TSGold", "tsgold_stacked_2024"): "TSGold.Stacked",
    ("TSGold", "tsgold_stacked_202x"): "TSGold.Stacked",
    ("Hist ECEAP", ""): "HistECEAP.Record",
    ("UI Wage", "UI_Employer"): "UIEmployer.Header",
    ("UI Employer", "UI_Employer"): "UIEmployer.Employer",
    ("UI Wage", "UI_Wage"): "UIWage.Wage",
    ("OFM", "admission"): "PCHEES.admission",
    ("OFM", "completion"): "PCHEES.completion",
    ("OFM", "program"): "PCHEES.program",
    ("OFM", "registration"): "PCHEES.registration",
    ("OFM", "student"): "PCHEES.student",
    ("OFM", "term_dates"): "PCHEES.term_dates",
    ("Report Card", "Teacher Ratio Certificate Program"): "ReportCard.TeacherStaffing",
    ("Report Card", "Teacher Demographics"): "ReportCard.TeacherStaffing",
    ("Census Bureau", "NCES EDGE"): "NCES.EDGE",
    ("NCES EDGE", "NCES EDGE"): "NCES.EDGE",
}


def source_key(r):
    k = (r["Source or Program"], r["Table Name"])
    if k in SOURCE_ALIASES:
        return SOURCE_ALIASES[k]
    prog = re.sub(r"[^A-Za-z0-9]", "", r["Source or Program"])
    tbl = re.sub(r"[^A-Za-z0-9_]", "", r["Table Name"].replace(" ", ""))
    return f"{prog}.{tbl}"


# --------------------------------------------------------------------------
# Governance ladder (most restrictive first). The ordinal drives the rule
# "a target column inherits the most restrictive classification among the
# inventory rows it derives from". RI is carried as a separate flag because it
# is a handling instruction (substitute a research ID), not a sensitivity tier.
# --------------------------------------------------------------------------
GOV_LADDER = OrderedDict([
    ("NA", "Not Available to Request"),
    ("ERDC_ADMIN", "ERDC Admin Only"),
    ("RC", "Use Restricted to Data Contributor"),
    ("RE", "Use Restricted to ERDC"),
    ("R", "Restricted Use"),
    ("A3", "Requires Authorization from Many Contributors"),
    ("A1", "Requires Authorization from 1 Data Contributor"),
    ("A0", "ERDC Authorizes on behalf of Contributor"),
    ("E", "ERDC to Authorize"),
    ("CN", "Requires Notification of Data Contributors"),
    ("RI", "Research ID will be Provided"),
    ("NONE", "None"),
])
GOV_RANK = {k: i for i, k in enumerate(GOV_LADDER)}


def governance_code(text):
    t = clean(text)
    if not t or t == "None":
        return "NONE"
    if t.startswith("ERDC Admin Only"):
        return "ERDC_ADMIN"
    m = re.match(r"^([A-Z0-9]+)\)", t)
    return m.group(1) if m else "NONE"


def most_restrictive(codes):
    codes = [c for c in codes if c]
    non_ri = [c for c in codes if c != "RI"]
    pool = non_ri or codes or ["NONE"]
    return min(pool, key=lambda c: GOV_RANK[c])


# --------------------------------------------------------------------------
# Naming
# --------------------------------------------------------------------------
def snake(name):
    s = clean(name)
    s = s.replace("/", " ").replace("-", " ").replace("&", " and ")
    s = re.sub(r"[()?.,'#]", " ", s)
    s = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", s)
    s = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1_\2", s)
    s = re.sub(r"[^A-Za-z0-9]+", "_", s).strip("_").lower()
    s = re.sub(r"_+", "_", s)
    if s and s[0].isdigit():
        s = "n_" + s
    return s


def pascal(name):
    return "".join(p[:1].upper() + p[1:] for p in snake(name).split("_") if p)


# --------------------------------------------------------------------------
# CEDS v14 element lookup (labels verified against CEDS-Elements repo)
# --------------------------------------------------------------------------
_CEDS = None


def ceds_index():
    global _CEDS
    if _CEDS is None:
        _CEDS = {}
        with open(CEDS_PROPS) as f:
            for r in csv.DictReader(f):
                if r["Deprecated (owl:deprecated)"] == "true":
                    continue
                label = r["Label (rdfs:label)"]
                entry = (r["Identifier (dc:identifier)"], label,
                         r["Technical Name (skos:notation)"])
                _CEDS[label.lower()] = entry
                if label.lower().startswith("has "):
                    _CEDS.setdefault(label[4:].lower(), entry)
    return _CEDS


def ceds(label):
    """Return (id, label, technical name) or None if CEDS has no such element."""
    if not label:
        return None
    return ceds_index().get(label.lower())


# --------------------------------------------------------------------------
# Data type inference (explicitly labelled "inferred" in the crosswalk; to be
# confirmed during silver profiling).
# --------------------------------------------------------------------------
BOOL_TOKENS = {"y", "n", "yes", "no", "0", "1", "true", "false", "or", "=", "-",
               "blank", "null", "no.", "yes."}


def infer_type(elem, desc, example, role=None):
    e, d, x = elem, desc.lower(), example.lower()
    el = e.lower()
    if role in ("PERSON_ID", "ORG", "SURR", "DEGENERATE"):
        return "STRING"
    if re.search(r"(datetime|timestamp|dataasof|extractdate$|submitdate$)", el):
        return "DATE" if "extract" in el or "submit" in el else "TIMESTAMP"
    if re.search(r"(^|_| )(date|dob)|date($|_|[A-Z ])|Date|_dt$|birthdate", e) and \
            not re.search(r"year|yrq|term|month_?of|ym$", el):
        if "termyyyy" in d or "ttyyyy" in x:
            return "STRING"
        return "DATE"
    if re.search(r"(flag|_ind$|^is[A-Z_]|indicator$|^has[A-Z_]|^eligible|^lives|^in_?prison|^under20|waitlisted|^eiu?|complete$)", e, re.I):
        toks = set(re.findall(r"[a-z0-9=]+", x)) - {"see", "flag"}
        if toks and toks <= BOOL_TOKENS:
            return "BOOLEAN"
    if re.search(r"(amount|income|wages?$|salary|sal$|contribution|costof|aidtotal|grant|loan|scholarship|waiver|cins$|cman$|fosterc?aremonthly|tanfmonthly|povertylevel|fpl$|needamount|asssal|base$|tfinsal|othersal)", el):
        return "DECIMAL(14,2)"
    if re.search(r"(gpa|grade_?point|theta|sem_|_rs$|_ss$|score|percent|pct|ratio|fte|credits?|hours?|hrs?$|days|exp$|experience|latitude|longitude|lat|lon|months|asspct|count|number_|^num|total_|domains|observations|age$|size$|interval|weeknumber|capacity|clock_hr|cr_equiv|^cr$|gr_dec|rsi|ojt|term_?in_?hours|quarter_?count|years_?in)", el) and \
            "code" not in el and "id" != el[-2:]:
        return "DECIMAL(12,3)"
    return "STRING"
