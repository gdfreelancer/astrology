# Phase 8 — QA and Release Readiness

## Release gate added

The manual Android APK workflow now runs these steps in order:

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`
4. `flutter build apk --release`
5. Upload `saral-jyotish-release-apk`

The workflow remains `workflow_dispatch` only. It does not run on commits or pushes. The APK is uploaded only if analysis, tests and the release build all succeed.

## Automated coverage

Existing tests cover:

- Shared astrology math and angle normalization.
- Bhava Chalit calculations.
- Vimshottari Mahadasha and Antardasha sequencing.
- Divisional chart mappings and boundaries.
- Lunar illumination, phase labels, event ordering and Sankranti sign indexes.
- Sade Sati phase selection and supported yoga detection.
- Manglik reference-point indicators and seventh-house profile derivation.
- App identity smoke test.

Added `test/translation_integrity_test.dart` to load English, Hindi and Gujarati translation assets and verify that all three locales contain the same keys and non-empty string values.

## Repository checks performed during this phase

- Parsed all three translation JSON files successfully.
- Confirmed English, Hindi and Gujarati each contain 1,015 keys, with no missing or extra keys.
- Confirmed there are no empty or non-string translation values.
- Confirmed the Android APK workflow is manual-only and now includes analysis and tests before packaging.

## Manual QA still required

Before production release, verify on physical Android devices:

- First launch, language selection, onboarding/splash flow and persistence after restart.
- Birth details, timezone conversion, geocoding failures and boundary warnings.
- Saved birth profiles: create, edit, delete and reuse in Kundali and matching.
- North, South and East chart preference persistence.
- D1, Bhava Chalit, Graha analysis, Rashi/Bhava analysis, Vimshottari Dasha and all 15 Varga screens.
- Panchang, Choghadiya, daily timings, observance finder and lunar-event date/time display across time zones.
- Gochar date changes, natal Moon/Lagna reference houses, Sade Sati phase and supported yoga cards.
- Matching score, Manglik indicators, seventh-house profile, saved reports and older report compatibility.
- English, Hindi and Gujarati text overflow, missing labels, date/time formats and small-screen layouts.
- Offline behavior, malformed local preferences/database payloads, app restart and fresh-install behavior.

## Accuracy and product boundaries

- The calculation engine uses GeoEngine and the app's approximate mean Lahiri ayanamsha. It has not been independently validated against Swiss Ephemeris or a trusted reference ephemeris.
- Muhurat remains guidance UI and does not provide computed auspicious windows.
- Daily horoscope text is generic sign-based content, not a live transit calculation.
- The observance finder is partial and does not replace regional Panchang/vrata adjudication.
- Gochar, Sade Sati and yoga rules are intentionally limited and must not be presented as exhaustive classical analysis.
- Kundali matching includes the 36-point Ashtakoota baseline and additional descriptive indicators; it is not a scientific compatibility assessment or relationship prediction.

## Validation status

No Flutter analyzer, Flutter test suite or Android release build was executed by this repository edit. Run the manual **Build Android APK** workflow on `dev`; it now acts as the automated release gate. Complete the physical-device checklist before publishing.
