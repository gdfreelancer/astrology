# Phase 3 — Features 5 and 6

## Phase status: complete with explicitly excluded Bhava Bala

The user-approved scope decision is to **skip full Bhava Bala and Bhavesha strength calculations** because their dependency on validated six-component Shadbala and disputed classical calculation conventions is not met by the current offline chart pipeline. Phase 3 is marked complete for the delivered Rashi/Bhava and Vimshottari features, without fabricating house-strength scores.

## Feature 5: Rashi & Bhava Analysis

### Included and delivered
- D1 Rashi (whole-sign) and Bhava Chalit selector.
- All twelve houses, sign at the house / Bhava Madhya, traditional sign lord, house topics, occupants and house-lord placement.
- Bhava Madhya degree display for Chalit.
- Dedicated BhavaAnalysisService returns house-by-house occupancy and Graha Drishti for the selected system.
- D1 aspect mapping uses whole-sign houseNumber; Bhava Chalit mapping uses bhavaNumber. The screen does not mix D1 and Chalit positions.
- Displays aspecting Grahas on each house card alongside its sign, lord, lord placement and occupants.
- App's current Parashari aspect convention: all Grahas have 7th aspect; Mars additionally 4th/8th, Jupiter 5th/9th, Saturn 3rd/10th. Rahu/Ketu 5th/9th aspects follow this app convention and vary by lineage.
- Tests cover D1 versus Chalit source-house handling, aspect targets, occupancy and immutable results.
- English, Hindi and Gujarati labels.

### Explicitly skipped / not included in this release
- Full Bhava Bala for all twelve houses and its component-by-component score.
- Bhavesha strength integrated with validated Phase 2 Shadbala.
- Quantitative house-lord strength interpretation combining Shadbala, occupants, aspects and selected classical rules.
- Reference-chart fixtures for those excluded calculations.

The screen explicitly says Bhava Bala is not included in this release. It does not show a proxy score. The uploaded Saral Jyotish PDF documents house cusps, Bhava Madhya and Chalit construction (printed pages 54–60), but does not specify a complete Bhava Bala formula in the retrieved material. Multiple classical interpretations exist; no single unvalidated interpretation is silently selected.

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
- Current running period card shows both Mahadasha and Antardasha start/end dates separately.
- Localized Pratyantardasha, Sookshma and Prana headings in English, Hindi and Gujarati.
- Existing Mahadasha and Antardasha timelines are retained.

## Date convention and accuracy
- One Dasha year is represented as 365.2425 days for calendar date conversion. Some Jyotish traditions/software use a different year-length convention; resulting dates can differ.
- Dasha calculations depend on Moon longitude and inherit the current GeoEngine and approximate Lahiri ayanamsha limitations.
- Nested periods are proportional subdivisions of their parent period; they are not independently ephemeris-derived or independently validated classical event predictions.
- This feature calculates periods; it does not provide deterministic event predictions or personalized Dasha interpretations.

## Verification
- Tests: test/services/bhava_analysis_service_test.dart and test/services/vimshottari_dasha_service_test.dart.
- Translation files are updated together for all new Phase 3 keys.
- Flutter tests, analyzer and Android build have not been executed here. Run the manual Android APK workflow on dev before release:
  https://github.com/gdfreelancer/astrology/actions/workflows/build-android-apk.yml
