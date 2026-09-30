"""Phase 2 code-set invariants. Run: .venv/bin/python -m pytest tests/"""

import csv
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parents[1]
SEEDS = REPO / "seeds" / "ref"


def load(path):
    with open(path, newline="") as fh:
        return list(csv.DictReader(fh))


@pytest.fixture(scope="module")
def registry():
    return {r["code_set"]: r for r in load(REPO / "catalog" / "code_sets.csv")}


@pytest.fixture(scope="module")
def elements():
    return {r["element_id"]: r for r in load(REPO / "catalog" / "elements.csv")}


def seed(name):
    return load(SEEDS / f"{name}.csv")


def codes(name, **flt):
    return {r["code"] for r in seed(name) if all(r.get(k) == v for k, v in flt.items())}


def test_registry_statuses(registry):
    assert {r["status"] for r in registry.values()} <= {"extracted", "external", "partial", "retired"}


def test_seed_files_match_registry(registry):
    extracted = {k for k, r in registry.items() if r["status"] in ("extracted", "partial")}
    assert extracted == {p.stem for p in SEEDS.glob("*.csv")}
    for k in extracted:
        assert len(seed(k)) == int(registry[k]["row_count"]) > 0, k


def test_seed_columns(registry):
    for k, r in registry.items():
        if r["seed_file"]:
            cols = list(seed(k)[0].keys())
            assert cols[:2] == ["code", "description"], k
            assert cols[-2:] == ["valid_from_year", "valid_to_year"], k


def test_no_blank_codes_or_descriptions(registry):
    for k, r in registry.items():
        if r["seed_file"]:
            for row in seed(k):
                assert row["code"].strip(), k
                assert row["description"].strip() or k == "el_placement_level_score", (k, row["code"])


def test_years_are_school_year_end(registry):
    for k, r in registry.items():
        if r["seed_file"]:
            for row in seed(k):
                for c in ("valid_from_year", "valid_to_year"):
                    assert row[c] == "" or (len(row[c]) == 4 and row[c].isdigit()), (k, c, row[c])


def test_every_coded_element_registered(registry, elements):
    covered = set()
    for r in registry.values():
        covered |= set(filter(None, r["referenced_by"].split(",")))
    for eid, e in elements.items():
        if e["appendix_refs"] or e["inline_valid_values"]:
            assert eid in covered, eid


def test_every_appendix_registered(registry):
    appx = {r["appendix"] for r in registry.values() if r["appendix"]}
    letters = [chr(c) for c in range(ord("A"), ord("Z") + 1)] + ["A" + chr(c) for c in range(ord("A"), ord("M") + 1)]
    assert set(letters) <= appx


def test_external_appendices_have_no_invented_values(registry):
    for code_set in ("county_district", "school"):
        assert registry[code_set]["status"] == "external"
        assert not (SEEDS / f"{code_set}.csv").exists()


# ---- cross-checks between the manual's inline lists and the appendices -------------------

def inline(elements, eid):
    return {p.split("=", 1)[0] for p in elements[eid]["inline_valid_values"].split("|")}


def test_r10_matches_appendix_d(elements):
    assert inline(elements, "R10") == codes("weapon")


def test_q06_subset_of_appendix_f(elements):
    assert inline(elements, "Q06") <= codes("attribute_program", status="active")


def test_j21_statuses_match_appendix_n(elements):
    assert inline(elements, "J21") == codes("el_placement_status")
    tests = {r["placement_test_code"] for r in seed("el_placement_status")}
    assert tests == inline(elements, "J18")


def test_d06_values_in_current_content_area(elements):
    current = {r["code"] for r in seed("content_area") if not r["valid_to_year"]}
    assert inline(elements, "D06") == current == {"123", "ZZZ"}


def test_xlsx_code_formats():
    sc = codes("state_course")
    assert "01001" in sc and "1001" not in sc          # zero-padded SCED codes
    assert "21063" in sc and "WA0005" in sc
    assert all(len(c) == 6 for c in codes("cip"))
    assert all(r["subject_area_code"] == "" or len(r["subject_area_code"]) == 2 for r in seed("state_course"))
    assert {r["subject_area_code"] for r in seed("state_course")} - {""} <= codes("course_subject_area")


def test_known_counts():
    assert len(codes("behavior")) == 23
    assert len(seed("race")) == 229
    assert len(seed("ethnicity")) == 30
    assert len(seed("staff_type")) == 59
    assert len(seed("lre")) == 25
    assert len(seed("term")) == 27
    assert len(seed("el_placement_status")) == 77
    assert codes("course_designation") >= {"A", "I", "C", "T", "O", "Z"}


def test_i10_map_targets_registered(registry):
    for r in load(REPO / "catalog" / "i10_qualification_map.csv"):
        assert r["i10_code_set"] in registry
        assert r["i06_code"] in codes("attribute_program", status="active")
