# Phase 8 — QA and Release Readiness

## Manual Android release gate

The **Build Android APK** GitHub Actions workflow is intentionally manual-only (`workflow_dispatch`). It does not run for commits or pushes.

The workflow now runs these gates in order:

1. Check out the selected branch.
2. Set up Java 17 and Flutter stable.
3. Run `flutter pub get`.
4. Run `flutter analyze --no-fatal-infos`.
5. Run the complete `flutter test` suite.
6. Build `flutter build apk --release`.
7. Upload `saral-jyotish-release-apk` for 14 days.

The APK artifact is uploaded only when dependency resolution, static analysis, tests and release packaging all succeed. This workflow does not publish to the Play Store.

## Automated regression coverage

The repository's automated tests cover:

- Astrology math, angle normalization and input validation.
- Birth chart calculations, Bhava Chalit and birth-profile serialization.
- Kundali history persistence and retention.
- Vimshottari sequencing and timeline boundaries.
- Divisional chart mappings, Vimsopaka weights and Pushkara/Vargottama indicators.
- Panchang lunar illumination, phase labels, event ordering and Sankranti sign indexes.
- Sade Sati phase selection and supported Yoga/Dosha screening.
- Matching Manglik reference points, mitigation review indicators, seventh-house aspects and Navamsa profiles.
- Matching report JSON round-trip, full D1 chart retention and compatibility with older saved payloads that lack optional chart fields.
- English, Hindi and Gujarati translation integrity: identical locale key sets and non-empty string values.

New Phase 8 test files:

- `test/translation_integrity_test.dart`
- `test/models/matching_report_test.dart`

## Repository checks completed in this phase

- Parsed English, Hindi and Gujarati translation JSON successfully.
- Confirmed all three locales currently contain **1,304 keys each**, with identical key sets.
- Confirmed all translation values are non-empty strings.
- Inspected the workflow and confirmed it contains no push or pull-request trigger; it remains manual-only.
- Corrected the workflow so `flutter test` runs before release APK packaging.
- Added saved matching-report serialization and legacy-payload regression coverage.

These are repository-content checks only. They do not mean the Dart tests, analyzer or APK build have been executed.

## Required physical-device QA before production

The following checks still require a real device and cannot be certified by repository inspection alone:

- First launch, language selection, onboarding/splash flow and persistence after restart.
- Birth details, timezone conversion, geocoding failures and boundary warnings.
- Saved birth profiles: create, edit, delete and reuse in Kundali and matching.
- North, South and East chart preference persistence.
- D1, Bhava Chalit, Graha analysis, Rashi/Bhava analysis, Vimshottari Dasha and all 15 Varga screens.
- Panchang, Choghadiya, daily timings, observance finder and lunar-event date/time display across time zones.
- Gochar date changes, natal Moon/Lagna reference houses, Sade Sati phase and supported Yoga cards.
- Matching score, Manglik indicators, seventh-house profile, saved reports and older report compatibility.
- English, Hindi and Gujarati text overflow, missing labels, date/time formats and small-screen layouts.
- Offline behavior, malformed local preferences/database payloads, app restart and fresh-install behavior.
- Android back navigation, keyboard/IME behavior, permission denial, low-storage conditions and process recreation.
- PDF generation and sharing on supported Android versions.

## Accuracy and product boundaries

- The calculation engine uses GeoEngine and the app's approximate mean Lahiri ayanamsha. It has not been independently validated against Swiss Ephemeris or a trusted reference ephemeris.
- Shadbala and Bhava Bala must not be shown as complete until their required inputs and all classical components have been implemented and validated.
- Muhurat remains guidance UI and does not provide computed auspicious windows.
- Daily horoscope text is generic sign-based content, not a live transit calculation.
- The observance finder is partial and does not replace regional Panchang/vrata adjudication.
- Gochar, Sade Sati and Yoga rules are intentionally limited and must not be presented as exhaustive classical analysis.
- Kundali matching includes the 36-point Ashtakoota baseline and additional descriptive indicators; it is not a scientific compatibility assessment or relationship prediction.

## Validation status

No Flutter analyzer, Flutter test suite or Android release build was executed by these repository edits. Run the manual **Build Android APK** workflow on `dev`; review its complete logs and downloaded APK. Complete the physical-device checklist before publishing.
