"""Turns (Src, inventory row) into lineage mappings for models A, B and C."""
import re
from common import snake, pascal, ceds, infer_type
from routing_core import (M, MODELS, ceds_for, colname, person_id_info, pii_column,
                          ORG_IDS, ORG_IDS_BY_SRC, ORG_NAMES, ORG_SAT, A_ORG_NAME_COL, A_ORG_ID_COL,
                          PERIOD_ELEMS, PERIOD_BY_SRC_SKIP, AUDIT, is_race_eth, race_eth_column,
                          DESC_RE, SURR_RE, FLAG_RE, DESIG_RE, code_concept)

# ---- conformed table names per model -------------------------------------
T = {
    "person_xwalk": {"A": "identity.PersonIdentifierXwalk", "B": "identity.person_xwalk", "C": "identity.PERSON_XWALK"},
    "person_pii": {"A": "identity.PersonDetailObservation", "B": "identity.person_pii_observation", "C": "identity.PERSON_PII_OBSERVATION"},
    "person": {"A": "ceds_ext.DimPeople_WaExt", "B": "core.person", "C": "conformed.PERSON"},
    "person_race": {"A": "ceds_ext.BridgePersonRaceEthnicityWaExt", "B": "core.person_race_ethnicity", "C": "conformed.PERSON_RACE_ETHNICITY"},
    "person_lang": {"A": "ceds_ext.BridgePersonLanguageWaExt", "B": "core.person_language", "C": "conformed.PERSON_LANGUAGE"},
    "org": {"A": "ceds_rds.DimOrganizations", "B": "core.organization", "C": "conformed.ORGANIZATION"},
    "org_xwalk": {"A": "conformed.OrganizationIdentifierXwalk", "B": "core.organization_xwalk", "C": "conformed.ORGANIZATION_XWALK"},
    "org_lineage": {"A": "conformed.OrganizationLineage", "B": "core.organization_lineage", "C": "conformed.ORGANIZATION_LINEAGE"},
    "period_xwalk": {"A": "conformed.AcademicPeriodXwalk", "B": "core.academic_period_xwalk", "C": "conformed.ACADEMIC_PERIOD_XWALK"},
}
DIMPEOPLE_PII = {"first_name": "FirstName", "middle_name": "MiddleName", "last_or_surname": "LastOrSurname",
                 "birthdate": "Birthdate", "generation_code_or_suffix": "GenerationCodeOrSuffix",
                 "social_security_number": "PersonIdentifierSSN"}
DIMPEOPLE_IDS = {"OSPI_SSID": "K12StudentStudentIdentifierState", "DISTRICT_STUDENT_ID": "K12StudentStudentIdentifierDistrict",
                 "ELMS_CHILD_ID": "ELChildChildIdentifierState", "SBCTC_DW_KEY": "PsStudentStudentIdentifierState",
                 "PCHEES_STUDENT_ID": "PsStudentStudentIdentifierState", "OSPI_CERTIFICATE_NUMBER": "K12StaffStaffMemberIdentifierState",
                 "OSPI_EDUCATOR_ID": "K12StaffStaffMemberIdentifierState", "DISTRICT_STAFF_ID": "K12StaffStaffMemberIdentifierDistrict",
                 "LNI_APPRENTICE_ID": "WorkforceProgramParticipantPersonIdentifierState"}
A_ORG_FK = {"lea": "LeaId", "resident_lea": "LeaMembershipResidentId", "school": "K12SchoolId", "esd": "IeuId",
            "ps_institution": "PsInstitutionId", "employer": "EmployerId"}
A_PERIOD = {"SCHOOL_YEAR": "SchoolYearId", "ACADEMIC_YEAR": "SchoolYearId", "PROGRAM_YEAR": "SchoolYearId",
            "YEAR": "SchoolYearId", "AWARD_YEAR": "SchoolYearId", "ELMS_SCHOOL_YEAR_ID": "SchoolYearId",
            "TERM": "AcademicTermDesignatorId", "SBCTC_QUARTER": "AcademicTermDesignatorId", "SBCTC_YEAR": "SchoolYearId",
            "SBCTC_YRQ": "AcademicTermDesignatorId", "CTCLINK_STRM": "AcademicTermDesignatorId",
            "CALENDAR_YEAR_QUARTER": "EmploymentRecordReferencePeriodStartDateId", "CALENDAR_YEAR": "SchoolYearId",
            "CALENDAR_QUARTER": "AcademicTermDesignatorId", "CALENDAR_MONTH": "ServiceMonthDateId",
            "ASSESSMENT_SEASON": "AssessmentAdministrationId"}


def _split(spec):
    """'schema.Table.col' -> (table, col); 'schema.Table' -> (table, None)."""
    parts = spec.split(".")
    if len(parts) >= 3:
        return ".".join(parts[:2]), ".".join(parts[2:])
    return spec, None


def _targets(model, spec, src, r, kind_default="DIRECT"):
    out = []
    if spec is None:
        return out
    if isinstance(spec, list):
        for s in spec:
            out += _targets(model, s, src, r, kind_default)
        return out
    logic = ""
    kind = kind_default
    if isinstance(spec, tuple):
        spec, logic = spec
        kind = "DIRECT" if logic.lower().startswith("direct") else "DERIVED"
    spec = (spec.replace("{T}", src.host.get(model) or "")
                .replace("{A}", src.attrs.get(model) or "")
                .replace("{datebase}", _datebase(r["elem"]))
                .replace("{L}", {"A": "ceds_ext.BridgePersonLanguageWaExt", "B": "core.person_language", "C": "conformed.PERSON_LANGUAGE"}[model]))
    if spec.startswith("EXCLUDE"):
        return [M(model, "(bronze only)", "", "EXCLUDED", spec.split(":", 1)[1].strip())]
    table, col = _split(spec)
    if col is None:
        col = default_col(model, r["elem"])
    label = ceds_for(r["elem"]) if col == default_col(model, r["elem"]) else ""
    out.append(M(model, table, col, kind, logic, label))
    return out


def _datebase(elem):
    base = snake(re.sub(r"\s*-?\s*(Year|Month|Day|year)$", "", elem))
    return {"setup_date": "setup_date", "initial_date_of_liability": "initial_liability_date",
            "end_of_liability_date": "end_liability_date", "reactivation_date": "reactivation_date"}.get(base, base + "_date")


def default_col(model, elem):
    label = ceds_for(elem)
    if label:
        base = pascal(label) if model == "A" else snake(label)
        if re.search(r"(code|cd|id)$", elem, re.I) and not base.lower().endswith(("code", "id", "date")):
            base += "Code" if model == "A" else "_code"
        return base
    return colname(model, elem)


def _names_match(names, r):
    elem = r["elem"]
    for n in names:
        if n.startswith("#"):
            if int(n[1:]) == r["row"]:
                return True
        elif n.startswith("re:"):
            if re.match(n[3:], elem, re.I):
                return True
        elif n == elem:
            return True
    return False


def resolve(src, r, src_rows):
    out = []
    remaining = list(MODELS)
    additive_only = True
    for names, tgt in src.groups:
        add = names and names[0] == "+"
        nm = names[1:] if add else names
        if not _names_match(nm, r):
            continue
        for m in list(remaining):
            if m in tgt:
                out += _targets(m, tgt[m], src, r)
                if not add:
                    remaining.remove(m)
        if not remaining:
            break
    if remaining:
        out += resolve_global(src, r, src_rows, remaining)
    # code elements that have description / surrogate partners also populate a reference table
    if not any(x.kind == "EXCLUDED" for x in out):
        out += ref_code_targets(src, r, src_rows, [m for m in MODELS])
    for x in out:
        if not x.dtype:
            x.dtype = "STRING" if x.kind == "EXCLUDED" else infer_type(r["elem"], r["desc"], r["Example Value(s)"])
    return out


# --------------------------------------------------------------------------
def resolve_global(src, r, src_rows, models):
    e = r["elem"]
    out = []

    pid = person_id_info(src.key, e)
    if pid:
        id_type, role = pid
        role = src.person_type.get(e, role)
        for m in models:
            out.append(M(m, T["person_xwalk"][m], "Identifier" if m == "A" else "source_person_identifier", "DIRECT",
                         f"Loaded with source_system='{src.system}', identifier_type='{id_type}'; identity resolution assigns the durable person_id",
                         "Person Identifier", "STRING"))
            fk = ("PersonId" if role == "subject" else pascal(role) + "PersonId") if m == "A" else \
                ("person_id" if role == "subject" else f"{role}_person_id")
            if m == "A" and role == "subject":
                fk = src.a_person_col
            if m == "A" and role == "staff":
                fk = "K12StaffId"
            host = src.host.get(m)
            if host:
                out.append(M(m, host, fk, "DERIVED",
                             f"Lookup PERSON_XWALK on (source_system='{src.system}', identifier_type='{id_type}', identifier=value, effective as of record period) -> durable person_id",
                             "", "BIGINT"))
            if m == "A" and id_type in DIMPEOPLE_IDS:
                out.append(M(m, "ceds_rds.DimPeople", DIMPEOPLE_IDS[id_type], "DERIVED",
                             "Survivorship: most recent value for the resolved person from the authoritative source for this identifier", "", "STRING"))
        return out

    pcol = pii_column(src.key, r)
    if pcol:
        for m in models:
            out.append(M(m, T["person_pii"][m], pascal(pcol) if m == "A" else pcol, "DIRECT",
                         f"Restricted identity zone; one observation per source record (source_system='{src.system}'); used for identity resolution only",
                         _ceds_label_for_pii(pcol), "DATE" if pcol == "birthdate" else "STRING"))
            if m == "A" and pcol in DIMPEOPLE_PII:
                out.append(M(m, "ceds_rds.DimPeople", DIMPEOPLE_PII[pcol], "DERIVED",
                             "CEDS DimPeople carries PII natively; survivorship across observations; column-masked by governance tag", "", "STRING"))
            if pcol in ("birthdate", "birth_year_month", "birth_year_as_reported", "birth_month_as_reported"):
                tgt = T["person"][m]
                for c in (("BirthYear", "BirthMonth") if m == "A" else ("birth_year", "birth_month")):
                    out.append(M(m, tgt, c, "DERIVED",
                                 "Year/month extracted from birth date observations; survivorship = modal value across sources, K-12 CEDARS preferred", "", "SMALLINT"))
        return out

    org = ORG_IDS_BY_SRC.get((src.key, e), ORG_IDS.get(e)) if (src.key, e) in ORG_IDS_BY_SRC or e in ORG_IDS else None
    if org:
        otype, idtype, role = org
        role = src.a_org_cols.get("role:" + e, role)
        sat_c, dim_a = ORG_SAT[otype]
        for m in models:
            out.append(M(m, T["org_xwalk"][m], "SourceOrganizationIdentifier" if m == "A" else "source_org_identifier", "DIRECT",
                         f"Loaded with source_system='{src.system}', identifier_type='{idtype}'; effective-dated resolution to durable org_id",
                         "Organization Identifier", "STRING"))
            if m == "A":
                idcol = A_ORG_ID_COL.get((otype, idtype))
                if idcol:
                    out.append(M(m, f"ceds_rds.{dim_a}", idcol, "DIRECT", "direct: natural identifier on CEDS dimension (Type 2 row as of record period)", "", "STRING"))
                else:
                    out.append(M(m, f"ceds_ext.{dim_a}_WaExt", pascal(idtype), "DIRECT", "direct: WA identifier not modeled in CEDS dimension", "", "STRING"))
            else:
                sat = ("conformed." if m == "C" else "core.") + (sat_c if m == "C" else sat_c.lower())
                out.append(M(m, sat, idtype.lower(), "DIRECT", "direct: natural identifier carried on the type-specific satellite (Type 2)", "", "STRING"))
            host = src.host.get(m)
            if m == "A" and host == f"ceds_rds.{dim_a}":
                host = None  # the natural identifier on the CEDS dimension itself is the key; no self-FK
            if host:
                if m == "A":
                    fk = src.a_org_cols.get(role, A_ORG_FK.get(role, pascal(role) + "OrganizationId"))
                    htable, hcol = (_split(fk) if fk.count(".") >= 2 else (host, fk))
                else:
                    own = host.lower().endswith(sat_c.lower())
                    htable, hcol = host, ("org_id" if own else f"{role}_org_id")
                out.append(M(m, htable, hcol, "DERIVED",
                             f"Lookup ORGANIZATION_XWALK on (source_system='{src.system}', identifier_type='{idtype}', identifier=value) where record period between effective dates -> org_id as reported (see ORGANIZATION_LINEAGE for successor roll-up)",
                             "", "BIGINT"))
        return out

    oname = ORG_NAMES.get(e)
    if oname:
        otype, role = oname
        sat_c, dim_a = ORG_SAT[otype]
        for m in models:
            if m == "A":
                col = "DoingBusinessAsName" if e.startswith("Trade Name") else A_ORG_NAME_COL[dim_a]
                tbl = f"ceds_ext.{dim_a}_WaExt" if e.startswith("Trade Name") else f"ceds_rds.{dim_a}"
                out.append(M(m, tbl, col, "DERIVED", "Survivorship: organization master source preferred (OSPI School Directory, SBCTC College, ESD UI Employer, ELMS Organization); name as reported retained in bronze", "Organization Name", "STRING"))
            else:
                if e.startswith("Trade Name"):
                    sat = ("conformed.ORG_EMPLOYER" if m == "C" else "core.org_employer")
                    out.append(M(m, sat, "doing_business_as_name", "DIRECT", "direct: Type 2 attribute", "", "STRING"))
                else:
                    out.append(M(m, T["org"][m], "organization_name", "DERIVED",
                                 "Survivorship by org type: master source preferred; Type 2 change tracked on ORGANIZATION (rename is NOT a lineage event)", "Organization Name", "STRING"))
        return out

    kind = PERIOD_ELEMS.get(e)
    if kind and (src.key, e) not in PERIOD_BY_SRC_SKIP:
        for m in models:
            out.append(M(m, T["period_xwalk"][m], "SourcePeriodCode" if m == "A" else "source_period_code", "DIRECT",
                         f"Loaded as source_system='{src.system}', period_code_type='{kind}'; translated to a conformed academic period", "", "STRING"))
            host = src.host.get(m)
            if host:
                col = src.a_org_cols.get("period:" + kind, A_PERIOD.get(kind, "PeriodId")) if m == "A" else "academic_period_id"
                htable, hcol = (_split(col) if col.count(".") >= 2 else (host, col))
                out.append(M(m, htable, hcol, "DERIVED",
                             f"Translate {kind} value via ACADEMIC_PERIOD_XWALK (e.g. SBCTC YEAR 'B90'+QUARTER '4' -> 2019-20 Spring; CEDARS SchoolYear 2022 -> 2021-22)",
                             "School Year" if "YEAR" in kind else "", "BIGINT"))
            attrs = src.attrs.get(m)
            if attrs:
                out.append(M(m, attrs, ("Source" + pascal(e)) if m == "A" else "source_" + snake(e), "DIRECT",
                             "direct: period code as reported, retained for audit", "", "STRING"))
        return out

    if is_race_eth(src.key, e):
        col = race_eth_column(e)
        flag = re.match(r"^(africanamerican|asian|caucasian|eastindian|hispanic|nativealaskan|nativeamerican|nativeamericanalaskan|pacificisland|white|hispanicorigin|raceamericanindian|raceasian|raceblack|racepacificislander|racewhite|raceother|isaian)$", e, re.I)
        positional = re.match(r"^(race|hispanic)_[1-5]$", e, re.I)
        for m in models:
            if flag:
                logic = f"Unpivot indicator: when '{e}' = Y/1 emit one row with source_race_ethnicity_code='{e.upper()}' (source_system='{src.system}')"
                out.append(M(m, T["person_race"][m], "SourceRaceEthnicityCode" if m == "A" else "source_race_ethnicity_code", "DERIVED", logic, "Race and Ethnicity", "STRING"))
            elif positional:
                logic = f"Normalize repeating group: position {e[-1]} of {e[:-2]} becomes one row with sequence={e[-1]}"
                out.append(M(m, T["person_race"][m], "SourceRaceEthnicityCode" if m == "A" else "source_race_ethnicity_code", "DERIVED", logic, "Race and Ethnicity", "STRING"))
            else:
                out.append(M(m, T["person_race"][m], pascal(col) if m == "A" else col, "DIRECT",
                             f"direct: multi-valued person attribute observation (source_system='{src.system}', observed period)", "", "STRING"))
            out.append(M(m, T["person"][m], "FederalRaceEthnicityRollup" if m == "A" else "federal_race_ethnicity_rollup", "DERIVED",
                         "Type 2 person attribute recomputed from all current race/ethnicity observations using OSPI federal roll-up rules; source priority CEDARS > SBCTC/PCHEES > others",
                         "Race and Ethnicity", "STRING"))
            if m == "A" and src.system in ("CEDARS",):
                out.append(M(m, "ceds_rds.BridgeK12StudentEnrollmentRaces", "RaceId", "DERIVED",
                             "Map CEDARS race/ethnicity code to CEDS RaceCode option set (DimRaces) for each enrollment", "Race and Ethnicity", "BIGINT"))
        return out

    if e in AUDIT:
        for m in models:
            t = src.attrs.get(m)
            if t:
                out.append(M(m, t, pascal(AUDIT[e]) if m == "A" else AUDIT[e], "DIRECT", "direct: source audit metadata carried to gold for lineage/reproducibility",
                             "", "DATE" if "date" in AUDIT[e] else "STRING"))
        return out

    d = r["desc"]
    mdesc, msurr, mflag = DESC_RE.match(d), SURR_RE.match(d), FLAG_RE.match(d)
    if (mdesc or msurr) and not re.search(r"flag$", e, re.I):
        partner = find_partner(src_rows, r, (mdesc or msurr).group(1) or (msurr.group(2) if msurr else None))
        concept = src.c_concepts.get(partner or "", None) if hasattr(src, "c_concepts") else None
        concept = concept or code_concept(partner or e)
        for m in models:
            rt, prefix = ref_table(m, src, concept)
            if mdesc:
                q = "short_" if d.lower().startswith("short") else ("long_" if d.lower().startswith("long") else "")
                col = (pascal(q + prefix + "_description")) if m == "A" else f"{q}{prefix}_description"
                out.append(M(m, rt, col, "DIRECT", f"direct: description for code element '{partner or '?'}' (purpose-built reference table, Type 1)", "", "STRING"))
            else:
                col = pascal(prefix + "_source_id") if m == "A" else f"{prefix}_source_id"
                out.append(M(m, rt, col, "DIRECT", f"direct: OSPI internal surrogate id for code element '{partner or '?'}'", "", "STRING"))
        return out

    for m in models:
        t = src.attrs.get(m)
        if not t:
            continue
        col = default_col(m, e)
        if mflag:
            out.append(M(m, t, col, "DERIVED", f"Derived flag: {d}", "", "BOOLEAN"))
        elif DESIG_RE.match(d):
            out.append(M(m, t, col, "DERIVED",
                         "Derived Y/N: set when FullCourseDesignationCode contains the designation code for this flag (CEDARS Appendix course designation codes)", "", "BOOLEAN"))
        else:
            out.append(M(m, t, col, "DIRECT", "direct", ceds_for(e)))
    return out


def _ceds_label_for_pii(col):
    return {"first_name": "First Name", "middle_name": "Middle Name", "last_or_surname": "Last or Surname",
            "birthdate": "Birthdate", "generation_code_or_suffix": "Generation Code or Suffix",
            "electronic_mail_address": "Electronic Mail Address", "telephone_number": "Telephone Number"}.get(col, "")


def find_partner(src_rows, r, name):
    if not name:
        return None
    names = {x["elem"].lower(): x["elem"] for x in src_rows if x["tbl"] == r["tbl"] and x is not r}
    names_all = {x["elem"].lower(): x["elem"] for x in src_rows if x is not r}
    for cand in (name, re.sub(r"Name$", "Code", name), re.sub(r"(Desc|Description|Name|Type)$", "Code", r["elem"]),
                 re.sub(r"(Desc|Description)$", "", r["elem"]), re.sub(r"(Desc|Description)$", "Id", r["elem"]),
                 re.sub(r"Id$", "Code", r["elem"]), re.sub(r"ID$", "", r["elem"]), name + "Code"):
        if cand.lower() in names:
            return names[cand.lower()]
        if cand.lower() in names_all:
            return names_all[cand.lower()]
    return name


def ref_table(model, src, concept):
    prefix = snake(concept)
    if model == "A":
        return f"ceds_ext.RefWa{pascal(src.ref_domain)}{pascal(concept)}", prefix
    return f"ref.{src.ref_domain}_{prefix}", prefix


def ref_code_targets(src, r, src_rows, models):
    """If some other element in this source is the description or surrogate id of r, r is a code
    and also populates the code column of that purpose-built reference table."""
    e = r["elem"]
    if (person_id_info(src.key, e) or pii_column(src.key, r) or e in ORG_IDS or e in ORG_NAMES
            or e in PERIOD_ELEMS or is_race_eth(src.key, e)):
        return []
    partners = []
    for x in src_rows:
        if x is r:
            continue
        mm = DESC_RE.match(x["desc"]) or SURR_RE.match(x["desc"])
        if not mm:
            continue
        target = mm.group(1) or (mm.groups()[1] if len(mm.groups()) > 1 else None)
        if find_partner(src_rows, x, target) == e:
            partners.append(x)
    if not partners:
        return []
    concept = getattr(src, "c_concepts", {}).get(e) or code_concept(e)
    out = []
    for m in models:
        rt, prefix = ref_table(m, src, concept)
        out.append(M(m, rt, pascal(prefix + "_code") if m == "A" else f"{prefix}_code", "DIRECT",
                     "direct: code value (natural key of purpose-built reference table, Type 1)", ceds_for(e), "STRING"))
    return out
