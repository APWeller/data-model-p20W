# P-20W Data Model Design Prompt

## ROLE

You are a data architect designing the target data model for a state
longitudinal education/workforce data warehouse migration, moving from a
~200-table normalized SQL Server ODS to Databricks (Delta Lake / Unity
Catalog). The ODS currently feeds downstream data marts and standardized
reporting queries.

## SCOPE

In scope: K-12, Postsecondary, Early Learning, Workforce, Financial Aid,
Apprenticeships.

Out of scope for this pass: Justice, Special Populations and Programs.
Ignore rows in the inventory tagged with these sectors.  Also ignore rows in the inventory tagged with agency name IPEDS.

## INPUT

Read `allDataElements.csv` in full before proposing anything. It is a
consolidated inventory of every table and data element across all source
systems, with columns: Sector Name, Agency Name, Source or Program, Table
Name, Data Element Name, Description/Definition, Example Value(s), Primary
Key?, Data Element Notes, First/Most Recent Year Available, Governance
Requirements, Table Granularity.

Relevant sources include (not exhaustive): K-12 (CEDARS, OSPI, Report
Card, Assessments, WaKIDS), Postsecondary (SBCTC, NSC, plus a public
4-year source), Early Learning (TSGold, Hist ECEAP, ELMS,
Subsidy, ESIT), Workforce (UI Employer, UI Wage), Financial Aid
(Financial Aid, College Bound Scholarship/Application Readiness),
Apprenticeships.

**Important note on the K-12 sector specifically:** CEDARS is the
current, authoritative K-12 source, but several other Source or Program
values tagged Sector Name = "K-12" may represent legacy systems that
CEDARS superseded, rather than genuinely duplicate or conflicting data.
Before treating two data elements as redundant, cross-check Source or
Program against First Year Available / Most Recent Year Available to
determine whether they represent the same concept across a legacy →
current transition (in which case they're the same conformed concept
with a source changeover, not two concepts) versus genuinely distinct
concepts that happen to sound similar. Do not assume duplication without
checking the time ranges first.

## KNOWN CONTEXT — treat these as established findings, not open questions

- K-12 is the best fit for adopting CEDS-IDS/CEDS-DW's physical schema
  directly; other domains are not.
- Race and ethnicity are Student-level demographic attributes with
  repeatable/multi-value structure, not their own entities.
- Postsecondary enrollment has competing grains historically split
  across sources: funding-source/credit-hour data and grade data are
  sometimes combined in one file and sometimes split across two.
  Reconcile this explicitly per the Enrollment grain rule below.
- Postsecondary two-year (open-admission) data has no true "applicant"
  grain distinct from enrollment; four-year data does. Don't collapse
  this distinction away.
- CEDS's physical DW/IDS table coverage is thin for Postsecondary detail
  beyond basic enrollment, for Workforce, and for Early Learning, and
  does not cover Financial Aid or Apprenticeships as first-class
  entities — these require original schema design regardless of overall
  approach.
- Financial aid awards are typically tied to a specific term + 
  institution and should be designed alongside postsecondary enrollment
  data, not as a fully isolated domain.
- Organization identifiers differ by source system, and real
  organization mergers/splits are documented in the source data (e.g.
  community/technical college district mergers and splits) — these
  require explicit handling per the Organization mastering constraint
  below, not just ordinary Type 2 history.

## HARD CONSTRAINTS (non-negotiable across every model you propose)

1. **No EAV pattern anywhere.** Every data element gets its own
   explicitly named, explicitly typed column in a purpose-built table.
   No generic attribute_name/attribute_value, key/value, or "flexible"
   generic tables of any kind.

2. **Full source-to-target lineage.** For every target column in every
   model, state exactly which row(s) of `allDataElements.csv` (Source or
   Program + Table Name + Data Element Name) it derives from. If a
   target column is derived/calculated, show the derivation logic
   explicitly. Produce this as an explicit crosswalk table, not prose.

3. **A single conformed Person/Student dimension**, keyed by a durable
   statewide identifier, that every sector's fact tables key against.
   State how identity resolution across source systems' different ID
   schemes (e.g. SSID, DW_KEY, EMPLID) is handled and where that logic
   lives.

4. **Respect established grain distinctions** (above) — do not force
   data with genuinely different grains into a single table for
   convenience.

5. **State SCD treatment (Type 1 vs Type 2) for every dimension**, given
   the annual/quarterly cadence of source updates.

6. **Carry Governance Requirements classification** from the source
   inventory into the target model (e.g. as a column-level tag or a
   separate governance mapping table) so Unity Catalog access controls
   can be built directly from it.

7. **Target platform is Delta Lake, medallion architecture** (bronze/
   silver/gold) on Unity Catalog. Bronze mirrors source structure
   as-landed; your proposed models describe the gold layer (and silver
   where it materially differs from gold).

8. **Organization mastering**, mirroring constraint 3 for people. Design
   a single conformed ORGANIZATION dimension with type-specific
   satellites (K-12 School, LEA, Postsecondary Institution, Employer,
   Early Learning Provider, Apprenticeship Sponsor — verify the full
   type list against actual org-bearing tables in the inventory). This
   requires:
   - **An ORGANIZATION_XWALK table** resolving each source system's own
     organization identifier (e.g. CEDARS ServingCountyDistrictCode,
     SBCTC COLLEGE code, IPEDS UnitID, UI employer account number) to
     one durable org_id, effective-dated to handle source-code reuse.
   - **An explicit ORGANIZATION_LINEAGE table** recording mergers,
     splits, and identity changes as predecessor/successor events. This
     is NOT the same mechanism as Type 2 attribute history — it changes
     which org_id a fact belongs to over time, not just an attribute's
     value. Verify against known real events in the source data (e.g.
     documented WA CTC district mergers/splits) that your design
     correctly attributes historical facts to the right organization on
     both sides of such an event.
   - **Hierarchy relationships** (e.g. K-12 School reports to LEA)
     modeled on the relevant type-specific satellite, not as a generic
     self-referencing parent on the conformed core — hierarchy shape is
     sector-specific, not universal.

## DELIVERABLE

Propose THREE candidate gold-layer data models:

### Model A — CEDS-DW/IDS native, extended

Adopt CEDS-IDS/CEDS-DW's actual published entities wherever they exist
(primarily K-12, and Workforce where documented) and design original
CEDS-aligned entities (using CEDS element names/definitions where they
exist, but original table/grain design) for every domain where CEDS's
physical model doesn't reach: Postsecondary detail, Financial Aid, Early
Learning, Apprenticeships.  CEDS data model can be found at https://github.com/CEDStandards

### Model B — Fully custom, CEDS-vocabulary-aligned

Design every entity from scratch based on the actual source data and
grains found in the inventory, using CEDS element names/definitions as
the column-naming and definition source wherever a CEDS element exists
for a concept, but not attempting to adopt CEDS's own table/entity
boundaries anywhere — including K-12. Optimize table boundaries purely
for this system's actual grains and known reporting needs.

### Model C — Conformed fact family with sector-specific satellite tables

Identify the following nine recurring fact/event types and design ONE
conformed table per type: **Absence, Achievement, Admission, Assessment,
CourseSection, Discipline, Enrollment, Program, Wage.**

For each of the nine, determine from the actual data in
`allDataElements.csv`:

1. **Which sectors populate it.** Some are inherently single-sector
   (Absence and Discipline: K-12 only; Wage: Workforce only) and need no
   satellite table — the conformed table itself holds all the detail.
   Others span multiple sectors (e.g. Enrollment spans Early Learning,
   K-12, Postsecondary, Apprenticeships) and need one `*_DETAIL`
   satellite per sector, holding only that sector's non-generalizable
   fields, joined 1:1 back to the conformed table.

2. **Whether the table is a person-level event/fact** (keyed to PERSON,
   with a date or period — true for Absence, Achievement, Admission,
   Assessment, Discipline, Enrollment, Wage) **or a
   definitional/reference entity** describing something an organization
   offers rather than something that happens to a person (true for
   CourseSection and Program — verify against actual source grain rather
   than assuming). Definitional entities still use the
   conformed-table-plus-sector-satellite pattern, but are keyed by
   organization/offering, not by person, and are referenced by foreign
   key from the person-level fact tables that use them (e.g. Enrollment
   references CourseSection; Enrollment or a dedicated bridge table
   references Program for program participation).

3. **Grain specifics that are already established and must be
   followed exactly:**
   - **Achievement is strictly terminal completion/credential events**
     — high school graduation, GED, degree or certificate conferral,
     apprenticeship completion. Grain: one row per person per credential
     awarded (person, credential type, award date, awarding org). It
     does NOT include GPA, credits attempted/earned, grade-level
     progression, or any in-progress academic status. Sector satellites
     on Achievement, if needed, carry only credential-type-specific
     descriptive detail (e.g. CIP code for a postsecondary credential).
   - **Enrollment's grain is periodic, not spell-level**: one row per
     person per organization per reporting period, where "period"
     matches how the source system actually reports it (school year for
     K-12, term/quarter for postsecondary, program year for Early
     Learning) — verify against the actual key structure in
     `allDataElements.csv` rather than assuming a single start/end-dated
     span. GPA, credits attempted, credits earned, grade level, and
     enrollment intensity are ordinary columns on the relevant sector's
     Enrollment satellite for that period.

4. **For every table in `allDataElements.csv`**, state explicitly which
   of the nine conformed tables (and which sector satellite, if any) it
   maps into, or whether it doesn't fit any of the nine and needs a
   tenth (name it and justify why the existing nine don't cover it).
   Financial Aid awards are a likely candidate for a table outside this
   family, keyed to PERSON and to the specific Enrollment row they're
   tied to — confirm or refute this against the actual data.

Show what querying within this family looks like for a genuinely
cross-sector question (e.g. assessment performance trends for a student
across Early Learning, K-12, and Postsecondary Assessment satellites)
versus a single-sector question (e.g. K-12 chronic absenteeism), and
compare the join cost of each against Model A and Model B for the same
two questions.

## FINAL OUTPUT

Close with a comparison matrix across all three models covering:
standards alignment, lineage traceability effort, development effort,
ongoing maintenance burden (including tracking CEDS version changes
where applicable), extensibility to sectors not yet in scope (Justice,
Special Populations), and the added complexity of Organization
mastering (constraint 8) under each model. Do not recommend one model —
present the trade-offs and let me decide.
