# p20w_target_model

Three candidate gold-layer data models for the P-20W ODS → Databricks migration, generated from `../allDataElements.csv`.

Start with **`P20W_Gold_Data_Model_Options.md`**. It covers the findings, shared foundations (identity, organization mastering, SCD, governance), Models A/B/C, query comparisons, the comparison matrix and open decisions.

| Folder | Contents |
|---|---|
| `lineage/` | Column-level source-to-target crosswalks per model, reverse coverage by inventory row, table catalogs (grain/key/SCD), Model C table assignment, validation report |
| `governance/` | Column governance tiers and Unity Catalog tag DDL per model |
| `ddl/` | Delta `CREATE TABLE` scripts per model |
| `org_mastering/` | Organization / xwalk / lineage seed rows for documented CTC events |
| `reference/ceds_v14/` | CEDS-IDS, CEDS-DW v14.1 table/column extracts and CEDS v14 element list used for validation |
| `scripts/` | Routing spec and generator |

Regenerate everything with:

```bash
python3 scripts/build.py
```

The build fails if an inventory table is unrouted, if any in-scope row has no target in a model, or if a Model A `ceds_rds` table does not exist in CEDS DW v14.1. It also re-homes non-CEDS columns to `_WaExt` and reports them.
