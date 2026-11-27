# Phase 7 — Advanced Kundali Matching

## Implemented

- Retains the existing North Indian 36-point Ashtakoota report and the separate directional South Indian 10-Porutham report. Their totals are never combined or treated as interchangeable.
- Retains locally saved matching reports and backward-compatible report payloads. Advanced D1/D9 profiles are derived from stored placements when available; older reports without a stored chart show unavailable values rather than fabricated data.
- Shows Manglik/Kuja screening independently from Lagna, Moon and Venus for both charts, using the configured 1, 2, 4, 7, 8 and 12 house convention.
- Adds conservative Manglik mitigation indicators for Mars in own sign, Mars exaltation sign and Jupiter's conjunction with or aspect to Mars. They are displayed as factors to review, never as automatic cancellation or a final dosha verdict.
- Expands each D1 seventh-house profile with seventh-house occupants, seventh lord and its house, a basic sign dignity classification, planets aspecting the seventh house, and planets aspecting the seventh lord.
- Expands Navamsa (D9) comparison with D9 ascendant, Venus and Jupiter positions, seventh-house sign and occupants, seventh lord and its house, seventh-lord sign dignity, and planets aspecting the D9 seventh house.
- Uses whole-sign Parashari graha drishti for this descriptive comparison: all planets cast the seventh aspect; Mars additionally casts fourth/eighth, Jupiter fifth/ninth, and Saturn third/tenth. Nodes are excluded from this aspect list.
- Includes the expanded D1 and D9 profiles in the shareable matching PDF as descriptive rows, without adding unsupported compatibility points. These remain separate analyses.
- Adds regression tests for independent Manglik reference points, mitigation indicator handling, seventh-lord dignity, D1 aspects, D9 profile generation and missing legacy chart data.
- Adds English, Hindi and Gujarati labels for the new analysis.

## Explicit conventions and limitations

- Manglik house lists, sign-based exceptions, Jupiter influence and cancellation rules vary by lineage and region. The app shows only three screening indicators; it does not claim that these cancel Manglik Dosha. A complete rule-by-rule cancellation engine is not part of this phase.
- Sign dignity is limited to own, exalted, debilitated or other. It is not a complete Shadbala, Vimsopaka, avastha or strength judgement.
- Seventh-house aspects use whole-sign Parashari aspects. Other drishti systems, sign aspects, orb weighting, dignity-weighted aspect strength and Bhava Chalit recalculation are not included.
- D9 interpretation is descriptive and inherits the current GeoEngine / approximate mean Lahiri calculation. D9 placements can change with birth-time uncertainty; unknown or approximate birth times should be treated cautiously.
- Upapada Lagna, Dara Karaka, full Jaimini matching, detailed Navamsa dignity/strength, Dasha compatibility, longevity or progeny judgement, full Ashtakoota regional variants and a comprehensive Manglik cancellation catalogue are not implemented.
- No advanced factor is converted into an overall marriage-success score. The report is a traditional astrology reference, not relationship advice or a prediction. Personal consent, communication and compatibility cannot be reduced to a chart score.
- Existing Ashtakoota and South Indian Porutham calculation conventions remain unchanged in this phase.

## Validation status

- Added automated test cases in `test/services/advanced_matching_service_test.dart`.
- Translation JSON files are expected to retain identical key sets in English, Hindi and Gujarati.
- Flutter tests, analyzer and Android APK build have not been run in this environment. Run the repository's manual Android workflow before release.
