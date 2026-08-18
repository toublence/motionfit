#!/usr/bin/env python3
"""Put the reference photo behind the app's own workout overlay.

Two captures of the same app frame are taken, identical except for the flat
colour painted where the camera preview would be: one on black, one on white.
Comparing them recovers, per pixel, exactly how much of that flat colour is
still visible through everything the app drew — including the semi-transparent
counter card. The photo is then substituted for the flat colour at exactly that
strength.

    capture_black = a*O
    capture_white = a*O + (1 - a)*255      =>  1 - a = (white - black)/255
    result        = a*O + (1 - a)*photo    =   black + (1 - a)*photo

So every pixel the app rendered keeps its own colour and its own translucency.
Nothing the app drew is repainted, recoloured or redrawn.

The skeleton already lands on the photo's joints: the replay sequence that drove
the app was built from this photo's landmark positions
(lib/features/squat/data/shot_replay_source.dart).

Usage:
    python3 store-assets/scripts/add_figure.py \
        <capture-black.png> <capture-white.png> <photo.png> <out.png>
"""
from __future__ import annotations

import argparse

from PIL import Image, ImageChops, ImageFilter


def cover(photo: Image.Image, size: tuple[int, int]) -> Image.Image:
    width, height = size
    scale = max(width / photo.width, height / photo.height)
    resized = photo.resize(
        (round(photo.width * scale), round(photo.height * scale)),
        Image.LANCZOS)
    left = (resized.width - width) // 2
    top = (resized.height - height) // 2
    return resized.crop((left, top, left + width, top + height))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("black")
    parser.add_argument("white")
    parser.add_argument("photo")
    parser.add_argument("destination")
    args = parser.parse_args()

    black = Image.open(args.black).convert("RGB")
    white = Image.open(args.white).convert("RGB")
    if black.size != white.size:
        raise SystemExit(f"captures differ in size: {black.size} vs {white.size}")
    photo = cover(Image.open(args.photo).convert("RGB"), black.size)

    # Visibility of the flat colour, per pixel: 1 - a.
    visible = ImageChops.difference(white, black).convert("L")
    visible = visible.filter(ImageFilter.MedianFilter(3))

    # result = black + (1 - a) * photo
    scaled_photo = Image.merge("RGB", [
        ImageChops.multiply(channel, visible) for channel in photo.split()
    ])
    out = ImageChops.add(black, scaled_photo)
    out.save(args.destination, "PNG")

    coverage = sum(visible.getdata()) / (255 * visible.width * visible.height)
    print(f"{args.destination}  {out.size}  photo visible {coverage:.1%}")


if __name__ == "__main__":
    main()
