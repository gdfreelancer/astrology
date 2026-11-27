# Phase 6 — Gochar, Yogas & Sade Sati

## Implemented on `dev`

- Retained date-selectable sidereal geocentric transit positions, retrograde screening, selected-date Sade Sati phase and Dhaiya sign indicators.
- Retained the existing placement-level Yoga checks.
- Added structured Yoga assessments with separate categories, planet references, formation criteria, dignity/combustion/retrograde modifiers, and formed/modified/weakened labels. No universal auspiciousness score is generated.
- Added localized Yoga names, formation descriptions, modifier labels and status labels in English, Hindi and Gujarati.
- Added a separate Dosha screening section:
  - **Manglik / Kuja**: checks Mars from Ascendant, Moon and Venus against houses 1, 2, 4, 7, 8 and 12, and displays each applicable reference independently.
  - **Kala Sarpa**: strict longitude-based screen requiring all seven classical planets to fall on one side of the Rahu–Ketu axis.
  - **Grahan Yoga screening**: reports Sun/node or Moon/node conjunction within a 12° longitude orb.
- Manglik mitigation indicators (Mars in own/exaltation sign and Jupiter influence) are shown as factors to review, never as automatic cancellation.
- Added English, Hindi and Gujarati translations for the new Yoga and Dosha content.
- Added regression tests for Yoga formation, Raja Yoga connection, Manglik reference points, Kala Sarpa positive/negative cases, and luminary-node proximity.

## Explicit limitations and remaining dependencies

Phase 6's standalone placement-screening scope is implemented. It is **not a complete classical judgement engine**, and the following items remain blocked or intentionally deferred rather than approximated:

- Full classical Yoga catalogue with source-by-source citations, lineage selection and complete formation/exception rules.
- Comprehensive Arishta catalogue and complete cancellation/mitigation rules.
- Full Neecha Bhanga Raja Yoga rules, planetary war, tradition-specific combustion thresholds, detailed affliction and cancellation judgement.
- Validated Shadbala and Bhava Bala integration. This depends on the outstanding full Shadbala work in Phase 2 and Bhava Bala/Bhavesha strength work in Phase 3.
- Rule-specific Vimsopaka/divisional confirmation and strength integration where a Yoga requires it.
- Historical/future Sade Sati ingress and exact retrograde re-entry/station windows. Current GeoEngine/Lahiri approximation is not sufficiently validated for publishing exact event times.
- Positive, negative, cancelled and borderline reference-chart fixtures validated against a chosen classical source and alternative lineages.

## Calculation and interpretation boundaries

- Yoga rules currently use whole-sign D1 placements and the app's supported whole-sign aspects. The screen describes screening criteria, not a definitive prediction.
- The status labels summarize only the implemented modifiers. They are not strength scores. A debilitated or combust planet does not automatically cancel a Yoga; a retrograde planet is not automatically weak.
- Manglik traditions differ on the reference houses, exceptions and cancellation. This implementation exposes the Lagna/Moon/Venus checks separately and does not decide compatibility or marriage outcomes.
- Kala Sarpa definitions vary. The implemented check is deliberately strict and does not infer partial Kala Sarpa forms.
- The 12° Grahan screening orb is a visible, configurable-style convention in this implementation, not a universal classical threshold. It does not calculate eclipse visibility.
- Vimsopaka and Shadbala are not combined. No unvalidated numeric strength score is inferred.
- Transit positions use GeoEngine and the app's mean Lahiri ayanamsha approximation; mean Rahu/Ketu are used.
- Sade Sati and Dhaiya remain selected-date sign classifications, not a complete historical/future transit timeline.
- These are educational rule-based indicators, not deterministic predictions. Important chart work should be verified against a trusted ephemeris and a qualified practitioner.

## Verification

Regression tests have been authored but **not run in this environment**. No analyzer or APK build was run. Run the manual GitHub Actions Android APK workflow on `dev` before release:
https://github.com/gdfreelancer/astrology/actions/workflows/build-android-apk.yml
