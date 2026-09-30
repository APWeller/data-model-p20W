# Decisions log

One entry per decision. Status is **decided** (applied in the repo) or **OPEN** (needs a
human answer before the phase that depends on it).

Source for all entries: CEDARS 2026-27 manual v19.0 (`sources/2026-27_cedars_manual_v19.pdf`).

---

## Phase 1: source catalog

### D-001 · 2026-09-29 · decided: catalog columns extended beyond the CLAUDE.md list
- **Decision.** `catalog/elements.csv` carries every column CLAUDE.md lists, plus these:
  - `manual_version`
  - `is_key`: from the "Key" column of the Data Element Summary
  - `example`
  - `valid_values_text`: the raw valid-values block
  - `inline_value_groups`
  - `multi_value_encoding`
  - `multi_valued_evidence`
  - `source_page`

  `catalog/files.csv` adds these:
  - `manual_version`
  - `file_title`
  - `file_name`: the submission file name
  - `grain_source`
  - `key_elements`
  - `sample_file_name`
  - `element_count`
  - `source_page`
- **Reason.** Design §1 says the catalog is keyed by manual version (the backload seam).
  The other columns give provenance, so a reviewer can check every row against the PDF.
- **Elements affected.** All.

### D-002 · 2026-09-29 · decided: File P elements come from the publication history
- **Decision.** v19 has no File P definitions; page 141 is a stub. P01–P24 IDs and names
  are taken from the manual's publication history (pp. 201–202). Every other metadata
  column is blank, and `is_active = N`.
- **Reason.** The expected count is 24, and the history is the only v19 source that lists
  them. `allDataElements.csv` was not used: it is out of scope and is a research data
  dictionary, not the CEDARS element list.
- **Elements affected.** P01–P24.

### D-003 · 2026-09-29 · decided: names for inactive elements come from the publication history
- **Decision.** For 23 inactive elements, both the body heading and the TOC read "No
  Longer An Active Data Element". Their names come from the publication history, and the
  build verifies each name against the manual text. The list is `INACTIVE_NAMES` in
  `tools/parse_manual.py`.
- **Elements affected.** B11, B19, B25, C07, C13, D11, H05, H06, H20, H21, H22, H28, H29,
  J10, J11, J12, J14, J15, J16, K10, K11, K12, K13.

### D-004 · 2026-09-29 · decided: B16 is inactive
- **Decision.** B16 Disability Code is marked `is_active = N`.
- **Reason.** Its body heading does not say "no longer active". However, the Data
  Element Summary says "Element is inactive", and its business rule says disability has
  been reported in File I since 2014-15.
- **Elements affected.** B16.

### D-005 · 2026-09-29 · decided: multi-valued elements, verified
- **Decision.** Ten elements are `is_multi_valued = Y`. Each carries a verbatim evidence
  quote, which the build checks.
  - **Comma-separated:** B43, D17, D20, D21, H31, H32, R09, V10.
  - **Concatenated single-character codes, no delimiter:** D07, H13. The manual's
    example is `IC`, and the business rules allow combinations such as "T" with a CTE
    Core Plus code.

  Silver must split D07 and H13 by character, not by comma.
- **Not flagged:** E15 and E16. They are inactive in v19, their definitions have no
  business rules, and the claim can't be verified. They map to `INACTIVE`, so no bridge
  is needed. Their active successors, H31 and H32, are flagged.
- **Elements affected.** B43, D07, D17, D20, D21, E15, E16, H13, H31, H32, R09, V10.
- **Addendum (2026-09-29, phase 3).** **T10** Course Designation Code (File T) is also
  multi-valued, with concatenated codes. Its example is `IC`, and it has the same rule:
  "may also be reported with T – CTE Dual Credit (Tech Prep) in Element T10". It was not on
  the CLAUDE.md candidate list, so phase 1 missed it. It is now flagged, and gold needs a
  bridge for it.

### D-006 · 2026-09-29 · decided: source defect in the Course Designation value list
- **Decision.** The PDF prints `P RWT – Recruiting Washington Teachers`, with no dash after
  the code. This is parsed as code `P`, description `RWT – Recruiting Washington Teachers`.
- **Elements affected.** D07, H13, T10.

### D-007 · 2026-09-29 · decided: scope of `inline_valid_values`
- **Decision.** `inline_valid_values` holds only real code lists, as `code=description`
  joined with `|`. It excludes:
  - school-year constants (`2027`)
  - numeric ranges (B28–B30, B40, J20)
  - appendix pointers

  Bare code lists (J21, J23) are kept without descriptions. Two-column lists are kept
  with the second column as the description; H10 and T15 carry grade points this way.
  "NULL" listed as a value (D06, T09) is recorded in `inline_value_groups` as "NULL
  permitted".
- **Elements affected.** All elements with valid values; notably D06, H10, J21, J23, T09,
  T15.

### D-008 · 2026-09-29 · decided: I10 Qualification Code depends on I06 (resolved by D-023)
- **Decision.** I10's valid values are a family of sub-lists that depend on the program
  in I06:
  - Career Launch → Appendix AJ
  - Disability → Appendix I
  - District-issued device → Appendix AI
  - FRL → Appendix X
  - Gifted referral → inline A–F, K
  - GRADS → inline A–C
  - Reengagement → Appendix R
  - Seal of Biliteracy → Appendix K

  The groups are recorded in `inline_value_groups`. Codes collide across groups (A, B
  and C are in both Gifted and GRADS).
- **Open for phase 2.** Should these become separate code sets (proposed:
  `i10_gifted_referral`, `i10_grads_qualification`, plus the appendix sets), with I10
  resolved by the I06 program? A single I10 code set can't work because of the
  collisions.
- **Elements affected.** I06, I10.

### D-009 · 2026-09-29 · decided: group headings inside value lists
- **Decision.** Group headings are kept as rollups:
  - S09: Physical Restraint / Mechanical Restraint / Isolation
  - U10: Develop IEP / Process Complete, No IEP to Develop

  They will become rollup columns in the phase 2 seeds.
- **Elements affected.** S09, U10.

### D-010 · 2026-09-29 · decided: File S does not state that it requires B and C
- **Finding.** CLAUDE.md lists "R, S and V require B and C". The v19 manual states this
  for R and V (file descriptions) but **not for S**. The closest rule is S05's: "The
  Location ID reported should be the enrolled Location ID of the student at the time of
  the reported action." It is recorded as an implied S → C rule (IR013,
  `enforcement = implied`).
- **Question.** Should the warehouse enforce S → B and S → C anyway, as a data-quality
  check rather than a manual rule?
- **Elements affected.** S04, S05, S07.
- **Resolution (phase 3).** Enforced as warehouse check DQ005: rows are flagged, not rejected. See docs/silver-contract.md §7.

### D-011 · 2026-09-29 · decided: T05 rule typo
- **Decision.** T05's business rule says "The ID reported in Element T03 must be included
  in the Location File A." It clearly means T05. The integrity rule is written against T05,
  with a note.
- **Elements affected.** T05.

### D-012 · 2026-09-29 · decided: how integrity rules are captured
- **Decision.** `catalog/integrity_rules.csv` holds both kinds of rule:
  - **Cross-file:** record existence, Location ID resolution, value and date consistency.
  - **Intra-file:** the ones that shape the design, such as spell non-overlap, the L
    code 10 exclusivity, R incident repetition, E uniqueness and H 9999.

  Each rule carries a verbatim `rule_text` quote, which the build checks. `enforcement` is
  one of `reject`, `required`, `expected` or `implied`, based on the manual's wording.
- **Elements affected.** See the CSV.

### D-013 · 2026-09-29 · decided: body vs summary type conflicts
- **Decision.** When a type is given in both places, `data_type` and `size` come from the
  element definition (the body). The Data Element Summary is used only to fill a size
  the body leaves out:
  - B41 `char(4)`
  - R27 `varchar(2)`
  - U13 `varchar(2)`

  J23 has no size anywhere; it is not in the summary at all.
- **Disagreements between body and summary:**

  | Element | Body | Summary | Note |
  |---|---|---|---|
  | K06 | int | numeric | |
  | L05 | varchar(3) | char(1) | The example `H01` fits the body |
  | Q16 | varchar(4) | char(4) | |
  | R13 | int | numeric(4,1) | The example is `2 or 105`; the sibling R14 is numeric(4,1) |
  | T10 | char(10) | varchar(10) | |
  | V05 | varchar(4) | varchar(50) | |
- **Proposal for silver.** Where they disagree, type to the wider of the two:
  - R13 → `DECIMAL(4,1)`
  - L05, Q16, T10 → `STRING`
  - V05 → `STRING`, because other files' Location IDs are varchar(4)

  Bronze is all STRING, so nothing is lost at ingest.
- **Elements affected.** B41, J23, K06, L05, Q16, R13, R27, T10, U13, V05.

---

## Phase 2: reference data

Build: `tools/extract_code_sets.py` writes `seeds/ref/*.csv`, `catalog/code_sets.csv` and
`catalog/i10_qualification_map.csv`. Tests are in `tests/test_code_sets.py`.
- **Resolution (phase 3).**
  - R13 → DECIMAL(4,1).
  - K06, L05, Q16 and T10 are codes, so they are STRING under D-028.
  - V05 → STRING.
  - J20 numeric(4) → INT.

### D-014 · 2026-09-29 · decided: seed layout and year convention
- **Decision.** Every seed has this column layout:
  - `code`, `description`
  - rollup and attribute columns
  - `source_order`
  - `valid_from_year`, `valid_to_year`

  Years are the 4-digit ending year of the school year (2026-27 → 2027), the same
  convention as A01. A blank year means open or not stated by the source. Years are never
  guessed: they are filled only where a source states them (archive sheets, "New in v19",
  era tables, or "prior to" wording). Seeds carry `status` (active/archived/closed) where
  the source provides one.
- **Elements affected.** All coded elements.

### D-015 · 2026-09-29 · decided (confirmed): a fourth code-set status, `retired`
- **Decision.** `catalog/code_sets.csv` uses `extracted` / `external` / `partial` as CLAUDE.md
  specifies, plus `retired` for appendices that hold no list because collection stopped:
  - L: Seal of Biliteracy test results, stopped 2024-25.
  - AI: district-issued devices, stopped 2023-24.
  - T: intentionally left blank.
- **Reason.** Registering these as `external` would imply that a list exists somewhere.
- **Elements affected.** I10 (AI). The Appendix L header says "Used by Element I09",
  which is probably a source typo for I10.

### D-016 · 2026-09-29 · decided: archived codes in the xlsx appendices
- **Finding.** The active sheets of F, K and R still list removed codes, formatted in
  **strikethrough**:
  - F: 13 codes
  - K: 44 codes, with change status "Archived"
  - R: 165 codes

  Every struck F and K code, and 163 of the struck R codes, also appears on the workbook's
  Archive sheet. The other two struck R codes have no Archive entry.
- **Decision.** Strikethrough ⇒ `status = archived`, and `valid_to_year` comes from the
  Archive sheet:
  - F "Last Active School Year" = last valid year
  - R "Last Valid School Year" = last valid year
  - K "Archived School Year" Y ⇒ last valid year Y − 1, because the code is struck on
    the 2026-27 active list

  Codes that appear only on the Archive sheet are included as archived.
- **R code 23 was reused.** It was "Atlantic Education / Everett SD" until 2017-18 and is
  now Chimacum Open Doors. It gets two rows: archived to 2018, then active.
- **Elements affected.** I06, I10, B17, B18, B43, D15.

### D-017 · 2026-09-29 · decided (mostly resolved): code sets that are external to the supplied sources
- **Finding.** These are separate files on the OSPI CEDARS page, or live in EDS, and none
  is in `sources/`. They are registered as `external`, with no seed and no invented values:

  | Appendix | Code set | Used by |
  |---|---|---|
  | A | county_district | the *02 elements, B03 |
  | EDS | school | A05, H26 |
  | S | CIP | D10, H17 |
  | V | state course | D08, H15, T11 |
  | AA | online provider | E10, T13 |
  | AB | online program | E11, T14 |
  | AK | industry certification | D17, E15, H31 |

  Appendix H (AVID) is a pointer only: AVID courses use state course code WA0005.
- **Resolution (2026-09-29).** The user supplied the 2026-27 workbooks for S, V, AA/AB and
  AK. They are now extracted (see D-026). Still external:
  - `county_district` (Appendix A)
  - `school` (EDS)
  - `avid_school` (H, a pointer only)

  An EDS directory extract would close these. Until then, dim_district and dim_school get
  their names from File A (A03, A06).

### D-018 · 2026-09-29 · decided: Appendix U staff-type patterns expanded to concrete codes
- **Decision.** Appendix U publishes patterns such as `21x` and `91y` and defines the
  suffixes: x = 0, 1 or 2; y = 0 or 3. Each suffix has a stated meaning (base contract,
  supplemental responsibility, and so on).
- **How the seed stores it.** It has one row per concrete code, 59 rows in total. It keeps
  the published pattern (`staff_type_group`), the `suffix` and the `suffix_description`.
  F04 data carries the concrete codes.
- **Elements affected.** F04.

### D-019 · 2026-09-29 · decided: Appendix O content areas split by era
- **Decision.** Appendix O publishes two tables:
  - "2015-16 and later": only 123 and ZZZ.
  - "2014-15 and earlier": codes 1–122.

  Codes 1–122 get `valid_to_year = 2015`. This confirms C-008: D06 and T09 accept only
  123 and ZZZ; H14 needs the full list for historical courses.
- **Elements affected.** D06, H14, T09.

### D-020 · 2026-09-29 · decided: J21 placement status is keyed by J18 placement test
- **Decision.** Appendix N is a matrix of placement test (11 rows) × status 0–6. The
  meaning of a J21 status depends on J18. The seed `el_placement_status` has the composite
  key (`placement_test_code`, `code`).
- **How it was built.**
  - The matrix was transcribed by hand because the PDF's header text is rotated. The
    build checks every status word against the page text.
  - Test rows are mapped to J18 codes by name (LASO = 1 … WIDA Alt Screener = 11); the
    test checks that they match J18's list.
- **Elements affected.** J18, J21.

### D-021 · 2026-09-29 · decided: Appendix AC code collision
- **Finding.** Code 63 is published twice:
  - active: Cinnamon Hills Youth Crisis Center
  - Closed Agency table: Family House Academy

  Separately, "New Haven Residential Treatment Center, Spanish Fork Campus" is active as
  114 and closed as 41. That one is not a collision, but it's worth knowing.
- **What was done.** Both code-63 rows are kept, distinguished by `status`.
- **Resolution (delegated to Claude).** K15 = 63 resolves to the **active** agency
  (Cinnamon Hills Youth Crisis Center). The closed row stays in the seed with
  `status = closed`, for history only. When loading ref_code, the key is (code_set, code,
  status); gold lookups use the active row.
- **Elements affected.** K15.

### D-022 · 2026-09-29 · decided: F code 67 Transitional Kindergarten is archived but the manual still uses it
- **Finding.** Appendix F archives 67 (last active 2023-24; struck through). However, the
  v19 manual's V06 business rule still says "Students participating in Transitional
  Kindergarten (Element I06 – Attribute or Program Code is 67-Transitional Kindergarten)
  can be screened…".
- **Resolution (delegated to Claude).** Appendix F governs code validity, so 67 is
  archived with `valid_to_year = 2024`. The V06 reference is treated as stale; the same rule
  says TK students "should not be reported to CEDARS" in File V anyway. Any I06 = 67 in
  2024-25 or later fails the ref check in silver as a data-quality exception, not a load
  error. TK enrollment is still available from grade level TK (Appendix E).
- **Elements affected.** I06, V06.

### D-023 · 2026-09-29 · decided: I06 → I10 code-set map (follow-up to D-008)
- **Decision.** I10 is resolved through `catalog/i10_qualification_map.csv`, which names the
  code set that governs I10 for each I06 program:
  - **9 rows are backed by quotes** from Appendix F reporting guidance, and the build
    checks each quote: 36 → disability; 40 → reengagement; 41, 42 and 81–84 → language;
    80 → sensory disability.
  - **6 rows are name matches only:** 19 → FRL, 30 → GRADS, 32–35 → Gifted, 69 → Career
    Launch. They are flagged `evidence_type = name_match`.
- **Resolution (delegated to Claude).**
  - The six name matches are accepted.
  - Code 60 (GRADS parenting-teen preschool, which serves the teen's child) is **not**
    mapped to the GRADS list, whose values describe the teen (pregnant, father-to-be,
    parenting). For I06 = 60, I10 is kept as reported and not validated against a list.
  - Appendix AI is retired, so no program maps to it. The related I06 codes 70–72 are
    archived (last active 2023-24).
- **Elements affected.** I06, I10.

### D-024 · 2026-09-29 · decided: shared inline code sets
- **Decision.** Elements with the same inline list share one seed:
  - `course_designation`: D07, H13, T10
  - `ale_course_type`: E09, H27, T12
  - `course_level`: D16, T18
  - `letter_grade`: H10, T15
  - `safety_staff_involvement`: R24, S12
  - `yes_no`: C10, Q17, S10

  Where the lists differ, the seed holds the union, and a `valid_elements` column marks
  codes that apply only to some elements. Example: `ale_course_type` Y ("only applicable
  for school years prior to 2014-15") applies to H27 only, with `valid_to_year = 2014`.
  Likewise, Term SUM1 and SUM2 apply to H19 only.

  Inline lists that repeat an appendix are registered against that appendix instead:
  - R10 → Appendix D
  - J21 → Appendix N
  - Q06 → Appendix F
  - D06, T09 → Appendix O

  Tests assert that each pair matches.
- **Elements affected.** Those listed.

### D-025 · 2026-09-29 · decided: rollups and flags carried into seeds

| Seed | Rollup or flag carried |
|---|---|
| race (Z) | `aggregate`, `race_category` (federal) |
| ethnicity (Y) | `aggregate` |
| school_withdrawal (M) | `status_group`, `reporting_guidance` |
| frl_qualification (X) | `frl_type` |
| lre (W) | `age_group` (setting name is the description) |
| intervention (AH) | `intervention_group` |
| student_growth_assessment (J) | Q08/Q10 applicability plus a per-program (LAP/WRC) applicability matrix |
| late_evaluation_reason (AF), late_part_c_transition_reason (AG) | `is_allowable_exception`, from the footnote marker |
| restraint_isolation_type (S09), initial_eval_outcome (U10) | `value_group` |
| letter_grade | `grade_points` |
| higher_ed_institution (AM) | `state` |
| career_launch_program (AJ) | `district`, `school` |

- **Also recorded.**
  - Appendix F's long reporting-guidance prose is **not** copied into the seed. Its
    `definition` is kept.
  - The Appendix Q workbook is v19.1 (June 2026); everything else is v19.0.
    `manual_version` stays 19.0.
  - `appendix_f_… (1).xlsx` is byte-identical to the other F file and is ignored.
- **Elements affected.** Those listed.

### D-026 · 2026-09-29 · decided: extracting the S, V, AA/AB and AK workbooks
- **Decision.** These workbooks are read with the same active/archive convention as F and R
  (D-016). Struck-through active rows are archived, and `valid_to_year` comes from "Last
  Active School Year". `valid_from_year` is set for codes the Summary of Changes marks New
  in v19.

  | Code set | Rows | Active | Archived | New in v19 |
  |---|---|---|---|---|
  | online_provider (AA) | 36 | 30 | 6 | — |
  | online_program (AB) | 396 | 316 | 80 | 1 |
  | industry_certification (AK) | 153 | 150 | 3 | — |
  | cip (S) | 490 | 286 | 204 | — |
  | state_course (V) | 3,629 | 1,851 | 1,778 | 8 |
  | course_subject_area (V's subject-area sheet) | 25 | — | — | — |
- **How codes were normalized.**
  - V integer codes are zero-padded to their cell display format `00000` (for example
    1001 → 01001). The overview says state course codes are five digits.
  - V `subject_area_code` is zero-padded to 2 digits, matching the Course Subject Areas
    sheet. The source has `8` for WA0053.
  - One V cell reads `03206 21063` (IB Design Technology, "New, Recoded from 03206"). It is
    loaded as code 21063 with `recoded_from = 03206`.
  - CIP codes are trimmed of stray spaces; all are 6 characters.
  - The AB archive lists some codes twice with the same name; one row is kept, with the
    latest year.
- **What is kept.**
  - Archived CIP and state course codes are kept, because H17 and H15 validate against the
    course's own school year (transcripts carry prior years).
  - CIP's multi-valued attributes (suggested state course codes, V-codes) are kept as
    published text.
- **Elements affected.** D08, D10, D17, E10, E11, H15, H17, H31, T11, T13, T14.

### D-027 · 2026-09-29 · decided: a code that is both active and archived
- **Finding.** Some codes appear unstruck on the active sheet *and* on the Archive sheet:
  - **Same name (7 V codes and 1 AB code):** 24567, 24617, 24717, 24817, 24912, 24913 and
    24917 (IB Language A: Language and Literature, archived 2020-21 as "no longer
    offered"), plus AB 195 (Meridian Online Learning, archived 2022-23).
  - **Different name, meaning the code was reused:** CIP 110102 (Java internet Academy to
    2008-09, now Artificial Intelligence) and V 04111 (WA State History & Government to
    2016-17, now CI U.S. History).
- **Decision.** For the same-name cases, the unstruck active listing wins: the code is
  active and the archive entry is dropped, because the workbook shows current validity. For
  reused codes, the earlier meaning is kept as a separate archived row with its own
  `valid_to_year`. Silver resolves a code against the row valid for the record's school
  year.
- **Elements affected.** D08, D10, E11, H15, H17, T11, T14.

---

## Phase 3: silver

Build: `tools/gen_ddl.py` (with `tools/silver_spec.py`) writes `sql/00_schemas.sql`,
`sql/bronze/*.sql`, `sql/ref/*.sql`, `sql/silver/*.sql` and `catalog/silver_columns.csv`.
The load rules are in `docs/silver-contract.md`. Tests are in `tests/test_ddl.py`.

### D-028 · 2026-09-29 · decided: coded elements are STRING in silver
- **Decision.** Every element with a registered code set is typed STRING, even when the
  manual says int.
- **Reason.** Several codes carry leading zeros:
  - Appendix B behavior `02`
  - SCED `01001`
  - CIP `010000`
  - AP code `1.01`

  An int would lose the zero and break the join to `ref.ref_code`. Silver normalizes each
  code to its code set's canonical form (silver contract §3).
- **Elements affected.** All coded elements, for example R08, R09, S09, D09, H16 and K06.

### D-029 · 2026-09-29 · decided: submission handling in silver
- **Decision.** Silver keeps the latest load per (school year, district, file,
  `_submission_type`), so `_submission_type` is part of every silver primary key. Bronze
  keeps every extract, and gold reads year-end final only.
- **Elements affected.** All.

### D-030 · 2026-09-29 · decided: PII in silver
- **Decision.** The silver entity tables keep their PII columns (B06–B09, B20, B36–B38,
  F06–F09), tagged `[PII]` in the column comment and listed in the `cedars.pii_columns`
  table property for column masks. Reported PII values are unpivoted into
  `silver.student_pii_history`, which is restricted as a whole table and feeds
  dim_student_pii survivorship. Non-PII attributes go to `student_attribute_history`.
- **Elements affected.** B06–B09, B20, B36–B38, F06–F09.

### D-031 · 2026-09-29 · decided: bronze and ref DDL generated alongside silver
- **Decision.** Bronze has one table per active file (19). Columns keep the manual's
  FieldName, all STRING, plus `_rescued_data` and the five load-metadata columns. The ref
  layer has `ref_code_set` and `ref_code` (one row per code version; `context_code` carries
  the J18 qualifier for J21, and rollups go in `attributes MAP<STRING,STRING>`).
- **Reason.** These are the contracts that silver reads from and validates against.
- **Elements affected.** All.

### D-032 · 2026-09-29 · decided: the B42/K27 parse fix and T10
- **Decision.**
  - The phase 1 range detector treated any valid-values line containing "to" as a range,
    which dropped the inline lists of B42 Credit Waiver ("…waive up to 2 credits") and K27
    Transition Consent. Fixed, and both are now registered (`credit_waiver`,
    `transition_consent`).
  - T10 is flagged multi-valued (see the D-005 addendum).
- **Elements affected.** B42, K27, T10.

---

## Phase 4: gold

Build: `tools/gold_spec.py` holds the star schema as data, and `tools/gen_ddl.py` writes:
- `sql/gold/*.sql` (87 tables)
- `sql/gold/views/*.sql`
- `sql/gold/special_members.sql`
- `sql/deploy_order.txt`
- `catalog/gold_columns.csv`
- `docs/erd.md`

Tests are in `tests/test_ddl.py`.

### D-033 · 2026-09-29 · decided: bridges for fact-level multi-valued elements use group dimensions
- **Decision.** For the multi-valued elements reported on fact rows (H13, T10, H31, H32, V10,
  R09, B43), the fact carries a group key: `dim_<x>_group`, one row per distinct sorted
  combination, with `-2` = none. The bridge links group → member with a `weighting_factor`.
  The course-level multi-valued elements (D07, D17, D20, D21) are bridged directly from
  `dim_course`, as the design specifies.
- **Reason.** A group table gives the fact a declarable foreign key (a bridge's group column
  is not unique) and a readable `group_codes` label for Tableau. The design's bridge names
  are kept (`bridge_other_behavior`, `bridge_course_*`, `bridge_student_race/ethnicity`,
  `bridge_staff_type`).
- **Elements affected.** B43, D07, D17, D20, D21, H13, H31, H32, R09, T10, V10.

### D-034 · 2026-09-29 · decided: dimensions beyond the design's named list
- **Code-set dimensions**, which the bus matrix calls for as fact-specific dimensions:
  - letter grade, ALE course type
  - online provider (AA), online program (AB)
  - teacher indicator, course designation, work-based learning
  - exclusionary action, restraint/isolation type, absence type
  - LRE (W), non-public agency (AC), growth assessment (J), state course (V)
- **Junk dimensions:**
  - transcript (H24, H27, 9999)
  - program participation (I09, I10 plus the governing code set)
  - EL (J06, J09, J18, J21)
  - SpEd (K09, K26, K27, school-inference method)
  - PreK outcomes (K16–K24)
  - LAP (Q09, Q15–Q17)
  - support screening (V07, V09)
  - initial evaluation (U09, U10, U12, U13)
- **Unchanged from the design:** the enrollment, discipline and restraint junk dimensions.
- **Elements affected.** Those listed.

### D-035 · 2026-09-29 · decided: key conventions
- **Decisions.**
  - `school_year_sk` is a BIGINT smart key equal to the ending year (2027).
  - `date_sk` is INT `YYYYMMDD`.
  - All other surrogate keys are BIGINT. -1 = unknown and -2 = not applicable, seeded by
    `sql/gold/special_members.sql` (idempotent).
  - The `dim_school` special member for school code 9999 (out-of-district, File H) is
    `school_sk = -3`.
  - `dim_date` assigns each date to the September–August school year (the H18 rule).
- **Constraints.** Primary and foreign keys are declared as Unity Catalog informational
  constraints (not enforced). `sql/deploy_order.txt` orders the files so that FK targets
  are created first. The one cycle, `dim_date` ↔ `dim_school_year`, is broken by creating
  `dim_school_year` first.
- **Elements affected.** All.

### D-036 · 2026-09-29 · decided: fact details not spelled out in the design
- **fact_transcript_course.** PK = student × course school year (H30) × term (`''` for
  transfer credits) × school (H26) × course, which is the design grain. It holds current
  versions only. `school_year_sk` is the reporting year of the surviving version, and
  `course_school_year_sk` is a second role of `dim_school_year`.
- **fact_student_section.** Factless in v19 (C-001). The `letter_grade_sk` (−2),
  `credits_attempted` and `credits_earned` columns are backload seams.
- **fact_sped_program.** `school_sk` is attached from the inferred school (C-005), not part
  of the PK.
- **fact_el_program.** J17 program designation maps to a `dim_program` member
  (family `el_program`).
- **fact_student_school_year.**
  - `federal_race_ethnicity` and `ospi_race_ethnicity` follow the Appendix Y/Z narrative.
  - `is_graduate` and `is_dropout` come from the Appendix M `status_group` of any C09 in
    the year.
  - `age_as_of_sept_1` comes from B09.
  - Year credits are H11/H12 summed over current versions with H30 = the year.
- **fact_exclusionary_action.** PK = incident_key × student × action type × action date.
  The manual requires a unique R12 per repeated NA action, so this is unique.
- **dim_program.category.** Record type Attribute → `attribute`; School or District Program
  → `program`; code 19 (Free/Reduced Meals eligibility) → `eligibility`.
- **dim_student.** Also stores `birth_country_sk` and `primary_language_sk` (type 1), so BI
  can use the code dimensions directly.
- **Elements affected.** Those listed.

---

## Phases 5–6: mapping and validation

### D-037 · 2026-09-29 · decided: mapping conventions
- **Decision.**
  - `mapping/source_to_target.csv` is generated from the element IDs on every gold column
    (`tools/gold_spec.py`), so the DDL and the mapping cannot drift apart.
  - `target_table` is schema-qualified (`gold.` / `silver.`).
  - An element that feeds several gold columns (for example a code that is both a
    dimension attribute and a fact lookup) gets one row per target.
- **Silver-only targets.** Elements used only for resolution map to silver:
  - the District Student IDs (C03 … V03) → `silver.xref_student`
  - A04 → `silver.xref_location`
- **EXCLUDED and INACTIVE.** No active element is EXCLUDED. Every inactive element and
  File P is listed as `INACTIVE`. For those that keep a NULL seam column in gold (B31, D18,
  D19, E12–E14), the notes name the column.
- **Elements affected.** All.

### D-038 · 2026-09-29 · decided: validator scope
- **Decision.** `tools/validate.py` implements the six CLAUDE.md checks, plus two convention
  checks: `${catalog}` parameterization, and a COMMENT on every silver and gold column.
- **Stricter than the spec.**
  - A statement that sqlglot can only keep as a raw Command (its fallback for text it cannot
    parse) counts as a parse failure.
  - Foreign keys must reference the target's primary key with matching types.
- **Proof it works.** `tests/test_validate.py` breaks each input on purpose and asserts that
  the matching check catches it.
- **CI.** `.github/workflows/validate.yml` rebuilds everything from `sources/`, fails if a
  committed artifact is stale, then runs the validator and the tests. The build is
  deterministic (verified by rebuilding twice).
- **Elements affected.** None.

---

## Conflicts between v19 and `docs/dimensional-design.md`

### C-001 · 2026-09-29 · decided: File E grade, credit, certification and work-based-learning elements are inactive
- **Finding.** E12 Letter Grade, E13 Credits Attempted, E14 Credits Earned, E15 Industry
  Certifications Earned and E16 Work-Based Learning Activities are all inactive in v19.
  E15 and E16 were last updated in March 2025.
- **Design impact.** Design §3 gives fact_student_section the measures
  `credits_attempted (E13)` and `credits_earned (E14)`. The bus matrix gives it a letter
  grade, plus industry-certification and work-based-learning bridges. Design §2 says "E
  carries grades and credits for all PK–12 courses". In v19, none of this has a source.
- **Proposal.** In v19, fact_student_section becomes a factless enrollment-in-section fact
  (schedule only). Credits and grades come only from H (high school) and T. The
  course-level offerings stay on dim_course (D17, D20). Keep nullable columns for the
  E12–E14 measures as a seam for backloading prior years.
- **Elements affected.** E12, E13, E14, E15, E16.
- **Resolution (phase 3, proposal adopted).** Silver `student_schedule` carries no E12–E16 columns. In phase 4, fact_student_section is a factless schedule fact. It keeps nullable credits_attempted, credits_earned and letter grade columns as a backload seam, and v19 always loads them NULL.

### C-002 · 2026-09-29 · decided: B31 immigrant is inactive
- **Design impact.** dim_student_profile (§5.2) lists immigrant (B31). There is no v19
  source.
- **Proposal.** Drop the attribute for v19, or derive it from File I if Appendix F has an
  immigrant attribute code (to be checked in phase 2).
- **Elements affected.** B31.
- **Resolution (phase 3).** Dropped for v19. Appendix F has no immigrant attribute code (checked), so there is nothing to derive it from. dim_student_profile keeps a nullable `is_immigrant` column as a seam for backloading prior years.

### C-003 · 2026-09-29 · decided: D18/D19 sequence and sequence group are inactive
- **Design impact.** dim_course (§5.6) lists sequence and sequence group (D18, D19). There
  is no v19 source. T19 and T20 are also inactive.
- **Proposal.** Drop the attributes, or keep them as null seam columns.
- **Elements affected.** D18, D19, T19, T20.
- **Resolution (phase 3).** Not in silver. dim_course keeps nullable `sequence` and `sequence_group` columns as a backload seam.

### C-004 · 2026-09-29 · decided: S13/S14 are inactive
- **Design impact.** The restraint junk dimension (§5.9) lists S10 and S12–S14. S13 and S14
  are inactive (April 2023), so the junk dimension has only S10 and S12.
- **Elements affected.** S13, S14.
- **Resolution (phase 3).** The restraint junk dimension uses S10 and S12 only.

### C-005 · 2026-09-29 · decided: Location ID is missing from files B, F, K, L, M and U
- **Finding.** Active Location ID elements exist only in C, D, E, G, I, J, N, Q, R, S, T and
  V (plus A04). K05 and H05 are inactive. B, F, L, M and U never had one.
- **Design impact.**
  - §5.4 says "Every file except A and H references Location ID and must resolve through
    [xref_location]". That is not true for B, F, K, L, M and U.
  - More importantly, the bus matrix and §3 give fact_sped_program a **School** dimension
    and the grain "SSID × school × SpEd program start (K14)". File K has no active
    location element, although the file description says "one entry for each student
    per enrollment into the program … per location".
- **Question.** For fact_sped_program, which should it be?
  - **(a)** school_sk = -2 (not applicable), grain SSID × district × K14.
  - **(b)** Infer the school from the File C enrollment that covers K14 (primary school,
    C10 = Y).
  - **(c)** Something else.
- **Elements affected.** K05, K14, and the Location ID elements of B, F, K, L, M and U.
- **Resolution (phase 3).** Option **(b)**. Silver `special_education_program` derives `inferred_school_code` (plus the method used) from the File C enrollment that covers K14, preferring C10 = Y. When nothing can be inferred, DQ007 is raised and gold uses -1 unknown. The fact grain stays SSID × district × K14; the school dimension is attached, not part of the grain. Files B, F, L, M and U have no school, by design.

### C-006 · 2026-09-29 · decided: File H key and nullable grain column
- **Finding.** The Data Element Summary marks only H01, H02 and H04 as key columns for
  File H, which is not unique. The design's grain is SSID × H30 × H19 × H26 × H07. H19
  Term is NULL for transfer credits: "Conditional. This is not required for transfer
  credits."
- **Proposal.** Keep the design grain. In the dedupe key, treat a NULL H19 as an empty
  string. Log the collision rate in silver.
- **Elements affected.** H01, H02, H04, H07, H19, H26, H30.
- **Resolution (phase 3).** Silver `student_grade_history` is keyed on school_year, district, SSID, H30, `term_key` (= coalesce(H19, '')), H26 and H07. `is_current_version` implements the design's "latest version wins" rule. A cross-district tie in the same year stays open (design open question 1) and raises DQ008.

### C-007 · 2026-09-29 · decided: Q09 Amount of Academic Growth is a code, not a number
- **Finding.** The Q09 values are:
  - -1 Negative Growth
  - 0–20 months
  - 21 More than 20 months
  - 22–27 N/A reasons (movement to Title I or SpEd, no pre-test, and so on)
- **Design impact.** §3 treats `academic_growth (Q09)` as a measure.
- **Proposal.** Store the Q09 code as a dimension attribute (a growth-category junk or code
  dimension). Add a nullable numeric `growth_months` measure, filled only for codes
  0–20.
- **Elements affected.** Q09.
- **Resolution (phase 3).** Silver carries `academic_growth_code` (STRING, code set `academic_growth`) and derives `growth_months` (0–20, otherwise NULL).

### C-008 · 2026-09-29 · decided: D06 content area is not Appendix O
- **Finding.** D06 (and T09) accept only `123` (block class) and `ZZZ` (non-instructional),
  or NULL. Only H14 references Appendix O Content Area Codes.
- **Design impact.** §5.6 has "content area (D06 → Appendix O)".
- **Proposal.** Model D06 as a small inline code set on dim_course. Use Appendix O only
  for H-inferred and T-inferred members through H14 and T09.
- **Elements affected.** D06, H14, T09.
- **Resolution.** Confirmed by D-019. D06 and T09 use the current rows of `content_area` (123 and ZZZ); H14 uses the full list with its validity years.

### C-009 · 2026-09-29 · decided: discipline and restraint keys in the Data Element Summary
- **Finding.**
  - The File R summary key is R01, R02, R04, R05, R06, R07, R11 and R12. It includes
    Location ID but not R03.
  - The File S key is S01, S02, S04, S05, S06, S07 and S09.
  - The manual says only "This ID serves to uniquely identify each restrained or
    isolated action record" for S06. It says nothing about incident-ID uniqueness scope
    for R06.
- **Design impact.** This is input to design open question 4 (district vs school scope of
  R06 and S06). The manual doesn't settle it. Because the summary key includes the
  location, school scope is the safer default.
- **Elements affected.** R05, R06, S05, S06.

### C-010 · 2026-09-29 · decided: S09 has zero-padding ambiguity
- **Finding.** S09 is `char(2)` and its example is `04`, but its valid values are listed
  without zero padding (1–18).
- **Proposal.** Normalize to integers in silver.
- **Elements affected.** S09.

---

## Design open questions (design §7)

| # | Question | Status |
|---|---|---|
| 1 | Tie-break for File H duplicate keys across districts within one year | **OPEN.** Both rows stay `is_current_version`, and DQ008 is raised (C-006). Needs a business rule, for example "prefer the district where the student was enrolled at the course's term end". |
| 2 | Source of an instructional-day calendar for attendance rates | **OPEN.** Enrolled days are approximated from C12 plus full-day absences, bounded by A07/A08 (design §6). |
| 3 | Which appendices are external lists | **Resolved (D-017, D-026).** S, V, AA, AB and AK were supplied and extracted. Only A (districts) and EDS schools remain external. |
| 4 | Uniqueness scope of R06 and S06 | **Decided.** District scope, per the design (`incident_key` / `action_key` = district + ID). DQ006 flags any R06 reused across schools, so the choice can be revisited with data (C-009). |
