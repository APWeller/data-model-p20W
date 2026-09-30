"""Regenerate every artifact from sources/ in dependency order.

Usage:  python tools/build.py
"""

import subprocess
import sys
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
STEPS = [
    "parse_manual.py",       # catalog/elements.csv, catalog/files.csv          (phase 1)
    "integrity_rules.py",    # catalog/integrity_rules.csv                       (phase 1)
    "extract_code_sets.py",  # seeds/ref/*.csv, catalog/code_sets.csv            (phase 2)
    "gen_ddl.py",            # sql/**, docs/erd.md, catalog/*_columns.csv        (phases 3-4)
    "gen_mapping.py",        # mapping/source_to_target.csv                      (phase 5)
]

for step in STEPS:
    print(f"== {step}", flush=True)
    rc = subprocess.run([sys.executable, str(TOOLS / step)]).returncode
    if rc:
        sys.exit(f"{step} failed with exit code {rc}")
