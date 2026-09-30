"""Step 2: propose hubs and business keys for the in-scope sector(s).

Writes outputs/hub_candidates.csv. Each candidate cites evidence by Row #; the
script checks every cited row exists, is in scope, and has the expected element
name, so evidence cannot drift from the input. Rejected candidates (reference
data, attributes, time keys) are listed too, so the reasoning is reviewable.

Re-run: python3 scripts/02_hub_candidates.py
"""
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "allDataElements.csv"
OUT = ROOT / "outputs"
SCOPE_SECTORS = ["Workforce"]

# Each candidate: evidence maps Row # -> expected (stripped) element name.
CANDIDATES = [
    {
        "hub_name": "HUB_ESD_EMPLOYER_ACCOUNT",
        "business_key_elements": "UI Account number",
        "evidence": {667: "UI Account number", 796: "EmployerAccountNumber",
                     670: "Predecessor UI Account Number", 672: "Successor UI Account Number",
                     778: "First Supplemental P/S UI Account Number",
                     781: "Second Supplemental P/S UI Account Number"},
        "status": "proposed",
        "confidence": "high",
        "notes": "PK-flagged (x) with RUN in UI_Employer. UI_Wage references the employer only by "
                 "EmployerAccountNumber (no RUN), so wages attach at account level. Notes on row 667: "
                 "keep last 8 chars (2-digit filler split off; 'Account Fill' row 666 = two zeros). "
                 "Normalization rule for the BK needs confirming (8 vs 10 chars) so UI_Wage and "
                 "UI_Employer keys hash identically. Pred/succ account numbers point back into this hub "
                 "(same-as/transfer link in step 3).",
    },
    {
        "hub_name": "HUB_ESD_REPORTING_UNIT",
        "business_key_elements": "UI Account number + Reporting Unit Number (RUN)",
        "evidence": {667: "UI Account number", 668: "Reporting Unit Number (RUN)",
                     671: "Predecessor RUN", 673: "Successor RUN"},
        "status": "proposed",
        "confidence": "high",
        "notes": "Both elements PK-flagged (x). Notes on row 668: RUN '00000' = master record, non-00000 = "
                 "locations (worksites) of the firm. Composite BK. Linked to HUB_ESD_EMPLOYER_ACCOUNT "
                 "(unit belongs to account). Most descriptive attributes (address, NAICS, geocode, "
                 "employment counts) sit at this grain. ALTERNATIVE: collapse both hubs into one hub on "
                 "account+RUN and treat RUN='00000' as the account; simpler but wage records would then "
                 "need a synthesized RUN='00000' to join.",
    },
    {
        "hub_name": "HUB_ESD_WORKER",
        "business_key_elements": "SSN (as reported to ESD in UI wage records)",
        "evidence": {792: "SSN"},
        "status": "proposed",
        "confidence": "medium",
        "notes": "No PK flag, but SSN is the only person identifier in UI_Wage. Scoped to ESD: NOT assumed "
                 "equal to SSNs held by LNI, SBCTC, PCHEES, WSAC, OSPI (cross-agency identity = future "
                 "same-as links, out of scope). Governance: 'NA) Not Available to Request', so the BK "
                 "itself is restricted. The hub needs a hashed/tokenized key, or ERDC's research ID if "
                 "one exists upstream (SME question). SSN quality (invalid/ITIN/shared SSNs) is unknown. "
                 "Names (rows 794-795) go to a restricted satellite, not the BK.",
    },
    {
        "hub_name": "HUB_FEDERAL_EMPLOYER (FEIN)",
        "business_key_elements": "EI Number / FEIN",
        "evidence": {669: "EI Number", 802: "FEIN"},
        "status": "deferred - satellite attribute for now",
        "confidence": "low",
        "notes": "FEIN identifies a federal tax entity that can span several UI accounts, and could be a "
                 "cross-agency employer key (e.g. LNI apprenticeship sponsors) when other sectors are added. "
                 "Within Workforce alone there is no evidence it is used for joins, so it's modeled as a "
                 "descriptive attribute of the account/unit. Revisit with the all-sectors scope.",
    },
    {
        "hub_name": "(none) Industry / occupation / geography codes",
        "business_key_elements": "NAICS code, Old NAICS code, NAICSCode, SIC Code, NSTA, SOC, County Code, "
                                 "Old County Code, Township Code, Place Code, State FIPS code",
        "evidence": {727: "NAICS code", 721: "Old NAICS code", 801: "NAICSCode", 725: "SIC Code",
                     726: "NSTA - mostly blank", 803: "SOC", 730: "County Code", 715: "Old County Code",
                     731: "Township Code", 764: "Place Code", 663: "State FIPS code"},
        "status": "rejected - reference tables",
        "confidence": "high",
        "notes": "Code sets (option sets) per the modeling rules, not hubs. NAICS/SIC/SOC/FIPS are external "
                 "standards and good shared reference tables across sectors.",
    },
    {
        "hub_name": "(none) Reporting period",
        "business_key_elements": "Year + Quarter (UI_Employer); YearQuarter (UI_Wage)",
        "evidence": {664: "Year", 665: "Quarter", 793: "YearQuarter"},
        "status": "rejected - dependent/time key",
        "confidence": "high",
        "notes": "Year and Quarter are PK-flagged in UI_Employer, which shows the file is a quarterly "
                 "snapshot (account + RUN + year + quarter). Time is modeled as a dependent child key on the "
                 "link/satellite, not as a hub. YearQuarter (YYYYQ) is the matching period in UI_Wage.",
    },
    {
        "hub_name": "(none) Wage record",
        "business_key_elements": "none in source",
        "evidence": {792: "SSN", 796: "EmployerAccountNumber", 793: "YearQuarter", 799: "WageTypeCode"},
        "status": "rejected - becomes a link",
        "confidence": "medium",
        "notes": "UI_Wage has no PK flag and no record identifier. A wage record is the transaction "
                 "worker x employer account x quarter (possibly x WageTypeCode, since original and adjusted "
                 "wages both arrive). It's modeled as a (likely non-historized) link in step 3. Grain needs SME "
                 "confirmation: can one SSN have multiple rows per account per quarter?",
    },
]


def main() -> None:
    df = pd.read_csv(SRC, encoding="utf-8-sig", dtype=str, keep_default_na=False)
    df["Row #"] = df["Row #"].astype(int)
    scope = df[df["Sector Name"].isin(SCOPE_SECTORS)].set_index("Row #")

    rows = []
    for c in CANDIDATES:
        ev = scope.reindex(list(c["evidence"]))
        missing = ev.index[ev["Data Element Name"].isna()].tolist()
        assert not missing, f"{c['hub_name']}: evidence rows not in scope: {missing}"
        for rn, expected in c["evidence"].items():
            actual = scope.at[rn, "Data Element Name"].strip()
            assert actual == expected, f"row {rn}: expected {expected!r}, found {actual!r}"
        tables = sorted({f"{r['Source or Program'].strip()}/{r['Table Name'].strip()}" for _, r in ev.iterrows()})
        pk = sorted({f"{rn}:{scope.at[rn, 'Primary Key?'] or 'blank'}" for rn in c["evidence"]})
        gov = sorted({scope.at[rn, "Governance Requirements"].strip() for rn in c["evidence"]})
        rows.append({
            "hub_name": c["hub_name"],
            "status": c["status"],
            "business_key_elements": c["business_key_elements"],
            "source_tables": "; ".join(tables),
            "evidence_rows": "; ".join(f"{rn}={n}" for rn, n in c["evidence"].items()),
            "pk_flags": "; ".join(pk),
            "governance": "; ".join(gov),
            "confidence": c["confidence"],
            "notes": c["notes"],
        })

    out = pd.DataFrame(rows)
    OUT.mkdir(exist_ok=True)
    out.to_csv(OUT / "hub_candidates.csv", index=False)
    print(f"wrote {OUT / 'hub_candidates.csv'}: "
          f"{(out.status == 'proposed').sum()} proposed, {len(out) - (out.status == 'proposed').sum()} other")


if __name__ == "__main__":
    main()
