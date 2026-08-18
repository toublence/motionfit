#!/usr/bin/env python3
"""Build 22% contact sheets so headline legibility can be judged at thumbnail size.

Usage:
    python3 store-assets/scripts/contact_sheet.py [locale ...]
"""
from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "output"
SHEETS = OUTPUT / "contact-sheet"
SCALE = 0.22
GAP = 24
BACKGROUND = (255, 255, 255)


def build(locale: str, device: str) -> Path | None:
    folder = OUTPUT / locale / device
    images = sorted(folder.glob("*.png"))
    if not images:
        return None
    thumbs = []
    for path in images:
        with Image.open(path) as image:
            size = (round(image.width * SCALE), round(image.height * SCALE))
            thumbs.append(image.convert("RGB").resize(size, Image.LANCZOS))
    width = sum(t.width for t in thumbs) + GAP * (len(thumbs) + 1)
    height = max(t.height for t in thumbs) + GAP * 2
    sheet = Image.new("RGB", (width, height), BACKGROUND)
    x = GAP
    for thumb in thumbs:
        sheet.paste(thumb, (x, GAP))
        x += thumb.width + GAP
    SHEETS.mkdir(parents=True, exist_ok=True)
    destination = SHEETS / f"{locale}-{device}.jpg"
    sheet.save(destination, "JPEG", quality=88)
    return destination


def main() -> None:
    locales = sys.argv[1:] or sorted(
        p.name for p in OUTPUT.iterdir() if p.is_dir() and p.name != "contact-sheet")
    for locale in locales:
        for device in ("iphone", "ipad"):
            path = build(locale, device)
            if path:
                with Image.open(path) as image:
                    print(f"  {path.relative_to(ROOT)}  {image.size}")


if __name__ == "__main__":
    main()
