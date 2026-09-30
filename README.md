# CEDARS Kimball data warehouse: framework

This repo holds the framework for a statewide Kimball warehouse on Azure Databricks, built from
the Washington OSPI CEDARS 2026-27 submission manual (v19.0) and its appendices. It does not
include load pipelines. The design is in `docs/dimensional-design.md`, and every decision and
deviation is in `docs/decisions-log.md`.

## Build and validate

```bash
uv venv --python 3.11 .venv && uv pip install --python .venv/bin/python -r requirements.txt
.venv/bin/python tools/build.py      # regenerate everything from sources/
.venv/bin/python tools/validate.py   # phase 6 checks (run in CI)
.venv/bin/python -m pytest -q tests
```

Every artifact below is generated. Change the generator or its spec, never the output.

| Path | What | Generator |
|---|---|---|
| `catalog/elements.csv`, `files.csv` | 361 elements and 21 files from the manual | `tools/parse_manual.py` |
| `catalog/integrity_rules.csv` | cross-file and intra-file rules, each quoted verbatim from the manual | `tools/integrity_rules.py` |
| `seeds/ref/*.csv`, `catalog/code_sets.csv` | every code set: appendix PDF, xlsx appendices and inline values | `tools/extract_code_sets.py` |
| `sql/bronze`, `sql/silver`, `sql/ref` | as-received, typed and code-set DDL | `tools/gen_ddl.py` + `tools/silver_spec.py` |
| `sql/gold`, `docs/erd.md` | star schema, special members, BI views, ERD | `tools/gen_ddl.py` + `tools/gold_spec.py` |
| `sql/deploy_order.txt` | the order to run the SQL files in (foreign-key targets first) | `tools/gen_ddl.py` |
| `mapping/source_to_target.csv` | element → silver/gold column, with the transformation | `tools/gen_mapping.py` |

The catalog name is parameterized as `${catalog}`. The load rules for silver are in
`docs/silver-contract.md`. `p20w_target_model/` is a separate legacy model; nothing here
depends on it.
