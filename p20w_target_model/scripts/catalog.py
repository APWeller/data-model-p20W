"""Table-level metadata (type, grain, key, SCD treatment, family) and structural
columns that do not come from an inventory row (surrogate keys, conformed
attributes computed during mastering, SCD housekeeping)."""
import re

# --------------------------------------------------------------------------
# Explicit table metadata. Anything not listed is classified by naming rules.
# (type, family, grain, primary key, SCD treatment, description)
# --------------------------------------------------------------------------
C = {
    "identity.PERSON_XWALK": ("IDENTITY_XWALK", "", "One row per source system x identifier type x source identifier x effective period", "person_xwalk_id", "Effective-dated (Type 2 semantics on the link; re-matches close the old row)", "Maps every source person identifier to the durable statewide person_id"),
    "identity.PERSON_PII_OBSERVATION": ("IDENTITY", "", "One row per source record observation of identifying attributes", "pii_observation_id", "Append-only observations (no overwrite); consumed by matching", "Restricted identity zone; never joined by analytic users"),
    "identity.NSC_STUDENTTRACKER_REQUEST_RESULT": ("IDENTITY", "", "One row per NSC return record (request metadata)", "nsc_record_id", "Append-only", "Admin-only NSC request/return metadata"),
    "conformed.PERSON": ("DIMENSION", "", "One row per durable person per version", "person_sk (person_id + effective_start_date)", "Type 2 (sex, birth year/month, race-ethnicity roll-up, country of birth recomputed by survivorship)", "Single conformed person dimension across all sectors"),
    "conformed.PERSON_RACE_ETHNICITY": ("DIMENSION_BRIDGE", "", "One row per person x source system x reported period x race/ethnicity value", "person_race_ethnicity_id", "Type 2 by observation period (source start/end dates); history never overwritten", "Multi-valued race/ethnicity observations"),
    "conformed.PERSON_LANGUAGE": ("DIMENSION_BRIDGE", "", "One row per person x source x period x language use type", "person_language_id", "Type 2 by observation period", "Multi-valued language observations"),
    "conformed.ORGANIZATION": ("DIMENSION", "", "One row per durable org_id per version", "org_sk (org_id + effective_start_date)", "Type 2 (name, operational status, type); renames are attribute changes, NOT lineage events", "Single conformed organization core"),
    "conformed.ORGANIZATION_XWALK": ("ORG_XWALK", "", "One row per source system x identifier type x source identifier x effective period", "org_xwalk_id", "Effective-dated; handles code reuse (same code, different org in different periods)", "Source org identifiers -> durable org_id"),
    "conformed.ORGANIZATION_LINEAGE": ("ORG_LINEAGE", "", "One row per lineage event x predecessor x successor", "lineage_event_id", "Append-only event log (events are facts about orgs, not attribute versions)", "Mergers, splits, closures, recodes, successions"),
    "conformed.ORGANIZATION_LINEAGE_CLOSURE": ("ORG_LINEAGE", "", "One row per org_id x ancestor/descendant org_id reachable through lineage events", "org_id + related_org_id", "Rebuilt from ORGANIZATION_LINEAGE on each load (Type 1)", "Transitive closure used to roll historical facts to current successors"),
    "conformed.ACADEMIC_PERIOD": ("DIMENSION", "", "One row per conformed period (school year, term/quarter, award year, program year, calendar quarter, month, registration spell)", "academic_period_id", "Type 1 (static calendar)", "Conformed periods across sectors"),
    "conformed.ACADEMIC_PERIOD_XWALK": ("PERIOD_XWALK", "", "One row per source system x period code type x source period code", "source_system + period_code_type + source_period_code", "Type 1", "Source period codes (YRQ, STRM, YYYYQ, SchoolYearId) -> academic_period_id"),
    "conformed.ACADEMIC_SESSION": ("DIMENSION", "", "One row per organization (institution/campus/school) x academic period", "org_id + academic_period_id", "Type 1 (corrections overwrite)", "Org-specific session/term calendar"),
    "conformed.DIM_DATE": ("DIMENSION", "", "One row per calendar date", "date_key", "Type 0", "Date dimension"),
    "conformed.ASSESSMENT_INSTRUMENT": ("DEFINITION", "Assessment", "One row per assessment instrument x subject/domain x version", "assessment_instrument_id", "Type 2 (instrument metadata versions)", "Assessment definitions referenced by fact.ASSESSMENT"),
    "conformed.COURSE": ("DEFINITION", "CourseSection (tenth: COURSE)", "One row per offering organization x period x course identifier", "course_id", "Periodic definition (period in key); corrections Type 1", "Course catalog level (coarser than section)"),
    "conformed.COURSE_SECTION": ("DEFINITION", "CourseSection", "One row per offering organization x period x course x section", "course_section_id", "Periodic definition (period in key); corrections Type 1", "Conformed course section offering"),
    "conformed.PROGRAM": ("DEFINITION", "Program", "One row per offering organization x program identifier x period of definition", "program_id", "Type 2 on program attributes (award level, credits, CIP)", "Conformed program definition"),
    "fact.ABSENCE": ("FACT", "Absence", "One row per person x school x absence date x absence code", "absence_id", "n/a (fact)", "Single-sector conformed family table"),
    "fact.DISCIPLINE": ("FACT", "Discipline", "One row per person x LEA x incident x disciplinary/exclusionary action", "discipline_id", "n/a (fact)", "Single-sector conformed family table (legacy + current files)"),
    "fact.WAGE": ("FACT", "Wage", "One row per person x employer UI account x calendar quarter x wage type", "wage_id", "n/a (fact)", "Single-sector conformed family table"),
    "fact.ASSESSMENT": ("FACT", "Assessment", "One row per person x assessment instrument x administration x subject/domain (plus ALL_DOMAINS summary rows for multi-domain checkpoints)", "assessment_result_id", "n/a (fact)", "Conformed assessment results across EL, K-12, PS"),
    "fact.ACHIEVEMENT": ("FACT", "Achievement", "One row per person x credential type x award date x awarding organization", "achievement_id", "n/a (fact)", "Terminal completion/credential events only"),
    "fact.ADMISSION": ("FACT", "Admission", "One row per person x organization x entry period x program (application/admission decision)", "admission_id", "n/a (fact)", "Admission / application grain (4-year, EPP, EL eligibility, College Bound pledge)"),
    "fact.ENROLLMENT": ("FACT", "Enrollment", "One row per person x organization x reporting period (school year / term / program year / month / registration spell) x enrollment segment", "enrollment_id", "n/a (fact)", "Periodic enrollment across EL, K-12, PS, Apprenticeship"),
    "fact.PROGRAM_PARTICIPATION": ("BRIDGE_FACT", "Program", "One row per person x program x organization x participation start (or period)", "program_participation_id", "n/a (fact)", "Person-level participation bridge to conformed PROGRAM"),
    "fact.STUDENT_COURSE_RECORD": ("BRIDGE_FACT", "CourseSection", "One row per person x organization x period x course (x section when known) x record type (SCHEDULE / TRANSCRIPT / NONTRADITIONAL / REGISTRATION)", "student_course_record_id", "n/a (fact)", "Person-level course record bridge to COURSE_SECTION / COURSE"),
    "fact.STUDENT_COURSE_RECORD_FUNDING": ("CHILD_FACT", "CourseSection", "One row per student course record x funding source", "student_course_record_id + funding_source_code", "n/a (fact)", "Funding split grain (SBCTC StuClass) / single funding row (PCHEES)"),
    "fact.FINANCIAL_AID_AWARD": ("FACT", "(tenth) FINANCIAL_AID_AWARD", "One row per person x institution x award year", "financial_aid_award_id", "n/a (fact)", "Annual aid package with explicit amount column per aid program"),
    "fact.FINANCIAL_AID_AWARD_TERM_ENROLLMENT": ("BRIDGE_FACT", "(tenth) FINANCIAL_AID_AWARD", "One row per aid award x term with an aid enrollment status", "financial_aid_award_id + academic_period_id", "n/a (fact)", "Ties the annual award to the term ENROLLMENT rows it funds"),
    "fact.EDUCATOR_CREDENTIAL": ("FACT", "(additional) EDUCATOR_CREDENTIAL", "One row per person x certificate x endorsement", "educator_credential_id", "Current-state license record; status/expiry changes tracked Type 2", "Professional educator certification"),
    "fact.STAFF_ASSIGNMENT": ("FACT", "(additional) STAFF_ASSIGNMENT", "One row per person x LEA x school year x assignment line", "staff_assignment_id", "n/a (fact)", "S-275 assignment lines"),
    "fact.STAFF_EMPLOYMENT_YEAR": ("FACT", "(additional) STAFF_EMPLOYMENT_YEAR", "One row per person x LEA x school year", "staff_employment_year_id", "n/a (fact)", "S-275 person-year contract/salary/degree/experience"),
    "fact.STAFF_SECTION_ASSIGNMENT": ("BRIDGE_FACT", "(additional) STAFF_SECTION_ASSIGNMENT", "One row per person x course section x staff role x instruction start", "staff_section_assignment_id", "n/a (fact)", "Teachers/instructors assigned to sections (K-12 and CTC)"),
    "fact.EDUCATOR_YEAR_STATUS": ("FACT", "(additional) EDUCATOR_YEAR_STATUS", "One row per person x school x school year", "educator_year_status_id", "n/a (fact)", "Derived retention/mobility statuses"),
    "fact.EMPLOYER_QUARTER_PROFILE": ("PERIODIC_SNAPSHOT", "(additional) EMPLOYER_QUARTER_PROFILE", "One row per employer reporting unit x calendar quarter", "employer_reporting_unit_org_id + academic_period_id", "n/a (periodic snapshot)", "QCEW establishment employment and wages"),
    "fact.SCHOOL_YEAR_PROFILE": ("PERIODIC_SNAPSHOT", "(additional) SCHOOL_YEAR_PROFILE", "One row per school x school year", "school_org_id + academic_period_id", "n/a (periodic snapshot)", "Published Report Card aggregates"),
    "fact.DISCIPLINE_SECONDARY_BEHAVIOR": ("CHILD_FACT", "Discipline", "One row per discipline row x secondary behavior code", "discipline_id + incident_behavior_code", "n/a", "Multi-valued secondary behaviors"),
    "fact.ENROLLMENT_EL_SUBSIDY_SERVICE_LINE": ("CHILD_FACT", "Enrollment", "One row per subsidy enrollment month x authorization x authorization line", "enrollment_id + auth_number + auth_line", "n/a", "Subsidy authorization/service lines under monthly enrollment"),
    "conformed.ORG_EL_PROVIDER_RELATIONSHIP": ("HIERARCHY", "", "One row per school year x contractor x subcontractor x site", "organization_relationship_id", "Effective by school year (Type 2 semantics)", "EL-specific hierarchy on the EL provider satellite"),
}
ORG_SATS = ["ORG_LEA", "ORG_K12_SCHOOL", "ORG_ESD", "ORG_SERVICE_PROVIDER", "ORG_CREDENTIAL_ISSUER", "ORG_EL_PROVIDER", "ORG_PS_INSTITUTION",
            "ORG_PS_COLLEGE_DISTRICT", "ORG_PS_CAMPUS_SITE", "ORG_EMPLOYER", "ORG_EMPLOYER_REPORTING_UNIT", "ORG_APPRENTICESHIP_SPONSOR", "ORG_SEA"]
HIER = {"ORG_LEA": "parent_esd_org_id (LEA -> ESD)", "ORG_K12_SCHOOL": "parent_lea_org_id (School -> LEA/ESD-as-district)",
        "ORG_PS_INSTITUTION": "parent_college_district_org_id (CTC -> college district); parent_ps_institution_org_id (NSC branch -> parent)",
        "ORG_PS_CAMPUS_SITE": "parent_ps_institution_org_id (campus / DOC site -> college; DOC site re-parenting effective-dated)",
        "ORG_EMPLOYER_REPORTING_UNIT": "parent_employer_org_id (RUN -> UI account)",
        "ORG_EL_PROVIDER": "via ORG_EL_PROVIDER_RELATIONSHIP (contractor -> subcontractor -> site, by school year)",
        "ORG_SERVICE_PROVIDER": "parent_service_provider_org_id (online program -> online provider)"}
for s in ORG_SATS:
    C["conformed." + s] = ("ORG_SATELLITE", "", f"One row per org_id per version ({s[4:].replace('_', ' ').title()} attributes)", "org_id + effective_start_date",
                           "Type 2", f"Type-specific satellite; hierarchy: {HIER.get(s, 'none')}")

B = {}
for k, v in C.items():
    schema, name = k.split(".")
    bschema = {"conformed": "core", "identity": "identity"}.get(schema, schema)
    if schema == "conformed":
        B[f"core.{name.lower()}"] = v
    elif schema == "identity":
        B[f"identity.{name.lower()}"] = v

A = {
    "identity.PersonIdentifierXwalk": C["identity.PERSON_XWALK"], "identity.PersonDetailObservation": C["identity.PERSON_PII_OBSERVATION"],
    "identity.NscStudentTrackerRequestResult": C["identity.NSC_STUDENTTRACKER_REQUEST_RESULT"],
    "ceds_rds.DimPeople": ("DIMENSION", "", "One row per person per version (CEDS DimPeople with DimPeople_Current companion)", "DimPersonId", "Type 2 (CEDS RecordStartDateTime/RecordEndDateTime)", "CEDS DW person dimension (carries PII natively; masked by tag)"),
    "ceds_ext.DimPeople_WaExt": ("EXTENSION", "", "1:1 with DimPeople version", "DimPersonId", "Type 2 (follows DimPeople)", "WA person attributes not in CEDS DW"),
    "conformed.OrganizationIdentifierXwalk": C["conformed.ORGANIZATION_XWALK"], "conformed.OrganizationLineage": C["conformed.ORGANIZATION_LINEAGE"],
    "conformed.OrganizationLineageClosure": C["conformed.ORGANIZATION_LINEAGE_CLOSURE"], "conformed.AcademicPeriodXwalk": C["conformed.ACADEMIC_PERIOD_XWALK"],
    "ceds_rds.DimK12Schools": ("DIMENSION", "", "One row per K-12 school per version", "DimK12SchoolId", "Type 2", "CEDS school dimension (LEA/SEA/IEU denormalized)"),
    "ceds_rds.DimLeas": ("DIMENSION", "", "One row per LEA per version", "DimLeaId", "Type 2", "CEDS LEA dimension (IEU denormalized)"),
    "ceds_rds.DimIeus": ("DIMENSION", "", "One row per ESD (IEU) per version", "DimIeuId", "Type 2", "CEDS intermediate educational unit"),
    "ceds_rds.DimPsInstitutions": ("DIMENSION", "", "One row per PS institution per version", "DimPsInstitutionId", "Type 2", "CEDS PS institution"),
    "ceds_rds.DimEmployers": ("DIMENSION", "", "One row per employer per version", "DimEmployerId", "Type 2", "CEDS employer"),
    "ceds_rds.DimEarlyLearningOrganizations": ("DIMENSION", "", "One row per EL organization per version", "DimEarlyLearningOrganizationId", "Type 2", "CEDS EL organization (very thin in DW v14.1)"),
    "ceds_rds.DimOrganizations": ("DIMENSION", "", "One row per other organization per version", "DimOrganizationId", "Type 2", "CEDS generic organization (college districts, campuses, service providers)"),
    "ceds_rds.DimCredentialIssuers": ("DIMENSION", "", "One row per credential issuer per version", "DimCredentialIssuerId", "Type 2", "Credential issuers incl. apprenticeship sponsors"),
}


def classify(model, table):
    meta = {"A": A, "B": B, "C": C}[model]
    if table in meta:
        return meta[table]
    schema, name = table.split(".", 1) if "." in table else ("", table)
    n = name
    if table.startswith("ref.") or re.search(r"RefWa", n):
        return ("REFERENCE", "", "One row per code value", "code", "Type 1 (description corrections overwrite; retired codes kept with end period)", "Purpose-built code reference table")
    if re.search(r"(_DETAIL|_WaExt|WaExt)$", n) or n.endswith("_DETAIL"):
        return ("SATELLITE" if model == "C" else "EXTENSION", "", "1:1 with parent row", "parent key", "Follows parent (fact satellites: n/a; dimension extensions: Type 2 with parent)", "Sector/source-specific non-generalizable columns")
    if re.search(r"_ELIGIBILITY_RESPONSE$|EligibilityResponses", n):
        return ("SATELLITE", "", "1:1 with application row", "admission_id", "n/a", "Pivoted boolean eligibility responses")
    if n.startswith("Dim") or re.match(r"org_|ORG_", n):
        return ("DIMENSION", "", "One row per member per version", n + "Id", "Type 2", "")
    if n.startswith("Bridge") or "_FUNDING_MODEL" in n or "_STAFF_POSITION" in n or "_MEETING_PATTERN" in n or n in ("class_section_funding_model", "class_section_staff_position", "class_section_meeting_pattern"):
        return ("BRIDGE", "", "Many-to-many / child rows", "composite", "Type 1 (rebuilt with parent)", "")
    if n.startswith("Fact") or schema in ("fact", "k12", "ps", "el", "wf", "fa", "appr", "edu"):
        if re.search(r"(course_catalog|course_section$|class_section$|academic_program|educator_prep_program|state_program|apprenticeship_program_occupation|^course$)", n):
            return ("DEFINITION", "", "One row per offering org x period x definition key", "surrogate", "Periodic definition (period in key); corrections Type 1", "")
        return ("FACT", "", "", "surrogate", "n/a (fact)", "")
    return ("OTHER", "", "", "", "", "")


# Structural columns (not sourced from an inventory row) --------------------
DW_KEYS = {}


def _dw_key(table):
    if not DW_KEYS:
        import os
        from common import ROOT
        for line in open(os.path.join(ROOT, "reference", "ceds_v14", "dw_cols.txt")):
            if ":" in line and line.startswith("RDS."):
                t, c = line.split(":", 1)
                DW_KEYS[t[4:]] = c.split(",")[0].strip()
    return DW_KEYS.get(table)


def structural_columns(model, table, ttype, scd=""):
    snakey = model in ("B", "C")
    base = table.split(".")[-1]
    pk = (re.sub(r"^(fact|conformed)\.", "", table).split(".")[-1].lower() + "_id") if snakey else (_dw_key(base) if table.startswith("ceds_rds.") and _dw_key(base) else re.sub(r"s(_WaExt)?$", "", base) + "Id")
    cols = []
    add = lambda c, t, logic: cols.append((c if snakey else _pascal(c), t, logic))
    if ttype in ("FACT", "BRIDGE_FACT", "CHILD_FACT", "PERIODIC_SNAPSHOT", "DEFINITION", "IDENTITY", "IDENTITY_XWALK", "ORG_XWALK", "ORG_LINEAGE", "HIERARCHY", "BRIDGE", "DIMENSION_BRIDGE"):
        cols.append((pk, "BIGINT", "SYSTEM: surrogate key (identity column)"))
    fact_ext = ttype == "EXTENSION" and re.match(r"(Fact|K12\w+ParticipationWaExt|K12MealEligibility)", base)
    if fact_ext:
        parent = base.split("_")[0] if "_" in base else base.replace("WaExt", "")
        cols.append((_dw_key(parent) or (re.sub(r"s$", "", parent) + "Id"), "BIGINT", "SYSTEM: 1:1 key to the extended CEDS fact row"))
    if ttype == "EXTENSION" and not fact_ext:
        parent = base.split("_")[0] if "_" in base else base.replace("WaExt", "")
        cols.append((_dw_key(parent) or (parent + "Id"), "BIGINT", "SYSTEM: 1:1 key to the extended CEDS dimension version"))
    type2 = (not fact_ext) and (("Type 2" in (scd or "")) or ttype == "ORG_SATELLITE")
    if ttype in ("DIMENSION", "ORG_SATELLITE", "EXTENSION") and type2 and table not in ("conformed.DIM_DATE",):
        if ttype != "EXTENSION":
            cols.append((pk.replace("_id", "_sk") if snakey else base + "Sk", "BIGINT", "SYSTEM: version surrogate key"))
        add("effective_start_date", "DATE", "SYSTEM: Type 2 version start (source period or load date)")
        add("effective_end_date", "DATE", "SYSTEM: Type 2 version end (9999-12-31 when current)")
        add("is_current", "BOOLEAN", "SYSTEM: current version flag")
        add("record_hash", "STRING", "SYSTEM: hash of tracked attributes for change detection")
    if ttype == "SATELLITE":
        cols.append(("parent_id", "BIGINT", "SYSTEM: 1:1 foreign key to the conformed family row (same value as parent surrogate key)"))
    add("source_system", "STRING", "SYSTEM: source system code of the contributing bronze table")
    add("bronze_batch_id", "STRING", "SYSTEM: bronze load batch id (Delta table version) for replay/lineage")
    add("silver_loaded_at", "TIMESTAMP", "SYSTEM: silver merge timestamp")
    return cols


def _pascal(s):
    return "".join(p.title() for p in s.split("_"))


# Conformed attributes that are computed during mastering rather than read from one element
MASTERED = {
    "C": {
        "conformed.PERSON": [("person_id", "BIGINT", "Durable statewide person key issued by identity resolution (never reused)"),
                             ("identity_confidence_tier", "STRING", "Lowest match confidence among links that formed this person (DETERMINISTIC_SSID / PROBABILISTIC_HIGH / CLERICAL_REVIEW)")],
        "conformed.ORGANIZATION": [("org_id", "BIGINT", "Durable organization key issued by organization mastering"), ("organization_type", "STRING", "Primary type: SEA, ESD, LEA, K12_SCHOOL, PS_INSTITUTION, PS_COLLEGE_DISTRICT, PS_CAMPUS_SITE, EL_PROVIDER, EMPLOYER, EMPLOYER_REPORTING_UNIT, APPRENTICESHIP_SPONSOR, SERVICE_PROVIDER, CREDENTIAL_ISSUER"),
                                   ("operational_status", "STRING", "Derived from lineage events and source status (open / closed / merged / split)")],
        "conformed.ORGANIZATION_XWALK": [("org_id", "BIGINT", "Durable org assigned by mastering"), ("source_system", "STRING", "Source system"), ("source_identifier_type", "STRING", "Identifier type"), ("effective_start_date", "DATE", "First date this code maps to this org"), ("effective_end_date", "DATE", "Last date (code reuse after this date maps elsewhere)"), ("assignment_basis", "STRING", "SOURCE_MASTER / LINEAGE_EVENT / STEWARD_OVERRIDE")],
        "conformed.ORGANIZATION_LINEAGE": [("lineage_event_id", "BIGINT", "SYSTEM"), ("event_type", "STRING", "SPLIT / MERGE / ABSORPTION / CLOSURE / OPENING / RECODE / SUCCESSION_FULL / SUCCESSION_PARTIAL / RECLASSIFICATION"), ("predecessor_org_id", "BIGINT", "Org before event"), ("successor_org_id", "BIGINT", "Org after event"), ("event_effective_date", "DATE", "Date/period the event takes effect"), ("event_effective_period_code", "STRING", "Source period code of the event (e.g. SBCTC YRQ A121)"), ("allocation_share", "DECIMAL(5,4)", "Share of predecessor attributed to this successor for aggregate re-attribution (splits); null = no allocation"), ("fact_reattribution_rule", "STRING", "AS_REPORTED_ONLY / ROLL_FORWARD_TO_SUCCESSOR / ROLL_BACK_TO_PREDECESSOR / ALLOCATE"), ("evidence_source_code", "STRING", "Documentation / source record for the event"), ("steward_note", "STRING", "Free-text steward rationale")],
        "conformed.ORGANIZATION_LINEAGE_CLOSURE": [("org_id", "BIGINT", "Derived"), ("related_org_id", "BIGINT", "Derived"), ("relationship_direction", "STRING", "SUCCESSOR / PREDECESSOR"), ("path_length", "INT", "Derived"), ("allocation_share_product", "DECIMAL(9,6)", "Derived"), ("is_terminal_successor", "BOOLEAN", "Derived: related_org has no successor"), ("lineage_group_id", "BIGINT", "Derived: connected component id (e.g. all Pierce College orgs)")],
        "conformed.ACADEMIC_PERIOD": [("academic_period_id", "BIGINT", "Derived"), ("period_type", "STRING", "SCHOOL_YEAR / TERM / QUARTER / AWARD_YEAR / PROGRAM_YEAR / PESB_YEAR / CALENDAR_QUARTER / CALENDAR_MONTH / REGISTRATION_SPELL"), ("school_year_end", "SMALLINT", "Ending year of the containing school/academic year"), ("term_code", "STRING", "SUMMER/FALL/WINTER/SPRING (null for annual)"), ("calendar_year", "SMALLINT", "Derived"), ("calendar_quarter", "SMALLINT", "Derived"), ("period_begin_date", "DATE", "Nominal statewide begin date"), ("period_end_date", "DATE", "Nominal statewide end date"), ("parent_academic_period_id", "BIGINT", "Term -> school year roll-up")],
        "conformed.ACADEMIC_PERIOD_XWALK": [("academic_period_id", "BIGINT", "Derived"), ("source_system", "STRING", "Source system"), ("period_code_type", "STRING", "Code type")],
        "conformed.DIM_DATE": [("date_key", "INT", "yyyymmdd"), ("calendar_date", "DATE", "Derived"), ("school_year_end", "SMALLINT", "Sept-Aug school year"), ("state_fiscal_year", "SMALLINT", "Jul-Jun"), ("calendar_quarter", "SMALLINT", "Derived")],
        "identity.PERSON_XWALK": [("person_id", "BIGINT", "Assigned by matching"), ("source_system", "STRING", "Source system"), ("source_identifier_type", "STRING", "Identifier type"), ("match_method", "STRING", "DETERMINISTIC / PROBABILISTIC / CLERICAL / MDM_TOKEN"), ("match_score", "DECIMAL(5,4)", "Probabilistic score"), ("effective_start_date", "DATE", "Link start"), ("effective_end_date", "DATE", "Link end (unmerge closes)")],
        "fact.ACHIEVEMENT": [("awarding_org_id", "BIGINT", "Institution/LEA/L&I org that conferred the credential (from the contributing source's org FK)")],
        "fact.ENROLLMENT": [("period_type", "STRING", "SCHOOL_YEAR / QUARTER / TERM / PROGRAM_YEAR / CALENDAR_MONTH / NSC_REPORTED_PERIOD / REGISTRATION_SPELL"), ("sector", "STRING", "EL / K12 / PS / APPR")],
        "fact.ASSESSMENT": [("sector", "STRING", "EL / K12 / PS"), ("organization_org_id", "BIGINT", "Conformed administering organization (school, EL site, institution) coalesced from sector-specific org FKs")],
        "fact.ADMISSION": [("sector", "STRING", "EL / PS / FA")],
        "fact.PROGRAM_PARTICIPATION": [("sector", "STRING", "EL / K12 / PS / FA")],
        "fact.STUDENT_COURSE_RECORD": [("record_type", "STRING", "SCHEDULE / TRANSCRIPT / NONTRADITIONAL_CREDIT / REGISTRATION"), ("sector", "STRING", "K12 / PS")],
        "fact.FINANCIAL_AID_AWARD_TERM_ENROLLMENT": [("financial_aid_award_id", "BIGINT", "FK"), ("enrollment_id", "BIGINT", "FK to fact.ENROLLMENT (PS term row); null when no matching enrollment"), ("academic_period_id", "BIGINT", "Term")],
    }
}


def mastered_for(model, table):
    if model == "C":
        return MASTERED["C"].get(table, [])
    if model == "B":
        m = {}
        for k, v in MASTERED["C"].items():
            s, n = k.split(".")
            if s == "conformed":
                m[f"core.{n.lower()}"] = v
            elif s == "identity":
                m[f"identity.{n.lower()}"] = v
        return m.get(table, [])
    amap = {"conformed.OrganizationIdentifierXwalk": "conformed.ORGANIZATION_XWALK", "conformed.OrganizationLineage": "conformed.ORGANIZATION_LINEAGE",
            "conformed.OrganizationLineageClosure": "conformed.ORGANIZATION_LINEAGE_CLOSURE", "conformed.AcademicPeriodXwalk": "conformed.ACADEMIC_PERIOD_XWALK",
            "identity.PersonIdentifierXwalk": "identity.PERSON_XWALK"}
    return [(_pascal(c), t, l) for c, t, l in MASTERED["C"].get(amap.get(table, ""), [])]


# Tables that exist in each design even when no inventory row lands in them directly
REQUIRED_TABLES = {
    "C": ["conformed.PERSON", "conformed.ORGANIZATION", "conformed.ORGANIZATION_XWALK", "conformed.ORGANIZATION_LINEAGE", "conformed.ORGANIZATION_LINEAGE_CLOSURE",
          "conformed.ACADEMIC_PERIOD", "conformed.ACADEMIC_PERIOD_XWALK", "conformed.DIM_DATE", "conformed.ORG_SEA", "fact.FINANCIAL_AID_AWARD_TERM_ENROLLMENT"],
    "B": ["core.person", "core.organization", "core.organization_xwalk", "core.organization_lineage", "core.organization_lineage_closure",
          "core.academic_period", "core.academic_period_xwalk", "core.dim_date", "core.org_sea"],
    "A": ["conformed.OrganizationLineageClosure", "ceds_rds.DimSchoolYears", "ceds_rds.DimDates", "ceds_rds.DimGradeLevels", "ceds_rds.DimRaces", "ceds_rds.DimSeas"],
}
