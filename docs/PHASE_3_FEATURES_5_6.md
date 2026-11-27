# Phase 3 — Features 5 and 6

## Feature 5: Rashi & Bhava Analysis

### Existing functionality retained
- D1 Rashi (whole-sign) and Bhava Chalit selector.
- All twelve houses, sign at the house / Bhava Madhya, traditional sign lord, house topics, occupants and house-lord placement.
- Bhava Madhya degree display for Chalit.

### Implemented in this Phase 3 continuation
- Added a dedicated BhavaAnalysisService that returns house-by-house occupancy and Graha Drishti for the selected system.
- D1 aspect mapping uses whole-sign houseNumber; Bhava Chalit mapping uses bhavaNumber. The screen does not mix D1 and Chalit positions.
- Displays aspecting Grahas on each house card alongside its sign, lord, lord placement and occupants.
- Uses the app's current Parashari aspect convention: all Grahas have 7th aspect; Mars additionally 4th/8th, Jupiter 5th/9th, Saturn 3rd/10th. Rahu/Ketu 5th/9th aspects follow the convention already used by this app and vary by lineage.
- Added tests for D1 versus Chalit source-house handling, aspect targets, occupancy and immutable results.
- Added English, Hindi and Gujarati labels.

### Required work still outstanding — do not mark Phase 3 complete
- **Bhava Bala for all twelve houses** with transparent components and units.
- **Bhavesha strength** integrated with validated Phase 2 Shadbala, not a placeholder.
- House-wise strength interpretation combining validated house-lord strength, occupants, aspects and documented rules.
- Reference-chart and boundary tests for the complete strength calculation.

The current calculation model does not yet provide validated Shadbala. Therefore the screen explicitly marks Bhava Bala as unavailable and explains the dependency; it does not display a fabricated or proxy score. The uploaded Saral Jyotish PDF documents house cusps, Bhava Madhya and Chalit construction (printed pages 54–60), but the retrieved contents do not specify a complete Bhava Bala formula. The full calculation must be based on a separately documented and validated classical method.

Interpretations remain descriptive and conditional, not deterministic. Rahu/Ketu aspect conventions and other lineage differences must remain visible in method notes.

## Feature 6: Vimshottari Dasha

### Existing calculation retained
- Uses sidereal Moon longitude to determine birth Nakshatra and its Dasha lord.
- Nine-lord sequence: Ketu, Venus, Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury.
- Traditional year allocations: 7, 20, 6, 10, 7, 18, 16, 19, 17 (120 years total).
- Calculates birth Mahadasha balance from the untraversed portion of the birth Nakshatra.
- Calculates subsequent Mahadasha dates.
- Calculates Antardasha periods proportionally within each full Mahadasha, reconstructing the pre-birth start of the first Mahadasha.
- Nested Pratyantardasha, Sookshma and Prana periods are proportionally derived from their parent period.

### Phase 3 improvements
- Current running period card now shows both Mahadasha and Antardasha start/end dates separately.
- Localized Pratyantardasha, Sookshma and Prana headings in English, Hindi and Gujarati.
- Existing Mahadasha and Antardasha timelines are retained.

## Date convention and accuracy

- One Dasha year is represented as 365.2425 days for calendar date conversion. Some Jyotish traditions/software use a different year-length convention; resulting dates can differ.
- Dasha calculations depend on Moon longitude and inherit the current GeoEngine and approximate Lahiri ayanamsha limitations.
- Nested periods are proportional subdivisions of their parent period; they are not independently ephemeris-derived or independently validated classical event predictions.
- This feature calculates periods; it does not provide deterministic event predictions or personalized Dasha interpretations.

## Verification

- Added test/services/bhava_analysis_service_test.dart.
- Added test/services/vimshottari_dasha_service_test.dart for birth Nakshatra lord, longitude wraparound, sequence/year allocations, pre-birth Antardasha reconstruction and timeline boundaries.
- Translation files are updated together for all new Phase 3 keys.
- Flutter tests, analyzer and Android build have **not** been executed in this environment. Run the manual Android APK workflow on dev before release:
  https://github.com/gdfreelancer/astrology/actions/workflows/build-android-apk.yml
