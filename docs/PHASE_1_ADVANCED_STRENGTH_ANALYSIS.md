# Phase 1 — Graha and Bhava Strength Analysis

## Objective

Extend the existing Kundali analysis with transparent, component-level planetary strength and descriptive Bhava assessment. Preserve the existing D1, Bhava Chalit, Graha placements, Avastha, Drishti, Yoga, Dasha, Varga and Gochar implementations.

## Existing features retained

- Existing seven visible-planet and two lunar-node chart placements.
- Existing whole-sign D1 and Sripati-style Bhava Chalit house assignments.
- Existing Avastha, dignity, approximate combustion and Naisargika Bala reference.
- Existing Graha Drishti and supported Yoga checks.
- Existing Varga chart calculations and D9 Navamsa.
- Existing chart layout, saved profiles and chart-style preference.

## Implemented additions

### 1. Component-based Graha strength

Added `ShadbalaAnalysisService` and a dedicated Strength Analysis screen linked from Kundali overview.

For the seven classical planets (Sun, Moon, Mars, Mercury, Jupiter, Venus and Saturn), the screen shows:

- **Uchcha Bala:** computed from the planet's angular distance from its debilitation point, using the classical exaltation/debilitation degree pairs; scaled from 0 to 60 virupas.
- **Dig Bala:** computed from angular distance to the traditional directional peak Bhava Madhya; scaled from 0 to 60 virupas.
- **Naisargika Bala:** displays the existing traditional natural-strength constants.
- **Paksha Bala:** estimated from Sun–Moon angular separation. Jupiter, Venus and Mercury are treated as natural benefics; the other planets receive the complementary value. This is a simplified reference convention.
- **Vargottama indicator:** identifies when a planet occupies the same sign in D1 and D9.

The screen presents components separately and does not add them into a purported full Shadbala total.

### 2. Descriptive Bhava strength

For all twelve Bhavas, the screen shows:

- Bhava Madhya sign.
- Sign lord.
- Lord's D1 placement and basic dignity (own, exaltation, debilitation or not assessed).
- Grahas occupying the Bhava Chalit house.
- Supported whole-sign Graha aspects reaching the Bhava.

This is an evidence summary, not a numerical classical Bhava Bala calculation.

### 3. Localization

Added matching English, Hindi and Gujarati translation keys for the new screen, component names, warnings and Bhava fields.

### 4. Regression tests

Added tests for:

- All displayed component values remaining within 0–60 virupas.
- Maximum and zero Uchcha Bala at the Sun's exact exaltation and debilitation points.
- Dig Bala at the configured directional peak Bhava Madhya.
- Waxing/waning Paksha Bala behavior for natural benefics and malefics.
- Twelve Bhava summaries and valid sign-lord mappings.

## Important accuracy boundary

This phase does **not** claim to implement complete Shadbala. Classical Shadbala includes six major categories and multiple sub-components. The current chart model does not yet provide all the astronomical and calendrical inputs needed to calculate every component reliably.

Still not fully calculated:

- Saptavargaja Bala and complete divisional dignity weighting.
- Ojhayugma Rasyamsa Bala and Kendradi Bala.
- Natonnata Bala, Tribhaga Bala, Varsha/Masa/Vara/Hora Bala and Ayana Bala.
- Exact Cheshta Bala from validated geocentric velocity and planetary station data.
- Graha Yuddha Bala.
- Drik Bala with fully specified aspect strengths and benefic/malefic weighting.
- Classical Bhava Bala total, including all required lord, directional and aspect contributions.
- Full Vimsopaka Bala.

No unsupported aggregate score, strength ranking or threshold verdict is shown.

## Calculation conventions

- Exaltation points: Sun 10° Aries, Moon 3° Taurus, Mars 28° Capricorn, Mercury 15° Virgo, Jupiter 5° Cancer, Venus 27° Pisces, Saturn 20° Libra.
- Dig Bala peak houses: Sun/Mars 10th, Moon/Venus 4th, Mercury/Jupiter 1st, Saturn 7th. The current Bhava Madhya values are used for the angular distance.
- Paksha Bala uses the Sun-to-Moon forward angular separation divided by three. It is a simplified component estimate; Mercury's natural-benefic treatment does not inspect conjunction/affliction.
- Vargottama is the same sign in D1 and D9 under the app's existing Varga convention.
- All positions inherit the GeoEngine and approximate mean Lahiri limitations documented in Phase 0.

## Non-regression

No existing calculation service or screen was removed. The new analysis is additive and has its own screen. The existing Advanced Chart Analysis screen remains available.

## Verification status

- Source files, translations and unit tests have been committed to `dev`.
- Automated tests, static analysis and Android packaging have not been executed after these edits.
- Run the existing manual-only Android APK workflow to verify the branch before release.

## Next recommended calculation work

1. Add verified reference fixtures for strength component boundaries and Bhava Madhya.
2. Implement remaining Shadbala sub-components only after their required input data and classical convention are explicitly defined.
3. Add complete functional lordship, Yoga cancellation and Dosha rule matrices as a separate calculation layer.
4. Add Jaimini-specific calculations (Arudha, Upapada, Karakamsha, Rashi Drishti, Argala and Chara Dasha) as a separate module rather than mixing them into Parashari Shadbala.
