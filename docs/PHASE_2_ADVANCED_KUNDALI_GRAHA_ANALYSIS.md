# Phase 2 — Advanced Kundali and Graha Analysis

## Scope delivered
- Added an ascendant-relative house-lord ownership engine for the seven classical visible planets.
- Added a functional-nature screening label based on Lagna, Kendra, Trikona, Dusthana, Maraka and Upachaya ownership.
- Added Yogakaraka screening when one planet owns both a Kendra (4/7/10) and a Trikona (5/9); Lagna ownership is treated separately.
- Added D1-to-D9 sign comparison and Vargottama flag.
- Added a chart-linked Graha profile screen showing natural/functional nature, owned houses, D1/D9 sign comparison, house theme and supported flags.
- Existing D1, Bhava Chalit, divisional charts, aspects, dignity, combustion, Ashtakavarga, Yoga screens and reference pages are retained.

## Interpretation limits
- Functional benefic/malefic rules vary by tradition and are not a complete judgement. The screen explicitly describes them as a rule-based screening.
- Moon's natural beneficence depends on paksha; the current chart model does not provide the required waxing/waning classification to resolve it here.
- Rahu and Ketu do not receive classical sign-lord ownership in this table.
- D9 is calculated using the existing VargaChartService rules. Vargottama here means the same Rashi index in D1 and D9; it is a placement flag, not a strength score.
- House themes are traditional educational keywords, not predictions.
- This phase does not claim full Shadbala, Bhava Bala, Ishta/Kashta, Vimsopaka Bala, Graha Yuddha or complete Yoga cancellation judgement. Those require separately validated calculation specifications.

## Offline and compatibility
- No backend, network dependency, new package or database migration.
- Existing chart models and calculation outputs are unchanged.
- New screen is linked from the existing Kundali result screen.
- English, Hindi and Gujarati labels are added together.

## Verification
- Unit tests are added for ascendant-relative lordship and Yogakaraka screening.
- Flutter tests, analyzer and APK build have not been run here. Use the manual Android APK workflow on the dev branch.
