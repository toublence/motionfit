#!/usr/bin/env python3
"""Compose App Store screenshots from raw iOS simulator captures.

Allowed operations only: cropping, uniform proportional scaling, corner
masking, and placing the untouched capture on a flat gradient with headline
text. No pixel inside the app screenshot is redrawn, recoloured, or generated.

Usage:
    python3 store-assets/scripts/compose_store_assets.py [locale ...]
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
CAPTURES = ROOT / "captures" / "ios"
OUTPUT = ROOT / "output"
COPY = ROOT / "copy.json"

# Per-locale type. Apple SD Gothic Neo covers Hangul and kana but drops some
# accented Latin glyphs, so Latin locales use Helvetica Neue. Arabic uses Al Nile,
# which carries both Arabic letters and Western digits (Damascus and Geeza Pro
# have the letters but not the digits). Arabic also needs shaping and bidi reordering here, because this
# Pillow build has no Raqm complex-text layout.
FONTS = {
    "ko": (("/System/Library/Fonts/AppleSDGothicNeo.ttc", 6),
           ("/System/Library/Fonts/AppleSDGothicNeo.ttc", 2)),
    "ja": (("/System/Library/Fonts/AppleSDGothicNeo.ttc", 6),
           ("/System/Library/Fonts/AppleSDGothicNeo.ttc", 2)),
    "zh": (("/System/Library/Fonts/Supplemental/Songti.ttc", 1),
           ("/System/Library/Fonts/Supplemental/Songti.ttc", 6)),
    "zh_Hant": (("/System/Library/Fonts/Supplemental/Songti.ttc", 2),
                ("/System/Library/Fonts/Supplemental/Songti.ttc", 7)),
    # Arabic: Tahoma is the only installed family that carries BOTH the Arabic
    # presentation forms the reshaper emits and Western digits. Damascus and
    # Geeza Pro have the letters but no digits; Al Nile has digits but not the
    # presentation forms.
    "ar": (("/System/Library/Fonts/Supplemental/Tahoma Bold.ttf", 0),
           ("/System/Library/Fonts/Supplemental/Tahoma.ttf", 0)),
    "_latin": (("/System/Library/Fonts/HelveticaNeue.ttc", 1),
               ("/System/Library/Fonts/HelveticaNeue.ttc", 0)),
}


def font_spec(locale: str, bold: bool) -> tuple[str, int]:
    bold_face, medium_face = FONTS.get(locale, FONTS["_latin"])
    return bold_face if bold else medium_face


def shape(text: str, locale: str) -> str:
    if locale != "ar":
        return text
    import arabic_reshaper
    from bidi.algorithm import get_display
    return get_display(arabic_reshaper.reshape(text))


GRADIENT_TOP = (46, 90, 133)
GRADIENT_BOTTOM = (24, 48, 72)
HEADLINE_COLOR = (255, 255, 255)
SUBTITLE_COLOR = (198, 218, 238)

DEVICES = {
    # 6.5" slot. Raw captures stay at the iPhone 17 Pro Max native 1320 x 2868
    # and are scaled down proportionally onto this canvas.
    "iphone": {
        "canvas": (1242, 2688),
        "text_band": 0.28,
        "headline_size": 90,
        "subtitle_size": 43,
        "side_margin": 90,
        "bottom_margin": 90,
        "radius_ratio": 0.05,
        "status_bar_inset": 186,
    },
    "ipad": {
        "canvas": (2064, 2752),
        "text_band": 0.26,
        "headline_size": 116,
        "subtitle_size": 56,
        "side_margin": 150,
        "bottom_margin": 110,
        "radius_ratio": 0.05,
        "status_bar_inset": 48,
    },
}

# Store order -> raw capture. `crop` is an optional box in raw-capture pixels;
# when present it replaces the default status-bar crop (the box already
# excludes the status bar). See storyboard.md.
#
# Slots 01/02 are the live workout screens. The counter, the pose skeleton and
# the feedback colour in those captures are all rendered by the app itself,
# driven through the production rep detector and form classifier by a
# landmark-only replay sequence. The body under the skeleton is an illustrated
# figure drawn onto the flat camera placeholder by scripts/add_figure.py - no
# app pixel is altered. See edit-log.md.
SCENES = [
    ("01-auto-count", "00-auto-count", None),
    ("02-form-analysis", "00-form-analysis", None),
    ("03-challenge", "02-challenge", None),
    ("04-sets-rest", "01-home", None),
    ("05-workout-result", "04-records", {
        "iphone": (32, 1390, 1288, 2680),
        "ipad": (330, 855, 1734, 1760),
    }),
    ("06-history", "04-records", None),
]


def gradient(size: tuple[int, int]) -> Image.Image:
    width, height = size
    base = Image.new("RGB", (1, height))
    draw = ImageDraw.Draw(base)
    for y in range(height):
        ratio = y / max(height - 1, 1)
        draw.point((0, y), fill=tuple(
            round(GRADIENT_TOP[i] + (GRADIENT_BOTTOM[i] - GRADIENT_TOP[i]) * ratio)
            for i in range(3)
        ))
    return base.resize((width, height), Image.BILINEAR)


def fit_font(text: str, size: int, max_width: int, locale: str,
             bold: bool) -> ImageFont.FreeTypeFont:
    """Shrink until the line fits; headlines must never wrap to 3 lines."""
    path, index = font_spec(locale, bold)
    while size > 24:
        font = ImageFont.truetype(path, size, index=index)
        if font.getbbox(text)[2] - font.getbbox(text)[0] <= max_width:
            return font
        size -= 2
    return ImageFont.truetype(path, size, index=index)


def rounded(image: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, image.width - 1, image.height - 1), radius=radius, fill=255)
    out = image.convert("RGBA")
    out.putalpha(mask)
    return out


def compose(capture: Path, headline: str, subtitle: str, spec: dict,
            crop_box: tuple[int, int, int, int] | None = None,
            locale: str = "en") -> Image.Image:
    canvas_w, canvas_h = spec["canvas"]
    canvas = gradient((canvas_w, canvas_h))

    band = round(canvas_h * spec["text_band"])
    max_text_width = canvas_w - spec["side_margin"] * 2
    draw = ImageDraw.Draw(canvas)

    headline = shape(headline, locale)
    subtitle = shape(subtitle, locale)
    headline_font = fit_font(headline, spec["headline_size"], max_text_width,
                             locale, bold=True)
    subtitle_font = fit_font(subtitle, spec["subtitle_size"], max_text_width,
                             locale, bold=False)

    head_h = headline_font.getbbox(headline)[3] - headline_font.getbbox(headline)[1]
    sub_h = subtitle_font.getbbox(subtitle)[3] - subtitle_font.getbbox(subtitle)[1]
    gap = round(spec["headline_size"] * 0.45)
    block_h = head_h + gap + sub_h
    top = round((band - block_h) / 2)

    draw.text((canvas_w / 2, top), headline, font=headline_font,
              fill=HEADLINE_COLOR, anchor="ma")
    draw.text((canvas_w / 2, top + head_h + gap), subtitle, font=subtitle_font,
              fill=SUBTITLE_COLOR, anchor="ma")

    shot = Image.open(capture).convert("RGB")
    if crop_box is not None:
        # Scene-specific crop. The box already sits below the status bar, so it
        # satisfies the same gate: no status bar is visible anywhere in the set.
        shot = shot.crop(crop_box)
    else:
        # Status-bar gate: the app renders light-content status bar glyphs on a
        # light background (AppBarTheme has no systemOverlayStyle), so the bar
        # is effectively invisible. Rather than redraw system UI - forbidden -
        # the same inset is cropped off every capture so no status bar shows.
        shot = shot.crop((0, spec["status_bar_inset"], shot.width, shot.height))
    available_h = canvas_h - band - spec["bottom_margin"]
    available_w = canvas_w - spec["side_margin"] * 2
    scale = min(available_h / shot.height, available_w / shot.width)
    target = (round(shot.width * scale), round(shot.height * scale))
    shot = shot.resize(target, Image.LANCZOS)
    radius = round(target[0] * spec["radius_ratio"])
    shot = rounded(shot, radius)

    x = round((canvas_w - target[0]) / 2)
    # Centre vertically in the app area so cropped scenes do not leave a large
    # dead band at the bottom. Full-screen scenes fill the area and are unmoved.
    y = band + round((available_h - target[1]) / 2)

    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (x, y + 18, x + target[0], y + target[1] + 18),
        radius=radius, fill=(0, 0, 0, 110))
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow)
    canvas.paste(shot, (x, y), shot)
    return canvas.convert("RGB")


def main() -> None:
    copy = json.loads(COPY.read_text(encoding="utf-8"))
    locales = sys.argv[1:] or sorted(copy)
    written = 0
    for locale in locales:
        if locale not in copy:
            raise SystemExit(f"no copy for locale {locale}")
        for device, spec in DEVICES.items():
            folder = OUTPUT / locale / device
            folder.mkdir(parents=True, exist_ok=True)
            for out_name, raw_name, crops in SCENES:
                capture = CAPTURES / locale / device / f"{raw_name}.png"
                if not capture.exists():
                    print(f"  SKIP {locale}/{device}/{out_name}: "
                          f"no capture {raw_name}.png")
                    continue
                entry = copy[locale].get(out_name)
                if entry is None:
                    continue
                crop_box = crops[device] if crops else None
                image = compose(capture, entry["headline"], entry["subtitle"],
                                spec, crop_box, locale)
                destination = folder / f"{out_name}.png"
                image.save(destination, "PNG")
                written += 1
                print(f"  {destination.relative_to(ROOT)}  {image.size}")
    print(f"composed {written} images")


if __name__ == "__main__":
    main()
