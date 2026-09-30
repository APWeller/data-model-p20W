-- Gold-layer Delta DDL for model A (generated). Types marked inferred in the lineage file should be
-- confirmed during silver profiling.

CREATE SCHEMA IF NOT EXISTS p20w_gold_ceds.ceds_aligned;
CREATE SCHEMA IF NOT EXISTS p20w_gold_ceds.ceds_ext;
CREATE SCHEMA IF NOT EXISTS p20w_gold_ceds.ceds_rds;
CREATE SCHEMA IF NOT EXISTS p20w_gold_ceds.conformed;
CREATE SCHEMA IF NOT EXISTS p20w_gold_ceds.identity;

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.BridgeElClassSectionFundingModels (
  BridgeElClassSectionFundingModelId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ClassScheduleFundingModelId STRING COMMENT 'src rows 128; ClassScheduleFundingModelId',
  FundingModelTypeId STRING COMMENT 'src rows 129; FundingModelTypeId'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.BridgeElClassSectionMeetingPatterns (
  BridgeElClassSectionMeetingPatternId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ScheduleRecurrenceTypeId STRING COMMENT 'src rows 133; ScheduleRecurrenceTypeId',
  WeekNumber DECIMAL(12,3) COMMENT 'src rows 134; WeekNumber',
  Interval DECIMAL(12,3) COMMENT 'src rows 135; Interval',
  ClassScheduleRecurrenceId STRING COMMENT 'src rows 136; ClassScheduleRecurrenceId',
  DayOfWeek STRING COMMENT 'src rows 137; DayOfWeek',
  ClassBeginningTime STRING COMMENT 'src rows 138; StartTime',
  ClassEndingTime STRING COMMENT 'src rows 139; EndTime',
  DayScheduleId STRING COMMENT 'src rows 140; DayScheduleId'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.BridgeElClassSectionStaffPositions (
  BridgeElClassSectionStaffPositionId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ClassSchedulePositionId STRING COMMENT 'src rows 130; ClassSchedulePositionId',
  StaffRoleTypeId STRING COMMENT 'src rows 131; StaffRoleTypeId',
  IsPresentForAllHours BOOLEAN COMMENT 'src rows 132; IsPresentForAllHours'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.BridgeElOrganizationRelationships (
  BridgeElOrganizationRelationshipId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ContractorOrganizationId BIGINT COMMENT 'src rows 142; ContractorID',
  SubcontractorOrganizationId BIGINT COMMENT 'src rows 145; SubcontractorID',
  SiteOrganizationId BIGINT COMMENT 'src rows 148,154; SiteID',
  OrganizationRelationshipId BIGINT COMMENT 'src rows 151; OrganizationRelationshipId',
  SchoolYearId BIGINT COMMENT 'src rows 152,156; SchoolYearId',
  SourceSchoolYearId STRING COMMENT 'src rows 152,156; SchoolYearId',
  AddressId STRING COMMENT 'src rows 157; AddressId'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.BridgeFinancialAidAwardPsTermEnrollments (
  BridgeFinancialAidAwardPsTermEnrollmentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PsEnrollmentStatusCode STRING COMMENT 'src rows 2514,2515,2516,2517,2518; EnrollmentFall, EnrollmentSpring, EnrollmentSummer1, EnrollmentSummer2, EnrollmentWinter'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.DimApprenticeshipPrograms (
  DimApprenticeshipProgramsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ProgramIdentifier STRING COMMENT 'src rows 809; Program Id',
  OccupationId STRING COMMENT 'src rows 811; Occupation Id',
  OccupationName STRING COMMENT 'src rows 812; Occupation Name',
  StandardOccupationalClassificationId STRING COMMENT 'src rows 813; Soc Code',
  TermInHours DECIMAL(12,3) COMMENT 'src rows 824; Term In Hours',
  ProgramRsiHours DECIMAL(12,3) COMMENT 'src rows 830; Program RSIHours',
  SubProgram STRING COMMENT 'src rows 857; Sub Program'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.DimElClassSections (
  DimElClassSectionsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ClassName STRING COMMENT 'src rows 120; ClassName',
  SchoolYearId BIGINT COMMENT 'src rows 121; SchoolYearId',
  SourceSchoolYearId STRING COMMENT 'src rows 121; SchoolYearId',
  ElSiteOrganizationId BIGINT COMMENT 'src rows 122; OrganizationRelationshipId',
  TotalClassroomDays DECIMAL(12,3) COMMENT 'src rows 123; TotalClassroomDays',
  LanguageOfInstruction STRING COMMENT 'src rows 141; LanguageOfInstruction'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.DimPsCourseSections (
  DimPsCourseSectionsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CourseSectionIdentifier STRING COMMENT 'src rows 2040,2371,2416; ITEM, SECTION, section',
  AcademicTermDesignatorId BIGINT COMMENT 'src rows 2164,2251,2433; QUARTER, STRM, YRQ',
  SourceQuarter STRING COMMENT 'src rows 2164; QUARTER',
  SchoolYearId BIGINT COMMENT 'src rows 2165; YEAR',
  SourceYear STRING COMMENT 'src rows 2165; YEAR',
  InstitInt STRING COMMENT 'src rows 2168; INSTIT_INT',
  InstitIntCat STRING COMMENT 'src rows 2169; INSTIT_INT_CAT',
  InstitIntentRecat STRING COMMENT 'src rows 2170,2294; INSTIT_INTENT_RECAT',
  ClassificationOfInstructionalProgramCode STRING COMMENT 'src rows 2171,2286; CIP',
  CipCluster STRING COMMENT 'src rows 2172; CIP_CLUSTER',
  CipGrp STRING COMMENT 'src rows 2173; CIP_GRP',
  PsInstitutionId BIGINT COMMENT 'src rows 2180,2357; COLLEGE, INSTITUTION',
  Bldg STRING COMMENT 'src rows 2186; BLDG',
  CourseSectionMaximumCapacity STRING COMMENT 'src rows 2189; CLASS_CAP',
  ClockHr DECIMAL(12,3) COMMENT 'src rows 2190; CLOCK_HR',
  ClockHrEquiv DECIMAL(12,3) COMMENT 'src rows 2191; CLOCK_HR_EQUIV',
  ClockHrIndicator DECIMAL(12,3) COMMENT 'src rows 2194; CLOCK_HR_INDICATOR',
  ClusterItm STRING COMMENT 'src rows 2195; CLUSTER_ITM',
  DistanceEducationCourseEnrollment STRING COMMENT 'src rows 2196,2288,2308; DIST_ED, INSTRUCTION_MODE',
  Doc STRING COMMENT 'src rows 2197; DOC',
  DocSiteOrganizationId BIGINT COMMENT 'src rows 2198; DOC_SITE',
  ContSeq STRING COMMENT 'src rows 2201; CONT_SEQ',
  CreditValue DECIMAL(12,3) COMMENT 'src rows 2204,2205; COURSE_CREDITS',
  FundSource STRING COMMENT 'src rows 2215; FUND_SOURCE',
  FundSourceCat STRING COMMENT 'src rows 2216; FUND_SOURCE_CAT',
  CreditEquiv DECIMAL(12,3) COMMENT 'src rows 2221; CREDIT_EQUIV',
  CreditEquivSrc DECIMAL(12,3) COMMENT 'src rows 2222; CREDIT_EQUIV_SRC',
  DayCode STRING COMMENT 'src rows 2231; DAY_CODE',
  DayTitle STRING COMMENT 'src rows 2232; DAY_TITLE',
  ClassMeetingDays DECIMAL(12,3) COMMENT 'src rows 2233; DAYS',
  SourceYrq STRING COMMENT 'src rows 2251; YRQ',
  SessionEndDate STRING COMMENT 'src rows 2264; END_DATE',
  ClassEndingTime STRING COMMENT 'src rows 2265; END_TIME',
  EnrollmentCountMethod DECIMAL(12,3) COMMENT 'src rows 2273; ENROLLMENT_COUNT_METHOD',
  Hegis STRING COMMENT 'src rows 2330; HEGIS',
  HegisCluster STRING COMMENT 'src rows 2334; HEGIS_CLUSTER',
  PctExternallyFunded DECIMAL(12,3) COMMENT 'src rows 2377; PCT_EXTERNALLY_FUNDED',
  RecordCode STRING COMMENT 'src rows 2391,2396; RECORD_CODE',
  RecordKey STRING COMMENT 'src rows 2401; RECORD_KEY',
  Room STRING COMMENT 'src rows 2413; ROOM',
  SectionStat STRING COMMENT 'src rows 2417; SECTION_STAT',
  SectionStatOne STRING COMMENT 'src rows 2418; SECTION_STAT_ONE',
  SourceStrm STRING COMMENT 'src rows 2433; STRM',
  SessionBeginDate STRING COMMENT 'src rows 2441; STRT_DATE',
  ClassBeginningTime STRING COMMENT 'src rows 2442; STRT_TIME',
  TenDayClass STRING COMMENT 'src rows 2453; TEN_DAY_CLASS',
  TimeLoc STRING COMMENT 'src rows 2455; TIME_LOC',
  VarCredit DECIMAL(12,3) COMMENT 'src rows 2463; VAR_CREDIT',
  Waol STRING COMMENT 'src rows 2466,2467; WAOL',
  WeeklyHrClin STRING COMMENT 'src rows 2468; WEEKLY_HR_CLIN',
  WeeklyHrLab STRING COMMENT 'src rows 2469; WEEKLY_HR_LAB',
  WeeklyHrLec STRING COMMENT 'src rows 2470; WEEKLY_HR_LEC',
  WeeklyHrOthr DECIMAL(12,3) COMMENT 'src rows 2471; WEEKLY_HR_OTHR',
  WeeklyHrSys STRING COMMENT 'src rows 2472; WEEKLY_HR_SYS',
  WeeklyHrTot STRING COMMENT 'src rows 2473; WEEKLY_HR_TOT',
  WorkBasedInd STRING COMMENT 'src rows 2475,2476; WORK_BASED_IND',
  CnedType STRING COMMENT 'src rows 2200; CNED_TYPE',
  BasicSkillCat STRING COMMENT 'src rows 2287; BASIC_SKILL_CAT',
  InstitIntentCat STRING COMMENT 'src rows 2293; INSTIT_INTENT_CAT'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.DimPsPrograms (
  DimPsProgramsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 2011; academic_year',
  SourceAcademicYear STRING COMMENT 'src rows 2011; academic_year',
  Concentration DECIMAL(12,3) COMMENT 'src rows 2012; concentration',
  ConcentrationCip DECIMAL(12,3) COMMENT 'src rows 2013; concentration_CIP',
  ConcentrationDescription DECIMAL(12,3) COMMENT 'src rows 2014; concentration_description',
  ConcentrationInstitutionalCode STRING COMMENT 'src rows 2015; concentration_institutional_code',
  CreditValue DECIMAL(12,3) COMMENT 'src rows 2016; credits_required',
  Degree STRING COMMENT 'src rows 2017,2430; DEGREE, degree',
  DegreeAcronym STRING COMMENT 'src rows 2018; degree_acronym',
  AcademicAwardLevelConferred STRING COMMENT 'src rows 2019; degree_level',
  FieldOfStudy STRING COMMENT 'src rows 2020; field_of_study',
  FieldOfStudyInstitutionalCode STRING COMMENT 'src rows 2021; field_of_study_institutional_code',
  CipCodeId STRING COMMENT 'src rows 2022,2425; CIP_CODE, field_of_study_CIP',
  PsInstitutionId BIGINT COMMENT 'src rows 2023; institution',
  SourceRecordNumber STRING COMMENT 'src rows 2024; record_number',
  ProgramIdentifier STRING COMMENT 'src rows 2025,2427; ACAD_PLAN, program',
  AcademicTermDesignatorId BIGINT COMMENT 'src rows 2026; term',
  SourceTerm STRING COMMENT 'src rows 2026; term',
  Descr STRING COMMENT 'src rows 2237; DESCR',
  AcadCareer STRING COMMENT 'src rows 2426; ACAD_CAREER',
  AcadProg STRING COMMENT 'src rows 2428; ACAD_PROG',
  Subplan STRING COMMENT 'src rows 2449; SUBPLAN',
  SubplanDescr STRING COMMENT 'src rows 2451; SUBPLAN_DESCR',
  TrnscrDescr STRING COMMENT 'src rows 2462; TRNSCR_DESCR'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.DimTeacherPrepPrograms (
  DimTeacherPrepProgramsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 378; year',
  SourceYear STRING COMMENT 'src rows 378; year',
  PsInstitutionId BIGINT COMMENT 'src rows 379; inst_code',
  ProgAwardName STRING COMMENT 'src rows 380; prog_award_name',
  program_identifier STRING COMMENT 'src rows 381; prog_id',
  ProgTermType STRING COMMENT 'src rows 382; prog_term_type',
  ProgAwardLevel STRING COMMENT 'src rows 383; prog_award_level',
  ProgAwardReqCred STRING COMMENT 'src rows 384; prog_award_req_cred',
  ProgLengthMin STRING COMMENT 'src rows 385; prog_length_min',
  ProgLengthMax STRING COMMENT 'src rows 386; prog_length_max',
  ProgField STRING COMMENT 'src rows 387; prog_field',
  CipCodeId STRING COMMENT 'src rows 388; prog_field_CIP',
  ProgConc STRING COMMENT 'src rows 389; prog_conc',
  ProgConcCip STRING COMMENT 'src rows 390; prog_conc_CIP'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactApprenticeshipRegistrations (
  FactApprenticeshipRegistrationId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PersonId BIGINT COMMENT 'src rows 804; Apprentice Id',
  ApprenticeshipProgramId STRING COMMENT 'src rows 809; Program Id',
  ApprenticeshipSponsorOrganizationId BIGINT COMMENT 'src rows 809; Program Id',
  EnrollmentEntryDate DATE COMMENT 'src rows 814; Registration Date',
  CurrentStatus STRING COMMENT 'src rows 815; Current Status',
  StatusDate DATE COMMENT 'src rows 816; Status Date',
  PreviousCredit DECIMAL(12,3) COMMENT 'src rows 817; Previous Credit',
  AdditionalCredit DECIMAL(12,3) COMMENT 'src rows 818; Additional Credit',
  OjtWorkHours DECIMAL(12,3) COMMENT 'src rows 819; OJTWork Hours',
  OjtFinalHours DECIMAL(12,3) COMMENT 'src rows 820; OJTFinal Hours',
  TotalOjtHours DECIMAL(12,3) COMMENT 'src rows 821; Total OJTHours',
  AnticipatedOjtHours DECIMAL(12,3) COMMENT 'src rows 822; Anticipated OJTHours',
  OjtPercentage DECIMAL(12,3) COMMENT 'src rows 823; OJTPercentage',
  RsiCreditedHours DECIMAL(12,3) COMMENT 'src rows 825; RSICredited Hours',
  RsiReportedHours DECIMAL(12,3) COMMENT 'src rows 826; RSIReported Hours',
  TotalRsiHours DECIMAL(12,3) COMMENT 'src rows 827; Total RSIHours',
  AnticipatedRsiHours DECIMAL(12,3) COMMENT 'src rows 828; Anticipated RSIHours',
  RsiPercentage DECIMAL(12,3) COMMENT 'src rows 829; RSIPercentage',
  QuarterCount DECIMAL(12,3) COMMENT 'src rows 831; Quarter Count',
  RsiReportedQuarterCount DECIMAL(12,3) COMMENT 'src rows 832; RSIReported Quarter Count',
  ProbationStartDate DATE COMMENT 'src rows 833; Probation Start Date',
  ProbationEndDate DATE COMMENT 'src rows 834; Probation End Date',
  YearsInProgram STRING COMMENT 'src rows 835; Years In Program',
  AnticipatedCompletionDate DATE COMMENT 'src rows 836; Anticipated Completion Date',
  InitialStepNumber STRING COMMENT 'src rows 837; Initial Step Number',
  InitialStepEffDate DATE COMMENT 'src rows 838; Initial Step Eff Date',
  CurrentStepEffDate DATE COMMENT 'src rows 839; Current Step Eff Date',
  TransferDate DATE COMMENT 'src rows 840; Transfer Date',
  Age DECIMAL(12,3) COMMENT 'src rows 842; Age',
  City STRING COMMENT 'src rows 848; City',
  State STRING COMMENT 'src rows 849; State',
  ZipCode STRING COMMENT 'src rows 850; Zip Code',
  Education STRING COMMENT 'src rows 854; Education',
  DirectEntryFlag STRING COMMENT 'src rows 855; Direct Entry Flag',
  OtherLicense STRING COMMENT 'src rows 856; Other License'
)
USING DELTA
CLUSTER BY (PersonId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactCollegeBoundScholarshipPledges (
  FactCollegeBoundScholarshipPledgeId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CbsPledgeId STRING COMMENT 'src rows 2584,2622; CBSPledgeID, CBSPledgeId',
  PersonId BIGINT COMMENT 'src rows 2585,2586,2623,2624; ApplicationSSID, ApplicationSSId, LastReportedSSID, LastReportedSSId',
  SchoolYearId BIGINT COMMENT 'src rows 2588,2650; ApplicationAcademicYear',
  SourceApplicationAcademicYear STRING COMMENT 'src rows 2588,2650; ApplicationAcademicYear',
  ApplicationStudentGrade STRING COMMENT 'src rows 2589,2634; ApplicationStudentGrade',
  Cohort STRING COMMENT 'src rows 2590,2649; Cohort',
  ExpectedHsGradYear STRING COMMENT 'src rows 2591,2661; ExpectedHSGradYear',
  GuardianAddressZip STRING COMMENT 'src rows 2600,2633; GuardianAddressZip',
  GuardianEducationLevel STRING COMMENT 'src rows 2602,2643; GuardianEducationLevel',
  ExpectedStudentGrade STRING COMMENT 'src rows 2603; ExpectedStudentGrade',
  LastReportedStudentGrade STRING COMMENT 'src rows 2604,2657; LastReportedStudentGrade',
  LastReportedGpa DECIMAL(12,3) COMMENT 'src rows 2605,2652; LastReportedGPA',
  LastOspiEnrollmentStatusCode STRING COMMENT 'src rows 2606,2679; LastOSPIEnrollmentStatusCode',
  LastReportedHsGradReqYear STRING COMMENT 'src rows 2607,2667; LastReportedHSGradReqYear',
  LastReportedExpectedHsGradYr STRING COMMENT 'src rows 2608; LastReportedExpectedHSGradYr',
  ActualHsGradYear STRING COMMENT 'src rows 2609,2666; ActualHSGradYear',
  HsRequirementsMet STRING COMMENT 'src rows 2610,2680; HSRequirementsMet',
  ApplicationSchoolOrganizationId BIGINT COMMENT 'src rows 2611,2639,2640; ApplicationSchoolCode, SchoolId',
  LastReportedSchoolOrganizationId BIGINT COMMENT 'src rows 2612,2625,2653; LastReportedSchCode, LastReportedSchoolCode',
  MatchedWithOspi STRING COMMENT 'src rows 2613,2660; MatchedWithOSPI',
  SourceOspiExtractDate DATE COMMENT 'src rows 2614; OSPIExtractDate',
  FafsaMatch STRING COMMENT 'src rows 2615,2662; FafsaMatch',
  OnlineApplication STRING COMMENT 'src rows 2616,2637,2681; IsOnlineApp, OnlineApplication',
  ApplicationLanguage DECIMAL(12,3) COMMENT 'src rows 2617,2638; ApplicationLanguage',
  PledgeCount DECIMAL(12,3) COMMENT 'src rows 2618; PledgeCount',
  CbsPledgeId1 STRING COMMENT 'src rows 2619; CBSPledgeID1',
  CbsPledgeId2 STRING COMMENT 'src rows 2620; CBSPledgeID2',
  CbsPledgeId3 STRING COMMENT 'src rows 2621; CBSPledgeID3',
  CbsApplicationStatusIndex STRING COMMENT 'src rows 2635; CBSApplicationStatusIndex',
  ApplicationAcademicYearIndex STRING COMMENT 'src rows 2636; ApplicationAcademicYearIndex',
  CbsApplicationStatus STRING COMMENT 'src rows 2641; CBSApplicationStatus',
  Complete STRING COMMENT 'src rows 2642; Complete',
  ApplicationLeaOrganizationId BIGINT COMMENT 'src rows 2645; ApplicationDistrictCode',
  ApplicationEsdOrganizationId BIGINT COMMENT 'src rows 2647; ApplicationESDNumber',
  GradYear STRING COMMENT 'src rows 2648; GradYear',
  ApplicationSchoolType STRING COMMENT 'src rows 2651; ApplicationSchoolType',
  LastReportedLeaOrganizationId BIGINT COMMENT 'src rows 2655; LastReportedDistrictCode',
  LastReportedSchoolType STRING COMMENT 'src rows 2658; LastReportedSchoolType',
  LeftOspiSystem STRING COMMENT 'src rows 2659; LeftOSPISystem',
  FafsaMatchDate DATE COMMENT 'src rows 2663; FAFSAMatchDate',
  CbsApplicantType STRING COMMENT 'src rows 2664; CBSApplicantType',
  ApplicationDate DATE COMMENT 'src rows 2665; PledgeSubmissionDate',
  HsGraduationAcademicYearIndex STRING COMMENT 'src rows 2668; HSGraduationAcademicYearIndex',
  CbshsRequirementsMetIndex STRING COMMENT 'src rows 2670; CBSHSRequirementsMetIndex',
  CbshsRequirementsMet STRING COMMENT 'src rows 2671; CBSHSRequirementsMet',
  BadAddress STRING COMMENT 'src rows 2672; BadAddress',
  RunningStart STRING COMMENT 'src rows 2673; RunningStart',
  CteDualCredit DECIMAL(12,3) COMMENT 'src rows 2674; CteDualCredit',
  CollegeInTheHighSchool STRING COMMENT 'src rows 2675; CollegeInTheHighSchool',
  EnrolledInCollege STRING COMMENT 'src rows 2676; EnrolledInCollege',
  HomeZip STRING COMMENT 'src rows 2678; HomeZip',
  IsEligibleIncome DECIMAL(14,2) COMMENT 'src rows 2682; IsEligibleIncome',
  IsEligibleFrpl STRING COMMENT 'src rows 2683; IsEligibleFRPL',
  IsEligibleTanf STRING COMMENT 'src rows 2684; IsEligibleTANF',
  HasBothSignaturesBv STRING COMMENT 'src rows 2685; HasBothSignatures_BV',
  HaveGLastN1 STRING COMMENT 'src rows 2686; HaveGLastN1',
  HaveGLastN2 STRING COMMENT 'src rows 2687; HaveGLastN2',
  HaveGEmail1 STRING COMMENT 'src rows 2688; HaveGEmail1',
  HaveGEmail2 STRING COMMENT 'src rows 2689; HaveGEmail2',
  HaveGhPhone STRING COMMENT 'src rows 2690; HaveGHPhone',
  HaveGTxPhone STRING COMMENT 'src rows 2691; HaveGTxPhone',
  HaveSPhone STRING COMMENT 'src rows 2692; HaveSPhone',
  HaveSTxPhone STRING COMMENT 'src rows 2693; HaveSTxPhone',
  HaveStEmail STRING COMMENT 'src rows 2694; HaveSTEmail',
  AutoEnrolledBv STRING COMMENT 'src rows 2696; AutoEnrolled_BV'
)
USING DELTA
CLUSTER BY (PersonId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactElChildAssessments (
  FactElChildAssessmentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PersonId BIGINT COMMENT 'src rows 302,327,332,358,361; ChildID, ELMS_SSID, SSID, SourceChildID, StudentID',
  AssessmentResultScoreValueRawScore DECIMAL(12,3) COMMENT 'src rows 309,316,330,334,336,340,343,346; CG_RS, LA_RS, LI_RS, MA_RS, PH_RS, SE_RS, SLA_RS, SLI_RS',
  AssessmentResultScoreValueScaleScore DECIMAL(12,3) COMMENT 'src rows 310,317,331,335,337,341,344,347; CG_SS, LA_SS, LI_SS, MA_SS, PH_SS, SE_SS, SLA_SS, SLI_SS',
  AssessmentAdministrationId BIGINT COMMENT 'src rows 325; season',
  SchoolYearId BIGINT COMMENT 'src rows 326; year',
  ElSiteOrganizationId BIGINT COMMENT 'src rows 348; SiteID',
  ElContractorOrganizationId BIGINT COMMENT 'src rows 356,357; ECEAP_Contractor, ELMS_Contractor_ID'
)
USING DELTA
CLUSTER BY (PersonId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactElChildEnrollments (
  FactElChildEnrollmentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ElClassSectionId STRING COMMENT 'src rows 117; ClassScheduleId',
  EnrollmentEntryDate DATE COMMENT 'src rows 118,194,199; ActualStartDate, EnrollmentDate, FirstServiceDate',
  EnrollmentExitDate DATE COMMENT 'src rows 119,196; ExitServiceDate, LastDateAttended',
  PersonId BIGINT COMMENT 'src rows 180; ChildKey',
  ElContractorOrganizationId BIGINT COMMENT 'src rows 181; Contractor',
  SchoolYearId BIGINT COMMENT 'src rows 222; ProgramYear',
  ElSiteOrganizationId BIGINT COMMENT 'src rows 231; SiteCodeAlpha'
)
USING DELTA
CLUSTER BY (PersonId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactElChildIndividualizedPrograms (
  FactElChildIndividualizedProgramId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ChildIepId STRING COMMENT 'src rows 99; ChildIEPId',
  IepCreatedDate DATE COMMENT 'src rows 100; IEPCreatedDate',
  IepExpirationDate DATE COMMENT 'src rows 101; IEPExpirationDate',
  IdeaDisabilityTypeId STRING COMMENT 'src rows 102; DisabilityTypeId'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactElChildPartCParticipations (
  FactElChildPartCParticipationId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PersonId BIGINT COMMENT 'src rows 239; ChildId',
  CountyTypeId STRING COMMENT 'src rows 246; CountyTypeId',
  ElProviderOrganizationId BIGINT COMMENT 'src rows 240; ESITOrganizationId',
  ZipCode STRING COMMENT 'src rows 247; ZipCode',
  StateTypeId STRING COMMENT 'src rows 248; StateTypeId'
)
USING DELTA
CLUSTER BY (PersonId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactElChildServicesApplications (
  FactElChildServicesApplicationId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 82,112,113,127,153; SchoolYear, SchoolYearID, SchoolYearId',
  SourceSchoolYearId STRING COMMENT 'src rows 82,112; SchoolYearID, SchoolYearId',
  ApplicationId STRING COMMENT 'src rows 104; ApplicationId',
  ApplicationDataId STRING COMMENT 'src rows 105; ApplicationDataId',
  IepLeaId BIGINT COMMENT 'src rows 97,106; IEPSchoolDistrictCode, IEPSchoolDistrictId',
  FamilyIncome DECIMAL(14,2) COMMENT 'src rows 107,109; AnnualFamilyIncomeForEligibility, MonthlyFamilyIncomeForEligibilit',
  AnnualFederalPovertyLevel DECIMAL(14,2) COMMENT 'src rows 108; AnnualFederalPovertyLevel',
  MonthlyFederalPovertyLevel DECIMAL(14,2) COMMENT 'src rows 110; MonthlyFederalPovertyLevel',
  ResidesWithTypeId STRING COMMENT 'src rows 111; ResidesWithTypeId',
  ReportingFpl DECIMAL(14,2) COMMENT 'src rows 114; ReportingFPL',
  ResidentLeaId BIGINT COMMENT 'src rows 96; SchoolDistrictCode',
  CountyNumber DECIMAL(12,3) COMMENT 'src rows 98; CountyNumber',
  ProgramTypeCode STRING COMMENT 'src rows 103; ProgramTypeId',
  SourceSchoolYear STRING COMMENT 'src rows 113,127,153; SchoolYear'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactElChildSubsidyServices (
  FactElChildSubsidyServiceId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ElProviderOrganizationId BIGINT COMMENT 'src rows 274; providernumber',
  PersonId BIGINT COMMENT 'src rows 276; UniqueSRIdentifer',
  HouseholdPersonId BIGINT COMMENT 'src rows 279; CaseNumber',
  AuthNumber STRING COMMENT 'src rows 280; AuthNumber',
  AuthLine STRING COMMENT 'src rows 281; AuthLine',
  ServiceMonthDateId STRING COMMENT 'src rows 282; MonthOfService',
  ServiceCode STRING COMMENT 'src rows 283; ServiceCode',
  ServiceName STRING COMMENT 'src rows 284; ServiceName',
  ServiceUnitType STRING COMMENT 'src rows 285; ServiceUnitType'
)
USING DELTA
CLUSTER BY (PersonId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactEmployerQuarterlyEstablishments (
  FactEmployerQuarterlyEstablishmentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 664; Year',
  SourceYear STRING COMMENT 'src rows 664; Year',
  AcademicTermDesignatorId BIGINT COMMENT 'src rows 665; Quarter',
  SourceQuarter STRING COMMENT 'src rows 665; Quarter',
  EmployerId BIGINT COMMENT 'src rows 667; UI Account number',
  EmployerReportingUnitOrganizationId BIGINT COMMENT 'src rows 668; Reporting Unit Number (RUN)',
  CesIndicator STRING COMMENT 'src rows 712; CES Indicator',
  ArsResponseCode STRING COMMENT 'src rows 713; ARS Response Code',
  ArsRefileYear STRING COMMENT 'src rows 714; ARS Refile Year',
  ArsVerificationYear STRING COMMENT 'src rows 717; ARS Verification Year',
  MwrMailIndicator STRING COMMENT 'src rows 720; MWR Mail Indicator',
  DataSource STRING COMMENT 'src rows 722; Data Source',
  FirstMonthEmployment STRING COMMENT 'src rows 733; First Month Employment',
  FirstMonthEmploymentIndicator STRING COMMENT 'src rows 734; First Month Employment Indicator',
  SecondMonthEmployment STRING COMMENT 'src rows 735; Second Month Employment',
  SecondMonthEmploymentIndicator STRING COMMENT 'src rows 736; Second Month Employment Indicator',
  ThirdMonthEmployment STRING COMMENT 'src rows 737; Third Month Employment',
  ThirdMonthEmploymentIndicator STRING COMMENT 'src rows 738; Third Month Employment Indicator',
  TotalWages DECIMAL(14,2) COMMENT 'src rows 739; Total Wages',
  TotalWageIndicator STRING COMMENT 'src rows 740; Total Wage Indicator',
  TaxableWages DECIMAL(14,2) COMMENT 'src rows 741; Taxable Wages',
  ContributionsDue DECIMAL(14,2) COMMENT 'src rows 742; Contributions Due',
  ReportingChangeIndicator STRING COMMENT 'src rows 745; Reporting Change Indicator',
  FirstCommentCode STRING COMMENT 'src rows 746; First Comment Code',
  SecondCommentCode STRING COMMENT 'src rows 747; Second Comment Code',
  ThirdCommentCode STRING COMMENT 'src rows 748; Third Comment Code',
  NarrativeComment STRING COMMENT 'src rows 749; Narrative Comment',
  CollectionModeIndicator STRING COMMENT 'src rows 750; Collection Mode Indicator',
  EconomicCodeChangeIndicatorEcci STRING COMMENT 'src rows 751; Economic Code Change Indicator (ECCI)'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactFinancialAidAwards (
  FactFinancialAidAwardId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceRecordNumber STRING COMMENT 'src rows 2480; WSACRecordNumber',
  FinancialAidYearDesignator STRING COMMENT 'src rows 2481; AwardYear',
  PsInstitutionId BIGINT COMMENT 'src rows 2482; WSACInstitutionCode',
  PsStudentId BIGINT COMMENT 'src rows 2484,2582,2583; StudentID, WSACSampleId, WSACStudentIdNumber',
  MaritalStatus STRING COMMENT 'src rows 2492; MaritalStatus',
  Resident STRING COMMENT 'src rows 2493; Resident',
  StudentClass STRING COMMENT 'src rows 2494; StudentClass',
  FamilyIncome DECIMAL(14,2) COMMENT 'src rows 2502; FamilyIncome',
  FamilyIncomePercentOfMfi DECIMAL(14,2) COMMENT 'src rows 2503; FamilyIncomePercentOfMFI',
  NumberOfPeopleInHousehold DECIMAL(12,3) COMMENT 'src rows 2504; FamilySize',
  FamilyInCollege STRING COMMENT 'src rows 2505; FamilyInCollege',
  AdjustedFamilySize DECIMAL(12,3) COMMENT 'src rows 2506; AdjustedFamilySize',
  CostOfAttendance DECIMAL(14,2) COMMENT 'src rows 2507; CostOfAttendance',
  ExpectedFamilyContribution DECIMAL(14,2) COMMENT 'src rows 2508; ExpectedFamilyContribution',
  ParentContribution DECIMAL(14,2) COMMENT 'src rows 2509; ParentContribution',
  StudentContribution DECIMAL(14,2) COMMENT 'src rows 2510; StudentContribution',
  FinancialNeed DECIMAL(14,2) COMMENT 'src rows 2511; NeedAmount',
  NeedDuration DECIMAL(12,3) COMMENT 'src rows 2512; NeedDuration',
  DependencyStatus STRING COMMENT 'src rows 2513; DependencyStatus',
  EnrollmentFall STRING COMMENT 'src rows 2514; EnrollmentFall',
  EnrollmentWinter STRING COMMENT 'src rows 2515; EnrollmentWinter',
  EnrollmentSpring STRING COMMENT 'src rows 2516; EnrollmentSpring',
  EnrollmentSummer1 STRING COMMENT 'src rows 2517; EnrollmentSummer1',
  EnrollmentSummer2 STRING COMMENT 'src rows 2518; EnrollmentSummer2',
  FafsaOnFile STRING COMMENT 'src rows 2519; FAFSAOnFile',
  AllAidTotal DECIMAL(14,2) COMMENT 'src rows 2520; AllAidTotal',
  FedAidTotal DECIMAL(14,2) COMMENT 'src rows 2521; FedAidTotal',
  StateAidTotal DECIMAL(14,2) COMMENT 'src rows 2522; StateAidTotal',
  InstAidTotal DECIMAL(14,2) COMMENT 'src rows 2523; InstAidTotal',
  OtherAidTotal DECIMAL(14,2) COMMENT 'src rows 2524; OtherAidTotal',
  GrantAidTotal DECIMAL(14,2) COMMENT 'src rows 2525; GrantAidTotal',
  WorkAidTotal DECIMAL(14,2) COMMENT 'src rows 2526; WorkAidTotal',
  LoanAidTotal DECIMAL(14,2) COMMENT 'src rows 2527; LoanAidTotal',
  FedPellGrant DECIMAL(14,2) COMMENT 'src rows 2528; FedPellGrant',
  FedSeog STRING COMMENT 'src rows 2529; FedSEOG',
  FedAcadCompetitivenessGrantYear1 DECIMAL(14,2) COMMENT 'src rows 2530; FedAcadCompetitivenessGrantYear1',
  FedAcadCompetitivenessGrantYear2 DECIMAL(14,2) COMMENT 'src rows 2531; FedAcadCompetitivenessGrantYear2',
  FedSmartGrantYear3 DECIMAL(14,2) COMMENT 'src rows 2532; FedSMARTGrantYear3',
  FedSmartGrantYear4 DECIMAL(14,2) COMMENT 'src rows 2533; FedSMARTGrantYear4',
  FedWorkStudy STRING COMMENT 'src rows 2534; FedWorkStudy',
  FedPerkinsLoan DECIMAL(14,2) COMMENT 'src rows 2535; FedPerkinsLoan',
  FedDirectSubsidizedLoan DECIMAL(14,2) COMMENT 'src rows 2536; FedDirectSubsidizedLoan',
  FedDirectUnsubsidizedLoan DECIMAL(14,2) COMMENT 'src rows 2537; FedDirectUnsubsidizedLoan',
  FedUnsubsidizedLoans DECIMAL(14,2) COMMENT 'src rows 2538; FedUnsubsidizedLoans',
  FedParentPlusLoan DECIMAL(14,2) COMMENT 'src rows 2539; FedParentPLUSLoan',
  FedGradPlusLoan DECIMAL(14,2) COMMENT 'src rows 2540; FedGradPLUSLoan',
  FedNursingScholarships DECIMAL(14,2) COMMENT 'src rows 2541; FedNursingScholarships',
  FedNursingHealthLoans DECIMAL(14,2) COMMENT 'src rows 2542; FedNursingHealthLoans',
  FedTeachGrant DECIMAL(14,2) COMMENT 'src rows 2543; FedTEACHGrant',
  StateWashingtonCollegeGrant DECIMAL(14,2) COMMENT 'src rows 2544; StateWashingtonCollegeGrant',
  StateNeedGrant DECIMAL(14,2) COMMENT 'src rows 2545; StateNeedGrant',
  StateCollegeBoundScholarship DECIMAL(14,2) COMMENT 'src rows 2546; StateCollegeBoundScholarship',
  StateWorkforceTraining STRING COMMENT 'src rows 2547; StateWorkforceTraining',
  StateSbctcOpportunityGrant DECIMAL(14,2) COMMENT 'src rows 2548; StateSBCTCOpportunityGrant',
  StatePassportScholarship DECIMAL(14,2) COMMENT 'src rows 2549; StatePassportScholarship',
  StateOpportunityScholarship DECIMAL(14,2) COMMENT 'src rows 2550; StateOpportunityScholarship',
  StateEdOpportunityGrant DECIMAL(14,2) COMMENT 'src rows 2551; StateEdOpportunityGrant',
  StateOtherGiftAid STRING COMMENT 'src rows 2552; StateOtherGiftAid',
  StateWorkStudyTotal STRING COMMENT 'src rows 2553; StateWorkStudyTotal',
  StateWorkStudyOnCampus STRING COMMENT 'src rows 2554; StateWorkStudyOnCampus',
  StateWorkStudyOffCampus STRING COMMENT 'src rows 2555; StateWorkStudyOffCampus',
  StateGetReadyForMathAndScience STRING COMMENT 'src rows 2556; StateGETReadyForMathAndScience',
  InstGrantsWaivers DECIMAL(14,2) COMMENT 'src rows 2557; InstGrantsWaivers',
  InstGrants DECIMAL(14,2) COMMENT 'src rows 2558; InstGrants',
  InstNeedBasedWaiversPublic DECIMAL(14,2) COMMENT 'src rows 2559; InstNeedBasedWaiversPublic',
  InstNeedBasedWaivers DECIMAL(14,2) COMMENT 'src rows 2560; InstNeedBasedWaivers',
  InstNonNeedBasedWaivers DECIMAL(14,2) COMMENT 'src rows 2561; InstNonNeedBasedWaivers',
  InstAidFundGrants DECIMAL(14,2) COMMENT 'src rows 2562; InstAidFundGrants',
  InstNeedBasedGiftAid STRING COMMENT 'src rows 2563; InstNeedBasedGiftAid',
  InstNonNeedBasedGiftAid STRING COMMENT 'src rows 2564; InstNonNeedBasedGiftAid',
  InstSubstitutionStateNeedGrant DECIMAL(14,2) COMMENT 'src rows 2565; InstSubstitutionStateNeedGrant',
  InstEmployment STRING COMMENT 'src rows 2566; InstEmployment',
  InstLoans DECIMAL(14,2) COMMENT 'src rows 2567; InstLoans',
  OtherGrantsWaAgencies DECIMAL(14,2) COMMENT 'src rows 2568; OtherGrantsWAAgencies',
  OtherGrantsAgencies DECIMAL(14,2) COMMENT 'src rows 2569; OtherGrantsAgencies',
  OtherGrantsNonWaAgencies DECIMAL(14,2) COMMENT 'src rows 2570; OtherGrantsNonWAAgencies',
  OtherGrantsPrivate DECIMAL(14,2) COMMENT 'src rows 2571; OtherGrantsPrivate',
  OtherLoansConditional DECIMAL(14,2) COMMENT 'src rows 2572; OtherLoansConditional',
  OtherLoansPrivate DECIMAL(14,2) COMMENT 'src rows 2573; OtherLoansPrivate',
  OtherAndInstLoansAllTypes DECIMAL(14,2) COMMENT 'src rows 2574; OtherAndInstLoansAllTypes',
  OtherLoansAgencies DECIMAL(14,2) COMMENT 'src rows 2575; OtherLoansAgencies',
  StateWcgApprenticeship STRING COMMENT 'src rows 2576; StateWCGApprenticeship',
  StatePassportIncentiveGrant DECIMAL(14,2) COMMENT 'src rows 2577; StatePassportIncentiveGrant',
  StateWsosbaScholarship DECIMAL(14,2) COMMENT 'src rows 2578; StateWSOSBAScholarship',
  StateWsosCareerTech STRING COMMENT 'src rows 2579; StateWSOSCareerTech',
  StateTeacherGrantPrograms DECIMAL(14,2) COMMENT 'src rows 2580; StateTeacherGrantPrograms',
  StateTeachConditionalScholarship DECIMAL(14,2) COMMENT 'src rows 2581; StateTeachConditionalScholarship'
)
USING DELTA
CLUSTER BY (PsStudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactK12SchoolYearProfiles (
  FactK12SchoolYearProfileId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYear STRING COMMENT 'src rows 1673; SchoolYear',
  SchoolYearId BIGINT COMMENT 'src rows 1674; School_Year',
  SourceSchoolYear STRING COMMENT 'src rows 1674; School_Year',
  LeaId BIGINT COMMENT 'src rows 1678,1679; CCDDD, NCESDIST',
  K12SchoolId BIGINT COMMENT 'src rows 1681,1682; BLDG, NCESSCH',
  SchoolTypeDesc STRING COMMENT 'src rows 1689; SCHOOL_TYPE_DESC',
  TotalEnrollment DECIMAL(12,3) COMMENT 'src rows 1690; Total_Enrollment',
  NumberAmerIndianOrAkNative DECIMAL(12,3) COMMENT 'src rows 1691; Number_Amer_Indian_or_AK_Native',
  PercentAmerIndianOrAkNative DECIMAL(12,3) COMMENT 'src rows 1692; Percent_Amer_Indian_or_AK_Native',
  NumberAsian DECIMAL(12,3) COMMENT 'src rows 1693; Number_Asian',
  PercentAsian DECIMAL(12,3) COMMENT 'src rows 1694; Percent_Asian',
  NumberPacificIslander DECIMAL(12,3) COMMENT 'src rows 1695; Number_Pacific_Islander',
  PercentPacificIslander DECIMAL(12,3) COMMENT 'src rows 1696; Percent_Pacific_Islander',
  NumberAsianPacificIslander DECIMAL(12,3) COMMENT 'src rows 1697; Number_Asian_Pacific_Islander',
  PercentAsianPacificIslander DECIMAL(12,3) COMMENT 'src rows 1698; Percent_Asian_Pacific_Islander',
  NumberBlack DECIMAL(12,3) COMMENT 'src rows 1699; Number_Black',
  PercentBlack DECIMAL(12,3) COMMENT 'src rows 1700; Percent_Black',
  NumberHispanic DECIMAL(12,3) COMMENT 'src rows 1701; Number_Hispanic',
  PercentHispanic DECIMAL(12,3) COMMENT 'src rows 1702; Percent_Hispanic',
  NumberWhite DECIMAL(12,3) COMMENT 'src rows 1703; Number_White',
  PercentWhite DECIMAL(12,3) COMMENT 'src rows 1704; Percent_White',
  NumberTwoOrMoreRaces DECIMAL(12,3) COMMENT 'src rows 1705; Number_Two_Or_More_Races',
  PercentTwoOrMoreRaces DECIMAL(12,3) COMMENT 'src rows 1706; Percent_Two_Or_More_Races',
  NumberMales DECIMAL(12,3) COMMENT 'src rows 1707; Number_Males',
  PercentMales DECIMAL(12,3) COMMENT 'src rows 1708; Percent_Males',
  NumberFemales DECIMAL(12,3) COMMENT 'src rows 1709; Number_Females',
  PercentFemales DECIMAL(12,3) COMMENT 'src rows 1710; Percent_Females',
  NumberMigrant DECIMAL(14,2) COMMENT 'src rows 1711; Number_Migrant',
  PercentMigrant DECIMAL(14,2) COMMENT 'src rows 1712; Percent_Migrant',
  NumberTransitionalBilingual DECIMAL(12,3) COMMENT 'src rows 1713; Number_Transitional_Bilingual',
  PercentTransitionalBilingual DECIMAL(12,3) COMMENT 'src rows 1714; Percent_Transitional_Bilingual',
  NumberSpecialEducation DECIMAL(12,3) COMMENT 'src rows 1715; Number_Special_Education',
  PercentSpecialEducation DECIMAL(12,3) COMMENT 'src rows 1716; Percent_Special_Education',
  NumFreeReducedPricedMeals DECIMAL(12,3) COMMENT 'src rows 1717; Num_Free_Reduced_Priced_Meals',
  PctFreeReducedPricedMeals DECIMAL(12,3) COMMENT 'src rows 1718; Pct_Free_Reduced_Priced_Meals',
  NumberSection504 DECIMAL(12,3) COMMENT 'src rows 1719; Number_Section_504',
  PercentSection504 DECIMAL(12,3) COMMENT 'src rows 1720; Percent_Section_504',
  NumberFosterCare DECIMAL(12,3) COMMENT 'src rows 1721; Number_Foster_Care',
  PercentFosterCare DECIMAL(12,3) COMMENT 'src rows 1722; Percent_Foster_Care',
  NumberFosterCareLt10 DECIMAL(12,3) COMMENT 'src rows 1723; Number_Foster_Care_LT10',
  PercentFosterCareLt10 DECIMAL(12,3) COMMENT 'src rows 1724; Percent_Foster_Care_LT10',
  Homeless STRING COMMENT 'src rows 1725; Homeless',
  PctHomeless DECIMAL(12,3) COMMENT 'src rows 1726; Pct_Homeless',
  MilitaryParent STRING COMMENT 'src rows 1727; Military Parent',
  PctMilitaryParent DECIMAL(12,3) COMMENT 'src rows 1728; Pct_Military Parent',
  Mobile STRING COMMENT 'src rows 1729; Mobile',
  PctMobile DECIMAL(12,3) COMMENT 'src rows 1730; Pct_Mobile',
  StudentsWithDisabilities STRING COMMENT 'src rows 1731; Students with Disabilities',
  PctStudentsWithDisabilities DECIMAL(12,3) COMMENT 'src rows 1732; Pct_Students with Disabilities',
  HighlyCapable STRING COMMENT 'src rows 1733; Highly Capable',
  PctHighlyCapable DECIMAL(12,3) COMMENT 'src rows 1734; Pct_Highly Capable',
  StudentsPerClassroomTeacher STRING COMMENT 'src rows 1735; Students_Per_Classroom_Teacher',
  AvgYearsEducationalExperience DECIMAL(12,3) COMMENT 'src rows 1736; Avg_Years_Educational_Experience',
  NumTeachersLeastMasterDegree DECIMAL(12,3) COMMENT 'src rows 1737; Num_Teachers_Least_Master_Degree',
  PctTeachersLeastMasterDegree DECIMAL(12,3) COMMENT 'src rows 1738; Pct_Teachers_Least_Master_Degree',
  NumberClassroomTeachers DECIMAL(12,3) COMMENT 'src rows 1739; Number_Classroom_Teachers',
  IncomeToPovertyRatioEstimate STRING COMMENT 'src rows 1748; IPR_EST'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactK12StaffRetentionMobility (
  FactK12StaffRetentionMobilityId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 620; SchoolYearCode',
  SourceSchoolYearCode STRING COMMENT 'src rows 620; SchoolYearCode',
  LeaId BIGINT COMMENT 'src rows 621; DistrictOrganizationId',
  K12SchoolId BIGINT COMMENT 'src rows 622; SchoolOrganizationId',
  K12StaffId BIGINT COMMENT 'src rows 623,624,625; CertificateNumber, EducatorID, PersonnelId',
  HighestDegree STRING COMMENT 'src rows 632; HighestDegree',
  YearsOfPriorTeachingExperience DECIMAL(12,3) COMMENT 'src rows 633; ReportedExperience',
  CalculatedExperience DECIMAL(12,3) COMMENT 'src rows 634; CalculatedExperience',
  IsParaeducator BOOLEAN COMMENT 'src rows 635; IsParaeducator',
  IsTeacher BOOLEAN COMMENT 'src rows 636; IsTeacher',
  IsPrincipal BOOLEAN COMMENT 'src rows 637; IsPrincipal',
  IsOtherSchoolLeader BOOLEAN COMMENT 'src rows 638; IsOtherSchoolLeader',
  IsEsa BOOLEAN COMMENT 'src rows 639; IsESA',
  IsStudentSupport BOOLEAN COMMENT 'src rows 640; IsStudentSupport',
  DataSourceId STRING COMMENT 'src rows 641; DataSourceId',
  IsLateHire BOOLEAN COMMENT 'src rows 642; IsLateHire',
  IsNbct BOOLEAN COMMENT 'src rows 643; IsNBCT',
  ContentAreaId STRING COMMENT 'src rows 644; ContentAreaId',
  ContentAreaName STRING COMMENT 'src rows 645; ContentAreaName',
  GradeLevel STRING COMMENT 'src rows 646; GradeLevel',
  IsNewHireSchool STRING COMMENT 'src rows 647; IsNewHireSchool',
  IsNewHireDistrict STRING COMMENT 'src rows 648; IsNewHireDistrict',
  IsNewHireState STRING COMMENT 'src rows 649; IsNewHireState',
  IsStayer BOOLEAN COMMENT 'src rows 650; IsStayer',
  IsStayerInGrade BOOLEAN COMMENT 'src rows 651; IsStayerInGrade',
  IsStayerInContent BOOLEAN COMMENT 'src rows 652; IsStayerInContent',
  IsMoverIn BOOLEAN COMMENT 'src rows 653; IsMoverIn',
  IsMoverOut BOOLEAN COMMENT 'src rows 654; IsMoverOut',
  IsReturnerInSchool BOOLEAN COMMENT 'src rows 656; IsReturnerInSchool',
  IsReturnerInDistrict BOOLEAN COMMENT 'src rows 657; IsReturnerInDistrict',
  IsReturnerOut BOOLEAN COMMENT 'src rows 658; IsReturnerOut',
  IsExiter BOOLEAN COMMENT 'src rows 659; IsExiter',
  IsRoleChange BOOLEAN COMMENT 'src rows 660; IsRoleChange',
  SourceDataAsOf STRING COMMENT 'src rows 661; DataAsOf'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactK12StudentCourseTranscripts (
  FactK12StudentCourseTranscriptId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ReportingSchoolYear STRING COMMENT 'src rows 1211; SchoolYear',
  LeaId BIGINT COMMENT 'src rows 1212; DistrictCode',
  K12SchoolId BIGINT COMMENT 'src rows 1214,1216; LocationID, SchoolCode',
  K12StudentId BIGINT COMMENT 'src rows 1217,1218; DistrictStudentID, SSID',
  TermEndDate STRING COMMENT 'src rows 1219; TermEndDate',
  Term STRING COMMENT 'src rows 1220; Term',
  CourseIdentifierCode STRING COMMENT 'src rows 1221; CourseID',
  CourseTitle STRING COMMENT 'src rows 1222; CourseTitle',
  K12StaffId BIGINT COMMENT 'src rows 1223,1224; CertificationNumber, StaffID',
  GradeLevelWhenCourseTaken STRING COMMENT 'src rows 1225; GradeLevelWhenCourseTaken',
  AlternativeLearningEducationCode STRING COMMENT 'src rows 1226; AlternativeLearningEducationCode',
  StudentCourseSectionGradeEarned STRING COMMENT 'src rows 1228; LetterGrade',
  NumberOfCreditsAttempted DECIMAL(12,3) COMMENT 'src rows 1229; CreditsAttempted',
  NumberOfCreditsEarned DECIMAL(12,3) COMMENT 'src rows 1230; CreditsEarned',
  StateCourseCode STRING COMMENT 'src rows 1231; StateCourseCode',
  ContentAreaCode STRING COMMENT 'src rows 1233; ContentAreaCode',
  AdvancedPlacementCourseCode STRING COMMENT 'src rows 1235; APIBCourseCode',
  ClassificationOfInstructionalProgramCode STRING COMMENT 'src rows 1237; CTECIPCode',
  CareerClusterCode STRING COMMENT 'src rows 1239; CTEClusterID',
  CteClusterName STRING COMMENT 'src rows 1240; CTEClusterName',
  CtePathwayId STRING COMMENT 'src rows 1241; CTEPathwayID',
  CtePathwayName STRING COMMENT 'src rows 1242; CTEPathwayName',
  CteAssessment STRING COMMENT 'src rows 1243; CTEAssessment',
  HasCteIndustryCertificateFlag BOOLEAN COMMENT 'src rows 1244; HasCTEIndustryCertificateFlag',
  CteVocCompleterFlag STRING COMMENT 'src rows 1245; CTEVocCompleterFlag',
  CteDirectTranscriptionAvailableFlag BOOLEAN COMMENT 'src rows 1246; CTEDirectTranscriptionAvailableFlag',
  TechPrepCourseFlag BOOLEAN COMMENT 'src rows 1247; TechPrepCourseFlag',
  TechPrepProgramAreaCompleterFlag STRING COMMENT 'src rows 1248; TechPrepProgramAreaCompleterFlag',
  FullCourseDesignationCode STRING COMMENT 'src rows 1249; FullCourseDesignationCode',
  InternationalBaccalaureateFlag BOOLEAN COMMENT 'src rows 1250; InternationalBaccalaureateFlag',
  CollegeattheHighSchoolFlag BOOLEAN COMMENT 'src rows 1251; CollegeattheHighSchoolFlag',
  HonorsFlag BOOLEAN COMMENT 'src rows 1252; HonorsFlag',
  AdvancedPlacementFlag BOOLEAN COMMENT 'src rows 1253; AdvancedPlacementFlag',
  RunningStartFlag BOOLEAN COMMENT 'src rows 1254; RunningStartFlag',
  CollegeAcademicDistributionRequirementsFlag BOOLEAN COMMENT 'src rows 1255; CollegeAcademicDistributionRequirementsFlag',
  CambridgeProgramFlag BOOLEAN COMMENT 'src rows 1256; CambridgeProgramFlag',
  OnlineFlag BOOLEAN COMMENT 'src rows 1257; OnlineFlag',
  LocalCompetencyTestFlag BOOLEAN COMMENT 'src rows 1258; LocalCompetencyTestFlag',
  NationalCompetencyTestFlag BOOLEAN COMMENT 'src rows 1259; NationalCompetencyTestFlag',
  QuantitativeFlag BOOLEAN COMMENT 'src rows 1260; QuantitativeFlag',
  ScienceLabFlag BOOLEAN COMMENT 'src rows 1261; ScienceLabFlag',
  NonInstructionalTimeFlag BOOLEAN COMMENT 'src rows 1262; NonInstructionalTimeFlag',
  SourceSubmitDate DATE COMMENT 'src rows 1263; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1264; ExtractDate',
  SchoolYearId STRING COMMENT 'src rows 1265; CourseSchoolYear',
  DistrictOrLocalDualCreditPgm BOOLEAN COMMENT 'src rows 1266; DistrictOrLocalDualCreditPgm',
  Youth1418ReengagementDualCredit BOOLEAN COMMENT 'src rows 1267; Youth1418ReengagementDualCredit',
  LocalTransitionFlag BOOLEAN COMMENT 'src rows 1268; LocalTransitionFlag',
  CteCorePlusFlag BOOLEAN COMMENT 'src rows 1269; CTECorePlusFlag',
  IndustryCertificationEarned STRING COMMENT 'src rows 1270; IndustryCertificationEarned',
  CteCorePlusAdvancedManufacturingFlag BOOLEAN COMMENT 'src rows 1271; CTECorePlusAdvancedManufacturingFlag',
  CteCorePlusMaritimeFlag BOOLEAN COMMENT 'src rows 1272; CTECorePlusMaritimeFlag',
  CteCorePlusAerospaceFlag BOOLEAN COMMENT 'src rows 1273; CTECorePlusAerospaceFlag',
  CteCorePlusConstructionFlag BOOLEAN COMMENT 'src rows 1274; CTECorePlusConstructionFlag',
  WorkBasedLearningOpportunityTypeCode STRING COMMENT 'src rows 1275; WorkBasedLearningActivityTypeCode',
  TribalLanguageCompetencyTestFlag BOOLEAN COMMENT 'src rows 1277; TribalLanguageCompetencyTestFlag'
)
USING DELTA
CLUSTER BY (K12StudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactK12StudentNonTraditionalCreditAttempts (
  FactK12StudentNonTraditionalCreditAttemptId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ReportingSchoolYear STRING COMMENT 'src rows 1352; SchoolYear',
  LeaId BIGINT COMMENT 'src rows 1353; DistrictCode',
  K12SchoolId BIGINT COMMENT 'src rows 1355,1357; LocationID, SchoolCode',
  K12StudentId BIGINT COMMENT 'src rows 1358,1359; DistrictStudentCode, SSID',
  AttemptIdentifier STRING COMMENT 'src rows 1360; AttemptId',
  AttemptTitle STRING COMMENT 'src rows 1361; AttemptTitle',
  CourseIdentifierCode STRING COMMENT 'src rows 1362; CourseId',
  FullCourseDesignationCode STRING COMMENT 'src rows 1363; FullCourseDesignationCode',
  TechPrepFlag BOOLEAN COMMENT 'src rows 1364; TechPrepFlag',
  InternationalBaccalaureateFlag BOOLEAN COMMENT 'src rows 1365; InternationalBaccalaureateFlag',
  CollegeattheHighSchoolFlag BOOLEAN COMMENT 'src rows 1366; CollegeattheHighSchoolFlag',
  HonorsFlag BOOLEAN COMMENT 'src rows 1367; HonorsFlag',
  AdvancedPlacementFlag BOOLEAN COMMENT 'src rows 1368; AdvancedPlacementFlag',
  RunningStartFlag BOOLEAN COMMENT 'src rows 1369; RunningStartFlag',
  CollegeAcademicDistributionRequirementsFlag BOOLEAN COMMENT 'src rows 1370; CollegeAcademicDistributionRequirementsFlag',
  CambridgeProgramFlag BOOLEAN COMMENT 'src rows 1371; CambridgeProgramFlag',
  OnlineFlag BOOLEAN COMMENT 'src rows 1372; OnlineFlag',
  LocalCompetencyTestFlag BOOLEAN COMMENT 'src rows 1373; LocalCompetencyTestFlag',
  NationalCompetencyTestFlag BOOLEAN COMMENT 'src rows 1374; NationalCompetencyTestFlag',
  QuantitativeFlag BOOLEAN COMMENT 'src rows 1375; QuantitativeFlag',
  ScienceLabFlag BOOLEAN COMMENT 'src rows 1376; ScienceLabFlag',
  NonInstructionalTimeFlag BOOLEAN COMMENT 'src rows 1377; NonInstructionalTimeFlag',
  DistrictOrLocalDualCreditPgm BOOLEAN COMMENT 'src rows 1378; DistrictOrLocalDualCreditPgm',
  Youth1418ReengagementDualCredit BOOLEAN COMMENT 'src rows 1379; Youth1418ReengagementDualCredit',
  LocallyDeterminedCourseLocallyAdministeredAssessmentFlag BOOLEAN COMMENT 'src rows 1380; LocallyDeterminedCourseLocallyAdministeredAssessmentFlag',
  StateCourseCode STRING COMMENT 'src rows 1381; StateCourseCode',
  ContentAreaCode STRING COMMENT 'src rows 1383; ContentAreaCode',
  AlternativeLearningEducationCode STRING COMMENT 'src rows 1385; AlternativeLearningEducationCode',
  OnlineProviderOrganizationId BIGINT COMMENT 'src rows 1387; ApprovedOnlineProviderCode',
  OnlineProgramOrganizationId BIGINT COMMENT 'src rows 1389,1393; ApprovedOnlineProgramCode, ApprovedOnlineProgramListOrder',
  OnlineProgramResidentLeaOrganizationId BIGINT COMMENT 'src rows 1391; ApprovedOnlinePGMResidentDistOrgId',
  StudentCourseSectionGradeEarned STRING COMMENT 'src rows 1394; LetterGrade',
  NumberOfCreditsAttempted DECIMAL(12,3) COMMENT 'src rows 1396; CreditsAttempted',
  NumberOfCreditsEarned DECIMAL(12,3) COMMENT 'src rows 1397; CreditsEarned',
  SourceSubmitDate DATE COMMENT 'src rows 1398; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1399; ExtractDate',
  LocalTransitionFlag BOOLEAN COMMENT 'src rows 1400; LocalTransitionFlag',
  CteCorePlusFlag BOOLEAN COMMENT 'src rows 1401; CTECorePlusFlag',
  CourseLevelCharacteristicCode STRING COMMENT 'src rows 1402; CourseLevelCode',
  SequenceCode STRING COMMENT 'src rows 1404; SequenceCode',
  SequenceGroupCode STRING COMMENT 'src rows 1406; SequenceGroupCode',
  CteCorePlusAdvancedManufacturingFlag BOOLEAN COMMENT 'src rows 1407; CTECorePlusAdvancedManufacturingFlag',
  CteCorePlusMaritimeFlag BOOLEAN COMMENT 'src rows 1408; CTECorePlusMaritimeFlag',
  CteCorePlusAerospaceFlag BOOLEAN COMMENT 'src rows 1409; CTECorePlusAerospaceFlag',
  CteCorePlusConstructionFlag BOOLEAN COMMENT 'src rows 1410; CTECorePlusConstructionFlag',
  TribalLanguageCompetencyTestFlag BOOLEAN COMMENT 'src rows 1411; TribalLanguageCompetencyTestFlag'
)
USING DELTA
CLUSTER BY (K12StudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactPsCourseSectionOfferings (
  FactPsCourseSectionOfferingId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ContractStuEnrollment STRING COMMENT 'src rows 2202; CONTRACT_STU_ENROLLMENT',
  ContractStuFtes DECIMAL(12,3) COMMENT 'src rows 2203; CONTRACT_STU_FTES',
  EnrContract STRING COMMENT 'src rows 2267; ENR_CONTRACT',
  EnrState STRING COMMENT 'src rows 2269; ENR_STATE',
  EnrStudent STRING COMMENT 'src rows 2270; ENR_STUDENT',
  EnrTotal STRING COMMENT 'src rows 2271; ENR_TOTAL',
  EnrWaiver DECIMAL(14,2) COMMENT 'src rows 2272; ENR_WAIVER',
  FteStudents DECIMAL(12,3) COMMENT 'src rows 2300; FTE_STUDENTS',
  FtesContract DECIMAL(12,3) COMMENT 'src rows 2301; FTES_CONTRACT',
  FtesState DECIMAL(12,3) COMMENT 'src rows 2304; FTES_STATE',
  FtesStudent DECIMAL(12,3) COMMENT 'src rows 2306; FTES_STUDENT',
  FtesTotal DECIMAL(12,3) COMMENT 'src rows 2309; FTES_TOTAL',
  FtesWaiver DECIMAL(14,2) COMMENT 'src rows 2311; FTES_WAIVER',
  TenDayEnr STRING COMMENT 'src rows 2454; TEN_DAY_ENR'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactPsStaffCourseSections (
  FactPsStaffCourseSectionId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  EmploymentStat STRING COMMENT 'src rows 2254; EMPLOYMENT_STAT',
  FteFaculty DECIMAL(12,3) COMMENT 'src rows 2298; FTE_FACULTY',
  PsStaffId STRING COMMENT 'src rows 2367; INSTR_ID',
  SourceFteFaculty DECIMAL(12,3) COMMENT 'src rows 2424; SOURCE_FTE_FACULTY',
  TeamTeach STRING COMMENT 'src rows 2452; TEAM_TEACH'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactPsStudentAdmissionTests (
  FactPsStudentAdmissionTestId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ActCompositeScore DECIMAL(12,3) COMMENT 'src rows 1953; ACT_composite_score',
  ActEnglishScore DECIMAL(12,3) COMMENT 'src rows 1954; ACT_english_score',
  ActMathScore DECIMAL(12,3) COMMENT 'src rows 1955; ACT_math_score',
  ActReadingScore DECIMAL(12,3) COMMENT 'src rows 1956; ACT_reading_score',
  ActScienceScore DECIMAL(12,3) COMMENT 'src rows 1957; ACT_science_score',
  ActWritingScore DECIMAL(12,3) COMMENT 'src rows 1958; ACT_writing_score',
  SatDateTaken DATE COMMENT 'src rows 1982; SAT_date_taken',
  SatMathSectionScore DECIMAL(12,3) COMMENT 'src rows 1984; SAT_math_section_score',
  SatCriticalReadingScore DECIMAL(12,3) COMMENT 'src rows 1985; SAT_critical_reading_score',
  SatMathScore DECIMAL(12,3) COMMENT 'src rows 1986; SAT_math_score',
  SatMathSubSectionScore DECIMAL(12,3) COMMENT 'src rows 1987; SAT_math_sub_section_score',
  SatReadingSubSectionScore DECIMAL(12,3) COMMENT 'src rows 1988; SAT_reading_sub_section_score',
  SatReadingWritingSectionScore DECIMAL(12,3) COMMENT 'src rows 1989; SAT_reading_writing_section_score',
  SatWritingLanguageSubSectionScore DECIMAL(12,3) COMMENT 'src rows 1990; SAT_writing_language_sub_section_score',
  SatWritingScore DECIMAL(12,3) COMMENT 'src rows 1992; SAT_writing_score'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactPsStudentApplications (
  FactPsStudentApplicationId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 1952; academic_year',
  SourceAcademicYear STRING COMMENT 'src rows 1952; academic_year',
  EntryAcademicTermDesignatorId STRING COMMENT 'src rows 1959,1960; admit_academic_year, admit_term',
  PsCampusOrganizationId BIGINT COMMENT 'src rows 1961; campus',
  CoEnrolledStatus STRING COMMENT 'src rows 1962; co_enrolled_status',
  LastHighSchoolOrganizationId BIGINT COMMENT 'src rows 1963; high_school',
  HighSchoolCompletionType STRING COMMENT 'src rows 1964; high_school_completion_type',
  HighSchoolCompletionYear STRING COMMENT 'src rows 1965; high_school_completion_year',
  HighSchoolGpaKey DECIMAL(12,3) COMMENT 'src rows 1966; high_school_GPA_key',
  HighSchoolLastYearAttended STRING COMMENT 'src rows 1967; high_school_last_year_attended',
  PsStudentId BIGINT COMMENT 'src rows 1968,1991; K12_state_ID, student_institution',
  PsInstitutionId BIGINT COMMENT 'src rows 1969; institution',
  PreviousCreditsEarned DECIMAL(12,3) COMMENT 'src rows 1970; previous_credits_earned',
  Nation STRING COMMENT 'src rows 1971; nation',
  PreviousCreditsTransferredAp DECIMAL(12,3) COMMENT 'src rows 1972; previous_credits_transferred_AP',
  PreviousCreditsTransferredIb DECIMAL(12,3) COMMENT 'src rows 1973; previous_credits_transferred_IB',
  PreviousCreditsTransferredTotal DECIMAL(12,3) COMMENT 'src rows 1974; previous_credits_transferred_total',
  PreviousPsInstitutionOrganizationId BIGINT COMMENT 'src rows 1975; previous_institution',
  PreviousInstitutionDegreeAcronym STRING COMMENT 'src rows 1976; previous_institution_degree_acronym',
  PreviousInstitutionDegreeLevel STRING COMMENT 'src rows 1977; previous_institution_degree_level',
  PreviousInstitutionGpaKey DECIMAL(12,3) COMMENT 'src rows 1978; previous_institution_GPA_key',
  PreviousInstitutionLastYearAttended STRING COMMENT 'src rows 1979; previous_institution_last_year_attended',
  PreviousInstitutionDtaAstStatus STRING COMMENT 'src rows 1980; previous_institution_dta_ast_status',
  SourceRecordNumber STRING COMMENT 'src rows 1981; record_number',
  RunningStartAffiliation STRING COMMENT 'src rows 1983; running_start_affiliation',
  StudentTypeCode STRING COMMENT 'src rows 1993; student_type',
  AcademicTermDesignatorId BIGINT COMMENT 'src rows 1994; term',
  SourceTerm STRING COMMENT 'src rows 1994; term',
  UsState STRING COMMENT 'src rows 1995; US_state',
  WaCounty DECIMAL(12,3) COMMENT 'src rows 1996; WA_county'
)
USING DELTA
CLUSTER BY (PsStudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactPsStudentCourseSectionEnrollments (
  FactPsStudentCourseSectionEnrollmentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AcademicTermDesignatorId BIGINT COMMENT 'src rows 2174,2318,2436; QUARTER, STRM, YRQ',
  SourceQuarter STRING COMMENT 'src rows 2174; QUARTER',
  SchoolYearId BIGINT COMMENT 'src rows 2175; YEAR',
  SourceYear STRING COMMENT 'src rows 2175; YEAR',
  NumberOfCreditsAttempted DECIMAL(12,3) COMMENT 'src rows 2224; CREDITS_ENROLLED',
  PsStudentId BIGINT COMMENT 'src rows 2242,2296; DW_KEY, EMPLID',
  PsInstitutionId BIGINT COMMENT 'src rows 2299,2359; COLLEGE, INSTITUTION',
  DocSiteOrganizationId BIGINT COMMENT 'src rows 2303; DOC_SITE',
  SourceYrq STRING COMMENT 'src rows 2318; YRQ',
  IbestIndicator STRING COMMENT 'src rows 2352; IBEST',
  PsCourseSectionId STRING COMMENT 'src rows 2372; ITEM',
  SourceStrm STRING COMMENT 'src rows 2436; STRM'
)
USING DELTA
CLUSTER BY (PsStudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactPsStudentCourseSectionFundings (
  FactPsStudentCourseSectionFundingId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  FundingSourceCode STRING COMMENT 'src rows 2032; funding_source',
  ClockHrEquiv DECIMAL(12,3) COMMENT 'src rows 2192; CLOCK_HR_EQUIV',
  CrEquiv DECIMAL(12,3) COMMENT 'src rows 2219; CR_EQUIV',
  FeePayStatus STRING COMMENT 'src rows 2289; FEE_PAY_STATUS',
  FundSource STRING COMMENT 'src rows 2290; FUND_SOURCE',
  FundSourceEnrollment STRING COMMENT 'src rows 2291; FUND_SOURCE_ENROLLMENT',
  FundSourceCat STRING COMMENT 'src rows 2292; FUND_SOURCE_CAT',
  KindOfEnrollment STRING COMMENT 'src rows 2295; KIND_OF_ENROLLMENT',
  FullTimeEquivalency DECIMAL(12,3) COMMENT 'src rows 2297; FTE',
  PctExternallyFunded DECIMAL(12,3) COMMENT 'src rows 2378; PCT_EXTERNALLY_FUNDED',
  StuClassStatus STRING COMMENT 'src rows 2443; STU_CLASS_STATUS'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactPsStudentProgramEnrollments (
  FactPsStudentProgramEnrollmentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AcademicTermDesignatorId BIGINT COMMENT 'src rows 2178,2438,2439; LEGACY_QUARTER, LEGACY_YRQ, STRM',
  SourceLegacyQuarter STRING COMMENT 'src rows 2178; LEGACY_QUARTER',
  SchoolYearId BIGINT COMMENT 'src rows 2179; LEGACY_YEAR',
  SourceLegacyYear STRING COMMENT 'src rows 2179; LEGACY_YEAR',
  PsStudentId BIGINT COMMENT 'src rows 2244,2250; DW_KEY, EMPLID',
  PsInstitutionId BIGINT COMMENT 'src rows 2361,2429; COLLEGE, INSTITUTION',
  Priority STRING COMMENT 'src rows 2381; PRIORITY',
  PsProgramId STRING COMMENT 'src rows 2427; ACAD_PLAN',
  StdntCarNbr STRING COMMENT 'src rows 2432; STDNT_CAR_NBR',
  Intent STRING COMMENT 'src rows 2435; INTENT',
  SourceLegacyYrq STRING COMMENT 'src rows 2438; LEGACY_YRQ',
  SourceStrm STRING COMMENT 'src rows 2439; STRM'
)
USING DELTA
CLUSTER BY (PsStudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactTeacherPrepApplications (
  FactTeacherPrepApplicationId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 470,471; academic_year, year',
  SourceYear STRING COMMENT 'src rows 470; year',
  SourceAcademicYear STRING COMMENT 'src rows 471; academic_year',
  PsInstitutionId BIGINT COMMENT 'src rows 472; inst_code',
  PsStudentId BIGINT COMMENT 'src rows 473,478; applicant_id, stu_id',
  ProgType STRING COMMENT 'src rows 474; prog_type',
  CredRole STRING COMMENT 'src rows 475; cred_role',
  CredType STRING COMMENT 'src rows 476; cred_type',
  TeacherPrepProgramId STRING COMMENT 'src rows 477; prog_id',
  ApplicationDate DATE COMMENT 'src rows 481; app_date',
  AssetPrime STRING COMMENT 'src rows 491; asset_prime',
  AssetPrimeTxt STRING COMMENT 'src rows 492; asset_prime_txt',
  AssetAux STRING COMMENT 'src rows 493; asset_aux',
  AssetAuxTxt STRING COMMENT 'src rows 494; asset_aux_txt',
  DeficiencyPrime STRING COMMENT 'src rows 495; deficiency_prime',
  DeficiencyPrimeTxt STRING COMMENT 'src rows 496; deficiency_prime_txt',
  DeficiencyClearDate DATE COMMENT 'src rows 497; deficiency_clear_date',
  DeficiencyAux STRING COMMENT 'src rows 498; deficiency_aux',
  DeficiencyAuxTxt STRING COMMENT 'src rows 499; deficiency_aux_txt',
  AdmittedStudentCode STRING COMMENT 'src rows 500; decision',
  WaitListedStudent DATE COMMENT 'src rows 501; waitlist_date',
  EndorseCodeInitial STRING COMMENT 'src rows 502; endorse_code_initial'
)
USING DELTA
CLUSTER BY (PsStudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactTeacherPrepAssessments (
  FactTeacherPrepAssessmentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 428,429; academic_year, year',
  SourceYear STRING COMMENT 'src rows 428; year',
  SourceAcademicYear STRING COMMENT 'src rows 429; academic_year',
  PsInstitutionId BIGINT COMMENT 'src rows 430; inst_code',
  PsStudentId BIGINT COMMENT 'src rows 431; stu_id',
  ProgType STRING COMMENT 'src rows 432; prog_type',
  CredRole STRING COMMENT 'src rows 433; cred_role',
  CredType STRING COMMENT 'src rows 434; cred_type',
  TeacherPrepProgramId STRING COMMENT 'src rows 435; prog_id',
  EnrollCat STRING COMMENT 'src rows 436; enroll_cat',
  AssessmentResultScoreValue DECIMAL(12,3) COMMENT 'src rows 442,504,508,512,517,522,527; score, score_exam1, score_exam2, score_exam3, score_exam_m, score_exam_r, score_exam_w',
  PassedIndicator STRING COMMENT 'src rows 443; passed',
  CbcStatus STRING COMMENT 'src rows 444; cbc_status',
  AltCompDemo1 STRING COMMENT 'src rows 445; alt_comp_demo1',
  AltCompDemo1Txt STRING COMMENT 'src rows 446; alt_comp_demo1_txt',
  AltCompDemo2 STRING COMMENT 'src rows 447; alt_comp_demo2',
  AltCompDemo2Txt STRING COMMENT 'src rows 448; alt_comp_demo2_txt',
  EntranceExamM STRING COMMENT 'src rows 503; entrance_exam_m',
  ExamStatM STRING COMMENT 'src rows 505; exam_stat_m',
  AltCompDemoTxtM STRING COMMENT 'src rows 506; alt_comp_demo_txt_m',
  EntranceExamR STRING COMMENT 'src rows 507; entrance_exam_r',
  ExamStatR STRING COMMENT 'src rows 509; exam_stat_r',
  AltCompDemoTxtR STRING COMMENT 'src rows 510; alt_comp_demo_txt_r',
  EntranceExamW STRING COMMENT 'src rows 511; entrance_exam_w',
  ExamStatW STRING COMMENT 'src rows 513; exam_stat_w',
  AltCompDemoTxtW STRING COMMENT 'src rows 514; alt_comp_demo_txt_w',
  EntranceExam1 STRING COMMENT 'src rows 515; entrance_exam1',
  BasicSkillsArea1 STRING COMMENT 'src rows 516; basic_skills_area1',
  ExamStat1 STRING COMMENT 'src rows 518; exam_stat1',
  AltCompDemoTxt1 STRING COMMENT 'src rows 519; alt_comp_demo_txt1',
  EntranceExam2 STRING COMMENT 'src rows 520; entrance_exam2',
  BasicSkillsArea2 STRING COMMENT 'src rows 521; basic_skills_area2',
  ExamStat2 STRING COMMENT 'src rows 523; exam_stat2',
  AltCompDemoTxt2 STRING COMMENT 'src rows 524; alt_comp_demo_txt2',
  EntranceExam3 STRING COMMENT 'src rows 525; entrance_exam3',
  BasicSkillsArea3 STRING COMMENT 'src rows 526; basic_skills_area3',
  ExamStat3 STRING COMMENT 'src rows 528; exam_stat3',
  AltCompDemoTxt3 STRING COMMENT 'src rows 529; alt_comp_demo_txt3'
)
USING DELTA
CLUSTER BY (PsStudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactTeacherPrepClinicalExperiences (
  FactTeacherPrepClinicalExperienceId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 449,450; academic_year, year',
  SourceYear STRING COMMENT 'src rows 449; year',
  SourceAcademicYear STRING COMMENT 'src rows 450; academic_year',
  PsInstitutionId BIGINT COMMENT 'src rows 451; inst_code',
  PsStudentId BIGINT COMMENT 'src rows 452; stu_id',
  ProgType STRING COMMENT 'src rows 453; prog_type',
  CredRole STRING COMMENT 'src rows 454; cred_role',
  CredType STRING COMMENT 'src rows 455; cred_type',
  TeacherPrepProgramId STRING COMMENT 'src rows 456; prog_id',
  PracName STRING COMMENT 'src rows 457; prac_name',
  PracType STRING COMMENT 'src rows 458; prac_type',
  PracEndorse STRING COMMENT 'src rows 459; prac_endorse',
  ClinicalLeaId BIGINT COMMENT 'src rows 460; dist_code',
  ClinicalK12SchoolId BIGINT COMMENT 'src rows 461; bldg_code',
  AltEdEnv STRING COMMENT 'src rows 462; alt_ed_env',
  MentorPersonId BIGINT COMMENT 'src rows 463; lead_mentor_cert',
  PracStart STRING COMMENT 'src rows 465; prac_start',
  PracEnd STRING COMMENT 'src rows 466; prac_end',
  SupervisedClinicalExperienceClockHours DECIMAL(12,3) COMMENT 'src rows 467; prac_hours',
  PracOutcome STRING COMMENT 'src rows 468; prac_outcome',
  PracHours2 DECIMAL(12,3) COMMENT 'src rows 469; prac_hours2'
)
USING DELTA
CLUSTER BY (PsStudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_aligned.FactTeacherPrepProgramParticipations (
  FactTeacherPrepProgramParticipationId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 391,392; academic_year, year',
  SourceYear STRING COMMENT 'src rows 391; year',
  SourceAcademicYear STRING COMMENT 'src rows 392; academic_year',
  PsInstitutionId BIGINT COMMENT 'src rows 393; inst_code',
  PsStudentId BIGINT COMMENT 'src rows 394; stu_id',
  ProgType STRING COMMENT 'src rows 395; prog_type',
  CredentialRoleCode STRING COMMENT 'src rows 396; cred_role',
  AlternativeRouteToCertificationOrLicensure STRING COMMENT 'src rows 396; cred_role',
  CredType STRING COMMENT 'src rows 397; cred_type',
  TeacherPrepProgramId STRING COMMENT 'src rows 398; prog_id',
  EnrollDate STRING COMMENT 'src rows 414; enroll_date',
  TermsAttended STRING COMMENT 'src rows 415; terms_attended',
  ExitDate STRING COMMENT 'src rows 416; exit_date',
  ExitReason STRING COMMENT 'src rows 417; exit_reason',
  Recommend STRING COMMENT 'src rows 418; recommend',
  FirstGenerationCollegeStudent STRING COMMENT 'src rows 419; first_gen',
  FirstLangEng STRING COMMENT 'src rows 420; first_lang_Eng',
  PrevDegree STRING COMMENT 'src rows 421; prev_degree',
  CrntyrEndorseActive STRING COMMENT 'src rows 422; crntyr_endorse_active',
  EndorseCompleteDate STRING COMMENT 'src rows 423; endorse_complete_date',
  EndorseRecommend STRING COMMENT 'src rows 424; endorse_recommend',
  CwCompletionDate STRING COMMENT 'src rows 425; cw_completion_date',
  CwtestCompletionDate STRING COMMENT 'src rows 426; cwtest_completion_date',
  TitleIiFlag STRING COMMENT 'src rows 427; Title_II_flag'
)
USING DELTA
CLUSTER BY (PsStudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.BridgePersonLanguageWaExt (
  BridgePersonLanguageId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  LanguageCode STRING COMMENT 'src rows 92,221,228,1076,1078,1123,2392; FamilyLanguageCode, LanguageSpokenatHomeCode, LanguageTypeId, PRIMARY_LANGUAGE, PrimaryLanguageCode, PrimeLang, SecondLang',
  LanguageUseType BOOLEAN COMMENT 'src rows 93; IsPrimaryLanguage'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.BridgePersonRaceEthnicityWaExt (
  BridgePersonRaceEthnicityId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceRaceEthnicityTypeId STRING COMMENT 'src rows 91,94,1129,1433; EthnicityTypeId, RaceTypeId',
  SourceRaceEthnicityCode STRING COMMENT 'src rows 173,177,179,184,195,202,214,215,216,219,223,238...; AfricanAmerican, Asian, CENSUS_HISP_CD, CENSUS_RACE_CD, CENSUS_RACE_CD2, Caucasian, ETH_ORIG, EastIndian, EthCode, EthnicCode, EthnicOther, Ethnicity, HISPANIC, Hispanic, HispanicO',
  ReportedRaceEthnicityRollup STRING COMMENT 'src rows 630,1074,1075,1132,1436,1832,1918,1929,1950,2277,2351,2398...; CEDARSRaceEthnicity, FedEthTypeRollup, FederalEthRaceRollupCode, FederalEthRaceRollupName, HU_STU_OF_COLOR, LastReportedOSPIRaceEthnicity, RACE_ETHNIC_CODE, RaceEthnicity, STU_OF_C',
  SchoolYearId BIGINT COMMENT 'src rows 1125,1429; SchoolYear',
  SourceSchoolYear STRING COMMENT 'src rows 1125,1429; SchoolYear',
  LeaId BIGINT COMMENT 'src rows 1126,1135,1430,1439; DistrictCode, DistrictOrganizationId',
  PersonId BIGINT COMMENT 'src rows 1127,1431; SSID',
  RaceOrEthnicityRecordType STRING COMMENT 'src rows 1128,1432; RaceOrEth',
  SourceRaceEthnicityDescription STRING COMMENT 'src rows 1131,1435; EthDesc, RaceDescription',
  SourceStatusStartDate STRING COMMENT 'src rows 1133,1437; EthStartDate, RaceStartDate',
  SourceStatusEndDate STRING COMMENT 'src rows 1134,1438; EthEndDate, RaceEndDate',
  SourceSubmitDate DATE COMMENT 'src rows 1136,1440; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1137,1441; ExtractDate',
  CollectionMethodCodeId STRING COMMENT 'src rows 1138,1442; EthnicityCollectionMethodID, RaceCollectionMethodID',
  CollectionMethodCode STRING COMMENT 'src rows 1139,1443; EthnicityCollectionMethodCode, RaceCollectionMethodCode',
  CollectionMethodDescription STRING COMMENT 'src rows 1140,1444; EthnicityCollectionMethod, RaceCollectionMethod'
)
USING DELTA
CLUSTER BY (PersonId)
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimAssessments_WaExt (
  DimAssessmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  TestCode STRING COMMENT 'src rows 438; test_code'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimCalendarSessions_WaExt (
  DimCalendarSessionId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 1340; SchoolYear',
  SourceSubmitDate DATE COMMENT 'src rows 1350; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1351; ExtractDate'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimCipCodes_WaExt (
  DimCipCodeId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  BasicSkillCat STRING COMMENT 'src rows 2154; BASIC_SKILL_CAT',
  CipAggregate STRING COMMENT 'src rows 2157; CIP_AGGREGATE',
  CipDiscipline STRING COMMENT 'src rows 2158; CIP_DISCIPLINE',
  CipFacAggregate STRING COMMENT 'src rows 2159; CIP_FAC_AGGREGATE',
  CipGrp STRING COMMENT 'src rows 2160; CIP_GRP',
  CipType STRING COMMENT 'src rows 2162; CIP_TYPE',
  BsInd STRING COMMENT 'src rows 2187; BS_IND',
  FirstApproved STRING COMMENT 'src rows 2283; FIRST_APPROVED',
  LastApproved STRING COMMENT 'src rows 2374; LAST_APPROVED',
  Revised STRING COMMENT 'src rows 2412; REVISED',
  SubjCluster STRING COMMENT 'src rows 2448; SUBJ_CLUSTER'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimCredentialIssuers_WaExt (
  DimCredentialIssuerId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  OspiRecommendingAgencyCode STRING COMMENT 'src rows 546; CertificateRecommendingAgencyCode',
  OspiIssueSourceCode STRING COMMENT 'src rows 549,561; CertificateIssueSourceCode, EndorsementIssueSourceCode',
  LniProgramId STRING COMMENT 'src rows 809; Program Id'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimEarlyLearningOrganizations_WaExt (
  DimEarlyLearningOrganizationId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ZipExtra STRING COMMENT 'src rows 160; ZipExtra',
  SiteEsdOrganizationId BIGINT COMMENT 'src rows 163; ESDId',
  LegislativeDistrictId STRING COMMENT 'src rows 164; LegislativeDistrictId',
  SiteLeaId BIGINT COMMENT 'src rows 165,167; CountyDistrictCode, SchoolDistrictId',
  ElmsOrganizationRelationshipId STRING COMMENT 'src rows 122,151; OrganizationRelationshipId',
  OrganizationName STRING COMMENT 'src rows 124,144,147,150,155,182,230,232,275,290; Contractor, ContractorName, ProviderName, SIteName, Site, SiteName, Subcontractor',
  ElmsOrganizationId STRING COMMENT 'src rows 125,142,145,148,154,348,356; ContractorID, ELMS_Contractor_ID, SiteID, SiteOrganizationID, SubcontractorID',
  ElmsOrganizationTypeId STRING COMMENT 'src rows 126,143,146,149; ContractorTypeID, SiteOrganizationTypeID, SiteTypeID, SubcontractorTypeID',
  DcyfLicensedProviderNumber STRING COMMENT 'src rows 168; ProviderNumber',
  ProvidesWrapAroundChildCare STRING COMMENT 'src rows 169; ProvidesWrapAroundChildCare',
  IsLicensedChildCareFacility BOOLEAN COMMENT 'src rows 170; IsLicensedChildCareFacility',
  IsOperatedByTribalOrganization BOOLEAN COMMENT 'src rows 171; IsOperatedByTribalOrganization',
  SiteType STRING COMMENT 'src rows 172; SiteType',
  HistEceapSiteCode STRING COMMENT 'src rows 231; SiteCodeAlpha',
  EsitOrganizationId STRING COMMENT 'src rows 240; ESITOrganizationId',
  SspsProviderNumber STRING COMMENT 'src rows 274; providernumber',
  ProviderType STRING COMMENT 'src rows 286; Provider_Type',
  EceapContractorCode STRING COMMENT 'src rows 357; ECEAP_Contractor'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimEmployers_WaExt (
  DimEmployerId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  EsdRun STRING COMMENT 'src rows 668; Reporting Unit Number (RUN)',
  EiNumber STRING COMMENT 'src rows 669; EI Number',
  DoingBusinessAsName STRING COMMENT 'src rows 675; Trade Name/DBA',
  UiStreetAddressLine1 STRING COMMENT 'src rows 676; UI Street Address - Line 1',
  UiStreatAddressLine2 STRING COMMENT 'src rows 677; UI Streat Address - Line 2',
  UiAddressCity STRING COMMENT 'src rows 678; UI Address - City',
  UiAddressState STRING COMMENT 'src rows 679; UI Address - State',
  UiAddressZip STRING COMMENT 'src rows 680; UI Address - ZIP',
  UiAddressZipExtension STRING COMMENT 'src rows 681; UI Address - ZIP extension',
  PhysicalLocationStreetAddressLine2 STRING COMMENT 'src rows 683; Physical Location Street Address - Line 2',
  PhysicalLocationAddressState STRING COMMENT 'src rows 685; Physical Location Address - State',
  PhysicalLocationAddressZipExtension STRING COMMENT 'src rows 687; Physical Location Address - ZIP extension',
  MailingOtherAddressMoaLine2 STRING COMMENT 'src rows 689; Mailing/Other Address (MOA) - Line 2',
  MailingOtherAddressMoaCity STRING COMMENT 'src rows 690; Mailing/Other Address (MOA) - City',
  MailingOtherAddressMoaState STRING COMMENT 'src rows 691; Mailing/Other Address (MOA) - State',
  MailingOtherAddressMoaZip STRING COMMENT 'src rows 692; Mailing/Other Address (MOA) - ZIP',
  MailingOtherAddressMoaZipExtension STRING COMMENT 'src rows 693; Mailing/Other Address (MOA) - ZIP extension',
  MailingOtherAddressMoaType STRING COMMENT 'src rows 694; Mailing/Other Address (MOA) type',
  ReportingUnitDescription STRING COMMENT 'src rows 695; Reporting Unit Description',
  AreaCode STRING COMMENT 'src rows 696; Area Code',
  PhonePrefix STRING COMMENT 'src rows 697; Phone Prefix',
  PhoneSuffix STRING COMMENT 'src rows 698; Phone Suffix',
  setup_date DATE COMMENT 'src rows 699,700,701; Setup Date - Day, Setup Date - Month, Setup Date - Year',
  initial_liability_date DATE COMMENT 'src rows 702,703,704; Initial Date of Liability - Day, Initial Date of Liability - Month, Initial Date of Liability - Year',
  end_liability_date DATE COMMENT 'src rows 705,706,707; End of Liability Date - Day, End of Liability Date - Month, End of Liability Date - year',
  reactivation_date DATE COMMENT 'src rows 708,709,710; Reactivation Date - Day, Reactivation Date - Month, Reactivation Date - Year',
  OldCountyCode STRING COMMENT 'src rows 715; Old County Code',
  OldOwnershipCode STRING COMMENT 'src rows 716; Old Ownership Code',
  OldTownshipCode STRING COMMENT 'src rows 718; Old Township Code',
  MaximumReportingUnitNumber STRING COMMENT 'src rows 719; Maximum Reporting Unit Number',
  OldNaicsCode STRING COMMENT 'src rows 721; Old NAICS code',
  SpecialIndicatorCode STRING COMMENT 'src rows 723; Special Indicator Code',
  AgentCode STRING COMMENT 'src rows 724; Agent Code',
  SicCode STRING COMMENT 'src rows 725; SIC Code',
  NstaMostlyBlank STRING COMMENT 'src rows 726; NSTA - mostly blank',
  EmploymentNaicsCode STRING COMMENT 'src rows 727; NAICS code',
  OwnershipCode STRING COMMENT 'src rows 728; Ownership Code',
  OrganizationTypeCode STRING COMMENT 'src rows 729; Organization Type Code',
  CountyCode STRING COMMENT 'src rows 730; County Code',
  TownshipCode STRING COMMENT 'src rows 731; Township Code',
  AuxiliaryCode STRING COMMENT 'src rows 732; Auxiliary Code',
  TypeOfCoverageCode STRING COMMENT 'src rows 743; Type of Coverage Code',
  MeeiCode STRING COMMENT 'src rows 744; MEEI Code',
  UiAddressTypeCode STRING COMMENT 'src rows 752; UI Address Type Code',
  PlaChangedDate DATE COMMENT 'src rows 753,754,755; Date PLA Day Changed, Date PLA Month Changed, Date PLA Year Changed',
  GeocodingSoftware STRING COMMENT 'src rows 756; Geocoding Software',
  GeocodingSource STRING COMMENT 'src rows 757; Geocoding Source',
  MatchCode STRING COMMENT 'src rows 758; Match Code',
  LocationCode STRING COMMENT 'src rows 759; Location Code',
  YearOfNewLatitudeAndLongitude DECIMAL(12,3) COMMENT 'src rows 762; Year of New Latitude and Longitude',
  QuarterOfNewLatitudeAndLongitude DECIMAL(12,3) COMMENT 'src rows 763; Quarter of New Latitude and Longitude',
  PlaceCode STRING COMMENT 'src rows 764; Place Code',
  ClassCode STRING COMMENT 'src rows 765; Class Code',
  CensusBlock STRING COMMENT 'src rows 766; Census Block',
  CensusTract STRING COMMENT 'src rows 767; Census Tract',
  AddressContactSource STRING COMMENT 'src rows 768; Address/Contact Source',
  ArsThirdPartyAgent STRING COMMENT 'src rows 783; ARS Third Party Agent',
  TelephoneExtension STRING COMMENT 'src rows 784; Telephone Extension',
  Es202ContactAttentionLine STRING COMMENT 'src rows 785; ES-202 Contact (Attention Line)',
  ContactTitle STRING COMMENT 'src rows 786; Contact Title',
  ContactEMailAddress STRING COMMENT 'src rows 787; Contact e-mail address',
  FaxAreaCode STRING COMMENT 'src rows 788; Fax Area Code',
  FaxPhoneNumber STRING COMMENT 'src rows 789; Fax Phone Number',
  Fein STRING COMMENT 'src rows 802; FEIN'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimIeus_WaExt (
  DimIeuId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ElmsEsdId STRING COMMENT 'src rows 163; ESDId'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimK12CourseSections_WaExt (
  DimK12CourseSectionId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  Term STRING COMMENT 'src rows 1540,1602; Term',
  ContentAreaCode STRING COMMENT 'src rows 1548,1610; ContentAreaCode',
  AdvancedPlacementCourseCode STRING COMMENT 'src rows 1550; APIBCourseCode',
  CareerClusterCode STRING COMMENT 'src rows 1554; CTEClusterID',
  CteClusterName STRING COMMENT 'src rows 1555,1617; CTEClusterName',
  CtePathwayId STRING COMMENT 'src rows 1556,1618; CTEPathwayID',
  CtePathwayName STRING COMMENT 'src rows 1557,1619; CTEPathwayName',
  FullCourseDesignationCode STRING COMMENT 'src rows 1558,1620; FullCourseDesignationCode',
  TechPrepFlag BOOLEAN COMMENT 'src rows 1559,1621; TechPrepFlag',
  InternationalBaccalaureateFlag BOOLEAN COMMENT 'src rows 1560,1622; InternationalBaccalaureateFlag',
  CollegeattheHighSchoolFlag BOOLEAN COMMENT 'src rows 1561,1623; CollegeattheHighSchoolFlag',
  HonorsFlag BOOLEAN COMMENT 'src rows 1562,1624; HonorsFlag',
  AdvancedPlacementFlag BOOLEAN COMMENT 'src rows 1563,1625; AdvancedPlacementFlag',
  RunningStartFlag BOOLEAN COMMENT 'src rows 1564,1626; RunningStartFlag',
  CollegeAcademicDistributionRequi STRING COMMENT 'src rows 1565,1627; CollegeAcademicDistributionRequi',
  CambridgeProgramFlag BOOLEAN COMMENT 'src rows 1566,1628; CambridgeProgramFlag',
  OnlineFlag BOOLEAN COMMENT 'src rows 1567,1629; OnlineFlag',
  LocalCompetencyTestFlag BOOLEAN COMMENT 'src rows 1568,1630; LocalCompetencyTestFlag',
  NationalCompetencyTestFlag BOOLEAN COMMENT 'src rows 1569,1631; NationalCompetencyTestFlag',
  QuantitativeFlag BOOLEAN COMMENT 'src rows 1570,1632; QuantitativeFlag',
  ScienceLabFlag BOOLEAN COMMENT 'src rows 1571,1633; ScienceLabFlag',
  NonInstructionalTimeFlag BOOLEAN COMMENT 'src rows 1572,1634; NonInstructionalTimeFlag',
  DistrictOrLocalDualCreditPgm DECIMAL(12,3) COMMENT 'src rows 1582,1637; DistrictOrLocalDualCreditPgm',
  Youth1418ReengagementDualCredit DECIMAL(12,3) COMMENT 'src rows 1583,1638; Youth1418ReengagementDualCredit',
  LocallyDeterminedCourseLocallyAdministeredAssessmentFlag BOOLEAN COMMENT 'src rows 1584; LocallyDeterminedCourseLocallyAdministeredAssessmentFlag',
  DualLanguageInstructionTypeCode STRING COMMENT 'src rows 1586,1655; DualLanguageInstructionTypeCode',
  DualLanguageInstructionLanguageCode STRING COMMENT 'src rows 1589,1658; DualLanguageInstructionLanguageCode',
  LocalTransitionFlag BOOLEAN COMMENT 'src rows 1591,1660; LocalTransitionFlag',
  CteCorePlusFlag BOOLEAN COMMENT 'src rows 1592,1661; CTECorePlusFlag',
  TribalLanguageCompetencyTestFlag BOOLEAN COMMENT 'src rows 1593,1672; TribalLanguageCompetencyTestFlag',
  StateCourseCode STRING COMMENT 'src rows 1608; StateCourseCode',
  LocallyDeterminedCourseLocallyAd STRING COMMENT 'src rows 1639; LocallyDeterminedCourseLocallyAd',
  SequenceCode STRING COMMENT 'src rows 1663; SequenceCode',
  SequenceGroupCode STRING COMMENT 'src rows 1665; SequenceGroupCode',
  CteCorePlusAdvancedManufacturingFlag BOOLEAN COMMENT 'src rows 1668; CTECorePlusAdvancedManufacturingFlag',
  CteCorePlusMaritimeFlag BOOLEAN COMMENT 'src rows 1669; CTECorePlusMaritimeFlag',
  CteCorePlusAerospaceFlag BOOLEAN COMMENT 'src rows 1670; CTECorePlusAerospaceFlag',
  CteCorePlusConstructionFlag BOOLEAN COMMENT 'src rows 1671; CTECorePlusConstructionFlag'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimK12Courses_WaExt (
  DimK12CourseId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 955; SchoolYear',
  SourceSchoolYear STRING COMMENT 'src rows 955; SchoolYear',
  LeaId BIGINT COMMENT 'src rows 956; DistrictCode',
  K12SchoolId BIGINT COMMENT 'src rows 958,960; LocationID, SchoolCode',
  ContentAreaCode STRING COMMENT 'src rows 963; ContentAreaCode',
  CourseDesignationCode STRING COMMENT 'src rows 965; CourseDesignationCode',
  StateCourseCode STRING COMMENT 'src rows 966; StateCourseCode',
  ClassificationOfInstructionalProgramCode STRING COMMENT 'src rows 970; CTECIPCode',
  CteClusterName STRING COMMENT 'src rows 973; CTEClusterName',
  CtePathwayId STRING COMMENT 'src rows 974; CTEPathwayID',
  CtePathwayName STRING COMMENT 'src rows 975; CTEPathwayName',
  IsDirectTranscriptionAvailable BOOLEAN COMMENT 'src rows 976; IsDirectTranscriptionAvailable',
  SourceSubmitDate DATE COMMENT 'src rows 978; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 979; ExtractDate',
  CteCourseEquivalencyIdentityCode STRING COMMENT 'src rows 980; CTECourseEquivalencyIdentityCode',
  CteEquivalencyCode STRING COMMENT 'src rows 983; CTEEquivalencyCode',
  DualLanguageInstructionTypeCode STRING COMMENT 'src rows 986; DualLanguageInstructionTypeCode',
  DualLanguageInstructionLanguageC STRING COMMENT 'src rows 989; DualLanguageInstructionLanguageC',
  WaCourseLevelCode STRING COMMENT 'src rows 991; CourseLevelCode',
  IndustryCertificationOffered STRING COMMENT 'src rows 993; IndustryCertificationOffered',
  SequenceCode STRING COMMENT 'src rows 994; SequenceCode',
  SequenceGroupCode STRING COMMENT 'src rows 996; SequenceGroupCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimK12Schools_WaExt (
  DimK12SchoolId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  OspiOrgId STRING COMMENT 'src rows 622,940,1000,1311,1344,1763,2639; SchoolId, SchoolOrgID, SchoolOrganizationId, Serving School Id',
  DistrictSisLocationId STRING COMMENT 'src rows 941,960,1001,1052,1148,1216,1283,1347,1357,1417,1452,1533...; LocationID, LocationId',
  LowestGrade STRING COMMENT 'src rows 1684; LOWEST_GRADE',
  HighestGrade STRING COMMENT 'src rows 1685; HIGHEST_GRADE',
  GradeSpan STRING COMMENT 'src rows 1686; Grade_Span',
  SchoolLevel STRING COMMENT 'src rows 1687; SCHOOL_LEVEL',
  AypSchoolTypeCode STRING COMMENT 'src rows 1688; SCHOOL_TYPE_CD',
  MlocaleTypeCd STRING COMMENT 'src rows 1740; MLOCALE_TYPE_CD',
  MlocaleTypeDesc STRING COMMENT 'src rows 1741; MLOCALE_TYPE_DESC',
  UlocaleTypeCd STRING COMMENT 'src rows 1742; ULOCALE_TYPE_CD',
  UlocaleTypeDesc STRING COMMENT 'src rows 1743; ULOCALE_TYPE_DESC',
  UrbanRural STRING COMMENT 'src rows 1744; Urban_Rural',
  GeogSetting STRING COMMENT 'src rows 1745; Geog_Setting',
  SchoolYearId BIGINT COMMENT 'src rows 1749; SCHOOL_YEAR',
  SourceSchoolYear STRING COMMENT 'src rows 1749; SCHOOL_YEAR',
  SbctcHighSchoolCode STRING COMMENT 'src rows 2335; HI_SCHL'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimLeas_WaExt (
  DimLeaId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ElmsSchoolDistrictId STRING COMMENT 'src rows 106,165; IEPSchoolDistrictId, SchoolDistrictId',
  OspiOrgId STRING COMMENT 'src rows 569,621,938,939,998,999,1126,1308,1341,1391,1430,1646...; ApprovedOnlinePGMResidentDistOrg, ApprovedOnlinePGMResidentDistOrgId, DistrictOrgID, DistrictOrganizationId, OrganizationId, Resident District Id, ResidentDistrictOrgID, Serving Di'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimOrganizationCalendarSessions_WaExt (
  DimOrganizationCalendarSessionId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PsInstitutionId BIGINT COMMENT 'src rows 369,2089; inst_code, institution',
  SchoolYearId BIGINT COMMENT 'src rows 370,2084; academic_year, inst_enroll_year',
  SourceInstEnrollYear STRING COMMENT 'src rows 370; inst_enroll_year',
  SummerLead STRING COMMENT 'src rows 371; summer_lead',
  AcademicTermDesignatorId BIGINT COMMENT 'src rows 372,2091; inst_enroll_term, term',
  SourceInstEnrollTerm STRING COMMENT 'src rows 372; inst_enroll_term',
  PsCampusOrganizationId BIGINT COMMENT 'src rows 373,2086; campus, course_campus',
  CampusEnrollTermSys STRING COMMENT 'src rows 374; campus_enroll_term_sys',
  CensusDate STRING COMMENT 'src rows 377,2087; campus_enroll_census, census_date',
  SourceAcademicYear STRING COMMENT 'src rows 2084; academic_year',
  SourceRecordNumber STRING COMMENT 'src rows 2090; record_number',
  SourceTerm STRING COMMENT 'src rows 2091; term',
  TermSystem STRING COMMENT 'src rows 2092; term_system'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimOrganizations_WaExt (
  DimOrganizationId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  EppCampusName STRING COMMENT 'src rows 373; course_campus',
  CedarsOnlineProviderCode STRING COMMENT 'src rows 1387,1641; ApprovedOnlineProviderCode',
  CedarsOnlineProgramCode STRING COMMENT 'src rows 1389,1644; ApprovedOnlineProgramCode',
  CedarsOnlineProgramListOrder STRING COMMENT 'src rows 1393,1648; ApprovedOnlineProgramListOrder',
  CedarsNonpublicAgencyId STRING COMMENT 'src rows 1469; NonPublicAgencyId',
  CedarsNonpublicAgencyCode STRING COMMENT 'src rows 1470; NonPublicAgencyCode',
  CedarsOnlineProviderId STRING COMMENT 'src rows 1640; ApprovedOnlineProviderId',
  CedarsOnlineProgramId STRING COMMENT 'src rows 1643; ApprovedOnlineProgramId',
  OpenDoorsProviderCode STRING COMMENT 'src rows 1764; Provider Code',
  PcheesCampusId STRING COMMENT 'src rows 1961,1998,2028,2045,2086; campus',
  SbctcDocSiteCode STRING COMMENT 'src rows 2198,2303; DOC_SITE',
  SbctcDistrictCode STRING COMMENT 'src rows 2240; DIST'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimPeople_WaExt (
  DimPersonId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  BirthYear SMALLINT COMMENT 'src rows 89,178,244,278,329,402,537,539,578,580,626,843...; BIRTH_DATE, Birth Date, BirthDate, BirthMonth, BirthYM, BirthYear, Birthdate, DOB, Date_of_Birth, SRBirthDate, StaffBirthDate, StudentBirthDate, WaK_Birthdate, birth_date',
  BirthMonth SMALLINT COMMENT 'src rows 89,178,244,278,329,402,537,539,578,580,626,843...; BIRTH_DATE, Birth Date, BirthDate, BirthMonth, BirthYM, BirthYear, Birthdate, DOB, Date_of_Birth, SRBirthDate, StaffBirthDate, StudentBirthDate, WaK_Birthdate, birth_date',
  SexCode STRING COMMENT 'src rows 90,229,245,841,2491,2596,2632,2677; Gender, GenderTypeId, Sex, StudentGender',
  FederalRaceEthnicityRollup STRING COMMENT 'src rows 91,94,173,177,179,184,195,202,214,215,216,219...; AfricanAmerican, Asian, CEDARSRaceEthnicity, CENSUS_HISP_CD, CENSUS_RACE_CD, CENSUS_RACE_CD2, Caucasian, ETH_ORIG, EastIndian, EthCode, EthDesc, EthEndDate, EthStartDate, EthnicCod',
  CountryOfBirthCode STRING COMMENT 'src rows 1071; BirthCountryCode'
)
USING DELTA
COMMENT 'WA person attributes not in CEDS DW | Grain: 1:1 with DimPeople version'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Type 2 (follows DimPeople)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimPsCourses_WaExt (
  DimPsCourseId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CourseId STRING COMMENT 'src rows 2207; COURSE_ID',
  CourseNum STRING COMMENT 'src rows 2208; COURSE_NUM',
  CourseNumPrefix STRING COMMENT 'src rows 2210; COURSE_NUM_PREFIX',
  CourseNumSuffix STRING COMMENT 'src rows 2212; COURSE_NUM_SUFFIX'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.DimPsInstitutions_WaExt (
  DimPsInstitutionId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS dimension version',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CeebCode STRING COMMENT 'src rows 369,379,393,430,451,472,1969,1975,2000,2023,2035,2063...; inst_code, institution, previous_institution',
  WaPublicFlag BOOLEAN COMMENT 'src rows 2102; WAPublicFlag',
  OrganizationYear STRING COMMENT 'src rows 2103; OrganizationYear',
  InstCatLvl STRING COMMENT 'src rows 2104; InstCatLvl',
  PsOrganizationLevelTtl STRING COMMENT 'src rows 2105; PSOrganizationLevelTTL',
  PsOrganizationLevelTtlSrc STRING COMMENT 'src rows 2106; PSOrganizationLevelTTL_Src',
  CollegeState STRING COMMENT 'src rows 2118; College_State',
  N2Year4Year STRING COMMENT 'src rows 2119; _2_year_4_year',
  PublicPrivate STRING COMMENT 'src rows 2120; Public_Private',
  CtclinkInstitutionCode STRING COMMENT 'src rows 2357,2358,2359,2360,2361,2366; INSTITUTION',
  SbctcCollegeCode STRING COMMENT 'src rows 2180,2252,2261,2299,2332,2429,2450; COLLEGE',
  ParentCollegeDistrictOrganizationId BIGINT COMMENT 'src rows 2240; DIST',
  CollegeDistrictOrganizationId BIGINT COMMENT 'src rows 2240; DIST',
  WsacInstitutionCode STRING COMMENT 'src rows 2482; WSACInstitutionCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactCredentialAwards_WaExt (
  FactCredentialAwardId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CertificateStatusCode STRING COMMENT 'src rows 544; CertificateStatusCode',
  CertificateCredentialSourceCode STRING COMMENT 'src rows 545; CertificateCredentialSourceCode',
  CertificateRecommendationDate DATE COMMENT 'src rows 548; CertificateRecommendationDate',
  IssueSourceOrgOrganizationId BIGINT COMMENT 'src rows 549,561; CertificateIssueSourceCode, EndorsementIssueSourceCode',
  CertificateOriginalIssueDate DATE COMMENT 'src rows 550; CertificateOriginalIssueDate',
  CertificateIssueDate DATE COMMENT 'src rows 551; CertificateIssueDate',
  CertificateRenewDate DATE COMMENT 'src rows 554; CertificateRenewDate',
  EndorsementCode STRING COMMENT 'src rows 555; EndorsementCode',
  GradeCode STRING COMMENT 'src rows 556; GradeCode',
  EndorsementStatusCode STRING COMMENT 'src rows 557; EndorsementStatusCode',
  EndorsementCredentialRuleCode STRING COMMENT 'src rows 558; EndorsementCredentialRuleCode',
  EndorsementCredentialSourceCode STRING COMMENT 'src rows 559; EndorsementCredentialSourceCode',
  EndorsementRecommendationDate DATE COMMENT 'src rows 560; EndorsementRecommendationDate',
  EndorsementOriginalIssueDate DATE COMMENT 'src rows 562; EndorsementOriginalIssueDate',
  EndorsementIssueDate DATE COMMENT 'src rows 563; EndorsementIssueDate',
  CredentialAwardStartDate DATE COMMENT 'src rows 564; EndorsementEffectiveDate',
  CredentialExpirationDate DATE COMMENT 'src rows 565; EndorsementExpireDate',
  EndorsementRenewDate DATE COMMENT 'src rows 566; EndorsementRenewDate'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactElChildAssessments_TsGoldWaExt (
  FactElChildAssessmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceDatasetName STRING COMMENT 'src rows 287; SourceDataset',
  ProgramId STRING COMMENT 'src rows 288; ProgramID',
  Program STRING COMMENT 'src rows 289; Program',
  FundingSources STRING COMMENT 'src rows 294; Funding_Sources',
  AgeGrade STRING COMMENT 'src rows 295; Age_Grade',
  EnglishLanguageAcquisitionDa STRING COMMENT 'src rows 303; English_Language_Acquisition_Da',
  DomainsMeetOrExceed DECIMAL(12,3) COMMENT 'src rows 304; Domains_Meet_or_Exceed',
  IsSpanishLang STRING COMMENT 'src rows 305; Is_Spanish_Lang',
  SeKr STRING COMMENT 'src rows 306; SE_KR',
  PhKr STRING COMMENT 'src rows 307; PH_KR',
  LaKr STRING COMMENT 'src rows 308; LA_KR',
  SlaNn STRING COMMENT 'src rows 312; SLA_NN',
  SlaKr STRING COMMENT 'src rows 313; SLA_KR',
  CgKr STRING COMMENT 'src rows 314; CG_KR',
  LiKr STRING COMMENT 'src rows 315; LI_KR',
  SliNn STRING COMMENT 'src rows 319; SLI_NN',
  SliKr STRING COMMENT 'src rows 320; SLI_KR',
  MaKr STRING COMMENT 'src rows 321; MA_KR',
  HasContentAreas STRING COMMENT 'src rows 322; Has_Content_Areas',
  HasOptionalPhysicalDims STRING COMMENT 'src rows 323; Has_Optional_Physical_Dims',
  HasOptionalDimensions STRING COMMENT 'src rows 324; Has_Optional_Dimensions',
  SourceSeason STRING COMMENT 'src rows 325; season',
  SourceYear STRING COMMENT 'src rows 326; year',
  AgeInMonths DECIMAL(12,3) COMMENT 'src rows 328; Age_in_Months',
  WheMeetOrExceed STRING COMMENT 'src rows 350; WHE_Meet_or_Exceed',
  KReadinessAccomplished STRING COMMENT 'src rows 353; K_Readiness_Accomplished',
  DomainsCompleted DECIMAL(12,3) COMMENT 'src rows 354; Domains_Completed',
  SchoolYear STRING COMMENT 'src rows 355; SchoolYear',
  HlsScore DECIMAL(12,3) COMMENT 'src rows 359; HLS_Score',
  ChildObservations DECIMAL(12,3) COMMENT 'src rows 360; Child_observations',
  CognitiveCompletionFlag STRING COMMENT 'src rows 362; Cognitive_Completion_Flag',
  LiteracyCompletionFlag STRING COMMENT 'src rows 363; Literacy_Completion_Flag',
  LanguageCompletionFlag STRING COMMENT 'src rows 364; Language_Completion_Flag',
  PhysicalCompletionFlag STRING COMMENT 'src rows 365; Physical_Completion_Flag',
  TeacherIrrStatus STRING COMMENT 'src rows 366; Teacher_IRR_Status',
  MathematicsCompletionFlag STRING COMMENT 'src rows 367; Mathematics_Completion_Flag',
  SocialEmotionalCompletion STRING COMMENT 'src rows 368; Social_Emotional_Completion'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactElChildEnrollments_ElmsWaExt (
  FactElChildEnrollmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ChildClassId STRING COMMENT 'src rows 116; ChildClassId'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactElChildEnrollments_HistEceapWaExt (
  FactElChildEnrollmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  County DECIMAL(12,3) COMMENT 'src rows 183; County',
  LivingZipDerived STRING COMMENT 'src rows 211; LivingZip_derived',
  SourceProgramYear STRING COMMENT 'src rows 222; ProgramYear',
  SourceRecordId STRING COMMENT 'src rows 225; RecordID',
  SchoolDistrict STRING COMMENT 'src rows 227; SchoolDistrict'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactElChildServicesApplications_EligibilityResponsesWaExt (
  FactElChildServicesApplicationId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp'
  -- Q{BooleanQuestionID}Answer: one BOOLEAN column per source question id (generated from ELMS BooleanQuestion lookup); inventory rows [79, 80]
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactElChildServicesApplications_HistEceapWaExt (
  FactElChildServicesApplicationId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  Age1 STRING COMMENT 'src rows 174; Age1',
  Age2 STRING COMMENT 'src rows 175; Age2',
  AnnualIncome DECIMAL(14,2) COMMENT 'src rows 176; AnnualIncome',
  EiAnnualIncome DECIMAL(14,2) COMMENT 'src rows 185; EIAnnualIncome',
  EiFosterCare STRING COMMENT 'src rows 186; EIFosterCare',
  EiMonthlyIncome DECIMAL(14,2) COMMENT 'src rows 187; EIMonthlyIncome',
  EiMonthlyIncomeDesc DECIMAL(14,2) COMMENT 'src rows 188; EIMonthlyIncomeDesc',
  EitanfFamily STRING COMMENT 'src rows 189; EITANFFamily',
  EligibleIncome DECIMAL(14,2) COMMENT 'src rows 190; EligibleIncome',
  EligibleReturning STRING COMMENT 'src rows 191; EligibleReturning',
  EligibleRisk STRING COMMENT 'src rows 192; EligibleRisk',
  EligibleSpecial STRING COMMENT 'src rows 193; EligibleSpecial',
  FamilyHomeless STRING COMMENT 'src rows 197; FamilyHomeless',
  FosterCareChildrenOnGrant DECIMAL(14,2) COMMENT 'src rows 200; FosterCareChildrenOnGrant',
  FosterCareMonthlyAmount DECIMAL(14,2) COMMENT 'src rows 201; FosterCareMonthlyAmount',
  InPrison1 STRING COMMENT 'src rows 203; InPrison1',
  InPrison2 STRING COMMENT 'src rows 204; InPrison2',
  LearningProgram STRING COMMENT 'src rows 206; LearningProgram',
  LivesWithFosterCare STRING COMMENT 'src rows 207; LivesWithFosterCare',
  LivesWithRelative DECIMAL(12,3) COMMENT 'src rows 208; LivesWithRelative',
  LivesWithSingleParent STRING COMMENT 'src rows 209; LivesWithSingleParent',
  LivesWithTwoParents STRING COMMENT 'src rows 210; LivesWithTwoParents',
  MonthlyIncome DECIMAL(14,2) COMMENT 'src rows 213; MonthlyIncome',
  OverIncome DECIMAL(14,2) COMMENT 'src rows 217; OverIncome',
  OverIncomeExplain DECIMAL(14,2) COMMENT 'src rows 218; OverIncomeExplain',
  NumberOfPeopleInHousehold STRING COMMENT 'src rows 220; PersonsHouse',
  Reason STRING COMMENT 'src rows 224; Reason',
  ResidesWith STRING COMMENT 'src rows 226; ResidesWith',
  TanfMonthlyAmount DECIMAL(14,2) COMMENT 'src rows 233; TANFMonthlyAmount',
  TanfPeopleOnGrant DECIMAL(14,2) COMMENT 'src rows 234; TANFPeopleOnGrant',
  Under20Parent1 STRING COMMENT 'src rows 235; Under20Parent1',
  Under20Parent2 STRING COMMENT 'src rows 236; Under20Parent2',
  Waitlisted STRING COMMENT 'src rows 237; Waitlisted'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactK12ProgramParticipations_WaExt (
  FactK12ProgramParticipationId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 1412; SchoolYear',
  ExitCode STRING COMMENT 'src rows 1424; ExitCode',
  QualificationCode STRING COMMENT 'src rows 1425; QualificationCode',
  SourceSubmitDate DATE COMMENT 'src rows 1427; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1428; ExtractDate',
  LeaMembershipResidentId BIGINT COMMENT 'src rows 1761; Resident District Id',
  ReengagementProviderOrganizationId BIGINT COMMENT 'src rows 1764; Provider Code'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactK12StaffAssignments_WaExt (
  FactK12StaffAssignmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 567; SchoolYear',
  Recno STRING COMMENT 'src rows 607; Recno',
  Area STRING COMMENT 'src rows 608; Area',
  Program STRING COMMENT 'src rows 609; Program',
  Activity STRING COMMENT 'src rows 610; Activity',
  DutyRootCode STRING COMMENT 'src rows 611; Droot',
  DutySuffix STRING COMMENT 'src rows 612; DutySuffix',
  Grade STRING COMMENT 'src rows 613; Grade',
  Asspct DECIMAL(12,3) COMMENT 'src rows 614; Asspct',
  Asssal DECIMAL(14,2) COMMENT 'src rows 616; Asssal',
  Asshpy STRING COMMENT 'src rows 617; Asshpy',
  Major STRING COMMENT 'src rows 618; Major',
  SourceReleaseType STRING COMMENT 'src rows 619; FinalOrPrelim'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactK12StaffCourseSections_WaExt (
  FactK12StaffCourseSectionId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 1528; SchoolYear',
  TeacherIndicatorId STRING COMMENT 'src rows 1575; TeacherIndicatorID',
  WaStaffTypeCode STRING COMMENT 'src rows 1578; StaffTypeCode',
  SourceSubmitDate DATE COMMENT 'src rows 1580; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1581; ExtractDate'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactK12StaffEmployments_WaExt (
  FactK12StaffEmploymentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  Hdeg STRING COMMENT 'src rows 584; Hdeg',
  Hyear STRING COMMENT 'src rows 585; Hyear',
  Acred STRING COMMENT 'src rows 586; Acred',
  Icred STRING COMMENT 'src rows 587; Icred',
  Bcred STRING COMMENT 'src rows 588; Bcred',
  Vcred STRING COMMENT 'src rows 589; Vcred',
  Camix1 STRING COMMENT 'src rows 591; Camix1',
  FtEhrs DECIMAL(12,3) COMMENT 'src rows 592; FTEhrs',
  BaseContractFte DECIMAL(12,3) COMMENT 'src rows 593; BaseContractFTE',
  CertFte DECIMAL(12,3) COMMENT 'src rows 594; CertFTE',
  ClasFte DECIMAL(12,3) COMMENT 'src rows 595; ClasFTE',
  Certbase DECIMAL(14,2) COMMENT 'src rows 596; Certbase',
  Clasbase DECIMAL(14,2) COMMENT 'src rows 597; Clasbase',
  Othersal DECIMAL(14,2) COMMENT 'src rows 598; Othersal',
  Tfinsal DECIMAL(14,2) COMMENT 'src rows 599; Tfinsal',
  Cins DECIMAL(14,2) COMMENT 'src rows 600; Cins',
  Cman DECIMAL(14,2) COMMENT 'src rows 601; Cman',
  Cbrtn STRING COMMENT 'src rows 602; CBRTN',
  Clasflag STRING COMMENT 'src rows 603; Clasflag',
  Certflag STRING COMMENT 'src rows 604; Certflag',
  Ceridate DATE COMMENT 'src rows 605; Ceridate',
  NBcertexpdate DATE COMMENT 'src rows 606; NBcertexpdate'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactK12StudentAcademicRecords_WaExt (
  FactK12StudentAcademicRecordId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CreditsAttemptedCumulative DECIMAL(12,3) COMMENT 'src rows 1083; CumulativeCreditsAttempted',
  CreditsEarnedCumulative DECIMAL(12,3) COMMENT 'src rows 1084; CumulativeCreditsEarned'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactK12StudentAssessments_WaExt (
  FactK12StudentAssessmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  HomeBased STRING COMMENT 'src rows 860; HomeBased',
  PrivateSchool STRING COMMENT 'src rows 861; PrivateSchool',
  SourceSchoolYear STRING COMMENT 'src rows 866,882; SchoolYear',
  StandardMetIndicator BOOLEAN COMMENT 'src rows 872,893; Standard_met_ind',
  WaAttemptCode STRING COMMENT 'src rows 875; Attempt',
  ForeignCode STRING COMMENT 'src rows 877; ForeignCode',
  TestGrade STRING COMMENT 'src rows 898; TestGrade',
  AssessmentAcademicSubject STRING COMMENT 'src rows 900; SubjectName',
  PctCorrect DECIMAL(12,3) COMMENT 'src rows 904; PctCorrect',
  ThetaReading DECIMAL(12,3) COMMENT 'src rows 909; Theta_Reading',
  SemThetaReading DECIMAL(12,3) COMMENT 'src rows 910; SEM_Theta_Reading',
  PctCorrectReading DECIMAL(12,3) COMMENT 'src rows 912; PctCorrect_Reading',
  ThetaWriting DECIMAL(12,3) COMMENT 'src rows 917; Theta_Writing',
  SemThetaWriting DECIMAL(12,3) COMMENT 'src rows 918; SEM_Theta_Writing',
  PctCorrectWriting DECIMAL(12,3) COMMENT 'src rows 920; PctCorrect_Writing',
  ThetaListening DECIMAL(12,3) COMMENT 'src rows 925; Theta_Listening',
  SemThetaListening DECIMAL(12,3) COMMENT 'src rows 926; SEM_Theta_Listening',
  PctCorrectListening DECIMAL(12,3) COMMENT 'src rows 928; PctCorrect_Listening',
  ThetaSpeaking DECIMAL(12,3) COMMENT 'src rows 933; Theta_Speaking',
  SemThetaSpeaking DECIMAL(12,3) COMMENT 'src rows 934; SEM_Theta_Speaking',
  PctCorrectSpeaking DECIMAL(12,3) COMMENT 'src rows 936; PctCorrect_Speaking',
  K12StaffId BIGINT COMMENT 'src rows 1820; WaK_TeacherID'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactK12StudentAssessments_WakidsWaExt (
  FactK12StudentAssessmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceDatasetName STRING COMMENT 'src rows 1816; SourceDataset',
  WakidsClass STRING COMMENT 'src rows 1821; WaK_Class',
  WakidsIep STRING COMMENT 'src rows 1827; WaK_IEP',
  WakidsBilingualFlag STRING COMMENT 'src rows 1828; WaK_BilingualFlag',
  WakidsPrimaryLanguage DECIMAL(12,3) COMMENT 'src rows 1833; WaK_PrimaryLanguage',
  WakidsIfsp STRING COMMENT 'src rows 1834; WaK_IFSP',
  WakidsFreeReducedLunchFlag STRING COMMENT 'src rows 1835; WaK_FreeReducedLunchFlag',
  DomainCompletionIndicator STRING COMMENT 'src rows 1889,1890,1891,1892,1893,1894; WaK_CognitiveCompletionFlag, WaK_LanguageCompletionFlag, WaK_LiteracyCompletionFlag, WaK_MathCompletionFlag, WaK_PhysicalCompletionFlag, WaK_SocialEmotionalCompletionFla',
  WakidsNumberofDomainsReady DECIMAL(12,3) COMMENT 'src rows 1895; WaK_NumberofDomainsReady',
  Wakidsnumberofdomainscomplete DECIMAL(12,3) COMMENT 'src rows 1896; WaK_numberofdomainscomplete',
  ReadinessIndicator STRING COMMENT 'src rows 1897,1898,1899,1900,1901,1902,1943,1947; SpanishLanguageReadinessFlag, SpanishLiteracyReadinessFlag, WaK_CognitiveReadinessFlag, WaK_LanguageReadinessFlag, WaK_LiteracyReadinessFlag, WaK_MathReadinessFlag, WaK_PhysicalRea',
  SourceWaKSchoolYear STRING COMMENT 'src rows 1906; WaK_SchoolYear',
  WakidsHasIep STRING COMMENT 'src rows 1917; WaK_HasIEP',
  WakidsFreeLunch STRING COMMENT 'src rows 1919; WaK_FreeLunch',
  WakidsClassId STRING COMMENT 'src rows 1926; WaK_ClassID',
  WakidsSpecialEd STRING COMMENT 'src rows 1927; WaK_SpecialEd',
  WakidsBilingual STRING COMMENT 'src rows 1928; WaK_Bilingual',
  WakidsNumofDomainsReady4Kindergar DECIMAL(12,3) COMMENT 'src rows 1930; WaK_NumofDomainsReady4Kindergar',
  AgeGrade STRING COMMENT 'src rows 1951; AgeGrade'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactK12StudentCourseSections_WaExt (
  FactK12StudentCourseSectionId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 1594; SchoolYear',
  AlternativeLearningEducationCode STRING COMMENT 'src rows 1606; AlternativeLearningEducationCode',
  SourceSubmitDate DATE COMMENT 'src rows 1635; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1636; ExtractDate',
  OnlineProviderOrganizationId BIGINT COMMENT 'src rows 1640,1641; ApprovedOnlineProviderCode, ApprovedOnlineProviderId',
  OnlineProgramOrganizationId BIGINT COMMENT 'src rows 1643,1644,1648; ApprovedOnlineProgramCode, ApprovedOnlineProgramId, ApprovedOnlineProgramListOrder',
  OnlineProgramResidentLeaOrganizationId BIGINT COMMENT 'src rows 1646; ApprovedOnlinePGMResidentDistOrg',
  IndustryCertificationEarned STRING COMMENT 'src rows 1662; IndustryCertificationEarned',
  WaWorkBasedLearningActivityTypeCode STRING COMMENT 'src rows 1666; WorkBasedLearningActivityTypeCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactK12StudentDailyAttendances_WaExt (
  FactK12StudentDailyAttendanceId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 937; SchoolYear',
  ResidentLeaId BIGINT COMMENT 'src rows 939; ResidentDistrictOrgID',
  WaAbsenceCode STRING COMMENT 'src rows 951; AbsenceCode',
  SourceSubmitDate DATE COMMENT 'src rows 953; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 954; ExtractDate'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactK12StudentDisciplines_WaExt (
  FactK12StudentDisciplineId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  DisciplineRecordScope STRING COMMENT 'src rows 997,1143; SchoolYear',
  SourceSchoolYear STRING COMMENT 'src rows 997,1143; SchoolYear',
  LeaMembershipResidentId BIGINT COMMENT 'src rows 999; ResidentDistrictOrgID',
  PrimarySchoolFlag BOOLEAN COMMENT 'src rows 1006; PrimarySchoolFlag',
  WaIncidentBehaviorCode STRING COMMENT 'src rows 1012,1154; BehaviorCode, BehaviorTypeCode',
  WaDisciplinaryActionCode STRING COMMENT 'src rows 1015,1163; ExclusionaryActionTypeCode, InterventionCode',
  WaWeaponTypeCode STRING COMMENT 'src rows 1020,1159; WeaponCode, WeaponTypeCode',
  WaInterimAlternativeSettingCode BOOLEAN COMMENT 'src rows 1022,1169; IsInIAES, SPEDInterimAlternativeEdSetting',
  SourceSubmitDate DATE COMMENT 'src rows 1023,1188; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1024,1189; ExtractDate',
  IsEmergencyExpulsion BOOLEAN COMMENT 'src rows 1025; IsEmergencyExpulsion',
  NumEeConversionDays DECIMAL(12,3) COMMENT 'src rows 1026; NumEEConversionDays',
  AcademicServicesCode STRING COMMENT 'src rows 1030,1171; AcademicServicesCode, AcademicServicesTypeCode',
  BehaviorServicesCode STRING COMMENT 'src rows 1031,1174; BehaviorServicesCode, BehaviorServicesTypeCode',
  PetitionForReadmissionSubmittedDate STRING COMMENT 'src rows 1034,1176; PetitionForReAdmitSubmittedDate, PetitionForReadmissionSubmittedd',
  PetitionForReadmissionGrantedDate DECIMAL(14,2) COMMENT 'src rows 1035,1177; PetitionForReAdmitGrantedDate, PetitionForReadmissionGrantedDat',
  PetitionTimeFrameCode STRING COMMENT 'src rows 1036,1179; PetitionTimeFrameCode, PetitiontoExceedMorethanOneYear',
  ReengagementMeetingDate DATE COMMENT 'src rows 1038,1184; DateReengagementMeetingHeld, ReengagementMeetingDate',
  ReengagementPlanCode STRING COMMENT 'src rows 1040,1182; ReengagementPlanCode, ReengagementPlanTypeCode',
  AppealCode STRING COMMENT 'src rows 1043,1186; AppealCode, AppealTypeCode',
  TotalExclusionaryTime STRING COMMENT 'src rows 1168; TotalExclusionaryTime',
  StaffInvolvementStatusCode STRING COMMENT 'src rows 1190; StaffInvolvementStatusCode',
  StaffInvolvementTypeCode STRING COMMENT 'src rows 1192; StaffInvolvementTypeCode',
  StaffInvolvementOutcomeCode STRING COMMENT 'src rows 1194; StaffInvolvementOutcomeCode',
  InterpreterRequestReengagMeetingTypeCode STRING COMMENT 'src rows 1197; InterpreterRequestReengagMeetingTypeCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactK12StudentEnrollments_WaExt (
  FactK12StudentEnrollmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 1045; SchoolYear',
  PrimarySchoolFlag BOOLEAN COMMENT 'src rows 1053; PrimarySchoolFlag',
  GradeLevelSortOrder STRING COMMENT 'src rows 1061; GradeLevelSortOrder',
  WaGradeLevel STRING COMMENT 'src rows 1062; GradeLevel',
  DateEnrolledinDistrict DATE COMMENT 'src rows 1063; DateEnrolledinDistrict',
  DateExitedDistrict DATE COMMENT 'src rows 1064; DateExitedDistrict',
  WaWithdrawalCode STRING COMMENT 'src rows 1067; WithdrawalCode',
  SchoolchoicetypeId STRING COMMENT 'src rows 1069; SchoolchoicetypeID',
  GradReqYear STRING COMMENT 'src rows 1080; GradReqYear',
  ExpectedGradYear STRING COMMENT 'src rows 1081; ExpectedGradYear',
  NumberOfDaysInAttendance DECIMAL(12,3) COMMENT 'src rows 1085; NumDaysPresent',
  WaDisabilityCode STRING COMMENT 'src rows 1086; DisabilityCode',
  DisabilityFlag BOOLEAN COMMENT 'src rows 1087; DisabilityFlag',
  ApprvdPrivateSchoolAttendPartTimeCode STRING COMMENT 'src rows 1089; ApprvdPrivateSchoolAttendPartTimeCode',
  ApprvdPrivateSchoolAttendPartTimeFlag BOOLEAN COMMENT 'src rows 1090; ApprvdPrivateSchoolAttendPartTimeFlag',
  HomeBasedAttendPartTimeCode STRING COMMENT 'src rows 1092; HomeBasedAttendPartTimeCode',
  HomeBasedAttendPartTimeFlag BOOLEAN COMMENT 'src rows 1093; HomeBasedAttendPartTimeFlag',
  F1VisaForeignExchgFlag STRING COMMENT 'src rows 1095; F1VisaForeignExchgFlag',
  WaHomelessCode STRING COMMENT 'src rows 1096; HomelessCode',
  HomelessnessStatus BOOLEAN COMMENT 'src rows 1097; HomelessFlag',
  IsStudentImmigrant BOOLEAN COMMENT 'src rows 1099; IsStudentImmigrant',
  FirstEntryDateIntoUsSchool DATE COMMENT 'src rows 1101,1325; InitialUSAPlacementDate, InitialUSPlacementDate',
  NumberOfMonthsUsAttendance DECIMAL(12,3) COMMENT 'src rows 1102,1326; NumMonthsUSAttendance',
  NumberOfMonthsNonUsFormalEducation DECIMAL(12,3) COMMENT 'src rows 1103,1327; NumMonthsNonUSEducation, NumMonthsNonUSFormalEducation',
  SourceSubmitDate DATE COMMENT 'src rows 1104; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1105; ExtractDate',
  ConfirmedTransferInTypeId STRING COMMENT 'src rows 1110; ConfirmedTransferInTypeID',
  WaMilitaryParentOrGuardianCode STRING COMMENT 'src rows 1111; MilitaryParentorGuardianCD',
  AsvabTestStatusCode STRING COMMENT 'src rows 1114; ASVABTestStatusCode',
  AsvabTestScore DECIMAL(12,3) COMMENT 'src rows 1116; ASVABTestScore',
  AsvabTestSchoolYear STRING COMMENT 'src rows 1117; ASVABTestSchoolYear',
  CreditWaiverCode DECIMAL(14,2) COMMENT 'src rows 1118; CreditWaiverCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentAcademicAwards_NscWaExt (
  FactPsStudentAcademicAwardId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  DegreeType STRING COMMENT 'src rows 2107; DegreeType',
  Graduated STRING COMMENT 'src rows 2124; Graduated',
  AcademicAwardTitle STRING COMMENT 'src rows 2126; Degree_Title',
  Major STRING COMMENT 'src rows 2127; Major',
  DegreeCip1 STRING COMMENT 'src rows 2135; Degree_CIP_1',
  DegreeMajor1 STRING COMMENT 'src rows 2136; Degree_Major_1',
  DegreeCip2 STRING COMMENT 'src rows 2137; Degree_CIP_2',
  DegreeMajor2 STRING COMMENT 'src rows 2138; Degree_Major_2',
  DegreeCip3 STRING COMMENT 'src rows 2139; Degree_CIP_3',
  DegreeMajor3 STRING COMMENT 'src rows 2140; Degree_Major_3',
  DegreeCip4 STRING COMMENT 'src rows 2141; Degree_CIP_4',
  DegreeMajor4 STRING COMMENT 'src rows 2142; Degree_Major_4'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentAcademicAwards_PcheesWaExt (
  FactPsStudentAcademicAwardId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceAcademicYear STRING COMMENT 'src rows 1997; academic_year',
  InstitutionalCreditsEarned DECIMAL(12,3) COMMENT 'src rows 2001; institutional_credits_earned',
  PostBaccalaureateStatus STRING COMMENT 'src rows 2002; post_baccalaureate_status',
  NonInstitutionalCreditsEarned DECIMAL(12,3) COMMENT 'src rows 2003; non_institutional_credits_earned',
  FirstMajorProgramId STRING COMMENT 'src rows 2004; program',
  SourceRecordNumber STRING COMMENT 'src rows 2005; record_number',
  SourceTerm STRING COMMENT 'src rows 2009; term',
  TeachingCertification STRING COMMENT 'src rows 2010; teaching_certification'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentAcademicAwards_SbctcWaExt (
  FactPsStudentAcademicAwardId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceQuarter STRING COMMENT 'src rows 2166; QUARTER',
  SourceYear STRING COMMENT 'src rows 2167; YEAR',
  DegreeNum STRING COMMENT 'src rows 2234; DEGREE_NUM',
  Disability STRING COMMENT 'src rows 2238; DISABILITY',
  AwardType STRING COMMENT 'src rows 2255; AWARD_TYPE',
  CenterCd STRING COMMENT 'src rows 2256; CENTER_CD',
  ExitCode STRING COMMENT 'src rows 2257; EXIT_CD',
  AcadProg STRING COMMENT 'src rows 2259; ACAD_PROG',
  UnitedStatesCitizenshipStatus STRING COMMENT 'src rows 2260; CITZ_STAT',
  EconDisadInd STRING COMMENT 'src rows 2266; ECON_DISAD_IND',
  InternationalStudent STRING COMMENT 'src rows 2369; INTERNATIONAL_STUDENT',
  ProgramCompl STRING COMMENT 'src rows 2382; PROGRAM_COMPL',
  ProgramSuffix STRING COMMENT 'src rows 2383; PROGRAM_SUFFIX',
  SourceYrqAdded STRING COMMENT 'src rows 2385; QTR_ADDED',
  RecCd STRING COMMENT 'src rows 2387; REC_CD',
  SourceStrm STRING COMMENT 'src rows 2434; STRM'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentAcademicAwards_WaExt (
  FactPsStudentAcademicAwardId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PsCampusOrganizationId BIGINT COMMENT 'src rows 1998; campus',
  AcademicTermDesignatorId BIGINT COMMENT 'src rows 2009,2166,2434; QUARTER, STRM, term'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentAcademicRecords_WaExt (
  FactPsStudentAcademicRecordId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CreditsEarnedCumulative DECIMAL(12,3) COMMENT 'src rows 2229; CUM_CREDITS_EARNED'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentCourseTranscripts_PcheesWaExt (
  FactPsStudentCourseTranscriptId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceAcademicYear STRING COMMENT 'src rows 2027; academic_year',
  GradeNumber STRING COMMENT 'src rows 2033; grade_number',
  SourceRecordNumber STRING COMMENT 'src rows 2036; record_number',
  RegistrationSequenceNumber DECIMAL(12,3) COMMENT 'src rows 2037; registration_sequence_number',
  RemedialType STRING COMMENT 'src rows 2038; remedial_type',
  CourseRepeatCode STRING COMMENT 'src rows 2039; repeat_status',
  SourceTerm STRING COMMENT 'src rows 2042; term'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentCourseTranscripts_SbctcWaExt (
  FactPsStudentCourseTranscriptId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceYear STRING COMMENT 'src rows 2163; YEAR',
  SourceQuarter STRING COMMENT 'src rows 2181; QUARTER',
  ClockHrInd BOOLEAN COMMENT 'src rows 2193; CLOCK_HR_IND',
  ClvlInd STRING COMMENT 'src rows 2199; CLVL_IND',
  CourseFlag STRING COMMENT 'src rows 2206; COURSE_FLAG',
  CourseNumPrefix STRING COMMENT 'src rows 2211; COURSE_NUM_PREFIX',
  CourseNumSuffix STRING COMMENT 'src rows 2213; COURSE_NUM_SUFFIX',
  CrInd STRING COMMENT 'src rows 2220; CR_IND',
  EnrHr DECIMAL(12,3) COMMENT 'src rows 2268; ENR_HR',
  GpaInd DECIMAL(12,3) COMMENT 'src rows 2315; GPA_IND',
  GrDec DECIMAL(12,3) COMMENT 'src rows 2326; GR_DEC',
  GrQlfr STRING COMMENT 'src rows 2327; GR_QLFR',
  Item STRING COMMENT 'src rows 2373; ITEM',
  SourceYrqAdded STRING COMMENT 'src rows 2386; QTR_ADDED',
  ReqrCourseNum STRING COMMENT 'src rows 2409; REQR_COURSE_NUM',
  ReqrDeptDiv STRING COMMENT 'src rows 2411; REQR_DEPT_DIV',
  SectStat STRING COMMENT 'src rows 2415; SECT_STAT',
  SourceStrm STRING COMMENT 'src rows 2440; STRM',
  Sect STRING COMMENT 'src rows 2445; SECT',
  AcadCareer STRING COMMENT 'src rows 2447; ACAD_CAREER',
  DistanceEducationCourseEnrollment STRING COMMENT 'src rows 2459; DIST_ED',
  EarnInd STRING COMMENT 'src rows 2461; EARN_IND',
  VocInd STRING COMMENT 'src rows 2465; VOC_IND',
  SourceYrq STRING COMMENT 'src rows 2479; YRQ'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentCourseTranscripts_WaExt (
  FactPsStudentCourseTranscriptId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PsCampusOrganizationId BIGINT COMMENT 'src rows 2028; campus'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentEnrollments_NscWaExt (
  FactPsStudentEnrollmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  NscEnrollmentStatus STRING COMMENT 'src rows 2123; Enrollment_Status',
  CollegeSequence STRING COMMENT 'src rows 2128; College_Sequence',
  ClassLevel STRING COMMENT 'src rows 2130; Class_Level',
  EnrollmentCip1 STRING COMMENT 'src rows 2131; Enrollment_CIP_1',
  EnrollmentMajor1 STRING COMMENT 'src rows 2132; Enrollment_Major_1',
  EnrollmentCip2 STRING COMMENT 'src rows 2133; Enrollment_CIP_2',
  EnrollmentMajor2 STRING COMMENT 'src rows 2134; Enrollment_Major_2'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentEnrollments_PcheesWaExt (
  FactPsStudentEnrollmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceAcademicYear STRING COMMENT 'src rows 2043; academic_year',
  ClassStanding STRING COMMENT 'src rows 2046; class_standing',
  Concentration DECIMAL(12,3) COMMENT 'src rows 2047; concentration',
  CumulativeOverallGpaKey DECIMAL(12,3) COMMENT 'src rows 2049; cumulative_overall_GPA_key',
  DisabilityStatus STRING COMMENT 'src rows 2050; disability_status',
  FeeExemptionType1 STRING COMMENT 'src rows 2051; fee_exemption_type_1',
  FeeExemptionType2 STRING COMMENT 'src rows 2052; fee_exemption_type_2',
  FeeExemptionType3 STRING COMMENT 'src rows 2053; fee_exemption_type_3',
  FeePaymentType STRING COMMENT 'src rows 2054; fee_payment_type',
  FeeWaiverType1 DECIMAL(14,2) COMMENT 'src rows 2055; fee_waiver_type_1',
  FeeWaiverType2 DECIMAL(14,2) COMMENT 'src rows 2056; fee_waiver_type_2',
  FeeWaiverType3 DECIMAL(14,2) COMMENT 'src rows 2057; fee_waiver_type_3',
  PellGrantStatus DECIMAL(14,2) COMMENT 'src rows 2066; pell_grant_status',
  PrimarySite STRING COMMENT 'src rows 2067; primary_site',
  SourceRecordNumber STRING COMMENT 'src rows 2073; record_number',
  SubmissionSequence STRING COMMENT 'src rows 2077; submission_sequence',
  SourceTerm STRING COMMENT 'src rows 2078; term',
  UsImmigrationStatus DECIMAL(12,3) COMMENT 'src rows 2079; US_immigration_status',
  VeteranBenefitsType STRING COMMENT 'src rows 2081; veteran_benefits_type',
  VeteranStatus STRING COMMENT 'src rows 2082; veteran_status',
  WaResidencyStatus STRING COMMENT 'src rows 2083; WA_residency_status'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentEnrollments_SbctcWaExt (
  FactPsStudentEnrollmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceQuarter STRING COMMENT 'src rows 2176; QUARTER',
  SourceYear STRING COMMENT 'src rows 2177; YEAR',
  AcadDisadInd BOOLEAN COMMENT 'src rows 2182; ACAD_DISAD_IND',
  ActiveDutyParent STRING COMMENT 'src rows 2183; ACTIVE_DUTY_PARENT',
  AgeGrpPrimary STRING COMMENT 'src rows 2184; AGE_GRP_PRIMARY',
  AgeGrpSecondary STRING COMMENT 'src rows 2185; AGE_GRP_SECONDARY',
  CreditsContract DECIMAL(12,3) COMMENT 'src rows 2223; CREDITS_CONTRACT',
  CreditsState DECIMAL(12,3) COMMENT 'src rows 2225; CREDITS_STATE',
  CreditsStudent DECIMAL(12,3) COMMENT 'src rows 2226; CREDITS_STUDENT',
  CumClvlCrEarned STRING COMMENT 'src rows 2228; CUM_CLVL_CR_EARNED',
  CumHoursEarned DECIMAL(12,3) COMMENT 'src rows 2230; CUM_HOURS_EARNED',
  Disability STRING COMMENT 'src rows 2239; DISABILITY',
  ELearningCode STRING COMMENT 'src rows 2246; eLEARNING_CODE',
  ELearningInd STRING COMMENT 'src rows 2247; eLEARNING_IND',
  EmploymentStatus STRING COMMENT 'src rows 2262; EMPLOYMENT_STATUS',
  ExclBs STRING COMMENT 'src rows 2280; EXCL_BS',
  ExclLl STRING COMMENT 'src rows 2282; EXCL_LL',
  FirstSystemYrq STRING COMMENT 'src rows 2284; FIRST_SYSTEM_YRQ',
  FtesContract DECIMAL(12,3) COMMENT 'src rows 2302; FTES_CONTRACT',
  FtesState DECIMAL(12,3) COMMENT 'src rows 2305; FTES_STATE',
  FtesStudent DECIMAL(12,3) COMMENT 'src rows 2307; FTES_STUDENT',
  FtesTotal DECIMAL(12,3) COMMENT 'src rows 2310; FTES_TOTAL',
  FullPartTimeIndicator STRING COMMENT 'src rows 2312; FULL_PART_TIME_IND',
  GpaClvl DECIMAL(12,3) COMMENT 'src rows 2313; GPA_CLVL',
  GpaQtrCr DECIMAL(12,3) COMMENT 'src rows 2316; GPA_QTR_CR',
  GpaQtrHr DECIMAL(12,3) COMMENT 'src rows 2317; GPA_QTR_HR',
  Age DECIMAL(12,3) COMMENT 'src rows 2319; AGE',
  DegreeOrCertificateSeekingStudent STRING COMMENT 'src rows 2320,2341; AWARD_SEEK, DEGREE_SEEK',
  KindOfStudent STRING COMMENT 'src rows 2323; KIND_OF_STUDENT',
  ClassificationOfInstructionalProgramCode STRING COMMENT 'src rows 2324; PROGRAM_CIP',
  HealthLim STRING COMMENT 'src rows 2328; HEALTH_LIM',
  UnitedStatesCitizenshipStatus STRING COMMENT 'src rows 2331; CITZ_STAT',
  CreditLevel DECIMAL(12,3) COMMENT 'src rows 2333; CREDIT_LEVEL',
  HiSchlCounty DECIMAL(12,3) COMMENT 'src rows 2336; HI_SCHL_COUNTY',
  HiSchlGrad STRING COMMENT 'src rows 2337; HI_SCHL_GRAD',
  HiSchlLastYr STRING COMMENT 'src rows 2338; HI_SCHL_LAST_YR',
  HomeCcDist STRING COMMENT 'src rows 2342; HOME_CC_DIST',
  DualEnroll STRING COMMENT 'src rows 2343; DUAL_ENROLL',
  HomeDist STRING COMMENT 'src rows 2344; HOME_DIST',
  EconDisadInd STRING COMMENT 'src rows 2345; ECON_DISAD_IND',
  HoursContract DECIMAL(12,3) COMMENT 'src rows 2346; HOURS_CONTRACT',
  HoursState DECIMAL(12,3) COMMENT 'src rows 2347; HOURS_STATE',
  HoursStudent DECIMAL(12,3) COMMENT 'src rows 2348; HOURS_STUDENT',
  HoursTotal DECIMAL(12,3) COMMENT 'src rows 2349; HOURS_TOTAL',
  HousingInsecurity STRING COMMENT 'src rows 2350; HOUSING_INSECURITY',
  FamStat STRING COMMENT 'src rows 2353; FAM_STAT',
  FeePay STRING COMMENT 'src rows 2354; FEE_PAY',
  FirstGenerationCollegeStudent DECIMAL(12,3) COMMENT 'src rows 2355; FIRST_GENERATION',
  InstitCategoryIndicator STRING COMMENT 'src rows 2356; INSTIT_CATEGORY_INDICATOR',
  FundSourceIndicator BOOLEAN COMMENT 'src rows 2362; FUND_SOURCE_INDICATOR',
  FundSourcePriority STRING COMMENT 'src rows 2363; FUND_SOURCE_PRIORITY',
  FundSourcePriorityCategory STRING COMMENT 'src rows 2364; FUND_SOURCE_PRIORITY_CATEGORY',
  InternationalStudent STRING COMMENT 'src rows 2370; INTERNATIONAL_STUDENT',
  LimEnglInd STRING COMMENT 'src rows 2375; LIM_ENGL_IND',
  MisStat STRING COMMENT 'src rows 2376; MIS_STAT',
  PerkinsFosterCare STRING COMMENT 'src rows 2379; PERKINS_FOSTER_CARE',
  Intent STRING COMMENT 'src rows 2384; INTENT',
  RecentHiSchl STRING COMMENT 'src rows 2388; RECENT_HI_SCHL',
  PlanAttnd STRING COMMENT 'src rows 2389; PLAN_ATTND',
  PlanWork STRING COMMENT 'src rows 2390; PLAN_WORK',
  PriorEduc STRING COMMENT 'src rows 2393; PRIOR_EDUC',
  ProgramCode STRING COMMENT 'src rows 2394; PROGRAM_CODE',
  PurpAttnd STRING COMMENT 'src rows 2395; PURP_ATTND',
  RegisteredDisability STRING COMMENT 'src rows 2402; REGISTERED_DISABILITY',
  ResidenceCountry DECIMAL(12,3) COMMENT 'src rows 2403; RESIDENCE_COUNTRY',
  ResidenceCounty DECIMAL(12,3) COMMENT 'src rows 2404; RESIDENCE_COUNTY',
  ResidenceState STRING COMMENT 'src rows 2405; RESIDENCE_STATE',
  ResidenceZip STRING COMMENT 'src rows 2406; RESIDENCE_ZIP',
  TuitionResidencyType STRING COMMENT 'src rows 2407; RESIDENT_STATUS',
  RunningStartStatus STRING COMMENT 'src rows 2408; RUNNING_START_STATUS',
  Sda STRING COMMENT 'src rows 2414; SDA',
  Source STRING COMMENT 'src rows 2422; SOURCE',
  SourceYrq STRING COMMENT 'src rows 2423; YRQ',
  StateStart STRING COMMENT 'src rows 2431; STATE_START',
  SourceStrm STRING COMMENT 'src rows 2437; STRM',
  TimeLocInd STRING COMMENT 'src rows 2456; TIME_LOC_IND',
  TimeLocPri STRING COMMENT 'src rows 2457; TIME_LOC_PRI',
  TransferReady STRING COMMENT 'src rows 2460; TRANSFER_READY',
  MilitaryVeteranStatusIndicator STRING COMMENT 'src rows 2464; VET_BENEFITS',
  WorkAttnd STRING COMMENT 'src rows 2474; WORK_ATTND',
  WorkerRetraining STRING COMMENT 'src rows 2477; WORKER_RETRAINING',
  YrqActStart STRING COMMENT 'src rows 2478; YRQ_ACT_START'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactPsStudentEnrollments_WaExt (
  FactPsStudentEnrollmentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PsCampusOrganizationId BIGINT COMMENT 'src rows 2045; campus',
  ParentPsInstitutionOrganizationId BIGINT COMMENT 'src rows 2144; Parent_College_Code',
  LastHighSchoolOrganizationId BIGINT COMMENT 'src rows 2335; HI_SCHL',
  PreviousPsInstitutionOrganizationId BIGINT COMMENT 'src rows 2380; PREV_COL_1'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactQuarterlyEmployments_WaExt (
  FactQuarterlyEmploymentId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  HoursWorkedInQuarter DECIMAL(12,3) COMMENT 'src rows 797; TotalHours',
  WageTypeCode STRING COMMENT 'src rows 799; WageTypeCode',
  WageHoursCalculatedCode STRING COMMENT 'src rows 800; WageHoursCalculatedCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.FactSpecialEducation_WaExt (
  FactSpecialEducationId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 1447,1504; SchoolYear',
  WaLreTypeCode STRING COMMENT 'src rows 1455; LRETypeCode',
  WaProgramExitReasonId STRING COMMENT 'src rows 1458; ProgramExitReasonID',
  InitialReferralDate DATE COMMENT 'src rows 1460,1509; InitialReferralDate',
  InitialEligibilityDate DATE COMMENT 'src rows 1461; InitialEligibilityDate',
  LastIepReviewDate DATE COMMENT 'src rows 1462; LastIEPReviewDate',
  LastEvaluationDate DATE COMMENT 'src rows 1463; LastEvaluationDate',
  InitialWaServiceDate DATE COMMENT 'src rows 1464; InitialWAServiceDate',
  SourceSubmitDate DATE COMMENT 'src rows 1466,1523; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1467,1524; ExtractDate',
  AnnualIepMeetingDate DATE COMMENT 'src rows 1468; AnnualIEPMeetingDate',
  NonpublicAgencyOrganizationId BIGINT COMMENT 'src rows 1469,1470; NonPublicAgencyCode, NonPublicAgencyId',
  InterpreterRequestAnnualIepMeetTypeCode STRING COMMENT 'src rows 1500; InterpreterRequestAnnualIEPMeetTypeCode',
  SchDaysToCompleteEval DECIMAL(12,3) COMMENT 'src rows 1513; SchDaysToCompleteEval',
  LateInitEvalReasonCode STRING COMMENT 'src rows 1515; LateInitEvalReasonCode',
  EligibilityOutcomeCode STRING COMMENT 'src rows 1518; EligibilityOutcomeCode',
  IepAfter3ReasonCode STRING COMMENT 'src rows 1521; IEPAfter3ReasonCode',
  InterpreterRequestInitialIepMeetTypeCode STRING COMMENT 'src rows 1526; InterpreterRequestInitialIEPMeetTypeCode'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.K12BilingualParticipationWaExt (
  K12BilingualParticipationId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 1305; SchoolYear',
  BilingualExitReasonId STRING COMMENT 'src rows 1315; BilingualExitReasonID',
  WaInstructionalModelId STRING COMMENT 'src rows 1317; InstructionalModelId',
  PlacementTestScaleScore DECIMAL(12,3) COMMENT 'src rows 1319; PlacementTestScaleScore',
  BilingualPlacementTestLevelCode STRING COMMENT 'src rows 1322; BilingualPlacementTestLevelCode',
  PlacementTestDate DATE COMMENT 'src rows 1323; PlacementTestDate',
  InitialWaPlacementDate DATE COMMENT 'src rows 1324; InitialWAPlacementDate',
  ProgramDesignation STRING COMMENT 'src rows 1328; ProgramDesignation',
  PlacementTestCodeId STRING COMMENT 'src rows 1330; PlacementTestCodeId',
  GradeLevelAtPlacementId STRING COMMENT 'src rows 1332; GradeLevelAtPlacementId',
  SourceSubmitDate DATE COMMENT 'src rows 1334; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1335; ExtractDate',
  WidaOverallPlacementScoreId STRING COMMENT 'src rows 1336; WIDAOverallPlacementScoreId'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.K12LapParticipationWaExt (
  K12LapParticipationId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 1278; SchoolYear',
  IdentificationAssessmentCode STRING COMMENT 'src rows 1288; IdentificationAssessmentCode',
  AcademicGrowthAmountCode DECIMAL(14,2) COMMENT 'src rows 1290; AcademicGrowthAmountCode',
  ProgressMonitoringAssessmentCode STRING COMMENT 'src rows 1292; ProgressMonitoringAssessmentCode',
  BeginningScaleScore DECIMAL(12,3) COMMENT 'src rows 1294; BeginningScaleScore',
  BeginningScaleScoreDate DATE COMMENT 'src rows 1295; BeginningScaleScoreDate',
  EndScaleScore DECIMAL(12,3) COMMENT 'src rows 1296; EndScaleScore',
  EndScaleScoreDate DATE COMMENT 'src rows 1297; EndScaleScoreDate',
  ExtendedLearningTimeTypeCode STRING COMMENT 'src rows 1298; ExtendedLearningTimeTypeCode',
  TutoringTypeCode STRING COMMENT 'src rows 1300; TutoringTypeCode',
  MetLearningGoal STRING COMMENT 'src rows 1302; MetLearningGoal',
  SourceSubmitDate DATE COMMENT 'src rows 1303; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1304; ExtractDate'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.K12MealEligibilityWaExt (
  K12MealEligibilityId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 1199; SchoolYear',
  FreeReducedMealsFlag BOOLEAN COMMENT 'src rows 1205; FreeReducedMealsFlag',
  FreeMealsFlag BOOLEAN COMMENT 'src rows 1206; FreeMealsFlag',
  ReducedMealsFlag BOOLEAN COMMENT 'src rows 1207; ReducedMealsFlag',
  IncomeSurveyFlag BOOLEAN COMMENT 'src rows 1208; IncomeSurveyFlag',
  SourceSubmitDate DATE COMMENT 'src rows 1209; SubmitDate',
  SourceExtractDate DATE COMMENT 'src rows 1210; ExtractDate'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.K12ReengagementParticipationWaExt (
  K12ReengagementParticipationId BIGINT COMMENT 'SYSTEM: 1:1 key to the extended CEDS fact row',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceSchoolYear STRING COMMENT 'src rows 1757; School Year',
  Age DECIMAL(12,3) COMMENT 'src rows 1771; Age',
  GradRequirementYear STRING COMMENT 'src rows 1772; Grad Requirement Year',
  EligibleThroughCreditDeficiency DECIMAL(12,3) COMMENT 'src rows 1773; Eligible through Credit Deficiency',
  MonthsOutOfSchoolPriorToEnrollment DECIMAL(12,3) COMMENT 'src rows 1774; Months out of School Prior to Enrollment',
  CreditsEarnedPriorToEnrollment DECIMAL(12,3) COMMENT 'src rows 1775; Credits Earned Prior To Enrollment',
  PreviouslyEnrolledInReengagementProgram STRING COMMENT 'src rows 1776; Previously Enrolled In Reengagement Program',
  NumberOfDaysEnrolled DECIMAL(12,3) COMMENT 'src rows 1777; Number of Days Enrolled',
  EnglishEquivalencyMeasurePass STRING COMMENT 'src rows 1778; English Equivalency Measure Pass',
  EnglishEquivalencyMeasureDate DATE COMMENT 'src rows 1779; English Equivalency Measure Date',
  MathEquivalencyMeasurePass STRING COMMENT 'src rows 1780; Math Equivalency Measure Pass',
  MathEquivalencyMeasureDate DATE COMMENT 'src rows 1781; Math Equivalency Measure Date',
  ScienceEquivalencyMeasurePass STRING COMMENT 'src rows 1782; Science Equivalency Measure Pass',
  ScienceEquivalencyMeasureDate DATE COMMENT 'src rows 1783; Science Equivalency Measure Date',
  SocialStudiesEquivalencyMeasurePass STRING COMMENT 'src rows 1784; SocialStudies Equivalency Measure Pass',
  SocialStudiesEquivalencyMeasureDate DATE COMMENT 'src rows 1785; Social Studies Equivalency Measure Date',
  AllFourEquivalencyMeasuresPass STRING COMMENT 'src rows 1786; All Four Equivalency Measures Pass',
  HighSchoolCreditsEarned DECIMAL(12,3) COMMENT 'src rows 1787; High School Credits Earned',
  CollegeCreditsEarned DECIMAL(12,3) COMMENT 'src rows 1788; College Credits Earned',
  GradeLevelCurriculums STRING COMMENT 'src rows 1789; Grade Level Curriculums',
  CoreAcademicSubjectAreaGains STRING COMMENT 'src rows 1790; Core Academic Subject Area Gains',
  CollegeReadinessCourses STRING COMMENT 'src rows 1791; College Readiness Courses',
  JobSearchRetentionCourses STRING COMMENT 'src rows 1792; Job Search/Retention Courses',
  WorkBasedLearningExperiences DECIMAL(12,3) COMMENT 'src rows 1793; Work-Based Learning Experiences',
  EnrolledInCollegeForFirstTime STRING COMMENT 'src rows 1794; Enrolled In College for First Time',
  EslCourses STRING COMMENT 'src rows 1795; ESL Courses',
  AdultBasicEducationAbeGedCourses STRING COMMENT 'src rows 1796; Adult Basic Education (ABE)/GED Courses',
  ShortTermIndustryRecognizedCertificates STRING COMMENT 'src rows 1797; Short Term Industry Recognized Certificates',
  SbeHighSchoolGraduationRequirement STRING COMMENT 'src rows 1798; SBE High School Graduation Requirement',
  HighSchoolEquivalencyCertificateIndicator STRING COMMENT 'src rows 1799; High School Equivalency Certificate',
  HighSchoolDiplomaIndicator STRING COMMENT 'src rows 1800; High School Diploma',
  CertificatesEarned STRING COMMENT 'src rows 1801; Certificates Earned',
  CollegeDegree STRING COMMENT 'src rows 1802; College Degree',
  IndustryRecognizedCertificate STRING COMMENT 'src rows 1803; Industry Recognized Certificate',
  ExitDescription STRING COMMENT 'src rows 1805; Exit Description',
  Migrant DECIMAL(14,2) COMMENT 'src rows 1808; Migrant',
  SpecialEducation STRING COMMENT 'src rows 1809; Special Education',
  Frl STRING COMMENT 'src rows 1810; FRL',
  Homeless STRING COMMENT 'src rows 1811; Homeless',
  N504 STRING COMMENT 'src rows 1812; 504',
  Lap STRING COMMENT 'src rows 1813; LAP',
  LimitedEnglishProficiency STRING COMMENT 'src rows 1814; Limited English Proficiency'
)
USING DELTA
COMMENT 'Sector/source-specific non-generalizable columns | Grain: 1:1 with parent row'
TBLPROPERTIES ('p20w.table_type' = 'EXTENSION', 'p20w.scd' = 'Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsAbsence (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AbsenceSourceId STRING COMMENT 'src rows 950; AbsenceCodeId',
  AbsenceCode STRING COMMENT 'src rows 951; AbsenceCode',
  AbsenceDescription STRING COMMENT 'src rows 952; AbsenceDescription'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsAcademicGrowthAmount (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AcademicGrowthAmountCode STRING COMMENT 'src rows 1290; AcademicGrowthAmountCode',
  AcademicGrowthAmountDescription STRING COMMENT 'src rows 1291; AcademicGrowthAmount'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsAcademicServices (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AcademicServicesSourceId STRING COMMENT 'src rows 1028,1170; AcademicServicesId, AcademicServicesTypeId',
  AcademicServicesCode STRING COMMENT 'src rows 1030,1171; AcademicServicesCode, AcademicServicesTypeCode',
  AcademicServicesDescription STRING COMMENT 'src rows 1032,1172; AcademicServicesDescription, AcademicServicesTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsAlternativeLearningEducation (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AlternativeLearningEducationCode STRING COMMENT 'src rows 1226,1385,1606; AlternativeLearningEducationCode',
  AlternativeLearningEducationDescription STRING COMMENT 'src rows 1227,1386,1607; AlternativeLearningEducation'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsApibCourse (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ApibCourseCode STRING COMMENT 'src rows 968,1235,1550,1612; APIBCourseCode',
  ApibCourseDescription STRING COMMENT 'src rows 969,1236,1551,1613; APIBCourseName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsAppeal (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AppealSourceId STRING COMMENT 'src rows 1042,1185; AppealTypeId',
  AppealCode STRING COMMENT 'src rows 1043,1186; AppealCode, AppealTypeCode',
  AppealDescription STRING COMMENT 'src rows 1044,1187; AppealDescription, AppealTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsApprovedOnlinePgmResidentDistOrg (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ApprovedOnlinePgmResidentDistOrgDescription STRING COMMENT 'src rows 1392,1647; ApprovedOnlinePGMResidentDistric, ApprovedOnlinePGMResidentDistrict'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsApprvdPrivateSchoolAttendPartTime (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ApprvdPrivateSchoolAttendPartTimeCode STRING COMMENT 'src rows 1089; ApprvdPrivateSchoolAttendPartTimeCode',
  ApprvdPrivateSchoolAttendPartTimeDescription STRING COMMENT 'src rows 1091; ApprvdPrivateSchoolAttendPartTimeDescription'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsAsvabTestStatus (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AsvabTestStatusCode STRING COMMENT 'src rows 1114; ASVABTestStatusCode',
  AsvabTestStatusDescription STRING COMMENT 'src rows 1115; ASVABTestStatusDesc',
  AsvabTestStatusSourceId STRING COMMENT 'src rows 1120; ASVABTestStatusId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsBehaviorServices (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  BehaviorServicesSourceId STRING COMMENT 'src rows 1029,1173; BehaviorServicesId, BehaviorServicesTypeId',
  BehaviorServicesCode STRING COMMENT 'src rows 1031,1174; BehaviorServicesCode, BehaviorServicesTypeCode',
  BehaviorServicesDescription STRING COMMENT 'src rows 1033,1175; BehaviorServicesDescription, BehaviorServicesTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsBilingualExitReason (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  BilingualExitReasonCode STRING COMMENT 'src rows 1315; BilingualExitReasonID',
  BilingualExitReasonDescription STRING COMMENT 'src rows 1316; BilingualExitReason'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsBilingualPlacementTestLevel (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  BilingualPlacementTestLevelSourceId STRING COMMENT 'src rows 1320; PlacementTestLevelId',
  BilingualPlacementTestLevelDescription STRING COMMENT 'src rows 1321; BilingualPlacementTestLevel',
  BilingualPlacementTestLevelCode STRING COMMENT 'src rows 1322; BilingualPlacementTestLevelCode'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsConfirmedTransferInType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ConfirmedTransferInTypeCode STRING COMMENT 'src rows 1110; ConfirmedTransferInTypeID',
  ConfirmedTransferInTypeDescription STRING COMMENT 'src rows 1113; ConfirmedTransferInType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsContentArea (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ContentAreaCode STRING COMMENT 'src rows 963,1233,1383,1548,1610; ContentAreaCode',
  ContentAreaDescription STRING COMMENT 'src rows 964,1234,1384,1549,1611; ContentAreaName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsCountry (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CountryCode STRING COMMENT 'src rows 1071; BirthCountryCode',
  CountryDescription STRING COMMENT 'src rows 1072; BirthCountry',
  CountrySourceId STRING COMMENT 'src rows 1100; BirthCountryId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsCourseLevel (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CourseLevelCode STRING COMMENT 'src rows 991,1402; CourseLevelCode',
  CourseLevelDescription STRING COMMENT 'src rows 992,1403; CourseLevelDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsCreditWaiver (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CreditWaiverCode STRING COMMENT 'src rows 1118; CreditWaiverCode',
  CreditWaiverDescription STRING COMMENT 'src rows 1119; CreditWaiverDesc',
  CreditWaiverSourceId STRING COMMENT 'src rows 1121; CreditWaiverId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsCteCourseEquivalencyIdentity (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CteCourseEquivalencyIdentitySourceId STRING COMMENT 'src rows 977; CourseEquivalencyIdent',
  CteCourseEquivalencyIdentityCode STRING COMMENT 'src rows 980; CTECourseEquivalencyIdentityCode',
  CteCourseEquivalencyIdentityDescription STRING COMMENT 'src rows 981; CTECourseEquivalencyIdentity'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsCteEquivalency (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CteEquivalencySourceId STRING COMMENT 'src rows 982; CTEEquivalencyIdent',
  CteEquivalencyCode STRING COMMENT 'src rows 983; CTEEquivalencyCode',
  CteEquivalencyDescription STRING COMMENT 'src rows 984; CTEEquivalency'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsCtecip (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CtecipCode STRING COMMENT 'src rows 970,1237,1552,1614; CTECIPCode',
  CtecipDescription STRING COMMENT 'src rows 971,1238,1553,1615; CTECIPName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsDisciplinaryAction (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  DisciplinaryActionSourceId STRING COMMENT 'src rows 1014,1162; ExclusionaryActionTypeId, InterventionId',
  DisciplinaryActionCode STRING COMMENT 'src rows 1015,1163; ExclusionaryActionTypeCode, InterventionCode',
  DisciplinaryActionDescription STRING COMMENT 'src rows 1016; InterventionDescription',
  ShortDisciplinaryActionDescription STRING COMMENT 'src rows 1164; ExclusionaryActionTypeName',
  LongDisciplinaryActionDescription STRING COMMENT 'src rows 1165; ExclusionaryActionTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsDualLanguageInstructionLanguage (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  DualLanguageInstructionLanguageSourceId STRING COMMENT 'src rows 988,1588,1657; DualLanguageInstructionLanguageI, DualLanguageInstructionLanguageId',
  DualLanguageInstructionLanguageCode STRING COMMENT 'src rows 989,1589,1658; DualLanguageInstructionLanguageC, DualLanguageInstructionLanguageCode',
  DualLanguageInstructionLanguageDescription STRING COMMENT 'src rows 990,1590,1659; DualLanguageInstructionLanguageN, DualLanguageInstructionLanguageName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsDualLanguageInstructionType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  DualLanguageInstructionTypeSourceId STRING COMMENT 'src rows 985,1585,1654; DualLanguageInstructionTypeId',
  DualLanguageInstructionTypeCode STRING COMMENT 'src rows 986,1586,1655; DualLanguageInstructionTypeCode',
  DualLanguageInstructionTypeDescription STRING COMMENT 'src rows 987,1587,1656; DualLanguageInstructionTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsEligibilityOutcome (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  EligibilityOutcomeSourceId STRING COMMENT 'src rows 1517; EligibilityOutcomeId',
  EligibilityOutcomeCode STRING COMMENT 'src rows 1518; EligibilityOutcomeCode',
  EligibilityOutcomeDescription STRING COMMENT 'src rows 1519; EligibilityOutcome'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsExit (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ExitDescription STRING COMMENT 'src rows 1423; ProgramExitReason',
  ExitCode STRING COMMENT 'src rows 1424; ExitCode'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsExitOrWithdrawalType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ExitOrWithdrawalTypeCode STRING COMMENT 'src rows 1067; WithdrawalCode',
  ExitOrWithdrawalTypeDescription STRING COMMENT 'src rows 1068; WithdrawalType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsExtendedLearningTimeType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ExtendedLearningTimeTypeCode STRING COMMENT 'src rows 1298; ExtendedLearningTimeTypeCode',
  ExtendedLearningTimeTypeDescription STRING COMMENT 'src rows 1299; ExtendedLearningTime'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsGradeLevelAtPlacement (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  GradeLevelAtPlacementCode STRING COMMENT 'src rows 1332; GradeLevelAtPlacementId',
  GradeLevelAtPlacementDescription STRING COMMENT 'src rows 1333; GradeLevelAtPlacement'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsHomeBasedAttendPartTime (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  HomeBasedAttendPartTimeCode STRING COMMENT 'src rows 1092; HomeBasedAttendPartTimeCode',
  HomeBasedAttendPartTimeDescription STRING COMMENT 'src rows 1094; HomeBasedAttendPartTimeDescription'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsHomelessness (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  HomelessnessCode STRING COMMENT 'src rows 1096; HomelessCode',
  HomelessnessDescription STRING COMMENT 'src rows 1098; HomelessDescription'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsIdentificationAssessment (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  IdentificationAssessmentCode STRING COMMENT 'src rows 1288; IdentificationAssessmentCode',
  IdentificationAssessmentDescription STRING COMMENT 'src rows 1289; IdentificationAssessment'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsIepAfter3Reason (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  IepAfter3ReasonSourceId STRING COMMENT 'src rows 1520; IEPAfter3ReasonId',
  IepAfter3ReasonCode STRING COMMENT 'src rows 1521; IEPAfter3ReasonCode',
  IepAfter3ReasonDescription STRING COMMENT 'src rows 1522; IEPAfter3Reason'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsIncidentBehavior (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  IncidentBehaviorSourceId STRING COMMENT 'src rows 1011,1153; BehaviorId',
  IncidentBehaviorCode STRING COMMENT 'src rows 1012,1154; BehaviorCode, BehaviorTypeCode',
  IncidentBehaviorDescription STRING COMMENT 'src rows 1013; BehaviorType',
  ShortIncidentBehaviorDescription STRING COMMENT 'src rows 1155; BehaviorTypeName',
  LongIncidentBehaviorDescription STRING COMMENT 'src rows 1156; BehaviorTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsInstructionalModel (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  InstructionalModelCode STRING COMMENT 'src rows 1317; InstructionalModelId',
  InstructionalModelDescription STRING COMMENT 'src rows 1318; InstructionalModel'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsInterpreterRequestAnnualIepMeetType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  InterpreterRequestAnnualIepMeetTypeSourceId STRING COMMENT 'src rows 1499; InterpreterRequestAnnualIEPMeetTypeId',
  InterpreterRequestAnnualIepMeetTypeCode STRING COMMENT 'src rows 1500; InterpreterRequestAnnualIEPMeetTypeCode',
  InterpreterRequestAnnualIepMeetTypeDescription STRING COMMENT 'src rows 1501; InterpreterRequestAnnualIEPMeetType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsInterpreterRequestInitialIepMeetType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  InterpreterRequestInitialIepMeetTypeSourceId STRING COMMENT 'src rows 1525; InterpreterRequestTypeId',
  InterpreterRequestInitialIepMeetTypeCode STRING COMMENT 'src rows 1526; InterpreterRequestInitialIEPMeetTypeCode',
  InterpreterRequestInitialIepMeetTypeDescription STRING COMMENT 'src rows 1527; InterpreterRequestInitialIEPMeetType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsInterpreterRequestReengagMeetingType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  InterpreterRequestReengagMeetingTypeSourceId STRING COMMENT 'src rows 1196; InterpreterRequestReengagMeetingTypeId',
  InterpreterRequestReengagMeetingTypeCode STRING COMMENT 'src rows 1197; InterpreterRequestReengagMeetingTypeCode',
  InterpreterRequestReengagMeetingTypeDescription STRING COMMENT 'src rows 1198; InterpreterRequestReengagMeetingType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsLanguage (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  LanguageCode STRING COMMENT 'src rows 1076,1078,1123; FamilyLanguageCode, LanguageSpokenatHomeCode, PrimaryLanguageCode',
  LanguageDescription STRING COMMENT 'src rows 1077,1079,1124; FamilyLanguage, LanguageSpokenatHome, PrimaryLanguage',
  LanguageSourceId STRING COMMENT 'src rows 1122; FamilyLanguageId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsLateInitEvalReason (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  LateInitEvalReasonSourceId STRING COMMENT 'src rows 1514; LateInitEvalReasonId',
  LateInitEvalReasonCode STRING COMMENT 'src rows 1515; LateInitEvalReasonCode',
  LateInitEvalReasonDescription STRING COMMENT 'src rows 1516; LateInitEvalReason'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsLetterGrade (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  LetterGradeCode STRING COMMENT 'src rows 1394,1650; LetterGrade',
  LetterGradeDescription STRING COMMENT 'src rows 1395,1651; LetterGradeDesc',
  LetterGradeSourceId STRING COMMENT 'src rows 1649; LetterGradeId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsLreType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  LreTypeCode STRING COMMENT 'src rows 1455; LRETypeCode',
  LreTypeDescription STRING COMMENT 'src rows 1456; LREType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsMilitaryParentorGuardian (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  MilitaryParentorGuardianSourceId STRING COMMENT 'src rows 1108; MilitaryParentorGuardian',
  MilitaryParentorGuardianCode STRING COMMENT 'src rows 1111; MilitaryParentorGuardianCD',
  MilitaryParentorGuardianDescription STRING COMMENT 'src rows 1112; MilitaryParentorGuardianDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPetitionTimeFrame (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PetitionTimeFrameCode STRING COMMENT 'src rows 1036,1179; PetitionTimeFrameCode, PetitiontoExceedMorethanOneYear',
  PetitionTimeFrameDescription STRING COMMENT 'src rows 1037,1180; PetitionTimeFrame, PetitionTimeFrameTypeDesc',
  PetitionTimeFrameSourceId STRING COMMENT 'src rows 1178; PetitionTimeFrameId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPlacementTestCode (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PlacementTestCodeCode STRING COMMENT 'src rows 1330; PlacementTestCodeId',
  PlacementTestCodeDescription STRING COMMENT 'src rows 1331; BilingualPlacementTest'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPreKAcqKnowEntry (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PreKAcqKnowEntrySourceId STRING COMMENT 'src rows 1481; PreKAcqKnowEntryId',
  PreKAcqKnowEntryCode STRING COMMENT 'src rows 1482; PreKAcqKnowEntryCode',
  PreKAcqKnowEntryDescription STRING COMMENT 'src rows 1483; PreKAcqKnowEntry'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPreKAcqKnowExit (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PreKAcqKnowExitSourceId STRING COMMENT 'src rows 1487; PreKAcqKnowExitId',
  PreKAcqKnowExitCode STRING COMMENT 'src rows 1488; PreKAcqKnowExitCode',
  PreKAcqKnowExitDescription STRING COMMENT 'src rows 1489; PreKAcqKnowExit'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPreKAcqKnowProgres (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PreKAcqKnowProgresSourceId STRING COMMENT 'src rows 1484; PreKAcqKnowProgresId',
  PreKAcqKnowProgresCode STRING COMMENT 'src rows 1485; PreKAcqKnowProgresCode',
  PreKAcqKnowProgresDescription STRING COMMENT 'src rows 1486; PreKAcqKnowProgres'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPreKBehaveEntry (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PreKBehaveEntrySourceId STRING COMMENT 'src rows 1490; PreKBehaveEntryId',
  PreKBehaveEntryCode STRING COMMENT 'src rows 1491; PreKBehaveEntryCode',
  PreKBehaveEntryDescription STRING COMMENT 'src rows 1492; PreKBehaveEntry'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPreKBehaveExit (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PreKBehaveExitSourceId STRING COMMENT 'src rows 1496; PreKBehaveExitId',
  PreKBehaveExitCode STRING COMMENT 'src rows 1497; PreKBehaveExitCode',
  PreKBehaveExitDescription STRING COMMENT 'src rows 1498; PreKBehaveExit'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPreKBehaveProgres (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PreKBehaveProgresSourceId STRING COMMENT 'src rows 1493; PreKBehaveProgresId',
  PreKBehaveProgresCode STRING COMMENT 'src rows 1494; PreKBehaveProgresCode',
  PreKBehaveProgresDescription STRING COMMENT 'src rows 1495; PreKBehaveProgres'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPreKSocialEntry (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PreKSocialEntrySourceId STRING COMMENT 'src rows 1472; PreKSocialEntryId',
  PreKSocialEntryCode STRING COMMENT 'src rows 1473; PreKSocialEntryCode',
  PreKSocialEntryDescription STRING COMMENT 'src rows 1474; PreKSocialEntry'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPreKSocialExit (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PreKSocialExitSourceId STRING COMMENT 'src rows 1478; PreKSocialExitId',
  PreKSocialExitCode STRING COMMENT 'src rows 1479; PreKSocialExitCode',
  PreKSocialExitDescription STRING COMMENT 'src rows 1480; PreKSocialExit'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPreKSocialProgres (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PreKSocialProgresSourceId STRING COMMENT 'src rows 1475; PreKSocialProgresId',
  PreKSocialProgresCode STRING COMMENT 'src rows 1476; PreKSocialProgresCode',
  PreKSocialProgresDescription STRING COMMENT 'src rows 1477; PreKSocialProgres'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsPrimaryDisability (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PrimaryDisabilityCode STRING COMMENT 'src rows 1086; DisabilityCode',
  PrimaryDisabilityDescription STRING COMMENT 'src rows 1088; DisabilityDescription'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsProgram (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ProgramCode STRING COMMENT 'src rows 1285,1419; ProgramCode, ProgramID',
  ProgramDescription STRING COMMENT 'src rows 1286; ProgramName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsProgramDesignation (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ProgramDesignationCode STRING COMMENT 'src rows 1328; ProgramDesignation',
  ProgramDesignationDescription STRING COMMENT 'src rows 1329; BilingualProgramDesignation'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsProgramExitReason (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ProgramExitReasonCode STRING COMMENT 'src rows 1458; ProgramExitReasonID',
  ProgramExitReasonDescription STRING COMMENT 'src rows 1459; ExitReason'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsProgressMonitoringAssessment (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ProgressMonitoringAssessmentCode STRING COMMENT 'src rows 1292; ProgressMonitoringAssessmentCode',
  ProgressMonitoringAssessmentDescription STRING COMMENT 'src rows 1293; ProgressMonitoringAssessment'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsQualification (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  QualificationCode STRING COMMENT 'src rows 1425; QualificationCode',
  QualificationDescription STRING COMMENT 'src rows 1426; QualificationReason'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsReengagementPlan (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ReengagementPlanSourceId STRING COMMENT 'src rows 1039,1181; ReengagementPlanId, ReengagementPlanTypeId',
  ReengagementPlanCode STRING COMMENT 'src rows 1040,1182; ReengagementPlanCode, ReengagementPlanTypeCode',
  ReengagementPlanDescription STRING COMMENT 'src rows 1041,1183; ReengagementPlanDescription, ReengagementPlanTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsSchoolchoicetype (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolchoicetypeCode STRING COMMENT 'src rows 1069; SchoolchoicetypeID',
  SchoolchoicetypeDescription STRING COMMENT 'src rows 1070; Schoolchoicetype'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsSequence (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SequenceCode STRING COMMENT 'src rows 994,1404,1663; SequenceCode',
  SequenceDescription STRING COMMENT 'src rows 995,1405,1664; SequenceName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsShareConsentTransitionAg (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ShareConsentTransitionAgCode STRING COMMENT 'src rows 1502; ShareConsentTransitionAgId',
  ShareConsentTransitionAgDescription STRING COMMENT 'src rows 1503; ShareConsentTransitionAg'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsSharing (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SharingSourceId STRING COMMENT 'src rows 1502; ShareConsentTransitionAgId'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsStaffInvolvementOutcome (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  StaffInvolvementOutcomeCode STRING COMMENT 'src rows 1194; StaffInvolvementOutcomeCode',
  StaffInvolvementOutcomeDescription STRING COMMENT 'src rows 1195; StaffInvolvementOutcome'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsStaffInvolvementStatus (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  StaffInvolvementStatusCode STRING COMMENT 'src rows 1190; StaffInvolvementStatusCode',
  StaffInvolvementStatusDescription STRING COMMENT 'src rows 1191; StaffInvolvementStatus'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsStaffInvolvementType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  StaffInvolvementTypeCode STRING COMMENT 'src rows 1192; StaffInvolvementTypeCode',
  StaffInvolvementTypeDescription STRING COMMENT 'src rows 1193; StaffInvolvementType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsStaffType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  StaffTypeSourceId STRING COMMENT 'src rows 1577; StaffTypeID',
  StaffTypeCode STRING COMMENT 'src rows 1578; StaffTypeCode',
  StaffTypeDescription STRING COMMENT 'src rows 1579; StaffType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsStateCourse (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  StateCourseCode STRING COMMENT 'src rows 966,1231,1381,1546,1608; StateCourseCode',
  StateCourseDescription STRING COMMENT 'src rows 967,1232,1382,1547,1609; StateCourseName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsTeacherIndicator (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  TeacherIndicatorCode STRING COMMENT 'src rows 1575; TeacherIndicatorID',
  TeacherIndicatorDescription STRING COMMENT 'src rows 1576; TeacherIndicator'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsTutoringType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  TutoringTypeCode STRING COMMENT 'src rows 1300; TutoringTypeCode',
  TutoringTypeDescription STRING COMMENT 'src rows 1301; TutoringType'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsWeaponType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  WeaponTypeSourceId STRING COMMENT 'src rows 1019,1158; WeaponId',
  WeaponTypeCode STRING COMMENT 'src rows 1020,1159; WeaponCode, WeaponTypeCode',
  WeaponTypeDescription STRING COMMENT 'src rows 1021; WeaponType',
  ShortWeaponTypeDescription STRING COMMENT 'src rows 1160; WeaponType',
  LongWeaponTypeDescription STRING COMMENT 'src rows 1161; WeaponTypeDesc'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsWidaOverallPlacementScore (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  WidaOverallPlacementScoreCode STRING COMMENT 'src rows 1336; WIDAOverallPlacementScoreId',
  WidaOverallPlacementScoreDescription STRING COMMENT 'src rows 1337; WIDAOverallPlacementScore'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_ext.RefWaCedarsWorkBasedLearningActivityType (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  WorkBasedLearningActivityTypeCode STRING COMMENT 'src rows 1275,1666; WorkBasedLearningActivityTypeCode',
  WorkBasedLearningActivityTypeDescription STRING COMMENT 'src rows 1276,1667; WorkBasedLearningActivityTypeName'
)
USING DELTA
COMMENT 'Purpose-built code reference table | Grain: One row per code value'
TBLPROPERTIES ('p20w.table_type' = 'REFERENCE', 'p20w.scd' = 'Type 1 (description corrections overwrite; retired codes kept with end period)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.BridgeCredentialAwardRelatedCredentialAwards (
  BridgeCredentialAwardRelatedCredentialAwardId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  RelatedFactCredentialAwardId STRING COMMENT 'src rows 555; EndorsementCode'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.BridgeK12StudentDisciplineIncidentBehaviors (
  BridgeK12StudentDisciplineIncidentBehaviorId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  IncidentBehaviorId STRING COMMENT 'src rows 1027,1157; OtherBehaviorCodes, OtherBehaviorIds'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.BridgeK12StudentEnrollmentRaces (
  BridgeK12StudentEnrollmentRaceId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  RaceId BIGINT COMMENT 'src rows 1074,1075,1128,1129,1130,1131,1132,1133,1134,1138,1139,1140...; EthCode, EthDesc, EthEndDate, EthStartDate, EthnicityCollectionMethod, EthnicityCollectionMethodCode, EthnicityCollectionMethodID, EthnicityTypeId, FedEthTypeRollup, FederalEthRace'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.BridgePsStudentAcademicAwardCipCodes (
  BridgePsStudentAcademicAwardCipCodeId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CipCodeId STRING COMMENT 'src rows 1999,2006,2007,2258; PROGRAM_CIP, first_minor_CIP, second_major_CIP, second_minor_CIP'
)
USING DELTA
COMMENT ' | Grain: Many-to-many / child rows'
TBLPROPERTIES ('p20w.table_type' = 'BRIDGE', 'p20w.scd' = 'Type 1 (rebuilt with parent)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimAssessmentAdministrations (
  DimAssessmentAdministrationsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AssessmentAdministrationFinishDate DATE COMMENT 'src rows 333,338,339,342,345,349,351,352,1931,1932,1933,1934...; Cognitive_Date_Finalized, Language_Date_Finalized, Literacy_Date_Finalized, Mathematics_Date_Finalized, Physical_Date_Finalized, Social_Emotional_Date_Finalized, SpanishLanguageDat',
  AssessmentAdministrationStartDate DATE COMMENT 'src rows 441,881,901; AssessmentDate, Assessment_Date, test_date',
  AssessmentAdministrationName STRING COMMENT 'src rows 871; Assessment_Name'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimAssessmentPerformanceLevels (
  DimAssessmentPerformanceLevelsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AssessmentPerformanceLevelLabel STRING COMMENT 'src rows 296,297,298,299,300,301,311,318,874,895,911,919...; CG_WHE, LA_WHE, LI_WHE, Level_Listening, Level_Reading, Level_Speaking, Level_Writing, MA_WHE, PH_WHE, PerformanceLevel, SE_WHE, SLA_WHE, SLI_WHE, SpanishLanguageDevelopmentLevel, '
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimAssessmentRegistrations (
  DimAssessmentRegistrationsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ReasonNotTestedCode STRING COMMENT 'src rows 875,896; Attempt'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimAssessmentSubtests (
  DimAssessmentSubtestsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AssessmentSubtestTitle STRING COMMENT 'src rows 440; rubric_name_edTPA',
  AssessmentLevelForWhichDesigned STRING COMMENT 'src rows 876; TestGrade',
  AssessmentSubtestAbbreviation STRING COMMENT 'src rows 905,913,921,929; SubjectName_Listening, SubjectName_Reading, SubjectName_Speaking, SubjectName_Writing'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimAssessments (
  DimAssessmentsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AssessmentIdentifierState STRING COMMENT 'src rows 437; assess_code',
  AssessmentTitle STRING COMMENT 'src rows 439; assess_name',
  AssessmentShortName STRING COMMENT 'src rows 873,892,894; AssessmentName, TestType',
  AssessmentAcademicSubjectCode STRING COMMENT 'src rows 880; SubjectName'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimAttendances (
  DimAttendancesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AbsentAttendanceCategoryCode STRING COMMENT 'src rows 951; AbsenceCode'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimCalendarSessions (
  DimCalendarSessionsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  FirstInstructionDate DATE COMMENT 'src rows 1348; InitialSchoolStartDate',
  LastInstructionDate DATE COMMENT 'src rows 1349; LastSchoolEndDate',
  SessionBeginDate STRING COMMENT 'src rows 1541; TermStartDate',
  SessionEndDate STRING COMMENT 'src rows 1542; TermEndDate'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimChildOutcomeSummaries (
  DimChildOutcomeSummariesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CosRatingACode STRING COMMENT 'src rows 1473,1479; PreKSocialEntryCode, PreKSocialExitCode',
  CosProgressAIndicatorCode STRING COMMENT 'src rows 1476; PreKSocialProgresCode',
  CosRatingBCode STRING COMMENT 'src rows 1482,1488; PreKAcqKnowEntryCode, PreKAcqKnowExitCode',
  CosProgressBIndicatorCode STRING COMMENT 'src rows 1485; PreKAcqKnowProgresCode',
  CosRatingCCode STRING COMMENT 'src rows 1491,1497; PreKBehaveEntryCode, PreKBehaveExitCode',
  CosProgressCIndicatorCode STRING COMMENT 'src rows 1494; PreKBehaveProgresCode'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimCipCodes (
  DimCipCodesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CareerClusterCode STRING COMMENT 'src rows 2155; CAREER_CLUSTER_CODE',
  CipCode STRING COMMENT 'src rows 2156; CIP',
  CipDescription STRING COMMENT 'src rows 2161; CIP_TITLE'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimCredentialAwards (
  DimCredentialAwardsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ProfessionalCertificateOrLicenseNumber STRING COMMENT 'src rows 533; CertificateNumber',
  CredentialAwardStartDate DATE COMMENT 'src rows 552; CertificateEffectiveDate',
  CredentialAwardEndDate DATE COMMENT 'src rows 553; CertificateExpireDate',
  CredentialCompletionDate DATE COMMENT 'src rows 816,2153; DateBatteryCompleted, Status Date'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimCredentialIssuers (
  DimCredentialIssuersSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CredentialIssuerOrganizationName STRING COMMENT 'src rows 547,810; CertificateRecommendingAgencyName, Program Name'
)
USING DELTA
COMMENT 'Credential issuers incl. apprenticeship sponsors | Grain: One row per credential issuer per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimDates (
  DimDatesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimDisciplineStatuses (
  DimDisciplineStatusesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  DisciplinaryActionTakenCode STRING COMMENT 'src rows 1015,1163; ExclusionaryActionTypeCode, InterventionCode',
  IdeaInterimRemovalCode BOOLEAN COMMENT 'src rows 1022,1169; IsInIAES, SPEDInterimAlternativeEdSetting'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimEconomicallyDisadvantagedStatuses (
  DimEconomicallyDisadvantagedStatusesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  EligibilityStatusForSchoolFoodServiceProgramsCode BOOLEAN COMMENT 'src rows 1205; FreeReducedMealsFlag'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimEmployers (
  DimEmployersSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  EmployerOrganizationIdentifierSea STRING COMMENT 'src rows 667,796; EmployerAccountNumber, UI Account number',
  EmployerOrganizationName STRING COMMENT 'src rows 674; Legal/Corporate Name',
  PhysicalAddressStreetNumberAndName STRING COMMENT 'src rows 682; Physical Location Street Address - Line 1',
  PhysicalAddressCity STRING COMMENT 'src rows 684; Physical Location Address - City',
  PhysicalAddressPostalCode STRING COMMENT 'src rows 686; Physical Location Address - ZIP',
  MailingAddressStreetNumberAndName STRING COMMENT 'src rows 688; Mailing/Other Address (MOA) - Line 1',
  OrganizationOperationalStatus STRING COMMENT 'src rows 711; Activity Status Code',
  Latitude DECIMAL(12,3) COMMENT 'src rows 760; Latitude',
  Longitude DECIMAL(12,3) COMMENT 'src rows 761; Longitude',
  WebSiteAddress STRING COMMENT 'src rows 790; Website Address'
)
USING DELTA
COMMENT 'CEDS employer | Grain: One row per employer per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimGradeLevels (
  DimGradeLevelsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimIdeaStatuses (
  DimIdeaStatusesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SpecialEducationExitReasonCode STRING COMMENT 'src rows 1458; ProgramExitReasonID'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimIeus (
  DimIeusSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  IeuOrganizationName STRING COMMENT 'src rows 1675,1755; ESD, ESD_NAME',
  IeuOrganizationIdentifierSea STRING COMMENT 'src rows 1754,2647; ApplicationESDNumber, ESD_ID'
)
USING DELTA
COMMENT 'CEDS intermediate educational unit | Grain: One row per ESD (IEU) per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimIncidentBehaviors (
  DimIncidentBehaviorsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  IncidentBehaviorCode STRING COMMENT 'src rows 1012,1154; BehaviorCode, BehaviorTypeCode'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimIncidents (
  DimIncidentsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  IncidentIdentifier STRING COMMENT 'src rows 1009,1151; IncidentId'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimK12CourseSections (
  DimK12CourseSectionsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CourseSectionIdentifier STRING COMMENT 'src rows 1543,1603; SectionID'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimK12CourseStatuses (
  DimK12CourseStatusesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CourseLevelCharacteristicCode STRING COMMENT 'src rows 991; CourseLevelCode'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimK12Courses (
  DimK12CoursesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CourseIdentifier STRING COMMENT 'src rows 961,1544,1604; CourseID',
  CourseTitle STRING COMMENT 'src rows 962,1545,1605; CourseTitle',
  AdvancedPlacementCourseCode STRING COMMENT 'src rows 968,1612; APIBCourseCode',
  CareerClusterCode STRING COMMENT 'src rows 972,1616; CTEClusterID'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimK12Demographics (
  DimK12DemographicsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SexCode STRING COMMENT 'src rows 540,581,631,1060,1806,1829; Gender, Gender Code, Sex, SexCode, WaK_Gender'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimK12EnrollmentStatuses (
  DimK12EnrollmentStatusesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ExitOrWithdrawalTypeCode STRING COMMENT 'src rows 1067; WithdrawalCode'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimK12ProgramTypes (
  DimK12ProgramTypesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ProgramTypeCode STRING COMMENT 'src rows 1285,1419; ProgramCode, ProgramID',
  ProgramTypeDescription STRING COMMENT 'src rows 1420; ProgramName'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimK12Schools (
  DimK12SchoolsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolIdentifierSea STRING COMMENT 'src rows 461,570,864,885,944,958,1004,1050,1146,1202,1214,1281...; ApplicationSchoolCode, BLDG, BuildingCode, LastReportedSchCode, LastReportedSchoolCode, SCHOOL_ID, SchCode, SchoolCode, WaK_schoolcode, bldg_code',
  NameOfInstitution STRING COMMENT 'src rows 865,886,945,959,1005,1051,1147,1203,1215,1282,1310,1346...; ApplicationSchoolName, LastReportedSchoolName, SCHOOL_NAME, SchName, School, SchoolName, Serving School Name, WaK_SchoolName',
  SchoolIdentifierNces STRING COMMENT 'src rows 1681; NCESSCH',
  SchoolTypeCode STRING COMMENT 'src rows 1688,1756; SCHOOL_TYPE_CD',
  Latitude DECIMAL(12,3) COMMENT 'src rows 1746; LATCOD',
  Longitude DECIMAL(12,3) COMMENT 'src rows 1747; LONCOD',
  LeaIdentifierSea STRING COMMENT 'src rows 1752; DISTRICT_ID',
  SchoolIdentifierAct STRING COMMENT 'src rows 1963; high_school'
)
USING DELTA
COMMENT 'CEDS school dimension (LEA/SEA/IEU denormalized) | Grain: One row per K-12 school per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimLeas (
  DimLeasSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  LeaIdentifierSea STRING COMMENT 'src rows 96,97,167,460,568,858,883,942,956,1002,1046,1048...; ApplicationDistrictCode, CCDDD, Codist, CountyDistrictCode, DISTRICT_ID, DistCode, DistrictCode, IEPSchoolDistrictCode, LastReportedDistrictCode, ResidentDistrictCode, SchoolDistri',
  LeaOrganizationName STRING COMMENT 'src rows 166,859,884,943,957,1003,1047,1049,1145,1201,1213,1280...; ApplicationDistrictName, DISTRICT_NAME, DistName, District, DistrictName, LastReportedDistrictName, Resident District Name, ResidentDistrictName, SchoolDistrictName, Serving Distri',
  PhysicalAddressCountyAnsiCodeCode STRING COMMENT 'src rows 1676; CC_CD',
  PhysicalAddressCountyName DECIMAL(12,3) COMMENT 'src rows 1677; County_Name',
  LeaIdentifierNces STRING COMMENT 'src rows 1678; NCESDIST',
  IeuOrganizationIdentifierSea STRING COMMENT 'src rows 1754; ESD_ID'
)
USING DELTA
COMMENT 'CEDS LEA dimension (IEU denormalized) | Grain: One row per LEA per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimMilitaryStatuses (
  DimMilitaryStatusesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  MilitaryVeteranStatusIndicatorCode STRING COMMENT 'src rows 853; Veteran'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimOrganizationAddresses (
  DimOrganizationAddressesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AddressCity STRING COMMENT 'src rows 158; City',
  AddressPostalCode STRING COMMENT 'src rows 159; ZipCode',
  Latitude DECIMAL(12,3) COMMENT 'src rows 161; Latitude',
  Longitude DECIMAL(12,3) COMMENT 'src rows 162; Longitude'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimOrganizationCalendarSessions (
  DimOrganizationCalendarSessionsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SessionBeginDate STRING COMMENT 'src rows 375,2085; begin_date, campus_enroll_term_start',
  SessionEndDate STRING COMMENT 'src rows 376,2088; campus_enroll_term_end, end_date'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimOrganizations (
  DimOrganizationsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  OrganizationName STRING COMMENT 'src rows 1388,1390,1471,1642,1645; ApprovedOnlineProgramName, ApprovedOnlineProviderName, NonPublicAgency'
)
USING DELTA
COMMENT 'CEDS generic organization (college districts, campuses, service providers) | Grain: One row per other organization per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimPeople (
  DimPeopleSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ELChildChildIdentifierState STRING COMMENT 'src rows 81,83,115; ChildId, Childid',
  K12StudentStudentIdentifierState STRING COMMENT 'src rows 85,358,361,863,887,947,1007,1054,1127,1149,1204,1217...; ApplicationSSID, ApplicationSSId, ELMS_SSID, K12_state_ID, LastReportedSSID, LastReportedSSId, SSID, WaK_SSID, WaK_StateStudentID',
  FirstName STRING COMMENT 'src rows 86,198,241,291,399,480,535,573,795,805,868,889...; Child_F_Name, EmployeeFirstName, First Name, FirstName, First_Name, LegalFirstName, NameFirst, StaffFirstName, StudentFirstName, WaK_ChildFName, first_name',
  LastOrSurname STRING COMMENT 'src rows 87,205,242,293,400,479,534,572,807,869,888,1056...; Child_L_Name, Last Name, LastName, Last_Name, LegalLastName, NameLast, StaffLastName, StudentLastName, WaK_ChildLName, last_name',
  MiddleName STRING COMMENT 'src rows 88,212,243,292,401,536,574,806,870,890,1058,1538...; Child_MI, LegalMiddleName, Middle Name, MiddleInitial, MiddleName, Middle_Name, NameMiddle, StaffMiddleName, StudentMiddleInitial, StudentMiddleName, WaK_ChildMI, middle_name',
  Birthdate STRING COMMENT 'src rows 89,178,244,278,329,402,626,843,867,891,1059,1539...; BIRTH_DATE, Birth Date, BirthDate, Birthdate, DOB, Date_of_Birth, SRBirthDate, StaffBirthDate, StudentBirthDate, WaK_Birthdate, birth_date',
  PersonIdentifierSSN STRING COMMENT 'src rows 403,808,2074,2146,2483,2587,2601,2626,2627; ApplicationSSN, SSN, UpdatedSSN, ssn',
  K12StaffStaffMemberIdentifierState STRING COMMENT 'src rows 463,531,575,577,624,625,1224,1535; Cert, CertificateNumber, CertificationNumber, EducatorID, lead_mentor_cert',
  WorkforceProgramParticipantPersonIdentifierState STRING COMMENT 'src rows 804; Apprentice Id',
  K12StudentStudentIdentifierDistrict STRING COMMENT 'src rows 948,1008,1055,1150,1218,1359,1507,1601,1766,1826; District Student Id, DistrictStudentCode, DistrictStudentID, WaK_DistrictStudentID',
  K12StaffStaffMemberIdentifierDistrict STRING COMMENT 'src rows 1223,1534; StaffID',
  PsStudentStudentIdentifierState STRING COMMENT 'src rows 1991,2008,2041,2075,2241,2242,2243,2244,2245; DW_KEY, student_OFM, student_institution',
  GenerationCodeOrSuffix STRING COMMENT 'src rows 2065,2111,2150; Name_Suffix, Suffix, name_suffix'
)
USING DELTA
COMMENT 'CEDS DW person dimension (carries PII natively; masked by tag) | Grain: One row per person per version (CEDS DimPeople with DimPeople_Current companion)'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2 (CEDS RecordStartDateTime/RecordEndDateTime)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimPersonAddresses (
  DimPersonAddressesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AddressPostalCode STRING COMMENT 'src rows 1073; ZipCode'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimPsAcademicAwardStatuses (
  DimPsAcademicAwardStatusesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PescAwardLevelTypeCode STRING COMMENT 'src rows 2143,2257; Degree_Level, EXIT_CD'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimPsAcademicAwardTitles (
  DimPsAcademicAwardTitlesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AcademicAwardTitle STRING COMMENT 'src rows 2263; DEGREE_TITLE'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimPsCourses (
  DimPsCoursesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CourseIdentifier STRING COMMENT 'src rows 2029; course',
  CourseNumber STRING COMMENT 'src rows 2209; COURSE_NUM',
  CourseTitle STRING COMMENT 'src rows 2214,2217; COURSE_TITLE',
  CourseSubjectAbbreviation STRING COMMENT 'src rows 2236; DEPT_DIV',
  CourseDepartmentName STRING COMMENT 'src rows 2235; DEPT_DIV'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimPsDemographics (
  DimPsDemographicsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SexCode STRING COMMENT 'src rows 405,482,2076,2152,2281,2410; Gender, SEX, gender, sex'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimPsInstitutions (
  DimPsInstitutionsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  Opeid STRING COMMENT 'src rows 2116,2144; College_Code_Branch, Parent_College_Code',
  NameOfInstitution STRING COMMENT 'src rows 2117,2145,2458; College_Name, Parent_College_Name, TITLE',
  IPEDSIdentifier STRING COMMENT 'src rows 2380; PREV_COL_1'
)
USING DELTA
COMMENT 'CEDS PS institution | Grain: One row per PS institution per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimRaces (
  DimRacesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimScedCodes (
  DimScedCodesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  ScedCourseCode STRING COMMENT 'src rows 1608; StateCourseCode'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimSchoolYears (
  DimSchoolYearsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimSeas (
  DimSeasSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimTitleIIIStatuses (
  DimTitleIIIStatusesSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  TitleIIILanguageInstructionProgramTypeCode STRING COMMENT 'src rows 1317; InstructionalModelId'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.DimWeapons (
  DimWeaponsSk BIGINT COMMENT 'SYSTEM: version surrogate key',
  EffectiveStartDate DATE COMMENT 'SYSTEM: Type 2 version start (source period or load date)',
  EffectiveEndDate DATE COMMENT 'SYSTEM: Type 2 version end (9999-12-31 when current)',
  IsCurrent BOOLEAN COMMENT 'SYSTEM: current version flag',
  RecordHash STRING COMMENT 'SYSTEM: hash of tracked attributes for change detection',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  WeaponTypeCode STRING COMMENT 'src rows 1020,1159; WeaponCode, WeaponTypeCode'
)
USING DELTA
COMMENT ' | Grain: One row per member per version'
TBLPROPERTIES ('p20w.table_type' = 'DIMENSION', 'p20w.scd' = 'Type 2', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactCredentialAwards (
  FactCredentialAwardId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  CredentialAwardStatusId STRING COMMENT 'src rows 418,423,424,425,426,427; Title_II_flag, cw_completion_date, cwtest_completion_date, endorse_complete_date, endorse_recommend, recommend',
  CredentialAwardRecipientPersonId BIGINT COMMENT 'src rows 530,531,533; CertificateNumber, EducatorID, PersonnelID',
  CredentialDefinitionId DATE COMMENT 'src rows 543,815,1270,1662,1799,2153; CertificateCode, Current Status, DateBatteryCompleted, High School Equivalency Certificate, IndustryCertificationEarned',
  CredentialIssuerId BIGINT COMMENT 'src rows 546; CertificateRecommendingAgencyCode'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12AcademicCalendars (
  FactK12AcademicCalendarId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 1340; SchoolYear',
  LeaId BIGINT COMMENT 'src rows 1341,1342; DistrictCode, DistrictOrganizationId',
  K12SchoolId BIGINT COMMENT 'src rows 1344,1345,1347; LocationID, SchoolCode, SchoolOrganizationId'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12ProgramParticipations (
  FactK12ProgramParticipationId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 1199,1278,1305,1412,1757; School Year, SchoolYear',
  LeaAttendanceId BIGINT COMMENT 'src rows 1200,1279,1306,1308,1413,1759; DistrictCode, DistrictOrganizationId, Serving District Id',
  K12SchoolId BIGINT COMMENT 'src rows 1202,1281,1283,1309,1311,1415,1417,1763; LocationID, LocationId, SchoolCode, SchoolOrganizationId, Serving School Id',
  K12StudentId BIGINT COMMENT 'src rows 1204,1284,1312,1418,1765,1766; District Student Id, SSID',
  K12ProgramTypeId STRING COMMENT 'src rows 1285,1419; ProgramCode, ProgramID',
  ProgramParticipationStartDateId DATE COMMENT 'src rows 1287,1313,1421; BilStartDate, StartDate',
  ProgramParticipationExitDateId DATE COMMENT 'src rows 1314,1422,1804; BilExitDate, ExitDate, Program Exit Date'
)
USING DELTA
CLUSTER BY (K12StudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12StaffAssignments (
  FactK12StaffAssignmentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 567; SchoolYear',
  LeaId BIGINT COMMENT 'src rows 568,569; Codist, OrganizationId',
  K12SchoolId BIGINT COMMENT 'src rows 570; BuildingCode',
  K12StaffId BIGINT COMMENT 'src rows 575,576,577; Cert, EducatorID, PersonnelId',
  K12StaffCategoryId STRING COMMENT 'src rows 611; Droot',
  FullTimeEquivalency DECIMAL(12,3) COMMENT 'src rows 615; AssFTE'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12StaffCourseSections (
  FactK12StaffCourseSectionId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 1528; SchoolYear',
  LeaId BIGINT COMMENT 'src rows 1529; DistrictCode',
  K12SchoolId BIGINT COMMENT 'src rows 1531,1533; LocationID, SchoolCode',
  K12StaffId BIGINT COMMENT 'src rows 1534,1535; CertificationNumber, StaffID',
  K12CourseSectionId STRING COMMENT 'src rows 1543; SectionID',
  ScedCodeId STRING COMMENT 'src rows 1546; StateCourseCode',
  CipCodeId STRING COMMENT 'src rows 1552; CTECIPCode',
  K12StaffAssignmentStartDateId DATE COMMENT 'src rows 1573; InstructionStartDate',
  K12StaffAssignmentEndDateId DATE COMMENT 'src rows 1574; InstructionEndDate',
  K12StaffCategoryId STRING COMMENT 'src rows 1578; StaffTypeCode'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12StaffEmployments (
  FactK12StaffEmploymentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  YearsOfTotalExperience DECIMAL(12,3) COMMENT 'src rows 590; Exp'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12StudentAcademicAwards (
  FactK12StudentAcademicAwardId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  DiplomaOrCredentialAwardDateId DATE COMMENT 'src rows 1066; DateExitedSchool',
  K12AcademicAwardStatusId STRING COMMENT 'src rows 1067,1800; High School Diploma, WithdrawalCode'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12StudentAcademicRecords (
  FactK12StudentAcademicRecordId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  HighSchoolGradePointAverageCumulativeUnweighted DECIMAL(12,3) COMMENT 'src rows 1082; CumulativeGPA'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12StudentAssessments (
  FactK12StudentAssessmentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  LeaId BIGINT COMMENT 'src rows 858,883,1818; DistrictCode, WaK_districtcode',
  GradeLevelWhenAssessedId STRING COMMENT 'src rows 862,897; ReportingGrade',
  K12StudentId BIGINT COMMENT 'src rows 863,887,1822,1826,1904,1905; SSID, WaK_ChildID, WaK_DistrictStudentID, WaK_SSID, WaK_StateStudentID',
  K12SchoolId BIGINT COMMENT 'src rows 864,885,1819; SchoolCode, WaK_schoolcode',
  SchoolYearId BIGINT COMMENT 'src rows 866,882,1906; SchoolYear, WaK_SchoolYear',
  AssessmentId STRING COMMENT 'src rows 873; TestType',
  AssessmentPerformanceLevelId STRING COMMENT 'src rows 874; PerformanceLevel',
  AssessmentResultScoreValueScaleScore DECIMAL(12,3) COMMENT 'src rows 878,899,907,915,923,931,1877,1878,1879,1880,1881,1882...; ScaleScore, ScaleScore_Listening, ScaleScore_Reading, ScaleScore_Speaking, ScaleScore_Writing, SpanishLanguageScaleScore, SpanishLiteracyScaleScore, WaK_CognitiveScaleScore, WaK_La',
  AssessmentResultScoreValueRawScore STRING COMMENT 'src rows 879,903,906,914,922,930,1836,1837,1838,1839,1840,1841...; RawScore, RawScore_Listening, RawScore_Reading, RawScore_Speaking, RawScore_Writing, Score, SpanishLanguageRawScore, SpanishLiteracyRawScore, WaK_CognitiveRawScore, WaK_LanguageRaw',
  AssessmentResultScoreValueStandardErrorScaleScore DECIMAL(12,3) COMMENT 'src rows 902,908,916,924,932; SEM_Scale, SEM_Scale_Listening, SEM_Scale_Reading, SEM_Scale_Speaking, SEM_Scale_Writing'
)
USING DELTA
CLUSTER BY (K12StudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12StudentCourseSections (
  FactK12StudentCourseSectionId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 1594; SchoolYear',
  LeaAttendanceId BIGINT COMMENT 'src rows 1595; DistrictCode',
  K12SchoolId BIGINT COMMENT 'src rows 1597,1599; LocationID, SchoolCode',
  K12StudentId BIGINT COMMENT 'src rows 1600,1601; DistrictStudentID, SSID',
  K12CourseSectionId STRING COMMENT 'src rows 1603; SectionID',
  LeaK12CourseId STRING COMMENT 'src rows 1604; CourseID',
  CipCodeId STRING COMMENT 'src rows 1614; CTECIPCode',
  StudentCourseSectionGradeEarned STRING COMMENT 'src rows 1650; LetterGrade',
  NumberOfCreditsAttempted DECIMAL(12,3) COMMENT 'src rows 1652; CreditsAttempted',
  NumberOfCreditsEarned DECIMAL(12,3) COMMENT 'src rows 1653; CreditsEarned',
  WorkBasedLearningStatusId STRING COMMENT 'src rows 1666; WorkBasedLearningActivityTypeCode'
)
USING DELTA
CLUSTER BY (K12StudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12StudentDailyAttendances (
  FactK12StudentDailyAttendanceId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 937; SchoolYear',
  LeaId BIGINT COMMENT 'src rows 938,942; DistrictCode, DistrictOrgID',
  K12SchoolId BIGINT COMMENT 'src rows 940,941,944; LocationID, SchoolCode, SchoolOrgID',
  PersonId BIGINT COMMENT 'src rows 947,948; DistrictStudentID, SSID',
  AttendanceEventDateId DATE COMMENT 'src rows 949; AbsenceDate',
  AttendanceEventDurationDay STRING COMMENT 'src rows 951; AbsenceCode'
)
USING DELTA
CLUSTER BY (PersonId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12StudentDisciplines (
  FactK12StudentDisciplineId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 997,1143; SchoolYear',
  LeaId BIGINT COMMENT 'src rows 998,1002,1144; DistrictCode, DistrictOrgID',
  K12SchoolId BIGINT COMMENT 'src rows 1000,1001,1004,1146,1148; LocationID, LocationId, SchoolCode, SchoolOrgID',
  K12StudentId BIGINT COMMENT 'src rows 1007,1008,1149,1150; DistrictStudentCode, DistrictStudentID, SSID',
  IncidentIdentifier STRING COMMENT 'src rows 1009,1151; IncidentId',
  IncidentDateId DATE COMMENT 'src rows 1010,1152; IncidentDate',
  DisciplinaryActionStartDateId DATE COMMENT 'src rows 1017,1166; ExclusionaryActionDate, InterventionDate',
  DurationOfDisciplinaryAction DECIMAL(12,3) COMMENT 'src rows 1018,1167; ExclusionaryActionDaysDuration, InterventionDays'
)
USING DELTA
CLUSTER BY (K12StudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactK12StudentEnrollments (
  FactK12StudentEnrollmentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 1045; SchoolYear',
  LeaAttendanceId BIGINT COMMENT 'src rows 1046; DistrictCode',
  LeaMembershipResidentId BIGINT COMMENT 'src rows 1048; ResidentDistrictCode',
  K12SchoolId BIGINT COMMENT 'src rows 1050,1052; LocationID, SchoolCode',
  K12StudentId BIGINT COMMENT 'src rows 1054,1055; DistrictStudentID, SSID',
  EntryGradeLevelId STRING COMMENT 'src rows 1062; GradeLevel',
  EnrollmentEntryDateId DATE COMMENT 'src rows 1065; DateEnrolledinSchool',
  EnrollmentExitDateId DATE COMMENT 'src rows 1066; DateExitedSchool',
  LanguageNativeId STRING COMMENT 'src rows 1076; PrimaryLanguageCode',
  LanguageHomeId STRING COMMENT 'src rows 1078; LanguageSpokenatHomeCode',
  CohortGraduationYearId STRING COMMENT 'src rows 1081; ExpectedGradYear',
  PrimaryDisabilityTypeId STRING COMMENT 'src rows 1086; DisabilityCode',
  HomelessnessStatusId STRING COMMENT 'src rows 1096; HomelessCode',
  ImmigrantStatusId BOOLEAN COMMENT 'src rows 1099; IsStudentImmigrant',
  MilitaryStatusId STRING COMMENT 'src rows 1111; MilitaryParentorGuardianCD'
)
USING DELTA
CLUSTER BY (K12StudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactPsStudentAcademicAwards (
  FactPsStudentAcademicAwardId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 1997,2167; YEAR, academic_year',
  PsInstitutionId BIGINT COMMENT 'src rows 2000,2261,2358; COLLEGE, INSTITUTION, institution',
  PsAcademicAwardTitleId STRING COMMENT 'src rows 2004,2263; DEGREE_TITLE, program',
  PsStudentId BIGINT COMMENT 'src rows 2008,2241,2248,2419; DW_KEY, EMPLID, SID, student_institution',
  AcademicAwardDateId DATE COMMENT 'src rows 2125,2285; Graduation_Date, YRQ'
)
USING DELTA
CLUSTER BY (PsStudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactPsStudentAcademicRecords (
  FactPsStudentAcademicRecordId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  GradePointAverageCumulative DECIMAL(12,3) COMMENT 'src rows 2048,2314; GPA_CUM, cumulative_institutional_GPA_key',
  GradePointAverage DECIMAL(12,3) COMMENT 'src rows 2080,2365; GPA, term_GPA_key',
  InstructionalActivityHoursCompletedCredit DECIMAL(12,3) COMMENT 'src rows 2227; CREDITS_TOTAL'
)
USING DELTA
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactPsStudentCourseTranscripts (
  FactPsStudentCourseTranscriptId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 2027,2163; YEAR, academic_year',
  NumberOfCreditsAttempted DECIMAL(12,3) COMMENT 'src rows 2030,2218; CR, credit_hours_attempted',
  NumberOfCreditsEarned DECIMAL(12,3) COMMENT 'src rows 2031,2218; CR, credit_hours_earned',
  StudentCourseSectionGradeEarned STRING COMMENT 'src rows 2034,2325; GR, grade',
  PsInstitutionId BIGINT COMMENT 'src rows 2035,2366,2450; COLLEGE, INSTITUTION, institution',
  PsStudentId BIGINT COMMENT 'src rows 2041,2245,2253,2421; DW_KEY, EMPLID, SID, student_institution',
  AcademicTermDesignatorId BIGINT COMMENT 'src rows 2042,2181,2440,2479; QUARTER, STRM, YRQ, term',
  CipCodeId STRING COMMENT 'src rows 2446; CIP'
)
USING DELTA
CLUSTER BY (PsStudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactPsStudentEnrollments (
  FactPsStudentEnrollmentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 2043,2177; YEAR, academic_year',
  PsInstitutionId BIGINT COMMENT 'src rows 2063,2116,2332,2360; COLLEGE, College_Code_Branch, INSTITUTION, institution',
  PsStudentId BIGINT COMMENT 'src rows 2075,2094,2243,2249,2420; DW_KEY, EMPLID, SID, TokenID, student_OFM',
  AcademicTermDesignatorId BIGINT COMMENT 'src rows 2078,2176,2423,2437; QUARTER, STRM, YRQ, term',
  EnrollmentEntryDateId DATE COMMENT 'src rows 2121; Enrollment_Begin_Date',
  EnrollmentExitDateId DATE COMMENT 'src rows 2122; Enrollment_End_Date',
  PsEnrollmentStatusId STRING COMMENT 'src rows 2123,2312,2320,2341; AWARD_SEEK, DEGREE_SEEK, Enrollment_Status, FULL_PART_TIME_IND'
)
USING DELTA
CLUSTER BY (PsStudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactQuarterlyEmployments (
  FactQuarterlyEmploymentId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  PersonId BIGINT COMMENT 'src rows 792; SSN',
  EmploymentRecordReferencePeriodStartDateId STRING COMMENT 'src rows 793; YearQuarter',
  EmploymentRecordReferencePeriodEndDateId STRING COMMENT 'src rows 793; YearQuarter',
  EmployerId BIGINT COMMENT 'src rows 796,802; EmployerAccountNumber, FEIN',
  QuarterlyEarnings DECIMAL(14,2) COMMENT 'src rows 798; TotalWageAmount',
  NaicsCodeId STRING COMMENT 'src rows 801; NAICSCode',
  StandardOccupationalClassificationId STRING COMMENT 'src rows 803; SOC'
)
USING DELTA
CLUSTER BY (PersonId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.ceds_rds.FactSpecialEducation (
  FactSpecialEducationId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SchoolYearId BIGINT COMMENT 'src rows 1447,1504; SchoolYear',
  LeaIEPServiceProviderId BIGINT COMMENT 'src rows 1448; DistCode',
  K12SchoolId BIGINT COMMENT 'src rows 1450,1452; LocationID, SchCode',
  K12StudentId BIGINT COMMENT 'src rows 1453,1507,1508; DistrictStudentCode, SSID',
  ProgramParticipationStartDateId DATE COMMENT 'src rows 1454; StartDate',
  IdeaStatusId STRING COMMENT 'src rows 1455; LRETypeCode',
  SpecialEducationServicesExitDateId DATE COMMENT 'src rows 1457; ExitDate',
  LeaAttendanceId BIGINT COMMENT 'src rows 1505; DistrictCode',
  ConsentToEvaluationDateId DATE COMMENT 'src rows 1510; DistReceivConsentDate',
  IndividualizedProgramDateId DATE COMMENT 'src rows 1511; InitialIEPMeetingDate',
  EligibilityEvaluationDateInitialId STRING COMMENT 'src rows 1512; InitEligDeterminDate'
)
USING DELTA
CLUSTER BY (K12StudentId)
COMMENT ' | Grain: '
TBLPROPERTIES ('p20w.table_type' = 'FACT', 'p20w.scd' = 'n/a (fact)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.conformed.AcademicPeriodXwalk (
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  AcademicPeriodId BIGINT COMMENT 'Derived',
  PeriodCodeType STRING COMMENT 'Code type',
  SourcePeriodCode STRING COMMENT 'src rows 82,112,113,121,127,152,153,156,222,282,325,326...; ApplicationAcademicYear, LEGACY_QUARTER, LEGACY_YEAR, LEGACY_YRQ, MonthOfService, ProgramYear, QUARTER, Quarter, SCHOOL_YEAR, STRM, School Year, SchoolYear, SchoolYearCode, SchoolY'
)
USING DELTA
COMMENT 'Source period codes (YRQ, STRM, YYYYQ, SchoolYearId) -> academic_period_id | Grain: One row per source system x period code type x source period code'
TBLPROPERTIES ('p20w.table_type' = 'PERIOD_XWALK', 'p20w.scd' = 'Type 1', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.conformed.OrganizationIdentifierXwalk (
  OrganizationIdentifierXwalkId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  OrgId BIGINT COMMENT 'Durable org assigned by mastering',
  SourceIdentifierType STRING COMMENT 'Identifier type',
  EffectiveStartDate DATE COMMENT 'First date this code maps to this org',
  EffectiveEndDate DATE COMMENT 'Last date (code reuse after this date maps elsewhere)',
  AssignmentBasis STRING COMMENT 'SOURCE_MASTER / LINEAGE_EVENT / STEWARD_OVERRIDE',
  SourceOrganizationIdentifier STRING COMMENT 'src rows 96,97,106,122,125,142,145,148,151,154,163,165...; ApplicationDistrictCode, ApplicationESDNumber, ApplicationSchoolCode, ApprovedOnlinePGMResidentDistOrg, ApprovedOnlinePGMResidentDistOrgId, ApprovedOnlineProgramCode, ApprovedOnlin'
)
USING DELTA
COMMENT 'Source org identifiers -> durable org_id | Grain: One row per source system x identifier type x source identifier x effective period'
TBLPROPERTIES ('p20w.table_type' = 'ORG_XWALK', 'p20w.scd' = 'Effective-dated; handles code reuse (same code, different org in different periods)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.conformed.OrganizationLineage (
  OrganizationLineageId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  LineageEventId BIGINT COMMENT 'SYSTEM',
  EventEffectivePeriodCode STRING COMMENT 'Source period code of the event (e.g. SBCTC YRQ A121)',
  AllocationShare DECIMAL(5,4) COMMENT 'Share of predecessor attributed to this successor for aggregate re-attribution (splits); null = no allocation',
  FactReattributionRule STRING COMMENT 'AS_REPORTED_ONLY / ROLL_FORWARD_TO_SUCCESSOR / ROLL_BACK_TO_PREDECESSOR / ALLOCATE',
  StewardNote STRING COMMENT 'Free-text steward rationale',
  PredecessorOrgId DECIMAL(12,3) COMMENT 'src rows 670,671; Predecessor RUN, Predecessor UI Account Number',
  SuccessorOrgId DECIMAL(12,3) COMMENT 'src rows 672,673; Successor RUN, Successor UI Account Number',
  EventType STRING COMMENT 'src rows 769,777,780; First Supplemental P/S Identifier, P/S Partial/Full Indicator, Second Supplemental P/S Identifier',
  EventEffectiveDate STRING COMMENT 'src rows 770,771,772; P/S Transfer Day, P/S Transfer Month, P/S Transfer Year',
  MultipleSuccessorIndicator STRING COMMENT 'src rows 773; Multiple Successors',
  MultiplePredecessorIndicator STRING COMMENT 'src rows 774; Multiple Predecessors',
  EvidenceSourceCode STRING COMMENT 'src rows 775,776; Predecessor Source, Successor Source Code',
  CounterpartyOrgId DECIMAL(12,3) COMMENT 'src rows 778,779,781,782; First Supplemental P/S Reporting Unit Number, First Supplemental P/S UI Account Number, Second Supplemental P/S Reporting Unit Number, Second Supplemental P/S UI Account Number'
)
USING DELTA
COMMENT 'Mergers, splits, closures, recodes, successions | Grain: One row per lineage event x predecessor x successor'
TBLPROPERTIES ('p20w.table_type' = 'ORG_LINEAGE', 'p20w.scd' = 'Append-only event log (events are facts about orgs, not attribute versions)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.conformed.OrganizationLineageClosure (
  OrganizationLineageClosureId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  OrgId BIGINT COMMENT 'Derived',
  RelatedOrgId BIGINT COMMENT 'Derived',
  RelationshipDirection STRING COMMENT 'SUCCESSOR / PREDECESSOR',
  PathLength INT COMMENT 'Derived',
  AllocationShareProduct DECIMAL(9,6) COMMENT 'Derived',
  IsTerminalSuccessor BOOLEAN COMMENT 'Derived: related_org has no successor',
  LineageGroupId BIGINT COMMENT 'Derived: connected component id (e.g. all Pierce College orgs)'
)
USING DELTA
COMMENT 'Transitive closure used to roll historical facts to current successors | Grain: One row per org_id x ancestor/descendant org_id reachable through lineage events'
TBLPROPERTIES ('p20w.table_type' = 'ORG_LINEAGE', 'p20w.scd' = 'Rebuilt from ORGANIZATION_LINEAGE on each load (Type 1)', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.identity.NscStudentTrackerRequestResult (
  NscStudentTrackerRequestResultId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  RecordId STRING COMMENT 'src rows 2093; RecordID',
  Status STRING COMMENT 'src rows 2095; Status',
  NscEffectiveDate DATE COMMENT 'src rows 2096; NSCEffectiveDate',
  NscRunDate DATE COMMENT 'src rows 2097; NSCRunDate',
  Request STRING COMMENT 'src rows 2098; Request',
  Description STRING COMMENT 'src rows 2099; Description',
  SasRecordId STRING COMMENT 'src rows 2100; SasRecordID',
  SearchDate DATE COMMENT 'src rows 2101; Search_Date',
  RecordFoundYN STRING COMMENT 'src rows 2113; Record_Found_Y_N',
  HighSchoolCode STRING COMMENT 'src rows 2114; High_School_Code',
  HighSchoolGraduationDate DATE COMMENT 'src rows 2115; High_School_Graduation_Date',
  ProgramCode STRING COMMENT 'src rows 2129; Program_Code'
)
USING DELTA
COMMENT 'Admin-only NSC request/return metadata | Grain: One row per NSC return record (request metadata)'
TBLPROPERTIES ('p20w.table_type' = 'IDENTITY', 'p20w.scd' = 'Append-only', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.identity.PersonDetailObservation (
  PersonDetailObservationId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  FirstName STRING COMMENT 'src rows 86,198,241,291,399,480,535,573,795,805,868,889...; Child_F_Name, EmployeeFirstName, First Name, FirstName, First_Name, LegalFirstName, NameFirst, StaffFirstName, StudentFirstName, WaK_ChildFName, first_name',
  LastOrSurname STRING COMMENT 'src rows 87,205,242,293,400,479,534,572,807,869,888,1056...; Child_L_Name, Last Name, LastName, Last_Name, LegalLastName, NameLast, StaffLastName, StudentLastName, WaK_ChildLName, last_name',
  MiddleName STRING COMMENT 'src rows 88,212,243,292,401,536,574,806,870,890,1058,1538...; Child_MI, LegalMiddleName, Middle Name, MiddleInitial, MiddleName, Middle_Name, NameMiddle, StaffMiddleName, StudentMiddleInitial, StudentMiddleName, WaK_ChildMI, middle_name',
  Birthdate DATE COMMENT 'src rows 89,178,244,278,329,402,626,843,867,891,1059,1539...; BIRTH_DATE, Birth Date, BirthDate, Birthdate, DOB, Date_of_Birth, SRBirthDate, StaffBirthDate, StudentBirthDate, WaK_Birthdate, birth_date',
  AddressPostalCode STRING COMMENT 'src rows 95; ZipCode',
  FullNameAsReported STRING COMMENT 'src rows 277,2368; INSTR_NAME, SRName',
  SocialSecurityNumber STRING COMMENT 'src rows 403,792,808,2074,2146,2483,2587,2601,2626,2627; ApplicationSSN, SSN, UpdatedSSN, ssn',
  SocialSecurityNumberLastFour STRING COMMENT 'src rows 404,532,571; SSN, SSNLastFourChars, ssn4',
  MentorContactAsReported STRING COMMENT 'src rows 464; lead_mentor_contact',
  BirthMonthAsReported STRING COMMENT 'src rows 537,578; BirthMonth',
  BirthDayAsReported STRING COMMENT 'src rows 538,579; BirthDay',
  BirthYearAsReported STRING COMMENT 'src rows 539,580; BirthYear',
  EmployeeFullNameAsReported STRING COMMENT 'src rows 794; EmployeeName',
  ElectronicMailAddress STRING COMMENT 'src rows 844; Email Addr',
  TelephoneNumber STRING COMMENT 'src rows 845,2597; Phone Data, StudentPhone',
  AddressStreetNumberAndName STRING COMMENT 'src rows 846; Address Line1',
  AddressApartmentRoomOrSuiteNumber STRING COMMENT 'src rows 847; Address Line2',
  PreferredLastOrSurname STRING COMMENT 'src rows 1106; PreferredLastName',
  PreferredFirstName STRING COMMENT 'src rows 1107; PreferredFirstName',
  PreferredMiddleName STRING COMMENT 'src rows 1109; Preferred Middle Name',
  GenerationCodeOrSuffix STRING COMMENT 'src rows 2065,2111,2150; Name_Suffix, Suffix, name_suffix',
  AlternateLastOrSurname STRING COMMENT 'src rows 2486; NameLast_Alternate',
  AlternateFirstName STRING COMMENT 'src rows 2488; NameFirst_Alternate',
  GuardianLastOrSurname STRING COMMENT 'src rows 2598; GuardianLastName',
  GuardianTelephoneNumber STRING COMMENT 'src rows 2599; GuardianHomePhone',
  BirthYearMonth STRING COMMENT 'src rows 2695; BirthYM'
)
USING DELTA
COMMENT 'Restricted identity zone; never joined by analytic users | Grain: One row per source record observation of identifying attributes'
TBLPROPERTIES ('p20w.table_type' = 'IDENTITY', 'p20w.scd' = 'Append-only observations (no overwrite); consumed by matching', 'delta.enableChangeDataFeed' = 'true');

CREATE TABLE IF NOT EXISTS p20w_gold_ceds.identity.PersonIdentifierXwalk (
  PersonIdentifierXwalkId BIGINT COMMENT 'SYSTEM: surrogate key (identity column)',
  SourceSystem STRING COMMENT 'SYSTEM: source system code of the contributing bronze table',
  BronzeBatchId STRING COMMENT 'SYSTEM: bronze load batch id (Delta table version) for replay/lineage',
  SilverLoadedAt TIMESTAMP COMMENT 'SYSTEM: silver merge timestamp',
  SourceIdentifierType STRING COMMENT 'Identifier type',
  MatchMethod STRING COMMENT 'DETERMINISTIC / PROBABILISTIC / CLERICAL / MDM_TOKEN',
  MatchScore DECIMAL(5,4) COMMENT 'Probabilistic score',
  EffectiveStartDate DATE COMMENT 'Link start',
  EffectiveEndDate DATE COMMENT 'Link end (unmerge closes)',
  Identifier STRING COMMENT 'src rows 81,83,84,85,115,180,239,276,279,302,327,332...; ApplicationSSID, ApplicationSSId, Apprentice Id, CaseNumber, Cert, CertificateNumber, CertificationNumber, ChildID, ChildId, ChildKey, Childid, DW_KEY, District Student Id, Distric',
  PersonId BIGINT COMMENT 'src rows 81,83,84,85,115; ChildId, Childid, FamilyMemberId, SSID'
)
USING DELTA
CLUSTER BY (PersonId)
COMMENT 'Maps every source person identifier to the durable statewide person_id | Grain: One row per source system x identifier type x source identifier x effective period'
TBLPROPERTIES ('p20w.table_type' = 'IDENTITY_XWALK', 'p20w.scd' = 'Effective-dated (Type 2 semantics on the link; re-matches close the old row)', 'delta.enableChangeDataFeed' = 'true');

