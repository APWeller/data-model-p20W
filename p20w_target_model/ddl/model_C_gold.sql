-- Gold-layer Delta DDL for model C (generated). Types marked inferred in the lineage file should be
-- confirmed during silver profiling.

CREATE SCHEMA IF NOT EXISTS p20w_gold_conformed.conformed;
CREATE SCHEMA IF NOT EXISTS p20w_gold_conformed.fact;
CREATE SCHEMA IF NOT EXISTS p20w_gold_conformed.identity;
CREATE SCHEMA IF NOT EXISTS p20w_gold_conformed.ref;

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ACADEMIC_PERIOD (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  academic_period_id BIGINT COMMENT 'Derived',
  period_type STRING COMMENT 'SCHOOL_YEAR / TERM / QUARTER / AWARD_YEAR / PROGRAM_YEAR / PESB_YEAR / CALENDAR_QUARTER / CALENDAR_MONTH / REGISTRATION_SPELL',
  school_year_end SMALLINT COMMENT 'Ending year of the containing school/academic year',
  term_code STRING COMMENT 'SUMMER/FALL/WINTER/SPRING (null for annual)',
  calendar_year SMALLINT COMMENT 'Derived',
  calendar_quarter SMALLINT COMMENT 'Derived',
  period_begin_date DATE COMMENT 'Nominal statewide begin date',
  period_end_date DATE COMMENT 'Nominal statewide end date',
  parent_academic_period_id BIGINT COMMENT 'Term -> school year roll-up'
)
USING DELTA
CLUSTER BY (academic_period_id)
COMMENT 'Conformed periods across sectors | Grain: One row per conformed period (school year, term/quarter, award year, program year, calendar quarter, month, registration spell)'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 1 (static calendar)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ACADEMIC_PERIOD_XWALK (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  academic_period_id BIGINT COMMENT 'Derived',
  period_code_type STRING COMMENT 'Code type',
  source_period_code STRING COMMENT 'src rows 82,112,113,121,127,152,153,156,222,325,326,370...; ApplicationAcademicYear, AwardYear, LEGACY_QUARTER, LEGACY_YEAR, LEGACY_YRQ, ProgramYear, QUARTER, Quarter, SCHOOL_YEAR, STRM, School Year, SchoolYear, SchoolYearCode, SchoolYearID'
)
USING DELTA
CLUSTER BY (academic_period_id)
COMMENT 'Source period codes (YRQ, STRM, YYYYQ, SchoolYearId) -> academic_period_id | Grain: One row per source system x period code type x source period code'
TBLPROPERTIES ('p20w.table_type' = 'PERIOD_XWALK', 'p20w.scd' = 'Type 1', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ACADEMIC_SESSION (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ps_institution_org_id BIGINT COMMENT 'src rows 369,2089; inst_code, institution',
  academic_period_id BIGINT COMMENT 'src rows 370,372,1340,2084,2091; SchoolYear, academic_year, inst_enroll_term, inst_enroll_year, term',
  source_inst_enroll_year STRING COMMENT 'src rows 370; inst_enroll_year',
  summer_lead STRING COMMENT 'src rows 371; summer_lead',
  source_inst_enroll_term STRING COMMENT 'src rows 372; inst_enroll_term',
  ps_campus_org_id BIGINT COMMENT 'src rows 373,2086; campus, course_campus',
  campus_enroll_term_sys STRING COMMENT 'src rows 374; campus_enroll_term_sys',
  session_begin_date STRING COMMENT 'src rows 375,2085; begin_date, campus_enroll_term_start',
  session_end_date STRING COMMENT 'src rows 376,2088; campus_enroll_term_end, end_date',
  census_date STRING COMMENT 'src rows 377,2087; campus_enroll_census, census_date',
  source_school_year STRING COMMENT 'src rows 1340; SchoolYear',
  lea_org_id BIGINT COMMENT 'src rows 1341,1342; DistrictCode, DistrictOrganizationId',
  school_org_id BIGINT COMMENT 'src rows 1344,1345,1347; LocationID, SchoolCode, SchoolOrganizationId',
  first_instruction_date DATE COMMENT 'src rows 1348; InitialSchoolStartDate',
  last_instruction_date DATE COMMENT 'src rows 1349; LastSchoolEndDate',
  source_submit_date DATE COMMENT 'src rows 1350; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1351; ExtractDate',
  source_academic_year STRING COMMENT 'src rows 2084; academic_year',
  source_record_number STRING COMMENT 'src rows 2090; record_number',
  source_term STRING COMMENT 'src rows 2091; term',
  term_system STRING COMMENT 'src rows 2092; term_system'
)
USING DELTA
CLUSTER BY (academic_period_id)
COMMENT 'Org-specific session/term calendar | Grain: One row per organization (institution/campus/school) x academic period'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 1 (corrections overwrite)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ASSESSMENT_INSTRUMENT (
  assessment_instrument_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  assess_code STRING COMMENT 'src rows 437; assess_code',
  test_code STRING COMMENT 'src rows 438; test_code',
  assess_name STRING COMMENT 'src rows 439; assess_name',
  assessment_short_name STRING COMMENT 'src rows 873,892,894; AssessmentName, TestType',
  assessment_academic_subject STRING COMMENT 'src rows 880; SubjectName'
)
USING DELTA
COMMENT 'Assessment definitions referenced by fact.ASSESSMENT | Grain: One row per assessment instrument x subject/domain x version'
TBLPROPERTIES ('p20w.table_type' = 'DEFINITION', 'p20w.scd' = 'Type 2 (instrument metadata versions)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.COURSE (
  course_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  academic_period_id BIGINT COMMENT 'src rows 955; SchoolYear',
  lea_org_id BIGINT COMMENT 'src rows 956; DistrictCode',
  school_org_id BIGINT COMMENT 'src rows 958,960; LocationID, SchoolCode',
  course_identifier STRING COMMENT 'src rows 961,2029,2209; COURSE_NUM, CourseID, course',
  course_title STRING COMMENT 'src rows 962,2214,2217; COURSE_TITLE, CourseTitle'
)
USING DELTA
CLUSTER BY (academic_period_id)
COMMENT 'Course catalog level (coarser than section) | Grain: One row per offering organization x period x course identifier'
TBLPROPERTIES ('p20w.table_type' = 'DEFINITION', 'p20w.scd' = 'Periodic definition (period in key); corrections Type 1', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.COURSE_K12_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year STRING COMMENT 'src rows 955; SchoolYear',
  content_area_code STRING COMMENT 'src rows 963; ContentAreaCode',
  course_designation_code STRING COMMENT 'src rows 965; CourseDesignationCode',
  state_course_code STRING COMMENT 'src rows 966; StateCourseCode',
  advanced_placement_course_code STRING COMMENT 'src rows 968; APIBCourseCode',
  classification_of_instructional_program_code STRING COMMENT 'src rows 970; CTECIPCode',
  career_cluster_code STRING COMMENT 'src rows 972; CTEClusterID',
  cte_cluster_name STRING COMMENT 'src rows 973; CTEClusterName',
  cte_pathway_id STRING COMMENT 'src rows 974; CTEPathwayID',
  cte_pathway_name STRING COMMENT 'src rows 975; CTEPathwayName',
  is_direct_transcription_available BOOLEAN COMMENT 'src rows 976; IsDirectTranscriptionAvailable',
  source_submit_date DATE COMMENT 'src rows 978; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 979; ExtractDate',
  cte_course_equivalency_identity_code STRING COMMENT 'src rows 980; CTECourseEquivalencyIdentityCode',
  cte_equivalency_code STRING COMMENT 'src rows 983; CTEEquivalencyCode',
  dual_language_instruction_type_code STRING COMMENT 'src rows 986; DualLanguageInstructionTypeCode',
  dual_language_instruction_language_c STRING COMMENT 'src rows 989; DualLanguageInstructionLanguageC',
  course_level_characteristic_code STRING COMMENT 'src rows 991; CourseLevelCode',
  industry_certification_offered STRING COMMENT 'src rows 993; IndustryCertificationOffered',
  sequence_code STRING COMMENT 'src rows 994; SequenceCode',
  sequence_group_code STRING COMMENT 'src rows 996; SequenceGroupCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.COURSE_PS_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  course_department_name STRING COMMENT 'src rows 2235,2236; DEPT_DIV',
  course_id STRING COMMENT 'src rows 2207; COURSE_ID',
  course_num STRING COMMENT 'src rows 2208; COURSE_NUM',
  course_num_prefix STRING COMMENT 'src rows 2210; COURSE_NUM_PREFIX',
  course_num_suffix STRING COMMENT 'src rows 2212; COURSE_NUM_SUFFIX'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.COURSE_SECTION (
  course_section_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  course_section_title STRING COMMENT 'src rows 120; ClassName',
  academic_period_id BIGINT COMMENT 'src rows 121,2164,2165,2251,2433; QUARTER, STRM, SchoolYearId, YEAR, YRQ',
  el_site_relationship_org_id BIGINT COMMENT 'src rows 122; OrganizationRelationshipId',
  session_begin_date STRING COMMENT 'src rows 1541,2441; STRT_DATE, TermStartDate',
  session_end_date STRING COMMENT 'src rows 1542,2264; END_DATE, TermEndDate',
  course_section_identifier STRING COMMENT 'src rows 1543,1603,2040,2371; ITEM, SectionID, section',
  course_id BIGINT COMMENT 'src rows 1544,1604; CourseID',
  ps_institution_org_id BIGINT COMMENT 'src rows 2180,2357; COLLEGE, INSTITUTION',
  doc_site_org_id BIGINT COMMENT 'src rows 2198; DOC_SITE'
)
USING DELTA
CLUSTER BY (academic_period_id)
COMMENT 'Conformed course section offering | Grain: One row per offering organization x period x course x section'
TBLPROPERTIES ('p20w.table_type' = 'DEFINITION', 'p20w.scd' = 'Periodic definition (period in key); corrections Type 1', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.COURSE_SECTION_EL_ELMS_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year_id STRING COMMENT 'src rows 121; SchoolYearId',
  total_classroom_days DECIMAL(12,3) COMMENT 'src rows 123; TotalClassroomDays',
  language_of_instruction STRING COMMENT 'src rows 141; LanguageOfInstruction'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.COURSE_SECTION_EL_FUNDING_MODEL (
  course_section_el_funding_model_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  class_schedule_funding_model_id STRING COMMENT 'src rows 128; ClassScheduleFundingModelId',
  funding_model_type_id STRING COMMENT 'src rows 129; FundingModelTypeId'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.COURSE_SECTION_EL_MEETING_PATTERN (
  course_section_el_meeting_pattern_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  schedule_recurrence_type_id STRING COMMENT 'src rows 133; ScheduleRecurrenceTypeId',
  week_number DECIMAL(12,3) COMMENT 'src rows 134; WeekNumber',
  interval DECIMAL(12,3) COMMENT 'src rows 135; Interval',
  class_schedule_recurrence_id STRING COMMENT 'src rows 136; ClassScheduleRecurrenceId',
  day_of_week STRING COMMENT 'src rows 137; DayOfWeek',
  class_beginning_time STRING COMMENT 'src rows 138; StartTime',
  class_ending_time STRING COMMENT 'src rows 139; EndTime',
  day_schedule_id STRING COMMENT 'src rows 140; DayScheduleId'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.COURSE_SECTION_EL_STAFF_POSITION (
  course_section_el_staff_position_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  class_schedule_position_id STRING COMMENT 'src rows 130; ClassSchedulePositionId',
  staff_role_type_id STRING COMMENT 'src rows 131; StaffRoleTypeId',
  is_present_for_all_hours BOOLEAN COMMENT 'src rows 132; IsPresentForAllHours'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.COURSE_SECTION_K12_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  term STRING COMMENT 'src rows 1540; Term',
  course_title STRING COMMENT 'src rows 1545,1605; CourseTitle',
  state_course_code STRING COMMENT 'src rows 1546,1608; StateCourseCode',
  content_area_code STRING COMMENT 'src rows 1548,1610; ContentAreaCode',
  advanced_placement_course_code STRING COMMENT 'src rows 1550,1612; APIBCourseCode',
  classification_of_instructional_program_code STRING COMMENT 'src rows 1552,1614; CTECIPCode',
  career_cluster_code STRING COMMENT 'src rows 1554,1616; CTEClusterID',
  cte_cluster_name STRING COMMENT 'src rows 1555,1617; CTEClusterName',
  cte_pathway_id STRING COMMENT 'src rows 1556,1618; CTEPathwayID',
  cte_pathway_name STRING COMMENT 'src rows 1557,1619; CTEPathwayName',
  full_course_designation_code STRING COMMENT 'src rows 1558,1620; FullCourseDesignationCode',
  tech_prep_flag BOOLEAN COMMENT 'src rows 1559,1621; TechPrepFlag',
  international_baccalaureate_flag BOOLEAN COMMENT 'src rows 1560,1622; InternationalBaccalaureateFlag',
  collegeatthe_high_school_flag BOOLEAN COMMENT 'src rows 1561,1623; CollegeattheHighSchoolFlag',
  honors_flag BOOLEAN COMMENT 'src rows 1562,1624; HonorsFlag',
  advanced_placement_flag BOOLEAN COMMENT 'src rows 1563,1625; AdvancedPlacementFlag',
  running_start_flag BOOLEAN COMMENT 'src rows 1564,1626; RunningStartFlag',
  college_academic_distribution_requi STRING COMMENT 'src rows 1565,1627; CollegeAcademicDistributionRequi',
  cambridge_program_flag BOOLEAN COMMENT 'src rows 1566,1628; CambridgeProgramFlag',
  online_flag BOOLEAN COMMENT 'src rows 1567,1629; OnlineFlag',
  local_competency_test_flag BOOLEAN COMMENT 'src rows 1568,1630; LocalCompetencyTestFlag',
  national_competency_test_flag BOOLEAN COMMENT 'src rows 1569,1631; NationalCompetencyTestFlag',
  quantitative_flag BOOLEAN COMMENT 'src rows 1570,1632; QuantitativeFlag',
  science_lab_flag BOOLEAN COMMENT 'src rows 1571,1633; ScienceLabFlag',
  non_instructional_time_flag BOOLEAN COMMENT 'src rows 1572,1634; NonInstructionalTimeFlag',
  district_or_local_dual_credit_pgm DECIMAL(12,3) COMMENT 'src rows 1582,1637; DistrictOrLocalDualCreditPgm',
  youth1418_reengagement_dual_credit DECIMAL(12,3) COMMENT 'src rows 1583,1638; Youth1418ReengagementDualCredit',
  locally_determined_course_locally_administered_assessment_flag BOOLEAN COMMENT 'src rows 1584; LocallyDeterminedCourseLocallyAdministeredAssessmentFlag',
  dual_language_instruction_type_code STRING COMMENT 'src rows 1586,1655; DualLanguageInstructionTypeCode',
  dual_language_instruction_language_code STRING COMMENT 'src rows 1589,1658; DualLanguageInstructionLanguageCode',
  local_transition_flag BOOLEAN COMMENT 'src rows 1591,1660; LocalTransitionFlag',
  cte_core_plus_flag BOOLEAN COMMENT 'src rows 1592,1661; CTECorePlusFlag',
  tribal_language_competency_test_flag BOOLEAN COMMENT 'src rows 1593,1672; TribalLanguageCompetencyTestFlag',
  district_term_code STRING COMMENT 'src rows 1602; Term',
  locally_determined_course_locally_ad STRING COMMENT 'src rows 1639; LocallyDeterminedCourseLocallyAd',
  sequence_code STRING COMMENT 'src rows 1663; SequenceCode',
  sequence_group_code STRING COMMENT 'src rows 1665; SequenceGroupCode',
  cte_core_plus_advanced_manufacturing_flag BOOLEAN COMMENT 'src rows 1668; CTECorePlusAdvancedManufacturingFlag',
  cte_core_plus_maritime_flag BOOLEAN COMMENT 'src rows 1669; CTECorePlusMaritimeFlag',
  cte_core_plus_aerospace_flag BOOLEAN COMMENT 'src rows 1670; CTECorePlusAerospaceFlag',
  cte_core_plus_construction_flag BOOLEAN COMMENT 'src rows 1671; CTECorePlusConstructionFlag'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.COURSE_SECTION_PS_SBCTC_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_quarter STRING COMMENT 'src rows 2164; QUARTER',
  source_year STRING COMMENT 'src rows 2165; YEAR',
  instit_int STRING COMMENT 'src rows 2168; INSTIT_INT',
  instit_int_cat STRING COMMENT 'src rows 2169; INSTIT_INT_CAT',
  instit_intent_recat STRING COMMENT 'src rows 2170,2294; INSTIT_INTENT_RECAT',
  classification_of_instructional_program_code STRING COMMENT 'src rows 2171,2286; CIP',
  cip_cluster STRING COMMENT 'src rows 2172; CIP_CLUSTER',
  cip_grp STRING COMMENT 'src rows 2173; CIP_GRP',
  bldg STRING COMMENT 'src rows 2186; BLDG',
  course_section_maximum_capacity STRING COMMENT 'src rows 2189; CLASS_CAP',
  clock_hr DECIMAL(12,3) COMMENT 'src rows 2190; CLOCK_HR',
  clock_hr_equiv DECIMAL(12,3) COMMENT 'src rows 2191; CLOCK_HR_EQUIV',
  clock_hr_indicator DECIMAL(12,3) COMMENT 'src rows 2194; CLOCK_HR_INDICATOR',
  cluster_itm STRING COMMENT 'src rows 2195; CLUSTER_ITM',
  distance_education_course_enrollment STRING COMMENT 'src rows 2196,2288,2308; DIST_ED, INSTRUCTION_MODE',
  doc STRING COMMENT 'src rows 2197; DOC',
  cont_seq STRING COMMENT 'src rows 2201; CONT_SEQ',
  contract_stu_enrollment STRING COMMENT 'src rows 2202; CONTRACT_STU_ENROLLMENT',
  contract_stu_ftes DECIMAL(12,3) COMMENT 'src rows 2203; CONTRACT_STU_FTES',
  credit_value DECIMAL(12,3) COMMENT 'src rows 2204,2205; COURSE_CREDITS',
  fund_source STRING COMMENT 'src rows 2215; FUND_SOURCE',
  fund_source_cat STRING COMMENT 'src rows 2216; FUND_SOURCE_CAT',
  credit_equiv DECIMAL(12,3) COMMENT 'src rows 2221; CREDIT_EQUIV',
  credit_equiv_src DECIMAL(12,3) COMMENT 'src rows 2222; CREDIT_EQUIV_SRC',
  day_code STRING COMMENT 'src rows 2231; DAY_CODE',
  day_title STRING COMMENT 'src rows 2232; DAY_TITLE',
  class_meeting_days DECIMAL(12,3) COMMENT 'src rows 2233; DAYS',
  source_yrq STRING COMMENT 'src rows 2251; YRQ',
  class_ending_time STRING COMMENT 'src rows 2265; END_TIME',
  enr_contract STRING COMMENT 'src rows 2267; ENR_CONTRACT',
  enr_state STRING COMMENT 'src rows 2269; ENR_STATE',
  enr_student STRING COMMENT 'src rows 2270; ENR_STUDENT',
  enr_total STRING COMMENT 'src rows 2271; ENR_TOTAL',
  enr_waiver DECIMAL(14,2) COMMENT 'src rows 2272; ENR_WAIVER',
  enrollment_count_method DECIMAL(12,3) COMMENT 'src rows 2273; ENROLLMENT_COUNT_METHOD',
  fte_students DECIMAL(12,3) COMMENT 'src rows 2300; FTE_STUDENTS',
  ftes_contract DECIMAL(12,3) COMMENT 'src rows 2301; FTES_CONTRACT',
  ftes_state DECIMAL(12,3) COMMENT 'src rows 2304; FTES_STATE',
  ftes_student DECIMAL(12,3) COMMENT 'src rows 2306; FTES_STUDENT',
  ftes_total DECIMAL(12,3) COMMENT 'src rows 2309; FTES_TOTAL',
  ftes_waiver DECIMAL(14,2) COMMENT 'src rows 2311; FTES_WAIVER',
  hegis STRING COMMENT 'src rows 2330; HEGIS',
  hegis_cluster STRING COMMENT 'src rows 2334; HEGIS_CLUSTER',
  pct_externally_funded DECIMAL(12,3) COMMENT 'src rows 2377; PCT_EXTERNALLY_FUNDED',
  record_code STRING COMMENT 'src rows 2391,2396; RECORD_CODE',
  record_key STRING COMMENT 'src rows 2401; RECORD_KEY',
  room STRING COMMENT 'src rows 2413; ROOM',
  course_section_identifier STRING COMMENT 'src rows 2416; SECTION',
  section_stat STRING COMMENT 'src rows 2417; SECTION_STAT',
  section_stat_one STRING COMMENT 'src rows 2418; SECTION_STAT_ONE',
  source_strm STRING COMMENT 'src rows 2433; STRM',
  class_beginning_time STRING COMMENT 'src rows 2442; STRT_TIME',
  ten_day_class STRING COMMENT 'src rows 2453; TEN_DAY_CLASS',
  ten_day_enr STRING COMMENT 'src rows 2454; TEN_DAY_ENR',
  time_loc STRING COMMENT 'src rows 2455; TIME_LOC',
  var_credit DECIMAL(12,3) COMMENT 'src rows 2463; VAR_CREDIT',
  waol STRING COMMENT 'src rows 2466,2467; WAOL',
  weekly_hr_clin STRING COMMENT 'src rows 2468; WEEKLY_HR_CLIN',
  weekly_hr_lab STRING COMMENT 'src rows 2469; WEEKLY_HR_LAB',
  weekly_hr_lec STRING COMMENT 'src rows 2470; WEEKLY_HR_LEC',
  weekly_hr_othr DECIMAL(12,3) COMMENT 'src rows 2471; WEEKLY_HR_OTHR',
  weekly_hr_sys STRING COMMENT 'src rows 2472; WEEKLY_HR_SYS',
  weekly_hr_tot STRING COMMENT 'src rows 2473; WEEKLY_HR_TOT',
  work_based_ind STRING COMMENT 'src rows 2475,2476; WORK_BASED_IND',
  cned_type STRING COMMENT 'src rows 2200; CNED_TYPE',
  basic_skill_cat STRING COMMENT 'src rows 2287; BASIC_SKILL_CAT',
  instit_intent_cat STRING COMMENT 'src rows 2293; INSTIT_INTENT_CAT'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.DIM_DATE (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  date_key INT COMMENT 'yyyymmdd',
  calendar_date DATE COMMENT 'Derived',
  school_year_end SMALLINT COMMENT 'Sept-Aug school year',
  state_fiscal_year SMALLINT COMMENT 'Jul-Jun',
  calendar_quarter SMALLINT COMMENT 'Derived'
)
USING DELTA
COMMENT 'Date dimension | Grain: One row per calendar date'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 0', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORGANIZATION (
  organization_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  org_id BIGINT COMMENT 'Durable organization key issued by organization mastering',
  organization_type STRING COMMENT 'Primary type: SEA, ESD, LEA, K12_SCHOOL, PS_INSTITUTION, PS_COLLEGE_DISTRICT, PS_CAMPUS_SITE, EL_PROVIDER, EMPLOYER, EMPLOYER_REPORTING_UNIT, APPRENTICESHIP_SPONSOR, SERVICE_PROVIDER, CREDENTIAL_ISSUER',
  operational_status STRING COMMENT 'Derived from lineage events and source status (open / closed / merged / split)',
  organization_name STRING COMMENT 'src rows 124,144,147,150,155,182,230,232,275,290,547,674...; ApplicationDistrictName, ApplicationSchoolName, ApprovedOnlineProgramName, ApprovedOnlineProviderName, CertificateRecommendingAgencyName, College_Name, Contractor, ContractorName, '
)
USING DELTA
COMMENT 'Single conformed organization core | Grain: One row per durable org_id per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2 (name, operational status, type); renames are attribute changes, NOT lineage events', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORGANIZATION_LINEAGE (
  organization_lineage_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  lineage_event_id BIGINT COMMENT 'SYSTEM',
  event_effective_period_code STRING COMMENT 'Source period code of the event (e.g. SBCTC YRQ A121)',
  allocation_share DECIMAL(5,4) COMMENT 'Share of predecessor attributed to this successor for aggregate re-attribution (splits); null = no allocation',
  fact_reattribution_rule STRING COMMENT 'AS_REPORTED_ONLY / ROLL_FORWARD_TO_SUCCESSOR / ROLL_BACK_TO_PREDECESSOR / ALLOCATE',
  steward_note STRING COMMENT 'Free-text steward rationale',
  predecessor_org_id BIGINT COMMENT 'src rows 670,671; Predecessor RUN, Predecessor UI Account Number',
  successor_org_id BIGINT COMMENT 'src rows 672,673; Successor RUN, Successor UI Account Number',
  event_type STRING COMMENT 'src rows 769,777,780; First Supplemental P/S Identifier, P/S Partial/Full Indicator, Second Supplemental P/S Identifier',
  event_effective_date STRING COMMENT 'src rows 770,771,772; P/S Transfer Day, P/S Transfer Month, P/S Transfer Year',
  multiple_successor_indicator STRING COMMENT 'src rows 773; Multiple Successors',
  multiple_predecessor_indicator STRING COMMENT 'src rows 774; Multiple Predecessors',
  evidence_source_code STRING COMMENT 'src rows 775,776; Predecessor Source, Successor Source Code',
  counterparty_org_id BIGINT COMMENT 'src rows 778,779,781,782; First Supplemental P/S Reporting Unit Number, First Supplemental P/S UI Account Number, Second Supplemental P/S Reporting Unit Number, Second Supplemental P/S UI Account Number'
)
USING DELTA
COMMENT 'Mergers, splits, closures, recodes, successions | Grain: One row per lineage event x predecessor x successor'
TBLPROPERTIES ('p20w.table_type' = 'ORG_LINEAGE', 'p20w.scd' = 'Append-only event log (events are facts about orgs, not attribute versions)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORGANIZATION_LINEAGE_CLOSURE (
  organization_lineage_closure_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  org_id BIGINT COMMENT 'Derived',
  related_org_id BIGINT COMMENT 'Derived',
  relationship_direction STRING COMMENT 'SUCCESSOR / PREDECESSOR',
  path_length INT COMMENT 'Derived',
  allocation_share_product DECIMAL(9,6) COMMENT 'Derived',
  is_terminal_successor BOOLEAN COMMENT 'Derived: related_org has no successor',
  lineage_group_id BIGINT COMMENT 'Derived: connected component id (e.g. all Pierce College orgs)'
)
USING DELTA
COMMENT 'Transitive closure used to roll historical facts to current successors | Grain: One row per org_id x ancestor/descendant org_id reachable through lineage events'
TBLPROPERTIES ('p20w.table_type' = 'ORG_LINEAGE', 'p20w.scd' = 'Rebuilt from ORGANIZATION_LINEAGE on each load (Type 1)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORGANIZATION_XWALK (
  organization_xwalk_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  org_id BIGINT COMMENT 'Durable org assigned by mastering',
  source_identifier_type STRING COMMENT 'Identifier type',
  effective_start_date DATE COMMENT 'First date this code maps to this org',
  effective_end_date DATE COMMENT 'Last date (code reuse after this date maps elsewhere)',
  assignment_basis STRING COMMENT 'SOURCE_MASTER / LINEAGE_EVENT / STEWARD_OVERRIDE',
  source_org_identifier STRING COMMENT 'src rows 96,97,106,122,125,142,145,148,151,154,163,168...; ApplicationDistrictCode, ApplicationESDNumber, ApplicationSchoolCode, ApprovedOnlinePGMResidentDistOrg, ApprovedOnlinePGMResidentDistOrgId, ApprovedOnlineProgramCode, ApprovedOnlin'
)
USING DELTA
COMMENT 'Source org identifiers -> durable org_id | Grain: One row per source system x identifier type x source identifier x effective period'
TBLPROPERTIES ('p20w.table_type' = 'ORG_XWALK', 'p20w.scd' = 'Effective-dated; handles code reuse (same code, different org in different periods)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_APPRENTICESHIP_SPONSOR (
  org_apprenticeship_sponsor_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  lni_program_id STRING COMMENT 'src rows 809; Program Id'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: none | Grain: One row per org_id per version (Apprenticeship Sponsor attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_CREDENTIAL_ISSUER (
  org_credential_issuer_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ospi_recommending_agency_code STRING COMMENT 'src rows 546; CertificateRecommendingAgencyCode',
  ospi_issue_source_code STRING COMMENT 'src rows 549,561; CertificateIssueSourceCode, EndorsementIssueSourceCode'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: none | Grain: One row per org_id per version (Credential Issuer attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_EL_PROVIDER (
  org_el_provider_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  site_address_city STRING COMMENT 'src rows 158; City',
  site_address_postal_code STRING COMMENT 'src rows 159; ZipCode',
  zip_extra STRING COMMENT 'src rows 160; ZipExtra',
  latitude DECIMAL(12,3) COMMENT 'src rows 161; Latitude',
  longitude DECIMAL(12,3) COMMENT 'src rows 162; Longitude',
  site_esd_org_id BIGINT COMMENT 'src rows 163; ESDId',
  legislative_district_id STRING COMMENT 'src rows 164; LegislativeDistrictId',
  school_district_id STRING COMMENT 'src rows 165; SchoolDistrictId',
  school_district_name STRING COMMENT 'src rows 166; SchoolDistrictName',
  county_district_code STRING COMMENT 'src rows 167; CountyDistrictCode',
  elms_organization_relationship_id STRING COMMENT 'src rows 122,151; OrganizationRelationshipId',
  elms_organization_id STRING COMMENT 'src rows 125,142,145,148,154,348,356; ContractorID, ELMS_Contractor_ID, SiteID, SiteOrganizationID, SubcontractorID',
  org_id BIGINT COMMENT 'src rows 125,168; ProviderNumber, SiteOrganizationID',
  el_provider_role_type_id STRING COMMENT 'src rows 126,143,146,149; ContractorTypeID, SiteOrganizationTypeID, SiteTypeID, SubcontractorTypeID',
  dcyf_licensed_provider_number STRING COMMENT 'src rows 168; ProviderNumber',
  provides_wrap_around_child_care STRING COMMENT 'src rows 169; ProvidesWrapAroundChildCare',
  is_licensed_child_care_facility BOOLEAN COMMENT 'src rows 170; IsLicensedChildCareFacility',
  is_operated_by_tribal_organization BOOLEAN COMMENT 'src rows 171; IsOperatedByTribalOrganization',
  site_type STRING COMMENT 'src rows 172; SiteType',
  hist_eceap_site_code STRING COMMENT 'src rows 231; SiteCodeAlpha',
  esit_organization_id STRING COMMENT 'src rows 240; ESITOrganizationId',
  ssps_provider_number STRING COMMENT 'src rows 274; providernumber',
  provider_type STRING COMMENT 'src rows 286; Provider_Type',
  eceap_contractor_code STRING COMMENT 'src rows 357; ECEAP_Contractor'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: via ORG_EL_PROVIDER_RELATIONSHIP (contractor -> subcontractor -> site, by school year) | Grain: One row per org_id per version (El Provider attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_EL_PROVIDER_RELATIONSHIP (
  org_el_provider_relationship_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  el_contractor_org_id BIGINT COMMENT 'src rows 142; ContractorID',
  el_subcontractor_org_id BIGINT COMMENT 'src rows 145; SubcontractorID',
  el_site_org_id BIGINT COMMENT 'src rows 148,154; SiteID',
  el_site_relationship_org_id BIGINT COMMENT 'src rows 151; OrganizationRelationshipId',
  academic_period_id BIGINT COMMENT 'src rows 152,156; SchoolYearId',
  source_school_year_id STRING COMMENT 'src rows 152,156; SchoolYearId',
  address_id STRING COMMENT 'src rows 157; AddressId'
)
USING DELTA
CLUSTER BY (academic_period_id)
COMMENT 'EL-specific hierarchy on the EL provider satellite | Grain: One row per school year x contractor x subcontractor x site'
TBLPROPERTIES ('p20w.table_type' = 'HIERARCHY', 'p20w.scd' = 'Effective by school year (Type 2 semantics)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_EMPLOYER (
  org_employer_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  esd_ui_account_number STRING COMMENT 'src rows 667,796; EmployerAccountNumber, UI Account number',
  ei_number STRING COMMENT 'src rows 669; EI Number',
  doing_business_as_name STRING COMMENT 'src rows 675; Trade Name/DBA',
  setup_date DATE COMMENT 'src rows 699,700,701; Setup Date - Day, Setup Date - Month, Setup Date - Year',
  initial_liability_date DATE COMMENT 'src rows 702,703,704; Initial Date of Liability - Day, Initial Date of Liability - Month, Initial Date of Liability - Year',
  end_liability_date DATE COMMENT 'src rows 705,706,707; End of Liability Date - Day, End of Liability Date - Month, End of Liability Date - year',
  reactivation_date DATE COMMENT 'src rows 708,709,710; Reactivation Date - Day, Reactivation Date - Month, Reactivation Date - Year',
  activity_status_code STRING COMMENT 'src rows 711; Activity Status Code',
  old_ownership_code STRING COMMENT 'src rows 716; Old Ownership Code',
  maximum_reporting_unit_number STRING COMMENT 'src rows 719; Maximum Reporting Unit Number',
  special_indicator_code STRING COMMENT 'src rows 723; Special Indicator Code',
  agent_code STRING COMMENT 'src rows 724; Agent Code',
  ownership_code STRING COMMENT 'src rows 728; Ownership Code',
  organization_type_code STRING COMMENT 'src rows 729; Organization Type Code',
  type_of_coverage_code STRING COMMENT 'src rows 743; Type of Coverage Code',
  ars_third_party_agent STRING COMMENT 'src rows 783; ARS Third Party Agent',
  fein STRING COMMENT 'src rows 802; FEIN'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: none | Grain: One row per org_id per version (Employer attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_EMPLOYER_REPORTING_UNIT (
  org_employer_reporting_unit_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  esd_run STRING COMMENT 'src rows 668; Reporting Unit Number (RUN)',
  ui_street_address_line_1 STRING COMMENT 'src rows 676; UI Street Address - Line 1',
  ui_streat_address_line_2 STRING COMMENT 'src rows 677; UI Streat Address - Line 2',
  ui_address_city STRING COMMENT 'src rows 678; UI Address - City',
  ui_address_state STRING COMMENT 'src rows 679; UI Address - State',
  ui_address_zip STRING COMMENT 'src rows 680; UI Address - ZIP',
  ui_address_zip_extension STRING COMMENT 'src rows 681; UI Address - ZIP extension',
  physical_location_street_address_line_1 STRING COMMENT 'src rows 682; Physical Location Street Address - Line 1',
  physical_location_street_address_line_2 STRING COMMENT 'src rows 683; Physical Location Street Address - Line 2',
  physical_location_address_city STRING COMMENT 'src rows 684; Physical Location Address - City',
  physical_location_address_state STRING COMMENT 'src rows 685; Physical Location Address - State',
  physical_location_address_zip STRING COMMENT 'src rows 686; Physical Location Address - ZIP',
  physical_location_address_zip_extension STRING COMMENT 'src rows 687; Physical Location Address - ZIP extension',
  mailing_other_address_moa_line_1 STRING COMMENT 'src rows 688; Mailing/Other Address (MOA) - Line 1',
  mailing_other_address_moa_line_2 STRING COMMENT 'src rows 689; Mailing/Other Address (MOA) - Line 2',
  mailing_other_address_moa_city STRING COMMENT 'src rows 690; Mailing/Other Address (MOA) - City',
  mailing_other_address_moa_state STRING COMMENT 'src rows 691; Mailing/Other Address (MOA) - State',
  mailing_other_address_moa_zip STRING COMMENT 'src rows 692; Mailing/Other Address (MOA) - ZIP',
  mailing_other_address_moa_zip_extension STRING COMMENT 'src rows 693; Mailing/Other Address (MOA) - ZIP extension',
  mailing_other_address_moa_type STRING COMMENT 'src rows 694; Mailing/Other Address (MOA) type',
  reporting_unit_description STRING COMMENT 'src rows 695; Reporting Unit Description',
  area_code STRING COMMENT 'src rows 696; Area Code',
  phone_prefix STRING COMMENT 'src rows 697; Phone Prefix',
  phone_suffix STRING COMMENT 'src rows 698; Phone Suffix',
  old_county_code STRING COMMENT 'src rows 715; Old County Code',
  old_township_code STRING COMMENT 'src rows 718; Old Township Code',
  old_naics_code STRING COMMENT 'src rows 721; Old NAICS code',
  sic_code STRING COMMENT 'src rows 725; SIC Code',
  nsta_mostly_blank STRING COMMENT 'src rows 726; NSTA - mostly blank',
  employment_naics_code STRING COMMENT 'src rows 727; NAICS code',
  county_code STRING COMMENT 'src rows 730; County Code',
  township_code STRING COMMENT 'src rows 731; Township Code',
  auxiliary_code STRING COMMENT 'src rows 732; Auxiliary Code',
  meei_code STRING COMMENT 'src rows 744; MEEI Code',
  ui_address_type_code STRING COMMENT 'src rows 752; UI Address Type Code',
  pla_changed_date DATE COMMENT 'src rows 753,754,755; Date PLA Day Changed, Date PLA Month Changed, Date PLA Year Changed',
  geocoding_software STRING COMMENT 'src rows 756; Geocoding Software',
  geocoding_source STRING COMMENT 'src rows 757; Geocoding Source',
  match_code STRING COMMENT 'src rows 758; Match Code',
  location_code STRING COMMENT 'src rows 759; Location Code',
  latitude DECIMAL(12,3) COMMENT 'src rows 760; Latitude',
  longitude DECIMAL(12,3) COMMENT 'src rows 761; Longitude',
  year_of_new_latitude_and_longitude DECIMAL(12,3) COMMENT 'src rows 762; Year of New Latitude and Longitude',
  quarter_of_new_latitude_and_longitude DECIMAL(12,3) COMMENT 'src rows 763; Quarter of New Latitude and Longitude',
  place_code STRING COMMENT 'src rows 764; Place Code',
  class_code STRING COMMENT 'src rows 765; Class Code',
  census_block STRING COMMENT 'src rows 766; Census Block',
  census_tract STRING COMMENT 'src rows 767; Census Tract',
  address_contact_source STRING COMMENT 'src rows 768; Address/Contact Source',
  telephone_extension STRING COMMENT 'src rows 784; Telephone Extension',
  es_202_contact_attention_line STRING COMMENT 'src rows 785; ES-202 Contact (Attention Line)',
  contact_title STRING COMMENT 'src rows 786; Contact Title',
  contact_e_mail_address STRING COMMENT 'src rows 787; Contact e-mail address',
  fax_area_code STRING COMMENT 'src rows 788; Fax Area Code',
  fax_phone_number STRING COMMENT 'src rows 789; Fax Phone Number',
  website_address STRING COMMENT 'src rows 790; Website Address'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: parent_employer_org_id (RUN -> UI account) | Grain: One row per org_id per version (Employer Reporting Unit attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_ESD (
  org_esd_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  elms_esd_id STRING COMMENT 'src rows 163; ESDId',
  ospi_esd_code STRING COMMENT 'src rows 1754,2647; ApplicationESDNumber, ESD_ID'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: none | Grain: One row per org_id per version (Esd attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_K12_SCHOOL (
  org_k12_school_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ospi_school_code STRING COMMENT 'src rows 461,570,864,885,944,958,1004,1050,1146,1202,1214,1281...; ApplicationSchoolCode, BLDG, BuildingCode, LastReportedSchCode, LastReportedSchoolCode, SCHOOL_ID, SchCode, SchoolCode, WaK_schoolcode, bldg_code',
  ospi_org_id BIGINT COMMENT 'src rows 622,940,1000,1311,1344,1763,2639; SchoolId, SchoolOrgID, SchoolOrganizationId, Serving School Id',
  district_sis_location_id STRING COMMENT 'src rows 941,960,1001,1052,1148,1216,1283,1347,1357,1417,1452,1533...; LocationID, LocationId',
  nces_school_id STRING COMMENT 'src rows 1681; NCESSCH',
  lowest_grade STRING COMMENT 'src rows 1684; LOWEST_GRADE',
  highest_grade STRING COMMENT 'src rows 1685; HIGHEST_GRADE',
  grade_span STRING COMMENT 'src rows 1686; Grade_Span',
  school_level STRING COMMENT 'src rows 1687; SCHOOL_LEVEL',
  ayp_school_type_code STRING COMMENT 'src rows 1688,1756; SCHOOL_TYPE_CD',
  mlocale_type_cd STRING COMMENT 'src rows 1740; MLOCALE_TYPE_CD',
  mlocale_type_desc STRING COMMENT 'src rows 1741; MLOCALE_TYPE_DESC',
  ulocale_type_cd STRING COMMENT 'src rows 1742; ULOCALE_TYPE_CD',
  ulocale_type_desc STRING COMMENT 'src rows 1743; ULOCALE_TYPE_DESC',
  urban_rural STRING COMMENT 'src rows 1744; Urban_Rural',
  geog_setting STRING COMMENT 'src rows 1745; Geog_Setting',
  latitude DECIMAL(12,3) COMMENT 'src rows 1746; LATCOD',
  longitude DECIMAL(12,3) COMMENT 'src rows 1747; LONCOD',
  academic_period_id BIGINT COMMENT 'src rows 1749; SCHOOL_YEAR',
  source_school_year STRING COMMENT 'src rows 1749; SCHOOL_YEAR',
  org_id BIGINT COMMENT 'src rows 1750; SCHOOL_ID',
  parent_lea_org_id BIGINT COMMENT 'src rows 1752; DISTRICT_ID',
  ceeb_code STRING COMMENT 'src rows 1963; high_school',
  sbctc_high_school_code STRING COMMENT 'src rows 2335; HI_SCHL'
)
USING DELTA
CLUSTER BY (academic_period_id)
COMMENT 'Type-specific satellite; hierarchy: parent_lea_org_id (School -> LEA/ESD-as-district) | Grain: One row per org_id per version (K12 School attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_LEA (
  org_lea_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  elms_school_district_id STRING COMMENT 'src rows 106; IEPSchoolDistrictId',
  ospi_ccddd STRING COMMENT 'src rows 96,97,460,568,858,883,942,956,1002,1046,1048,1135...; ApplicationDistrictCode, CCDDD, Codist, DISTRICT_ID, DistCode, DistrictCode, IEPSchoolDistrictCode, LastReportedDistrictCode, ResidentDistrictCode, SchoolDistrictCode, WaK_district',
  ospi_org_id BIGINT COMMENT 'src rows 569,621,938,939,998,999,1126,1308,1341,1391,1430,1646...; ApprovedOnlinePGMResidentDistOrg, ApprovedOnlinePGMResidentDistOrgId, DistrictOrgID, DistrictOrganizationId, OrganizationId, Resident District Id, ResidentDistrictOrgID, Serving Di',
  county_code STRING COMMENT 'src rows 1676; CC_CD',
  county_name DECIMAL(12,3) COMMENT 'src rows 1677; County_Name',
  nces_lea_id STRING COMMENT 'src rows 1678; NCESDIST',
  parent_esd_org_id BIGINT COMMENT 'src rows 1754; ESD_ID'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: parent_esd_org_id (LEA -> ESD) | Grain: One row per org_id per version (Lea attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_PS_CAMPUS_SITE (
  org_ps_campus_site_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  epp_campus_name STRING COMMENT 'src rows 373; course_campus',
  pchees_campus_id STRING COMMENT 'src rows 1961,1998,2028,2045,2086; campus',
  sbctc_doc_site_code STRING COMMENT 'src rows 2198,2303; DOC_SITE'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: parent_ps_institution_org_id (campus / DOC site -> college; DOC site re-parenting effective-dated) | Grain: One row per org_id per version (Ps Campus Site attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_PS_COLLEGE_DISTRICT (
  org_ps_college_district_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  sbctc_district_code STRING COMMENT 'src rows 2240; DIST'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: none | Grain: One row per org_id per version (Ps College District attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_PS_INSTITUTION (
  org_ps_institution_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ceeb_code STRING COMMENT 'src rows 369,379,393,430,451,472,1969,1975,2000,2023,2035,2063...; inst_code, institution, previous_institution',
  wa_public_flag BOOLEAN COMMENT 'src rows 2102; WAPublicFlag',
  organization_year STRING COMMENT 'src rows 2103; OrganizationYear',
  inst_cat_lvl STRING COMMENT 'src rows 2104; InstCatLvl',
  ps_organization_level_ttl STRING COMMENT 'src rows 2105; PSOrganizationLevelTTL',
  ps_organization_level_ttl_src STRING COMMENT 'src rows 2106; PSOrganizationLevelTTL_Src',
  opeid_branch STRING COMMENT 'src rows 2116,2144; College_Code_Branch, Parent_College_Code',
  college_state STRING COMMENT 'src rows 2118; College_State',
  n_2_year_4_year STRING COMMENT 'src rows 2119; _2_year_4_year',
  public_private STRING COMMENT 'src rows 2120; Public_Private',
  ctclink_institution_code STRING COMMENT 'src rows 2357,2358,2359,2360,2361,2366; INSTITUTION',
  sbctc_college_code STRING COMMENT 'src rows 2180,2252,2261,2299,2332,2429,2450; COLLEGE',
  ipeds_unitid STRING COMMENT 'src rows 2380; PREV_COL_1',
  parent_college_district_org_id BIGINT COMMENT 'src rows 2240; DIST',
  ps_college_district_org_id BIGINT COMMENT 'src rows 2240; DIST',
  org_id BIGINT COMMENT 'src rows 2252; COLLEGE',
  wsac_institution_code STRING COMMENT 'src rows 2482; WSACInstitutionCode'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: parent_college_district_org_id (CTC -> college district); parent_ps_institution_org_id (NSC branch -> parent) | Grain: One row per org_id per version (Ps Institution attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_SEA (
  org_sea_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: none | Grain: One row per org_id per version (Sea attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.ORG_SERVICE_PROVIDER (
  org_service_provider_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  cedars_online_provider_code STRING COMMENT 'src rows 1387,1641; ApprovedOnlineProviderCode',
  cedars_online_program_code STRING COMMENT 'src rows 1389,1644; ApprovedOnlineProgramCode',
  cedars_online_program_list_order STRING COMMENT 'src rows 1393,1648; ApprovedOnlineProgramListOrder',
  cedars_nonpublic_agency_id STRING COMMENT 'src rows 1469; NonPublicAgencyId',
  cedars_nonpublic_agency_code STRING COMMENT 'src rows 1470; NonPublicAgencyCode',
  cedars_online_provider_id STRING COMMENT 'src rows 1640; ApprovedOnlineProviderId',
  cedars_online_program_id STRING COMMENT 'src rows 1643; ApprovedOnlineProgramId',
  open_doors_provider_code STRING COMMENT 'src rows 1764; Provider Code'
)
USING DELTA
COMMENT 'Type-specific satellite; hierarchy: parent_service_provider_org_id (online program -> online provider) | Grain: One row per org_id per version (Service Provider attributes)'
TBLPROPERTIES ('p20w.table_type' = 'ORG_SATELLITE', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.PERSON (
  person_sk BIGINT COMMENT 'SYSTEM: version surrogate key',
  effective_start_date DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  effective_end_date DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  is_current BOOLEAN COMMENT 'SYSTEM: current version flag',
  record_hash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  person_id BIGINT COMMENT 'Durable statewide person key issued by identity resolution (never reused)',
  identity_confidence_tier STRING COMMENT 'Lowest match confidence among links that formed this person (DETERMINISTIC_SSID / PROBABILISTIC_HIGH / CLERICAL_REVIEW)',
  birth_year SMALLINT COMMENT 'src rows 89,178,244,278,329,402,537,539,578,580,626,843...; BIRTH_DATE, Birth Date, BirthDate, BirthMonth, BirthYM, BirthYear, Birthdate, DOB, Date_of_Birth, SRBirthDate, StaffBirthDate, StudentBirthDate, WaK_Birthdate, birth_date',
  birth_month SMALLINT COMMENT 'src rows 89,178,244,278,329,402,537,539,578,580,626,843...; BIRTH_DATE, Birth Date, BirthDate, BirthMonth, BirthYM, BirthYear, Birthdate, DOB, Date_of_Birth, SRBirthDate, StaffBirthDate, StudentBirthDate, WaK_Birthdate, birth_date',
  sex STRING COMMENT 'src rows 90,229,245,405,482,540,581,631,841,1060,1806,1829...; Gender, Gender Code, GenderTypeId, SEX, Sex, SexCode, StudentGender, WaK_Gender, gender, sex',
  federal_race_ethnicity_rollup STRING COMMENT 'src rows 91,94,173,177,179,184,195,202,214,215,216,219...; AfricanAmerican, Asian, CEDARSRaceEthnicity, CENSUS_HISP_CD, CENSUS_RACE_CD, CENSUS_RACE_CD2, Caucasian, ETH_ORIG, EastIndian, EthCode, EthDesc, EthEndDate, EthStartDate, EthnicCod',
  country_of_birth_code STRING COMMENT 'src rows 1071; BirthCountryCode'
)
USING DELTA
CLUSTER BY (person_id)
COMMENT 'Single conformed person dimension across all sectors | Grain: One row per durable person per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2 (sex, birth year/month, race-ethnicity roll-up, country of birth recomputed by survivorship)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.PERSON_LANGUAGE (
  person_language_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  language_code STRING COMMENT 'src rows 92,221,228,1076,1078,1123,2392; FamilyLanguageCode, LanguageSpokenatHomeCode, LanguageTypeId, PRIMARY_LANGUAGE, PrimaryLanguageCode, PrimeLang, SecondLang',
  language_use_type BOOLEAN COMMENT 'src rows 93; IsPrimaryLanguage'
)
USING DELTA
COMMENT 'Multi-valued language observations | Grain: One row per person x source x period x language use type'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION_BRIDGE', 'p20w.scd' = 'Type 2 by observation period', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.PERSON_RACE_ETHNICITY (
  person_race_ethnicity_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_race_ethnicity_type_id STRING COMMENT 'src rows 91,94,1129,1433; EthnicityTypeId, RaceTypeId',
  source_race_ethnicity_code STRING COMMENT 'src rows 173,177,179,184,195,202,214,215,216,219,223,238...; AfricanAmerican, Asian, CENSUS_HISP_CD, CENSUS_RACE_CD, CENSUS_RACE_CD2, Caucasian, ETH_ORIG, EastIndian, EthCode, EthnicCode, EthnicOther, Ethnicity, HISPANIC, Hispanic, HispanicO',
  reported_race_ethnicity_rollup STRING COMMENT 'src rows 630,1074,1075,1132,1436,1832,1918,1929,1950,2277,2351,2398...; CEDARSRaceEthnicity, FedEthTypeRollup, FederalEthRaceRollupCode, FederalEthRaceRollupName, HU_STU_OF_COLOR, LastReportedOSPIRaceEthnicity, RACE_ETHNIC_CODE, RaceEthnicity, STU_OF_C',
  academic_period_id BIGINT COMMENT 'src rows 1125,1429; SchoolYear',
  source_school_year STRING COMMENT 'src rows 1125,1429; SchoolYear',
  lea_org_id BIGINT COMMENT 'src rows 1126,1135,1430,1439; DistrictCode, DistrictOrganizationId',
  person_id BIGINT COMMENT 'src rows 1127,1431; SSID',
  race_or_ethnicity_record_type STRING COMMENT 'src rows 1128,1432; RaceOrEth',
  source_race_ethnicity_description STRING COMMENT 'src rows 1131,1435; EthDesc, RaceDescription',
  source_status_start_date STRING COMMENT 'src rows 1133,1437; EthStartDate, RaceStartDate',
  source_status_end_date STRING COMMENT 'src rows 1134,1438; EthEndDate, RaceEndDate',
  source_submit_date DATE COMMENT 'src rows 1136,1440; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1137,1441; ExtractDate',
  collection_method_code_id STRING COMMENT 'src rows 1138,1442; EthnicityCollectionMethodID, RaceCollectionMethodID',
  collection_method_code STRING COMMENT 'src rows 1139,1443; EthnicityCollectionMethodCode, RaceCollectionMethodCode',
  collection_method_description STRING COMMENT 'src rows 1140,1444; EthnicityCollectionMethod, RaceCollectionMethod'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Multi-valued race/ethnicity observations | Grain: One row per person x source system x reported period x race/ethnicity value'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION_BRIDGE', 'p20w.scd' = 'Type 2 by observation period (source start/end dates); history never overwritten', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.PROGRAM (
  program_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  academic_period_id BIGINT COMMENT 'src rows 378,2011,2026; academic_year, term, year',
  ps_institution_org_id BIGINT COMMENT 'src rows 379,2023; inst_code, institution',
  program_name STRING COMMENT 'src rows 380,1420,2017; ProgramName, degree, prog_award_name',
  program_identifier STRING COMMENT 'src rows 381,809,2025,2427; ACAD_PLAN, Program Id, prog_id, program',
  classification_of_instructional_program_code STRING COMMENT 'src rows 388,2022,2425; CIP_CODE, field_of_study_CIP, prog_field_CIP',
  credits_required DECIMAL(12,3) COMMENT 'src rows 2016; credits_required'
)
USING DELTA
CLUSTER BY (academic_period_id)
COMMENT 'Conformed program definition | Grain: One row per offering organization x program identifier x period of definition'
TBLPROPERTIES ('p20w.table_type' = 'DEFINITION', 'p20w.scd' = 'Type 2 on program attributes (award level, credits, CIP)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.PROGRAM_APPR_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  occupation_id STRING COMMENT 'src rows 811; Occupation Id',
  occupation_name STRING COMMENT 'src rows 812; Occupation Name',
  standard_occupational_classification_code STRING COMMENT 'src rows 813; Soc Code',
  term_in_hours DECIMAL(12,3) COMMENT 'src rows 824; Term In Hours',
  program_rsi_hours DECIMAL(12,3) COMMENT 'src rows 830; Program RSIHours',
  sub_program STRING COMMENT 'src rows 857; Sub Program'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.PROGRAM_EL_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  elms_program_type_id STRING COMMENT 'src rows 103; ProgramTypeId'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.PROGRAM_K12_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  state_program_code STRING COMMENT 'src rows 1285; ProgramCode',
  state_program_id STRING COMMENT 'src rows 1419; ProgramID'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.PROGRAM_PS_EPP_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_year STRING COMMENT 'src rows 378; year',
  prog_term_type STRING COMMENT 'src rows 382; prog_term_type',
  prog_award_level STRING COMMENT 'src rows 383; prog_award_level',
  prog_award_req_cred STRING COMMENT 'src rows 384; prog_award_req_cred',
  prog_length_min STRING COMMENT 'src rows 385; prog_length_min',
  prog_length_max STRING COMMENT 'src rows 386; prog_length_max',
  prog_field STRING COMMENT 'src rows 387; prog_field',
  prog_conc STRING COMMENT 'src rows 389; prog_conc',
  prog_conc_cip STRING COMMENT 'src rows 390; prog_conc_CIP'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.PROGRAM_PS_PCHEES_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_academic_year STRING COMMENT 'src rows 2011; academic_year',
  concentration DECIMAL(12,3) COMMENT 'src rows 2012; concentration',
  concentration_cip DECIMAL(12,3) COMMENT 'src rows 2013; concentration_CIP',
  concentration_description DECIMAL(12,3) COMMENT 'src rows 2014; concentration_description',
  concentration_institutional_code STRING COMMENT 'src rows 2015; concentration_institutional_code',
  degree_acronym STRING COMMENT 'src rows 2018; degree_acronym',
  academic_award_level_conferred STRING COMMENT 'src rows 2019; degree_level',
  field_of_study STRING COMMENT 'src rows 2020; field_of_study',
  field_of_study_institutional_code STRING COMMENT 'src rows 2021; field_of_study_institutional_code',
  source_record_number STRING COMMENT 'src rows 2024; record_number',
  source_term STRING COMMENT 'src rows 2026; term'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.conformed.PROGRAM_PS_SBCTC_PLAN_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  descr STRING COMMENT 'src rows 2237; DESCR',
  acad_career STRING COMMENT 'src rows 2426; ACAD_CAREER',
  acad_prog STRING COMMENT 'src rows 2428; ACAD_PROG',
  degree STRING COMMENT 'src rows 2430; DEGREE',
  subplan STRING COMMENT 'src rows 2449; SUBPLAN',
  subplan_descr STRING COMMENT 'src rows 2451; SUBPLAN_DESCR',
  trnscr_descr STRING COMMENT 'src rows 2462; TRNSCR_DESCR'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ABSENCE (
  absence_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  academic_period_id BIGINT COMMENT 'src rows 937; SchoolYear',
  source_school_year STRING COMMENT 'src rows 937; SchoolYear',
  lea_org_id BIGINT COMMENT 'src rows 938,942; DistrictCode, DistrictOrgID',
  resident_lea_org_id BIGINT COMMENT 'src rows 939; ResidentDistrictOrgID',
  school_org_id BIGINT COMMENT 'src rows 940,941,944; LocationID, SchoolCode, SchoolOrgID',
  person_id BIGINT COMMENT 'src rows 947,948; DistrictStudentID, SSID',
  attendance_event_date DATE COMMENT 'src rows 949; AbsenceDate',
  absence_code STRING COMMENT 'src rows 951; AbsenceCode',
  absent_attendance_category STRING COMMENT 'src rows 951; AbsenceCode',
  full_day_absence_indicator STRING COMMENT 'src rows 951; AbsenceCode',
  source_submit_date DATE COMMENT 'src rows 953; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 954; ExtractDate'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Single-sector conformed family table | Grain: One row per person x school x absence date x absence code'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ACHIEVEMENT (
  achievement_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  awarding_org_id BIGINT COMMENT 'Institution/LEA/L&I org that conferred the credential (from the contributing source''s org FK)',
  credential_type DATE COMMENT 'src rows 815,1067,1270,1662,1799,1800,1802,1803,2004,2143,2153,2257; College Degree, Current Status, DateBatteryCompleted, Degree_Level, EXIT_CD, High School Diploma, High School Equivalency Certificate, Industry Recognized Certificate, IndustryCert',
  award_date DATE COMMENT 'src rows 816,1066,2009,2125,2153,2285; DateBatteryCompleted, DateExitedSchool, Graduation_Date, Status Date, YRQ, term',
  academic_period_id BIGINT COMMENT 'src rows 1997,2009,2166,2167,2285,2434; QUARTER, STRM, YEAR, YRQ, academic_year, term',
  ps_campus_org_id BIGINT COMMENT 'src rows 1998; campus',
  ps_institution_org_id BIGINT COMMENT 'src rows 2000,2261,2358; COLLEGE, INSTITUTION, institution',
  person_id BIGINT COMMENT 'src rows 2008,2153,2241,2248,2419; DW_KEY, DateBatteryCompleted, EMPLID, SID, student_institution'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Terminal completion/credential events only | Grain: One row per person x credential type x award date x awarding organization'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ACHIEVEMENT_APPR_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  program_id BIGINT COMMENT 'src rows 815; Current Status'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ACHIEVEMENT_K12_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  cedars_withdrawal_code STRING COMMENT 'src rows 1067; WithdrawalCode',
  industry_certification_code STRING COMMENT 'src rows 1270; IndustryCertificationEarned'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ACHIEVEMENT_PS_EPP_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  recommend STRING COMMENT 'src rows 418; recommend',
  endorse_complete_date STRING COMMENT 'src rows 423; endorse_complete_date',
  endorse_recommend STRING COMMENT 'src rows 424; endorse_recommend',
  cw_completion_date STRING COMMENT 'src rows 425; cw_completion_date',
  cwtest_completion_date STRING COMMENT 'src rows 426; cwtest_completion_date',
  title_ii_flag STRING COMMENT 'src rows 427; Title_II_flag'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ACHIEVEMENT_PS_NSC_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  status STRING COMMENT 'src rows 2095; Status',
  nsc_effective_date DATE COMMENT 'src rows 2096; NSCEffectiveDate',
  degree_type STRING COMMENT 'src rows 2107; DegreeType',
  graduated STRING COMMENT 'src rows 2124; Graduated',
  graduation_date DATE COMMENT 'src rows 2125; Graduation_Date',
  academic_award_title STRING COMMENT 'src rows 2126; Degree_Title',
  major STRING COMMENT 'src rows 2127; Major',
  degree_cip_1 STRING COMMENT 'src rows 2135; Degree_CIP_1',
  degree_major_1 STRING COMMENT 'src rows 2136; Degree_Major_1',
  degree_cip_2 STRING COMMENT 'src rows 2137; Degree_CIP_2',
  degree_major_2 STRING COMMENT 'src rows 2138; Degree_Major_2',
  degree_cip_3 STRING COMMENT 'src rows 2139; Degree_CIP_3',
  degree_major_3 STRING COMMENT 'src rows 2140; Degree_Major_3',
  degree_cip_4 STRING COMMENT 'src rows 2141; Degree_CIP_4',
  degree_major_4 STRING COMMENT 'src rows 2142; Degree_Major_4',
  degree_level STRING COMMENT 'src rows 2143; Degree_Level'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ACHIEVEMENT_PS_PCHEES_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_academic_year STRING COMMENT 'src rows 1997; academic_year',
  first_minor_cip STRING COMMENT 'src rows 1999; first_minor_CIP',
  institutional_credits_earned DECIMAL(12,3) COMMENT 'src rows 2001; institutional_credits_earned',
  post_baccalaureate_status STRING COMMENT 'src rows 2002; post_baccalaureate_status',
  non_institutional_credits_earned DECIMAL(12,3) COMMENT 'src rows 2003; non_institutional_credits_earned',
  first_major_program_id STRING COMMENT 'src rows 2004; program',
  classification_of_instructional_program_code STRING COMMENT 'src rows 2004; program',
  source_record_number STRING COMMENT 'src rows 2005; record_number',
  second_major_cip STRING COMMENT 'src rows 2006; second_major_CIP',
  second_minor_cip STRING COMMENT 'src rows 2007; second_minor_CIP',
  source_term STRING COMMENT 'src rows 2009; term',
  teaching_certification STRING COMMENT 'src rows 2010; teaching_certification'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ACHIEVEMENT_PS_SBCTC_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_quarter STRING COMMENT 'src rows 2166; QUARTER',
  source_year STRING COMMENT 'src rows 2167; YEAR',
  degree_num STRING COMMENT 'src rows 2234; DEGREE_NUM',
  disability STRING COMMENT 'src rows 2238; DISABILITY',
  award_type STRING COMMENT 'src rows 2255; AWARD_TYPE',
  center_cd STRING COMMENT 'src rows 2256; CENTER_CD',
  exit_code STRING COMMENT 'src rows 2257; EXIT_CD',
  classification_of_instructional_program_code STRING COMMENT 'src rows 2258; PROGRAM_CIP',
  acad_prog STRING COMMENT 'src rows 2259; ACAD_PROG',
  united_states_citizenship_status STRING COMMENT 'src rows 2260; CITZ_STAT',
  academic_award_title STRING COMMENT 'src rows 2263; DEGREE_TITLE',
  econ_disad_ind STRING COMMENT 'src rows 2266; ECON_DISAD_IND',
  international_student STRING COMMENT 'src rows 2369; INTERNATIONAL_STUDENT',
  program_compl STRING COMMENT 'src rows 2382; PROGRAM_COMPL',
  program_suffix STRING COMMENT 'src rows 2383; PROGRAM_SUFFIX',
  source_yrq_added STRING COMMENT 'src rows 2385; QTR_ADDED',
  rec_cd STRING COMMENT 'src rows 2387; REC_CD',
  source_strm STRING COMMENT 'src rows 2434; STRM'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ADMISSION (
  admission_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  sector STRING COMMENT 'EL / PS / FA',
  academic_period_id BIGINT COMMENT 'src rows 82,112,113,127,153,470,471,1952,1994,2588,2650; ApplicationAcademicYear, SchoolYear, SchoolYearID, SchoolYearId, academic_year, term, year',
  source_application_identifier STRING COMMENT 'src rows 104,105,2584,2622; ApplicationDataId, ApplicationId, CBSPledgeID, CBSPledgeId',
  iep_lea_org_id BIGINT COMMENT 'src rows 97,106; IEPSchoolDistrictCode, IEPSchoolDistrictId',
  resident_lea_org_id BIGINT COMMENT 'src rows 96; SchoolDistrictCode',
  program_id BIGINT COMMENT 'src rows 103,477,2584,2622; CBSPledgeID, CBSPledgeId, ProgramTypeId, prog_id',
  person_id BIGINT COMMENT 'src rows 174,175,176,185,186,187,188,189,190,191,192,193...; Age1, Age2, AnnualIncome, ApplicationSSID, ApplicationSSId, EIAnnualIncome, EIFosterCare, EIMonthlyIncome, EIMonthlyIncomeDesc, EITANFFamily, EligibleIncome, EligibleReturning, Eli',
  ps_institution_org_id BIGINT COMMENT 'src rows 472,1969; inst_code, institution',
  application_date DATE COMMENT 'src rows 481,2665; PledgeSubmissionDate, app_date',
  admission_decision_code STRING COMMENT 'src rows 500; decision',
  entry_academic_period_id BIGINT COMMENT 'src rows 1959,1960; admit_academic_year, admit_term',
  ps_campus_org_id BIGINT COMMENT 'src rows 1961; campus',
  last_high_school_org_id BIGINT COMMENT 'src rows 1963; high_school',
  previous_ps_institution_org_id BIGINT COMMENT 'src rows 1975; previous_institution',
  admission_type STRING COMMENT 'src rows 1993; student_type',
  application_school_org_id BIGINT COMMENT 'src rows 2611,2639,2640; ApplicationSchoolCode, SchoolId',
  last_reported_school_org_id BIGINT COMMENT 'src rows 2612,2625,2653; LastReportedSchCode, LastReportedSchoolCode',
  application_lea_org_id BIGINT COMMENT 'src rows 2645; ApplicationDistrictCode',
  application_esd_org_id BIGINT COMMENT 'src rows 2647; ApplicationESDNumber',
  last_reported_lea_org_id BIGINT COMMENT 'src rows 2655; LastReportedDistrictCode'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Admission / application grain (4-year, EPP, EL eligibility, College Bound pledge) | Grain: One row per person x organization x entry period x program (application/admission decision)'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ADMISSION_EL_ELMS_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year_id STRING COMMENT 'src rows 82,112; SchoolYearID, SchoolYearId',
  family_income DECIMAL(14,2) COMMENT 'src rows 107,109; AnnualFamilyIncomeForEligibility, MonthlyFamilyIncomeForEligibilit',
  annual_federal_poverty_level DECIMAL(14,2) COMMENT 'src rows 108; AnnualFederalPovertyLevel',
  monthly_family_income_for_eligibilit DECIMAL(14,2) COMMENT 'src rows 109; MonthlyFamilyIncomeForEligibilit',
  monthly_federal_poverty_level DECIMAL(14,2) COMMENT 'src rows 110; MonthlyFederalPovertyLevel',
  resides_with_type_id STRING COMMENT 'src rows 111; ResidesWithTypeId',
  reporting_fpl DECIMAL(14,2) COMMENT 'src rows 114; ReportingFPL',
  county_number DECIMAL(12,3) COMMENT 'src rows 98; CountyNumber',
  source_school_year STRING COMMENT 'src rows 113,127,153; SchoolYear'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ADMISSION_EL_ELMS_ELIGIBILITY_RESPONSE (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp'
  -- q{boolean_question_id}_answer: one BOOLEAN column per source question id (generated from ELMS BooleanQuestion lookup); inventory rows [79, 80]
)
USING DELTA
COMMENT 'Pivoted boolean eligibility responses | Grain: 1:1 with application row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'n/a', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ADMISSION_EL_HIST_ECEAP_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  age1 STRING COMMENT 'src rows 174; Age1',
  age2 STRING COMMENT 'src rows 175; Age2',
  annual_income DECIMAL(14,2) COMMENT 'src rows 176; AnnualIncome',
  ei_annual_income DECIMAL(14,2) COMMENT 'src rows 185; EIAnnualIncome',
  ei_foster_care STRING COMMENT 'src rows 186; EIFosterCare',
  ei_monthly_income DECIMAL(14,2) COMMENT 'src rows 187; EIMonthlyIncome',
  ei_monthly_income_desc DECIMAL(14,2) COMMENT 'src rows 188; EIMonthlyIncomeDesc',
  eitanf_family STRING COMMENT 'src rows 189; EITANFFamily',
  eligible_income DECIMAL(14,2) COMMENT 'src rows 190; EligibleIncome',
  eligible_returning STRING COMMENT 'src rows 191; EligibleReturning',
  eligible_risk STRING COMMENT 'src rows 192; EligibleRisk',
  eligible_special STRING COMMENT 'src rows 193; EligibleSpecial',
  family_homeless STRING COMMENT 'src rows 197; FamilyHomeless',
  foster_care_children_on_grant DECIMAL(14,2) COMMENT 'src rows 200; FosterCareChildrenOnGrant',
  foster_care_monthly_amount DECIMAL(14,2) COMMENT 'src rows 201; FosterCareMonthlyAmount',
  in_prison1 STRING COMMENT 'src rows 203; InPrison1',
  in_prison2 STRING COMMENT 'src rows 204; InPrison2',
  learning_program STRING COMMENT 'src rows 206; LearningProgram',
  lives_with_foster_care STRING COMMENT 'src rows 207; LivesWithFosterCare',
  lives_with_relative DECIMAL(12,3) COMMENT 'src rows 208; LivesWithRelative',
  lives_with_single_parent STRING COMMENT 'src rows 209; LivesWithSingleParent',
  lives_with_two_parents STRING COMMENT 'src rows 210; LivesWithTwoParents',
  monthly_income DECIMAL(14,2) COMMENT 'src rows 213; MonthlyIncome',
  over_income DECIMAL(14,2) COMMENT 'src rows 217; OverIncome',
  over_income_explain DECIMAL(14,2) COMMENT 'src rows 218; OverIncomeExplain',
  number_of_people_in_household STRING COMMENT 'src rows 220; PersonsHouse',
  reason STRING COMMENT 'src rows 224; Reason',
  resides_with STRING COMMENT 'src rows 226; ResidesWith',
  tanf_monthly_amount DECIMAL(14,2) COMMENT 'src rows 233; TANFMonthlyAmount',
  tanf_people_on_grant DECIMAL(14,2) COMMENT 'src rows 234; TANFPeopleOnGrant',
  under20_parent1 STRING COMMENT 'src rows 235; Under20Parent1',
  under20_parent2 STRING COMMENT 'src rows 236; Under20Parent2',
  waitlisted STRING COMMENT 'src rows 237; Waitlisted'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ADMISSION_FA_CBS_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_application_academic_year STRING COMMENT 'src rows 2588,2650; ApplicationAcademicYear',
  application_student_grade STRING COMMENT 'src rows 2589,2634; ApplicationStudentGrade',
  cohort STRING COMMENT 'src rows 2590,2649; Cohort',
  expected_hs_grad_year STRING COMMENT 'src rows 2591,2661; ExpectedHSGradYear',
  guardian_address_zip STRING COMMENT 'src rows 2600,2633; GuardianAddressZip',
  guardian_education_level STRING COMMENT 'src rows 2602,2643; GuardianEducationLevel',
  expected_student_grade STRING COMMENT 'src rows 2603; ExpectedStudentGrade',
  last_reported_student_grade STRING COMMENT 'src rows 2604,2657; LastReportedStudentGrade',
  last_reported_gpa DECIMAL(12,3) COMMENT 'src rows 2605,2652; LastReportedGPA',
  last_ospi_enrollment_status_code STRING COMMENT 'src rows 2606,2679; LastOSPIEnrollmentStatusCode',
  last_reported_hs_grad_req_year STRING COMMENT 'src rows 2607,2667; LastReportedHSGradReqYear',
  last_reported_expected_hs_grad_yr STRING COMMENT 'src rows 2608; LastReportedExpectedHSGradYr',
  actual_hs_grad_year STRING COMMENT 'src rows 2609,2666; ActualHSGradYear',
  hs_requirements_met STRING COMMENT 'src rows 2610,2680; HSRequirementsMet',
  matched_with_ospi STRING COMMENT 'src rows 2613,2660; MatchedWithOSPI',
  source_ospi_extract_date DATE COMMENT 'src rows 2614; OSPIExtractDate',
  fafsa_match STRING COMMENT 'src rows 2615,2662; FafsaMatch',
  online_application STRING COMMENT 'src rows 2616,2637,2681; IsOnlineApp, OnlineApplication',
  application_language DECIMAL(12,3) COMMENT 'src rows 2617,2638; ApplicationLanguage',
  pledge_count DECIMAL(12,3) COMMENT 'src rows 2618; PledgeCount',
  cbs_pledge_id1 STRING COMMENT 'src rows 2619; CBSPledgeID1',
  cbs_pledge_id2 STRING COMMENT 'src rows 2620; CBSPledgeID2',
  cbs_pledge_id3 STRING COMMENT 'src rows 2621; CBSPledgeID3',
  cbs_application_status_index STRING COMMENT 'src rows 2635; CBSApplicationStatusIndex',
  application_academic_year_index STRING COMMENT 'src rows 2636; ApplicationAcademicYearIndex',
  cbs_application_status STRING COMMENT 'src rows 2641; CBSApplicationStatus',
  complete STRING COMMENT 'src rows 2642; Complete',
  grad_year STRING COMMENT 'src rows 2648; GradYear',
  application_school_type STRING COMMENT 'src rows 2651; ApplicationSchoolType',
  last_reported_school_type STRING COMMENT 'src rows 2658; LastReportedSchoolType',
  left_ospi_system STRING COMMENT 'src rows 2659; LeftOSPISystem',
  fafsa_match_date DATE COMMENT 'src rows 2663; FAFSAMatchDate',
  cbs_applicant_type STRING COMMENT 'src rows 2664; CBSApplicantType',
  pledge_submission_date DATE COMMENT 'src rows 2665; PledgeSubmissionDate',
  hs_graduation_academic_year_index STRING COMMENT 'src rows 2668; HSGraduationAcademicYearIndex',
  cbshs_requirements_met_index STRING COMMENT 'src rows 2670; CBSHSRequirementsMetIndex',
  cbshs_requirements_met STRING COMMENT 'src rows 2671; CBSHSRequirementsMet',
  bad_address STRING COMMENT 'src rows 2672; BadAddress',
  running_start STRING COMMENT 'src rows 2673; RunningStart',
  cte_dual_credit DECIMAL(12,3) COMMENT 'src rows 2674; CteDualCredit',
  college_in_the_high_school STRING COMMENT 'src rows 2675; CollegeInTheHighSchool',
  enrolled_in_college STRING COMMENT 'src rows 2676; EnrolledInCollege',
  home_zip STRING COMMENT 'src rows 2678; HomeZip',
  is_eligible_income DECIMAL(14,2) COMMENT 'src rows 2682; IsEligibleIncome',
  is_eligible_frpl STRING COMMENT 'src rows 2683; IsEligibleFRPL',
  is_eligible_tanf STRING COMMENT 'src rows 2684; IsEligibleTANF',
  has_both_signatures_bv STRING COMMENT 'src rows 2685; HasBothSignatures_BV',
  have_g_last_n1 STRING COMMENT 'src rows 2686; HaveGLastN1',
  have_g_last_n2 STRING COMMENT 'src rows 2687; HaveGLastN2',
  have_g_email1 STRING COMMENT 'src rows 2688; HaveGEmail1',
  have_g_email2 STRING COMMENT 'src rows 2689; HaveGEmail2',
  have_gh_phone STRING COMMENT 'src rows 2690; HaveGHPhone',
  have_g_tx_phone STRING COMMENT 'src rows 2691; HaveGTxPhone',
  have_s_phone STRING COMMENT 'src rows 2692; HaveSPhone',
  have_s_tx_phone STRING COMMENT 'src rows 2693; HaveSTxPhone',
  have_st_email STRING COMMENT 'src rows 2694; HaveSTEmail',
  auto_enrolled_bv STRING COMMENT 'src rows 2696; AutoEnrolled_BV'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ADMISSION_PS_EPP_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_year STRING COMMENT 'src rows 470; year',
  source_academic_year STRING COMMENT 'src rows 471; academic_year',
  prog_type STRING COMMENT 'src rows 474; prog_type',
  cred_role STRING COMMENT 'src rows 475; cred_role',
  cred_type STRING COMMENT 'src rows 476; cred_type',
  program_identifier STRING COMMENT 'src rows 477; prog_id',
  asset_prime STRING COMMENT 'src rows 491; asset_prime',
  asset_prime_txt STRING COMMENT 'src rows 492; asset_prime_txt',
  asset_aux STRING COMMENT 'src rows 493; asset_aux',
  asset_aux_txt STRING COMMENT 'src rows 494; asset_aux_txt',
  deficiency_prime STRING COMMENT 'src rows 495; deficiency_prime',
  deficiency_prime_txt STRING COMMENT 'src rows 496; deficiency_prime_txt',
  deficiency_clear_date DATE COMMENT 'src rows 497; deficiency_clear_date',
  deficiency_aux STRING COMMENT 'src rows 498; deficiency_aux',
  deficiency_aux_txt STRING COMMENT 'src rows 499; deficiency_aux_txt',
  wait_listed_student DATE COMMENT 'src rows 501; waitlist_date',
  endorse_code_initial STRING COMMENT 'src rows 502; endorse_code_initial'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ADMISSION_PS_PCHEES_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_academic_year STRING COMMENT 'src rows 1952; academic_year',
  admit_academic_year STRING COMMENT 'src rows 1959; admit_academic_year',
  admit_term STRING COMMENT 'src rows 1960; admit_term',
  co_enrolled_status STRING COMMENT 'src rows 1962; co_enrolled_status',
  high_school_completion_type STRING COMMENT 'src rows 1964; high_school_completion_type',
  high_school_completion_year STRING COMMENT 'src rows 1965; high_school_completion_year',
  high_school_gpa_key DECIMAL(12,3) COMMENT 'src rows 1966; high_school_GPA_key',
  high_school_last_year_attended STRING COMMENT 'src rows 1967; high_school_last_year_attended',
  previous_credits_earned DECIMAL(12,3) COMMENT 'src rows 1970; previous_credits_earned',
  nation STRING COMMENT 'src rows 1971; nation',
  previous_credits_transferred_ap DECIMAL(12,3) COMMENT 'src rows 1972; previous_credits_transferred_AP',
  previous_credits_transferred_ib DECIMAL(12,3) COMMENT 'src rows 1973; previous_credits_transferred_IB',
  previous_credits_transferred_total DECIMAL(12,3) COMMENT 'src rows 1974; previous_credits_transferred_total',
  previous_institution_degree_acronym STRING COMMENT 'src rows 1976; previous_institution_degree_acronym',
  previous_institution_degree_level STRING COMMENT 'src rows 1977; previous_institution_degree_level',
  previous_institution_gpa_key DECIMAL(12,3) COMMENT 'src rows 1978; previous_institution_GPA_key',
  previous_institution_last_year_attended STRING COMMENT 'src rows 1979; previous_institution_last_year_attended',
  previous_institution_dta_ast_status STRING COMMENT 'src rows 1980; previous_institution_dta_ast_status',
  source_record_number STRING COMMENT 'src rows 1981; record_number',
  running_start_affiliation STRING COMMENT 'src rows 1983; running_start_affiliation',
  student_type_code STRING COMMENT 'src rows 1993; student_type',
  source_term STRING COMMENT 'src rows 1994; term',
  us_state STRING COMMENT 'src rows 1995; US_state',
  wa_county DECIMAL(12,3) COMMENT 'src rows 1996; WA_county'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ASSESSMENT (
  assessment_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  sector STRING COMMENT 'EL / K12 / PS',
  organization_org_id BIGINT COMMENT 'Conformed administering organization (school, EL site, institution) coalesced from sector-specific org FKs',
  program_id BIGINT COMMENT 'src rows 288,289; Program, ProgramID',
  performance_level_code STRING COMMENT 'src rows 296,297,298,299,300,301,311,318,874,895,911,919...; CG_WHE, LA_WHE, LI_WHE, Level_Listening, Level_Reading, Level_Speaking, Level_Writing, MA_WHE, PH_WHE, PerformanceLevel, SE_WHE, SLA_WHE, SLI_WHE, SpanishLanguageDevelopmentLevel, ',
  standard_met_indicator BOOLEAN COMMENT 'src rows 296,297,298,299,300,301,311,318,443,872,893,1897...; CG_WHE, LA_WHE, LI_WHE, MA_WHE, PH_WHE, SE_WHE, SLA_WHE, SLI_WHE, SpanishLanguageReadinessFlag, SpanishLiteracyReadinessFlag, Standard_met_ind, WaK_CognitiveReadinessFlag, WaK_Lang',
  person_id BIGINT COMMENT 'src rows 302,327,332,358,361,431,863,887,1822,1826,1904,1905...; ACT_composite_score, ACT_english_score, ACT_math_score, ACT_reading_score, ACT_science_score, ACT_writing_score, ChildID, ELMS_SSID, SAT_critical_reading_score, SAT_date_taken, SAT',
  raw_score DECIMAL(12,3) COMMENT 'src rows 309,316,330,334,336,340,343,346,879,903,906,914...; CG_RS, LA_RS, LI_RS, MA_RS, PH_RS, RawScore, RawScore_Listening, RawScore_Reading, RawScore_Speaking, RawScore_Writing, SE_RS, SLA_RS, SLI_RS, Score, SpanishLanguageRawScore, Spani',
  scale_score DECIMAL(12,3) COMMENT 'src rows 310,317,331,335,337,341,344,347,442,504,508,512...; CG_SS, LA_SS, LI_SS, MA_SS, PH_SS, SE_SS, SLA_SS, SLI_SS, ScaleScore, ScaleScore_Listening, ScaleScore_Reading, ScaleScore_Speaking, ScaleScore_Writing, SpanishLanguageScaleScore, ',
  academic_period_id BIGINT COMMENT 'src rows 325,326,428,429,866,882,1906; SchoolYear, WaK_SchoolYear, academic_year, season, year',
  assessment_administration_date DATE COMMENT 'src rows 333,338,339,342,345,349,351,352,441,881,901,1931...; AssessmentDate, Assessment_Date, Cognitive_Date_Finalized, Language_Date_Finalized, Literacy_Date_Finalized, Mathematics_Date_Finalized, Physical_Date_Finalized, Social_Emotional_D',
  el_site_org_id BIGINT COMMENT 'src rows 348; SiteID',
  el_contractor_org_id BIGINT COMMENT 'src rows 356,357; ECEAP_Contractor, ELMS_Contractor_ID',
  ps_institution_org_id BIGINT COMMENT 'src rows 430; inst_code',
  assessment_instrument_id BIGINT COMMENT 'src rows 437,438,439,873,892,894; AssessmentName, TestType, assess_code, assess_name, test_code',
  assessment_subject_or_domain STRING COMMENT 'src rows 440,880,905,913,921,929; SubjectName, SubjectName_Listening, SubjectName_Reading, SubjectName_Speaking, SubjectName_Writing, rubric_name_edTPA',
  score_value_as_reported DECIMAL(12,3) COMMENT 'src rows 442,504,508,512,517,522,527; score, score_exam1, score_exam2, score_exam3, score_exam_m, score_exam_r, score_exam_w',
  lea_org_id BIGINT COMMENT 'src rows 858,883,1818; DistrictCode, WaK_districtcode',
  grade_level_when_assessed STRING COMMENT 'src rows 862,897; ReportingGrade',
  school_org_id BIGINT COMMENT 'src rows 864,885,1819; SchoolCode, WaK_schoolcode',
  assessment_administration_name STRING COMMENT 'src rows 871; Assessment_Name',
  participation_status_code STRING COMMENT 'src rows 875,896; Attempt',
  scale_score_standard_error DECIMAL(12,3) COMMENT 'src rows 902,908,916,924,932; SEM_Scale, SEM_Scale_Listening, SEM_Scale_Reading, SEM_Scale_Speaking, SEM_Scale_Writing',
  staff_person_id BIGINT COMMENT 'src rows 1820; WaK_TeacherID'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Conformed assessment results across EL, K-12, PS | Grain: One row per person x assessment instrument x administration x subject/domain (plus ALL_DOMAINS summary rows for multi-domain checkpoints)'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ASSESSMENT_EL_TSGOLD_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_dataset_name STRING COMMENT 'src rows 287; SourceDataset',
  program_id STRING COMMENT 'src rows 288; ProgramID',
  program STRING COMMENT 'src rows 289; Program',
  funding_sources STRING COMMENT 'src rows 294; Funding_Sources',
  age_grade STRING COMMENT 'src rows 295; Age_Grade',
  english_language_acquisition_da STRING COMMENT 'src rows 303; English_Language_Acquisition_Da',
  domains_meet_or_exceed DECIMAL(12,3) COMMENT 'src rows 304; Domains_Meet_or_Exceed',
  is_spanish_lang STRING COMMENT 'src rows 305; Is_Spanish_Lang',
  se_kr STRING COMMENT 'src rows 306; SE_KR',
  ph_kr STRING COMMENT 'src rows 307; PH_KR',
  la_kr STRING COMMENT 'src rows 308; LA_KR',
  sla_nn STRING COMMENT 'src rows 312; SLA_NN',
  sla_kr STRING COMMENT 'src rows 313; SLA_KR',
  cg_kr STRING COMMENT 'src rows 314; CG_KR',
  li_kr STRING COMMENT 'src rows 315; LI_KR',
  sli_nn STRING COMMENT 'src rows 319; SLI_NN',
  sli_kr STRING COMMENT 'src rows 320; SLI_KR',
  ma_kr STRING COMMENT 'src rows 321; MA_KR',
  has_content_areas STRING COMMENT 'src rows 322; Has_Content_Areas',
  has_optional_physical_dims STRING COMMENT 'src rows 323; Has_Optional_Physical_Dims',
  has_optional_dimensions STRING COMMENT 'src rows 324; Has_Optional_Dimensions',
  source_season STRING COMMENT 'src rows 325; season',
  source_year STRING COMMENT 'src rows 326; year',
  age_in_months DECIMAL(12,3) COMMENT 'src rows 328; Age_in_Months',
  whe_meet_or_exceed STRING COMMENT 'src rows 350; WHE_Meet_or_Exceed',
  k_readiness_accomplished STRING COMMENT 'src rows 353; K_Readiness_Accomplished',
  domains_completed DECIMAL(12,3) COMMENT 'src rows 354; Domains_Completed',
  school_year STRING COMMENT 'src rows 355; SchoolYear',
  hls_score DECIMAL(12,3) COMMENT 'src rows 359; HLS_Score',
  child_observations DECIMAL(12,3) COMMENT 'src rows 360; Child_observations',
  cognitive_completion_flag STRING COMMENT 'src rows 362; Cognitive_Completion_Flag',
  literacy_completion_flag STRING COMMENT 'src rows 363; Literacy_Completion_Flag',
  language_completion_flag STRING COMMENT 'src rows 364; Language_Completion_Flag',
  physical_completion_flag STRING COMMENT 'src rows 365; Physical_Completion_Flag',
  teacher_irr_status STRING COMMENT 'src rows 366; Teacher_IRR_Status',
  mathematics_completion_flag STRING COMMENT 'src rows 367; Mathematics_Completion_Flag',
  social_emotional_completion STRING COMMENT 'src rows 368; Social_Emotional_Completion'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ASSESSMENT_K12_ELP_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year STRING COMMENT 'src rows 882; SchoolYear',
  test_grade STRING COMMENT 'src rows 898; TestGrade',
  assessment_academic_subject STRING COMMENT 'src rows 900; SubjectName',
  pct_correct DECIMAL(12,3) COMMENT 'src rows 904; PctCorrect',
  theta_reading DECIMAL(12,3) COMMENT 'src rows 909; Theta_Reading',
  sem_theta_reading DECIMAL(12,3) COMMENT 'src rows 910; SEM_Theta_Reading',
  pct_correct_reading DECIMAL(12,3) COMMENT 'src rows 912; PctCorrect_Reading',
  theta_writing DECIMAL(12,3) COMMENT 'src rows 917; Theta_Writing',
  sem_theta_writing DECIMAL(12,3) COMMENT 'src rows 918; SEM_Theta_Writing',
  pct_correct_writing DECIMAL(12,3) COMMENT 'src rows 920; PctCorrect_Writing',
  theta_listening DECIMAL(12,3) COMMENT 'src rows 925; Theta_Listening',
  sem_theta_listening DECIMAL(12,3) COMMENT 'src rows 926; SEM_Theta_Listening',
  pct_correct_listening DECIMAL(12,3) COMMENT 'src rows 928; PctCorrect_Listening',
  theta_speaking DECIMAL(12,3) COMMENT 'src rows 933; Theta_Speaking',
  sem_theta_speaking DECIMAL(12,3) COMMENT 'src rows 934; SEM_Theta_Speaking',
  pct_correct_speaking DECIMAL(12,3) COMMENT 'src rows 936; PctCorrect_Speaking'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ASSESSMENT_K12_STATEWIDE_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  home_based STRING COMMENT 'src rows 860; HomeBased',
  private_school STRING COMMENT 'src rows 861; PrivateSchool',
  source_school_year STRING COMMENT 'src rows 866; SchoolYear',
  test_grade STRING COMMENT 'src rows 876; TestGrade',
  foreign_code STRING COMMENT 'src rows 877; ForeignCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ASSESSMENT_K12_WAKIDS_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_dataset_name STRING COMMENT 'src rows 1816; SourceDataset',
  wakids_class STRING COMMENT 'src rows 1821; WaK_Class',
  wakids_iep STRING COMMENT 'src rows 1827; WaK_IEP',
  wakids_bilingual_flag STRING COMMENT 'src rows 1828; WaK_BilingualFlag',
  wakids_primary_language DECIMAL(12,3) COMMENT 'src rows 1833; WaK_PrimaryLanguage',
  wakids_ifsp STRING COMMENT 'src rows 1834; WaK_IFSP',
  wakids_free_reduced_lunch_flag STRING COMMENT 'src rows 1835; WaK_FreeReducedLunchFlag',
  wakids_obj1a STRING COMMENT 'src rows 1836; WaK_Obj1a',
  wakids_obj1b STRING COMMENT 'src rows 1837; WaK_Obj1b',
  wakids_obj1c STRING COMMENT 'src rows 1838; WaK_Obj1c',
  wakids_obj2c STRING COMMENT 'src rows 1839; WaK_Obj2c',
  wakids_obj2d STRING COMMENT 'src rows 1840; WaK_Obj2d',
  wakids_obj4 STRING COMMENT 'src rows 1841; WaK_Obj4',
  wakids_obj5 STRING COMMENT 'src rows 1842; WaK_Obj5',
  wakids_obj6 STRING COMMENT 'src rows 1843; WaK_Obj6',
  wakids_obj7a STRING COMMENT 'src rows 1844; WaK_Obj7a',
  wakids_obj7b STRING COMMENT 'src rows 1845; WaK_Obj7b',
  wakids_obj8b STRING COMMENT 'src rows 1846; WaK_Obj8b',
  wakids_obj9a STRING COMMENT 'src rows 1847; WaK_Obj9a',
  wakids_obj9b STRING COMMENT 'src rows 1848; WaK_Obj9b',
  wakids_obj9c STRING COMMENT 'src rows 1849; WaK_Obj9c',
  wakids_obj9d STRING COMMENT 'src rows 1850; WaK_Obj9d',
  wakids_obj10a STRING COMMENT 'src rows 1851; WaK_Obj10a',
  wakids_obj10b STRING COMMENT 'src rows 1852; WaK_Obj10b',
  wakids_obj11c STRING COMMENT 'src rows 1853; WaK_Obj11c',
  wakids_obj11d STRING COMMENT 'src rows 1854; WaK_Obj11d',
  wakids_obj11e STRING COMMENT 'src rows 1855; WaK_Obj11e',
  wakids_obj12a STRING COMMENT 'src rows 1856; WaK_Obj12a',
  wakids_obj13 STRING COMMENT 'src rows 1857; WaK_Obj13',
  wakids_obj15a STRING COMMENT 'src rows 1858; WaK_Obj15a',
  wakids_obj15b STRING COMMENT 'src rows 1859; WaK_Obj15b',
  wakids_obj15c STRING COMMENT 'src rows 1860; WaK_Obj15c',
  wakids_obj16a STRING COMMENT 'src rows 1861; WaK_Obj16a',
  wakids_obj16b STRING COMMENT 'src rows 1862; WaK_Obj16b',
  wakids_obj17a STRING COMMENT 'src rows 1863; WaK_Obj17a',
  wakids_obj17b STRING COMMENT 'src rows 1864; WaK_Obj17b',
  wakids_obj18a STRING COMMENT 'src rows 1865; WaK_Obj18a',
  wakids_obj18b STRING COMMENT 'src rows 1866; WaK_Obj18b',
  wakids_obj18c STRING COMMENT 'src rows 1867; WaK_Obj18c',
  wakids_obj19a STRING COMMENT 'src rows 1868; WaK_Obj19a',
  wakids_obj19b STRING COMMENT 'src rows 1869; WaK_Obj19b',
  wakids_obj20a STRING COMMENT 'src rows 1870; WaK_Obj20a',
  wakids_obj20b STRING COMMENT 'src rows 1871; WaK_Obj20b',
  wakids_obj20c STRING COMMENT 'src rows 1872; WaK_Obj20c',
  wakids_obj21a STRING COMMENT 'src rows 1873; WaK_Obj21a',
  wakids_obj21b STRING COMMENT 'src rows 1874; WaK_Obj21b',
  wakids_obj22 STRING COMMENT 'src rows 1875; WaK_Obj22',
  wakids_obj23 STRING COMMENT 'src rows 1876; WaK_Obj23',
  domain_completion_indicator STRING COMMENT 'src rows 1889,1890,1891,1892,1893,1894; WaK_CognitiveCompletionFlag, WaK_LanguageCompletionFlag, WaK_LiteracyCompletionFlag, WaK_MathCompletionFlag, WaK_PhysicalCompletionFlag, WaK_SocialEmotionalCompletionFla',
  wakids_numberof_domains_ready DECIMAL(12,3) COMMENT 'src rows 1895; WaK_NumberofDomainsReady',
  wakidsnumberofdomainscomplete DECIMAL(12,3) COMMENT 'src rows 1896; WaK_numberofdomainscomplete',
  source_wa_k_school_year STRING COMMENT 'src rows 1906; WaK_SchoolYear',
  wakids_obj11a STRING COMMENT 'src rows 1907; WaK_Obj11a',
  wakids_obj11b STRING COMMENT 'src rows 1908; WaK_Obj11b',
  wakids_obj12b STRING COMMENT 'src rows 1909; WaK_Obj12b',
  wakids_obj14a STRING COMMENT 'src rows 1910; WaK_Obj14a',
  wakids_obj14b STRING COMMENT 'src rows 1911; WaK_Obj14b',
  wakids_obj2a STRING COMMENT 'src rows 1912; WaK_Obj2a',
  wakids_obj2b STRING COMMENT 'src rows 1913; WaK_Obj2b',
  wakids_obj3a STRING COMMENT 'src rows 1914; WaK_Obj3a',
  wakids_obj3b STRING COMMENT 'src rows 1915; WaK_Obj3b',
  wakids_obj8a STRING COMMENT 'src rows 1916; WaK_Obj8a',
  wakids_has_iep STRING COMMENT 'src rows 1917; WaK_HasIEP',
  wakids_free_lunch STRING COMMENT 'src rows 1919; WaK_FreeLunch',
  wakids_class_id STRING COMMENT 'src rows 1926; WaK_ClassID',
  wakids_special_ed STRING COMMENT 'src rows 1927; WaK_SpecialEd',
  wakids_bilingual STRING COMMENT 'src rows 1928; WaK_Bilingual',
  wakids_numof_domains_ready4_kindergar DECIMAL(12,3) COMMENT 'src rows 1930; WaK_NumofDomainsReady4Kindergar',
  age_grade STRING COMMENT 'src rows 1951; AgeGrade'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ASSESSMENT_PS_ADMISSION_TEST_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  act_composite_score DECIMAL(12,3) COMMENT 'src rows 1953; ACT_composite_score',
  act_english_score DECIMAL(12,3) COMMENT 'src rows 1954; ACT_english_score',
  act_math_score DECIMAL(12,3) COMMENT 'src rows 1955; ACT_math_score',
  act_reading_score DECIMAL(12,3) COMMENT 'src rows 1956; ACT_reading_score',
  act_science_score DECIMAL(12,3) COMMENT 'src rows 1957; ACT_science_score',
  act_writing_score DECIMAL(12,3) COMMENT 'src rows 1958; ACT_writing_score',
  sat_date_taken DATE COMMENT 'src rows 1982; SAT_date_taken',
  sat_math_section_score DECIMAL(12,3) COMMENT 'src rows 1984; SAT_math_section_score',
  sat_critical_reading_score DECIMAL(12,3) COMMENT 'src rows 1985; SAT_critical_reading_score',
  sat_math_score DECIMAL(12,3) COMMENT 'src rows 1986; SAT_math_score',
  sat_math_sub_section_score DECIMAL(12,3) COMMENT 'src rows 1987; SAT_math_sub_section_score',
  sat_reading_sub_section_score DECIMAL(12,3) COMMENT 'src rows 1988; SAT_reading_sub_section_score',
  sat_reading_writing_section_score DECIMAL(12,3) COMMENT 'src rows 1989; SAT_reading_writing_section_score',
  sat_writing_language_sub_section_score DECIMAL(12,3) COMMENT 'src rows 1990; SAT_writing_language_sub_section_score',
  sat_writing_score DECIMAL(12,3) COMMENT 'src rows 1992; SAT_writing_score'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ASSESSMENT_PS_EPP_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_year STRING COMMENT 'src rows 428; year',
  source_academic_year STRING COMMENT 'src rows 429; academic_year',
  prog_type STRING COMMENT 'src rows 432; prog_type',
  cred_role STRING COMMENT 'src rows 433; cred_role',
  cred_type STRING COMMENT 'src rows 434; cred_type',
  program_participation_id BIGINT COMMENT 'src rows 435; prog_id',
  program_identifier STRING COMMENT 'src rows 435; prog_id',
  enroll_cat STRING COMMENT 'src rows 436; enroll_cat',
  cbc_status STRING COMMENT 'src rows 444; cbc_status',
  alt_comp_demo1 STRING COMMENT 'src rows 445; alt_comp_demo1',
  alt_comp_demo1_txt STRING COMMENT 'src rows 446; alt_comp_demo1_txt',
  alt_comp_demo2 STRING COMMENT 'src rows 447; alt_comp_demo2',
  alt_comp_demo2_txt STRING COMMENT 'src rows 448; alt_comp_demo2_txt',
  entrance_exam_m STRING COMMENT 'src rows 503; entrance_exam_m',
  exam_stat_m STRING COMMENT 'src rows 505; exam_stat_m',
  alt_comp_demo_txt_m STRING COMMENT 'src rows 506; alt_comp_demo_txt_m',
  entrance_exam_r STRING COMMENT 'src rows 507; entrance_exam_r',
  exam_stat_r STRING COMMENT 'src rows 509; exam_stat_r',
  alt_comp_demo_txt_r STRING COMMENT 'src rows 510; alt_comp_demo_txt_r',
  entrance_exam_w STRING COMMENT 'src rows 511; entrance_exam_w',
  exam_stat_w STRING COMMENT 'src rows 513; exam_stat_w',
  alt_comp_demo_txt_w STRING COMMENT 'src rows 514; alt_comp_demo_txt_w',
  entrance_exam1 STRING COMMENT 'src rows 515; entrance_exam1',
  basic_skills_area1 STRING COMMENT 'src rows 516; basic_skills_area1',
  exam_stat1 STRING COMMENT 'src rows 518; exam_stat1',
  alt_comp_demo_txt1 STRING COMMENT 'src rows 519; alt_comp_demo_txt1',
  entrance_exam2 STRING COMMENT 'src rows 520; entrance_exam2',
  basic_skills_area2 STRING COMMENT 'src rows 521; basic_skills_area2',
  exam_stat2 STRING COMMENT 'src rows 523; exam_stat2',
  alt_comp_demo_txt2 STRING COMMENT 'src rows 524; alt_comp_demo_txt2',
  entrance_exam3 STRING COMMENT 'src rows 525; entrance_exam3',
  basic_skills_area3 STRING COMMENT 'src rows 526; basic_skills_area3',
  exam_stat3 STRING COMMENT 'src rows 528; exam_stat3',
  alt_comp_demo_txt3 STRING COMMENT 'src rows 529; alt_comp_demo_txt3'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.DISCIPLINE (
  discipline_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  discipline_record_scope STRING COMMENT 'src rows 997,1143; SchoolYear',
  academic_period_id BIGINT COMMENT 'src rows 997,1143; SchoolYear',
  source_school_year STRING COMMENT 'src rows 997,1143; SchoolYear',
  lea_org_id BIGINT COMMENT 'src rows 998,1002,1144; DistrictCode, DistrictOrgID',
  resident_lea_org_id BIGINT COMMENT 'src rows 999; ResidentDistrictOrgID',
  school_org_id BIGINT COMMENT 'src rows 1000,1001,1004,1146,1148; LocationID, LocationId, SchoolCode, SchoolOrgID',
  primary_school_flag BOOLEAN COMMENT 'src rows 1006; PrimarySchoolFlag',
  person_id BIGINT COMMENT 'src rows 1007,1008,1149,1150; DistrictStudentCode, DistrictStudentID, SSID',
  incident_identifier STRING COMMENT 'src rows 1009,1151; IncidentId',
  incident_date DATE COMMENT 'src rows 1010,1152; IncidentDate',
  incident_behavior_code STRING COMMENT 'src rows 1012,1154; BehaviorCode, BehaviorTypeCode',
  disciplinary_action_taken_code STRING COMMENT 'src rows 1015,1163; ExclusionaryActionTypeCode, InterventionCode',
  disciplinary_action_start_date DATE COMMENT 'src rows 1017,1166; ExclusionaryActionDate, InterventionDate',
  duration_of_disciplinary_action DECIMAL(12,3) COMMENT 'src rows 1018,1167; ExclusionaryActionDaysDuration, InterventionDays',
  weapon_type_code STRING COMMENT 'src rows 1020,1159; WeaponCode, WeaponTypeCode',
  idea_interim_alternative_setting_code BOOLEAN COMMENT 'src rows 1022,1169; IsInIAES, SPEDInterimAlternativeEdSetting',
  source_submit_date DATE COMMENT 'src rows 1023,1188; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1024,1189; ExtractDate',
  is_emergency_expulsion BOOLEAN COMMENT 'src rows 1025; IsEmergencyExpulsion',
  num_ee_conversion_days DECIMAL(12,3) COMMENT 'src rows 1026; NumEEConversionDays',
  academic_services_code STRING COMMENT 'src rows 1030,1171; AcademicServicesCode, AcademicServicesTypeCode',
  behavior_services_code STRING COMMENT 'src rows 1031,1174; BehaviorServicesCode, BehaviorServicesTypeCode',
  petition_for_readmission_submitted_date STRING COMMENT 'src rows 1034,1176; PetitionForReAdmitSubmittedDate, PetitionForReadmissionSubmittedd',
  petition_for_readmission_granted_date DECIMAL(14,2) COMMENT 'src rows 1035,1177; PetitionForReAdmitGrantedDate, PetitionForReadmissionGrantedDat',
  petition_time_frame_code STRING COMMENT 'src rows 1036,1179; PetitionTimeFrameCode, PetitiontoExceedMorethanOneYear',
  reengagement_meeting_date DATE COMMENT 'src rows 1038,1184; DateReengagementMeetingHeld, ReengagementMeetingDate',
  reengagement_plan_code STRING COMMENT 'src rows 1040,1182; ReengagementPlanCode, ReengagementPlanTypeCode',
  appeal_code STRING COMMENT 'src rows 1043,1186; AppealCode, AppealTypeCode',
  total_exclusionary_time STRING COMMENT 'src rows 1168; TotalExclusionaryTime',
  staff_involvement_status_code STRING COMMENT 'src rows 1190; StaffInvolvementStatusCode',
  staff_involvement_type_code STRING COMMENT 'src rows 1192; StaffInvolvementTypeCode',
  staff_involvement_outcome_code STRING COMMENT 'src rows 1194; StaffInvolvementOutcomeCode',
  interpreter_request_reengag_meeting_type_code STRING COMMENT 'src rows 1197; InterpreterRequestReengagMeetingTypeCode'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Single-sector conformed family table (legacy + current files) | Grain: One row per person x LEA x incident x disciplinary/exclusionary action'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.DISCIPLINE_SECONDARY_BEHAVIOR (
  discipline_secondary_behavior_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  incident_behavior_code STRING COMMENT 'src rows 1027,1157; OtherBehaviorCodes, OtherBehaviorIds'
)
USING DELTA
COMMENT 'Multi-valued secondary behaviors | Grain: One row per discipline row x secondary behavior code'
TBLPROPERTIES ('p20w.table_type' = 'CHILD_FACT', 'p20w.scd' = 'n/a', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.EDUCATOR_CREDENTIAL (
  educator_credential_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  person_id BIGINT COMMENT 'src rows 530,531,533; CertificateNumber, EducatorID, PersonnelID',
  professional_certificate_or_license_number STRING COMMENT 'src rows 533; CertificateNumber',
  certificate_code STRING COMMENT 'src rows 543; CertificateCode',
  certificate_status_code STRING COMMENT 'src rows 544; CertificateStatusCode',
  certificate_credential_source_code STRING COMMENT 'src rows 545; CertificateCredentialSourceCode',
  recommending_org_org_id BIGINT COMMENT 'src rows 546; CertificateRecommendingAgencyCode',
  certificate_recommendation_date DATE COMMENT 'src rows 548; CertificateRecommendationDate',
  issue_source_org_org_id BIGINT COMMENT 'src rows 549,561; CertificateIssueSourceCode, EndorsementIssueSourceCode',
  certificate_original_issue_date DATE COMMENT 'src rows 550; CertificateOriginalIssueDate',
  certificate_issue_date DATE COMMENT 'src rows 551; CertificateIssueDate',
  credential_award_start_date DATE COMMENT 'src rows 552,564; CertificateEffectiveDate, EndorsementEffectiveDate',
  credential_expiration_date DATE COMMENT 'src rows 553,565; CertificateExpireDate, EndorsementExpireDate',
  certificate_renew_date DATE COMMENT 'src rows 554; CertificateRenewDate',
  endorsement_code STRING COMMENT 'src rows 555; EndorsementCode',
  grade_code STRING COMMENT 'src rows 556; GradeCode',
  endorsement_status_code STRING COMMENT 'src rows 557; EndorsementStatusCode',
  endorsement_credential_rule_code STRING COMMENT 'src rows 558; EndorsementCredentialRuleCode',
  endorsement_credential_source_code STRING COMMENT 'src rows 559; EndorsementCredentialSourceCode',
  endorsement_recommendation_date DATE COMMENT 'src rows 560; EndorsementRecommendationDate',
  endorsement_original_issue_date DATE COMMENT 'src rows 562; EndorsementOriginalIssueDate',
  endorsement_issue_date DATE COMMENT 'src rows 563; EndorsementIssueDate',
  endorsement_renew_date DATE COMMENT 'src rows 566; EndorsementRenewDate'
)
USING DELTA
CLUSTER BY (person_id)
COMMENT 'Professional educator certification | Grain: One row per person x certificate x endorsement'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'Current-state license record; status/expiry changes tracked Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.EDUCATOR_YEAR_STATUS (
  educator_year_status_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  academic_period_id BIGINT COMMENT 'src rows 620; SchoolYearCode',
  source_school_year_code STRING COMMENT 'src rows 620; SchoolYearCode',
  lea_org_id BIGINT COMMENT 'src rows 621; DistrictOrganizationId',
  school_org_id BIGINT COMMENT 'src rows 622; SchoolOrganizationId',
  person_id BIGINT COMMENT 'src rows 623,624,625; CertificateNumber, EducatorID, PersonnelId',
  highest_degree STRING COMMENT 'src rows 632; HighestDegree',
  years_of_prior_teaching_experience DECIMAL(12,3) COMMENT 'src rows 633; ReportedExperience',
  calculated_experience DECIMAL(12,3) COMMENT 'src rows 634; CalculatedExperience',
  is_paraeducator BOOLEAN COMMENT 'src rows 635; IsParaeducator',
  is_teacher BOOLEAN COMMENT 'src rows 636; IsTeacher',
  is_principal BOOLEAN COMMENT 'src rows 637; IsPrincipal',
  is_other_school_leader BOOLEAN COMMENT 'src rows 638; IsOtherSchoolLeader',
  is_esa BOOLEAN COMMENT 'src rows 639; IsESA',
  is_student_support BOOLEAN COMMENT 'src rows 640; IsStudentSupport',
  data_source_id STRING COMMENT 'src rows 641; DataSourceId',
  is_late_hire BOOLEAN COMMENT 'src rows 642; IsLateHire',
  is_nbct BOOLEAN COMMENT 'src rows 643; IsNBCT',
  content_area_id STRING COMMENT 'src rows 644; ContentAreaId',
  content_area_name STRING COMMENT 'src rows 645; ContentAreaName',
  grade_level STRING COMMENT 'src rows 646; GradeLevel',
  is_new_hire_school STRING COMMENT 'src rows 647; IsNewHireSchool',
  is_new_hire_district STRING COMMENT 'src rows 648; IsNewHireDistrict',
  is_new_hire_state STRING COMMENT 'src rows 649; IsNewHireState',
  is_stayer BOOLEAN COMMENT 'src rows 650; IsStayer',
  is_stayer_in_grade BOOLEAN COMMENT 'src rows 651; IsStayerInGrade',
  is_stayer_in_content BOOLEAN COMMENT 'src rows 652; IsStayerInContent',
  is_mover_in BOOLEAN COMMENT 'src rows 653; IsMoverIn',
  is_mover_out BOOLEAN COMMENT 'src rows 654; IsMoverOut',
  is_returner_in_school BOOLEAN COMMENT 'src rows 656; IsReturnerInSchool',
  is_returner_in_district BOOLEAN COMMENT 'src rows 657; IsReturnerInDistrict',
  is_returner_out BOOLEAN COMMENT 'src rows 658; IsReturnerOut',
  is_exiter BOOLEAN COMMENT 'src rows 659; IsExiter',
  is_role_change BOOLEAN COMMENT 'src rows 660; IsRoleChange',
  source_data_as_of STRING COMMENT 'src rows 661; DataAsOf'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Derived retention/mobility statuses | Grain: One row per person x school x school year'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.EMPLOYER_QUARTER_PROFILE (
  employer_quarter_profile_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  academic_period_id BIGINT COMMENT 'src rows 664,665; Quarter, Year',
  source_year STRING COMMENT 'src rows 664; Year',
  source_quarter STRING COMMENT 'src rows 665; Quarter',
  employer_org_id BIGINT COMMENT 'src rows 667; UI Account number',
  employer_reporting_unit_org_id BIGINT COMMENT 'src rows 668; Reporting Unit Number (RUN)',
  ces_indicator STRING COMMENT 'src rows 712; CES Indicator',
  ars_response_code STRING COMMENT 'src rows 713; ARS Response Code',
  ars_refile_year STRING COMMENT 'src rows 714; ARS Refile Year',
  ars_verification_year STRING COMMENT 'src rows 717; ARS Verification Year',
  mwr_mail_indicator STRING COMMENT 'src rows 720; MWR Mail Indicator',
  data_source STRING COMMENT 'src rows 722; Data Source',
  first_month_employment STRING COMMENT 'src rows 733; First Month Employment',
  first_month_employment_indicator STRING COMMENT 'src rows 734; First Month Employment Indicator',
  second_month_employment STRING COMMENT 'src rows 735; Second Month Employment',
  second_month_employment_indicator STRING COMMENT 'src rows 736; Second Month Employment Indicator',
  third_month_employment STRING COMMENT 'src rows 737; Third Month Employment',
  third_month_employment_indicator STRING COMMENT 'src rows 738; Third Month Employment Indicator',
  total_wages DECIMAL(14,2) COMMENT 'src rows 739; Total Wages',
  total_wage_indicator STRING COMMENT 'src rows 740; Total Wage Indicator',
  taxable_wages DECIMAL(14,2) COMMENT 'src rows 741; Taxable Wages',
  contributions_due DECIMAL(14,2) COMMENT 'src rows 742; Contributions Due',
  reporting_change_indicator STRING COMMENT 'src rows 745; Reporting Change Indicator',
  first_comment_code STRING COMMENT 'src rows 746; First Comment Code',
  second_comment_code STRING COMMENT 'src rows 747; Second Comment Code',
  third_comment_code STRING COMMENT 'src rows 748; Third Comment Code',
  narrative_comment STRING COMMENT 'src rows 749; Narrative Comment',
  collection_mode_indicator STRING COMMENT 'src rows 750; Collection Mode Indicator',
  economic_code_change_indicator_ecci STRING COMMENT 'src rows 751; Economic Code Change Indicator (ECCI)'
)
USING DELTA
CLUSTER BY (academic_period_id)
COMMENT 'QCEW establishment employment and wages | Grain: One row per employer reporting unit x calendar quarter'
TBLPROPERTIES ('p20w.table_type' = 'PERIODIC_SNAPSHOT', 'p20w.scd' = 'n/a (periodic snapshot)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ENROLLMENT (
  enrollment_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  period_type STRING COMMENT 'SCHOOL_YEAR / QUARTER / TERM / PROGRAM_YEAR / CALENDAR_MONTH / NSC_REPORTED_PERIOD / REGISTRATION_SPELL',
  sector STRING COMMENT 'EL / K12 / PS / APPR',
  academic_period_id BIGINT COMMENT 'src rows 117,222,282,1045,2043,2078,2176,2177,2423,2437; ClassScheduleId, MonthOfService, ProgramYear, QUARTER, STRM, SchoolYear, YEAR, YRQ, academic_year, term',
  el_site_org_id BIGINT COMMENT 'src rows 117,231; ClassScheduleId, SiteCodeAlpha',
  enrollment_entry_date DATE COMMENT 'src rows 118,194,199,814,1065,2121; ActualStartDate, DateEnrolledinSchool, EnrollmentDate, Enrollment_Begin_Date, FirstServiceDate, Registration Date',
  enrollment_exit_date DATE COMMENT 'src rows 119,196,816,1066,2122; DateExitedSchool, Enrollment_End_Date, ExitServiceDate, LastDateAttended, Status Date',
  person_id BIGINT COMMENT 'src rows 180,276,804,1054,1055,2075,2094,2243,2249,2420; Apprentice Id, ChildKey, DW_KEY, DistrictStudentID, EMPLID, SID, SSID, TokenID, UniqueSRIdentifer, student_OFM',
  el_contractor_org_id BIGINT COMMENT 'src rows 181; Contractor',
  el_provider_org_id BIGINT COMMENT 'src rows 274; providernumber',
  household_person_id BIGINT COMMENT 'src rows 279; CaseNumber',
  apprenticeship_sponsor_org_id BIGINT COMMENT 'src rows 809; Program Id',
  lea_org_id BIGINT COMMENT 'src rows 1046; DistrictCode',
  resident_lea_org_id BIGINT COMMENT 'src rows 1048; ResidentDistrictCode',
  school_org_id BIGINT COMMENT 'src rows 1050,1052; LocationID, SchoolCode',
  enrollment_segment_key DATE COMMENT 'src rows 1065; DateEnrolledinSchool',
  ps_campus_org_id BIGINT COMMENT 'src rows 2045; campus',
  ps_institution_org_id BIGINT COMMENT 'src rows 2063,2116,2332,2360; COLLEGE, College_Code_Branch, INSTITUTION, institution',
  parent_ps_institution_org_id BIGINT COMMENT 'src rows 2144; Parent_College_Code',
  last_high_school_org_id BIGINT COMMENT 'src rows 2335; HI_SCHL',
  previous_ps_institution_org_id BIGINT COMMENT 'src rows 2380; PREV_COL_1'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Periodic enrollment across EL, K-12, PS, Apprenticeship | Grain: One row per person x organization x reporting period (school year / term / program year / month / registration spell) x enrollment segment'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ENROLLMENT_APPR_LNI_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  program_id BIGINT COMMENT 'src rows 809; Program Id',
  current_status STRING COMMENT 'src rows 815; Current Status',
  status_date DATE COMMENT 'src rows 816; Status Date',
  previous_credit DECIMAL(12,3) COMMENT 'src rows 817; Previous Credit',
  additional_credit DECIMAL(12,3) COMMENT 'src rows 818; Additional Credit',
  ojt_work_hours DECIMAL(12,3) COMMENT 'src rows 819; OJTWork Hours',
  ojt_final_hours DECIMAL(12,3) COMMENT 'src rows 820; OJTFinal Hours',
  total_ojt_hours DECIMAL(12,3) COMMENT 'src rows 821; Total OJTHours',
  anticipated_ojt_hours DECIMAL(12,3) COMMENT 'src rows 822; Anticipated OJTHours',
  ojt_percentage DECIMAL(12,3) COMMENT 'src rows 823; OJTPercentage',
  rsi_credited_hours DECIMAL(12,3) COMMENT 'src rows 825; RSICredited Hours',
  rsi_reported_hours DECIMAL(12,3) COMMENT 'src rows 826; RSIReported Hours',
  total_rsi_hours DECIMAL(12,3) COMMENT 'src rows 827; Total RSIHours',
  anticipated_rsi_hours DECIMAL(12,3) COMMENT 'src rows 828; Anticipated RSIHours',
  rsi_percentage DECIMAL(12,3) COMMENT 'src rows 829; RSIPercentage',
  quarter_count DECIMAL(12,3) COMMENT 'src rows 831; Quarter Count',
  rsi_reported_quarter_count DECIMAL(12,3) COMMENT 'src rows 832; RSIReported Quarter Count',
  probation_start_date DATE COMMENT 'src rows 833; Probation Start Date',
  probation_end_date DATE COMMENT 'src rows 834; Probation End Date',
  years_in_program STRING COMMENT 'src rows 835; Years In Program',
  anticipated_completion_date DATE COMMENT 'src rows 836; Anticipated Completion Date',
  initial_step_number STRING COMMENT 'src rows 837; Initial Step Number',
  initial_step_eff_date DATE COMMENT 'src rows 838; Initial Step Eff Date',
  current_step_eff_date DATE COMMENT 'src rows 839; Current Step Eff Date',
  transfer_date DATE COMMENT 'src rows 840; Transfer Date',
  age DECIMAL(12,3) COMMENT 'src rows 842; Age',
  city STRING COMMENT 'src rows 848; City',
  state STRING COMMENT 'src rows 849; State',
  zip_code STRING COMMENT 'src rows 850; Zip Code',
  military_veteran_status_indicator STRING COMMENT 'src rows 853; Veteran',
  education STRING COMMENT 'src rows 854; Education',
  direct_entry_flag STRING COMMENT 'src rows 855; Direct Entry Flag',
  other_license STRING COMMENT 'src rows 856; Other License'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ENROLLMENT_EL_ELMS_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  child_class_id STRING COMMENT 'src rows 116; ChildClassId',
  course_section_id BIGINT COMMENT 'src rows 117; ClassScheduleId'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ENROLLMENT_EL_HIST_ECEAP_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  county DECIMAL(12,3) COMMENT 'src rows 183; County',
  enrollment_date DATE COMMENT 'src rows 194; EnrollmentDate',
  first_service_date DATE COMMENT 'src rows 199; FirstServiceDate',
  living_zip_derived STRING COMMENT 'src rows 211; LivingZip_derived',
  source_program_year STRING COMMENT 'src rows 222; ProgramYear',
  source_record_id STRING COMMENT 'src rows 225; RecordID',
  school_district STRING COMMENT 'src rows 227; SchoolDistrict'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ENROLLMENT_EL_SUBSIDY_SERVICE_LINE (
  enrollment_el_subsidy_service_line_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  auth_number STRING COMMENT 'src rows 280; AuthNumber',
  auth_line STRING COMMENT 'src rows 281; AuthLine',
  month_of_service STRING COMMENT 'src rows 282; MonthOfService',
  service_code STRING COMMENT 'src rows 283; ServiceCode',
  service_name STRING COMMENT 'src rows 284; ServiceName',
  service_unit_type STRING COMMENT 'src rows 285; ServiceUnitType'
)
USING DELTA
COMMENT 'Subsidy authorization/service lines under monthly enrollment | Grain: One row per subsidy enrollment month x authorization x authorization line'
TBLPROPERTIES ('p20w.table_type' = 'CHILD_FACT', 'p20w.scd' = 'n/a', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ENROLLMENT_K12_CEDARS_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year STRING COMMENT 'src rows 1045; SchoolYear',
  primary_school_flag BOOLEAN COMMENT 'src rows 1053; PrimarySchoolFlag',
  grade_level_sort_order STRING COMMENT 'src rows 1061; GradeLevelSortOrder',
  grade_level STRING COMMENT 'src rows 1062; GradeLevel',
  date_enrolledin_district DATE COMMENT 'src rows 1063; DateEnrolledinDistrict',
  date_exited_district DATE COMMENT 'src rows 1064; DateExitedDistrict',
  exit_or_withdrawal_type_code STRING COMMENT 'src rows 1067; WithdrawalCode',
  schoolchoicetype_id STRING COMMENT 'src rows 1069; SchoolchoicetypeID',
  zip_code STRING COMMENT 'src rows 1073; ZipCode',
  grad_req_year STRING COMMENT 'src rows 1080; GradReqYear',
  expected_grad_year STRING COMMENT 'src rows 1081; ExpectedGradYear',
  grade_point_average_cumulative DECIMAL(12,3) COMMENT 'src rows 1082; CumulativeGPA',
  credits_attempted_cumulative DECIMAL(12,3) COMMENT 'src rows 1083; CumulativeCreditsAttempted',
  credits_earned_cumulative DECIMAL(12,3) COMMENT 'src rows 1084; CumulativeCreditsEarned',
  number_of_days_in_attendance DECIMAL(12,3) COMMENT 'src rows 1085; NumDaysPresent',
  primary_disability_type_code STRING COMMENT 'src rows 1086; DisabilityCode',
  disability_flag BOOLEAN COMMENT 'src rows 1087; DisabilityFlag',
  apprvd_private_school_attend_part_time_code STRING COMMENT 'src rows 1089; ApprvdPrivateSchoolAttendPartTimeCode',
  apprvd_private_school_attend_part_time_flag BOOLEAN COMMENT 'src rows 1090; ApprvdPrivateSchoolAttendPartTimeFlag',
  home_based_attend_part_time_code STRING COMMENT 'src rows 1092; HomeBasedAttendPartTimeCode',
  home_based_attend_part_time_flag BOOLEAN COMMENT 'src rows 1093; HomeBasedAttendPartTimeFlag',
  f1_visa_foreign_exchg_flag STRING COMMENT 'src rows 1095; F1VisaForeignExchgFlag',
  homeless_primary_nighttime_residence_code STRING COMMENT 'src rows 1096; HomelessCode',
  homelessness_status BOOLEAN COMMENT 'src rows 1097; HomelessFlag',
  is_student_immigrant BOOLEAN COMMENT 'src rows 1099; IsStudentImmigrant',
  first_entry_date_into_us_school DATE COMMENT 'src rows 1101,1325; InitialUSAPlacementDate, InitialUSPlacementDate',
  number_of_months_us_attendance DECIMAL(12,3) COMMENT 'src rows 1102,1326; NumMonthsUSAttendance',
  number_of_months_non_us_formal_education DECIMAL(12,3) COMMENT 'src rows 1103,1327; NumMonthsNonUSEducation, NumMonthsNonUSFormalEducation',
  source_submit_date DATE COMMENT 'src rows 1104; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1105; ExtractDate',
  confirmed_transfer_in_type_id STRING COMMENT 'src rows 1110; ConfirmedTransferInTypeID',
  military_connected_student_indicator_code STRING COMMENT 'src rows 1111; MilitaryParentorGuardianCD',
  asvab_test_status_code STRING COMMENT 'src rows 1114; ASVABTestStatusCode',
  asvab_test_score DECIMAL(12,3) COMMENT 'src rows 1116; ASVABTestScore',
  asvab_test_school_year STRING COMMENT 'src rows 1117; ASVABTestSchoolYear',
  credit_waiver_code DECIMAL(14,2) COMMENT 'src rows 1118; CreditWaiverCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ENROLLMENT_PS_NSC_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  status STRING COMMENT 'src rows 2095; Status',
  nsc_effective_date DATE COMMENT 'src rows 2096; NSCEffectiveDate',
  postsecondary_enrollment_status STRING COMMENT 'src rows 2123; Enrollment_Status',
  college_sequence STRING COMMENT 'src rows 2128; College_Sequence',
  class_level STRING COMMENT 'src rows 2130; Class_Level',
  enrollment_cip_1 STRING COMMENT 'src rows 2131; Enrollment_CIP_1',
  enrollment_major_1 STRING COMMENT 'src rows 2132; Enrollment_Major_1',
  enrollment_cip_2 STRING COMMENT 'src rows 2133; Enrollment_CIP_2',
  enrollment_major_2 STRING COMMENT 'src rows 2134; Enrollment_Major_2'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ENROLLMENT_PS_PCHEES_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_academic_year STRING COMMENT 'src rows 2043; academic_year',
  class_standing STRING COMMENT 'src rows 2046; class_standing',
  concentration DECIMAL(12,3) COMMENT 'src rows 2047; concentration',
  first_major_program_id BIGINT COMMENT 'src rows 2047,2077; concentration, submission_sequence',
  grade_point_average_cumulative_institutional DECIMAL(12,3) COMMENT 'src rows 2048; cumulative_institutional_GPA_key',
  cumulative_overall_gpa_key DECIMAL(12,3) COMMENT 'src rows 2049; cumulative_overall_GPA_key',
  disability_status STRING COMMENT 'src rows 2050; disability_status',
  fee_exemption_type_1 STRING COMMENT 'src rows 2051; fee_exemption_type_1',
  fee_exemption_type_2 STRING COMMENT 'src rows 2052; fee_exemption_type_2',
  fee_exemption_type_3 STRING COMMENT 'src rows 2053; fee_exemption_type_3',
  fee_payment_type STRING COMMENT 'src rows 2054; fee_payment_type',
  fee_waiver_type_1 DECIMAL(14,2) COMMENT 'src rows 2055; fee_waiver_type_1',
  fee_waiver_type_2 DECIMAL(14,2) COMMENT 'src rows 2056; fee_waiver_type_2',
  fee_waiver_type_3 DECIMAL(14,2) COMMENT 'src rows 2057; fee_waiver_type_3',
  pell_grant_status DECIMAL(14,2) COMMENT 'src rows 2066; pell_grant_status',
  primary_site STRING COMMENT 'src rows 2067; primary_site',
  source_record_number STRING COMMENT 'src rows 2073; record_number',
  submission_sequence STRING COMMENT 'src rows 2077; submission_sequence',
  source_term STRING COMMENT 'src rows 2078; term',
  us_immigration_status DECIMAL(12,3) COMMENT 'src rows 2079; US_immigration_status',
  grade_point_average DECIMAL(12,3) COMMENT 'src rows 2080; term_GPA_key',
  veteran_benefits_type STRING COMMENT 'src rows 2081; veteran_benefits_type',
  veteran_status STRING COMMENT 'src rows 2082; veteran_status',
  wa_residency_status STRING COMMENT 'src rows 2083; WA_residency_status'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.ENROLLMENT_PS_SBCTC_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_quarter STRING COMMENT 'src rows 2176; QUARTER',
  source_year STRING COMMENT 'src rows 2177; YEAR',
  acad_disad_ind BOOLEAN COMMENT 'src rows 2182; ACAD_DISAD_IND',
  active_duty_parent STRING COMMENT 'src rows 2183; ACTIVE_DUTY_PARENT',
  age_grp_primary STRING COMMENT 'src rows 2184; AGE_GRP_PRIMARY',
  age_grp_secondary STRING COMMENT 'src rows 2185; AGE_GRP_SECONDARY',
  credits_contract DECIMAL(12,3) COMMENT 'src rows 2223; CREDITS_CONTRACT',
  credits_state DECIMAL(12,3) COMMENT 'src rows 2225; CREDITS_STATE',
  credits_student DECIMAL(12,3) COMMENT 'src rows 2226; CREDITS_STUDENT',
  credits_enrolled_total DECIMAL(12,3) COMMENT 'src rows 2227; CREDITS_TOTAL',
  cum_clvl_cr_earned STRING COMMENT 'src rows 2228; CUM_CLVL_CR_EARNED',
  credits_earned_cumulative DECIMAL(12,3) COMMENT 'src rows 2229; CUM_CREDITS_EARNED',
  cum_hours_earned DECIMAL(12,3) COMMENT 'src rows 2230; CUM_HOURS_EARNED',
  disability STRING COMMENT 'src rows 2239; DISABILITY',
  e_learning_code STRING COMMENT 'src rows 2246; eLEARNING_CODE',
  e_learning_ind STRING COMMENT 'src rows 2247; eLEARNING_IND',
  employment_status STRING COMMENT 'src rows 2262; EMPLOYMENT_STATUS',
  excl_bs STRING COMMENT 'src rows 2280; EXCL_BS',
  excl_ll STRING COMMENT 'src rows 2282; EXCL_LL',
  first_system_yrq STRING COMMENT 'src rows 2284; FIRST_SYSTEM_YRQ',
  ftes_contract DECIMAL(12,3) COMMENT 'src rows 2302; FTES_CONTRACT',
  ftes_state DECIMAL(12,3) COMMENT 'src rows 2305; FTES_STATE',
  ftes_student DECIMAL(12,3) COMMENT 'src rows 2307; FTES_STUDENT',
  ftes_total DECIMAL(12,3) COMMENT 'src rows 2310; FTES_TOTAL',
  enrollment_intensity_code STRING COMMENT 'src rows 2312; FULL_PART_TIME_IND',
  gpa_clvl DECIMAL(12,3) COMMENT 'src rows 2313; GPA_CLVL',
  grade_point_average_cumulative DECIMAL(12,3) COMMENT 'src rows 2314; GPA_CUM',
  gpa_qtr_cr DECIMAL(12,3) COMMENT 'src rows 2316; GPA_QTR_CR',
  gpa_qtr_hr DECIMAL(12,3) COMMENT 'src rows 2317; GPA_QTR_HR',
  age DECIMAL(12,3) COMMENT 'src rows 2319; AGE',
  degree_or_certificate_seeking_student STRING COMMENT 'src rows 2320,2341; AWARD_SEEK, DEGREE_SEEK',
  kind_of_student STRING COMMENT 'src rows 2323; KIND_OF_STUDENT',
  classification_of_instructional_program_code STRING COMMENT 'src rows 2324; PROGRAM_CIP',
  health_lim STRING COMMENT 'src rows 2328; HEALTH_LIM',
  united_states_citizenship_status STRING COMMENT 'src rows 2331; CITZ_STAT',
  credit_level DECIMAL(12,3) COMMENT 'src rows 2333; CREDIT_LEVEL',
  hi_schl_county DECIMAL(12,3) COMMENT 'src rows 2336; HI_SCHL_COUNTY',
  hi_schl_grad STRING COMMENT 'src rows 2337; HI_SCHL_GRAD',
  hi_schl_last_yr STRING COMMENT 'src rows 2338; HI_SCHL_LAST_YR',
  home_cc_dist STRING COMMENT 'src rows 2342; HOME_CC_DIST',
  dual_enroll STRING COMMENT 'src rows 2343; DUAL_ENROLL',
  home_dist STRING COMMENT 'src rows 2344; HOME_DIST',
  econ_disad_ind STRING COMMENT 'src rows 2345; ECON_DISAD_IND',
  hours_contract DECIMAL(12,3) COMMENT 'src rows 2346; HOURS_CONTRACT',
  hours_state DECIMAL(12,3) COMMENT 'src rows 2347; HOURS_STATE',
  hours_student DECIMAL(12,3) COMMENT 'src rows 2348; HOURS_STUDENT',
  hours_total DECIMAL(12,3) COMMENT 'src rows 2349; HOURS_TOTAL',
  housing_insecurity STRING COMMENT 'src rows 2350; HOUSING_INSECURITY',
  fam_stat STRING COMMENT 'src rows 2353; FAM_STAT',
  fee_pay STRING COMMENT 'src rows 2354; FEE_PAY',
  first_generation_college_student DECIMAL(12,3) COMMENT 'src rows 2355; FIRST_GENERATION',
  instit_category_indicator STRING COMMENT 'src rows 2356; INSTIT_CATEGORY_INDICATOR',
  fund_source_indicator BOOLEAN COMMENT 'src rows 2362; FUND_SOURCE_INDICATOR',
  fund_source_priority STRING COMMENT 'src rows 2363; FUND_SOURCE_PRIORITY',
  fund_source_priority_category STRING COMMENT 'src rows 2364; FUND_SOURCE_PRIORITY_CATEGORY',
  grade_point_average DECIMAL(12,3) COMMENT 'src rows 2365; GPA',
  international_student STRING COMMENT 'src rows 2370; INTERNATIONAL_STUDENT',
  lim_engl_ind STRING COMMENT 'src rows 2375; LIM_ENGL_IND',
  mis_stat STRING COMMENT 'src rows 2376; MIS_STAT',
  perkins_foster_care STRING COMMENT 'src rows 2379; PERKINS_FOSTER_CARE',
  intent STRING COMMENT 'src rows 2384; INTENT',
  recent_hi_schl STRING COMMENT 'src rows 2388; RECENT_HI_SCHL',
  plan_attnd STRING COMMENT 'src rows 2389; PLAN_ATTND',
  plan_work STRING COMMENT 'src rows 2390; PLAN_WORK',
  prior_educ STRING COMMENT 'src rows 2393; PRIOR_EDUC',
  program_code STRING COMMENT 'src rows 2394; PROGRAM_CODE',
  purp_attnd STRING COMMENT 'src rows 2395; PURP_ATTND',
  registered_disability STRING COMMENT 'src rows 2402; REGISTERED_DISABILITY',
  residence_country DECIMAL(12,3) COMMENT 'src rows 2403; RESIDENCE_COUNTRY',
  residence_county DECIMAL(12,3) COMMENT 'src rows 2404; RESIDENCE_COUNTY',
  residence_state STRING COMMENT 'src rows 2405; RESIDENCE_STATE',
  residence_zip STRING COMMENT 'src rows 2406; RESIDENCE_ZIP',
  tuition_residency_type STRING COMMENT 'src rows 2407; RESIDENT_STATUS',
  running_start_status STRING COMMENT 'src rows 2408; RUNNING_START_STATUS',
  sda STRING COMMENT 'src rows 2414; SDA',
  source STRING COMMENT 'src rows 2422; SOURCE',
  source_yrq STRING COMMENT 'src rows 2423; YRQ',
  state_start STRING COMMENT 'src rows 2431; STATE_START',
  source_strm STRING COMMENT 'src rows 2437; STRM',
  time_loc_ind STRING COMMENT 'src rows 2456; TIME_LOC_IND',
  time_loc_pri STRING COMMENT 'src rows 2457; TIME_LOC_PRI',
  transfer_ready STRING COMMENT 'src rows 2460; TRANSFER_READY',
  military_veteran_status_indicator STRING COMMENT 'src rows 2464; VET_BENEFITS',
  work_attnd STRING COMMENT 'src rows 2474; WORK_ATTND',
  worker_retraining STRING COMMENT 'src rows 2477; WORKER_RETRAINING',
  yrq_act_start STRING COMMENT 'src rows 2478; YRQ_ACT_START'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.FINANCIAL_AID_AWARD (
  financial_aid_award_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_record_number STRING COMMENT 'src rows 2480; WSACRecordNumber',
  academic_period_id BIGINT COMMENT 'src rows 2481; AwardYear',
  source_award_year STRING COMMENT 'src rows 2481; AwardYear',
  ps_institution_org_id BIGINT COMMENT 'src rows 2482; WSACInstitutionCode',
  person_id BIGINT COMMENT 'src rows 2484,2582,2583; StudentID, WSACSampleId, WSACStudentIdNumber',
  marital_status STRING COMMENT 'src rows 2492; MaritalStatus',
  resident STRING COMMENT 'src rows 2493; Resident',
  student_class STRING COMMENT 'src rows 2494; StudentClass',
  family_income DECIMAL(14,2) COMMENT 'src rows 2502; FamilyIncome',
  family_income_percent_of_mfi DECIMAL(14,2) COMMENT 'src rows 2503; FamilyIncomePercentOfMFI',
  number_of_people_in_household DECIMAL(12,3) COMMENT 'src rows 2504; FamilySize',
  family_in_college STRING COMMENT 'src rows 2505; FamilyInCollege',
  adjusted_family_size DECIMAL(12,3) COMMENT 'src rows 2506; AdjustedFamilySize',
  cost_of_attendance DECIMAL(14,2) COMMENT 'src rows 2507; CostOfAttendance',
  expected_family_contribution DECIMAL(14,2) COMMENT 'src rows 2508; ExpectedFamilyContribution',
  parent_contribution DECIMAL(14,2) COMMENT 'src rows 2509; ParentContribution',
  student_contribution DECIMAL(14,2) COMMENT 'src rows 2510; StudentContribution',
  financial_need DECIMAL(14,2) COMMENT 'src rows 2511; NeedAmount',
  need_duration DECIMAL(12,3) COMMENT 'src rows 2512; NeedDuration',
  dependency_status STRING COMMENT 'src rows 2513; DependencyStatus',
  enrollment_fall STRING COMMENT 'src rows 2514; EnrollmentFall',
  enrollment_winter STRING COMMENT 'src rows 2515; EnrollmentWinter',
  enrollment_spring STRING COMMENT 'src rows 2516; EnrollmentSpring',
  enrollment_summer1 STRING COMMENT 'src rows 2517; EnrollmentSummer1',
  enrollment_summer2 STRING COMMENT 'src rows 2518; EnrollmentSummer2',
  fafsa_on_file STRING COMMENT 'src rows 2519; FAFSAOnFile',
  all_aid_total DECIMAL(14,2) COMMENT 'src rows 2520; AllAidTotal',
  fed_aid_total DECIMAL(14,2) COMMENT 'src rows 2521; FedAidTotal',
  state_aid_total DECIMAL(14,2) COMMENT 'src rows 2522; StateAidTotal',
  inst_aid_total DECIMAL(14,2) COMMENT 'src rows 2523; InstAidTotal',
  other_aid_total DECIMAL(14,2) COMMENT 'src rows 2524; OtherAidTotal',
  grant_aid_total DECIMAL(14,2) COMMENT 'src rows 2525; GrantAidTotal',
  work_aid_total DECIMAL(14,2) COMMENT 'src rows 2526; WorkAidTotal',
  loan_aid_total DECIMAL(14,2) COMMENT 'src rows 2527; LoanAidTotal',
  fed_pell_grant DECIMAL(14,2) COMMENT 'src rows 2528; FedPellGrant',
  fed_seog STRING COMMENT 'src rows 2529; FedSEOG',
  fed_acad_competitiveness_grant_year1 DECIMAL(14,2) COMMENT 'src rows 2530; FedAcadCompetitivenessGrantYear1',
  fed_acad_competitiveness_grant_year2 DECIMAL(14,2) COMMENT 'src rows 2531; FedAcadCompetitivenessGrantYear2',
  fed_smart_grant_year3 DECIMAL(14,2) COMMENT 'src rows 2532; FedSMARTGrantYear3',
  fed_smart_grant_year4 DECIMAL(14,2) COMMENT 'src rows 2533; FedSMARTGrantYear4',
  fed_work_study STRING COMMENT 'src rows 2534; FedWorkStudy',
  fed_perkins_loan DECIMAL(14,2) COMMENT 'src rows 2535; FedPerkinsLoan',
  fed_direct_subsidized_loan DECIMAL(14,2) COMMENT 'src rows 2536; FedDirectSubsidizedLoan',
  fed_direct_unsubsidized_loan DECIMAL(14,2) COMMENT 'src rows 2537; FedDirectUnsubsidizedLoan',
  fed_unsubsidized_loans DECIMAL(14,2) COMMENT 'src rows 2538; FedUnsubsidizedLoans',
  fed_parent_plus_loan DECIMAL(14,2) COMMENT 'src rows 2539; FedParentPLUSLoan',
  fed_grad_plus_loan DECIMAL(14,2) COMMENT 'src rows 2540; FedGradPLUSLoan',
  fed_nursing_scholarships DECIMAL(14,2) COMMENT 'src rows 2541; FedNursingScholarships',
  fed_nursing_health_loans DECIMAL(14,2) COMMENT 'src rows 2542; FedNursingHealthLoans',
  fed_teach_grant DECIMAL(14,2) COMMENT 'src rows 2543; FedTEACHGrant',
  state_washington_college_grant DECIMAL(14,2) COMMENT 'src rows 2544; StateWashingtonCollegeGrant',
  state_need_grant DECIMAL(14,2) COMMENT 'src rows 2545; StateNeedGrant',
  state_college_bound_scholarship DECIMAL(14,2) COMMENT 'src rows 2546; StateCollegeBoundScholarship',
  state_workforce_training STRING COMMENT 'src rows 2547; StateWorkforceTraining',
  state_sbctc_opportunity_grant DECIMAL(14,2) COMMENT 'src rows 2548; StateSBCTCOpportunityGrant',
  state_passport_scholarship DECIMAL(14,2) COMMENT 'src rows 2549; StatePassportScholarship',
  state_opportunity_scholarship DECIMAL(14,2) COMMENT 'src rows 2550; StateOpportunityScholarship',
  state_ed_opportunity_grant DECIMAL(14,2) COMMENT 'src rows 2551; StateEdOpportunityGrant',
  state_other_gift_aid STRING COMMENT 'src rows 2552; StateOtherGiftAid',
  state_work_study_total STRING COMMENT 'src rows 2553; StateWorkStudyTotal',
  state_work_study_on_campus STRING COMMENT 'src rows 2554; StateWorkStudyOnCampus',
  state_work_study_off_campus STRING COMMENT 'src rows 2555; StateWorkStudyOffCampus',
  state_get_ready_for_math_and_science STRING COMMENT 'src rows 2556; StateGETReadyForMathAndScience',
  inst_grants_waivers DECIMAL(14,2) COMMENT 'src rows 2557; InstGrantsWaivers',
  inst_grants DECIMAL(14,2) COMMENT 'src rows 2558; InstGrants',
  inst_need_based_waivers_public DECIMAL(14,2) COMMENT 'src rows 2559; InstNeedBasedWaiversPublic',
  inst_need_based_waivers DECIMAL(14,2) COMMENT 'src rows 2560; InstNeedBasedWaivers',
  inst_non_need_based_waivers DECIMAL(14,2) COMMENT 'src rows 2561; InstNonNeedBasedWaivers',
  inst_aid_fund_grants DECIMAL(14,2) COMMENT 'src rows 2562; InstAidFundGrants',
  inst_need_based_gift_aid STRING COMMENT 'src rows 2563; InstNeedBasedGiftAid',
  inst_non_need_based_gift_aid STRING COMMENT 'src rows 2564; InstNonNeedBasedGiftAid',
  inst_substitution_state_need_grant DECIMAL(14,2) COMMENT 'src rows 2565; InstSubstitutionStateNeedGrant',
  inst_employment STRING COMMENT 'src rows 2566; InstEmployment',
  inst_loans DECIMAL(14,2) COMMENT 'src rows 2567; InstLoans',
  other_grants_wa_agencies DECIMAL(14,2) COMMENT 'src rows 2568; OtherGrantsWAAgencies',
  other_grants_agencies DECIMAL(14,2) COMMENT 'src rows 2569; OtherGrantsAgencies',
  other_grants_non_wa_agencies DECIMAL(14,2) COMMENT 'src rows 2570; OtherGrantsNonWAAgencies',
  other_grants_private DECIMAL(14,2) COMMENT 'src rows 2571; OtherGrantsPrivate',
  other_loans_conditional DECIMAL(14,2) COMMENT 'src rows 2572; OtherLoansConditional',
  other_loans_private DECIMAL(14,2) COMMENT 'src rows 2573; OtherLoansPrivate',
  other_and_inst_loans_all_types DECIMAL(14,2) COMMENT 'src rows 2574; OtherAndInstLoansAllTypes',
  other_loans_agencies DECIMAL(14,2) COMMENT 'src rows 2575; OtherLoansAgencies',
  state_wcg_apprenticeship STRING COMMENT 'src rows 2576; StateWCGApprenticeship',
  state_passport_incentive_grant DECIMAL(14,2) COMMENT 'src rows 2577; StatePassportIncentiveGrant',
  state_wsosba_scholarship DECIMAL(14,2) COMMENT 'src rows 2578; StateWSOSBAScholarship',
  state_wsos_career_tech STRING COMMENT 'src rows 2579; StateWSOSCareerTech',
  state_teacher_grant_programs DECIMAL(14,2) COMMENT 'src rows 2580; StateTeacherGrantPrograms',
  state_teach_conditional_scholarship DECIMAL(14,2) COMMENT 'src rows 2581; StateTeachConditionalScholarship'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Annual aid package with explicit amount column per aid program | Grain: One row per person x institution x award year'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.FINANCIAL_AID_AWARD_TERM_ENROLLMENT (
  financial_aid_award_term_enrollment_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  financial_aid_award_id BIGINT COMMENT 'FK',
  enrollment_id BIGINT COMMENT 'FK to fact.ENROLLMENT (PS term row); null when no matching enrollment',
  academic_period_id BIGINT COMMENT 'Term',
  aid_enrollment_status_code STRING COMMENT 'src rows 2514,2515,2516,2517,2518; EnrollmentFall, EnrollmentSpring, EnrollmentSummer1, EnrollmentSummer2, EnrollmentWinter'
)
USING DELTA
CLUSTER BY (academic_period_id)
COMMENT 'Ties the annual award to the term ENROLLMENT rows it funds | Grain: One row per aid award x term with an aid enrollment status'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE_FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION (
  program_participation_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  sector STRING COMMENT 'EL / K12 / PS / FA',
  program_participation_start_date DATE COMMENT 'src rows 100,414,1287,1313,1421,1454,1509; BilStartDate, IEPCreatedDate, InitialReferralDate, StartDate, enroll_date',
  program_id BIGINT COMMENT 'src rows 100,246,398,456,1205,1285,1328,1419,1454,2427; ACAD_PLAN, CountyTypeId, FreeReducedMealsFlag, IEPCreatedDate, ProgramCode, ProgramDesignation, ProgramID, StartDate, prog_id',
  program_participation_exit_date DATE COMMENT 'src rows 101,416,1314,1422,1457,1804; BilExitDate, ExitDate, IEPExpirationDate, Program Exit Date, exit_date',
  person_id BIGINT COMMENT 'src rows 239,394,452,1204,1284,1312,1418,1453,1507,1508,1765,1766...; ChildId, DW_KEY, District Student Id, DistrictStudentCode, EMPLID, SSID, stu_id',
  el_provider_org_id BIGINT COMMENT 'src rows 240; ESITOrganizationId',
  academic_period_id BIGINT COMMENT 'src rows 391,392,449,450,1199,1278,1305,1412,1447,1504,1757,2178...; LEGACY_QUARTER, LEGACY_YEAR, LEGACY_YRQ, STRM, School Year, SchoolYear, academic_year, year',
  ps_institution_org_id BIGINT COMMENT 'src rows 393,451,2361,2429; COLLEGE, INSTITUTION, inst_code',
  clinical_lea_org_id BIGINT COMMENT 'src rows 460; dist_code',
  clinical_school_org_id BIGINT COMMENT 'src rows 461; bldg_code',
  mentor_person_id BIGINT COMMENT 'src rows 463; lead_mentor_cert',
  lea_org_id BIGINT COMMENT 'src rows 1200,1279,1306,1308,1413,1448,1505,1759; DistCode, DistrictCode, DistrictOrganizationId, Serving District Id',
  school_org_id BIGINT COMMENT 'src rows 1202,1281,1283,1309,1311,1415,1417,1450,1452,1763; LocationID, LocationId, SchCode, SchoolCode, SchoolOrganizationId, Serving School Id',
  nonpublic_agency_org_id BIGINT COMMENT 'src rows 1469,1470; NonPublicAgencyCode, NonPublicAgencyId',
  resident_lea_org_id BIGINT COMMENT 'src rows 1761; Resident District Id',
  reengagement_provider_org_id BIGINT COMMENT 'src rows 1764; Provider Code'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Person-level participation bridge to conformed PROGRAM | Grain: One row per person x program x organization x participation start (or period)'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE_FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_EL_ESIT_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  county_type_id STRING COMMENT 'src rows 246; CountyTypeId',
  zip_code STRING COMMENT 'src rows 247; ZipCode',
  state_type_id STRING COMMENT 'src rows 248; StateTypeId'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_EL_IEP_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  child_iep_id STRING COMMENT 'src rows 99; ChildIEPId',
  primary_disability_type_code STRING COMMENT 'src rows 102; DisabilityTypeId'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_K12_BILINGUAL_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year STRING COMMENT 'src rows 1305; SchoolYear',
  bilingual_exit_reason_id STRING COMMENT 'src rows 1315; BilingualExitReasonID',
  instructional_model_id STRING COMMENT 'src rows 1317; InstructionalModelId',
  placement_test_scale_score DECIMAL(12,3) COMMENT 'src rows 1319; PlacementTestScaleScore',
  bilingual_placement_test_level_code STRING COMMENT 'src rows 1322; BilingualPlacementTestLevelCode',
  placement_test_date DATE COMMENT 'src rows 1323; PlacementTestDate',
  initial_wa_placement_date DATE COMMENT 'src rows 1324; InitialWAPlacementDate',
  program_designation_code STRING COMMENT 'src rows 1328; ProgramDesignation',
  placement_test_code_id STRING COMMENT 'src rows 1330; PlacementTestCodeId',
  grade_level_at_placement_id STRING COMMENT 'src rows 1332; GradeLevelAtPlacementId',
  source_submit_date DATE COMMENT 'src rows 1334; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1335; ExtractDate',
  wida_overall_placement_score_id STRING COMMENT 'src rows 1336; WIDAOverallPlacementScoreId'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_K12_CEDARS_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year STRING COMMENT 'src rows 1412; SchoolYear',
  exit_code STRING COMMENT 'src rows 1424; ExitCode',
  qualification_code STRING COMMENT 'src rows 1425; QualificationCode',
  source_submit_date DATE COMMENT 'src rows 1427; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1428; ExtractDate'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_K12_FRPL_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year STRING COMMENT 'src rows 1199; SchoolYear',
  free_reduced_meals_flag BOOLEAN COMMENT 'src rows 1205; FreeReducedMealsFlag',
  free_meals_flag BOOLEAN COMMENT 'src rows 1206; FreeMealsFlag',
  reduced_meals_flag BOOLEAN COMMENT 'src rows 1207; ReducedMealsFlag',
  income_survey_flag BOOLEAN COMMENT 'src rows 1208; IncomeSurveyFlag',
  source_submit_date DATE COMMENT 'src rows 1209; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1210; ExtractDate'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_K12_LAP_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year STRING COMMENT 'src rows 1278; SchoolYear',
  identification_assessment_code STRING COMMENT 'src rows 1288; IdentificationAssessmentCode',
  academic_growth_amount_code DECIMAL(14,2) COMMENT 'src rows 1290; AcademicGrowthAmountCode',
  progress_monitoring_assessment_code STRING COMMENT 'src rows 1292; ProgressMonitoringAssessmentCode',
  beginning_scale_score DECIMAL(12,3) COMMENT 'src rows 1294; BeginningScaleScore',
  beginning_scale_score_date DATE COMMENT 'src rows 1295; BeginningScaleScoreDate',
  end_scale_score DECIMAL(12,3) COMMENT 'src rows 1296; EndScaleScore',
  end_scale_score_date DATE COMMENT 'src rows 1297; EndScaleScoreDate',
  extended_learning_time_type_code STRING COMMENT 'src rows 1298; ExtendedLearningTimeTypeCode',
  tutoring_type_code STRING COMMENT 'src rows 1300; TutoringTypeCode',
  met_learning_goal STRING COMMENT 'src rows 1302; MetLearningGoal',
  source_submit_date DATE COMMENT 'src rows 1303; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1304; ExtractDate'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_K12_OPEN_DOORS_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year STRING COMMENT 'src rows 1757; School Year',
  age DECIMAL(12,3) COMMENT 'src rows 1771; Age',
  grad_requirement_year STRING COMMENT 'src rows 1772; Grad Requirement Year',
  eligible_through_credit_deficiency DECIMAL(12,3) COMMENT 'src rows 1773; Eligible through Credit Deficiency',
  months_out_of_school_prior_to_enrollment DECIMAL(12,3) COMMENT 'src rows 1774; Months out of School Prior to Enrollment',
  credits_earned_prior_to_enrollment DECIMAL(12,3) COMMENT 'src rows 1775; Credits Earned Prior To Enrollment',
  previously_enrolled_in_reengagement_program STRING COMMENT 'src rows 1776; Previously Enrolled In Reengagement Program',
  number_of_days_enrolled DECIMAL(12,3) COMMENT 'src rows 1777; Number of Days Enrolled',
  english_equivalency_measure_pass STRING COMMENT 'src rows 1778; English Equivalency Measure Pass',
  english_equivalency_measure_date DATE COMMENT 'src rows 1779; English Equivalency Measure Date',
  math_equivalency_measure_pass STRING COMMENT 'src rows 1780; Math Equivalency Measure Pass',
  math_equivalency_measure_date DATE COMMENT 'src rows 1781; Math Equivalency Measure Date',
  science_equivalency_measure_pass STRING COMMENT 'src rows 1782; Science Equivalency Measure Pass',
  science_equivalency_measure_date DATE COMMENT 'src rows 1783; Science Equivalency Measure Date',
  social_studies_equivalency_measure_pass STRING COMMENT 'src rows 1784; SocialStudies Equivalency Measure Pass',
  social_studies_equivalency_measure_date DATE COMMENT 'src rows 1785; Social Studies Equivalency Measure Date',
  all_four_equivalency_measures_pass STRING COMMENT 'src rows 1786; All Four Equivalency Measures Pass',
  high_school_credits_earned DECIMAL(12,3) COMMENT 'src rows 1787; High School Credits Earned',
  college_credits_earned DECIMAL(12,3) COMMENT 'src rows 1788; College Credits Earned',
  grade_level_curriculums STRING COMMENT 'src rows 1789; Grade Level Curriculums',
  core_academic_subject_area_gains STRING COMMENT 'src rows 1790; Core Academic Subject Area Gains',
  college_readiness_courses STRING COMMENT 'src rows 1791; College Readiness Courses',
  job_search_retention_courses STRING COMMENT 'src rows 1792; Job Search/Retention Courses',
  work_based_learning_experiences DECIMAL(12,3) COMMENT 'src rows 1793; Work-Based Learning Experiences',
  enrolled_in_college_for_first_time STRING COMMENT 'src rows 1794; Enrolled In College for First Time',
  esl_courses STRING COMMENT 'src rows 1795; ESL Courses',
  adult_basic_education_abe_ged_courses STRING COMMENT 'src rows 1796; Adult Basic Education (ABE)/GED Courses',
  short_term_industry_recognized_certificates STRING COMMENT 'src rows 1797; Short Term Industry Recognized Certificates',
  sbe_high_school_graduation_requirement STRING COMMENT 'src rows 1798; SBE High School Graduation Requirement',
  high_school_equivalency_certificate_indicator STRING COMMENT 'src rows 1799; High School Equivalency Certificate',
  high_school_diploma_indicator STRING COMMENT 'src rows 1800; High School Diploma',
  certificates_earned STRING COMMENT 'src rows 1801; Certificates Earned',
  college_degree STRING COMMENT 'src rows 1802; College Degree',
  industry_recognized_certificate STRING COMMENT 'src rows 1803; Industry Recognized Certificate',
  exit_description STRING COMMENT 'src rows 1805; Exit Description',
  migrant DECIMAL(14,2) COMMENT 'src rows 1808; Migrant',
  special_education STRING COMMENT 'src rows 1809; Special Education',
  frl STRING COMMENT 'src rows 1810; FRL',
  homeless STRING COMMENT 'src rows 1811; Homeless',
  n_504 STRING COMMENT 'src rows 1812; 504',
  lap STRING COMMENT 'src rows 1813; LAP',
  limited_english_proficiency STRING COMMENT 'src rows 1814; Limited English Proficiency'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_K12_SPED_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year STRING COMMENT 'src rows 1447; SchoolYear',
  idea_educational_environment_for_school_age_code STRING COMMENT 'src rows 1455; LRETypeCode',
  program_exit_reason_id STRING COMMENT 'src rows 1458; ProgramExitReasonID',
  last_iep_review_date DATE COMMENT 'src rows 1462; LastIEPReviewDate',
  last_evaluation_date DATE COMMENT 'src rows 1463; LastEvaluationDate',
  initial_wa_service_date DATE COMMENT 'src rows 1464; InitialWAServiceDate',
  source_submit_date DATE COMMENT 'src rows 1466; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1467; ExtractDate',
  annual_iep_meeting_date DATE COMMENT 'src rows 1468; AnnualIEPMeetingDate',
  pre_k_social_entry_code STRING COMMENT 'src rows 1473; PreKSocialEntryCode',
  pre_k_social_progres_code STRING COMMENT 'src rows 1476; PreKSocialProgresCode',
  pre_k_social_exit_code STRING COMMENT 'src rows 1479; PreKSocialExitCode',
  pre_k_acq_know_entry_code STRING COMMENT 'src rows 1482; PreKAcqKnowEntryCode',
  pre_k_acq_know_progres_code STRING COMMENT 'src rows 1485; PreKAcqKnowProgresCode',
  pre_k_acq_know_exit_code STRING COMMENT 'src rows 1488; PreKAcqKnowExitCode',
  pre_k_behave_entry_code STRING COMMENT 'src rows 1491; PreKBehaveEntryCode',
  pre_k_behave_progres_code STRING COMMENT 'src rows 1494; PreKBehaveProgresCode',
  pre_k_behave_exit_code STRING COMMENT 'src rows 1497; PreKBehaveExitCode',
  interpreter_request_annual_iep_meet_type_code STRING COMMENT 'src rows 1500; InterpreterRequestAnnualIEPMeetTypeCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_K12_SPED_EVALUATION_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  initial_referral_date DATE COMMENT 'src rows 1460,1509; InitialReferralDate',
  initial_eligibility_date DATE COMMENT 'src rows 1461; InitialEligibilityDate',
  source_school_year STRING COMMENT 'src rows 1504; SchoolYear',
  dist_receiv_consent_date DATE COMMENT 'src rows 1510; DistReceivConsentDate',
  initial_iep_meeting_date DATE COMMENT 'src rows 1511; InitialIEPMeetingDate',
  init_elig_determin_date STRING COMMENT 'src rows 1512; InitEligDeterminDate',
  sch_days_to_complete_eval DECIMAL(12,3) COMMENT 'src rows 1513; SchDaysToCompleteEval',
  late_init_eval_reason_code STRING COMMENT 'src rows 1515; LateInitEvalReasonCode',
  eligibility_outcome_code STRING COMMENT 'src rows 1518; EligibilityOutcomeCode',
  iep_after3_reason_code STRING COMMENT 'src rows 1521; IEPAfter3ReasonCode',
  source_submit_date DATE COMMENT 'src rows 1523; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1524; ExtractDate',
  interpreter_request_initial_iep_meet_type_code STRING COMMENT 'src rows 1526; InterpreterRequestInitialIEPMeetTypeCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_PS_EPP_CLINICAL_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_year STRING COMMENT 'src rows 449; year',
  source_academic_year STRING COMMENT 'src rows 450; academic_year',
  prog_type STRING COMMENT 'src rows 453; prog_type',
  cred_role STRING COMMENT 'src rows 454; cred_role',
  cred_type STRING COMMENT 'src rows 455; cred_type',
  program_identifier STRING COMMENT 'src rows 456; prog_id',
  prac_name STRING COMMENT 'src rows 457; prac_name',
  prac_type STRING COMMENT 'src rows 458; prac_type',
  prac_endorse STRING COMMENT 'src rows 459; prac_endorse',
  alt_ed_env STRING COMMENT 'src rows 462; alt_ed_env',
  prac_start STRING COMMENT 'src rows 465; prac_start',
  prac_end STRING COMMENT 'src rows 466; prac_end',
  supervised_clinical_experience_clock_hours DECIMAL(12,3) COMMENT 'src rows 467; prac_hours',
  prac_outcome STRING COMMENT 'src rows 468; prac_outcome',
  prac_hours2 DECIMAL(12,3) COMMENT 'src rows 469; prac_hours2'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_PS_EPP_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_year STRING COMMENT 'src rows 391; year',
  source_academic_year STRING COMMENT 'src rows 392; academic_year',
  prog_type STRING COMMENT 'src rows 395; prog_type',
  cred_role STRING COMMENT 'src rows 396; cred_role',
  cred_type STRING COMMENT 'src rows 397; cred_type',
  program_identifier STRING COMMENT 'src rows 398; prog_id',
  enroll_term STRING COMMENT 'src rows 414; enroll_date',
  terms_attended STRING COMMENT 'src rows 415; terms_attended',
  exit_term STRING COMMENT 'src rows 416; exit_date',
  exit_reason STRING COMMENT 'src rows 417; exit_reason',
  recommend STRING COMMENT 'src rows 418; recommend',
  first_generation_college_student STRING COMMENT 'src rows 419; first_gen',
  first_lang_eng STRING COMMENT 'src rows 420; first_lang_Eng',
  prev_degree STRING COMMENT 'src rows 421; prev_degree',
  crntyr_endorse_active STRING COMMENT 'src rows 422; crntyr_endorse_active',
  endorse_complete_date STRING COMMENT 'src rows 423; endorse_complete_date',
  endorse_recommend STRING COMMENT 'src rows 424; endorse_recommend',
  cw_completion_date STRING COMMENT 'src rows 425; cw_completion_date',
  cwtest_completion_date STRING COMMENT 'src rows 426; cwtest_completion_date',
  title_ii_flag STRING COMMENT 'src rows 427; Title_II_flag'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.PROGRAM_PARTICIPATION_PS_SBCTC_PLAN_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_legacy_quarter STRING COMMENT 'src rows 2178; LEGACY_QUARTER',
  source_legacy_year STRING COMMENT 'src rows 2179; LEGACY_YEAR',
  priority STRING COMMENT 'src rows 2381; PRIORITY',
  stdnt_car_nbr STRING COMMENT 'src rows 2432; STDNT_CAR_NBR',
  intent STRING COMMENT 'src rows 2435; INTENT',
  source_legacy_yrq STRING COMMENT 'src rows 2438; LEGACY_YRQ',
  source_strm STRING COMMENT 'src rows 2439; STRM'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.SCHOOL_YEAR_PROFILE (
  school_year_profile_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  school_year STRING COMMENT 'src rows 1673; SchoolYear',
  academic_period_id BIGINT COMMENT 'src rows 1674; School_Year',
  source_school_year STRING COMMENT 'src rows 1674; School_Year',
  lea_org_id BIGINT COMMENT 'src rows 1678,1679; CCDDD, NCESDIST',
  school_org_id BIGINT COMMENT 'src rows 1681,1682; BLDG, NCESSCH',
  school_type_desc STRING COMMENT 'src rows 1689; SCHOOL_TYPE_DESC',
  total_enrollment DECIMAL(12,3) COMMENT 'src rows 1690; Total_Enrollment',
  number_amer_indian_or_ak_native DECIMAL(12,3) COMMENT 'src rows 1691; Number_Amer_Indian_or_AK_Native',
  percent_amer_indian_or_ak_native DECIMAL(12,3) COMMENT 'src rows 1692; Percent_Amer_Indian_or_AK_Native',
  number_asian DECIMAL(12,3) COMMENT 'src rows 1693; Number_Asian',
  percent_asian DECIMAL(12,3) COMMENT 'src rows 1694; Percent_Asian',
  number_pacific_islander DECIMAL(12,3) COMMENT 'src rows 1695; Number_Pacific_Islander',
  percent_pacific_islander DECIMAL(12,3) COMMENT 'src rows 1696; Percent_Pacific_Islander',
  number_asian_pacific_islander DECIMAL(12,3) COMMENT 'src rows 1697; Number_Asian_Pacific_Islander',
  percent_asian_pacific_islander DECIMAL(12,3) COMMENT 'src rows 1698; Percent_Asian_Pacific_Islander',
  number_black DECIMAL(12,3) COMMENT 'src rows 1699; Number_Black',
  percent_black DECIMAL(12,3) COMMENT 'src rows 1700; Percent_Black',
  number_hispanic DECIMAL(12,3) COMMENT 'src rows 1701; Number_Hispanic',
  percent_hispanic DECIMAL(12,3) COMMENT 'src rows 1702; Percent_Hispanic',
  number_white DECIMAL(12,3) COMMENT 'src rows 1703; Number_White',
  percent_white DECIMAL(12,3) COMMENT 'src rows 1704; Percent_White',
  number_two_or_more_races DECIMAL(12,3) COMMENT 'src rows 1705; Number_Two_Or_More_Races',
  percent_two_or_more_races DECIMAL(12,3) COMMENT 'src rows 1706; Percent_Two_Or_More_Races',
  number_males DECIMAL(12,3) COMMENT 'src rows 1707; Number_Males',
  percent_males DECIMAL(12,3) COMMENT 'src rows 1708; Percent_Males',
  number_females DECIMAL(12,3) COMMENT 'src rows 1709; Number_Females',
  percent_females DECIMAL(12,3) COMMENT 'src rows 1710; Percent_Females',
  number_migrant DECIMAL(14,2) COMMENT 'src rows 1711; Number_Migrant',
  percent_migrant DECIMAL(14,2) COMMENT 'src rows 1712; Percent_Migrant',
  number_transitional_bilingual DECIMAL(12,3) COMMENT 'src rows 1713; Number_Transitional_Bilingual',
  percent_transitional_bilingual DECIMAL(12,3) COMMENT 'src rows 1714; Percent_Transitional_Bilingual',
  number_special_education DECIMAL(12,3) COMMENT 'src rows 1715; Number_Special_Education',
  percent_special_education DECIMAL(12,3) COMMENT 'src rows 1716; Percent_Special_Education',
  num_free_reduced_priced_meals DECIMAL(12,3) COMMENT 'src rows 1717; Num_Free_Reduced_Priced_Meals',
  pct_free_reduced_priced_meals DECIMAL(12,3) COMMENT 'src rows 1718; Pct_Free_Reduced_Priced_Meals',
  number_section_504 DECIMAL(12,3) COMMENT 'src rows 1719; Number_Section_504',
  percent_section_504 DECIMAL(12,3) COMMENT 'src rows 1720; Percent_Section_504',
  number_foster_care DECIMAL(12,3) COMMENT 'src rows 1721; Number_Foster_Care',
  percent_foster_care DECIMAL(12,3) COMMENT 'src rows 1722; Percent_Foster_Care',
  number_foster_care_lt10 DECIMAL(12,3) COMMENT 'src rows 1723; Number_Foster_Care_LT10',
  percent_foster_care_lt10 DECIMAL(12,3) COMMENT 'src rows 1724; Percent_Foster_Care_LT10',
  homeless STRING COMMENT 'src rows 1725; Homeless',
  pct_homeless DECIMAL(12,3) COMMENT 'src rows 1726; Pct_Homeless',
  military_parent STRING COMMENT 'src rows 1727; Military Parent',
  pct_military_parent DECIMAL(12,3) COMMENT 'src rows 1728; Pct_Military Parent',
  mobile STRING COMMENT 'src rows 1729; Mobile',
  pct_mobile DECIMAL(12,3) COMMENT 'src rows 1730; Pct_Mobile',
  students_with_disabilities STRING COMMENT 'src rows 1731; Students with Disabilities',
  pct_students_with_disabilities DECIMAL(12,3) COMMENT 'src rows 1732; Pct_Students with Disabilities',
  highly_capable STRING COMMENT 'src rows 1733; Highly Capable',
  pct_highly_capable DECIMAL(12,3) COMMENT 'src rows 1734; Pct_Highly Capable',
  students_per_classroom_teacher STRING COMMENT 'src rows 1735; Students_Per_Classroom_Teacher',
  avg_years_educational_experience DECIMAL(12,3) COMMENT 'src rows 1736; Avg_Years_Educational_Experience',
  num_teachers_least_master_degree DECIMAL(12,3) COMMENT 'src rows 1737; Num_Teachers_Least_Master_Degree',
  pct_teachers_least_master_degree DECIMAL(12,3) COMMENT 'src rows 1738; Pct_Teachers_Least_Master_Degree',
  number_classroom_teachers DECIMAL(12,3) COMMENT 'src rows 1739; Number_Classroom_Teachers',
  income_to_poverty_ratio_estimate STRING COMMENT 'src rows 1748; IPR_EST'
)
USING DELTA
CLUSTER BY (academic_period_id)
COMMENT 'Published Report Card aggregates | Grain: One row per school x school year'
TBLPROPERTIES ('p20w.table_type' = 'PERIODIC_SNAPSHOT', 'p20w.scd' = 'n/a (periodic snapshot)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.STAFF_ASSIGNMENT (
  staff_assignment_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  academic_period_id BIGINT COMMENT 'src rows 567; SchoolYear',
  source_school_year STRING COMMENT 'src rows 567; SchoolYear',
  lea_org_id BIGINT COMMENT 'src rows 568,569; Codist, OrganizationId',
  school_org_id BIGINT COMMENT 'src rows 570; BuildingCode',
  person_id BIGINT COMMENT 'src rows 575,576,577; Cert, EducatorID, PersonnelId',
  recno STRING COMMENT 'src rows 607; Recno',
  area STRING COMMENT 'src rows 608; Area',
  program STRING COMMENT 'src rows 609; Program',
  activity STRING COMMENT 'src rows 610; Activity',
  droot STRING COMMENT 'src rows 611; Droot',
  duty_suffix STRING COMMENT 'src rows 612; DutySuffix',
  grade STRING COMMENT 'src rows 613; Grade',
  asspct DECIMAL(12,3) COMMENT 'src rows 614; Asspct',
  full_time_equivalency DECIMAL(12,3) COMMENT 'src rows 615; AssFTE',
  asssal DECIMAL(14,2) COMMENT 'src rows 616; Asssal',
  asshpy STRING COMMENT 'src rows 617; Asshpy',
  major STRING COMMENT 'src rows 618; Major',
  source_release_type STRING COMMENT 'src rows 619; FinalOrPrelim'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'S-275 assignment lines | Grain: One row per person x LEA x school year x assignment line'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.STAFF_EMPLOYMENT_YEAR (
  staff_employment_year_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  hdeg STRING COMMENT 'src rows 584; Hdeg',
  hyear STRING COMMENT 'src rows 585; Hyear',
  acred STRING COMMENT 'src rows 586; Acred',
  icred STRING COMMENT 'src rows 587; Icred',
  bcred STRING COMMENT 'src rows 588; Bcred',
  vcred STRING COMMENT 'src rows 589; Vcred',
  exp DECIMAL(12,3) COMMENT 'src rows 590; Exp',
  camix1 STRING COMMENT 'src rows 591; Camix1',
  ft_ehrs DECIMAL(12,3) COMMENT 'src rows 592; FTEhrs',
  base_contract_fte DECIMAL(12,3) COMMENT 'src rows 593; BaseContractFTE',
  cert_fte DECIMAL(12,3) COMMENT 'src rows 594; CertFTE',
  clas_fte DECIMAL(12,3) COMMENT 'src rows 595; ClasFTE',
  certbase DECIMAL(14,2) COMMENT 'src rows 596; Certbase',
  clasbase DECIMAL(14,2) COMMENT 'src rows 597; Clasbase',
  othersal DECIMAL(14,2) COMMENT 'src rows 598; Othersal',
  tfinsal DECIMAL(14,2) COMMENT 'src rows 599; Tfinsal',
  cins DECIMAL(14,2) COMMENT 'src rows 600; Cins',
  cman DECIMAL(14,2) COMMENT 'src rows 601; Cman',
  cbrtn STRING COMMENT 'src rows 602; CBRTN',
  clasflag STRING COMMENT 'src rows 603; Clasflag',
  certflag STRING COMMENT 'src rows 604; Certflag',
  ceridate DATE COMMENT 'src rows 605; Ceridate',
  n_bcertexpdate DATE COMMENT 'src rows 606; NBcertexpdate'
)
USING DELTA
COMMENT 'S-275 person-year contract/salary/degree/experience | Grain: One row per person x LEA x school year'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.STAFF_SECTION_ASSIGNMENT (
  staff_section_assignment_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  academic_period_id BIGINT COMMENT 'src rows 1528; SchoolYear',
  source_school_year STRING COMMENT 'src rows 1528; SchoolYear',
  lea_org_id BIGINT COMMENT 'src rows 1529; DistrictCode',
  school_org_id BIGINT COMMENT 'src rows 1531,1533; LocationID, SchoolCode',
  person_id BIGINT COMMENT 'src rows 1534,1535,2367; CertificationNumber, INSTR_ID, StaffID',
  course_section_id BIGINT COMMENT 'src rows 1543; SectionID',
  instruction_start_date DATE COMMENT 'src rows 1573; InstructionStartDate',
  instruction_end_date DATE COMMENT 'src rows 1574; InstructionEndDate',
  teacher_indicator_id STRING COMMENT 'src rows 1575; TeacherIndicatorID',
  staff_type_code STRING COMMENT 'src rows 1578; StaffTypeCode',
  source_submit_date DATE COMMENT 'src rows 1580; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1581; ExtractDate',
  employment_stat STRING COMMENT 'src rows 2254; EMPLOYMENT_STAT',
  fte_faculty DECIMAL(12,3) COMMENT 'src rows 2298; FTE_FACULTY',
  record_code STRING COMMENT 'src rows 2391; RECORD_CODE',
  record_key STRING COMMENT 'src rows 2401; RECORD_KEY',
  source_fte_faculty DECIMAL(12,3) COMMENT 'src rows 2424; SOURCE_FTE_FACULTY',
  team_teach STRING COMMENT 'src rows 2452; TEAM_TEACH'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Teachers/instructors assigned to sections (K-12 and CTC) | Grain: One row per person x course section x staff role x instruction start'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE_FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.STUDENT_COURSE_RECORD (
  student_course_record_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  record_type STRING COMMENT 'SCHEDULE / TRANSCRIPT / NONTRADITIONAL_CREDIT / REGISTRATION',
  sector STRING COMMENT 'K12 / PS',
  lea_org_id BIGINT COMMENT 'src rows 1212,1353,1595; DistrictCode',
  school_org_id BIGINT COMMENT 'src rows 1214,1216,1355,1357,1597,1599; LocationID, SchoolCode',
  person_id BIGINT COMMENT 'src rows 1217,1218,1358,1359,1600,1601,2041,2242,2245,2253,2296,2421; DW_KEY, DistrictStudentCode, DistrictStudentID, EMPLID, SID, SSID, student_institution',
  academic_period_id BIGINT COMMENT 'src rows 1219,1265,1352,1594,1602,2027,2042,2163,2174,2175,2181,2318...; CourseSchoolYear, QUARTER, STRM, SchoolYear, Term, TermEndDate, YEAR, YRQ, academic_year, term',
  course_record_end_date STRING COMMENT 'src rows 1219; TermEndDate',
  course_identifier STRING COMMENT 'src rows 1221,1362,1604,2029,2209; COURSE_NUM, CourseID, CourseId, course',
  course_id BIGINT COMMENT 'src rows 1221,1362,2029,2236; CourseID, CourseId, DEPT_DIV, course',
  staff_person_id BIGINT COMMENT 'src rows 1223,1224; CertificationNumber, StaffID',
  grade_earned STRING COMMENT 'src rows 1228,1394,1650,2034,2325; GR, LetterGrade, grade',
  number_of_credits_attempted DECIMAL(12,3) COMMENT 'src rows 1229,1396,1652,2030,2218; CR, CreditsAttempted, credit_hours_attempted',
  number_of_credits_earned DECIMAL(12,3) COMMENT 'src rows 1230,1397,1653,2031,2218; CR, CreditsEarned, credit_hours_earned',
  source_record_identifier STRING COMMENT 'src rows 1360; AttemptId',
  online_provider_org_id BIGINT COMMENT 'src rows 1387,1640,1641; ApprovedOnlineProviderCode, ApprovedOnlineProviderId',
  online_program_org_id BIGINT COMMENT 'src rows 1389,1393,1643,1644,1648; ApprovedOnlineProgramCode, ApprovedOnlineProgramId, ApprovedOnlineProgramListOrder',
  online_program_resident_lea_org_id BIGINT COMMENT 'src rows 1391,1646; ApprovedOnlinePGMResidentDistOrg, ApprovedOnlinePGMResidentDistOrgId',
  course_section_id BIGINT COMMENT 'src rows 1603,2040,2372,2373; ITEM, SectionID, section',
  ps_campus_org_id BIGINT COMMENT 'src rows 2028; campus',
  ps_institution_org_id BIGINT COMMENT 'src rows 2035,2299,2359,2366,2450; COLLEGE, INSTITUTION, institution',
  doc_site_org_id BIGINT COMMENT 'src rows 2303; DOC_SITE'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Person-level course record bridge to COURSE_SECTION / COURSE | Grain: One row per person x organization x period x course (x section when known) x record type (SCHEDULE / TRANSCRIPT / NONTRADITIONAL / REGISTRATION)'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE_FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.STUDENT_COURSE_RECORD_FUNDING (
  student_course_record_funding_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  funding_source_code STRING COMMENT 'src rows 2032; funding_source',
  clock_hr_equiv DECIMAL(12,3) COMMENT 'src rows 2192; CLOCK_HR_EQUIV',
  cr_equiv DECIMAL(12,3) COMMENT 'src rows 2219; CR_EQUIV',
  fee_pay_status STRING COMMENT 'src rows 2289; FEE_PAY_STATUS',
  fund_source STRING COMMENT 'src rows 2290; FUND_SOURCE',
  fund_source_enrollment STRING COMMENT 'src rows 2291; FUND_SOURCE_ENROLLMENT',
  fund_source_cat STRING COMMENT 'src rows 2292; FUND_SOURCE_CAT',
  kind_of_enrollment STRING COMMENT 'src rows 2295; KIND_OF_ENROLLMENT',
  full_time_equivalency DECIMAL(12,3) COMMENT 'src rows 2297; FTE',
  pct_externally_funded DECIMAL(12,3) COMMENT 'src rows 2378; PCT_EXTERNALLY_FUNDED',
  stu_class_status STRING COMMENT 'src rows 2443; STU_CLASS_STATUS'
)
USING DELTA
COMMENT 'Funding split grain (SBCTC StuClass) / single funding row (PCHEES) | Grain: One row per student course record x funding source'
TBLPROPERTIES ('p20w.table_type' = 'CHILD_FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.STUDENT_COURSE_RECORD_K12_NONTRADITIONAL_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  reporting_school_year STRING COMMENT 'src rows 1352; SchoolYear',
  attempt_title STRING COMMENT 'src rows 1361; AttemptTitle',
  full_course_designation_code STRING COMMENT 'src rows 1363; FullCourseDesignationCode',
  tech_prep_flag BOOLEAN COMMENT 'src rows 1364; TechPrepFlag',
  international_baccalaureate_flag BOOLEAN COMMENT 'src rows 1365; InternationalBaccalaureateFlag',
  collegeatthe_high_school_flag BOOLEAN COMMENT 'src rows 1366; CollegeattheHighSchoolFlag',
  honors_flag BOOLEAN COMMENT 'src rows 1367; HonorsFlag',
  advanced_placement_flag BOOLEAN COMMENT 'src rows 1368; AdvancedPlacementFlag',
  running_start_flag BOOLEAN COMMENT 'src rows 1369; RunningStartFlag',
  college_academic_distribution_requirements_flag BOOLEAN COMMENT 'src rows 1370; CollegeAcademicDistributionRequirementsFlag',
  cambridge_program_flag BOOLEAN COMMENT 'src rows 1371; CambridgeProgramFlag',
  online_flag BOOLEAN COMMENT 'src rows 1372; OnlineFlag',
  local_competency_test_flag BOOLEAN COMMENT 'src rows 1373; LocalCompetencyTestFlag',
  national_competency_test_flag BOOLEAN COMMENT 'src rows 1374; NationalCompetencyTestFlag',
  quantitative_flag BOOLEAN COMMENT 'src rows 1375; QuantitativeFlag',
  science_lab_flag BOOLEAN COMMENT 'src rows 1376; ScienceLabFlag',
  non_instructional_time_flag BOOLEAN COMMENT 'src rows 1377; NonInstructionalTimeFlag',
  district_or_local_dual_credit_pgm BOOLEAN COMMENT 'src rows 1378; DistrictOrLocalDualCreditPgm',
  youth1418_reengagement_dual_credit BOOLEAN COMMENT 'src rows 1379; Youth1418ReengagementDualCredit',
  locally_determined_course_locally_administered_assessment_flag BOOLEAN COMMENT 'src rows 1380; LocallyDeterminedCourseLocallyAdministeredAssessmentFlag',
  state_course_code STRING COMMENT 'src rows 1381; StateCourseCode',
  content_area_code STRING COMMENT 'src rows 1383; ContentAreaCode',
  alternative_learning_education_code STRING COMMENT 'src rows 1385; AlternativeLearningEducationCode',
  source_submit_date DATE COMMENT 'src rows 1398; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1399; ExtractDate',
  local_transition_flag BOOLEAN COMMENT 'src rows 1400; LocalTransitionFlag',
  cte_core_plus_flag BOOLEAN COMMENT 'src rows 1401; CTECorePlusFlag',
  course_level_characteristic_code STRING COMMENT 'src rows 1402; CourseLevelCode',
  sequence_code STRING COMMENT 'src rows 1404; SequenceCode',
  sequence_group_code STRING COMMENT 'src rows 1406; SequenceGroupCode',
  cte_core_plus_advanced_manufacturing_flag BOOLEAN COMMENT 'src rows 1407; CTECorePlusAdvancedManufacturingFlag',
  cte_core_plus_maritime_flag BOOLEAN COMMENT 'src rows 1408; CTECorePlusMaritimeFlag',
  cte_core_plus_aerospace_flag BOOLEAN COMMENT 'src rows 1409; CTECorePlusAerospaceFlag',
  cte_core_plus_construction_flag BOOLEAN COMMENT 'src rows 1410; CTECorePlusConstructionFlag',
  tribal_language_competency_test_flag BOOLEAN COMMENT 'src rows 1411; TribalLanguageCompetencyTestFlag'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.STUDENT_COURSE_RECORD_K12_SCHEDULE_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_school_year STRING COMMENT 'src rows 1594; SchoolYear',
  alternative_learning_education_code STRING COMMENT 'src rows 1606; AlternativeLearningEducationCode',
  source_submit_date DATE COMMENT 'src rows 1635; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1636; ExtractDate',
  industry_certification_earned STRING COMMENT 'src rows 1662; IndustryCertificationEarned',
  work_based_learning_opportunity_type_code STRING COMMENT 'src rows 1666; WorkBasedLearningActivityTypeCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.STUDENT_COURSE_RECORD_K12_TRANSCRIPT_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  reporting_school_year STRING COMMENT 'src rows 1211; SchoolYear',
  term STRING COMMENT 'src rows 1220; Term',
  course_title STRING COMMENT 'src rows 1222; CourseTitle',
  grade_level_when_course_taken STRING COMMENT 'src rows 1225; GradeLevelWhenCourseTaken',
  alternative_learning_education_code STRING COMMENT 'src rows 1226; AlternativeLearningEducationCode',
  state_course_code STRING COMMENT 'src rows 1231; StateCourseCode',
  content_area_code STRING COMMENT 'src rows 1233; ContentAreaCode',
  advanced_placement_course_code STRING COMMENT 'src rows 1235; APIBCourseCode',
  classification_of_instructional_program_code STRING COMMENT 'src rows 1237; CTECIPCode',
  career_cluster_code STRING COMMENT 'src rows 1239; CTEClusterID',
  cte_cluster_name STRING COMMENT 'src rows 1240; CTEClusterName',
  cte_pathway_id STRING COMMENT 'src rows 1241; CTEPathwayID',
  cte_pathway_name STRING COMMENT 'src rows 1242; CTEPathwayName',
  cte_assessment STRING COMMENT 'src rows 1243; CTEAssessment',
  has_cte_industry_certificate_flag BOOLEAN COMMENT 'src rows 1244; HasCTEIndustryCertificateFlag',
  cte_voc_completer_flag STRING COMMENT 'src rows 1245; CTEVocCompleterFlag',
  cte_direct_transcription_available_flag BOOLEAN COMMENT 'src rows 1246; CTEDirectTranscriptionAvailableFlag',
  tech_prep_course_flag BOOLEAN COMMENT 'src rows 1247; TechPrepCourseFlag',
  tech_prep_program_area_completer_flag STRING COMMENT 'src rows 1248; TechPrepProgramAreaCompleterFlag',
  full_course_designation_code STRING COMMENT 'src rows 1249; FullCourseDesignationCode',
  international_baccalaureate_flag BOOLEAN COMMENT 'src rows 1250; InternationalBaccalaureateFlag',
  collegeatthe_high_school_flag BOOLEAN COMMENT 'src rows 1251; CollegeattheHighSchoolFlag',
  honors_flag BOOLEAN COMMENT 'src rows 1252; HonorsFlag',
  advanced_placement_flag BOOLEAN COMMENT 'src rows 1253; AdvancedPlacementFlag',
  running_start_flag BOOLEAN COMMENT 'src rows 1254; RunningStartFlag',
  college_academic_distribution_requirements_flag BOOLEAN COMMENT 'src rows 1255; CollegeAcademicDistributionRequirementsFlag',
  cambridge_program_flag BOOLEAN COMMENT 'src rows 1256; CambridgeProgramFlag',
  online_flag BOOLEAN COMMENT 'src rows 1257; OnlineFlag',
  local_competency_test_flag BOOLEAN COMMENT 'src rows 1258; LocalCompetencyTestFlag',
  national_competency_test_flag BOOLEAN COMMENT 'src rows 1259; NationalCompetencyTestFlag',
  quantitative_flag BOOLEAN COMMENT 'src rows 1260; QuantitativeFlag',
  science_lab_flag BOOLEAN COMMENT 'src rows 1261; ScienceLabFlag',
  non_instructional_time_flag BOOLEAN COMMENT 'src rows 1262; NonInstructionalTimeFlag',
  source_submit_date DATE COMMENT 'src rows 1263; SubmitDate',
  source_extract_date DATE COMMENT 'src rows 1264; ExtractDate',
  course_school_year STRING COMMENT 'src rows 1265; CourseSchoolYear',
  district_or_local_dual_credit_pgm BOOLEAN COMMENT 'src rows 1266; DistrictOrLocalDualCreditPgm',
  youth1418_reengagement_dual_credit BOOLEAN COMMENT 'src rows 1267; Youth1418ReengagementDualCredit',
  local_transition_flag BOOLEAN COMMENT 'src rows 1268; LocalTransitionFlag',
  cte_core_plus_flag BOOLEAN COMMENT 'src rows 1269; CTECorePlusFlag',
  industry_certification_earned STRING COMMENT 'src rows 1270; IndustryCertificationEarned',
  cte_core_plus_advanced_manufacturing_flag BOOLEAN COMMENT 'src rows 1271; CTECorePlusAdvancedManufacturingFlag',
  cte_core_plus_maritime_flag BOOLEAN COMMENT 'src rows 1272; CTECorePlusMaritimeFlag',
  cte_core_plus_aerospace_flag BOOLEAN COMMENT 'src rows 1273; CTECorePlusAerospaceFlag',
  cte_core_plus_construction_flag BOOLEAN COMMENT 'src rows 1274; CTECorePlusConstructionFlag',
  work_based_learning_opportunity_type_code STRING COMMENT 'src rows 1275; WorkBasedLearningActivityTypeCode',
  tribal_language_competency_test_flag BOOLEAN COMMENT 'src rows 1277; TribalLanguageCompetencyTestFlag'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.STUDENT_COURSE_RECORD_PS_PCHEES_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_academic_year STRING COMMENT 'src rows 2027; academic_year',
  grade_number STRING COMMENT 'src rows 2033; grade_number',
  source_record_number STRING COMMENT 'src rows 2036; record_number',
  registration_sequence_number DECIMAL(12,3) COMMENT 'src rows 2037; registration_sequence_number',
  remedial_type STRING COMMENT 'src rows 2038; remedial_type',
  course_repeat_code STRING COMMENT 'src rows 2039; repeat_status',
  source_term STRING COMMENT 'src rows 2042; term'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.STUDENT_COURSE_RECORD_PS_SBCTC_DETAIL (
  parent_id BIGINT COMMENT 'SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_year STRING COMMENT 'src rows 2163,2175; YEAR',
  source_quarter STRING COMMENT 'src rows 2174,2181; QUARTER',
  clock_hr_ind BOOLEAN COMMENT 'src rows 2193; CLOCK_HR_IND',
  clvl_ind STRING COMMENT 'src rows 2199; CLVL_IND',
  course_flag STRING COMMENT 'src rows 2206; COURSE_FLAG',
  course_num_prefix STRING COMMENT 'src rows 2211; COURSE_NUM_PREFIX',
  course_num_suffix STRING COMMENT 'src rows 2213; COURSE_NUM_SUFFIX',
  cr_ind STRING COMMENT 'src rows 2220; CR_IND',
  enr_hr DECIMAL(12,3) COMMENT 'src rows 2268; ENR_HR',
  gpa_ind DECIMAL(12,3) COMMENT 'src rows 2315; GPA_IND',
  gr_dec DECIMAL(12,3) COMMENT 'src rows 2326; GR_DEC',
  gr_qlfr STRING COMMENT 'src rows 2327; GR_QLFR',
  source_yrq_added STRING COMMENT 'src rows 2386; QTR_ADDED',
  reqr_course_num STRING COMMENT 'src rows 2409; REQR_COURSE_NUM',
  reqr_dept_div STRING COMMENT 'src rows 2411; REQR_DEPT_DIV',
  sect_stat STRING COMMENT 'src rows 2415; SECT_STAT',
  source_strm STRING COMMENT 'src rows 2436,2440; STRM',
  sect STRING COMMENT 'src rows 2445; SECT',
  classification_of_instructional_program_code STRING COMMENT 'src rows 2446; CIP',
  acad_career STRING COMMENT 'src rows 2447; ACAD_CAREER',
  distance_education_course_enrollment STRING COMMENT 'src rows 2459; DIST_ED',
  earn_ind STRING COMMENT 'src rows 2461; EARN_IND',
  voc_ind STRING COMMENT 'src rows 2465; VOC_IND',
  source_yrq STRING COMMENT 'src rows 2318,2479; YRQ',
  credits_enrolled DECIMAL(12,3) COMMENT 'src rows 2224; CREDITS_ENROLLED',
  ibest_indicator STRING COMMENT 'src rows 2352; IBEST'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'SATELLITE', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.fact.WAGE (
  wage_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  person_id BIGINT COMMENT 'src rows 792; SSN',
  reference_period_start_date STRING COMMENT 'src rows 793; YearQuarter',
  reference_period_end_date STRING COMMENT 'src rows 793; YearQuarter',
  academic_period_id BIGINT COMMENT 'src rows 793; YearQuarter',
  employer_org_id BIGINT COMMENT 'src rows 796,802; EmployerAccountNumber, FEIN',
  hours_worked_in_quarter DECIMAL(12,3) COMMENT 'src rows 797; TotalHours',
  quarterly_earnings DECIMAL(14,2) COMMENT 'src rows 798; TotalWageAmount',
  wage_type_code STRING COMMENT 'src rows 799; WageTypeCode',
  wage_hours_calculated_code STRING COMMENT 'src rows 800; WageHoursCalculatedCode',
  employment_naics_code STRING COMMENT 'src rows 801; NAICSCode',
  standard_occupational_classification STRING COMMENT 'src rows 803; SOC'
)
USING DELTA
CLUSTER BY (person_id, academic_period_id)
COMMENT 'Single-sector conformed family table | Grain: One row per person x employer UI account x calendar quarter x wage type'
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.identity.NSC_STUDENTTRACKER_REQUEST_RESULT (
  nsc_studenttracker_request_result_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  record_id STRING COMMENT 'src rows 2093; RecordID',
  status STRING COMMENT 'src rows 2095; Status',
  nsc_effective_date DATE COMMENT 'src rows 2096; NSCEffectiveDate',
  nsc_run_date DATE COMMENT 'src rows 2097; NSCRunDate',
  request STRING COMMENT 'src rows 2098; Request',
  description STRING COMMENT 'src rows 2099; Description',
  sas_record_id STRING COMMENT 'src rows 2100; SasRecordID',
  search_date DATE COMMENT 'src rows 2101; Search_Date',
  record_found_y_n STRING COMMENT 'src rows 2113; Record_Found_Y_N',
  high_school_code STRING COMMENT 'src rows 2114; High_School_Code',
  high_school_graduation_date DATE COMMENT 'src rows 2115; High_School_Graduation_Date',
  program_code STRING COMMENT 'src rows 2129; Program_Code'
)
USING DELTA
COMMENT 'Admin-only NSC request/return metadata | Grain: One row per NSC return record (request metadata)'
TBLPROPERTIES ('p20w.table_type' = 'IDENTITY', 'p20w.scd' = 'Append-only', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.identity.PERSON_PII_OBSERVATION (
  person_pii_observation_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  first_name STRING COMMENT 'src rows 86,198,241,291,399,480,535,573,795,805,868,889...; Child_F_Name, EmployeeFirstName, First Name, FirstName, First_Name, LegalFirstName, NameFirst, StaffFirstName, StudentFirstName, WaK_ChildFName, first_name',
  last_or_surname STRING COMMENT 'src rows 87,205,242,293,400,479,534,572,807,869,888,1056...; Child_L_Name, Last Name, LastName, Last_Name, LegalLastName, NameLast, StaffLastName, StudentLastName, WaK_ChildLName, last_name',
  middle_name STRING COMMENT 'src rows 88,212,243,292,401,536,574,806,870,890,1058,1538...; Child_MI, LegalMiddleName, Middle Name, MiddleInitial, MiddleName, Middle_Name, NameMiddle, StaffMiddleName, StudentMiddleInitial, StudentMiddleName, WaK_ChildMI, middle_name',
  birthdate DATE COMMENT 'src rows 89,178,244,278,329,402,626,843,867,891,1059,1539...; BIRTH_DATE, Birth Date, BirthDate, Birthdate, DOB, Date_of_Birth, SRBirthDate, StaffBirthDate, StudentBirthDate, WaK_Birthdate, birth_date',
  address_postal_code STRING COMMENT 'src rows 95; ZipCode',
  full_name_as_reported STRING COMMENT 'src rows 277,2368; INSTR_NAME, SRName',
  social_security_number STRING COMMENT 'src rows 403,792,808,2074,2146,2483,2587,2601,2626,2627; ApplicationSSN, SSN, UpdatedSSN, ssn',
  social_security_number_last_four STRING COMMENT 'src rows 404,532,571; SSN, SSNLastFourChars, ssn4',
  mentor_contact_as_reported STRING COMMENT 'src rows 464; lead_mentor_contact',
  birth_month_as_reported STRING COMMENT 'src rows 537,578; BirthMonth',
  birth_day_as_reported STRING COMMENT 'src rows 538,579; BirthDay',
  birth_year_as_reported STRING COMMENT 'src rows 539,580; BirthYear',
  employee_full_name_as_reported STRING COMMENT 'src rows 794; EmployeeName',
  electronic_mail_address STRING COMMENT 'src rows 844; Email Addr',
  telephone_number STRING COMMENT 'src rows 845,2597; Phone Data, StudentPhone',
  address_street_number_and_name STRING COMMENT 'src rows 846; Address Line1',
  address_apartment_room_or_suite_number STRING COMMENT 'src rows 847; Address Line2',
  preferred_last_or_surname STRING COMMENT 'src rows 1106; PreferredLastName',
  preferred_first_name STRING COMMENT 'src rows 1107; PreferredFirstName',
  preferred_middle_name STRING COMMENT 'src rows 1109; Preferred Middle Name',
  generation_code_or_suffix STRING COMMENT 'src rows 2065,2111,2150; Name_Suffix, Suffix, name_suffix',
  alternate_last_or_surname STRING COMMENT 'src rows 2486; NameLast_Alternate',
  alternate_first_name STRING COMMENT 'src rows 2488; NameFirst_Alternate',
  guardian_last_or_surname STRING COMMENT 'src rows 2598; GuardianLastName',
  guardian_telephone_number STRING COMMENT 'src rows 2599; GuardianHomePhone',
  birth_year_month STRING COMMENT 'src rows 2695; BirthYM'
)
USING DELTA
COMMENT 'Restricted identity zone; never joined by analytic users | Grain: One row per source record observation of identifying attributes'
TBLPROPERTIES ('p20w.table_type' = 'IDENTITY', 'p20w.scd' = 'Append-only observations (no overwrite); consumed by matching', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.identity.PERSON_XWALK (
  person_xwalk_id BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  source_identifier_type STRING COMMENT 'Identifier type',
  match_method STRING COMMENT 'DETERMINISTIC / PROBABILISTIC / CLERICAL / MDM_TOKEN',
  match_score DECIMAL(5,4) COMMENT 'Probabilistic score',
  effective_start_date DATE COMMENT 'Link start',
  effective_end_date DATE COMMENT 'Link end (unmerge closes)',
  source_person_identifier STRING COMMENT 'src rows 81,83,84,85,115,180,239,276,279,302,327,332...; ApplicationSSID, ApplicationSSId, Apprentice Id, CaseNumber, Cert, CertificateNumber, CertificationNumber, ChildID, ChildId, ChildKey, Childid, DW_KEY, District Student Id, Distric',
  person_id BIGINT COMMENT 'src rows 81,83,84,85,115; ChildId, Childid, FamilyMemberId, SSID'
)
USING DELTA
CLUSTER BY (person_id)
COMMENT 'Maps every source person identifier to the durable statewide person_id | Grain: One row per source system x identifier type x source identifier x effective period'
TBLPROPERTIES ('p20w.table_type' = 'IDENTITY_XWALK', 'p20w.scd' = 'Effective-dated (Type 2 semantics on the link; re-matches close the old row)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_absence (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  absence_source_id STRING COMMENT 'src rows 950; AbsenceCodeId',
  absence_code STRING COMMENT 'src rows 951; AbsenceCode',
  absence_description STRING COMMENT 'src rows 952; AbsenceDescription'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_academic_growth_amount (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  academic_growth_amount_code STRING COMMENT 'src rows 1290; AcademicGrowthAmountCode',
  academic_growth_amount_description STRING COMMENT 'src rows 1291; AcademicGrowthAmount'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_academic_services (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  academic_services_source_id STRING COMMENT 'src rows 1028,1170; AcademicServicesId, AcademicServicesTypeId',
  academic_services_code STRING COMMENT 'src rows 1030,1171; AcademicServicesCode, AcademicServicesTypeCode',
  academic_services_description STRING COMMENT 'src rows 1032,1172; AcademicServicesDescription, AcademicServicesTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_alternative_learning_education (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  alternative_learning_education_code STRING COMMENT 'src rows 1226,1385,1606; AlternativeLearningEducationCode',
  alternative_learning_education_description STRING COMMENT 'src rows 1227,1386,1607; AlternativeLearningEducation'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_apib_course (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  apib_course_code STRING COMMENT 'src rows 968,1235,1550,1612; APIBCourseCode',
  apib_course_description STRING COMMENT 'src rows 969,1236,1551,1613; APIBCourseName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_appeal (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  appeal_source_id STRING COMMENT 'src rows 1042,1185; AppealTypeId',
  appeal_code STRING COMMENT 'src rows 1043,1186; AppealCode, AppealTypeCode',
  appeal_description STRING COMMENT 'src rows 1044,1187; AppealDescription, AppealTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_approved_online_pgm_resident_dist_org (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  approved_online_pgm_resident_dist_org_description STRING COMMENT 'src rows 1392,1647; ApprovedOnlinePGMResidentDistric, ApprovedOnlinePGMResidentDistrict'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_apprvd_private_school_attend_part_time (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  apprvd_private_school_attend_part_time_code STRING COMMENT 'src rows 1089; ApprvdPrivateSchoolAttendPartTimeCode',
  apprvd_private_school_attend_part_time_description STRING COMMENT 'src rows 1091; ApprvdPrivateSchoolAttendPartTimeDescription'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_asvab_test_status (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  asvab_test_status_code STRING COMMENT 'src rows 1114; ASVABTestStatusCode',
  asvab_test_status_description STRING COMMENT 'src rows 1115; ASVABTestStatusDesc',
  asvab_test_status_source_id STRING COMMENT 'src rows 1120; ASVABTestStatusId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_behavior_services (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  behavior_services_source_id STRING COMMENT 'src rows 1029,1173; BehaviorServicesId, BehaviorServicesTypeId',
  behavior_services_code STRING COMMENT 'src rows 1031,1174; BehaviorServicesCode, BehaviorServicesTypeCode',
  behavior_services_description STRING COMMENT 'src rows 1033,1175; BehaviorServicesDescription, BehaviorServicesTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_bilingual_exit_reason (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  bilingual_exit_reason_code STRING COMMENT 'src rows 1315; BilingualExitReasonID',
  bilingual_exit_reason_description STRING COMMENT 'src rows 1316; BilingualExitReason'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_bilingual_placement_test_level (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  bilingual_placement_test_level_source_id STRING COMMENT 'src rows 1320; PlacementTestLevelId',
  bilingual_placement_test_level_description STRING COMMENT 'src rows 1321; BilingualPlacementTestLevel',
  bilingual_placement_test_level_code STRING COMMENT 'src rows 1322; BilingualPlacementTestLevelCode'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_confirmed_transfer_in_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  confirmed_transfer_in_type_code STRING COMMENT 'src rows 1110; ConfirmedTransferInTypeID',
  confirmed_transfer_in_type_description STRING COMMENT 'src rows 1113; ConfirmedTransferInType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_content_area (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  content_area_code STRING COMMENT 'src rows 963,1233,1383,1548,1610; ContentAreaCode',
  content_area_description STRING COMMENT 'src rows 964,1234,1384,1549,1611; ContentAreaName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_country (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  country_code STRING COMMENT 'src rows 1071; BirthCountryCode',
  country_description STRING COMMENT 'src rows 1072; BirthCountry',
  country_source_id STRING COMMENT 'src rows 1100; BirthCountryId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_course_level (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  course_level_code STRING COMMENT 'src rows 991,1402; CourseLevelCode',
  course_level_description STRING COMMENT 'src rows 992,1403; CourseLevelDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_credit_waiver (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  credit_waiver_code STRING COMMENT 'src rows 1118; CreditWaiverCode',
  credit_waiver_description STRING COMMENT 'src rows 1119; CreditWaiverDesc',
  credit_waiver_source_id STRING COMMENT 'src rows 1121; CreditWaiverId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_cte_course_equivalency_identity (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  cte_course_equivalency_identity_source_id STRING COMMENT 'src rows 977; CourseEquivalencyIdent',
  cte_course_equivalency_identity_code STRING COMMENT 'src rows 980; CTECourseEquivalencyIdentityCode',
  cte_course_equivalency_identity_description STRING COMMENT 'src rows 981; CTECourseEquivalencyIdentity'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_cte_equivalency (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  cte_equivalency_source_id STRING COMMENT 'src rows 982; CTEEquivalencyIdent',
  cte_equivalency_code STRING COMMENT 'src rows 983; CTEEquivalencyCode',
  cte_equivalency_description STRING COMMENT 'src rows 984; CTEEquivalency'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_ctecip (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ctecip_code STRING COMMENT 'src rows 970,1237,1552,1614; CTECIPCode',
  ctecip_description STRING COMMENT 'src rows 971,1238,1553,1615; CTECIPName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_disciplinary_action (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  disciplinary_action_source_id STRING COMMENT 'src rows 1014,1162; ExclusionaryActionTypeId, InterventionId',
  disciplinary_action_code STRING COMMENT 'src rows 1015,1163; ExclusionaryActionTypeCode, InterventionCode',
  disciplinary_action_description STRING COMMENT 'src rows 1016; InterventionDescription',
  short_disciplinary_action_description STRING COMMENT 'src rows 1164; ExclusionaryActionTypeName',
  long_disciplinary_action_description STRING COMMENT 'src rows 1165; ExclusionaryActionTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_dual_language_instruction_language (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  dual_language_instruction_language_source_id STRING COMMENT 'src rows 988,1588,1657; DualLanguageInstructionLanguageI, DualLanguageInstructionLanguageId',
  dual_language_instruction_language_code STRING COMMENT 'src rows 989,1589,1658; DualLanguageInstructionLanguageC, DualLanguageInstructionLanguageCode',
  dual_language_instruction_language_description STRING COMMENT 'src rows 990,1590,1659; DualLanguageInstructionLanguageN, DualLanguageInstructionLanguageName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_dual_language_instruction_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  dual_language_instruction_type_source_id STRING COMMENT 'src rows 985,1585,1654; DualLanguageInstructionTypeId',
  dual_language_instruction_type_code STRING COMMENT 'src rows 986,1586,1655; DualLanguageInstructionTypeCode',
  dual_language_instruction_type_description STRING COMMENT 'src rows 987,1587,1656; DualLanguageInstructionTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_eligibility_outcome (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  eligibility_outcome_source_id STRING COMMENT 'src rows 1517; EligibilityOutcomeId',
  eligibility_outcome_code STRING COMMENT 'src rows 1518; EligibilityOutcomeCode',
  eligibility_outcome_description STRING COMMENT 'src rows 1519; EligibilityOutcome'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_exit (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  exit_description STRING COMMENT 'src rows 1423; ProgramExitReason',
  exit_code STRING COMMENT 'src rows 1424; ExitCode'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_exit_or_withdrawal_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  exit_or_withdrawal_type_code STRING COMMENT 'src rows 1067; WithdrawalCode',
  exit_or_withdrawal_type_description STRING COMMENT 'src rows 1068; WithdrawalType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_extended_learning_time_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  extended_learning_time_type_code STRING COMMENT 'src rows 1298; ExtendedLearningTimeTypeCode',
  extended_learning_time_type_description STRING COMMENT 'src rows 1299; ExtendedLearningTime'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_grade_level_at_placement (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  grade_level_at_placement_code STRING COMMENT 'src rows 1332; GradeLevelAtPlacementId',
  grade_level_at_placement_description STRING COMMENT 'src rows 1333; GradeLevelAtPlacement'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_home_based_attend_part_time (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  home_based_attend_part_time_code STRING COMMENT 'src rows 1092; HomeBasedAttendPartTimeCode',
  home_based_attend_part_time_description STRING COMMENT 'src rows 1094; HomeBasedAttendPartTimeDescription'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_homelessness (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  homelessness_code STRING COMMENT 'src rows 1096; HomelessCode',
  homelessness_description STRING COMMENT 'src rows 1098; HomelessDescription'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_identification_assessment (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  identification_assessment_code STRING COMMENT 'src rows 1288; IdentificationAssessmentCode',
  identification_assessment_description STRING COMMENT 'src rows 1289; IdentificationAssessment'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_iep_after3_reason (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  iep_after3_reason_source_id STRING COMMENT 'src rows 1520; IEPAfter3ReasonId',
  iep_after3_reason_code STRING COMMENT 'src rows 1521; IEPAfter3ReasonCode',
  iep_after3_reason_description STRING COMMENT 'src rows 1522; IEPAfter3Reason'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_incident_behavior (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  incident_behavior_source_id STRING COMMENT 'src rows 1011,1153; BehaviorId',
  incident_behavior_code STRING COMMENT 'src rows 1012,1154; BehaviorCode, BehaviorTypeCode',
  incident_behavior_description STRING COMMENT 'src rows 1013; BehaviorType',
  short_incident_behavior_description STRING COMMENT 'src rows 1155; BehaviorTypeName',
  long_incident_behavior_description STRING COMMENT 'src rows 1156; BehaviorTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_instructional_model (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  instructional_model_code STRING COMMENT 'src rows 1317; InstructionalModelId',
  instructional_model_description STRING COMMENT 'src rows 1318; InstructionalModel'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_interpreter_request_annual_iep_meet_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  interpreter_request_annual_iep_meet_type_source_id STRING COMMENT 'src rows 1499; InterpreterRequestAnnualIEPMeetTypeId',
  interpreter_request_annual_iep_meet_type_code STRING COMMENT 'src rows 1500; InterpreterRequestAnnualIEPMeetTypeCode',
  interpreter_request_annual_iep_meet_type_description STRING COMMENT 'src rows 1501; InterpreterRequestAnnualIEPMeetType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_interpreter_request_initial_iep_meet_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  interpreter_request_initial_iep_meet_type_source_id STRING COMMENT 'src rows 1525; InterpreterRequestTypeId',
  interpreter_request_initial_iep_meet_type_code STRING COMMENT 'src rows 1526; InterpreterRequestInitialIEPMeetTypeCode',
  interpreter_request_initial_iep_meet_type_description STRING COMMENT 'src rows 1527; InterpreterRequestInitialIEPMeetType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_interpreter_request_reengag_meeting_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  interpreter_request_reengag_meeting_type_source_id STRING COMMENT 'src rows 1196; InterpreterRequestReengagMeetingTypeId',
  interpreter_request_reengag_meeting_type_code STRING COMMENT 'src rows 1197; InterpreterRequestReengagMeetingTypeCode',
  interpreter_request_reengag_meeting_type_description STRING COMMENT 'src rows 1198; InterpreterRequestReengagMeetingType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_language (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  language_code STRING COMMENT 'src rows 1076,1078,1123; FamilyLanguageCode, LanguageSpokenatHomeCode, PrimaryLanguageCode',
  language_description STRING COMMENT 'src rows 1077,1079,1124; FamilyLanguage, LanguageSpokenatHome, PrimaryLanguage',
  language_source_id STRING COMMENT 'src rows 1122; FamilyLanguageId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_late_init_eval_reason (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  late_init_eval_reason_source_id STRING COMMENT 'src rows 1514; LateInitEvalReasonId',
  late_init_eval_reason_code STRING COMMENT 'src rows 1515; LateInitEvalReasonCode',
  late_init_eval_reason_description STRING COMMENT 'src rows 1516; LateInitEvalReason'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_letter_grade (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  letter_grade_code STRING COMMENT 'src rows 1394,1650; LetterGrade',
  letter_grade_description STRING COMMENT 'src rows 1395,1651; LetterGradeDesc',
  letter_grade_source_id STRING COMMENT 'src rows 1649; LetterGradeId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_lre_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  lre_type_code STRING COMMENT 'src rows 1455; LRETypeCode',
  lre_type_description STRING COMMENT 'src rows 1456; LREType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_military_parentor_guardian (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  military_parentor_guardian_source_id STRING COMMENT 'src rows 1108; MilitaryParentorGuardian',
  military_parentor_guardian_code STRING COMMENT 'src rows 1111; MilitaryParentorGuardianCD',
  military_parentor_guardian_description STRING COMMENT 'src rows 1112; MilitaryParentorGuardianDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_petition_time_frame (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  petition_time_frame_code STRING COMMENT 'src rows 1036,1179; PetitionTimeFrameCode, PetitiontoExceedMorethanOneYear',
  petition_time_frame_description STRING COMMENT 'src rows 1037,1180; PetitionTimeFrame, PetitionTimeFrameTypeDesc',
  petition_time_frame_source_id STRING COMMENT 'src rows 1178; PetitionTimeFrameId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_placement_test_code (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  placement_test_code_code STRING COMMENT 'src rows 1330; PlacementTestCodeId',
  placement_test_code_description STRING COMMENT 'src rows 1331; BilingualPlacementTest'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_pre_k_acq_know_entry (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  pre_k_acq_know_entry_source_id STRING COMMENT 'src rows 1481; PreKAcqKnowEntryId',
  pre_k_acq_know_entry_code STRING COMMENT 'src rows 1482; PreKAcqKnowEntryCode',
  pre_k_acq_know_entry_description STRING COMMENT 'src rows 1483; PreKAcqKnowEntry'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_pre_k_acq_know_exit (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  pre_k_acq_know_exit_source_id STRING COMMENT 'src rows 1487; PreKAcqKnowExitId',
  pre_k_acq_know_exit_code STRING COMMENT 'src rows 1488; PreKAcqKnowExitCode',
  pre_k_acq_know_exit_description STRING COMMENT 'src rows 1489; PreKAcqKnowExit'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_pre_k_acq_know_progres (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  pre_k_acq_know_progres_source_id STRING COMMENT 'src rows 1484; PreKAcqKnowProgresId',
  pre_k_acq_know_progres_code STRING COMMENT 'src rows 1485; PreKAcqKnowProgresCode',
  pre_k_acq_know_progres_description STRING COMMENT 'src rows 1486; PreKAcqKnowProgres'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_pre_k_behave_entry (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  pre_k_behave_entry_source_id STRING COMMENT 'src rows 1490; PreKBehaveEntryId',
  pre_k_behave_entry_code STRING COMMENT 'src rows 1491; PreKBehaveEntryCode',
  pre_k_behave_entry_description STRING COMMENT 'src rows 1492; PreKBehaveEntry'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_pre_k_behave_exit (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  pre_k_behave_exit_source_id STRING COMMENT 'src rows 1496; PreKBehaveExitId',
  pre_k_behave_exit_code STRING COMMENT 'src rows 1497; PreKBehaveExitCode',
  pre_k_behave_exit_description STRING COMMENT 'src rows 1498; PreKBehaveExit'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_pre_k_behave_progres (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  pre_k_behave_progres_source_id STRING COMMENT 'src rows 1493; PreKBehaveProgresId',
  pre_k_behave_progres_code STRING COMMENT 'src rows 1494; PreKBehaveProgresCode',
  pre_k_behave_progres_description STRING COMMENT 'src rows 1495; PreKBehaveProgres'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_pre_k_social_entry (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  pre_k_social_entry_source_id STRING COMMENT 'src rows 1472; PreKSocialEntryId',
  pre_k_social_entry_code STRING COMMENT 'src rows 1473; PreKSocialEntryCode',
  pre_k_social_entry_description STRING COMMENT 'src rows 1474; PreKSocialEntry'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_pre_k_social_exit (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  pre_k_social_exit_source_id STRING COMMENT 'src rows 1478; PreKSocialExitId',
  pre_k_social_exit_code STRING COMMENT 'src rows 1479; PreKSocialExitCode',
  pre_k_social_exit_description STRING COMMENT 'src rows 1480; PreKSocialExit'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_pre_k_social_progres (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  pre_k_social_progres_source_id STRING COMMENT 'src rows 1475; PreKSocialProgresId',
  pre_k_social_progres_code STRING COMMENT 'src rows 1476; PreKSocialProgresCode',
  pre_k_social_progres_description STRING COMMENT 'src rows 1477; PreKSocialProgres'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_primary_disability (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  primary_disability_code STRING COMMENT 'src rows 1086; DisabilityCode',
  primary_disability_description STRING COMMENT 'src rows 1088; DisabilityDescription'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_program (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  program_code STRING COMMENT 'src rows 1285,1419; ProgramCode, ProgramID',
  program_description STRING COMMENT 'src rows 1286; ProgramName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_program_designation (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  program_designation_code STRING COMMENT 'src rows 1328; ProgramDesignation',
  program_designation_description STRING COMMENT 'src rows 1329; BilingualProgramDesignation'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_program_exit_reason (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  program_exit_reason_code STRING COMMENT 'src rows 1458; ProgramExitReasonID',
  program_exit_reason_description STRING COMMENT 'src rows 1459; ExitReason'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_progress_monitoring_assessment (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  progress_monitoring_assessment_code STRING COMMENT 'src rows 1292; ProgressMonitoringAssessmentCode',
  progress_monitoring_assessment_description STRING COMMENT 'src rows 1293; ProgressMonitoringAssessment'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_qualification (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  qualification_code STRING COMMENT 'src rows 1425; QualificationCode',
  qualification_description STRING COMMENT 'src rows 1426; QualificationReason'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_reengagement_plan (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  reengagement_plan_source_id STRING COMMENT 'src rows 1039,1181; ReengagementPlanId, ReengagementPlanTypeId',
  reengagement_plan_code STRING COMMENT 'src rows 1040,1182; ReengagementPlanCode, ReengagementPlanTypeCode',
  reengagement_plan_description STRING COMMENT 'src rows 1041,1183; ReengagementPlanDescription, ReengagementPlanTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_schoolchoicetype (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  schoolchoicetype_code STRING COMMENT 'src rows 1069; SchoolchoicetypeID',
  schoolchoicetype_description STRING COMMENT 'src rows 1070; Schoolchoicetype'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_sequence (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  sequence_code STRING COMMENT 'src rows 994,1404,1663; SequenceCode',
  sequence_description STRING COMMENT 'src rows 995,1405,1664; SequenceName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_share_consent_transition_ag (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  share_consent_transition_ag_code STRING COMMENT 'src rows 1502; ShareConsentTransitionAgId',
  share_consent_transition_ag_description STRING COMMENT 'src rows 1503; ShareConsentTransitionAg'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_sharing (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  sharing_source_id STRING COMMENT 'src rows 1502; ShareConsentTransitionAgId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_staff_involvement_outcome (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  staff_involvement_outcome_code STRING COMMENT 'src rows 1194; StaffInvolvementOutcomeCode',
  staff_involvement_outcome_description STRING COMMENT 'src rows 1195; StaffInvolvementOutcome'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_staff_involvement_status (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  staff_involvement_status_code STRING COMMENT 'src rows 1190; StaffInvolvementStatusCode',
  staff_involvement_status_description STRING COMMENT 'src rows 1191; StaffInvolvementStatus'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_staff_involvement_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  staff_involvement_type_code STRING COMMENT 'src rows 1192; StaffInvolvementTypeCode',
  staff_involvement_type_description STRING COMMENT 'src rows 1193; StaffInvolvementType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_staff_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  staff_type_source_id STRING COMMENT 'src rows 1577; StaffTypeID',
  staff_type_code STRING COMMENT 'src rows 1578; StaffTypeCode',
  staff_type_description STRING COMMENT 'src rows 1579; StaffType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_state_course (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  state_course_code STRING COMMENT 'src rows 966,1231,1381,1546,1608; StateCourseCode',
  state_course_description STRING COMMENT 'src rows 967,1232,1382,1547,1609; StateCourseName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_teacher_indicator (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  teacher_indicator_code STRING COMMENT 'src rows 1575; TeacherIndicatorID',
  teacher_indicator_description STRING COMMENT 'src rows 1576; TeacherIndicator'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_tutoring_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  tutoring_type_code STRING COMMENT 'src rows 1300; TutoringTypeCode',
  tutoring_type_description STRING COMMENT 'src rows 1301; TutoringType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_weapon_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  weapon_type_source_id STRING COMMENT 'src rows 1019,1158; WeaponId',
  weapon_type_code STRING COMMENT 'src rows 1020,1159; WeaponCode, WeaponTypeCode',
  weapon_type_description STRING COMMENT 'src rows 1021; WeaponType',
  short_weapon_type_description STRING COMMENT 'src rows 1160; WeaponType',
  long_weapon_type_description STRING COMMENT 'src rows 1161; WeaponTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_wida_overall_placement_score (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  wida_overall_placement_score_code STRING COMMENT 'src rows 1336; WIDAOverallPlacementScoreId',
  wida_overall_placement_score_description STRING COMMENT 'src rows 1337; WIDAOverallPlacementScore'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cedars_work_based_learning_activity_type (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  work_based_learning_activity_type_code STRING COMMENT 'src rows 1275,1666; WorkBasedLearningActivityTypeCode',
  work_based_learning_activity_type_description STRING COMMENT 'src rows 1276,1667; WorkBasedLearningActivityTypeName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_conformed.ref.cip_code (
  source_system STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  bronze_batch_id STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  silver_loaded_at TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  basic_skill_cat STRING COMMENT 'src rows 2154; BASIC_SKILL_CAT',
  career_cluster_code STRING COMMENT 'src rows 2155; CAREER_CLUSTER_CODE',
  cip_code STRING COMMENT 'src rows 2156; CIP',
  cip_aggregate STRING COMMENT 'src rows 2157; CIP_AGGREGATE',
  cip_discipline STRING COMMENT 'src rows 2158; CIP_DISCIPLINE',
  cip_fac_aggregate STRING COMMENT 'src rows 2159; CIP_FAC_AGGREGATE',
  cip_grp STRING COMMENT 'src rows 2160; CIP_GRP',
  cip_title STRING COMMENT 'src rows 2161; CIP_TITLE',
  cip_type STRING COMMENT 'src rows 2162; CIP_TYPE',
  bs_ind STRING COMMENT 'src rows 2187; BS_IND',
  first_approved STRING COMMENT 'src rows 2283; FIRST_APPROVED',
  last_approved STRING COMMENT 'src rows 2374; LAST_APPROVED',
  revised STRING COMMENT 'src rows 2412; REVISED',
  subj_cluster STRING COMMENT 'src rows 2448; SUBJ_CLUSTER'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

