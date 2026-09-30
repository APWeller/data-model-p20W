"""Gold star schema specification (docs/dimensional-design.md), as data.

tools/gen_ddl.py turns this into sql/gold/*.sql and docs/erd.md; tools/gen_mapping.py uses the
element IDs on each column for mapping/source_to_target.csv.

Column tuple helpers:
  col(name, type, elems, desc, fk=None, nn=False)
    elems: CEDARS element IDs the column is built from ("" = derived from other gold/silver columns);
           @ssid / @district mean the SSID / serving-district element of the fact's source file
    fk:    (table, column) the column references
Conventions: surrogate keys <dim>_sk BIGINT with -1 unknown / -2 not applicable; date keys
INT YYYYMMDD named <role>_date_sk; school_year_sk BIGINT = ending year (2027 for 2026-27).
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class Col:
    name: str
    type: str
    elems: str
    desc: str
    fk: tuple[str, str] | None = None
    nn: bool = False


@dataclass
class Table:
    name: str
    kind: str                    # fact | dim | junk | bridge | outrigger
    comment: str
    cols: list[Col]
    pk: list[str]
    cluster: list[str]
    family: str = ""             # fact family for the ERD
    scd2: bool = False
    special_members: bool = True  # dims: seed -1 / -2 rows
    restricted: bool = False
    extra: dict = field(default_factory=dict)


def col(name, type_, elems, desc, fk=None, nn=False):
    return Col(name, type_, elems, desc, fk, nn)


def sk(table):
    base = table[4:] if table.startswith("dim_") else table
    return col(f"{base}_sk", "BIGINT", "", "Surrogate key (-1 unknown, -2 not applicable)", nn=True)


def ref(table, elems, desc, name=None):
    base = table[4:]
    return col(name or f"{base}_sk", "BIGINT", elems, desc, fk=(table, f"{base}_sk"), nn=True)


def date(role, elems, desc):
    return col(f"{role}_date_sk", "INT", elems, desc, fk=("dim_date", "date_sk"), nn=True)


def year(elems="*01", desc="School year of the submission"):
    return col("school_year_sk", "BIGINT", elems, desc, fk=("dim_school_year", "school_year_sk"), nn=True)


SCD2 = [
    col("effective_from", "DATE", "", "SCD2: row effective from (first day of the school year it was first reported)", nn=True),
    col("effective_to", "DATE", "", "SCD2: row effective to (9999-12-31 while current)", nn=True),
    col("is_current", "BOOLEAN", "", "SCD2: current row flag", nn=True),
]
VALIDITY = [
    col("status", "STRING", "", "Source status: active | archived | closed"),
    col("valid_from_year", "INT", "", "First valid school year (ending year); NULL = not stated"),
    col("valid_to_year", "INT", "", "Last valid school year (ending year); NULL = open"),
]
META = [
    col("_manual_version", "STRING", "", "Load metadata: CEDARS manual version (backload seam)", nn=True),
    col("_load_ts", "TIMESTAMP", "", "Load metadata: load timestamp"),
]
WEIGHT = col("weighting_factor", "DECIMAL(9,8)", "", "1 / number of members in the group (allocation weight for BI tools)", nn=True)

T: list[Table] = []


def add(t: Table):
    t.cols = t.cols + META
    T.append(t)
    return t


# ======================================================================================
# Standard dimensions
# ======================================================================================

add(Table("dim_date", "dim", "Calendar date. date_sk = YYYYMMDD; -1 unknown, -2 not applicable.", [
    col("date_sk", "INT", "", "Date key YYYYMMDD (-1 unknown, -2 not applicable)", nn=True),
    col("full_date", "DATE", "", "Calendar date"),
    col("calendar_year", "INT", "", "Calendar year"),
    col("calendar_quarter", "INT", "", "Calendar quarter 1-4"),
    col("calendar_month", "INT", "", "Calendar month 1-12"),
    col("month_name", "STRING", "", "Month name"),
    col("day_of_month", "INT", "", "Day of month"),
    col("day_of_week", "INT", "", "ISO day of week 1 (Mon) - 7 (Sun)"),
    col("day_name", "STRING", "", "Day name"),
    col("iso_week_of_year", "INT", "", "ISO week number"),
    col("is_weekend", "BOOLEAN", "", "Saturday or Sunday"),
    col("school_year_sk", "BIGINT", "", "School year the date falls in (September-August; H18 rule)",
        fk=("dim_school_year", "school_year_sk")),
], pk=["date_sk"], cluster=["date_sk"]))

add(Table("dim_school_year", "dim", "CEDARS school year. school_year_sk = ending year (2027 = 2026-27).", [
    col("school_year_sk", "BIGINT", "", "School year key = ending year (-1 unknown, -2 not applicable)", nn=True),
    col("school_year", "INT", "A01,B01", "School year (ending year) as reported in *01"),
    col("school_year_label", "STRING", "", "Label, e.g. 2026-27"),
    col("manual_version", "STRING", "", "CEDARS manual version governing the year (19.0 for 2026-27)"),
    col("start_date", "DATE", "", "September 1 of the starting year"),
    col("end_date", "DATE", "", "August 31 of the ending year"),
], pk=["school_year_sk"], cluster=["school_year_sk"]))

add(Table("dim_district", "dim", "School district (SCD2 on name). Roles: serving district, home district.", [
    sk("dim_district"),
    col("county_district_code", "STRING", "A02,B02,B03", "County-district code (5 digits)"),
    col("county_code", "STRING", "A02", "County code = first 2 digits of the county-district code"),
    col("district_name", "STRING", "A03", "District name as reported in File A"),
    *SCD2,
], pk=["district_sk"], cluster=["county_district_code"], scd2=True))

add(Table("dim_school", "dim", "School (SCD2 on name). Special members: -1 unknown, -2 not applicable, "
          "and school code 9999 = out-of-district school (File H).", [
    sk("dim_school"),
    col("county_district_code", "STRING", "A02", "County-district code the school belongs to"),
    col("school_code", "STRING", "A05,H26", "OSPI school code (9999 = out-of-district)"),
    col("school_name", "STRING", "A06", "School name as reported in File A"),
    col("is_out_of_district", "BOOLEAN", "H26", "Special member for H26 = 9999"),
    *SCD2,
], pk=["school_sk"], cluster=["county_district_code", "school_code"], scd2=True))

add(Table("dim_school_year_calendar", "dim", "First and last instructional day per school and year "
          "(earliest A07 / latest A08 across the school's Location IDs, per the manual).", [
    col("school_sk", "BIGINT", "A05", "School", fk=("dim_school", "school_sk"), nn=True),
    year("A01"),
    col("first_instruction_date", "DATE", "A07", "Initial school start date (earliest across Location IDs)"),
    col("last_instruction_date", "DATE", "A08", "Last school end date (latest across Location IDs)"),
    col("calendar_days", "INT", "A07,A08", "Calendar days from first to last instructional date inclusive"),
], pk=["school_sk", "school_year_sk"], cluster=["school_year_sk", "school_sk"], special_members=False))

add(Table("dim_grade_level", "dim", "Grade level (Appendix E).", [
    sk("dim_grade_level"),
    col("grade_level_code", "STRING", "B13,H09,J19", "Grade level code (Appendix E)"),
    col("grade_level_description", "STRING", "B13", "Appendix E description"),
    col("sort_order", "INT", "", "Display order (Appendix E order: PK, TK, K1, K2, 1-12)"),
    col("grade_band", "STRING", "", "Derived band: Early Learning (PK, TK) | Elementary (K1-5) | Middle (6-8) | High (9-12)"),
    *VALIDITY,
], pk=["grade_level_sk"], cluster=["grade_level_code"]))

# ======================================================================================
# Student
# ======================================================================================

add(Table("dim_student", "dim", "Student, one row per SSID version (thin; design §5.1). Survivorship across "
          "districts from silver.student_attribute_history.", [
    sk("dim_student"),
    col("ssid", "STRING", "B05", "State Student ID (durable key)"),
    col("gender", "STRING", "B12", "Gender (SCD2)"),
    col("birth_country_code", "STRING", "B10", "Birth country (Appendix C) (type 1)"),
    col("birth_country_sk", "BIGINT", "B10", "Birth country", fk=("dim_country", "country_sk")),
    col("primary_language_sk", "BIGINT", "B17", "Primary language (Appendix K) (type 1)", fk=("dim_language", "language_sk")),
    col("initial_us_school_enrollment_date", "DATE", "B32", "Initial USA school enrollment date (type 1)"),
    col("months_non_us_attendance", "INT", "B34", "Months of non-US school attendance (type 1)"),
    *SCD2,
], pk=["student_sk"], cluster=["ssid"], scd2=True))

add(Table("dim_student_pii", "outrigger", "Restricted student PII keyed by SSID (design §5.1). Access via Unity "
          "Catalog grants and column masks only; no gold fact references it.", [
    col("ssid", "STRING", "B05", "State Student ID", nn=True),
    col("legal_last_name", "STRING", "B06", "Legal last name"),
    col("legal_first_name", "STRING", "B07", "Legal first name"),
    col("legal_middle_name", "STRING", "B08", "Legal middle name"),
    col("preferred_last_name", "STRING", "B36", "Preferred last name"),
    col("preferred_first_name", "STRING", "B37", "Preferred first name"),
    col("preferred_middle_name", "STRING", "B38", "Preferred middle name"),
    col("birth_date", "DATE", "B09", "Birth date"),
    col("residential_zip_plus4", "STRING", "B20", "Residential ZIP+4"),
], pk=["ssid"], cluster=["ssid"], special_members=False, restricted=True))

add(Table("dim_student_profile", "junk", "Mini-dimension of low-cardinality student flags (design §5.2). "
          "File I flags are for the reporting period.", [
    sk("dim_student_profile"),
    col("homeless_status_code", "STRING", "B21", "Homeless status (N, A-D)"),
    col("is_homeless", "BOOLEAN", "B21", "B21 <> N"),
    col("is_immigrant", "BOOLEAN", "B31", "Seam: B31 is inactive in v19; always NULL (C-002)"),
    col("military_parent_code", "STRING", "B35", "Military parent or guardian code"),
    col("exchange_status_code", "STRING", "B24", "Student exchange status (N, J, F)"),
    col("private_school_part_time_code", "STRING", "B22", "Approved private-school part-time code"),
    col("home_school_part_time_code", "STRING", "B23", "Home-based part-time code"),
    col("is_low_income", "BOOLEAN", "I06", "File I program 19 (Free/Reduced Meals) in the period"),
    col("is_special_education", "BOOLEAN", "I06,K14", "File I program 36 (disability) or a File K spell in the period"),
    col("is_section_504", "BOOLEAN", "I06", "File I attribute 16 (504 Plan) in the period"),
    col("is_english_learner", "BOOLEAN", "J07,J17", "File J EL program spell in the period"),
    col("is_gifted", "BOOLEAN", "I06", "File I programs 32-35 in the period"),
    col("is_unaccompanied_youth", "BOOLEAN", "I06", "File I attribute 24 in the period"),
    col("is_sensory_disability", "BOOLEAN", "I06", "File I attribute 80 in the period"),
], pk=["student_profile_sk"], cluster=["student_profile_sk"]))

# ======================================================================================
# Code-set dimensions (design §5.9) — built from ref.ref_code
# ======================================================================================

CODE_DIMS = {
    # name: (code_sets, elements, description, extra columns [(name, type, desc)])
    "dim_language": (["language"], "B17,B18,B43,D15,I10", "Language (Appendix K). Roles: primary, home, family "
                     "communication (bridge), dual-language instruction.",
                     [("recommended_language", "STRING", "Recommended replacement language (archived codes)")]),
    "dim_country": (["country"], "B10", "National origin country (Appendix C).", []),
    "dim_race": (["race"], "M05", "Race (Appendix Z).",
                 [("aggregate", "STRING", "Appendix Z aggregate"),
                  ("race_category", "STRING", "Federal race category (Appendix Z)")]),
    "dim_ethnicity": (["ethnicity"], "L05", "Ethnicity (Appendix Y).",
                      [("aggregate", "STRING", "Hispanic/Latino | Not Hispanic (Appendix Y)")]),
    "dim_disability": (["disability"], "I10", "Primary disability (Appendix I; I10 when I06 = 36).", []),
    "dim_behavior": (["behavior"], "R08,R09", "Behavior (Appendix B).",
                     [("definition", "STRING", "Appendix B behavior description")]),
    "dim_weapon": (["weapon"], "R10", "Weapon type (Appendix D).", [("definition", "STRING", "Appendix D description")]),
    "dim_cip": (["cip"], "D10,H17", "CIP code (Appendix S).",
                [("career_cluster", "STRING", "Career cluster"), ("cluster_pathway", "STRING", "Cluster pathway"),
                 ("program_area", "STRING", "CTE program area"), ("ctso", "STRING", "Career and technical student organization"),
                 ("exploratory_or_preparatory", "STRING", "E = exploratory, P = preparatory")]),
    "dim_ap_ib_cambridge": (["ap_ib_cambridge_course"], "D09,H16", "AP / IB / Cambridge course (Appendix Q).",
                            [("program", "STRING", "Advanced Placement | International Baccalaureate | Cambridge International"),
                             ("subject", "STRING", "Subject"), ("abbreviation", "STRING", "Course title abbreviation")]),
    "dim_higher_ed_institution": (["higher_ed_institution"], "D21", "Higher education institution (Appendix AM).",
                                  [("state", "STRING", "State")]),
    "dim_industry_certification": (["industry_certification"], "D17,H31", "Industry-recognized certification (Appendix AK).",
                                   [("career_cluster", "STRING", "Career cluster"),
                                    ("cte_program_area", "STRING", "CTE program area")]),
    "dim_intervention": (["intervention"], "V10", "Intervention (Appendix AH).",
                         [("intervention_group", "STRING", "Appendix AH section")]),
    "dim_staff_type": (["staff_type"], "F04", "Staff type (Appendix U, expanded to concrete codes).",
                       [("staff_type_group", "STRING", "Published pattern, e.g. 31x"),
                        ("suffix_description", "STRING", "Meaning of the third digit")]),
    "dim_course_designation": (["course_designation"], "D07,H13,T10", "Course designation (manual inline values).", []),
    "dim_work_based_learning": (["work_based_learning_offered", "work_based_learning_activity"], "D20,H32",
                                "Work-based learning activity (manual inline values; code_set distinguishes D20 offered "
                                "from H32 participated).", []),
    "dim_letter_grade": (["letter_grade"], "H10,T15,E12", "Letter grade (manual inline values).",
                         [("grade_points", "DECIMAL(2,1)", "Grade points (A = 4.0); NULL for non-graded marks")]),
    "dim_exclusionary_action": (["exclusionary_action"], "R11", "Exclusionary action applied (R11).", []),
    "dim_restraint_isolation_type": (["restraint_isolation_type"], "S09", "Type of restraint or isolation (S09).",
                                     [("value_group", "STRING", "Physical Restraint | Mechanical Restraint | Isolation")]),
    "dim_absence_type": (["absence_code"], "N07", "Absence type (N07).",
                         [("is_excused", "BOOLEAN", "EF, EP"), ("is_full_day", "BOOLEAN", "EF, UF")]),
    "dim_lre": (["lre"], "K06", "Least restrictive environment (Appendix W).",
                [("age_group", "STRING", "Appendix W age group section")]),
    "dim_non_public_agency": (["non_public_agency"], "K15", "Non-public agency (Appendix AC).", []),
    "dim_growth_assessment": (["student_growth_assessment"], "Q08,Q10", "Student growth assessment (Appendix J). "
                              "Roles: identification, progress monitoring.", []),
    "dim_online_provider": (["online_provider"], "E10,T13", "Approved online provider (Appendix AA).", []),
    "dim_online_program": (["online_program"], "E11,T14", "Approved online program (Appendix AB).",
                           [("resident_district", "STRING", "Resident district")]),
    "dim_teacher_indicator": (["teacher_indicator"], "G10", "Teacher indicator (G10).", []),
    "dim_ale_course_type": (["ale_course_type"], "E09,H27,T12", "ALE course type (E09/H27/T12).", []),
}

for name, (code_sets, elems, desc, extra) in CODE_DIMS.items():
    cols = [sk(name)]
    if len(code_sets) > 1:
        cols.append(col("code_set", "STRING", elems, f"Source code set: {', '.join(code_sets)}"))
    cols += [col("code", "STRING", elems, "Code value"), col("description", "STRING", elems, "Code description")]
    cols += [col(n, t, elems, d) for n, t, d in extra]
    cols += VALIDITY
    add(Table(name, "dim", desc + f" Built from ref.ref_code ({', '.join(code_sets)}).", cols,
              pk=[f"{name[4:]}_sk"], cluster=["code"], extra={"code_sets": code_sets}))

add(Table("dim_state_course", "dim", "State course code (Appendix V); the conformed course level (design §5.6).", [
    sk("dim_state_course"),
    col("state_course_code", "STRING", "D08,H15,T11", "State course code (SCED, 5 digits, or WA00xx)"),
    col("state_course_name", "STRING", "D08", "Appendix V name"),
    col("state_course_description", "STRING", "D08", "Appendix V description"),
    col("subject_area_code", "STRING", "D08", "SCED subject area code"),
    col("subject_area_name", "STRING", "D08", "SCED subject area name"),
    col("ap_ib_type", "STRING", "D08", "AP | IB | blank"),
    col("is_computer_science", "BOOLEAN", "D08", "Appendix V computer science flag"),
    col("is_wa_state_only", "BOOLEAN", "D08", "Washington-only code"),
    col("recoded_from", "STRING", "D08", "Earlier code this course replaced"),
    *VALIDITY,
], pk=["state_course_sk"], cluster=["state_course_code"]))

add(Table("dim_program", "dim", "Unified program dimension (design §5.7): Appendix F attribute/program codes (I06), "
          "EL program designation (J17), special education (single member), LAP/WRC (Q06, a subset of F) and "
          "support codes (V06). SCD2 by effective school year.", [
    sk("dim_program"),
    col("program_family", "STRING", "I06,J17,K14,Q06,V06", "attribute_program | el_program | special_education | support"),
    col("program_code", "STRING", "I06,J17,Q06,V06", "Code within the family"),
    col("program_name", "STRING", "I06,J17,V06", "Program name"),
    col("category", "STRING", "I06", "attribute | program | eligibility (from Appendix F record type)"),
    col("record_type", "STRING", "I06", "Appendix F record type: School Program | District Program | Attribute"),
    col("is_lap_wrc", "BOOLEAN", "Q06", "LAP / Washington Reading Corps program (Q06 codes 6, 7, 37, 38, 44)"),
    *SCD2,
], pk=["program_sk"], cluster=["program_family", "program_code"], scd2=True))

# ======================================================================================
# Staff, course, section
# ======================================================================================

add(Table("dim_staff", "dim", "Staff member, keyed by district + district staff ID (design §5.5).", [
    sk("dim_staff"),
    col("county_district_code", "STRING", "F02", "District"),
    col("staff_id", "STRING", "F03", "District-assigned staff ID"),
    col("certification_number", "STRING", "F05", "Certification number (cross-district rollups where present)"),
    col("is_certificated", "BOOLEAN", "F05", "F05 reported and not UNK"),
    *SCD2,
], pk=["staff_sk"], cluster=["county_district_code", "staff_id"], scd2=True))

add(Table("dim_staff_pii", "outrigger", "Restricted staff PII outrigger (design §5.5).", [
    col("staff_sk", "BIGINT", "F03", "Staff member", fk=("dim_staff", "staff_sk"), nn=True),
    col("legal_last_name", "STRING", "F06", "Last name"),
    col("legal_first_name", "STRING", "F07", "First name"),
    col("legal_middle_name", "STRING", "F08", "Middle name"),
    col("birth_date", "DATE", "F09", "Birth date"),
], pk=["staff_sk"], cluster=["staff_sk"], special_members=False, restricted=True))

add(Table("bridge_staff_type", "bridge", "Staff x school year x staff type (File F has one row per staff type).", [
    ref("dim_staff", "F03", "Staff member"),
    year("F01"),
    ref("dim_staff_type", "F04", "Staff type"),
    WEIGHT,
], pk=["staff_sk", "school_year_sk", "staff_type_sk"], cluster=["school_year_sk", "staff_sk"],
    family="course"))

add(Table("dim_course", "dim", "Local course: school year + district + school + course ID (design §5.6). Members "
          "from D (catalog), H (inferred from grade history, incl. school 9999 and prior years) or T (inferred "
          "from non-traditional credit), per catalog_source.", [
    sk("dim_course"),
    year("D01,H30,T01", "School year of the course"),
    col("school_sk", "BIGINT", "D03,H26,T05", "School offering the course", fk=("dim_school", "school_sk"), nn=True),
    col("county_district_code", "STRING", "D02,H02,T02", "District"),
    col("school_code", "STRING", "D03,H26,T05", "OSPI school code (via xref_location for D03/T05)"),
    col("course_id", "STRING", "D04,H07,T07,T06", "District course ID (T: T07, else attempt T06)"),
    col("course_title", "STRING", "D05,H08,T08", "Course title"),
    col("content_area_code", "STRING", "D06,H14,T09", "Content area code (Appendix O)"),
    col("content_area_description", "STRING", "D06,H14,T09", "Content area description"),
    col("state_course_sk", "BIGINT", "D08,H15,T11", "State course", fk=("dim_state_course", "state_course_sk"), nn=True),
    col("ap_ib_cambridge_sk", "BIGINT", "D09,H16", "AP/IB/Cambridge course", fk=("dim_ap_ib_cambridge", "ap_ib_cambridge_sk"), nn=True),
    col("cip_sk", "BIGINT", "D10,H17", "CIP code", fk=("dim_cip", "cip_sk"), nn=True),
    col("cte_equivalency_id_code", "STRING", "D12", "CTE course equivalency identification (A/B/C)"),
    col("cte_equivalency_code", "STRING", "D13", "CTE equivalency (01-19)"),
    col("cte_equivalency_description", "STRING", "D13", "CTE equivalency description"),
    col("dual_language_type_code", "STRING", "D14", "Dual language instruction type"),
    col("dual_language_language_sk", "BIGINT", "D15", "Dual language instruction language",
        fk=("dim_language", "language_sk"), nn=True),
    col("course_level_code", "STRING", "D16,T18", "Course level (B/G/E/H/C/X)"),
    col("course_level_description", "STRING", "D16,T18", "Course level description"),
    col("sequence", "STRING", "D18", "Seam: D18 inactive in v19; NULL (C-003)"),
    col("sequence_group", "STRING", "D19", "Seam: D19 inactive in v19; NULL (C-003)"),
    col("catalog_source", "STRING", "", "D = course catalog, H = inferred from File H, T = inferred from File T"),
], pk=["course_sk"], cluster=["school_year_sk", "county_district_code"]))

add(Table("bridge_course_designation", "bridge", "Course x course designation (D07; concatenated codes).", [
    ref("dim_course", "D04", "Course"), ref("dim_course_designation", "D07", "Designation"), WEIGHT,
], pk=["course_sk", "course_designation_sk"], cluster=["course_sk"], family="course"))
add(Table("bridge_course_industry_cert_offered", "bridge", "Course x industry certification offered (D17).", [
    ref("dim_course", "D04", "Course"), ref("dim_industry_certification", "D17", "Certification offered"), WEIGHT,
], pk=["course_sk", "industry_certification_sk"], cluster=["course_sk"], family="course"))
add(Table("bridge_course_wbl_offered", "bridge", "Course x work-based learning offered (D20).", [
    ref("dim_course", "D04", "Course"), ref("dim_work_based_learning", "D20", "Work-based learning offered"), WEIGHT,
], pk=["course_sk", "work_based_learning_sk"], cluster=["course_sk"], family="course"))
add(Table("bridge_course_higher_ed_institution", "bridge", "Course x approving higher-ed institution (D21).", [
    ref("dim_course", "D04", "Course"), ref("dim_higher_ed_institution", "D21", "Institution"), WEIGHT,
], pk=["course_sk", "higher_ed_institution_sk"], cluster=["course_sk"], family="course"))

add(Table("dim_section", "dim", "Section = school year + district + school + course ID + section ID + term; "
          "union of the E and G keys (design §5.6).", [
    sk("dim_section"),
    year("E01,G01"),
    ref("dim_course", "E06,G05", "Course"),
    col("county_district_code", "STRING", "E02,G02", "District"),
    col("school_code", "STRING", "E05,G03", "OSPI school code (via xref_location)"),
    col("course_id", "STRING", "E06,G05", "District course ID"),
    col("section_id", "STRING", "E07,G06", "Section ID"),
    col("term_code", "STRING", "E08,G07", "Term (Appendix P)"),
    col("term_description", "STRING", "E08,G07", "Term description"),
    col("term_start_date", "DATE", "G11", "Term start date"),
    col("term_end_date", "DATE", "G12", "Term end date"),
], pk=["section_sk"], cluster=["school_year_sk", "county_district_code"]))

# ======================================================================================
# Group dimensions and bridges for fact-level multi-valued elements (design §5.11)
# ======================================================================================

GROUPS = {
    # group: (member dim, elements)
    "course_designation_group": ("dim_course_designation", "H13,T10"),
    "industry_certification_group": ("dim_industry_certification", "H31"),
    "work_based_learning_group": ("dim_work_based_learning", "H32"),
    "intervention_group": ("dim_intervention", "V10"),
    "other_behavior_group": ("dim_behavior", "R09"),
    "family_language_group": ("dim_language", "B43"),
}
for g, (member, elems) in GROUPS.items():
    add(Table(f"dim_{g}", "dim", f"Distinct combination of {member[4:]} codes reported together ({elems}). "
              "-2 = none reported.", [
        sk(f"dim_{g}"),
        col("group_codes", "STRING", elems, "Member codes, sorted, comma-separated"),
        col("member_count", "INT", elems, "Number of members"),
    ], pk=[f"{g}_sk"], cluster=["group_codes"]))
    bridge = "bridge_other_behavior" if g == "other_behavior_group" else f"bridge_{g}"
    add(Table(bridge, "bridge", f"Group x {member[4:]} ({elems}).", [
        ref(f"dim_{g}", elems, "Group"), ref(member, elems, "Member"), WEIGHT,
    ], pk=[f"{g}_sk", f"{member[4:]}_sk"], cluster=[f"{g}_sk"]))

add(Table("bridge_student_race", "bridge", "Student x school year x district x race (M05, M06).", [
    ref("dim_student", "M04", "Student"), year("M01"),
    ref("dim_district", "M02", "Reporting district"),
    ref("dim_race", "M05", "Race"),
    col("race_collection_method_code", "STRING", "M06", "Race collection method"),
    WEIGHT,
], pk=["student_sk", "school_year_sk", "district_sk", "race_sk"], cluster=["school_year_sk", "student_sk"],
    family="enrollment"))
add(Table("bridge_student_ethnicity", "bridge", "Student x school year x district x ethnicity (L05, L06).", [
    ref("dim_student", "L04", "Student"), year("L01"),
    ref("dim_district", "L02", "Reporting district"),
    ref("dim_ethnicity", "L05", "Ethnicity"),
    col("ethnicity_collection_method_code", "STRING", "L06", "Ethnicity collection method"),
    WEIGHT,
], pk=["student_sk", "school_year_sk", "district_sk", "ethnicity_sk"], cluster=["school_year_sk", "student_sk"],
    family="enrollment"))

# ======================================================================================
# Junk dimensions (design §5.9)
# ======================================================================================

def junk(name, desc, members):
    cols = [sk(name)] + [col(n, t, e, d) for n, t, e, d in members]
    return add(Table(name, "junk", desc, cols, pk=[f"{name[4:]}_sk"], cluster=[f"{name[4:]}_sk"]))


junk("dim_enrollment_junk", "School-enrollment flags and codes (C09-C11, C14).", [
    ("school_withdrawal_code", "STRING", "C09", "School withdrawal code (Appendix M)"),
    ("school_withdrawal_description", "STRING", "C09", "Withdrawal description"),
    ("withdrawal_status_group", "STRING", "C09", "Confirmed Transfer | Dropout | Graduate ... (Appendix M)"),
    ("is_primary_school", "BOOLEAN", "C10", "School primarily responsible for the student"),
    ("school_choice_code", "STRING", "C11", "School choice code"),
    ("school_choice_description", "STRING", "C11", "School choice description"),
    ("confirmed_transfer_in_code", "STRING", "C14", "Confirmed transfer-in code"),
    ("confirmed_transfer_in_description", "STRING", "C14", "Confirmed transfer-in description"),
])
junk("dim_transcript_junk", "Transcript-course flags (H24, H27, H26 = 9999).", [
    ("cte_assessment_code", "STRING", "H24", "State/national technical skill assessment taken/passed"),
    ("cte_assessment_description", "STRING", "H24", "Description"),
    ("ale_course_type_code", "STRING", "H27", "ALE course type"),
    ("ale_course_type_description", "STRING", "H27", "ALE course type description"),
    ("is_out_of_district", "BOOLEAN", "H26", "Course taken outside the serving district (H26 = 9999)"),
])
junk("dim_program_participation_junk", "File I exit reason and qualification (I09, I10). The qualification "
     "code set depends on I06 (catalog/i10_qualification_map.csv).", [
    ("exit_reason_code", "STRING", "I09", "Program exit reason"),
    ("exit_reason_description", "STRING", "I09", "Exit reason description"),
    ("qualification_code_set", "STRING", "I06,I10", "Code set governing I10 for this program"),
    ("qualification_code", "STRING", "I10", "Qualification code as reported"),
    ("qualification_description", "STRING", "I10", "Qualification description from the governing code set"),
])
junk("dim_el_junk", "English-learner program codes (J06, J09, J18, J21).", [
    ("instructional_model_code", "STRING", "J06", "Instructional model"),
    ("instructional_model_description", "STRING", "J06", "Instructional model description"),
    ("exit_reason_code", "STRING", "J09", "EL exit reason"),
    ("exit_reason_description", "STRING", "J09", "EL exit reason description"),
    ("placement_test_code", "STRING", "J18", "Placement test"),
    ("placement_test_description", "STRING", "J18", "Placement test description"),
    ("placement_status_code", "STRING", "J21", "Placement status 0-6 (meaning depends on J18)"),
    ("placement_status_description", "STRING", "J18,J21", "Placement status description for this test (Appendix N)"),
])
junk("dim_sped_junk", "Special-education program codes (K09, K26, K27) and school-inference method.", [
    ("exit_reason_code", "STRING", "K09", "SpEd exit reason"),
    ("exit_reason_description", "STRING", "K09", "SpEd exit reason description"),
    ("interpreter_annual_iep_code", "STRING", "K26", "Interpreter requested for annual IEP meeting"),
    ("transition_consent_code", "STRING", "K27", "Consent to share with state transition agencies"),
    ("school_inference_method", "STRING", "", "primary_enrollment | single_enrollment | none (C-005)"),
])
junk("dim_prek_outcome_junk", "PreK early-childhood outcome ratings (K16-K24), design §3.", [
    ("social_emotional_entry_code", "STRING", "K16", "Positive social-emotional skills - entry (Appendix AD)"),
    ("knowledge_skills_entry_code", "STRING", "K17", "Acquisition and use of knowledge/skills - entry (AD)"),
    ("behaviors_entry_code", "STRING", "K18", "Appropriate behaviors and skills - entry (AD)"),
    ("social_emotional_exit_code", "STRING", "K19", "Positive social-emotional skills - exit (AD)"),
    ("social_emotional_progress_code", "STRING", "K20", "Positive social-emotional skills - progress (AE)"),
    ("knowledge_skills_exit_code", "STRING", "K21", "Knowledge/skills - exit (AD)"),
    ("knowledge_skills_progress_code", "STRING", "K22", "Knowledge/skills - progress (AE)"),
    ("behaviors_exit_code", "STRING", "K23", "Appropriate behaviors - exit (AD)"),
    ("behaviors_progress_code", "STRING", "K24", "Appropriate behaviors - progress (AE)"),
])
junk("dim_lap_junk", "LAP/WRC growth codes (Q09, Q15, Q16, Q17).", [
    ("academic_growth_code", "STRING", "Q09", "Amount of academic growth code (C-007)"),
    ("academic_growth_description", "STRING", "Q09", "Growth description"),
    ("extended_learning_intervention_code", "STRING", "Q15", "Extended learning time intervention"),
    ("extended_learning_intervention_description", "STRING", "Q15", "Description"),
    ("regular_day_intervention_code", "STRING", "Q16", "Intervention during regular school day"),
    ("regular_day_intervention_description", "STRING", "Q16", "Description"),
    ("at_grade_level", "STRING", "Q17", "At grade level (Y/N)"),
])
junk("dim_support_screening_junk", "Student support screening codes (V07, V09).", [
    ("identification_assessment_code", "STRING", "V07", "Identification assessment"),
    ("identification_assessment_description", "STRING", "V07", "Description"),
    ("support_determination_code", "STRING", "V09", "Support determination"),
    ("support_determination_description", "STRING", "V09", "Description"),
])
junk("dim_discipline_junk", "Exclusionary-discipline flags (R15-R17, R20, R21, R23-R27), design §5.9.", [
    ("iaes_code", "STRING", "R15", "Interim alternative education setting"),
    ("academic_services_code", "STRING", "R16", "Academic services"),
    ("behavior_services_code", "STRING", "R17", "Behavior services"),
    ("expulsion_extension_petition_code", "STRING", "R20", "Petition for extension of an expulsion"),
    ("reengagement_plan_code", "STRING", "R21", "Reengagement plan"),
    ("appeal_code", "STRING", "R23", "Appeal"),
    ("safety_staff_involvement_code", "STRING", "R24", "Safety/security staff involvement"),
    ("safety_staff_used_force_code", "STRING", "R25", "Safety/security staff used force"),
    ("safety_staff_arrest_code", "STRING", "R26", "Safety/security staff involved in arrest"),
    ("interpreter_reengagement_meeting_code", "STRING", "R27", "Interpreter requested for reengagement meeting"),
])
junk("dim_restraint_junk", "Restraint/isolation flags (S10, S12; S13/S14 inactive, C-004).", [
    ("student_injured", "STRING", "S10", "Student injured (Y/N)"),
    ("safety_staff_involvement_code", "STRING", "S12", "Safety/security staff involvement"),
])
junk("dim_initial_evaluation_junk", "Initial evaluation codes (U09, U10, U12, U13).", [
    ("late_evaluation_reason_code", "STRING", "U09", "Reason for late initial evaluation (Appendix AF)"),
    ("late_evaluation_reason_description", "STRING", "U09", "Description"),
    ("is_allowable_late_evaluation", "BOOLEAN", "U09", "Appendix AF allowable exception"),
    ("evaluation_outcome_code", "STRING", "U10", "Outcome of initial evaluation/eligibility"),
    ("evaluation_outcome_description", "STRING", "U10", "Description"),
    ("evaluation_outcome_group", "STRING", "U10", "Develop IEP | Process Complete, No IEP to Develop"),
    ("late_part_c_transition_reason_code", "STRING", "U12", "Reason for late transition from Part C (Appendix AG)"),
    ("late_part_c_transition_reason_description", "STRING", "U12", "Description"),
    ("is_allowable_late_part_c", "BOOLEAN", "U12", "Appendix AG allowable exception"),
    ("interpreter_initial_iep_code", "STRING", "U13", "Interpreter requested for initial IEP meeting"),
])

# ======================================================================================
# Facts (design §3)
# ======================================================================================

def fact(name, family, grain, cols, pk, cluster2="district_sk"):
    return add(Table(name, "fact", grain, cols, pk=pk, cluster=["school_year_sk", cluster2], family=family,
                     special_members=False))


# @ssid / @district resolve to the fact's own SSID / serving-district element (gen_ddl.resolve_elems).
STUDENT = ref("dim_student", "@ssid", "Student (SSID)")
DISTRICT = ref("dim_district", "@district", "Serving district")
SCHOOL = lambda e: ref("dim_school", e, "School (Location ID via xref_location)")  # noqa: E731

fact("fact_district_enrollment", "enrollment", "Coverage: SSID x serving district x district entry date (B14).", [
    year("B01"), STUDENT, DISTRICT,
    ref("dim_district", "B03", "Home (resident) district", name="home_district_sk"),
    date("entry", "B14", "District enrollment date"),
    date("exit", "B15", "District exit date (-2 while enrolled)"),
    ref("dim_grade_level", "B13", "Grade level"),
    ref("dim_student_profile", "B21,B22,B23,B24,B35,I06,J07,K14", "Student profile"),
    ref("dim_family_language_group", "B43", "Languages the family prefers to communicate in"),
    col("enrolled_days", "INT", "B14,B15,A07,A08", "Derived: calendar days enrolled within A07-A08 bounds (approximation, design §6)"),
], pk=["school_year_sk", "student_sk", "district_sk", "entry_date_sk"])

fact("fact_school_enrollment", "enrollment", "Coverage: SSID x school x school entry date (C06).", [
    year("C01"), STUDENT, DISTRICT, SCHOOL("C05"),
    date("entry", "C06", "School enrollment date"),
    date("exit", "C08", "School exit date (-2 while enrolled)"),
    ref("dim_grade_level", "B13", "Grade level (from the covering File B spell)"),
    ref("dim_enrollment_junk", "C09,C10,C11,C14", "Withdrawal, primary-school, school-choice and transfer-in codes"),
    ref("dim_student_profile", "B21,B22,B23,B24,B35,I06,J07,K14", "Student profile"),
    col("days_present", "INT", "C12", "Cumulative days present this enrollment period"),
    col("enrolled_days", "INT", "C06,C08,C12,N07,A07,A08", "Derived: days present + full-day absences, bounded by A07/A08 (approximation, design §6)"),
], pk=["school_year_sk", "student_sk", "school_sk", "entry_date_sk"])

fact("fact_student_school_year", "enrollment", "Periodic snapshot: SSID x serving district x school year.", [
    year("B01"), STUDENT, DISTRICT,
    ref("dim_school", "C05,C10", "Primary school (C10 = Y)", name="primary_school_sk"),
    ref("dim_grade_level", "B13", "Grade level (latest spell in the year)"),
    ref("dim_student_profile", "B21,B22,B23,B24,B35,I06,J07,K14", "Student profile"),
    ref("dim_language", "B18", "Language spoken at home", name="home_language_sk"),
    ref("dim_family_language_group", "B43", "Family communication languages"),
    col("federal_race_ethnicity", "STRING", "L05,M05", "Derived: Hispanic if any ethnicity aggregate is Hispanic/Latino; else the single race_category; else Two or More Races (Appendices Y/Z)"),
    col("ospi_race_ethnicity", "STRING", "L05,M05", "Derived: OSPI reporting category (same rule; Appendix Z race_category values)"),
    col("graduation_requirements_year", "INT", "B26", "Graduation requirements year"),
    col("expected_graduation_year", "INT", "B27", "Expected year of graduation"),
    col("credit_waiver_code", "STRING", "B42", "Credit waiver (0/1)"),
    col("asvab_test_status_code", "STRING", "B39", "ASVAB test status"),
    col("asvab_test_score", "INT", "B40", "ASVAB test score"),
    col("asvab_school_year", "INT", "B41", "ASVAB administration school year"),
    col("ela_pathway_completed_school_year", "INT", "B44", "ELA performance-based pathway completed year"),
    col("math_pathway_completed_school_year", "INT", "B45", "Math performance-based pathway completed year"),
    col("age_as_of_sept_1", "INT", "B09", "Derived: age in years on September 1 of the school year"),
    col("is_graduate", "BOOLEAN", "C09", "Derived: a withdrawal code in the Graduate status group (Appendix M)"),
    col("is_dropout", "BOOLEAN", "C09", "Derived: a withdrawal code in a Dropout status group (Appendix M)"),
    col("cumulative_gpa", "DECIMAL(4,3)", "B28", "Cumulative GPA"),
    col("cumulative_credits_attempted", "DECIMAL(6,2)", "B29", "Cumulative credits attempted"),
    col("cumulative_credits_earned", "DECIMAL(6,2)", "B30", "Cumulative credits earned"),
    col("enrolled_days", "INT", "C12,N07,A07,A08", "Derived: sum of school-enrollment enrolled_days (approximation, design §6)"),
    col("days_present", "INT", "C12", "Derived: sum of C12 over the year's school enrollments"),
    col("excused_full_day_absences", "INT", "N07", "Derived: count of N07 = EF"),
    col("unexcused_full_day_absences", "INT", "N07", "Derived: count of N07 = UF"),
    col("excused_part_day_absences", "INT", "N07", "Derived: count of N07 = EP"),
    col("unexcused_part_day_absences", "INT", "N07", "Derived: count of N07 = UP"),
    col("year_credits_attempted", "DECIMAL(6,2)", "H11", "Derived: sum of H11 for H30 = the school year (current versions)"),
    col("year_credits_earned", "DECIMAL(6,2)", "H12", "Derived: sum of H12 for H30 = the school year (current versions)"),
], pk=["school_year_sk", "student_sk", "district_sk"], cluster2="student_sk")

fact("fact_student_section", "course", "Schedule: SSID x section (school, course, section, term). Factless in v19: "
     "E12-E14 are inactive; credit/grade columns are NULL seams (C-001).", [
    year("E01"), STUDENT, DISTRICT, SCHOOL("E05"),
    ref("dim_course", "E06", "Course"), ref("dim_section", "E07,E08", "Section"),
    ref("dim_ale_course_type", "E09", "ALE course type"),
    ref("dim_online_provider", "E10", "Approved online provider"),
    ref("dim_online_program", "E11", "Approved online program"),
    ref("dim_letter_grade", "E12", "Seam: E12 inactive in v19; -2"),
    col("credits_attempted", "DECIMAL(4,2)", "E13", "Seam: E13 inactive in v19; NULL (C-001)"),
    col("credits_earned", "DECIMAL(4,2)", "E14", "Seam: E14 inactive in v19; NULL (C-001)"),
], pk=["school_year_sk", "student_sk", "section_sk"])

fact("fact_staff_section", "course", "Factless: staff x section x instruction start date. Teacher of record = "
     "teacher indicator filter (design §5.6).", [
    year("G01"), DISTRICT, SCHOOL("G03"),
    ref("dim_course", "G05", "Course"), ref("dim_section", "G06,G07", "Section"),
    ref("dim_staff", "G04", "Staff member"),
    ref("dim_teacher_indicator", "G10", "Teacher indicator"),
    date("instruction_start", "G08", "Instruction start date"),
    date("instruction_end", "G09", "Instruction end date (-2 if still instructing)"),
    col("instruction_days", "INT", "G08,G09,G12", "Derived: calendar days from G08 to G09 (or G12 term end)"),
], pk=["school_year_sk", "section_sk", "staff_sk", "instruction_start_date_sk"])

fact("fact_transcript_course", "course", "Full grade history: SSID x course school year (H30) x term (H19) x school "
     "code (H26) x course ID (H07); latest reported version (design §6).", [
    year("H01", "Reporting school year of the latest version"),
    ref("dim_school_year", "H30", "School year the course was taken", name="course_school_year_sk"),
    STUDENT, DISTRICT,
    ref("dim_school", "H26", "School the course was taken at (9999 = out of district)"),
    ref("dim_course", "H07,H08,H13,H14,H15,H16,H17", "Course (catalog or H-inferred)"),
    ref("dim_grade_level", "H09", "Grade level when taken"),
    ref("dim_letter_grade", "H10", "Letter grade"),
    date("term_end", "H18", "Term end month (first day of month)"),
    col("term_code", "STRING", "H19", "Term (Appendix P); '' for transfer credits"),
    ref("dim_transcript_junk", "H24,H26,H27", "Transcript flags"),
    ref("dim_course_designation_group", "H13", "Course designations (bridge)"),
    ref("dim_industry_certification_group", "H31", "Industry certifications earned (bridge)"),
    ref("dim_work_based_learning_group", "H32", "Work-based learning activities (bridge)"),
    col("teacher_certification_number", "STRING", "H25", "Degenerate: certification number of the teacher"),
    col("credits_attempted", "DECIMAL(4,2)", "H11", "Credits attempted"),
    col("credits_earned", "DECIMAL(4,2)", "H12", "Credits earned"),
], pk=["student_sk", "course_school_year_sk", "term_code", "school_sk", "course_sk"], cluster2="student_sk")

fact("fact_nontraditional_credit", "course", "Non-traditional credit attempt: district + attempt ID (T06).", [
    year("T01"), STUDENT, DISTRICT, SCHOOL("T05"),
    ref("dim_course", "T07,T08,T09,T11,T18", "Course (T-inferred)"),
    col("attempt_id", "STRING", "T06", "Degenerate: attempt ID"),
    ref("dim_letter_grade", "T15", "Letter grade"),
    ref("dim_ale_course_type", "T12", "ALE course type"),
    ref("dim_online_provider", "T13", "Approved online provider"),
    ref("dim_online_program", "T14", "Approved online program"),
    ref("dim_course_designation_group", "T10", "Course designations (bridge)"),
    col("credits_attempted", "DECIMAL(4,2)", "T16", "Credits attempted"),
    col("credits_earned", "DECIMAL(4,2)", "T17", "Credits earned"),
], pk=["school_year_sk", "district_sk", "attempt_id"])

fact("fact_program_participation", "programs", "Coverage: SSID x school x program (I06) x start date (I07).", [
    year("I01"), STUDENT, DISTRICT, SCHOOL("I05"),
    ref("dim_program", "I06", "Attribute or program"),
    date("start", "I07", "Program start date"),
    date("exit", "I08", "Program exit date (-2 while active)"),
    ref("dim_program_participation_junk", "I09,I10", "Exit reason and qualification"),
    ref("dim_disability", "I10", "Primary disability when I06 = 36 (-2 otherwise)"),
    col("participation_days", "INT", "I07,I08,A08", "Derived: calendar days from I07 to I08 (or A08)"),
], pk=["school_year_sk", "student_sk", "school_sk", "program_sk", "start_date_sk"])

fact("fact_el_program", "programs", "Coverage + placement test: SSID x school x EL program start (J07).", [
    year("J01"), STUDENT, DISTRICT, SCHOOL("J05"),
    ref("dim_program", "J17", "EL program designation"),
    ref("dim_grade_level", "J19", "Grade level at placement"),
    date("start", "J07", "Program status start date"),
    date("exit", "J08", "Program exit date"),
    date("initial_wa_placement_test", "J13", "Initial WA placement test date"),
    date("placement_test", "J22", "Placement test date"),
    ref("dim_el_junk", "J06,J09,J18,J21", "EL codes"),
    col("placement_test_scale_score", "INT", "J20", "Placement test scale score"),
    col("placement_test_level_score", "DECIMAL(2,1)", "J23", "Overall placement test score (0.0-6.0)"),
    col("participation_days", "INT", "J07,J08,A08", "Derived: calendar days from J07 to J08 (or A08)"),
], pk=["school_year_sk", "student_sk", "school_sk", "start_date_sk"])

fact("fact_sped_program", "programs", "Coverage: SSID x district x SpEd program start (K14); school inferred from "
     "File C (C-005).", [
    year("K01"), STUDENT, DISTRICT,
    ref("dim_school", "C05,C10", "School inferred from the covering File C enrollment (-1 if none)"),
    ref("dim_program", "K14", "Special education (single member)"),
    date("start", "K14", "Program start date"),
    date("exit", "K08", "Program exit date"),
    date("annual_iep_meeting", "K25", "Date of annual IEP meeting"),
    ref("dim_lre", "K06", "Least restrictive environment"),
    ref("dim_non_public_agency", "K15", "Non-public agency"),
    ref("dim_prek_outcome_junk", "K16,K17,K18,K19,K20,K21,K22,K23,K24", "PreK outcome ratings"),
    ref("dim_sped_junk", "K09,K26,K27", "Exit reason, interpreter, transition consent"),
    col("participation_days", "INT", "K14,K08,A08", "Derived: calendar days from K14 to K08 (or A08)"),
], pk=["school_year_sk", "student_sk", "district_sk", "start_date_sk"])

fact("fact_lap_growth", "programs", "Spell with scores: SSID x school x LAP program (Q06) x start date (Q07).", [
    year("Q01"), STUDENT, DISTRICT, SCHOOL("Q05"),
    ref("dim_program", "Q06", "LAP / WRC program"),
    date("start", "Q07", "Program start date"),
    date("beginning_score", "Q12", "Date of beginning score"),
    date("end_score", "Q14", "Date of end score"),
    ref("dim_growth_assessment", "Q08", "Identification assessment", name="identification_assessment_sk"),
    ref("dim_growth_assessment", "Q10", "Progress monitoring assessment", name="progress_monitoring_assessment_sk"),
    ref("dim_lap_junk", "Q09,Q15,Q16,Q17", "Growth and intervention codes"),
    col("beginning_score", "DECIMAL(6,2)", "Q11", "Beginning score"),
    col("end_score", "DECIMAL(6,2)", "Q13", "End score"),
    col("growth_months", "INT", "Q09", "Derived: Q09 as months (0-20); NULL for other codes (C-007)"),
], pk=["school_year_sk", "student_sk", "school_sk", "program_sk", "start_date_sk"])

fact("fact_support_screening", "programs", "Event (factless): SSID x school x support code (V06) screening.", [
    year("V01"), STUDENT, DISTRICT, SCHOOL("V05"),
    ref("dim_program", "V06", "Support code"),
    date("identification_assessment", "V08", "Identification assessment date"),
    ref("dim_support_screening_junk", "V07,V09", "Identification assessment and determination"),
    ref("dim_intervention_group", "V10", "Interventions used (bridge)"),
], pk=["school_year_sk", "student_sk", "school_sk", "program_sk"])

fact("fact_absence", "attendance", "Transaction: SSID x school x absence date (N06).", [
    year("N01"), STUDENT, DISTRICT, SCHOOL("N05"),
    date("absence", "N06", "Absence date"),
    ref("dim_absence_type", "N07", "Absence type"),
    col("absence_count", "INT", "N07", "Always 1"),
    col("full_day_flag", "INT", "N07", "1 when N07 is EF or UF"),
    col("part_day_flag", "INT", "N07", "1 when N07 is EP or UP"),
    col("excused_flag", "INT", "N07", "1 when N07 is EF or EP"),
], pk=["school_year_sk", "student_sk", "school_sk", "absence_date_sk", "absence_type_sk"], cluster2="school_sk")

fact("fact_exclusionary_action", "discipline", "Transaction: one exclusionary action within an incident; incident "
     "is degenerate (incident_key = district + R06) with R01-R10 on every row.", [
    year("R01"), STUDENT, DISTRICT, SCHOOL("R05"),
    col("incident_key", "STRING", "R02,R06", "Degenerate: district + incident ID"),
    col("incident_id", "STRING", "R06", "Degenerate: incident ID"),
    date("incident", "R07", "Incident date"),
    date("action", "R12", "Exclusionary action date"),
    ref("dim_behavior", "R08", "Behavior"),
    ref("dim_other_behavior_group", "R09", "Other behaviors (bridge_other_behavior)"),
    ref("dim_weapon", "R10", "Weapon type (-2 unless R08 = 8)"),
    ref("dim_exclusionary_action", "R11", "Exclusionary action applied"),
    ref("dim_discipline_junk", "R15,R16,R17,R20,R21,R23,R24,R25,R26,R27", "Discipline flags"),
    date("readmission_petition_submitted", "R18", "Date petition for readmission submitted"),
    date("readmission_petition_granted", "R19", "Date petition for readmission granted"),
    date("reengagement_meeting", "R22", "Date reengagement meeting held"),
    col("duration_days", "DECIMAL(4,1)", "R13", "Duration of exclusionary action (days)"),
    col("total_exclusionary_time", "DECIMAL(4,1)", "R14", "Total amount of exclusionary time"),
], pk=["school_year_sk", "incident_key", "student_sk", "exclusionary_action_sk", "action_date_sk"])

fact("fact_restraint_isolation", "discipline", "Transaction: action (district + S06).", [
    year("S01"), STUDENT, DISTRICT, SCHOOL("S05"),
    col("action_key", "STRING", "S02,S06", "Degenerate: district + action ID"),
    col("action_id", "STRING", "S06", "Degenerate: action ID"),
    date("action", "S07", "Action date"),
    ref("dim_restraint_isolation_type", "S09", "Type of restraint or isolation"),
    ref("dim_restraint_junk", "S10,S12", "Injury and safety-staff flags"),
    col("duration_minutes", "DECIMAL(4,1)", "S08", "Action duration (minutes)"),
    col("staff_injured_count", "INT", "S11", "Number of staff injured"),
], pk=["school_year_sk", "action_key", "student_sk", "restraint_isolation_type_sk"])

fact("fact_initial_evaluation", "evaluation", "Accumulating snapshot: one initial referral (SSID x district x U05).", [
    year("U01"), STUDENT, DISTRICT,
    date("referral", "U05", "Date of initial referral"),
    date("consent", "U06", "Date district received consent"),
    date("eligibility_determination", "U07", "Date of initial evaluation/eligibility determination"),
    date("initial_iep_meeting", "U11", "Date of initial IEP meeting (-2 unless U10 = 1)"),
    ref("dim_initial_evaluation_junk", "U09,U10,U12,U13", "Late reasons, outcome, interpreter"),
    col("school_days_to_complete", "INT", "U08", "School days to complete initial evaluation/eligibility"),
    col("referral_to_consent_days", "INT", "U05,U06", "Derived: calendar days U05 -> U06"),
    col("consent_to_eligibility_days", "INT", "U06,U07", "Derived: calendar days U06 -> U07"),
    col("eligibility_to_iep_days", "INT", "U07,U11", "Derived: calendar days U07 -> U11"),
    col("referral_to_iep_days", "INT", "U05,U11", "Derived: calendar days U05 -> U11"),
], pk=["school_year_sk", "student_sk", "district_sk", "referral_date_sk"])

TABLES = {t.name: t for t in T}

FAMILIES = {
    "enrollment": "Enrollment and student year",
    "course": "Courses, sections and credit",
    "programs": "Programs and services",
    "attendance": "Attendance",
    "discipline": "Discipline and restraint",
    "evaluation": "Special-education initial evaluation",
}

# BI helper views (design §5.11)
VIEWS = {
    "v_students_by_federal_race_ethnicity": """SELECT
  y.school_year_label,
  d.county_district_code,
  d.district_name,
  f.federal_race_ethnicity,
  COUNT(DISTINCT f.student_sk) AS student_count
FROM ${catalog}.gold.fact_student_school_year AS f
JOIN ${catalog}.gold.dim_school_year AS y ON f.school_year_sk = y.school_year_sk
JOIN ${catalog}.gold.dim_district AS d ON f.district_sk = d.district_sk
GROUP BY y.school_year_label, d.county_district_code, d.district_name, f.federal_race_ethnicity""",
    "v_students_by_race_weighted": """SELECT
  b.school_year_sk,
  b.district_sk,
  r.race_category,
  SUM(b.weighting_factor) AS weighted_student_count,
  COUNT(DISTINCT b.student_sk) AS students_reporting_race
FROM ${catalog}.gold.bridge_student_race AS b
JOIN ${catalog}.gold.dim_race AS r ON b.race_sk = r.race_sk
GROUP BY b.school_year_sk, b.district_sk, r.race_category""",
    "v_courses_by_designation": """SELECT
  c.school_year_sk,
  c.county_district_code,
  c.school_code,
  cd.code AS course_designation_code,
  cd.description AS course_designation,
  COUNT(DISTINCT c.course_sk) AS course_count
FROM ${catalog}.gold.dim_course AS c
JOIN ${catalog}.gold.bridge_course_designation AS b ON c.course_sk = b.course_sk
JOIN ${catalog}.gold.dim_course_designation AS cd ON b.course_designation_sk = cd.course_designation_sk
GROUP BY c.school_year_sk, c.county_district_code, c.school_code, cd.code, cd.description""",
}
