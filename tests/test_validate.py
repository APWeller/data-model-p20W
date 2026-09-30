"""The validator must pass on the repo and catch each class of defect (mutation tests)."""

import copy
import sys
from pathlib import Path

import pytest
import sqlglot

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import validate as v  # noqa: E402


@pytest.fixture(scope="module")
def repo():
    elements = {r["element_id"]: r for r in v.load("catalog/elements.csv")}
    mapping = v.load("mapping/source_to_target.csv")
    code_sets = v.load("catalog/code_sets.csv")
    sql_errors, tables, _ = v.parse_sql()
    return dict(elements=elements, mapping=mapping, code_sets=code_sets, sql_errors=sql_errors, tables=tables)


def test_repo_passes(repo):
    assert v.check_mapping(repo["elements"], repo["mapping"]) == []
    assert v.check_targets(repo["mapping"], repo["tables"]) == []
    assert v.check_fks(repo["tables"]) == []
    assert v.check_code_sets(repo["elements"], repo["code_sets"]) == []
    assert v.check_bridges(repo["elements"], repo["mapping"]) == []
    assert repo["sql_errors"] == []
    assert v.check_conventions(repo["tables"]) == []
    assert v.main() == 0


def test_catches_unmapped_active_element(repo):
    mapping = [r for r in repo["mapping"] if r["element_id"] != "B12"]
    assert any("B12" in e for e in v.check_mapping(repo["elements"], mapping))


def test_catches_unknown_element_and_bad_inactive(repo):
    mapping = copy.deepcopy(repo["mapping"])
    mapping.append({"element_id": "Z99", "target_table": "gold.dim_student", "target_column": "ssid",
                    "transformation": "", "notes": ""})
    mapping.append({"element_id": "P05", "target_table": "gold.dim_school", "target_column": "school_code",
                    "transformation": "", "notes": ""})
    errs = v.check_mapping(repo["elements"], mapping)
    assert any("Z99" in e for e in errs) and any("P05" in e for e in errs)


def test_catches_excluded_without_reason(repo):
    mapping = [r for r in repo["mapping"] if r["element_id"] != "B12"]
    mapping.append({"element_id": "B12", "target_table": "EXCLUDED", "target_column": "", "transformation": "",
                    "notes": ""})
    assert any("without a reason" in e for e in v.check_mapping(repo["elements"], mapping))


def test_catches_missing_target_column(repo):
    mapping = copy.deepcopy(repo["mapping"])
    mapping[0]["target_column"] = "no_such_column"
    assert v.check_targets(mapping, repo["tables"])


def test_catches_broken_fk(repo):
    tables = dict(repo["tables"])
    stmt = sqlglot.parse_one(
        "CREATE TABLE cedars.gold.fact_bad (x_sk BIGINT NOT NULL, y_sk BIGINT NOT NULL, "
        "CONSTRAINT a FOREIGN KEY (x_sk) REFERENCES cedars.gold.dim_missing (x_sk), "
        "CONSTRAINT b FOREIGN KEY (y_sk) REFERENCES cedars.gold.dim_student (ssid))", read="databricks")
    tables["gold.fact_bad"] = {"cols": {c.name: c for c in stmt.find_all(sqlglot.exp.ColumnDef)}, "stmt": stmt}
    errs = v.check_fks(tables)
    assert any("dim_missing" in e for e in errs) and any("not its primary key" in e for e in errs)


def test_catches_unregistered_code_set(repo):
    code_sets = [r for r in repo["code_sets"] if r["code_set"] != "gender"]
    assert any(e.startswith("B12") for e in v.check_code_sets(repo["elements"], code_sets))


def test_catches_multi_valued_without_bridge(repo):
    mapping = [r for r in repo["mapping"] if not (r["element_id"] == "R09" and "bridge_" in r["target_table"])]
    assert any("R09" in e for e in v.check_bridges(repo["elements"], mapping))


def test_catches_unparseable_sql(tmp_path, monkeypatch):
    monkeypatch.setattr(v, "SQL", tmp_path)
    for bad in ("CREATE TABLE ${catalog}.gold.x (a STRING", "CREATE TABL ${catalog}.gold.x (a STRING)"):
        (tmp_path / "bad.sql").write_text(bad)
        errs, _, _ = v.parse_sql()
        assert errs, bad
