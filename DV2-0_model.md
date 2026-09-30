# Task: Draft a Data Vault 2.0 model from a data element inventory

## Context
I'm evaluating architectures for migrating a SQL Server ODS of Washington P-20W
administrative data (K-12, postsecondary, financial aid, workforce/wage, early
learning, justice, apprenticeships) to Databricks (medallion: bronze/silver/gold,
Unity Catalog). I want a draft Data Vault 2.0 raw vault model derived from our
element inventory, so I can judge its size, complexity, and maintenance cost
against a lean silver layer + Kimball/CEDS RDS-style gold.

This is an evaluation draft, not a production design. Accuracy about what is
known vs. guessed matters more than completeness.

## Input
`allDataElements.csv` (~2,700 rows, UTF-8 with BOM). Columns:
Source.Name, Dataset, Sector Name, Agency Name, Source or Program, Table Name,
Data Element Name, Description/Definition, Example Value(s), Primary Key?,
Data Element Notes, First Year Available, Most Recent Year Available,
Governance Requirements, Table Granularity, Row #

Known data quality issues:
- `Primary Key?` is inconsistent: "x", "Y", "?", or blank. Treat x/Y as
  flagged PK, "?" as uncertain, blank as unknown (NOT as "not a key").
- ~69 rows have a blank Table Name.
- Some Data Element Names have leading/trailing whitespace or tab characters.
- Table Granularity is almost always blank.
- There are no foreign key / relationship columns. Relationships must be inferred
  from element names and descriptions (e.g., shared identifiers).

Optional supporting documentation (use to confirm keys and grain when helpful):
[list paths to data dictionaries/manuals, e.g., CEDARS manual, SBCTC table docs,
PCHEES submission guide]

## Scope
[Start with Sector Name = "Workforce" only | or: all sectors]

## Modeling rules
- Hubs: one per core business concept identified by a business key
  (e.g., person/student, institution/organization, course, program, employer).
  Use business keys, never source surrogate keys, unless no business key exists
  (flag these).
- Do NOT assume identifiers are shared across agencies. Person IDs from different
  agencies (e.g., OSPI vs SBCTC vs ESD) are different business keys. Model
  cross-source identity via same-as links or separate hubs, and flag it; identity
  resolution is out of scope.
- Links: relationships and transactions between hubs (enrollment, course taken,
  employment/wage record, award, program participation). Note grain for each.
  Flag candidates for non-historized (transactional) links.
- Satellites: descriptive attributes, split by (1) source system, (2) rate of
  change where obvious, and (3) Governance Requirements category, so restricted
  elements (e.g., "R) Restricted Use", "NA) Not Available to Request") are not
  mixed with less-restricted ones.
- Multi-active satellites where a key legitimately has multiple concurrent rows
  (e.g., "multiple observations by childid" for race, language, etc.).
- Code/lookup values (option sets) are reference tables, not hubs.
- Every element maps to exactly one target (hub business key, link, satellite
  attribute, reference table) OR is explicitly excluded with a reason.

## Process (stop at each checkpoint for my review)
1. **Profile** the file with a Python script: counts by sector, agency, source,
   table; PK flag distribution; blank/dirty values; candidate identifier
   elements (names/descriptions containing id, key, code, number, SSN, etc.).
   Write `outputs/profile.md`. **CHECKPOINT.**
2. **Propose hubs and business keys** with evidence (which elements, which
   tables) and a confidence rating (high/medium/low). Write
   `outputs/hub_candidates.csv`. **CHECKPOINT; wait for my approval.**
3. **Propose links and satellites** based on approved hubs.
4. **Map every element** and produce the outputs below.

## Outputs (in `outputs/`)
- `hubs.csv`: hub_name, business_key_elements, source_tables, confidence, notes
- `links.csv`: link_name, hubs_connected, grain, historized (Y/N), source_tables,
  confidence, notes
- `satellites.csv`: sat_name, parent (hub/link), source_system,
  governance_category, multi_active (Y/N), attribute_count
- `element_mapping.csv`: every input row (by Row #) with target_type,
  target_object, target_column, confidence, rationale; excluded rows included
  with reason
- `open_questions.md`: ambiguities, uncertain keys, inferred relationships
  needing SME confirmation, grouped by sector
- `summary.md`: object counts (hubs/links/sats/reference tables), counts by
  sector, estimated PIT/bridge tables needed for typical queries, and a short
  assessment of where the vault is simplest vs. most complex
- `model.mmd`: Mermaid ER diagram of hubs and links (satellites summarized)

## Constraints
- Do all processing in reproducible Python scripts under `scripts/`; do not
  hand-edit outputs. Do not modify the input file.
- Do not generate DDL or pipeline code yet.
- Never invent keys or relationships without evidence. Mark inferences as such
  and route low-confidence items to open_questions.md.
- Validate at the end: every Row # appears exactly once in element_mapping.csv;
  every satellite has a valid parent; every link references existing hubs.