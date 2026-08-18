#!/usr/bin/env python3
"""Preflight the composed App Store screenshots against Apple's current specs.

Checked (2026-08 App Store Connect screenshot specifications):
  * iPhone 6.5" slot  -> 1242 x 2688 portrait (also accepts 1284 x 2778)
  * iPad  13"  slot   -> 2064 x 2752 portrait
  * PNG or JPEG, no alpha channel, no transparency
  * 1-10 images per size class
  * every image in a size class is identical in pixel size

Also checked, from this project's rules:
  * every composed image traces back to a raw capture of the same device class
  * no status bar is visible (the whole set crops the same inset)
  * the message band is clean background, no leaked app pixels

Usage:
    python3 store-assets/scripts/preflight_assets.py [locale ...]
"""
from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "output"
CAPTURES = ROOT / "captures" / "ios"

SLOTS = {
    "iphone": {"size": (1242, 2688), "slot": '6.5" iPhone'},
    "ipad": {"size": (2064, 2752), "slot": '13" iPad'},
}
RAW_SIZES = {"iphone": (1320, 2868), "ipad": (2064, 2752)}
# Locales carry 5 slots; ko also has the form-feedback workout screen.
EXPECTED_MIN = 5
MAX_BYTES = 8 * 1024 * 1024


def check_locale(locale: str) -> tuple[list[str], list[str], int]:
    errors: list[str] = []
    notes: list[str] = []
    checked = 0

    for device, spec in SLOTS.items():
        folder = OUTPUT / locale / device
        if not folder.is_dir():
            errors.append(f"{locale}/{device}: output folder missing")
            continue
        images = sorted(folder.glob("*.png"))
        if len(images) < EXPECTED_MIN:
            errors.append(
                f"{locale}/{device}: {len(images)} images, expected at least "
                f"{EXPECTED_MIN}")
        if not 1 <= len(images) <= 10:
            errors.append(f"{locale}/{device}: App Store allows 1-10 per size class")

        sizes = set()
        for path in images:
            rel = path.relative_to(ROOT)
            checked += 1
            with Image.open(path) as image:
                sizes.add(image.size)
                if image.format != "PNG":
                    errors.append(f"{rel}: format {image.format}, expected PNG")
                if image.size != spec["size"]:
                    errors.append(
                        f"{rel}: {image.size}, {spec['slot']} requires {spec['size']}")
                if image.height <= image.width:
                    errors.append(f"{rel}: not portrait")
                if image.mode not in ("RGB", "L"):
                    errors.append(f"{rel}: mode {image.mode} carries an alpha channel")
                if "transparency" in image.info:
                    errors.append(f"{rel}: transparency chunk present")
                rgb = image.convert("RGB")

            # The top message band must be pure background: no app pixels, no
            # leaked system UI. Sample the first 120 rows across the width.
            band = rgb.crop((0, 0, rgb.width, 120))
            distinct = {p for p in band.getdata()}
            if len(distinct) > 40:
                errors.append(
                    f"{rel}: message band has {len(distinct)} colours, "
                    "expected a clean gradient")

            size_bytes = path.stat().st_size
            if size_bytes > MAX_BYTES:
                errors.append(f"{rel}: {size_bytes/1e6:.1f} MB is large for upload")

        if len(sizes) > 1:
            errors.append(f"{locale}/{device}: mixed pixel sizes {sorted(sizes)}")

        raws = sorted((CAPTURES / locale / device).glob("*.png"))
        if not raws:
            errors.append(f"{locale}/{device}: no raw captures")
        for raw in raws:
            with Image.open(raw) as image:
                if image.size != RAW_SIZES[device]:
                    errors.append(
                        f"{raw.relative_to(ROOT)}: raw capture is {image.size}, "
                        f"expected native {RAW_SIZES[device]}")
        notes.append(
            f"{locale}/{device}: {len(images)} images @ {spec['size']} ({spec['slot']})")

    return errors, notes, checked


def cross_device_check(locale: str) -> list[str]:
    """iPhone and iPad output must come from genuinely different captures."""
    errors = []
    for raw in ("01-home", "02-challenge", "03-challenge-detail",
                "04-records", "05-voice-coaching", "06-reminder"):
        phone = CAPTURES / locale / "iphone" / f"{raw}.png"
        pad = CAPTURES / locale / "ipad" / f"{raw}.png"
        if not (phone.exists() and pad.exists()):
            continue
        with Image.open(phone) as a, Image.open(pad) as b:
            if a.size == b.size:
                errors.append(
                    f"{locale}: {raw} iPhone and iPad captures share a size - "
                    "one device layout may have been reused")
    return errors


def main() -> None:
    locales = sys.argv[1:] or sorted(
        p.name for p in OUTPUT.iterdir()
        if p.is_dir() and p.name != "contact-sheet")
    all_errors: list[str] = []
    all_notes: list[str] = []
    total = 0
    for locale in locales:
        errors, notes, checked = check_locale(locale)
        all_errors += errors + cross_device_check(locale)
        all_notes += notes
        total += checked

    print(f"preflight: {total} images across {len(locales)} locale(s)")
    for note in all_notes:
        print(f"  ok  {note}")
    if all_errors:
        print(f"\n{len(all_errors)} problem(s):")
        for error in all_errors:
            print(f"  FAIL  {error}")
        raise SystemExit(1)
    print("\nall checks passed")


if __name__ == "__main__":
    main()
