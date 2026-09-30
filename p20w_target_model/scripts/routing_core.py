"""Routing engine.

A Src object describes one source extract (one or more inventory tables that
share a grain) and says, per model, where its keys land (``host``) and where
its ordinary attributes land (``attrs``). Explicit ``groups`` override the
global role handlers below. Every inventory row must resolve to at least one
target column in every model, or to an explicit, reasoned exclusion.
"""
import re
from common import snake, pascal, ceds, infer_type

MODELS = ("A", "B", "C")


class M:
    """One lineage mapping: inventory row -> target column."""
    __slots__ = ("model", "table", "column", "kind", "logic", "ceds_label", "dtype")

    def __init__(self, model, table, column, kind, logic="", ceds_label="", dtype=""):
        self.model, self.table, self.column = model, table, column
        self.kind, self.logic, self.ceds_label, self.dtype = kind, logic, ceds_label, dtype


class Src:
    def __init__(self, key, system, sector, grain, host, attrs, groups=(),
                 c_assign=None, ref_domain=None, a_person_col="PersonId",
                 a_org_cols=None, notes="", person_type=None, concepts=None):
        self.key, self.system, self.sector, self.grain = key, system, sector, grain
        self.c_concepts = concepts or {}
        self.host = expand(host)
        self.attrs = expand(attrs)
        self.groups = [(names, expand(t)) for names, t in groups]
        self.c_assign = c_assign or []
        self.ref_domain = ref_domain or snake(system)
        self.a_person_col = a_person_col
        self.a_org_cols = a_org_cols or {}
        self.notes = notes
        self.person_type = person_type or {}


def expand(d):
    """Allow keys like 'BC' or 'ABC' to set several models at once."""
    out = {}
    for k, v in (d or {}).items():
        for m in k:
            out[m] = v
    return out


# --------------------------------------------------------------------------
# CEDS vocabulary for column naming (labels verified against CEDS v14).
# Keys are lower-cased source element names.
# --------------------------------------------------------------------------
CONCEPTS = {
    "gradelevel": "Grade Level", "reportinggrade": "Grade Level When Assessed",
    "gradelevelwhencoursetaken": "Grade Level When Course Taken",
    "dateenrolledinschool": "Enrollment Entry Date", "dateexitedschool": "Enrollment Exit Date",
    "withdrawalcode": "Exit or Withdrawal Type", "cumulativegpa": "Grade Point Average Cumulative",
    "cumulativecreditsattempted": "Credits Attempted Cumulative",
    "cumulativecreditsearned": "Credits Earned Cumulative",
    "creditsattempted": "Number of Credits Attempted", "creditsearned": "Number of Credits Earned",
    "credit_hours_attempted": "Number of Credits Attempted", "credit_hours_earned": "Number of Credits Earned",
    "lettergrade": "Student Course Section Grade Earned",
    "gr": "Student Course Section Grade Earned",
    "coursetitle": "Course Title", "course_title": "Course Title", "courseid": "Course Identifier",
    "sectionid": "Course Section Identifier", "section": "Course Section Identifier",
    "absencedate": "Attendance Event Date", "incidentid": "Incident Identifier",
    "incidentdate": "Incident Date", "behaviorcode": "Incident Behavior",
    "behaviortypecode": "Incident Behavior", "weaponcode": "Weapon Type", "weapontypecode": "Weapon Type",
    "interventioncode": "Disciplinary Action Taken", "exclusionaryactiontypecode": "Disciplinary Action Taken",
    "interventiondate": "Disciplinary Action Start Date", "exclusionaryactiondate": "Disciplinary Action Start Date",
    "interventiondays": "Duration of Disciplinary Action",
    "exclusionaryactiondaysduration": "Duration of Disciplinary Action",
    "scalescore": "Assessment Result Score Value", "performancelevel": "Assessment Performance Level Label",
    "assessment_date": "Assessment Administration Start Date", "assessmentdate": "Assessment Administration Start Date",
    "subjectname": "Assessment Academic Subject", "lretypecode": "IDEA Educational Environment for School Age",
    "disabilitycode": "Primary Disability Type", "startdate": "Program Participation Start Date",
    "exitdate": "Program Participation Exit Date", "bilstartdate": "Program Participation Start Date",
    "bilexitdate": "Program Participation Exit Date", "homelesscode": "Homeless Primary Nighttime Residence",
    "homelessflag": "Homelessness Status", "militaryparentorguardiancd": "Military Connected Student Indicator",
    "freereducedmealsflag": "Eligibility Status for School Food Service Programs",
    "birthcountrycode": "Country of Birth Code", "primarylanguagecode": "ISO 639-2 Language Code",
    "ctecipcode": "Classification of Instructional Program Code", "cip": "Classification of Instructional Program Code",
    "program_cip": "Classification of Instructional Program Code", "cip_code": "Classification of Instructional Program Code",
    "ctecluserid": "Career Cluster", "cteclusterid": "Career Cluster", "apibcoursecode": "Advanced Placement Course Code",
    "courselevelcode": "Course Level Characteristic", "workbasedlearningactivitytypecode": "Work-based Learning Opportunity Type",
    "totalwageamount": "Quarterly Earnings", "naicscode": "Employment NAICS Code", "naics code": "Employment NAICS Code",
    "soc": "Standard Occupational Classification", "soc code": "Standard Occupational Classification",
    "award_seek": "Degree or Certificate Seeking Student", "degree_seek": "Degree or Certificate Seeking Student",
    "graduation_date": "Academic Award Date", "degree_title": "Academic Award Title",
    "academic_award_title": "Academic Award Title", "decision": "Admitted Student",
    "waitlist_date": "Wait Listed Student", "needamount": "Financial Need",
    "awardyear": "Financial Aid Year Designator", "dependencystatus": "Dependency Status",
    "first_generation": "First Generation College Student", "first_gen": "First Generation College Student",
    "familyincome": "Family Income", "annualfamilyincomeforeligibility": "Family Income",
    "personshouse": "Number of People in Household", "familysize": "Number of People in Household",
    "fte": "Full Time Equivalency", "assfte": "Full Time Equivalency", "certificatenumber": "Professional Certificate or License Number",
    "certificateeffectivedate": "Credential Award Start Date", "certificateexpiredate": "Credential Expiration Date",
    "endorsementeffectivedate": "Credential Award Start Date", "endorsementexpiredate": "Credential Expiration Date",
    "reportedexperience": "Years of Prior Teaching Experience", "prac_hours": "Supervised Clinical Experience Clock Hours",
    "numdayspresent": "Number of Days in Attendance", "latitude": "Latitude", "longitude": "Longitude",
    "latcod": "Latitude", "loncod": "Longitude", "resident_status": "Tuition Residency Type",
    "citz_stat": "United States Citizenship Status", "vet_benefits": "Military Veteran Status Indicator",
    "veteran": "Military Veteran Status Indicator", "enrollment_status": "Postsecondary Enrollment Status",
    "enrollment_begin_date": "Enrollment Entry Date", "enrollment_end_date": "Enrollment Exit Date",
    "degree_level": "Academic Award Level Conferred",
    "repeat_status": "Course Repeat Code", "instruction_mode": "Distance Education Course Enrollment",
    "dist_ed": "Distance Education Course Enrollment", "class_cap": "Course Section Maximum Capacity",
    "course_credits": "Credit Value", "credits_required": "Credit Value", "dept_div": "Course Department Name",
    "days": "Class Meeting Days", "strt_time": "Class Beginning Time", "end_time": "Class Ending Time",
    "starttime": "Class Beginning Time", "endtime": "Class Ending Time", "gpa_cum": "Grade Point Average Cumulative",
    "cum_credits_earned": "Credits Earned Cumulative",
    "datebatterycompleted": "Diploma or Credential Award Date",
}


def ceds_for(elem):
    label = CONCEPTS.get(elem.lower())
    hit = ceds(label) if label else None
    return re.sub(r"^Has ", "", hit[1]) if hit else ""


def colname(model, elem):
    """Default target column name for an ordinary attribute."""
    elem = re.sub(r"^WaK_", "Wakids", elem)
    if model == "A":
        return pascal(elem)
    return snake(elem)


# --------------------------------------------------------------------------
# Global identifier dictionaries
# --------------------------------------------------------------------------
# (element) -> (identifier type, person role). Keyed first by source key, then
# by bare element name.
PERSON_IDS = {
    "SSID": ("OSPI_SSID", "subject"), "WaK_SSID": ("OSPI_SSID", "subject"),
    "WaK_StateStudentID": ("OSPI_SSID", "subject"), "ELMS_SSID": ("OSPI_SSID", "subject"),
    "K12_state_ID": ("OSPI_SSID", "subject"), "ApplicationSSID": ("OSPI_SSID", "subject"),
    "ApplicationSSId": ("OSPI_SSID", "subject"), "LastReportedSSID": ("OSPI_SSID", "subject"),
    "LastReportedSSId": ("OSPI_SSID", "subject"),
    "DistrictStudentID": ("DISTRICT_STUDENT_ID", "subject"), "DistrictStudentCode": ("DISTRICT_STUDENT_ID", "subject"),
    "District Student Id": ("DISTRICT_STUDENT_ID", "subject"), "WaK_DistrictStudentID": ("DISTRICT_STUDENT_ID", "subject"),
    "WaK_ChildID": ("WAKIDS_CHILD_ID", "subject"),
    "Childid": ("ELMS_CHILD_ID", "subject"), "ChildId": ("ELMS_CHILD_ID", "subject"),
    "FamilyMemberId": ("ELMS_FAMILY_MEMBER_ID", "subject"), "ChildKey": ("HIST_ECEAP_CHILD_KEY", "subject"),
    "UniqueSRIdentifer": ("SSPS_SR_ID", "subject"), "CaseNumber": ("SSPS_CASE_NUMBER", "household"),
    "StudentID": ("TSGOLD_STUDENT_ID", "subject"), "SourceChildID": ("TSGOLD_SOURCE_CHILD_ID", "subject"),
    "ChildID": ("TSGOLD_CHILD_ID", "subject"),
    "DW_KEY": ("SBCTC_DW_KEY", "subject"), "EMPLID": ("CTCLINK_EMPLID", "subject"), "SID": ("SBCTC_SID", "subject"),
    "student_institution": ("PCHEES_STUDENT_ID", "subject"), "student_OFM": ("PCHEES_STUDENT_ID", "subject"),
    "stu_id": ("EPP_STUDENT_ID", "subject"), "applicant_id": ("EPP_APPLICANT_ID", "subject"),
    "TokenID": ("ERDC_MDM_TOKEN_ID", "subject"),
    "WSACSampleId": ("WSAC_SAMPLE_ID", "subject"), "WSACStudentIdNumber": ("WSAC_STUDENT_ID", "subject"),
    "Apprentice Id": ("LNI_APPRENTICE_ID", "subject"),
    "PersonnelID": ("OSPI_PERSONNEL_ID", "subject"), "PersonnelId": ("OSPI_PERSONNEL_ID", "subject"),
    "EducatorID": ("OSPI_EDUCATOR_ID", "subject"), "Cert": ("OSPI_CERTIFICATE_NUMBER", "subject"),
    "StaffID": ("DISTRICT_STAFF_ID", "staff"), "CertificationNumber": ("OSPI_CERTIFICATE_NUMBER", "staff"),
    "WaK_TeacherID": ("WAKIDS_TEACHER_ID", "staff"), "INSTR_ID": ("SBCTC_INSTRUCTOR_ID", "staff"),
    "lead_mentor_cert": ("OSPI_CERTIFICATE_NUMBER", "mentor"),
}
# Source-specific overrides where the same bare name means something else.
PERSON_IDS_BY_SRC = {
    ("FinancialAid.UnitRecord", "StudentID"): ("INSTITUTION_STUDENT_ID", "subject"),
    ("OSPI.Ecert", "CertificateNumber"): ("OSPI_CERTIFICATE_NUMBER", "subject"),
    ("OSPI.RetentionMobility", "CertificateNumber"): ("OSPI_CERTIFICATE_NUMBER", "subject"),
    ("ESIT.child", "ChildId"): ("ESIT_CHILD_ID", "subject"),
}


def person_id_info(src_key, elem):
    return PERSON_IDS_BY_SRC.get((src_key, elem)) or PERSON_IDS.get(elem)


# PII -> identity observation column (snake, CEDS-aligned where possible)
PII_PATTERNS = [
    (r"^(legal)?first_?name$|^studentfirstname$|^child_f_name$|^wak_childfname$|^namefirst$|^first name$|^employeefirstname$|^stafffirstname$", "first_name"),
    (r"^namefirst_alternate$", "alternate_first_name"),
    (r"^(legal)?middle_?name$|^studentmiddlename$|^studentmiddleinitial$|^child_mi$|^wak_childmi$|^namemiddle$|^middle name$|^middleinitial$|^staffmiddlename$", "middle_name"),
    (r"^(legal)?last_?name$|^studentlastname$|^child_l_name$|^wak_childlname$|^namelast$|^last name$|^stafflastname$", "last_or_surname"),
    (r"^namelast_alternate$", "alternate_last_or_surname"),
    (r"^employeename$", "employee_full_name_as_reported"),
    (r"^srname$", "full_name_as_reported"),
    (r"^preferredfirstname$", "preferred_first_name"), (r"^preferred middle name$", "preferred_middle_name"),
    (r"^preferredlastname$", "preferred_last_or_surname"),
    (r"^(name_)?suffix$", "generation_code_or_suffix"),
    (r"^(birth_?date|birthdate|dob|date_of_birth|srbirthdate|studentbirthdate|wak_birthdate|staffbirthdate|birth date)$", "birthdate"),
    (r"^birthmonth$", "birth_month_as_reported"), (r"^birthday$", "birth_day_as_reported"),
    (r"^birthyear$", "birth_year_as_reported"), (r"^birthym$", "birth_year_month"),
    (r"^(ssn|applicationssn|updatedssn)$", "social_security_number"),
    (r"^(ssn4|ssnlastfourchars)$", "social_security_number_last_four"),
    (r"^(studentphone|phone data)$", "telephone_number"), (r"^guardianhomephone$", "guardian_telephone_number"),
    (r"^guardianlastname$", "guardian_last_or_surname"), (r"^email addr$", "electronic_mail_address"),
    (r"^address line1$", "address_street_number_and_name"), (r"^address line2$", "address_apartment_room_or_suite_number"),
    (r"^instr_name$", "full_name_as_reported"), (r"^lead_mentor_contact$", "mentor_contact_as_reported"),
]
PII_EXEMPT_SRC = {"UIEmployer.Employer"}  # employer contact fields are org attributes, not person PII


def pii_column(src_key, r):
    if src_key in PII_EXEMPT_SRC:
        return None
    e = r["elem"].lower()
    if src_key == "OSPI.S275" and e == "ssn":
        return "social_security_number_last_four"
    for pat, col in PII_PATTERNS:
        if re.match(pat, e):
            return col
    return None


# Organization identifiers: element -> (org type, identifier type, role)
ORG_IDS = {
    "DistrictCode": ("LEA", "OSPI_CCDDD", "lea"), "DistCode": ("LEA", "OSPI_CCDDD", "lea"),
    "Codist": ("LEA", "OSPI_CCDDD", "lea"), "WaK_districtcode": ("LEA", "OSPI_CCDDD", "lea"),
    "CCDDD": ("LEA", "OSPI_CCDDD", "lea"), "DISTRICT_ID": ("LEA", "OSPI_CCDDD", "lea"),
    "dist_code": ("LEA", "OSPI_CCDDD", "clinical_lea"),
    "DistrictOrgID": ("LEA", "OSPI_ORG_ID", "lea"), "DistrictOrganizationId": ("LEA", "OSPI_ORG_ID", "lea"),
    "OrganizationId": ("LEA", "OSPI_ORG_ID", "lea"), "Serving District Id": ("LEA", "OSPI_ORG_ID", "lea"),
    "ResidentDistrictCode": ("LEA", "OSPI_CCDDD", "resident_lea"),
    "ResidentDistrictOrgID": ("LEA", "OSPI_ORG_ID", "resident_lea"), "Resident District Id": ("LEA", "OSPI_ORG_ID", "resident_lea"),
    "NCESDIST": ("LEA", "NCES_LEA_ID", "lea"),
    "SchoolCode": ("K12_SCHOOL", "OSPI_SCHOOL_CODE", "school"), "SchCode": ("K12_SCHOOL", "OSPI_SCHOOL_CODE", "school"),
    "BuildingCode": ("K12_SCHOOL", "OSPI_SCHOOL_CODE", "school"), "BLDG": ("K12_SCHOOL", "OSPI_SCHOOL_CODE", "school"),
    "SCHOOL_ID": ("K12_SCHOOL", "OSPI_SCHOOL_CODE", "school"), "WaK_schoolcode": ("K12_SCHOOL", "OSPI_SCHOOL_CODE", "school"),
    "bldg_code": ("K12_SCHOOL", "OSPI_SCHOOL_CODE", "clinical_school"),
    "SchoolOrgID": ("K12_SCHOOL", "OSPI_ORG_ID", "school"), "SchoolOrganizationId": ("K12_SCHOOL", "OSPI_ORG_ID", "school"),
    "Serving School Id": ("K12_SCHOOL", "OSPI_ORG_ID", "school"),
    "LocationID": ("K12_SCHOOL", "DISTRICT_SIS_LOCATION_ID", "school"), "LocationId": ("K12_SCHOOL", "DISTRICT_SIS_LOCATION_ID", "school"),
    "NCESSCH": ("K12_SCHOOL", "NCES_SCHOOL_ID", "school"),
    "ESD_ID": ("ESD", "OSPI_ESD_CODE", "esd"),
    "ApprovedOnlineProviderCode": ("SERVICE_PROVIDER", "CEDARS_ONLINE_PROVIDER_CODE", "online_provider"),
    "ApprovedOnlineProviderId": ("SERVICE_PROVIDER", "CEDARS_ONLINE_PROVIDER_ID", "online_provider"),
    "ApprovedOnlineProgramCode": ("SERVICE_PROVIDER", "CEDARS_ONLINE_PROGRAM_CODE", "online_program"),
    "ApprovedOnlineProgramId": ("SERVICE_PROVIDER", "CEDARS_ONLINE_PROGRAM_ID", "online_program"),
    "ApprovedOnlineProgramListOrder": ("SERVICE_PROVIDER", "CEDARS_ONLINE_PROGRAM_LIST_ORDER", "online_program"),
    "ApprovedOnlinePGMResidentDistOrgId": ("LEA", "OSPI_ORG_ID", "online_program_resident_lea"),
    "ApprovedOnlinePGMResidentDistOrg": ("LEA", "OSPI_ORG_ID", "online_program_resident_lea"),
    "NonPublicAgencyCode": ("SERVICE_PROVIDER", "CEDARS_NONPUBLIC_AGENCY_CODE", "nonpublic_agency"),
    "NonPublicAgencyId": ("SERVICE_PROVIDER", "CEDARS_NONPUBLIC_AGENCY_ID", "nonpublic_agency"),
    "Provider Code": ("SERVICE_PROVIDER", "OPEN_DOORS_PROVIDER_CODE", "reengagement_provider"),
    "CertificateRecommendingAgencyCode": ("CREDENTIAL_ORG", "OSPI_RECOMMENDING_AGENCY_CODE", "recommending_org"),
    "CertificateIssueSourceCode": ("CREDENTIAL_ORG", "OSPI_ISSUE_SOURCE_CODE", "issue_source_org"),
    "EndorsementIssueSourceCode": ("CREDENTIAL_ORG", "OSPI_ISSUE_SOURCE_CODE", "issue_source_org"),
    # Early learning
    "SiteOrganizationID": ("EL_PROVIDER", "ELMS_ORGANIZATION_ID", "el_site"),
    "SiteID": ("EL_PROVIDER", "ELMS_ORGANIZATION_ID", "el_site"),
    "ContractorID": ("EL_PROVIDER", "ELMS_ORGANIZATION_ID", "el_contractor"),
    "SubcontractorID": ("EL_PROVIDER", "ELMS_ORGANIZATION_ID", "el_subcontractor"),
    "OrganizationRelationshipId": ("EL_PROVIDER", "ELMS_ORGANIZATION_RELATIONSHIP_ID", "el_site_relationship"),
    "ProviderNumber": ("EL_PROVIDER", "DCYF_LICENSED_PROVIDER_NUMBER", "el_site"),
    "providernumber": ("EL_PROVIDER", "SSPS_PROVIDER_NUMBER", "el_provider"),
    "SchoolDistrictCode": ("LEA", "OSPI_CCDDD", "resident_lea"), "IEPSchoolDistrictCode": ("LEA", "OSPI_CCDDD", "iep_lea"),
    "IEPSchoolDistrictId": ("LEA", "ELMS_SCHOOL_DISTRICT_ID", "iep_lea"), "SchoolDistrictId": ("LEA", "ELMS_SCHOOL_DISTRICT_ID", "site_lea"),
    "CountyDistrictCode": ("LEA", "OSPI_CCDDD", "site_lea"), "ESDId": ("ESD", "ELMS_ESD_ID", "site_esd"),
    "ESITOrganizationId": ("EL_PROVIDER", "ESIT_ORGANIZATION_ID", "el_provider"),
    "ELMS_Contractor_ID": ("EL_PROVIDER", "ELMS_ORGANIZATION_ID", "el_contractor"),
    "ECEAP_Contractor": ("EL_PROVIDER", "ECEAP_CONTRACTOR_CODE", "el_contractor"),
    "SiteCodeAlpha": ("EL_PROVIDER", "HIST_ECEAP_SITE_CODE", "el_site"),
    # Postsecondary
    "COLLEGE": ("PS_INSTITUTION", "SBCTC_COLLEGE_CODE", "ps_institution"),
    "INSTITUTION": ("PS_INSTITUTION", "CTCLINK_INSTITUTION_CODE", "ps_institution"),
    "DIST": ("PS_COLLEGE_DISTRICT", "SBCTC_DISTRICT_CODE", "ps_college_district"),
    "DOC_SITE": ("PS_CAMPUS_SITE", "SBCTC_DOC_SITE_CODE", "doc_site"),
    "PREV_COL_1": ("PS_INSTITUTION", "IPEDS_UNITID", "previous_ps_institution"),
    "HI_SCHL": ("K12_SCHOOL", "SBCTC_HIGH_SCHOOL_CODE", "last_high_school"),
    "institution": ("PS_INSTITUTION", "CEEB_CODE", "ps_institution"),
    "inst_code": ("PS_INSTITUTION", "CEEB_CODE", "ps_institution"),
    "campus": ("PS_CAMPUS_SITE", "PCHEES_CAMPUS_ID", "ps_campus"),
    "course_campus": ("PS_CAMPUS_SITE", "EPP_CAMPUS_NAME", "ps_campus"),
    "high_school": ("K12_SCHOOL", "CEEB_CODE", "last_high_school"),
    "previous_institution": ("PS_INSTITUTION", "CEEB_CODE", "previous_ps_institution"),
    "College_Code_Branch": ("PS_INSTITUTION", "OPEID_BRANCH", "ps_institution"),
    "Parent_College_Code": ("PS_INSTITUTION", "OPEID_BRANCH", "parent_ps_institution"),
    "High_School_Code": ("K12_SCHOOL", "ACT_CEEB_HS_CODE", "high_school"),
    "WSACInstitutionCode": ("PS_INSTITUTION", "WSAC_INSTITUTION_CODE", "ps_institution"),
    "ApplicationSchoolCode": ("K12_SCHOOL", "OSPI_SCHOOL_CODE", "application_school"),
    "LastReportedSchoolCode": ("K12_SCHOOL", "OSPI_SCHOOL_CODE", "last_reported_school"),
    "LastReportedSchCode": ("K12_SCHOOL", "OSPI_SCHOOL_CODE", "last_reported_school"),
    "SchoolId": ("K12_SCHOOL", "OSPI_ORG_ID", "application_school"),
    "ApplicationDistrictCode": ("LEA", "OSPI_CCDDD", "application_lea"),
    "LastReportedDistrictCode": ("LEA", "OSPI_CCDDD", "last_reported_lea"),
    "ApplicationESDNumber": ("ESD", "OSPI_ESD_CODE", "application_esd"),
    # Workforce / apprenticeship
    "UI Account number": ("EMPLOYER", "ESD_UI_ACCOUNT_NUMBER", "employer"),
    "Reporting Unit Number (RUN)": ("EMPLOYER_REPORTING_UNIT", "ESD_RUN", "employer_reporting_unit"),
    "EI Number": ("EMPLOYER", "FEIN", "employer"), "FEIN": ("EMPLOYER", "FEIN", "employer"),
    "EmployerAccountNumber": ("EMPLOYER", "ESD_UI_ACCOUNT_NUMBER", "employer"),
    "Program Id": ("APPRENTICESHIP_SPONSOR", "LNI_PROGRAM_ID", "apprenticeship_sponsor"),
}
ORG_IDS_BY_SRC = {
    ("OSPI.S275", "OrganizationId"): ("LEA", "OSPI_ORG_ID", "lea"),
    ("ELMS.Organization", "SiteOrganizationTypeID"): None,
}

ORG_NAMES = {
    "DistrictName": ("LEA", "lea"), "DistName": ("LEA", "lea"), "District": ("LEA", "lea"),
    "DISTRICT_NAME": ("LEA", "lea"), "WaK_DistrictName": ("LEA", "lea"), "Serving District Name": ("LEA", "lea"),
    "ResidentDistrictName": ("LEA", "resident_lea"), "Resident District Name": ("LEA", "resident_lea"),
    "SchoolName": ("K12_SCHOOL", "school"), "SchName": ("K12_SCHOOL", "school"), "School": ("K12_SCHOOL", "school"),
    "SCHOOL_NAME": ("K12_SCHOOL", "school"), "WaK_SchoolName": ("K12_SCHOOL", "school"),
    "Serving School Name": ("K12_SCHOOL", "school"), "ESD_NAME": ("ESD", "esd"),
    "ApprovedOnlineProviderName": ("SERVICE_PROVIDER", "online_provider"),
    "ApprovedOnlineProgramName": ("SERVICE_PROVIDER", "online_program"),
    "NonPublicAgency": ("SERVICE_PROVIDER", "nonpublic_agency"),
    "CertificateRecommendingAgencyName": ("CREDENTIAL_ORG", "recommending_org"),
    "SiteName": ("EL_PROVIDER", "el_site"), "Site": ("EL_PROVIDER", "el_site"), "SIteName": ("EL_PROVIDER", "el_site"),
    "Contractor": ("EL_PROVIDER", "el_contractor"), "ContractorName": ("EL_PROVIDER", "el_contractor"),
    "Subcontractor": ("EL_PROVIDER", "el_subcontractor"), "ProviderName": ("EL_PROVIDER", "el_provider"),
    "SchoolDistrictName": ("LEA", "site_lea"), "TITLE": ("PS_INSTITUTION", "ps_institution"),
    "College_Name": ("PS_INSTITUTION", "ps_institution"), "Parent_College_Name": ("PS_INSTITUTION", "parent_ps_institution"),
    "ApplicationSchoolName": ("K12_SCHOOL", "application_school"), "LastReportedSchoolName": ("K12_SCHOOL", "last_reported_school"),
    "ApplicationDistrictName": ("LEA", "application_lea"), "LastReportedDistrictName": ("LEA", "last_reported_lea"),
    "Legal/Corporate Name": ("EMPLOYER", "employer"), "Trade Name/DBA": ("EMPLOYER", "employer"),
    "Program Name": ("APPRENTICESHIP_SPONSOR", "apprenticeship_sponsor"),
}

# Satellite natural-identifier columns by (org type, identifier type)
ORG_SAT = {
    "LEA": ("ORG_LEA", "DimLeas"), "K12_SCHOOL": ("ORG_K12_SCHOOL", "DimK12Schools"), "ESD": ("ORG_ESD", "DimIeus"),
    "SERVICE_PROVIDER": ("ORG_SERVICE_PROVIDER", "DimOrganizations"), "CREDENTIAL_ORG": ("ORG_CREDENTIAL_ISSUER", "DimCredentialIssuers"),
    "EL_PROVIDER": ("ORG_EL_PROVIDER", "DimEarlyLearningOrganizations"),
    "PS_INSTITUTION": ("ORG_PS_INSTITUTION", "DimPsInstitutions"), "PS_COLLEGE_DISTRICT": ("ORG_PS_COLLEGE_DISTRICT", "DimOrganizations"),
    "PS_CAMPUS_SITE": ("ORG_PS_CAMPUS_SITE", "DimOrganizations"), "EMPLOYER": ("ORG_EMPLOYER", "DimEmployers"),
    "EMPLOYER_REPORTING_UNIT": ("ORG_EMPLOYER_REPORTING_UNIT", "DimEmployers"),
    "APPRENTICESHIP_SPONSOR": ("ORG_APPRENTICESHIP_SPONSOR", "DimCredentialIssuers"),
}
A_ORG_NAME_COL = {
    "DimLeas": "LeaOrganizationName", "DimK12Schools": "NameOfInstitution", "DimIeus": "IeuOrganizationName",
    "DimOrganizations": "OrganizationName", "DimCredentialIssuers": "CredentialIssuerOrganizationName",
    "DimEarlyLearningOrganizations": "OrganizationName", "DimPsInstitutions": "NameOfInstitution",
    "DimEmployers": "EmployerOrganizationName",
}
A_ORG_ID_COL = {
    ("LEA", "OSPI_CCDDD"): "LeaIdentifierSea", ("LEA", "NCES_LEA_ID"): "LeaIdentifierNces",
    ("K12_SCHOOL", "OSPI_SCHOOL_CODE"): "SchoolIdentifierSea", ("K12_SCHOOL", "NCES_SCHOOL_ID"): "SchoolIdentifierNces",
    ("K12_SCHOOL", "CEEB_CODE"): "SchoolIdentifierAct", ("K12_SCHOOL", "ACT_CEEB_HS_CODE"): "SchoolIdentifierAct",
    ("ESD", "OSPI_ESD_CODE"): "IeuOrganizationIdentifierSea", ("PS_INSTITUTION", "IPEDS_UNITID"): "IPEDSIdentifier",
    ("PS_INSTITUTION", "OPEID_BRANCH"): "Opeid", ("EMPLOYER", "ESD_UI_ACCOUNT_NUMBER"): "EmployerOrganizationIdentifierSea",
}

PERIOD_ELEMS = {
    "SchoolYear": "SCHOOL_YEAR", "School_Year": "SCHOOL_YEAR", "SCHOOL_YEAR": "SCHOOL_YEAR", "School Year": "SCHOOL_YEAR",
    "WaK_SchoolYear": "SCHOOL_YEAR", "SchoolYearCode": "SCHOOL_YEAR", "SchoolYearID": "ELMS_SCHOOL_YEAR_ID",
    "SchoolYearId": "ELMS_SCHOOL_YEAR_ID", "ProgramYear": "PROGRAM_YEAR", "season": "ASSESSMENT_SEASON",
    "year": "YEAR", "academic_year": "ACADEMIC_YEAR", "inst_enroll_year": "ACADEMIC_YEAR", "inst_enroll_term": "TERM",
    "term": "TERM", "YEAR": "SBCTC_YEAR", "QUARTER": "SBCTC_QUARTER", "YRQ": "SBCTC_YRQ", "STRM": "CTCLINK_STRM",
    "LEGACY_YEAR": "SBCTC_YEAR", "LEGACY_QUARTER": "SBCTC_QUARTER", "LEGACY_YRQ": "SBCTC_YRQ",
    "AwardYear": "AWARD_YEAR", "YearQuarter": "CALENDAR_YEAR_QUARTER", "Year": "CALENDAR_YEAR", "Quarter": "CALENDAR_QUARTER",
    "MonthOfService": "CALENDAR_MONTH", "OrganizationYear": "ACADEMIC_YEAR", "ApplicationAcademicYear": "SCHOOL_YEAR",
}
PERIOD_BY_SRC_SKIP = {("TSGold.Stacked", "SchoolYear")}  # handled explicitly

AUDIT = {
    "SubmitDate": "source_submit_date", "ExtractDate": "source_extract_date", "record_number": "source_record_number",
    "RecordID": "source_record_id", "SasRecordID": "source_sas_record_id", "WSACRecordNumber": "source_record_number",
    "QTR_ADDED": "source_yrq_added", "DataAsOf": "source_data_as_of", "SourceDataset": "source_dataset_name",
    "FinalOrPrelim": "source_release_type", "OSPIExtractDate": "source_ospi_extract_date",
}

RACE_ETH_PATTERNS = [
    r"^(race|racecode|racetypeid|racedescription|raceorEth|raceoreth|fedethtyperollup|racestartdate|raceenddate|racecollectionmethod.*)$",
    r"^(ethcode|ethdesc|ethnicitytypeid|ethstartdate|ethenddate|ethnicitycollectionmethod.*|ethnicity|ethniccode|hispanic)$",
    r"^(race_[1-5]|hispanic_[1-3]|race_code|race_ethnic_code|race_ethnic_ind2?|census_race_cd2?|census_hisp_cd|eth_orig|hu_stu_of_color|stu_of_color)$",
    r"^(africanamerican|asian|caucasian|eastindian|hispanic|nativealaskan|nativeamerican|nativeamericanalaskan|pacificisland|white|ethnicother|raceother)$",
    r"^(hispanicorigin|raceamericanindian|raceasian|raceblack|racepacificislander|racewhite|raceother)$",
    r"^(federalethracerollupcode|federalethracerollupname|isaian|raceethnicity|race/ethnicity|wak_ethnicity[12]|wak_racefederalrollup|wak_federalrollup|wak_federalraceethnicity|cedarsraceethnicity|lastreportedospiraceethnicity)$",
]


def is_race_eth(src_key, elem):
    e = elem.lower()
    return any(re.match(p, e) for p in RACE_ETH_PATTERNS)


def race_eth_column(elem):
    e = elem.lower()
    if re.search(r"(start|end)date", e):
        return "source_status_" + ("start" if "start" in e else "end") + "_date"
    if "collectionmethod" in e:
        return "collection_method_" + ("description" if not re.search(r"(id|code)$", e) else ("code_id" if e.endswith("id") else "code"))
    if re.search(r"rollup|federal|raceethnicity|race_ethnic_code|isaian|stu_of_color", e):
        return "reported_race_ethnicity_rollup"
    if re.search(r"(desc|description|name)$", e):
        return "source_race_ethnicity_description"
    if re.search(r"typeid$", e):
        return "source_race_ethnicity_type_id"
    if e in ("raceoreth",):
        return "race_or_ethnicity_record_type"
    if re.search(r"_ind2?$", e):
        return "source_race_ethnicity_code"
    return "source_race_ethnicity_code"


DESC_RE = re.compile(r"^(?:Short |Long )?[Dd]escriptions? (?:associated with|of) (?:the )?([A-Za-z0-9_]+)")
SURR_RE = re.compile(r"^ID (?:values?|value) (?:of|associated with|for) (?:the )?([A-Za-z0-9_]+)|^ID associated with the ([A-Za-z0-9_]+)")
FLAG_RE = re.compile(r"^Flag associated with ([A-Za-z0-9_]+)|^IF\(([A-Za-z0-9_]+)\)")
DESIG_RE = re.compile(r"^Derived from (?:Full)?\s?Course ?Designation", re.I)


def code_concept(code_elem):
    c = re.sub(r"(Code|CD|Cd|Id|ID)$", "", code_elem)
    return c or code_elem
