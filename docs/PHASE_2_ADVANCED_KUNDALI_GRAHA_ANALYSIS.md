# Phase 2 — Advanced Kundali and Graha Analysis

## Phase status: complete with explicitly excluded advanced calculations

The implemented Phase 2 scope is complete: ascendant-relative Graha profile analysis, functional-nature screening, Yogakaraka screening, D1/D9 comparison and Vargottama flag, chart-linked profile screen, existing chart analysis, dignity/condition references and localization are retained.

The user-approved scope decision is to **skip the full Shadbala dependency and mark Phase 2 complete without presenting unvalidated calculations**. This is a scope exclusion, not a claim that Shadbala has been calculated.

## Included and delivered
- Ascendant-relative house-lord ownership for the seven classical visible planets.
- Functional-nature screening based on Lagna, Kendra, Trikona, Dusthana, Maraka and Upachaya ownership.
- Yogakaraka screening when one planet owns both a Kendra (4/7/10) and a Trikona (5/9); Lagna ownership is treated separately.
- D1-to-D9 sign comparison and Vargottama flag.
- Chart-linked Graha profile screen showing natural/functional nature, owned houses, D1/D9 sign comparison and house theme.
- Existing D1, Bhava Chalit, divisional charts, aspects, dignity, combustion screening, Ashtakavarga, Yoga screens and reference pages are retained.
- Vimsopaka Bala, Pushkara indicators and cross-Varga analysis are delivered separately in Phase 4.

## Explicitly skipped / not included in this release
These items are not implemented and must not be inferred from the existing partial strength indicators:
- Full six-component Shadbala (Sthana, Dig, Kala, Cheshta, Naisargika and Drik), total Rupas/Virupas and minimum-strength comparison.
- Ishta Phala and Kashta Phala.
- Quantitative Graha Yuddha and complete planetary-latitude based winner determination.
- Complete source-validated combustion thresholds and motion-state classification.
- Full classical functional benefic/malefic, Badhaka and exception rules.
- Independently validated reference-chart fixtures for those excluded calculations.

The app must continue to label the existing strength indicators as partial references, not Shadbala. No total, rank or percentage may be inferred or displayed.

## Interpretation limits
- Functional-nature screening is a preliminary rule-based label, not a complete classical judgement.
- Moon's natural beneficence depends on paksha; the current chart model does not provide the required waxing/waning classification to resolve it here.
- Rahu and Ketu do not receive classical sign-lord ownership in the current table.
- D9 is calculated using the existing VargaChartService rules. Vargottama means the same Rashi index in D1 and D9; it is a placement flag, not a strength score.
- House themes are traditional educational keywords, not predictions.
- Existing GeoEngine positions and the app's Lahiri approximation remain the underlying calculation basis.

## Offline and compatibility
- No backend or network dependency is required; calculations and reference data remain on-device.
- No existing chart model or calculation output has been removed or silently redefined.
- The skipped calculations remain unavailable rather than being approximated and presented as classical scores.

## Verification
- Existing tests cover ascendant-relative lordship and Yogakaraka screening.
- Flutter tests, analyzer and APK build have not been run here. Use the manual Android APK workflow on the dev branch:
  https://github.com/gdfreelancer/astrology/actions/workflows/build-android-apk.yml
