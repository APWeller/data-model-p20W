# CEDARS Kimball Data Warehouse

## What this project is

A Kimball dimensional data warehouse on Azure Databricks, derived from Washington OSPI's
CEDARS (Comprehensive Education Data and Research System) submission specification,
2026-27 manual v19.0 and its appendices.

The warehouse is **statewide**: it receives CEDARS data from all districts. The State
Student ID (SSID) is the durable student key.

This repo produces the **framework** of the warehouse:
- a machine-readable source catalog
- reference/code-set seeds
- silver and gold DDL
- a source-to-target mapping
- an ERD
- validation scripts

Load pipelines (DLT, notebooks, jobs) are out of scope for this pass.

The full dimensional design (bus matrix, fact grains, dimension specs, decisions) is in
`docs/dimensional-design.md`. Read it before starting any phase. It is the source of
truth. If the source documents contradict it, log the conflict in `docs/decisions-log.md`
and ask the human. Do not silently diverge from it.

## Sources (`sources/`)

- `2026-27_cedars_manual_v19.pdf`: 20 file definitions (A–V; File P is retired) and
  361 element IDs, including inactive ones.
- `2026-27_cedars_appendices.pdf`: code sets, Appendix A through AM.
- Appendices F, K, Q and R are delivered as separate xlsx files (also in `sources/`).
  They are authoritative over the PDF for those code sets.
- Some appendices may only point to external lists (likely V State Course Codes,
  S CIP codes, possibly AM). Record these in `catalog/code_sets.csv` with
  `status = external`. Do not invent values.

Out of scope, and in `sources/` only if present:
- SBCTC and PCHEES documents
- `allDataElements.csv`

## Tech conventions

- **Platform.** Databricks, Delta tables, Unity Catalog.
- **Catalog name.** Parameterize the catalog name as `${catalog}`.
- **Schemas:**
  - `bronze`: files as received, all columns STRING, plus metadata columns
  - `silver`: typed, validated, crosswalked entities
  - `ref`: code sets
  - `gold`: the star schema
- **Naming:**
  - snake_case throughout
  - table prefixes: `fact_`, `dim_`, `bridge_`, `xref_` (silver crosswalks), `ref_`
  - surrogate keys: `<dim>_sk BIGINT`
  - natural keys keep their source-meaningful names, e.g. `ssid`, `county_district_code`
- **Unknown and special members.**
  - `-1` = unknown, `-2` = not applicable.
  - `dim_school` also has a special member for school code `9999` (out-of-district
    courses reported in File H).
- **SCD2 columns:** `effective_from`, `effective_to`, `is_current`.
- **Date keys:** INT `YYYYMMDD`. Role-playing date columns are named
  `<role>_date_sk`, e.g. `entry_date_sk`.
- **Bronze metadata columns:** `_source_file`, `_school_year`, `_manual_version`,
  `_submission_type`, `_load_ts`.
  - `_manual_version` is the seam for a future backload of prior years. Keep it on
    every table even though only v19 is in scope now.
- **Column comments.** Every gold and silver column gets a `COMMENT` with its CEDARS
  element ID(s), e.g. `COMMENT 'CEDARS C12'`.
- **Clustering.** Liquid clustering on `school_year_sk` plus the most common filter
  column.
- **Python.** Python 3.11 for tooling. Use `pdfplumber` for PDF extraction and
  `openpyxl` for xlsx.
- **SQL validation.** Validate SQL with `sqlglot` (dialect `databricks`) so the
  validators run locally without a workspace.

## Repo layout

```
sources/                 original PDFs and xlsx (read-only)
catalog/                 files.csv, elements.csv, integrity_rules.csv, code_sets.csv
seeds/ref/               one CSV per code set
sql/bronze/  sql/silver/  sql/ref/  sql/gold/
mapping/                 source_to_target.csv
docs/                    dimensional-design.md, decisions-log.md, erd.md (Mermaid)
tools/                   parsers, generators, validators
tests/
```

## Phases (stop for human review where marked)

### 1. Source catalog

Parse the manual into these outputs:

- **`catalog/elements.csv`**, with columns: `file_code`, `element_id`, `element_name`,
  `field_name`, `data_type`, `size`, `nullable`, `description`, `business_rules`,
  `inline_valid_values`, `appendix_refs`, `validations`, `last_updated`, `is_active`,
  `is_multi_valued`.
- **`catalog/files.csv`**, with file code, name, description, stated grain,
  `is_active`.
- **`catalog/integrity_rules.csv`**: the cross-file rules. Examples:
  - E requires C at the same school and D at the same school.
  - G requires F and D.
  - K requires a disability record in I.
  - Q requires B, C and I.
  - R, S and V require B and C.

Parsing notes, learned from a first pass:

- Page headers like `2026-27 CEDARS Data Manual Page | N` interrupt definitions
  mid-element. Strip them first.
- Element definitions appear twice: once in the table of contents, once in the body.
  Anchor on a heading line `Element X99 – Name` that is followed within a few lines by
  `Field Name:`.
- Element IDs also appear inside business-rule prose (e.g. "Element K15 Non-Public
  Agency is required"). Those are not headings.
- `is_multi_valued` means the business rules allow comma-separated values. Known
  candidates: B43, D07, D17, D20, D21, E15, E16, H13, H31, H32, R09, V10. Verify each.

Expected element counts per file, including inactive elements (validate against these):

| File | A | B | C | D | E | F | G | H | I | J | K | L | M | N | P | Q | R | S | T | U | V |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Elements | 8 | 45 | 14 | 21 | 16 | 9 | 12 | 32 | 10 | 23 | 27 | 6 | 6 | 7 | 24 | 17 | 27 | 14 | 20 | 13 | 10 |

The total is 361.

### 2. Reference data

- Extract every appendix code set into `seeds/ref/<code_set>.csv`, with columns:
  `code`, `description`, plus any hierarchy or rollup columns the appendix provides,
  plus `valid_from_year`, `valid_to_year`.
- Also extract code sets defined inline in the manual's valid values, e.g. N07 absence
  codes, R11 exclusionary actions, B12 gender.
- Register every code set in `catalog/code_sets.csv`, with columns: `code_set`,
  `source`, `appendix`, `status` (`extracted` / `external` / `partial`), `used_by`
  (the element IDs that reference it).

**STOP: human review of the catalog and seeds before phase 3.**

### 3. Silver

- Define the typed silver entities, one per CEDARS file.
- Define the crosswalks:
  - `xref_location`: school year + county district code + Location ID → OSPI school
    code, built from file A.
  - District Student ID → SSID.
  - District Staff ID → certification number, where present.
- Multi-valued elements become `ARRAY<STRING>` in silver.
- Add `silver.student_attribute_history`, holding every reported value of each student
  attribute from each district, for survivorship auditing.

### 4. Gold DDL

- Write the gold DDL exactly as specified in `docs/dimensional-design.md`: facts,
  dimensions, bridges, the mini-dimension and junk dimensions.
- Write `docs/erd.md` in Mermaid, with one diagram per fact family.

### 5. Source-to-target mapping

`mapping/source_to_target.csv`, with columns: `element_id`, `target_table`,
`target_column`, `transformation`, `notes`.

- Every **active** element must either map to at least one target or carry
  `target_table = EXCLUDED` with a reason.
- Inactive elements and File P are listed with `target_table = INACTIVE`.

### 6. Validators (`tools/validate.py`; must pass in CI)

- Every element in the mapping exists in `catalog/elements.csv`, and every active
  element is mapped or excluded.
- Every target table and column in the mapping exists in the DDL.
- Every foreign key in the gold DDL references an existing table and key.
- Every element with an appendix reference or inline valid values has a registered
  code set.
- Every multi-valued element maps to a bridge table in gold.
- All SQL parses under sqlglot's Databricks dialect.

## Working rules

- Keep `docs/decisions-log.md` current, one entry per decision:
  - date
  - decision
  - reason
  - which element IDs it affects
- Never guess code values or business rules. If the documents are ambiguous, log the
  question and ask.
- Deferred items. Do not build these, but do not design them out:
  - prior-year backload and manual-version element crosswalks
  - SSID merge/retirement handling
  - postsecondary (SBCTC/PCHEES) conformance
