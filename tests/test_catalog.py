"""Phase 1 catalog invariants. Run: .venv/bin/python -m pytest tests/"""

import csv
from collections import Counter
from pathlib import Path

import pytest

CATALOG = Path(__file__).resolve().parents[1] / "catalog"

EXPECTED = dict(A=8, B=45, C=14, D=21, E=16, F=9, G=12, H=32, I=10, J=23, K=27, L=6, M=6,
                N=7, P=24, Q=17, R=27, S=14, T=20, U=13, V=10)
MULTI_VALUED = {"B43", "D07", "D17", "D20", "D21", "H13", "H31", "H32", "R09", "T10", "V10"}


def load(name):
    with open(CATALOG / name, newline="") as fh:
        return list(csv.DictReader(fh))


@pytest.fixture(scope="module")
def elements():
    return load("elements.csv")


@pytest.fixture(scope="module")
def files():
    return load("files.csv")


def test_element_counts_per_file(elements):
    assert Counter(e["file_code"] for e in elements) == EXPECTED
    assert len(elements) == 361


def test_element_ids_unique(elements):
    ids = [e["element_id"] for e in elements]
    assert len(ids) == len(set(ids))


def test_required_columns(elements):
    required = ["file_code", "element_id", "element_name", "field_name", "data_type", "size", "nullable",
                "description", "business_rules", "inline_valid_values", "appendix_refs", "validations",
                "last_updated", "is_active", "is_multi_valued"]
    assert all(c in elements[0] for c in required)


def test_every_element_named(elements):
    assert all(e["element_name"] and "no longer an active" not in e["element_name"].lower() for e in elements)


def test_active_elements_have_type_and_nullability(elements):
    for e in elements:
        if e["is_active"] == "Y":
            assert e["field_name"], e["element_id"]
            assert e["data_type"], e["element_id"]
            assert e["nullable"] in {"yes", "no", "conditional"}, e["element_id"]


def test_file_p_inactive(elements, files):
    assert all(e["is_active"] == "N" for e in elements if e["file_code"] == "P")
    assert {f["file_code"]: f["is_active"] for f in files}["P"] == "N"


def test_multi_valued(elements):
    assert {e["element_id"] for e in elements if e["is_multi_valued"] == "Y"} == MULTI_VALUED
    enc = {e["element_id"]: e["multi_value_encoding"] for e in elements if e["is_multi_valued"] == "Y"}
    assert enc["D07"] == enc["H13"] == enc["T10"] == "concatenated"


def test_files(files):
    assert [f["file_code"] for f in files] == sorted(EXPECTED)
    for f in files:
        assert f["stated_grain"], f["file_code"]
        if f["is_active"] == "Y":
            assert f["key_elements"], f["file_code"]
            assert int(f["element_count"]) == EXPECTED[f["file_code"]]


def test_integrity_rules_reference_catalog(elements):
    ids = {e["element_id"] for e in elements}
    rules = load("integrity_rules.csv")
    for r in rules:
        for col in ("child_elements", "parent_elements"):
            for eid in filter(None, r[col].split(",")):
                assert eid in ids, (r["rule_id"], eid)
    pairs = {(r["child_file"], p) for r in rules for p in r["parent_files"].split(",")}
    for pair in [("E", "C"), ("E", "D"), ("G", "F"), ("G", "D"), ("K", "I"), ("Q", "B"), ("Q", "C"),
                 ("Q", "I"), ("R", "B"), ("R", "C"), ("V", "B"), ("V", "C")]:
        assert pair in pairs, pair
