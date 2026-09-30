"""Curated silver-layer specification: table names, column names, keys and derived columns.

Everything else (types, comments, multi-valued arrays) is derived from catalog/elements.csv
and catalog/code_sets.csv by tools/gen_ddl.py.
"""

# One silver entity per active CEDARS file. key = the natural key (element IDs, plus derived
# column names where the manual key is not unique). Bronze uses the same table names.
FILES = {
    "A": dict(table="location", key=["A01", "A02", "A04", "A05"]),
    "B": dict(table="district_student_enrollment", key=["B01", "B02", "B05", "B14"],
              pii=["B06", "B07", "B08", "B09", "B20", "B36", "B37", "B38"]),
    "C": dict(table="school_student_enrollment", key=["C01", "C02", "C04", "C05", "C06"]),
    "D": dict(table="course_catalog", key=["D01", "D02", "D03", "D04"]),
    "E": dict(table="student_schedule", key=["E01", "E02", "E04", "E05", "E06", "E07", "E08"]),
    "F": dict(table="staff", key=["F01", "F02", "F03", "F04"], pii=["F06", "F07", "F08", "F09"]),
    "G": dict(table="staff_schedule", key=["G01", "G02", "G03", "G04", "G05", "G06", "G07", "G08"]),
    # Manual key (H01, H02, H04) is not unique; design grain SSID x H30 x H19 x H26 x H07 (C-006).
    "H": dict(table="student_grade_history", key=["H01", "H02", "H04", "H30", "term_key", "H26", "H07"]),
    "I": dict(table="student_program", key=["I01", "I02", "I04", "I05", "I06", "I07"]),
    "J": dict(table="english_learner_program", key=["J01", "J02", "J04", "J05", "J07"]),
    "K": dict(table="special_education_program", key=["K01", "K02", "K04", "K14"]),
    # Manual key (L01-L04) allows several ethnicity rows per student; add the code (M likewise).
    "L": dict(table="student_ethnicity", key=["L01", "L02", "L04", "L05"]),
    "M": dict(table="student_race", key=["M01", "M02", "M04", "M05"]),
    "N": dict(table="student_absence", key=["N01", "N02", "N04", "N05", "N06", "N07"]),
    "Q": dict(table="student_growth", key=["Q01", "Q02", "Q04", "Q05", "Q06", "Q07"]),
    "R": dict(table="exclusionary_discipline", key=["R01", "R02", "R04", "R05", "R06", "R07", "R11", "R12"]),
    "S": dict(table="restraint_isolation", key=["S01", "S02", "S04", "S05", "S06", "S07", "S09"]),
    "T": dict(table="nontraditional_credit", key=["T01", "T02", "T04", "T05", "T06"]),
    "U": dict(table="initial_evaluation", key=["U01", "U02", "U04", "U05"]),
    "V": dict(table="student_support", key=["V01", "V02", "V04", "V05", "V06"]),
}

# Column names. Defaults come from snake_casing the element name; these override it.
COMMON = {"01": "school_year", "02": "county_district_code", "03": "district_student_id", "04": "ssid"}
NAMES = {
    "A04": "location_id", "A05": "school_code",
    "B03": "home_county_district_code", "B04": "district_student_id", "B05": "ssid",
    "B06": "legal_last_name", "B07": "legal_first_name", "B08": "legal_middle_name",
    "B14": "district_enrollment_date", "B15": "district_exit_date", "B17": "primary_language_code",
    "B18": "home_language_code", "B20": "residential_zip_plus4", "B21": "homeless_status_code",
    "B22": "private_school_part_time_code", "B23": "home_school_part_time_code", "B24": "exchange_status_code",
    "B26": "graduation_requirements_year", "B27": "expected_graduation_year", "B28": "cumulative_gpa",
    "B29": "cumulative_credits_attempted", "B30": "cumulative_credits_earned",
    "B32": "initial_us_school_enrollment_date", "B34": "months_non_us_attendance", "B35": "military_parent_code",
    "B39": "asvab_test_status_code", "B40": "asvab_test_score", "B41": "asvab_school_year",
    "B42": "credit_waiver_code", "B43": "family_language_codes",
    "B44": "ela_pathway_completed_school_year", "B45": "math_pathway_completed_school_year",
    "C05": "location_id", "C06": "school_enrollment_date", "C08": "school_exit_date",
    "C09": "school_withdrawal_code", "C10": "is_primary_school", "C11": "school_choice_code",
    "C12": "days_present", "C14": "confirmed_transfer_in_code",
    "D03": "location_id", "D07": "course_designation_codes", "D09": "ap_ib_ci_course_code", "D10": "cip_code",
    "D12": "cte_equivalency_id_code", "D13": "cte_equivalency_code", "D14": "dual_language_type_code",
    "D15": "dual_language_language_code", "D16": "course_level_code", "D17": "industry_certification_codes_offered",
    "D20": "work_based_learning_codes_offered", "D21": "higher_ed_institution_codes",
    "E05": "location_id", "E09": "ale_course_type_code", "E10": "online_provider_code",
    "E11": "online_program_code",
    "F03": "staff_id", "F06": "legal_last_name", "F07": "legal_first_name", "F08": "legal_middle_name",
    "G03": "location_id", "G04": "staff_id", "G10": "teacher_indicator_code",
    "H09": "grade_level_code", "H10": "letter_grade", "H13": "course_designation_codes",
    "H16": "ap_ib_ci_course_code", "H17": "cip_code", "H18": "term_end_month", "H24": "cte_assessment_code",
    "H25": "teacher_certification_number", "H27": "ale_course_type_code", "H30": "course_school_year",
    "H31": "industry_certification_codes_earned", "H32": "work_based_learning_codes",
    "I05": "location_id", "I06": "program_code", "I07": "program_start_date", "I08": "program_exit_date",
    "I09": "exit_reason_code",
    "J05": "location_id", "J07": "program_start_date", "J13": "initial_wa_placement_test_date",
    "J17": "program_designation_code", "J20": "placement_test_scale_score", "J21": "placement_status_code",
    "J23": "placement_test_level_score",
    "K06": "lre_code", "K14": "program_start_date", "K15": "non_public_agency_code",
    "K16": "prek_social_emotional_entry_code", "K17": "prek_knowledge_skills_entry_code",
    "K18": "prek_behaviors_entry_code", "K19": "prek_social_emotional_exit_code",
    "K20": "prek_social_emotional_progress_code", "K21": "prek_knowledge_skills_exit_code",
    "K22": "prek_knowledge_skills_progress_code", "K23": "prek_behaviors_exit_code",
    "K24": "prek_behaviors_progress_code", "K25": "annual_iep_meeting_date",
    "K26": "interpreter_annual_iep_code", "K27": "transition_consent_code",
    "L05": "ethnicity_code", "L06": "ethnicity_collection_method_code",
    "M05": "race_code", "M06": "race_collection_method_code",
    "N05": "location_id", "N07": "absence_code",
    "Q05": "location_id", "Q06": "program_code", "Q07": "program_start_date", "Q08": "identification_assessment_code",
    "Q09": "academic_growth_code", "Q10": "progress_monitoring_assessment_code", "Q12": "beginning_score_date",
    "Q14": "end_score_date", "Q15": "extended_learning_intervention_code", "Q16": "regular_day_intervention_code",
    "Q17": "at_grade_level",
    "R05": "location_id", "R08": "behavior_code", "R09": "other_behavior_codes", "R10": "weapon_type_code",
    "R11": "exclusionary_action_code", "R13": "duration_days", "R14": "total_exclusionary_time",
    "R15": "iaes_code", "R16": "academic_services_code", "R17": "behavior_services_code",
    "R18": "readmission_petition_submitted_date", "R19": "readmission_petition_granted_date",
    "R20": "expulsion_extension_petition_code", "R21": "reengagement_plan_code",
    "R22": "reengagement_meeting_date", "R23": "appeal_code", "R24": "safety_staff_involvement_code",
    "R25": "safety_staff_used_force_code", "R26": "safety_staff_arrest_code",
    "R27": "interpreter_reengagement_meeting_code",
    "S05": "location_id", "S08": "action_duration_minutes", "S09": "restraint_isolation_type_code",
    "S10": "student_injured", "S11": "staff_injured_count", "S12": "safety_staff_involvement_code",
    "T05": "location_id", "T09": "content_area_code", "T10": "course_designation_codes",
    "T12": "ale_course_type_code", "T13": "online_provider_code", "T14": "online_program_code",
    "T18": "course_level_code",
    "U05": "initial_referral_date", "U06": "consent_received_date", "U07": "eligibility_determination_date",
    "U08": "school_days_to_complete", "U09": "late_evaluation_reason_code", "U10": "evaluation_outcome_code",
    "U11": "initial_iep_meeting_date", "U12": "late_part_c_transition_reason_code",
    "U13": "interpreter_initial_iep_code",
    "V05": "location_id", "V06": "support_code", "V07": "identification_assessment_code",
    "V09": "support_determination_code", "V10": "intervention_codes",
}

# Types that differ from the catalog-derived default (decisions log D-013 / D-028).
TYPE_OVERRIDES = {"R13": "DECIMAL(4,1)", "J20": "INT"}

# Location-bearing files: silver adds school_code resolved through xref_location.
LOCATION_ELEMENT = {"C": "C05", "D": "D03", "E": "E05", "G": "G03", "I": "I05", "J": "J05", "N": "N05",
                    "Q": "Q05", "R": "R05", "S": "S05", "T": "T05", "V": "V05"}

# Derived (non-element) silver columns per file: (name, type, not_null, comment).
DERIVED = {
    "H": [
        ("term_key", "STRING", True, "Derived: CEDARS H19 with NULL as '' (transfer credits have no term); dedupe-key member (C-006)"),
        ("term_end_month_date", "DATE", False, "Derived: first day of the month in CEDARS H18 (MM/YYYY)"),
        ("is_out_of_district", "BOOLEAN", False, "Derived: CEDARS H26 = 9999 (course taken outside the serving district)"),
        ("is_current_version", "BOOLEAN", False, "Derived: latest reported version of this SSID + H30 + H19 + H26 + H07 across submissions (design §6)"),
    ],
    "K": [
        ("inferred_school_code", "STRING", False, "Derived: CEDARS C05/A05 of the File C enrollment covering K14 (primary school C10 = Y preferred); File K has no active Location ID (C-005)"),
        ("school_inference_method", "STRING", False, "Derived: primary_enrollment | single_enrollment | none"),
    ],
    "Q": [
        ("growth_months", "INT", False, "Derived: CEDARS Q09 as months of growth when Q09 is 0-20; NULL otherwise (C-007)"),
    ],
    "R": [
        ("incident_key", "STRING", False, "Derived: CEDARS R02 + R06 (design: incident unique within district; see decisions C-009)"),
    ],
    "S": [
        ("action_key", "STRING", False, "Derived: CEDARS S02 + S06 (action unique within district; see decisions C-009)"),
    ],
}

# Attributes captured in silver.student_attribute_history (non-PII) and student_pii_history.
STUDENT_ATTRIBUTES = ["B10", "B12", "B13", "B17", "B18", "B21", "B22", "B23", "B24", "B26", "B27", "B28",
                      "B29", "B30", "B32", "B34", "B35", "B39", "B40", "B41", "B42", "B43", "B44", "B45"]
STUDENT_PII_ATTRIBUTES = ["B06", "B07", "B08", "B09", "B20", "B36", "B37", "B38"]
