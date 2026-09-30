"""Phase 3+ DDL invariants. Run: .venv/bin/python -m pytest tests/"""

import csv
import re
from pathlib import Path

import pytest
import sqlglot
from sqlglot import exp

REPO = Path(__file__).resolve().parents[1]
SQL = REPO / "sql"


def load(path):
    with open(path, newline="") as fh:
        return list(csv.DictReader(fh))


def tables(layer):
    out = {}
    for f in sorted((SQL / layer).glob("*.sql")):
        for stmt in sqlglot.parse(f.read_text().replace("${catalog}", "cedars"), read="databricks"):
            if isinstance(stmt, exp.Create) and stmt.kind == "TABLE":
                out[stmt.this.this.name] = stmt
    return out


@pytest.fixture(scope="module")
def silver():
    return tables("silver")


def cols(stmt):
    return {c.name: c for c in stmt.find_all(exp.ColumnDef)}


def comment(coldef):
    c = coldef.find(exp.CommentColumnConstraint)
    return c.this.name if c else ""


def test_all_sql_parses():
    for f in sorted(SQL.rglob("*.sql")):
        assert sqlglot.parse(f.read_text().replace("${catalog}", "cedars"), read="databricks"), f


def test_catalog_parameterized():
    for f in SQL.rglob("*.sql"):
        for fqn in re.findall(r"(?:TABLE IF NOT EXISTS|SCHEMA IF NOT EXISTS|REFERENCES)\s+(\S+)", f.read_text()):
            assert fqn.startswith("${catalog}."), (f, fqn)


def test_every_active_element_in_silver(silver):
    act = {r["element_id"] for r in load(REPO / "catalog" / "elements.csv") if r["is_active"] == "Y"}
    lineage = load(REPO / "catalog" / "silver_columns.csv")
    assert act <= {r["element_id"] for r in lineage}
    for r in lineage:
        assert r["silver_column"] in cols(silver[r["silver_table"]]), r


def test_silver_columns_commented(silver):
    for t, stmt in silver.items():
        for name, c in cols(stmt).items():
            assert re.match(r"^(CEDARS [A-V*]|Derived:|Load metadata:)", comment(c)), (t, name)


def test_multi_valued_are_arrays(silver):
    lineage = {(r["element_id"], r["silver_column"]): r for r in load(REPO / "catalog" / "silver_columns.csv")}
    for e in load(REPO / "catalog" / "elements.csv"):
        if e["is_multi_valued"] == "Y" and e["is_active"] == "Y":
            arr = [r for (eid, _), r in lineage.items() if eid == e["element_id"] and "multi-valued" in r["transformation"]]
            assert arr, e["element_id"]
            c = cols(silver[arr[0]["silver_table"]])[arr[0]["silver_column"]]
            assert c.args["kind"].this == exp.DataType.Type.ARRAY, e["element_id"]


def test_primary_keys_not_null(silver):
    for t, stmt in silver.items():
        pk = stmt.find(exp.PrimaryKey)
        assert pk is not None, t
        c = cols(stmt)
        for k in pk.expressions:
            assert c[k.name].find(exp.NotNullColumnConstraint) is not None, (t, k.name)


def test_metadata_columns_everywhere():
    for layer in ("bronze", "silver"):
        for t, stmt in tables(layer).items():
            names = set(cols(stmt))
            assert {"_source_file", "_school_year", "_manual_version", "_submission_type", "_load_ts"} <= names, t


# ---- gold -------------------------------------------------------------------------------

@pytest.fixture(scope="module")
def gold():
    return tables("gold")


def pk_cols(stmt):
    pk = stmt.find(exp.PrimaryKey)
    return [k.name for k in pk.expressions] if pk else []


def test_gold_foreign_keys_resolve(gold):
    for t, stmt in gold.items():
        for fk in stmt.find_all(exp.ForeignKey):
            ref = fk.args["reference"].this
            target = ref.this.this.name
            ref_cols = [c.name for c in ref.expressions]
            assert target in gold, (t, target)
            assert ref_cols == pk_cols(gold[target]), (t, target, ref_cols)
            for c in fk.expressions:
                assert c.name in cols(stmt), (t, c.name)


def test_gold_keys_and_comments(gold):
    for t, stmt in gold.items():
        c = cols(stmt)
        assert pk_cols(stmt), t
        for k in pk_cols(stmt):
            assert c[k].find(exp.NotNullColumnConstraint) is not None, (t, k)
        for name, cd in c.items():
            assert comment(cd), (t, name)
        assert {"_manual_version", "_load_ts"} <= set(c), t


def test_gold_naming(gold):
    for t in gold:
        assert re.match(r"^(fact|dim|bridge)_", t), t
    for t, stmt in gold.items():
        for name, cd in cols(stmt).items():
            if name.endswith("_date_sk") or name == "date_sk":
                assert cd.args["kind"].this == exp.DataType.Type.INT, (t, name)
            elif name.endswith("_sk"):
                assert cd.args["kind"].this == exp.DataType.Type.BIGINT, (t, name)


def test_fact_clustering(gold):
    for t, stmt in gold.items():
        if t.startswith("fact_"):
            assert "CLUSTER BY (school_year_sk" in stmt.sql("databricks"), t


def test_multi_valued_elements_have_bridges():
    gc = load(REPO / "catalog" / "gold_columns.csv")
    bridged = {e for r in gc if r["gold_table"].startswith("bridge_") for e in r["element_ids"].split(",")}
    for e in load(REPO / "catalog" / "elements.csv"):
        if e["is_multi_valued"] == "Y" and e["is_active"] == "Y":
            assert e["element_id"] in bridged, e["element_id"]


def test_deploy_order():
    order = (SQL / "deploy_order.txt").read_text().split()
    assert set(order) == {str(p.relative_to(SQL)) for p in SQL.rglob("*.sql")}
    pos = {o: i for i, o in enumerate(order)}
    for t, stmt in tables("gold").items():
        for fk in stmt.find_all(exp.ForeignKey):
            target = fk.args["reference"].this.this.this.name
            if target != t and {t, target} != {"dim_date", "dim_school_year"}:
                assert pos[f"gold/{target}.sql"] < pos[f"gold/{t}.sql"], (t, target)
