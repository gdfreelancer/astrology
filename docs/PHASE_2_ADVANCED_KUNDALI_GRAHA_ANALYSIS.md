# Phase 2 — Advanced Kundali and Graha Analysis

## Scope delivered so far
- Added an ascendant-relative house-lord ownership engine for the seven classical visible planets.
- Added a functional-nature screening label based on Lagna, Kendra, Trikona, Dusthana, Maraka and Upachaya ownership.
- Added Yogakaraka screening when one planet owns both a Kendra (4/7/10) and a Trikona (5/9); Lagna ownership is treated separately.
- Added D1-to-D9 sign comparison and Vargottama flag.
- Added a chart-linked Graha profile screen showing natural/functional nature, owned houses, D1/D9 sign comparison, house theme and supported flags.
- Existing D1, Bhava Chalit, divisional charts, aspects, dignity, combustion, Ashtakavarga, Yoga screens and reference pages are retained.

## Required Phase 2 continuation — not optional / not yet implemented
Phase 2 is **not complete** until the following advanced Graha-analysis work is implemented and validated. These items are carried forward as mandatory Phase 2 completion work, not silently deferred or removed.

### 2B. Full Graha Bala calculations
- Shadbala for Sun, Moon, Mars, Mercury, Jupiter, Venus and Saturn, with all six components shown separately:
  - Sthana Bala (including applicable positional sub-components)
  - Dig Bala
  - Kala Bala (including its applicable sub-components)
  - Cheshta Bala
  - Naisargika Bala
  - Drik Bala
- Total Shadbala in Rupas and Virupas, planet-specific minimum reference values, and a transparent component breakdown.
- Ishta Phala and Kashta Phala derived from the validated strength inputs.
- No generic percentage or arbitrary score may be presented as Shadbala. If an input required by a component is unavailable or insufficiently accurate, show that component as unavailable and explain why rather than fabricate a value.

### 2C. Planetary condition and advanced placement flags
- Graha Yuddha detection for eligible planets, including the required geocentric latitude/separation and a documented winner rule.
- Combustion with planet-specific angular limits and source/method disclosure.
- Retrogression and motion condition, including the distinction between calculated motion and simplified indicators.
- Vargottama and Pushkara Navamsa/Bhaga indicators, with exact convention and boundary tests.
- Functional benefic, malefic, Yogakaraka, Maraka and Badhaka analysis with Lagna-specific rules and documented school-dependent exceptions.
- Planet-in-sign, planet-in-house and house-lord-in-house interpretations, with D1 and Bhava Chalit context kept distinct.

### 2D. Validation and presentation
- Add independently sourced reference-chart fixtures for each calculation component and boundary conditions before displaying results as complete.
- Add regression tests for all seven classical planets, edge degrees, retrograde/direct cases, latitude-dependent cases and missing-input behavior.
- Display the formula/method, units, reference threshold and any unavailable component in the UI.
- Keep English, Hindi and Gujarati localization in sync.
- Preserve existing chart calculations and screens; new analysis must be additive.

## Required work in dependent phases
These are also mandatory and are assigned to the phase whose data/calculation they depend on:
- **Phase 3:** Bhava Bala and detailed Bhava/house-lord strength interpretation, integrated into Rashi & Bhava Analysis.
- **Phase 4:** Vimsopaka Bala and cross-Varga strength analysis, after the divisional chart conventions are validated.
- **Phase 6:** Comprehensive Yoga/Dosha strength, cancellation and exception rules, using the validated Graha Bala and divisional-chart results.

## Interpretation limits
- Functional-nature screening currently delivered is a preliminary rule-based label, not a complete classical judgement.
- Moon's natural beneficence depends on paksha; the current chart model does not provide the required waxing/waning classification to resolve it here.
- Rahu and Ketu do not receive classical sign-lord ownership in the current table.
- D9 is calculated using the existing VargaChartService rules. Vargottama currently means the same Rashi index in D1 and D9; it is a placement flag, not a strength score.
- House themes are traditional educational keywords, not predictions.
- The currently delivered screen does **not** calculate full Shadbala, Bhava Bala, Ishta/Kashta, Vimsopaka Bala, Graha Yuddha or complete Yoga cancellation judgement.

## Offline and compatibility
- No backend or network dependency is required; calculations and reference data remain on-device.
- No existing chart model or calculation output should be removed or silently redefined.
- Any new input needed for accurate calculations must be added to the local calculation pipeline with backward-compatible defaults and validation.

## Verification status
- Unit tests currently cover ascendant-relative lordship and Yogakaraka screening.
- The required continuation items above are outstanding and must receive calculation tests and reference fixtures before Phase 2 can be marked complete.
- Flutter tests, analyzer and APK build have not been run here. Use the manual Android APK workflow on the dev branch.
