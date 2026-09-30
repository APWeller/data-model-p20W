# Silver layer contract

What the silver tables in `sql/silver/` promise, and the rules a load pipeline must follow
to keep that promise. Pipelines are out of scope for this repo. This document is the
specification they are built against.

- **Generator:** `tools/gen_ddl.py`, with column names, keys and derived columns set in
  `tools/silver_spec.py`.
- **Lineage (element → column):** `catalog/silver_columns.csv`.
- **Decisions referenced below:** `docs/decisions-log.md`.

## 1. Tables

| Table | Source | Natural key (plus `_submission_type`) |
|---|---|---|
| `location` | File A | school_year, county_district_code, location_id, school_code |
| `district_student_enrollment` | B | school_year, county_district_code, ssid, district_enrollment_date |
| `school_student_enrollment` | C | school_year, county_district_code, ssid, location_id, school_enrollment_date |
| `course_catalog` | D | school_year, county_district_code, location_id, course_id |
| `student_schedule` | E | school_year, county_district_code, ssid, location_id, course_id, section_id, term |
| `staff` | F | school_year, county_district_code, staff_id, staff_type_code |
| `staff_schedule` | G | school_year, county_district_code, location_id, staff_id, course_id, section_id, term, instruction_start_date |
| `student_grade_history` | H | school_year, county_district_code, ssid, course_school_year, term_key, school_code, course_id |
| `student_program` | I | school_year, county_district_code, ssid, location_id, program_code, program_start_date |
| `english_learner_program` | J | school_year, county_district_code, ssid, location_id, program_start_date |
| `special_education_program` | K | school_year, county_district_code, ssid, program_start_date |
| `student_ethnicity` | L | school_year, county_district_code, ssid, ethnicity_code |
| `student_race` | M | school_year, county_district_code, ssid, race_code |
| `student_absence` | N | school_year, county_district_code, ssid, location_id, absence_date, absence_code |
| `student_growth` | Q | school_year, county_district_code, ssid, location_id, program_code, program_start_date |
| `exclusionary_discipline` | R | school_year, county_district_code, ssid, location_id, incident_id, incident_date, exclusionary_action_code, exclusionary_action_date |
| `restraint_isolation` | S | school_year, county_district_code, ssid, location_id, action_id, action_date, restraint_isolation_type_code |
| `nontraditional_credit` | T | school_year, county_district_code, ssid, location_id, attempt_id |
| `initial_evaluation` | U | school_year, county_district_code, ssid, initial_referral_date |
| `student_support` | V | school_year, county_district_code, ssid, location_id, support_code |
| `xref_location` | A | school_year, county_district_code, location_id, school_code |
| `xref_student` | all files with a District Student ID | school_year, county_district_code, district_student_id, ssid |
| `xref_staff` | F | school_year, county_district_code, staff_id |
| `student_attribute_history` | B | ssid, school_year, county_district_code, district_enrollment_date, attribute_element_id |
| `student_pii_history` | B (restricted) | same as above |

Keys come from the Data Element Summary's key column, with three exceptions:
- **File H** uses the design grain, because the manual key H01/H02/H04 is not unique (C-006).
- **Files L and M** add the ethnicity/race code, because the manual allows several rows per
  student.

## 2. Submissions

- **Bronze** keeps every extract received.
- **Silver** keeps the latest load for each (school year, district, file, `_submission_type`).
  A reload of the same submission type replaces that district's rows for the year.
- **Gold** reads `_submission_type = year-end final` only (design §1).
- `_manual_version` is on every row. It is the seam for a future backload of prior years.

## 3. Typing and normalization

- **Codes are STRING (D-028).** Every element with a code set is typed STRING, whatever the
  manual's data type. After trimming, a code is normalized to the canonical form of its code
  set in `ref.ref_code`:
  - numeric codes are zero-padded when the code set is padded (Appendix B behavior `02`),
    and unpadded otherwise (S09 `4`)
  - AP/IB/CI codes are rendered with 2 decimals (`1.01`)
  - letter codes are upper-cased
- **Other types:**
  - Dates are parsed from `MM/DD/YYYY`.
  - H18 (`MM/YYYY`) stays STRING in `term_end_month`, with `term_end_month_date` derived.
  - Years stored as char(4) (A01, B26, B27, B41, B44, B45, H30) become INT.
  - Numerics use DECIMAL(p,s) from the manual. R13 is widened to DECIMAL(4,1) (D-013).
- **Blank handling:** blanks and whitespace become NULL, which is how the manual itself
  says CEDARS treats them.
- **Multi-valued elements** become `ARRAY<STRING>`, with the as-reported value kept in
  `<column>_raw`:
  - B43, D17, D20, D21, H31, H32, R09, V10: split on comma, then trim each value.
  - D07, H13, T10: split into single characters, because the codes are concatenated with
    no delimiter (for example `IC`).
- **PII.** PII columns (B06–B09, B20, B36–B38, F06–F09) stay in the entity tables. They are
  listed in the `cedars.pii_columns` table property, so column masks can be applied at
  deploy time. `student_pii_history` is restricted as a whole table.

## 4. Crosswalks

- **`xref_location`** comes from File A.
  - Every Location ID in C, D, E, G, I, J, N, Q, R, S, T and V resolves to `school_code`
    via (school_year, county_district_code, location_id).
  - Unresolved → `school_code` NULL plus DQ001.
  - More than one A05 for the key → `is_ambiguous`, `school_code` NULL, plus DQ002.
  - Files B, F, K, L, M and U have no active Location ID (C-005). File H carries the OSPI
    school code directly (H26).
- **`xref_student`** comes from every (district_student_id, ssid) pair reported in any file
  for the year. A district student ID that maps to more than one SSID (or the reverse) sets
  `is_conflict` plus DQ003 (manual B04 rule).
- **`xref_staff`** comes from File F. F05 `UNK` becomes NULL. A staff ID with more than one
  certification number sets `is_conflict` plus DQ010.

## 5. Derived columns

| Column | Rule |
|---|---|
| `special_education_program.inferred_school_code` | Among File C enrollments for the same year, district and SSID whose spell covers K14: first choose the one with C10 = Y, which gives method `primary_enrollment`. Otherwise use the only one, which gives `single_enrollment`. Otherwise NULL, with `none` and DQ007 (C-005). |
| `student_grade_history.term_key` | `coalesce(H19, '')` |
| `student_grade_history.is_out_of_district` | `H26 = '9999'` |
| `student_grade_history.is_current_version` | TRUE for the latest version of (SSID, H30, H19, H26, H07) across all submissions, ranked by school_year desc then `_load_ts` desc. If two districts report the same key in the same school year, both stay current and DQ008 is raised. That tie-break is design open question 1. |
| `student_growth.growth_months` | Q09 as an integer when Q09 is 0–20; NULL for -1, 21 and 22–27 (C-007) |
| `exclusionary_discipline.incident_key` | `county_district_code \|\| '\|' \|\| incident_id` (design §3). DQ006 if the same key appears at more than one location (C-009). |
| `restraint_isolation.action_key` | `county_district_code \|\| '\|' \|\| action_id` |
| `*.school_code` | Resolved through `xref_location` (§4) |

## 6. Student attribute history and survivorship

- **Contents.** `student_attribute_history` holds one row per (SSID, school year, district,
  B14 spell, attribute) for every non-PII student attribute in File B. `student_pii_history`
  does the same for B06–B09, B20 and B36–B38.
- **Survivorship rank.** `survivorship_rank = 1` marks the surviving value for dim_student
  (design §5.1). Rows are ordered by:
  1. school_year desc
  2. district_enrollment_date desc
  3. `is_primary_responsibility_district` desc (any C10 = Y enrollment in the district
     overlapping the spell)
  4. `_load_ts` desc
  5. county_district_code (a deterministic last resort)

## 7. Data-quality checks

Checks never drop rows. A failing row carries the check ID in `_dq_issues`. The IDs are:
- `IR###`: manual rules, from `catalog/integrity_rules.csv`
- `DQ###`: warehouse checks, listed below

| ID | Check |
|---|---|
| DQ001 | Location ID not found in `xref_location` for the year and district |
| DQ002 | Location ID maps to more than one school code |
| DQ003 | District student ID ↔ SSID conflict |
| DQ004 | Code not in `ref.ref_code` for its code set, valid in the row's school year (`valid_from_year ≤ year ≤ valid_to_year`, NULL = open) |
| DQ005 | File S student has no File B / File C record in the district. This is not stated in the manual; it is enforced as a warehouse check (D-010). |
| DQ006 | Incident ID (R06) reported at more than one location within the district |
| DQ007 | File K record whose school cannot be inferred from File C |
| DQ008 | File H dedupe key reported by more than one district in the same school year |
| DQ009 | Overlapping enrollment spells within a district (B) or school (C); covers IR050/IR051 |
| DQ010 | Staff ID with more than one certification number |
| DQ011 | I10 value not in the code set that `catalog/i10_qualification_map.csv` assigns to the row's I06; no check for unmapped programs (D-023) |
