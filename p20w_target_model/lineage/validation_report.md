# Lineage build validation report

- Model A: 2593/2593 in-scope inventory rows mapped (16 explicitly excluded to bronze-only with reasons); 237 gold tables; 2048 inventory-derived columns
- Model B: 2593/2593 in-scope inventory rows mapped (16 explicitly excluded to bronze-only with reasons); 166 gold tables; 2195 inventory-derived columns
- Model C: 2593/2593 in-scope inventory rows mapped (16 explicitly excluded to bronze-only with reasons); 184 gold tables; 1986 inventory-derived columns

## Explicit exclusions (identical in all models)

| Row | Source | Table | Element | Reason |
|---|---|---|---|---|
| 655 | OSPI | RetentionMobility | IsRetire | Inventory notes the field does not work yet and is empty (First/Most Recent Year = 'No data'). Retained in bronze only. |
| 662 | UI Wage | UI_Employer | transaction code | Record-type control field (H/F/T/P/S); used as the bronze->silver filter (only 'F' rows loaded). Retained in bronze only. |
| 663 | UI Wage | UI_Employer | State FIPS code | Constant 53 on every record. Retained in bronze only. |
| 666 | UI Wage | UI_Employer | Account Fill | Two-zero filler preceding the 8-character account number. Retained in bronze only. |
| 791 | UI Employer | UI_Employer | Future Use | Reserved filler field with no content. Retained in bronze only. |
| 946 | CEDARS | Absence | PrimarySchoolFlag | Inventory note says the field is left over from the original extract and can be ignored. |
| 1141 | CEDARS | Ethnicity | RecEndDate | Inventory marks element 'DO NOT USE' (all null / default dates; dropped from file in 2017). Retained in bronze only. |
| 1142 | CEDARS | Ethnicity | RecStartDate | Inventory marks element 'DO NOT USE' (all null / default dates; dropped from file in 2017). Retained in bronze only. |
| 1338 | CEDARS | LEP | RecEndDate | Inventory marks element 'DO NOT USE' (all null / default dates; dropped from file in 2017). Retained in bronze only. |
| 1339 | CEDARS | LEP | RecStartDate | Inventory marks element 'DO NOT USE' (all null / default dates; dropped from file in 2017). Retained in bronze only. |
| 1445 | CEDARS | Race | RecEndDate | Inventory marks element 'DO NOT USE' (all null / default dates; dropped from file in 2017). Retained in bronze only. |
| 1446 | CEDARS | Race | RecStartDate | Inventory marks element 'DO NOT USE' (all null / default dates; dropped from file in 2017). Retained in bronze only. |
| 1465 | CEDARS | SPED | SpedRank | OSPI-generated constant (value = 1 for all records); carries no information. Retained in bronze only. |
| 1937 | WaKIDS | WAKIDSSTACKED_2012_2024 | WaK_Obj22a | Inventory profile shows 100% missing across all years. Retained in bronze only. |
| 1938 | WaKIDS | WAKIDSSTACKED_2012_2024 | WaK_Obj22b | Inventory profile shows 100% missing across all years. Retained in bronze only. |
| 1939 | WaKIDS | WAKIDSSTACKED_2012_2024 | WaK_Obj22c | Inventory profile shows 100% missing across all years. Retained in bronze only. |

## Model A: CEDS DW v14.1 conformance check

Every `ceds_rds.*` target was checked against the published CEDS-Data-Warehouse DDL. 32 proposed native columns were not present on the CEDS table and were automatically re-homed to the `_WaExt` extension:

- `ceds_rds.DimCalendarSessions.SourceExtractDate`
- `ceds_rds.DimCalendarSessions.SourceSchoolYear`
- `ceds_rds.DimCalendarSessions.SourceSubmitDate`
- `ceds_rds.DimEarlyLearningOrganizations.OrganizationName`
- `ceds_rds.DimEarlyLearningOrganizations.SiteEsdOrganizationId`
- `ceds_rds.DimK12Courses.K12SchoolId`
- `ceds_rds.DimK12Courses.LeaId`
- `ceds_rds.DimK12Courses.SchoolYearId`
- `ceds_rds.DimK12Schools.SchoolYearId`
- `ceds_rds.DimOrganizationCalendarSessions.AcademicTermDesignatorId`
- `ceds_rds.DimOrganizationCalendarSessions.PsCampusOrganizationId`
- `ceds_rds.DimOrganizationCalendarSessions.PsInstitutionId`
- `ceds_rds.DimOrganizationCalendarSessions.SchoolYearId`
- `ceds_rds.DimPsCourses.CourseId`
- `ceds_rds.DimPsCourses.CourseNum`
- `ceds_rds.DimPsCourses.CourseNumPrefix`
- `ceds_rds.DimPsCourses.CourseNumSuffix`
- `ceds_rds.FactCredentialAwards.IssueSourceOrgOrganizationId`
- `ceds_rds.FactK12ProgramParticipations.LeaMembershipResidentId`
- `ceds_rds.FactK12ProgramParticipations.ReengagementProviderOrganizationId`
- `ceds_rds.FactK12StudentAssessments.K12StaffId`
- `ceds_rds.FactK12StudentCourseSections.OnlineProgramOrganizationId`
- `ceds_rds.FactK12StudentCourseSections.OnlineProgramResidentLeaOrganizationId`
- `ceds_rds.FactK12StudentCourseSections.OnlineProviderOrganizationId`
- `ceds_rds.FactK12StudentDisciplines.LeaMembershipResidentId`
- `ceds_rds.FactPsStudentAcademicAwards.AcademicTermDesignatorId`
- `ceds_rds.FactPsStudentAcademicAwards.PsCampusOrganizationId`
- `ceds_rds.FactPsStudentCourseTranscripts.PsCampusOrganizationId`
- `ceds_rds.FactPsStudentEnrollments.LastHighSchoolOrganizationId`
- `ceds_rds.FactPsStudentEnrollments.ParentPsInstitutionOrganizationId`
- `ceds_rds.FactPsStudentEnrollments.PreviousPsInstitutionOrganizationId`
- `ceds_rds.FactPsStudentEnrollments.PsCampusOrganizationId`

## EAV scan

No generic attribute/value columns found.

## Conformance points (Model C columns fed by more than one distinct source element)

| Table.Column | Contributing elements (row numbers) |
|---|---|
| fact.ADMISSION_EL_ELMS_ELIGIBILITY_RESPONSE.q{boolean_question_id}_answer | ELMS.ApplicationDataBooleanQuestion.BooleanQuestionID (79); ELMS.ApplicationDataBooleanQuestion.Answer (80) |
| fact.ADMISSION.program_id | ELMS.Application.ProgramTypeId (103); EPP.Admissions.prog_id (477); College Bound Scholarship Application.College Bound Scholarship Application.CBSPledgeID (2584); College Bound Application Readiness.College Bound Application Readiness.CBSPledgeId (2622) |
| fact.ADMISSION.application_date | EPP.Admissions.app_date (481); College Bound Application Readiness.College Bound Application Readiness.PledgeSubmissionDate (2665) |
| fact.ADMISSION.entry_academic_period_id | OFM.admission.admit_academic_year (1959); OFM.admission.admit_term (1960) |
| fact.ADMISSION_EL_ELMS_DETAIL.family_income | ELMS.ApplicationData.AnnualFamilyIncomeForEligibility (107,107); ELMS.ApplicationData.MonthlyFamilyIncomeForEligibilit (109) |
| conformed.ORG_LEA.ospi_ccddd | ELMS.SchoolDistrict.SchoolDistrictCode (96); ELMS.SchoolDistrict.IEPSchoolDistrictCode (97); EPP.Clinical.dist_code (460); OSPI.S275.Codist (568); Assessments.Statewide Assessments.DistrictCode (858); Assessments.English Language Assessments.DistrictCode (883); CEDARS.Absence.DistrictCode (942); CEDARS.Course Catalog.DistrictCode (956) ... |
| conformed.PERSON.sex | ELMS.FamilyMember.GenderTypeId (90); Hist ECEAP..Sex (229); ESIT.child.GenderTypeId (245); EPP.Demographic.gender (405); EPP.Admissions.gender (482); OSPI.Ecert.SexCode (540); OSPI.S275.Sex (581); OSPI.RetentionMobility.Gender (631) ... |
| conformed.PERSON_RACE_ETHNICITY.reported_race_ethnicity_rollup | OSPI.RetentionMobility.RaceEthnicity (630); CEDARS.Enrollment.FederalEthRaceRollupCode (1074); CEDARS.Enrollment.FederalEthRaceRollupName (1075); CEDARS.Ethnicity.FedEthTypeRollup (1132); CEDARS.Race.FedEthTypeRollup (1436); WaKIDS.WAKIDSSTACKED_2012_2024.WaK_RaceFederalrollup (1832); WaKIDS.WAKIDSSTACKED_2012_2024.WaK_FederalRollup (1918); WaKIDS.WAKIDSSTACKED_2012_2024.WaK_FederalRaceEthnicity (1929) ... |
| conformed.PERSON_RACE_ETHNICITY.collection_method_code_id | CEDARS.Ethnicity.EthnicityCollectionMethodID (1138); CEDARS.Race.RaceCollectionMethodID (1442) |
| conformed.PERSON_RACE_ETHNICITY.collection_method_code | CEDARS.Ethnicity.EthnicityCollectionMethodCode (1139); CEDARS.Race.RaceCollectionMethodCode (1443) |
| conformed.PERSON_RACE_ETHNICITY.collection_method_description | CEDARS.Ethnicity.EthnicityCollectionMethod (1140); CEDARS.Race.RaceCollectionMethod (1444) |
| conformed.PERSON_LANGUAGE.language_code | ELMS.FamilyMemberLanguage.LanguageTypeId (92); Hist ECEAP..PrimeLang (221); Hist ECEAP..SecondLang (228); CEDARS.Enrollment.PrimaryLanguageCode (1076); CEDARS.Enrollment.LanguageSpokenatHomeCode (1078); CEDARS.Enrollment.FamilyLanguageCode (1123); SBCTC.Student.PRIMARY_LANGUAGE (2392) |
| conformed.ORG_EL_PROVIDER.elms_organization_id | ELMS.Organization.SiteOrganizationID (125); ELMS.OrganizationRelationship.ContractorID (142); ELMS.OrganizationRelationship.SubcontractorID (145); ELMS.OrganizationRelationship.SiteID (148,154); TSGold.tsgold_stacked_202x.SiteID (348); TSGold.tsgold_stacked_202x.ELMS_Contractor_ID (356) |
| conformed.ORG_EL_PROVIDER.org_id | ELMS.Organization.SiteOrganizationID (125); ELMS.SiteECEAPMetaData.ProviderNumber (168) |
| conformed.ORG_EL_PROVIDER.el_provider_role_type_id | ELMS.Organization.SiteOrganizationTypeID (126); ELMS.Organization.ContractorTypeID (143); ELMS.Organization.SubcontractorTypeID (146); ELMS.Organization.SiteTypeID (149) |
| conformed.ORG_ESD.ospi_esd_code | OSPI School Directory.OSPI School Directory.ESD_ID (1754); College Bound Application Readiness.College Bound Application Readiness.ApplicationESDNumber (2647) |
| fact.PROGRAM_PARTICIPATION.program_participation_start_date | ELMS.ChildIEP.IEPCreatedDate (100); EPP.Demographic.enroll_date (414); CEDARS.LAP.StartDate (1287); CEDARS.LEP.BilStartDate (1313); CEDARS.Programs.StartDate (1421); CEDARS.SPED.StartDate (1454); CEDARS.SPED Eval.InitialReferralDate (1509) |
| fact.PROGRAM_PARTICIPATION.program_id | ELMS.ChildIEP.IEPCreatedDate (100); ESIT.child.CountyTypeId (246); EPP.Demographic.prog_id (398); EPP.Clinical.prog_id (456); CEDARS.FRPL.FreeReducedMealsFlag (1205); CEDARS.LAP.ProgramCode (1285); CEDARS.LEP.ProgramDesignation (1328); CEDARS.Programs.ProgramID (1419) ... |
| fact.PROGRAM_PARTICIPATION.program_participation_exit_date | ELMS.ChildIEP.IEPExpirationDate (101); EPP.Demographic.exit_date (416); CEDARS.LEP.BilExitDate (1314); CEDARS.Programs.ExitDate (1422); CEDARS.SPED.ExitDate (1457); OSPI.ERDC_YYYYSYOpenDoorsYouthEngage.Program Exit Date (1804) |
| fact.ENROLLMENT.enrollment_entry_date | ELMS.ChildClass.ActualStartDate (118); Hist ECEAP..EnrollmentDate (194); Hist ECEAP..FirstServiceDate (199); Apprenticeship.LNI_APPRENTICE.Registration Date (814); CEDARS.Enrollment.DateEnrolledinSchool (1065); NSC.Stacked.Enrollment_Begin_Date (2121) |
| fact.ENROLLMENT.enrollment_exit_date | ELMS.ChildClass.LastDateAttended (119); Hist ECEAP..ExitServiceDate (196); Apprenticeship.LNI_APPRENTICE.Status Date (816); CEDARS.Enrollment.DateExitedSchool (1066); NSC.Stacked.Enrollment_End_Date (2122) |
| conformed.COURSE_SECTION.session_begin_date | CEDARS.Staff Schedule.TermStartDate (1541); SBCTC.Class.STRT_DATE (2441) |
| conformed.COURSE_SECTION.session_end_date | CEDARS.Staff Schedule.TermEndDate (1542); SBCTC.Class.END_DATE (2264) |
| conformed.COURSE_SECTION.course_section_identifier | CEDARS.Staff Schedule.SectionID (1543); CEDARS.Student Schedule.SectionID (1603); OFM.registration.section (2040); SBCTC.Class.ITEM (2371) |
| fact.ASSESSMENT.program_id | TSGold.tsgold_stacked_2024.ProgramID (288); TSGold.tsgold_stacked_2024.Program (289) |
| fact.ASSESSMENT.performance_level_code | TSGold.tsgold_stacked_2024.SE_WHE (296); TSGold.tsgold_stacked_2024.PH_WHE (297); TSGold.tsgold_stacked_202x.LA_WHE (298); TSGold.tsgold_stacked_202x.CG_WHE (299); TSGold.tsgold_stacked_202x.LI_WHE (300); TSGold.tsgold_stacked_202x.MA_WHE (301); TSGold.tsgold_stacked_202x.SLA_WHE (311); TSGold.tsgold_stacked_202x.SLI_WHE (318) ... |
| fact.ASSESSMENT.standard_met_indicator | TSGold.tsgold_stacked_2024.SE_WHE (296); TSGold.tsgold_stacked_2024.PH_WHE (297); TSGold.tsgold_stacked_202x.LA_WHE (298); TSGold.tsgold_stacked_202x.CG_WHE (299); TSGold.tsgold_stacked_202x.LI_WHE (300); TSGold.tsgold_stacked_202x.MA_WHE (301); TSGold.tsgold_stacked_202x.SLA_WHE (311); TSGold.tsgold_stacked_202x.SLI_WHE (318) ... |
| fact.ASSESSMENT.raw_score | TSGold.tsgold_stacked_202x.SLA_RS (309); TSGold.tsgold_stacked_202x.SLI_RS (316); TSGold.tsgold_stacked_202x.CG_RS (330); TSGold.tsgold_stacked_202x.LA_RS (334); TSGold.tsgold_stacked_202x.LI_RS (336); TSGold.tsgold_stacked_202x.MA_RS (340); TSGold.tsgold_stacked_202x.PH_RS (343); TSGold.tsgold_stacked_202x.SE_RS (346) ... |
| fact.ASSESSMENT.scale_score | TSGold.tsgold_stacked_202x.SLA_SS (310); TSGold.tsgold_stacked_202x.SLI_SS (317); TSGold.tsgold_stacked_202x.CG_SS (331); TSGold.tsgold_stacked_202x.LA_SS (335); TSGold.tsgold_stacked_202x.LI_SS (337); TSGold.tsgold_stacked_202x.MA_SS (341); TSGold.tsgold_stacked_202x.PH_SS (344); TSGold.tsgold_stacked_202x.SE_SS (347) ... |
| fact.ASSESSMENT.assessment_administration_date | TSGold.tsgold_stacked_202x.Cognitive_Date_Finalized (333); TSGold.tsgold_stacked_202x.Language_Date_Finalized (338); TSGold.tsgold_stacked_202x.Literacy_Date_Finalized (339); TSGold.tsgold_stacked_202x.Mathematics_Date_Finalized (342); TSGold.tsgold_stacked_202x.Physical_Date_Finalized (345); TSGold.tsgold_stacked_202x.Social_Emotional_Date_Finalized (349); TSGold.tsgold_stacked_202x.Spanish_Language_Date_Finalized (351); TSGold.tsgold_stacked_202x.Spanish_Literacy_Date_Finalized (352) ... |
| fact.ASSESSMENT.assessment_instrument_id | EPP.Assessment.assess_code (437); EPP.Assessment.test_code (438); EPP.Assessment.assess_name (439); Assessments.Statewide Assessments.TestType (873); Assessments.English Language Assessments.AssessmentName (892); Assessments.English Language Assessments.TestType (894) |
| fact.ASSESSMENT.assessment_subject_or_domain | EPP.Assessment.rubric_name_edTPA (440); Assessments.Statewide Assessments.SubjectName (880); Assessments.English Language Assessments.SubjectName_Reading (905); Assessments.English Language Assessments.SubjectName_Writing (913); Assessments.English Language Assessments.SubjectName_Listening (921); Assessments.English Language Assessments.SubjectName_Speaking (929) |
| fact.ASSESSMENT.score_value_as_reported | EPP.Assessment.score (442); EPP.Admissions.score_exam_m (504); EPP.Admissions.score_exam_r (508); EPP.Admissions.score_exam_w (512); EPP.Admissions.score_exam1 (517); EPP.Admissions.score_exam2 (522); EPP.Admissions.score_exam3 (527) |
| fact.ASSESSMENT.scale_score_standard_error | Assessments.English Language Assessments.SEM_Scale (902); Assessments.English Language Assessments.SEM_Scale_Reading (908); Assessments.English Language Assessments.SEM_Scale_Writing (916); Assessments.English Language Assessments.SEM_Scale_Listening (924); Assessments.English Language Assessments.SEM_Scale_Speaking (932) |
| conformed.ORG_PS_INSTITUTION.ceeb_code | EPP.Institution.inst_code (369); EPP.Program.inst_code (379); EPP.Demographic.inst_code (393); EPP.Assessment.inst_code (430); EPP.Clinical.inst_code (451); EPP.Admissions.inst_code (472); OFM.admission.institution (1969); OFM.admission.previous_institution (1975) ... |
| conformed.ORG_PS_INSTITUTION.opeid_branch | NSC.Stacked.College_Code_Branch (2116); NSC.Stacked.Parent_College_Code (2144) |
| conformed.ACADEMIC_SESSION.session_begin_date | EPP.Institution.campus_enroll_term_start (375); OFM.term_dates.begin_date (2085) |
| conformed.ACADEMIC_SESSION.session_end_date | EPP.Institution.campus_enroll_term_end (376); OFM.term_dates.end_date (2088) |
| conformed.ACADEMIC_SESSION.census_date | EPP.Institution.campus_enroll_census (377); OFM.term_dates.census_date (2087) |
| conformed.PROGRAM.program_name | EPP.Program.prog_award_name (380); CEDARS.Programs.ProgramName (1420); OFM.program.degree (2017) |
| conformed.PROGRAM.program_identifier | EPP.Program.prog_id (381); Apprenticeship.LNI_APPRENTICE.Program Id (809); OFM.program.program (2025); SBCTC.Student Plans.ACAD_PLAN (2427) |
| conformed.PROGRAM.classification_of_instructional_program_code | EPP.Program.prog_field_CIP (388); OFM.program.field_of_study_CIP (2022); SBCTC.Student Plans.CIP_CODE (2425) |
| conformed.ASSESSMENT_INSTRUMENT.assessment_short_name | Assessments.Statewide Assessments.TestType (873); Assessments.English Language Assessments.AssessmentName (892); Assessments.English Language Assessments.TestType (894) |
| conformed.ORG_K12_SCHOOL.ospi_school_code | EPP.Clinical.bldg_code (461); OSPI.S275.BuildingCode (570); Assessments.Statewide Assessments.SchoolCode (864); Assessments.English Language Assessments.SchoolCode (885); CEDARS.Absence.SchoolCode (944); CEDARS.Course Catalog.SchoolCode (958); CEDARS.Discipline.SchoolCode (1004); CEDARS.Enrollment.SchoolCode (1050) ... |
| conformed.ORG_K12_SCHOOL.district_sis_location_id | CEDARS.Absence.LocationID (941); CEDARS.Course Catalog.LocationID (960); CEDARS.Discipline.LocationID (1001); CEDARS.Enrollment.LocationID (1052); CEDARS.Exclusionary Discipline.LocationId (1148); CEDARS.Grade History.LocationID (1216); CEDARS.LAP.LocationId (1283); CEDARS.Location.LocationID (1347) ... |
| fact.EDUCATOR_CREDENTIAL.credential_award_start_date | OSPI.Ecert.CertificateEffectiveDate (552); OSPI.Ecert.EndorsementEffectiveDate (564) |
| fact.EDUCATOR_CREDENTIAL.credential_expiration_date | OSPI.Ecert.CertificateExpireDate (553); OSPI.Ecert.EndorsementExpireDate (565) |
| conformed.ORG_CREDENTIAL_ISSUER.ospi_issue_source_code | OSPI.Ecert.CertificateIssueSourceCode (549); OSPI.Ecert.EndorsementIssueSourceCode (561) |
| conformed.ORG_EMPLOYER.esd_ui_account_number | UI Employer.UI_Employer.UI Account number (667); UI Wage.UI_Wage.EmployerAccountNumber (796) |
| conformed.ORG_EMPLOYER.setup_date | UI Employer.UI_Employer.Setup Date - Year (699); UI Employer.UI_Employer.Setup Date - Month (700); UI Employer.UI_Employer.Setup Date - Day (701) |
| conformed.ORG_EMPLOYER.initial_liability_date | UI Employer.UI_Employer.Initial Date of Liability - Year (702); UI Employer.UI_Employer.Initial Date of Liability - Month (703); UI Employer.UI_Employer.Initial Date of Liability - Day (704) |
| conformed.ORG_EMPLOYER.end_liability_date | UI Employer.UI_Employer.End of Liability Date - year (705); UI Employer.UI_Employer.End of Liability Date - Month (706); UI Employer.UI_Employer.End of Liability Date - Day (707) |
| conformed.ORG_EMPLOYER.reactivation_date | UI Employer.UI_Employer.Reactivation Date - Year (708); UI Employer.UI_Employer.Reactivation Date - Month (709); UI Employer.UI_Employer.Reactivation Date - Day (710) |
| conformed.ORG_EMPLOYER_REPORTING_UNIT.pla_changed_date | UI Employer.UI_Employer.Date PLA Year Changed (753); UI Employer.UI_Employer.Date PLA Month Changed (754); UI Employer.UI_Employer.Date PLA Day Changed (755) |
| fact.ACHIEVEMENT.credential_type | Apprenticeship.LNI_APPRENTICE.Current Status (815); CEDARS.Enrollment.WithdrawalCode (1067); CEDARS.Grade History.IndustryCertificationEarned (1270); CEDARS.Student Schedule.IndustryCertificationEarned (1662); OSPI.ERDC_YYYYSYOpenDoorsYouthEngage.High School Equivalency Certificate (1799); OSPI.ERDC_YYYYSYOpenDoorsYouthEngage.High School Diploma (1800); OSPI.ERDC_YYYYSYOpenDoorsYouthEngage.College Degree (1802); OSPI.ERDC_YYYYSYOpenDoorsYouthEngage.Industry Recognized Certificate (1803) ... |
| fact.ACHIEVEMENT.award_date | Apprenticeship.LNI_APPRENTICE.Status Date (816); CEDARS.Enrollment.DateExitedSchool (1066); OFM.completion.term (2009); NSC.Stacked.Graduation_Date (2125); GED Battery Completers.GED Battery Completers.DateBatteryCompleted (2153); SBCTC.Completions.YRQ (2285) |
| conformed.COURSE.course_identifier | CEDARS.Course Catalog.CourseID (961); OFM.registration.course (2029); SBCTC.Transcripts.COURSE_NUM (2209) |
| conformed.COURSE.course_title | CEDARS.Course Catalog.CourseTitle (962); SBCTC.Transcripts.COURSE_TITLE (2217); SBCTC.Class.COURSE_TITLE (2214) |
| ref.cedars_dual_language_instruction_language.dual_language_instruction_language_source_id | CEDARS.Course Catalog.DualLanguageInstructionLanguageI (988); CEDARS.Staff Schedule.DualLanguageInstructionLanguageId (1588); CEDARS.Student Schedule.DualLanguageInstructionLanguageId (1657) |
| ref.cedars_dual_language_instruction_language.dual_language_instruction_language_code | CEDARS.Course Catalog.DualLanguageInstructionLanguageC (989); CEDARS.Staff Schedule.DualLanguageInstructionLanguageCode (1589); CEDARS.Student Schedule.DualLanguageInstructionLanguageCode (1658) |
| ref.cedars_dual_language_instruction_language.dual_language_instruction_language_description | CEDARS.Course Catalog.DualLanguageInstructionLanguageN (990); CEDARS.Staff Schedule.DualLanguageInstructionLanguageName (1590); CEDARS.Student Schedule.DualLanguageInstructionLanguageName (1659) |
| fact.DISCIPLINE.incident_behavior_code | CEDARS.Discipline.BehaviorCode (1012); CEDARS.Exclusionary Discipline.BehaviorTypeCode (1154) |
| fact.DISCIPLINE.disciplinary_action_taken_code | CEDARS.Discipline.InterventionCode (1015); CEDARS.Exclusionary Discipline.ExclusionaryActionTypeCode (1163) |
| fact.DISCIPLINE.disciplinary_action_start_date | CEDARS.Discipline.InterventionDate (1017); CEDARS.Exclusionary Discipline.ExclusionaryActionDate (1166) |
| fact.DISCIPLINE.duration_of_disciplinary_action | CEDARS.Discipline.InterventionDays (1018); CEDARS.Exclusionary Discipline.ExclusionaryActionDaysDuration (1167) |
| fact.DISCIPLINE.weapon_type_code | CEDARS.Discipline.WeaponCode (1020); CEDARS.Exclusionary Discipline.WeaponTypeCode (1159) |
| fact.DISCIPLINE.idea_interim_alternative_setting_code | CEDARS.Discipline.IsInIAES (1022); CEDARS.Exclusionary Discipline.SPEDInterimAlternativeEdSetting (1169) |
| fact.DISCIPLINE.academic_services_code | CEDARS.Discipline.AcademicServicesCode (1030); CEDARS.Exclusionary Discipline.AcademicServicesTypeCode (1171) |
| fact.DISCIPLINE.behavior_services_code | CEDARS.Discipline.BehaviorServicesCode (1031); CEDARS.Exclusionary Discipline.BehaviorServicesTypeCode (1174) |
| fact.DISCIPLINE.petition_for_readmission_submitted_date | CEDARS.Discipline.PetitionForReadmissionSubmittedd (1034); CEDARS.Exclusionary Discipline.PetitionForReAdmitSubmittedDate (1176) |
| fact.DISCIPLINE.petition_for_readmission_granted_date | CEDARS.Discipline.PetitionForReadmissionGrantedDat (1035); CEDARS.Exclusionary Discipline.PetitionForReAdmitGrantedDate (1177) |
| fact.DISCIPLINE.petition_time_frame_code | CEDARS.Discipline.PetitiontoExceedMorethanOneYear (1036); CEDARS.Exclusionary Discipline.PetitionTimeFrameCode (1179) |
| fact.DISCIPLINE.reengagement_meeting_date | CEDARS.Discipline.DateReengagementMeetingHeld (1038); CEDARS.Exclusionary Discipline.ReengagementMeetingDate (1184) |
| fact.DISCIPLINE.reengagement_plan_code | CEDARS.Discipline.ReengagementPlanCode (1040); CEDARS.Exclusionary Discipline.ReengagementPlanTypeCode (1182) |
| fact.DISCIPLINE.appeal_code | CEDARS.Discipline.AppealCode (1043); CEDARS.Exclusionary Discipline.AppealTypeCode (1186) |
| ref.cedars_incident_behavior.incident_behavior_code | CEDARS.Discipline.BehaviorCode (1012); CEDARS.Exclusionary Discipline.BehaviorTypeCode (1154) |
| ref.cedars_disciplinary_action.disciplinary_action_source_id | CEDARS.Discipline.InterventionId (1014); CEDARS.Exclusionary Discipline.ExclusionaryActionTypeId (1162) |
| ref.cedars_disciplinary_action.disciplinary_action_code | CEDARS.Discipline.InterventionCode (1015); CEDARS.Exclusionary Discipline.ExclusionaryActionTypeCode (1163) |
| ref.cedars_weapon_type.weapon_type_code | CEDARS.Discipline.WeaponCode (1020); CEDARS.Exclusionary Discipline.WeaponTypeCode (1159) |
| fact.DISCIPLINE_SECONDARY_BEHAVIOR.incident_behavior_code | CEDARS.Discipline.OtherBehaviorIds (1027); CEDARS.Exclusionary Discipline.OtherBehaviorCodes (1157) |
| ref.cedars_academic_services.academic_services_source_id | CEDARS.Discipline.AcademicServicesId (1028); CEDARS.Exclusionary Discipline.AcademicServicesTypeId (1170) |
| ref.cedars_academic_services.academic_services_code | CEDARS.Discipline.AcademicServicesCode (1030); CEDARS.Exclusionary Discipline.AcademicServicesTypeCode (1171) |
| ref.cedars_academic_services.academic_services_description | CEDARS.Discipline.AcademicServicesDescription (1032); CEDARS.Exclusionary Discipline.AcademicServicesTypeDesc (1172) |
| ref.cedars_behavior_services.behavior_services_source_id | CEDARS.Discipline.BehaviorServicesId (1029); CEDARS.Exclusionary Discipline.BehaviorServicesTypeId (1173) |
| ref.cedars_behavior_services.behavior_services_code | CEDARS.Discipline.BehaviorServicesCode (1031); CEDARS.Exclusionary Discipline.BehaviorServicesTypeCode (1174) |
| ref.cedars_behavior_services.behavior_services_description | CEDARS.Discipline.BehaviorServicesDescription (1033); CEDARS.Exclusionary Discipline.BehaviorServicesTypeDesc (1175) |
| ref.cedars_petition_time_frame.petition_time_frame_code | CEDARS.Discipline.PetitiontoExceedMorethanOneYear (1036); CEDARS.Exclusionary Discipline.PetitionTimeFrameCode (1179) |
| ref.cedars_petition_time_frame.petition_time_frame_description | CEDARS.Discipline.PetitionTimeFrame (1037); CEDARS.Exclusionary Discipline.PetitionTimeFrameTypeDesc (1180) |
| ref.cedars_reengagement_plan.reengagement_plan_source_id | CEDARS.Discipline.ReengagementPlanId (1039); CEDARS.Exclusionary Discipline.ReengagementPlanTypeId (1181) |
| ref.cedars_reengagement_plan.reengagement_plan_code | CEDARS.Discipline.ReengagementPlanCode (1040); CEDARS.Exclusionary Discipline.ReengagementPlanTypeCode (1182) |
| ref.cedars_reengagement_plan.reengagement_plan_description | CEDARS.Discipline.ReengagementPlanDescription (1041); CEDARS.Exclusionary Discipline.ReengagementPlanTypeDesc (1183) |
| ref.cedars_appeal.appeal_code | CEDARS.Discipline.AppealCode (1043); CEDARS.Exclusionary Discipline.AppealTypeCode (1186) |
| ref.cedars_appeal.appeal_description | CEDARS.Discipline.AppealDescription (1044); CEDARS.Exclusionary Discipline.AppealTypeDesc (1187) |
| fact.ENROLLMENT_K12_CEDARS_DETAIL.first_entry_date_into_us_school | CEDARS.Enrollment.InitialUSAPlacementDate (1101); CEDARS.LEP.InitialUSPlacementDate (1325) |
| fact.ENROLLMENT_K12_CEDARS_DETAIL.number_of_months_non_us_formal_education | CEDARS.Enrollment.NumMonthsNonUSFormalEducation (1103); CEDARS.LEP.NumMonthsNonUSEducation (1327) |
| ref.cedars_language.language_code | CEDARS.Enrollment.PrimaryLanguageCode (1076); CEDARS.Enrollment.LanguageSpokenatHomeCode (1078); CEDARS.Enrollment.FamilyLanguageCode (1123) |
| ref.cedars_language.language_description | CEDARS.Enrollment.PrimaryLanguage (1077); CEDARS.Enrollment.LanguageSpokenatHome (1079); CEDARS.Enrollment.FamilyLanguage (1124) |
| fact.STUDENT_COURSE_RECORD.course_identifier | CEDARS.Grade History.CourseID (1221); CEDARS.Non-Traditional Credit Attempt.CourseId (1362); CEDARS.Student Schedule.CourseID (1604); OFM.registration.course (2029); SBCTC.Transcripts.COURSE_NUM (2209) |
| fact.STUDENT_COURSE_RECORD.course_id | CEDARS.Grade History.CourseID (1221); CEDARS.Non-Traditional Credit Attempt.CourseId (1362); OFM.registration.course (2029); SBCTC.Transcripts.DEPT_DIV (2236) |
| fact.STUDENT_COURSE_RECORD.staff_person_id | CEDARS.Grade History.StaffID (1223); CEDARS.Grade History.CertificationNumber (1224) |
| fact.STUDENT_COURSE_RECORD.grade_earned | CEDARS.Grade History.LetterGrade (1228); CEDARS.Non-Traditional Credit Attempt.LetterGrade (1394); CEDARS.Student Schedule.LetterGrade (1650); OFM.registration.grade (2034); SBCTC.Transcripts.GR (2325) |
| fact.STUDENT_COURSE_RECORD.number_of_credits_attempted | CEDARS.Grade History.CreditsAttempted (1229); CEDARS.Non-Traditional Credit Attempt.CreditsAttempted (1396); CEDARS.Student Schedule.CreditsAttempted (1652); OFM.registration.credit_hours_attempted (2030); SBCTC.Transcripts.CR (2218) |
| fact.STUDENT_COURSE_RECORD.number_of_credits_earned | CEDARS.Grade History.CreditsEarned (1230); CEDARS.Non-Traditional Credit Attempt.CreditsEarned (1397); CEDARS.Student Schedule.CreditsEarned (1653); OFM.registration.credit_hours_earned (2031); SBCTC.Transcripts.CR (2218) |
| fact.STUDENT_COURSE_RECORD.course_section_id | CEDARS.Student Schedule.SectionID (1603); OFM.registration.section (2040); SBCTC.Transcripts.ITEM (2373); SBCTC.StuClass.ITEM (2372) |
| ref.cedars_program.program_code | CEDARS.LAP.ProgramCode (1285); CEDARS.Programs.ProgramID (1419) |
| ref.cedars_approved_online_pgm_resident_dist_org.approved_online_pgm_resident_dist_org_description | CEDARS.Non-Traditional Credit Attempt.ApprovedOnlinePGMResidentDistrict (1392); CEDARS.Student Schedule.ApprovedOnlinePGMResidentDistric (1647) |
| fact.ASSESSMENT_K12_WAKIDS_DETAIL.domain_completion_indicator | WaKIDS.WAKIDSSTACKED_2012_2024.WaK_SocialEmotionalCompletionFla (1889); WaKIDS.WAKIDSSTACKED_2012_2024.WaK_PhysicalCompletionFlag (1890); WaKIDS.WAKIDSSTACKED_2012_2024.WaK_LanguageCompletionFlag (1891); WaKIDS.WAKIDSSTACKED_2012_2024.WaK_CognitiveCompletionFlag (1892); WaKIDS.WAKIDSSTACKED_2012_2024.WaK_LiteracyCompletionFlag (1893); WaKIDS.WAKIDSSTACKED_2012_2024.WaK_MathCompletionFlag (1894) |
| fact.ENROLLMENT_PS_PCHEES_DETAIL.first_major_program_id | OFM.student.concentration (2047); OFM.student.submission_sequence (2077) |
| conformed.COURSE_SECTION_PS_SBCTC_DETAIL.distance_education_course_enrollment | SBCTC.Class.DIST_ED (2196); SBCTC.StuClass.DIST_ED (2288); SBCTC.StuClass.INSTRUCTION_MODE (2308) |
| fact.ENROLLMENT_PS_SBCTC_DETAIL.degree_or_certificate_seeking_student | SBCTC.Student.AWARD_SEEK (2320); SBCTC.Student.DEGREE_SEEK (2341) |
| fact.FINANCIAL_AID_AWARD_TERM_ENROLLMENT.aid_enrollment_status_code | Financial Aid.Unit Record.EnrollmentFall (2514); Financial Aid.Unit Record.EnrollmentWinter (2515); Financial Aid.Unit Record.EnrollmentSpring (2516); Financial Aid.Unit Record.EnrollmentSummer1 (2517); Financial Aid.Unit Record.EnrollmentSummer2 (2518) |
| fact.ADMISSION_FA_CBS_DETAIL.online_application | College Bound Scholarship Application.College Bound Scholarship Application.OnlineApplication (2616); College Bound Application Readiness.College Bound Application Readiness.IsOnlineApp (2637); College Bound Application Readiness.College Bound Application Readiness.OnlineApplication (2681) |
