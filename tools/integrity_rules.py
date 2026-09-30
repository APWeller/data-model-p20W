"""Phase 1: cross-file (and key intra-file) integrity rules -> catalog/integrity_rules.csv.

Usage:  .venv/bin/python tools/integrity_rules.py

Every rule quotes the manual verbatim in `rule_text`; the build fails if a quote cannot be
found in the v19 manual text. `enforcement`:
  reject   - manual says records are rejected / the submission raises an exception
  required - manual says "must"
  expected - manual says "should"
  implied  - not stated as a cross-file rule, but follows from the quoted text (see notes)
"""

from __future__ import annotations

import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from parse_manual import HEADER_RE, MANUAL, MANUAL_VERSION, OUT, norm  # noqa: E402
from pdf_text import extract_pages, lines_with_pages  # noqa: E402

R = []  # rules, in the order they are written to CSV


def rule(child, parents, rule_type, rule_text, source, *, scope="cross_file", child_elements="",
         parent_elements="", match_scope="", condition="", enforcement="required", notes=""):
    R.append(dict(
        manual_version=MANUAL_VERSION, rule_id=f"IR{len(R) + 1:03d}", scope=scope, child_file=child,
        parent_files=parents, rule_type=rule_type, child_elements=child_elements,
        parent_elements=parent_elements, match_scope=match_scope, condition=condition,
        enforcement=enforcement, rule_text=rule_text, source=source, notes=notes))


# ---- Record existence: child file requires a parent record --------------------------------

rule("E", "C", "record_exists",
     "All students reported in File (E) must have a corresponding enrollment record reported for them in "
     "School Student File (C) at the same school.",
     "File E description", child_elements="E01,E02,E04,E05", parent_elements="C01,C02,C04,C05",
     match_scope="same district, same school", enforcement="reject")
rule("E", "D", "record_exists",
     "All courses reported in File (E) must have a corresponding course record reported for them for the "
     "same school in Course Catalog File (D).",
     "File E description; E06 business rules", child_elements="E01,E02,E05,E06",
     parent_elements="D01,D02,D03,D04", match_scope="same district, same school", enforcement="reject")
rule("G", "F", "record_exists",
     "All staff reported in File (G) must have a corresponding staff record reported for them in Staff File (F).",
     "File G description; G04 business rules", child_elements="G01,G02,G04", parent_elements="F01,F02,F03",
     match_scope="same district", enforcement="reject")
rule("G", "D", "record_exists",
     "All courses reported in File (G) must have a corresponding course record reported for them for the "
     "same school in Course Catalog File (D).",
     "File G description; G05 business rules", child_elements="G01,G02,G03,G05",
     parent_elements="D01,D02,D03,D04", match_scope="same district, same school", enforcement="reject")
rule("I", "C", "record_exists",
     "All students reported in File (I) must have an enrollment record reported for them in School Student "
     "File (C).",
     "File I description", child_elements="I01,I02,I04", parent_elements="C01,C02,C04",
     match_scope="same district", notes="The text does not say 'same school'.")
rule("K", "I", "record_exists",
     "All students reported in File (K) must be reported as having a disability in Student Attributes and "
     "Programs File (I).",
     "File K description", child_elements="K01,K02,K04", parent_elements="I01,I02,I04,I06",
     match_scope="same district", condition="I06 = 36", enforcement="reject")
rule("K", "I", "value_consistency",
     "If the student is reported in Special Education File (K) they must be reported with a valid value "
     "equal to 36 – Student Identified With a Disability in Element I06.",
     "I06 business rules", child_elements="K04", parent_elements="I06", match_scope="same district",
     condition="I06 = 36")
rule("Q", "B,C,I", "record_exists",
     "Students reported in this file must also be reported in District Student File (B), School Student "
     "File (C), and Student Attributes and Programs File (I).",
     "File Q description", child_elements="Q01,Q02,Q04", parent_elements="B05,C04,I04",
     match_scope="same district")
rule("Q", "I", "value_consistency",
     "This date must be equal to the date contained in Element I07 – Start Date.",
     "Q07 business rules", child_elements="Q06,Q07", parent_elements="I06,I07", match_scope="same district",
     notes="Q06 program code and Q07 start date identify the matching File I program record.")
rule("I", "Q", "record_exists",
     "Districts must submit LAP File Q data for students submitted in Element I06 – Attribute or Program "
     "Code with any of the valid values of 6, 7, 37, 38, or 44 by the end of the current school year.",
     "File Q description", child_elements="I06", parent_elements="Q06", match_scope="same district",
     condition="I06 in (6,7,37,38,44); at end of school year",
     notes="Reverse direction: an I program record requires a Q record by year end.")
rule("R", "B,C", "record_exists",
     "Students reported in this file must also be reported in District Student File (B) and School Student "
     "File (C).",
     "File R description", child_elements="R01,R02,R04", parent_elements="B05,C04", match_scope="same district")
rule("R", "K", "record_exists",
     "If Element R15 is Y – Yes, the student must be reported as receiving special education services in the "
     "Student Special Education Programs File (K).",
     "R15 business rules", child_elements="R04,R15", parent_elements="K04", match_scope="same district",
     condition="R15 = Y")
rule("S", "C", "record_exists",
     "The Location ID reported should be the enrolled Location ID of the student at the time of the reported "
     "action.",
     "S05 business rules", child_elements="S04,S05,S07", parent_elements="C04,C05,C06,C08",
     match_scope="same district, same school, S07 within enrollment", enforcement="implied",
     notes="CLAUDE.md lists 'S requires B and C'. The v19 manual has no such statement for File S; this is "
           "the closest rule. See decisions log.")
rule("V", "B,C", "record_exists",
     "Students reported in this file must also be reported in District Student File (B) and School Student "
     "File (C).",
     "File V description", child_elements="V01,V02,V04", parent_elements="B05,C04", match_scope="same district")
rule("T", "D,E", "record_not_exists",
     "Non-scheduled courses are courses for students where there is not a corresponding record in the Course "
     "Catalog File (D) or the Student Schedule File (E).",
     "File T description", child_elements="T07", parent_elements="D04,E06", match_scope="same district",
     enforcement="expected", notes="Negative rule: T holds attempts that are NOT in D/E.")

# ---- Location ID must resolve through File A ----------------------------------------------

for code, eid in [("C", "C05"), ("D", "D03"), ("E", "E05"), ("G", "G03"), ("I", "I05"), ("J", "J05"),
                  ("N", "N05"), ("Q", "Q05"), ("R", "R05"), ("S", "S05"), ("V", "V05")]:
    comma = "," if code in "JNQRSV" else ""
    tail = "must be included in Location File A." if code == "V" else "must be included in the Location File A."
    rule(code, "A", "location_ref", f"The ID reported in Element {eid}{comma} {tail}",
         f"{eid} business rules", child_elements=f"{code}01,{code}02,{eid}", parent_elements="A01,A02,A04",
         match_scope="same school year, same district")
rule("T", "A", "location_ref", "The ID reported in Element T03 must be included in the Location File A.",
     "T05 business rules", child_elements="T01,T02,T05", parent_elements="A01,A02,A04",
     match_scope="same school year, same district",
     notes="Source typo: the T05 rule says 'Element T03' (District Student ID); it means T05 Location ID.")
rule("E", "A,D", "value_consistency",
     "The Location ID submitted in Element E05 and Element D03 – Location ID, for the same course, must map "
     "to the same School Code submitted in Location File (A), Element A05 – School Code.",
     "E05 business rules", child_elements="E05,E06", parent_elements="A04,A05,D03,D04",
     match_scope="same district")
rule("G", "A,D", "value_consistency",
     "The Location ID submitted in Element G03 and Element D03 – Location ID, for the corresponding record in "
     "both files, must map to the same School Code submitted in Location File (A), Element A05 – School Code.",
     "G03 business rules", child_elements="G03,G05", parent_elements="A04,A05,D03,D04",
     match_scope="same district")

# ---- Cross-file value and date consistency ------------------------------------------------

rule("B", "C", "date_order",
     "This date must be the same as, or earlier than, the date contained in Element C06 – Date Student "
     "Enrolled in School.",
     "B14 business rules", child_elements="B14", parent_elements="C06", match_scope="same district, same student",
     condition="B14 <= C06")
rule("B", "C", "value_consistency",
     "If a date is entered, then Element C08 – Date Student Exited from School should have a matching exit "
     "date for the school within the district that was last attended by the student.",
     "B15 business rules", child_elements="B15", parent_elements="C08", match_scope="same district, last school",
     condition="B15 = C08 of last-attended school", enforcement="expected")
rule("C", "B", "value_consistency",
     "If the student is also leaving the district Element B15 – Date Exited from District must also be "
     "provided.",
     "C08 business rules", child_elements="C08", parent_elements="B15", match_scope="same district")
rule("C", "B", "date_order", "The enrollment date must be on or after Element B09 – Birth Date.",
     "C06 business rules", child_elements="C06", parent_elements="B09", condition="C06 >= B09")
rule("I", "B", "date_order",
     "This date must be equal to or greater than the date contained in Element B14 – Date Enrolled in District.",
     "I07 business rules (same text in C06)", child_elements="I07", parent_elements="B14",
     match_scope="same district", condition="I07 >= B14; also C06 >= B14")
rule("I", "B", "date_order", "The program start date must be on or after Element B09 – Birth Date.",
     "I07 business rules", child_elements="I07", parent_elements="B09", condition="I07 >= B09")
rule("J", "A,B", "date_order",
     "If the student qualifies for services, the Program Status Start Date must be on or after Element A07 – "
     "Initial School Start Date, on or after Element B14 – Date Enrolled in District and on or after Element "
     "J22 – Placement Test Date.",
     "J07 business rules", child_elements="J07,J22", parent_elements="A07,B14",
     condition="J07 >= A07 and J07 >= B14 and J07 >= J22")
rule("G", "A", "date_order",
     "The date reported must be equal to or greater than the date reported in Element A07 – Initial School "
     "Start Date.",
     "G11 business rules", child_elements="G11", parent_elements="A07", match_scope="same school",
     condition="G11 >= A07")
rule("E", "G", "value_consistency",
     "This value will be used to connect teacher and student schedules so the designator for Term must be the "
     "same for Element E08 and Element G07 – Term.",
     "E08 business rules (mirrored in G07)", child_elements="E05,E06,E07,E08", parent_elements="G03,G05,G06,G07",
     match_scope="same district, same school, same course and section",
     notes="Basis for dim_section = union of E and G keys.")
rule("E", "D", "value_consistency",
     "If Element E09 contains a valid value of O – Online then Element D07 – Course Designation Code must "
     "contain a valid value of O – Online.",
     "E09 business rules", child_elements="E09", parent_elements="D07", match_scope="same school, same course",
     condition="E09 = O => D07 contains O")
rule("E", "D", "value_consistency",
     "If Element D07 – Course Designation Code contains a valid value of O – Online then Element E10 – "
     "Approved Online Provider is required.",
     "E10 business rules (E11 has the same rule)", child_elements="E10,E11", parent_elements="D07",
     match_scope="same school, same course", condition="D07 contains O => E10, E11 required")
rule("H", "A,D", "value_consistency",
     "If the course is not a transfer credit, and Element A05 – School Code matches Element H26 – School "
     "Code, then the same CIP Code Number must also be reported in Element D10 – CIP Code.",
     "H17 business rules", child_elements="H17,H26", parent_elements="A05,D10",
     match_scope="same district, same school", condition="H26 = A05 (not transfer)")
rule("H", "A", "value_consistency",
     "If Element A05 – School Code matches Element H26 – School Code (indicating this is not a transfer "
     "credit) then term must be supplied.",
     "H19 business rules", child_elements="H19,H26", parent_elements="A05", condition="H26 = A05 => H19 not null",
     notes="H19 is part of the design's File H grain but is NULL for transfer credits.")
rule("J", "B", "value_consistency",
     "If Element J17 contains valid value = 1 and Element J09 does not contain a valid value of P, one of the "
     "elements, Element B17 – Primary Language Code or Element B18 – Student Language Spoken at Home, must "
     "have a language code other than 639 – English.",
     "J17 business rules", child_elements="J09,J17", parent_elements="B17,B18", match_scope="same district")
rule("J", "B", "value_consistency",
     "If Element J17 contains valid value = 3, Element B17 – Primary Language Code and Element B18 – Student "
     "Language Spoken at Home, must be 639 – English or 640 – American Sign Language.",
     "J17 business rules", child_elements="J17", parent_elements="B17,B18", match_scope="same district")
rule("K", "C", "value_consistency",
     "Element C09 – School Withdrawal Code must indicate withdrawal from district.",
     "K09 business rules", child_elements="K09", parent_elements="C09", match_scope="same district",
     condition="K09 = 6 (no longer enrolled in district)")
rule("K", "B", "value_consistency",
     "If Element B13 – Grade Level is not PK, you must report NULL.",
     "K16-K24 business rules", child_elements="K16,K17,K18,K19,K20,K21,K22,K23,K24", parent_elements="B13",
     match_scope="same district", condition="B13 <> PK => K16..K24 NULL")
rule("K", "B", "value_consistency",
     "LRE codes reported must be appropriate to the current age and Grade Level (Element B13) of the student.",
     "K06 business rules", child_elements="K06", parent_elements="B09,B13", match_scope="same district")
rule("I", "B", "value_consistency",
     "Valid value 11 - LAP Extended Learning Opportunities Program eligibility is limited to students in "
     "grades 8, 9, 10, 11, and 12 as reported in Element B13 – Grade Level.",
     "I06 business rules", child_elements="I06", parent_elements="B13", match_scope="same district",
     condition="I06 = 11 => B13 in (8..12)")
rule("V", "B", "value_consistency",
     "May only be 1 – Dyslexia if Element B13 – Grade Level is K1, K2, 1, or 2.",
     "V06 business rules", child_elements="V06", parent_elements="B13", match_scope="same district")

# ---- Intra-file rules that shape the dimensional design -----------------------------------

rule("B", "B", "no_overlap", "These entry and exit dates may not overlap for an individual student.",
     "File B description", scope="intra_file", child_elements="B05,B14,B15",
     match_scope="same district, same student")
rule("C", "C", "no_overlap", "Entry and exit dates may not overlap for individual students.",
     "File C description", scope="intra_file", child_elements="C04,C05,C06,C08",
     match_scope="same district, same school, same student")
rule("L", "L", "exclusive_value",
     "If Ethnicity Code equals '10' (Non– Hispanic), there cannot be other records in this file for the same "
     "student.",
     "File L description", scope="intra_file", child_elements="L04,L05")
rule("R", "R", "repeated_attributes",
     "Each exclusionary action associated with a student for a single incident must be reported with "
     "identical incident information in Elements R01 through R10.",
     "File R description", scope="intra_file", child_elements="R01,R02,R03,R04,R05,R06,R07,R08,R09,R10",
     match_scope="same district, same student, same incident (R06)",
     notes="Basis for the incident degenerate dimension in fact_exclusionary_action.")
rule("E", "E", "unique_key",
     "Element E06 – Course ID, Element E07 – Section ID and Element E08 - Term combination must be distinct.",
     "E07 business rules", scope="intra_file", child_elements="E02,E03,E05,E06,E07,E08")
rule("H", "H", "value_consistency",
     "Grade history records for courses the student received from schools outside the serving district "
     "should be reported using a LocationID of 9999 within Element H26 – School Code.",
     "File H description", scope="intra_file", child_elements="H26", condition="out-of-district => H26 = 9999",
     notes="Basis for the dim_school 9999 special member.")


def main() -> int:
    pages = extract_pages(MANUAL)
    flat = norm(" ".join(l for _, l in lines_with_pages(pages, HEADER_RE))).lower()
    bad = [r["rule_id"] for r in R if norm(r["rule_text"]).lower() not in flat]
    OUT.mkdir(exist_ok=True)
    with open(OUT / "integrity_rules.csv", "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(R[0].keys()))
        w.writeheader()
        w.writerows(R)
    print(f"integrity rules: {len(R)} ({sum(r['scope'] == 'cross_file' for r in R)} cross-file)")
    if bad:
        print("PROBLEMS: rule_text not found verbatim in manual:", ", ".join(bad))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
