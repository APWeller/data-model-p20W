# CEDARS Warehouse: Dimensional Design

Status: agreed design, as of the handoff from design sessions. Source: CEDARS 2026-27
manual v19.0 and appendices.

## 1. Scope and assumptions

**In scope**

- Statewide warehouse: all districts' CEDARS submissions.
- The 19 active CEDARS files (A–V, excluding P). File P is retired and is not modeled.
- Inactive elements are catalogued but not modeled.

**Submission handling**

- Gold is built from each school year's **year-end final** submission.
- Bronze retains every extract received.

**Deferred.** Keep the seams described here, but don't build these:

- **Prior-year backload.** Keep `_manual_version` on all tables. The catalog is keyed
  by manual version.
- **SSID merge/retirement handling.** For now, `dim_student` is keyed on SSID as
  reported.
- **Postsecondary conformance.** The student, date and institution dimensions
  (Appendix AM) should not preclude it later.

## 2. Source facts that shaped the design

- **No section file.** A section exists only as course ID + section ID + term, inside
  Student Schedule (E) and Staff Schedule (G).
- **District-scoped IDs.** District Student ID, Location ID (the district's own SIS
  number), Staff ID and Course ID are all scoped to a district, school or year. The
  statewide keys are:
  - SSID for students
  - OSPI school code (A05) for schools
  - certification number (F05) for certificated staff
- **File H resends full grade history every year.** This includes out-of-district
  courses (H26 = 9999) and prior years (H30 Course School Year).
- **File E and File H overlap.** E carries grades and credits for all PK–12 courses.
  H carries high-school credit courses and must match the transcript. They overlap for
  current-year high-school courses.
- **No instructional-day calendar.**
  - C12 gives cumulative days present per enrollment.
  - N gives daily absences, coded excused/unexcused × full/part day
    (EF, UF, EP, UP).
  - A07/A08 give each school's first and last day of the school year.
- **File R repeats incident data.** Incident fields R01–R10 repeat on every action row.
  R09 (other behaviors) can hold several values.
- **Comma-separated multi-valued elements** (verify in phase 1): B43, D07, D17, D20,
  D21, E15, E16, H13, H31, H32, R09, V10.

## 3. Fact tables

| Fact | Source | Kimball type | Grain | Measures |
|---|---|---|---|---|
| fact_district_enrollment | B | Coverage (spell) | SSID × serving district × entry date (B14) | enrolled_days (derived) |
| fact_school_enrollment | C | Coverage (spell) | SSID × school × entry date (C06) | days_present (C12), enrolled_days |
| fact_student_section | E | Transaction | SSID × section (school, course, section, term) | credits_attempted (E13), credits_earned (E14) |
| fact_staff_section | G | Factless | staff × section | instruction_days (derived from G08/G09) |
| fact_transcript_course | H | Transaction, full history | SSID × course school year (H30) × term (H19) × school code (H26) × course ID (H07) | credits_attempted (H11), credits_earned (H12) |
| fact_nontraditional_credit | T | Transaction | attempt (district + T06) | credits_attempted (T16), credits_earned (T17) |
| fact_program_participation | I | Coverage (spell) | SSID × school × program code (I06) × start date (I07) | participation_days |
| fact_el_program | J | Coverage + placement test | SSID × school × EL program start (J07) | placement test scores (J20, J23) |
| fact_sped_program | K | Coverage (spell) | SSID × school × SpEd program start (K14) | participation_days; PreK outcome ratings (K16–K24) are dimensions |
| fact_lap_growth | Q | Spell with begin/end scores | SSID × school × LAP program (Q06) × start date (Q07) | beginning_score (Q11), end_score (Q13), academic_growth (Q09) |
| fact_support_screening | V | Event | SSID × school × support code (V06) screening | none (factless) |
| fact_absence | N | Transaction | SSID × school × absence date (N06) | absence_count (=1), full_day_flag, part_day_flag, excused_flag |
| fact_exclusionary_action | R | Transaction | one exclusionary action within an incident | duration_days (R13), total_exclusionary_time (R14) |
| fact_restraint_isolation | S | Transaction | action (district + S06) | duration (S08), staff_injured_count (S11) |
| fact_initial_evaluation | U | Accumulating snapshot | one initial referral | school_days_to_complete (U08), plus lag measures between milestones |
| fact_student_school_year | derived | Periodic snapshot | SSID × serving district × school year | enrolled_days, days_present, absence counts by type, credits, GPA, status flags |

Notes on individual facts:

- **fact_exclusionary_action.** The incident is a degenerate dimension:
  `incident_key` = county district code + R06. The incident attributes from R01–R10 are
  carried on every action row. R09 goes to `bridge_other_behavior`.
- **fact_initial_evaluation.** Milestone date roles:
  - referral (U05)
  - consent (U06)
  - evaluation/eligibility (U07)
  - initial IEP meeting (U11)
- **fact_student_school_year.** Also carries the year-scoped student attributes listed
  in §4.1: grade, home language, graduation requirements year, expected graduation
  year, cumulative GPA and credits (B28–B30), credit waiver, ASVAB (B39–B41),
  performance-based pathway years (B44, B45), and age as of September 1.
- **fact_student_section vs fact_transcript_course.** Never sum credits across the two.
  H is authoritative for transcript credits; E is authoritative for schedules.

## 4. Bus matrix

| Fact | Date | Year | Student | District | School | Grade | Course | Section | Staff | Program | Dimensions specific to this fact |
|---|---|---|---|---|---|---|---|---|---|---|---|
| District enrollment | ✓ | ✓ | ✓ | ✓ | | ✓ | | | | | Home district (district in a second role), student profile |
| School enrollment | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | | | | Withdrawal code, school choice, primary-school flag, student profile |
| Student section | | ✓ | ✓ | ✓ | ✓ | | ✓ | ✓ | | | Letter grade, ALE type, online provider/program; industry certs and work-based learning via bridges |
| Staff section | ✓ | ✓ | | ✓ | ✓ | | ✓ | ✓ | ✓ | | Teacher indicator |
| Transcript course | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | | | Letter grade, CTE flags; course designation via bridge |
| Non-traditional credit | | ✓ | ✓ | ✓ | ✓ | | ✓ | | | | Letter grade, ALE type, online provider/program |
| Program participation | ✓ | ✓ | ✓ | ✓ | ✓ | | | | | ✓ | Exit reason, qualification code |
| EL program | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | | | ✓ | Instructional model, placement test, placement status, exit reason |
| SpEd program | ✓ | ✓ | ✓ | ✓ | ✓ | | | | | ✓ | LRE, non-public agency, PreK outcomes, exit reason |
| LAP growth | ✓ | ✓ | ✓ | ✓ | ✓ | | | | | ✓ | Identification assessment, progress-monitoring assessment, interventions |
| Support screening | ✓ | ✓ | ✓ | ✓ | ✓ | | | | | ✓ | Identification assessment, determination; interventions via bridge |
| Absence | ✓ | ✓ | ✓ | ✓ | ✓ | | | | | | Absence type |
| Exclusionary action | ✓ | ✓ | ✓ | ✓ | ✓ | | | | | | Behavior, weapon, action type, IAES, discipline junk dimension (services, petitions, reengagement, appeal, school-security-staff involvement); other behaviors via bridge |
| Restraint/isolation | ✓ | ✓ | ✓ | ✓ | ✓ | | | | | | Restraint/isolation type, restraint junk dimension (injury, school-security-staff involvement) |
| Initial evaluation | ✓ | ✓ | ✓ | ✓ | | | | | | | Late-evaluation reason, outcome, late Part C transition reason |
| Student school year | | ✓ | ✓ | ✓ | ✓ | ✓ | | | | | Student profile, race/ethnicity rollups, primary school (C10) |

## 5. Dimensions

### 5.1 dim_student (thin)

One row per SSID version.

| Attribute | Source | Handling |
|---|---|---|
| ssid | B05 | Durable natural key |
| gender | B12 | SCD2 |
| birth_country | B10 → Appendix C | Type 1 |
| primary_language | B17 → Appendix K | Type 1 (a change is a correction) |
| initial_us_school_enrollment_date | B32 | Type 1 |
| months_non_us_attendance | B34 | Type 1 |

**Survivorship.** When districts disagree, each attribute takes its value from the
student's most recent district enrollment record: latest school year, then latest B14
entry date. Ties go to the district whose school is primarily responsible (C10 = Y).
All reported values are retained in `silver.student_attribute_history`.

**dim_student_pii** holds the restricted fields, keyed by SSID:

- legal names (B06–B08)
- preferred names (B36–B38)
- birth date (B09)
- residential ZIP+4 (B20)

Access is controlled with Unity Catalog grants and column masking. No gold fact or
analyst-facing view needs this table.

### 5.2 dim_student_profile (mini-dimension)

One row per distinct combination of these low-cardinality flags:

- homeless (B21)
- immigrant (B31)
- military parent (B35)
- exchange status (B24)
- private-school part-time (B22)
- home-school part-time (B23)
- flags derived from File I for the reporting period: low income, special education,
  Section 504, EL, and others per the Appendix F categories

It attaches to the enrollment facts and to fact_student_school_year.

### 5.3 dim_district

- **Key:** county_district_code (A02).
- **Attributes:** district_name (A03), SCD2; county, derived from Appendix A.
- **Roles:** serving district, home district (B03).

### 5.4 dim_school

- **Key:** county_district_code + OSPI school_code (A05).
- **Attributes:** school_name (A06), SCD2.
- **Special members:** 9999 = out-of-district school (File H), plus the standard
  -1 and -2.

Related tables:

- `dim_school_year_calendar` (school × school year) holds the first and last day of the
  school year (A07, A08).
- `silver.xref_location` maps school year + district + Location ID (A04) → school code.
  Every file except A and H references Location ID and must resolve through it.

### 5.5 dim_staff

- **Key:** county_district_code + staff_id (F03).
- **Attributes:** certification_number (F05), for cross-district rollups where present.
- **Restricted outrigger:** names (F06–F08) and birth date (F09) go in a separate table.
- **bridge_staff_type:** staff × school year × staff type code (F04 → Appendix U).
  File F has one row per staff type per staff member.

### 5.6 Course dimensions

**dim_state_course** is the conformed level.

- **Key:** state course code (Appendix V).
- **Attributes:** OSPI descriptors, if Appendix V provides them. If Appendix V is
  external, create code-only members.

**dim_course** is the local course.

- **Key:** school year + district + school + course ID.
- **Attributes:**
  - title (D05)
  - content area (D06 → Appendix O)
  - CIP (D10 → Appendix S)
  - AP/IB/Cambridge (D09 → Appendix Q)
  - CTE equivalency (D12, D13)
  - dual language type and language (D14, D15)
  - course level (D16)
  - sequence and sequence group (D18, D19)
  - link to dim_state_course (D08)
- **Members** come from three sources, recorded in a `catalog_source` column:
  - `D`: the course catalog.
  - `H`: inferred members built from File H's own attributes (H07, H08, H13–H17) for
    courses that never appeared in a catalog, including school 9999 and prior years.
  - `T`: inferred members built from File T (T07–T11).
- **Bridges from dim_course:**
  - `bridge_course_designation` (D07)
  - `bridge_course_industry_cert_offered` (D17 → Appendix AK)
  - `bridge_course_wbl_offered` (D20)
  - `bridge_course_higher_ed_institution` (D21 → Appendix AM)

**dim_section**

- **Key:** school year + district + school + course ID + section ID + term.
- **Built from** the union of the E and G keys.
- **Attributes:** term code (Appendix P), term start and end dates (G11, G12), link to
  dim_course.

fact_staff_section, filtered on the teacher indicator (G10), is the path from a
student's section to its teacher of record.

### 5.7 dim_program (unified)

Members:

- Appendix F attribute/program codes (I06)
- EL program designation (J17)
- special education (single member)
- LAP and Washington Reading Corps programs (Q06, a subset of the F codes)
- support codes (V06)

Attributes: `program_family`, `program_name`, `category`
(attribute / program / eligibility). SCD2 by effective school year.

### 5.8 Standard dimensions

- **dim_date:** standard calendar attributes plus the school year it falls in.
- **dim_school_year:** year code, manual version, start and end dates.
- **dim_grade_level:** Appendix E codes, sort order, grade band.

### 5.9 Code-set dimensions

All code sets live in `ref.ref_code` (code_set, code, description, rollups,
valid_from_year, valid_to_year). Gold exposes them in one of two ways.

**Standalone dimensions**, for code sets shared across facts or with hierarchies:

- language (Appendix K), with roles: primary language, home language, family
  communication language (a bridge, B43), dual-language instruction language
- country (Appendix C)
- race (Appendix Z)
- ethnicity (Appendix Y)
- disability (Appendix I)
- behavior (Appendix B)
- weapon (Appendix D)
- CIP (Appendix S)
- AP/IB/Cambridge (Appendix Q)
- higher-ed institution (Appendix AM)
- industry certification (Appendix AK)
- intervention (Appendix AH)
- staff type (Appendix U)

**Junk dimensions per fact**, for flag-like or single-use codes. Examples:

- the discipline junk dimension for R15–R27
- the restraint junk dimension for S10, S12–S14
- the enrollment junk dimension for C09–C11 and C14

### 5.10 Race and ethnicity

- `bridge_student_race` (M05, M06) and `bridge_student_ethnicity` (L05, L06), keyed by
  SSID and school year.
- Derived rollups on fact_student_school_year: federal race/ethnicity category (Hispanic
  of any race first, then two or more races) and the OSPI reporting category. Use the
  rollup mappings in Appendices Y and Z where they are provided.

### 5.11 Bridges and BI usability

Every multi-valued element listed in §2 becomes a bridge table. For Tableau use,
provide:

- a weighting factor on each bridge (1 / number of values), and
- pre-aggregated views for common questions, e.g. students by federal race category,
  and courses by designation.

## 6. Key rules

- **File H deduplication.** Latest reported version wins, keyed on SSID + H30 + H19 +
  H26 + H07. Superseded versions stay in silver. The tie-break when two districts report
  the same key in the same year is open; log it in the decisions log.
- **Enrollment spells.** B and C spells may not overlap within a district or school
  (manual rule). Overlaps across districts are legitimate and are kept.
- **Attendance denominators.** Enrolled days are approximated from days present (C12)
  plus full-day absences, bounded by the school-year dates in A07/A08. A true
  instructional-day calendar is an open question, and any rate built on this
  approximation must say so.
- **Pre-2018-19 discipline (File P).** Not modeled now. If backloaded later, it goes into
  fact_exclusionary_action with a lower-fidelity flag.

## 7. Open questions (track in decisions-log.md)

1. Tie-break rule for File H duplicate keys across districts within one year.
2. Instructional-day calendar source for attendance rates.
3. Which appendices are external lists (V, S, AM?), and where to source their values.
4. Uniqueness scope of incident IDs (R06) and action IDs (S06): district, or school?
