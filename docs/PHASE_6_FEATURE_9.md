# Phase 6 — Gochar, Yogas & Sade Sati

## Implemented on dev
- Existing date-selectable sidereal geocentric transit positions, retrograde screening, Sade Sati phase and Dhaiya sign indicators are retained.
- Existing placement-level Gajakesari, Budhaditya, Chandra-Mangala, Raja/Dhana, Vipareeta, Neecha Bhanga and supported Pancha Mahapurusha checks are retained.
- Added `YogaDoshaAnalysisService` with structured, separate Yoga categories (Raja, Dhana, Vipareeta, Mahapurusha, lunar and other), explicit formation conditions, planet references, dignity/combustion/retrograde modifiers and formed/modified/weakened status.
- Added structured assessments to the Gochar & Yogas screen; the result does not collapse all combinations into a single auspicious/inauspicious score.
- Added English, Hindi and Gujarati labels and an educational limitations notice.
- Added regression tests for Gajakesari formation/non-formation, Budhaditya and Chandra-Mangala formation, and structured result/caveat behavior.

## Important remaining Phase 6 work
Phase 6 is **partially implemented, not complete**. The following planned work remains:
- Full classical Yoga catalogue with source-by-source citations and lineage/tradition selection.
- Full Arishta/Dosha catalogue and cancellation/mitigation rules.
- Comprehensive Neecha Bhanga Raja Yoga exceptions, planetary war, combustion thresholds by tradition, aspects and affliction judgement.
- Validated Shadbala and Bhava Bala integration (blocked on the outstanding Phase 2 and Phase 3 work).
- Rule-specific Vimsopaka/divisional confirmation and validated strength integration where required.
- Historical/future Sade Sati ingress and retrograde crossing windows.
- Positive, negative, cancelled and borderline reference-chart fixtures across alternative traditions.

## Calculation boundaries
- Current Yoga screening uses the existing whole-sign placements/aspects and combustion screening. It is not a complete classical judgement engine; combustion and dignity indicators are simplified and do not prove a Yoga is cancelled.
- Retrograde status is displayed as a modifier, not automatically considered weakness or strength.
- Vimsopaka and Shadbala are not combined. No unvalidated numeric strength score is inferred.
- Transit positions use GeoEngine and the app's mean Lahiri ayanamsha approximation; mean Rahu/Ketu are used.
- Sade Sati and Dhaiya remain selected-date sign classifications, not a complete historical/future transit timeline.
- These are educational rule-based indicators, not deterministic predictions. Important chart work should be verified against a trusted ephemeris and a qualified practitioner.

## Verification
Regression tests have been authored but not run in this environment. Run the manual GitHub Actions Android APK workflow on `dev` before release.
