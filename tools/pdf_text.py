"""Shared PDF text extraction with a local cache.

pdfplumber is slow on the 217-page manual, so extracted text is cached next to the
repo in `.cache/` (git-ignored) keyed by file size and mtime.
"""

from __future__ import annotations

import hashlib
import re
from pathlib import Path

import pdfplumber

REPO = Path(__file__).resolve().parents[1]
CACHE = REPO / ".cache"

PAGE_MARK = re.compile(r"^<<<PAGE (\d+)>>>$")


def extract_pages(pdf_path: Path) -> list[str]:
    """Return the text of each page (index 0 = page 1)."""
    st = pdf_path.stat()
    key = hashlib.sha1(f"{pdf_path.name}|{st.st_size}|{st.st_mtime_ns}".encode()).hexdigest()[:12]
    cached = CACHE / f"{pdf_path.stem}.{key}.txt"
    if cached.exists():
        text = cached.read_text()
    else:
        with pdfplumber.open(pdf_path) as pdf:
            text = "\n".join(
                f"<<<PAGE {i}>>>\n{p.extract_text() or ''}" for i, p in enumerate(pdf.pages, 1)
            )
        CACHE.mkdir(exist_ok=True)
        cached.write_text(text)
    pages: list[str] = []
    for chunk in text.split("<<<PAGE ")[1:]:
        _, _, body = chunk.partition(">>>\n")
        pages.append(body)
    return pages


def lines_with_pages(pages: list[str], header_re: re.Pattern[str]) -> list[tuple[int, str]]:
    """Flatten pages to (page_no, line), dropping running page headers/footers."""
    out: list[tuple[int, str]] = []
    for pno, text in enumerate(pages, 1):
        for line in text.splitlines():
            if header_re.match(line.strip()):
                continue
            out.append((pno, line.rstrip()))
    return out
