# MotionFit - Squat 스토어 스크린샷

App Store용 스크린샷을 **실제 iOS/iPadOS 시뮬레이터 캡처**만으로 만든다.
생성형 이미지, 목업, 합성 인물, 합성 포즈 라인을 일절 쓰지 않는다.

빌드 1.1.0 (10) / 커밋 `eb0e807` / 언어 en(기준)·ko / iPhone 6.9" + iPad 13".

**현재 상태: 6슬롯 중 4슬롯 생성 완료.** 1·2번(자동 카운트, 실시간 자세 분석)은 실기기 카메라 캡처가 있어야 만들 수 있어 **의도적으로 비워 두었다.** 목업이나 생성 이미지로 채우지 않았다. 해제 절차는 [storyboard.md](storyboard.md) 마지막 절 참조.

## 문서

| 파일 | 내용 |
|---|---|
| [storyboard.md](storyboard.md) | 화면 순서, 헤드라인·부제목, 기본 순서를 바꾼 이유 |
| [evidence.md](evidence.md) | 기능 주장 ↔ 소스·실행·캡처 대응표, 사용하지 않은 주장 |
| [capture-manifest.md](capture-manifest.md) | 빌드·기기·OS·캡처 방법·시드 내역 |
| [edit-log.md](edit-log.md) | 원본에 적용한 작업 전부, 상태 표시줄 처리 |
| [qa-report.md](qa-report.md) | 최종 QA 게이트, 권한 흐름 점검, 남은 리젝 위험 |
| [RESTORE-ME.md](RESTORE-ME.md) | 스크린샷용 임시 변경과 복구 상태 |

## 재현

```sh
# 1. 광고 게이트를 임시로 올리고 (RESTORE-ME.md 참조) 빌드
flutter build ios --simulator --debug

# 2. 두 시뮬레이터에 설치하고 상태 표시줄 정리
xcrun simctl install <UDID> build/ios/iphonesimulator/Runner.app
xcrun simctl status_bar <UDID> override --time "9:41" --batteryState charged \
  --batteryLevel 100 --wifiMode active --wifiBars 3 --dataNetwork wifi

# 3. 데모 데이터 시드 (기기가 부팅된 상태)
python3 store-assets/scripts/seed_demo_data.py <IPHONE_UDID> <IPAD_UDID>

# 4. 로케일·운동 계획 지정 (기기를 반드시 종료한 상태에서)
python3 store-assets/scripts/set_app_state.py <UDID> --locale ko

# 5. 앱을 실행해 6개 화면을 캡처 -> captures/ios/<locale>/<device>/

# 6. 합성 · 검증 · 축소 검수
python3 store-assets/scripts/compose_store_assets.py
python3 store-assets/scripts/preflight_assets.py
python3 store-assets/scripts/contact_sheet.py

# 7. 앱 소스 복구 (필수)
git checkout -- lib/core/ads/ad_eligibility.dart
```

## 산출물

- `captures/ios/<locale>/<device>/*.png` — 손대지 않은 원본 (iPhone 1320 × 2868, iPad 2064 × 2752)
- `output/<locale>/<device>/*.png` — 최종 이미지 (iPhone 1242 × 2688 = 6.5" 슬롯, iPad 2064 × 2752 = 13" 슬롯), 알파 채널 없음
- `output/contact-sheet/<locale>-<device>.jpg` — 22% 축소 검수 시트

## 슬롯

| # | 화면 | 상태 |
|---|---|---|
| 01 | Automatic squat counting | 🔴 실기기 캡처 필요 |
| 02 | Real-time form analysis | 🔴 실기기 캡처 필요 |
| 03 | Challenge | ✅ |
| 04 | Sets & rest | ✅ |
| 05 | Workout result | ✅ |
| 06 | History | ✅ |

## 미완료

- **01·02 슬롯** — 실기기 + 실제 인물 촬영 필요. 파이프라인에는 카피·레이아웃이 이미 배선돼 있어 원본만 넣으면 바로 생성된다
- 휴식 타이머·운동 완료 요약 화면 — 활성 운동 세션 필요 (같은 블로커)
- ja / de / fr / es / ar 세트 — 동일 파이프라인으로 확장 가능
- Google Play — Android 실제 빌드와 실제 Android 캡처로 **완전히 분리된** 파이프라인이 필요하다

`_deprecated-2026-08-05/`는 생성형 인물을 사용한 이전 파이프라인 산출물이다. 스토어에 올리면 안 된다.
