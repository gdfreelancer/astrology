# Phase 0 — Calculation foundation and PDF audit

## Scope

Phase 0 establishes shared calculation primitives and audits the astrology features already present. It does not implement the later feature milestones (advanced Bhava Chalit, Vimshottari Dasha, Varga charts, Gochar, Yogas or expanded matching).

Reference: `Saral_Jyotish_009373_std(1).pdf`.

## Changes made

- Added `AyanamshaService` as the single shared implementation of the app's Lahiri/Chitrapaksha mean-ayanamsha approximation.
- Updated birth-chart and Panchang calculations to use that shared service rather than maintaining duplicate polynomial implementations.
- Added pure `AstrologyMath` helpers for longitude normalization, tropical-to-sidereal conversion, angular separation, Nakshatra/Pada, Tithi, Yoga and Karana indexing.
- Corrected the Panchang Karana sequence. The previous mapping incorrectly returned Bava/Balava/Kaulava for the final three half-tithis. The PDF's sequence is Kimstughna at index 0, seven movable Karanas repeated through index 56, then Shakuni, Chatushpada and Naga at indexes 57–59.
- Added unit tests for the shared mathematical helpers and Lahiri reference epoch.
- Replaced the stale generated counter widget test (which imported a non-existent package and widget) with a smoke test for the actual app.
- Updated the app display name to **Saral Jyotish** for Flutter, Android, iOS, macOS and web.

## Existing implementation audit against the PDF

| PDF topic | Current app status | Phase 0 finding / follow-up |
|---|---|---|
| Local birth time and place correction (PDF pp. 48–53) | Birth forms store place, coordinates and timezone; chart service converts local time to UTC | Keep IANA timezone IDs and coordinates together. Validate DST and boundary cases in later test expansion. |
| Ascendant and twelve houses (PDF pp. 49–60) | Ascendant is calculated; current D1 display assigns whole-sign houses | Bhava cusps, house sandhi and Bhava Chalit placements are not implemented yet. These belong in the advanced Kundali milestone. |
| Planetary positions (PDF pp. 61–64) | Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn and mean Rahu/Ketu are represented | Retrograde status is not calculated; current model defaults it to false. Planetary longitudes and Ascendant need comparison against a trusted ephemeris before claiming professional accuracy. |
| Lagna and Chalit charts (PDF pp. 65–67) | D1 whole-sign chart is displayed | Chalit chart and cusp-based house placement are missing and must not be implied by the current D1 screen. |
| Vimshottari Dasha (PDF pp. 68–72) | Not implemented | PDF specifies the 120-year sequence and birth-Nakshatra-based balance. Implement in the dedicated Dasha milestone. |
| Divisional charts (PDF pp. 73–76) | Not implemented | PDF describes D2, D3, D7, D9, D10, D12, D16, D30 and D60. Implement reusable Varga calculation rules before adding more charts. |
| Panchang (PDF pp. 77–87) | Tithi, Vara, Nakshatra, Yoga, Karana and timing information exist | Karana ending sequence corrected in Phase 0. Add boundary/reference-date tests before expanding calendar coverage. |
| Sunrise, sunset, Sankranti, Amavasya, Purnima and Moon phases (PDF pp. 88–94) | Sunrise/sunset and lunar tithi calculations exist | Sankranti and a complete lunar-event calendar are not yet implemented. Existing observance finder is intentionally partial. |
| Planetary combinations / Yogas (PDF pp. 119–124) | Not implemented as a chart rule engine | Needs explicit, testable rule definitions and cancellation conditions; do not generate predictions from simple name matching. |
| Gochar and Sade Sati (PDF pp. 125–142) | Not implemented as a complete transit analysis | PDF emphasizes evaluating natal chart promise, Dasha and transit together. A transit-only good/bad label would be incomplete. |
| Horoscope matching (PDF pp. 143–154) | Existing Ashtakoota 36-point calculation and saved reports | Expanded Manglik, Dosha cancellation and additional chart compatibility are not yet implemented. Validate traditional tables and regional variants before extending. |

## Accuracy and licensing notes

- The shared ayanamsha service is still a **mean Lahiri/Chitrapaksha approximation**, not a Swiss Ephemeris implementation and not independently validated against a reference ephemeris.
- The existing GeoEngine-based planetary and rise/set calculations must be validated with known reference charts and dates before being described as professionally accurate.
- Do not silently change ephemeris libraries. Review license terms and commercial distribution obligations first.
- Interpretive rules in the PDF are traditional astrological material. Keep calculation outputs separate from interpretations and expose the selected calculation method.
- Do not label the current whole-sign D1 chart as Bhava Chalit.
- The existing Panchang observance list is partial; do not market it as a complete regional festival calendar.

## Verification

- Unit tests were added for the pure shared calculation helpers.
- The Android APK workflow has not been run as part of this source-only change. Run the repository's manual GitHub Actions APK workflow on `dev` to verify the full Flutter/Android build.
