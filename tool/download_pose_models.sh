#!/bin/sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
download_directory="${TMPDIR:-/tmp}/motionfit_pose_models"
android_assets="$repository_root/packages/motionfit_pose/android/src/main/assets"
ios_assets="$repository_root/packages/motionfit_pose/ios/Assets"

lite_name="pose_landmarker_lite.task"
heavy_name="pose_landmarker_heavy.task"
full_name="pose_landmarker_full.task"
lite_sha256="59929e1d1ee95287735ddd833b19cf4ac46d29bc7afddbbf6753c459690d574a"
heavy_sha256="64437af838a65d18e5ba7a0d39b465540069bc8aae8308de3e318aad31fcbc7b"
full_sha256="4eaa5eb7a98365221087693fcc286334cf0858e2eb6e15b506aa4a7ecdcec4ad"
lite_url="https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/latest/$lite_name"
heavy_url="https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_heavy/float16/latest/$heavy_name"
full_url="https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_full/float16/latest/$full_name"

mkdir -p "$download_directory" "$android_assets" "$ios_assets"

curl --fail --location --silent --show-error "$lite_url" \
  --output "$download_directory/$lite_name"
curl --fail --location --silent --show-error "$heavy_url" \
  --output "$download_directory/$heavy_name"
curl --fail --location --silent --show-error "$full_url" \
  --output "$download_directory/$full_name"

printf '%s  %s\n' "$lite_sha256" "$download_directory/$lite_name" \
  | shasum -a 256 -c -
printf '%s  %s\n' "$heavy_sha256" "$download_directory/$heavy_name" \
  | shasum -a 256 -c -
printf '%s  %s\n' "$full_sha256" "$download_directory/$full_name" \
  | shasum -a 256 -c -

install -m 0644 "$download_directory/$lite_name" "$android_assets/$lite_name"
install -m 0644 "$download_directory/$heavy_name" "$android_assets/$heavy_name"
install -m 0644 "$download_directory/$full_name" "$android_assets/$full_name"
install -m 0644 "$download_directory/$lite_name" "$ios_assets/$lite_name"
install -m 0644 "$download_directory/$heavy_name" "$ios_assets/$heavy_name"
install -m 0644 "$download_directory/$full_name" "$ios_assets/$full_name"

cmp "$android_assets/$lite_name" "$ios_assets/$lite_name"
cmp "$android_assets/$heavy_name" "$ios_assets/$heavy_name"
cmp "$android_assets/$full_name" "$ios_assets/$full_name"

printf '%s\n' "MediaPipe Lite, Full, and Heavy pose models installed for Android and iOS."
