# Phase 3 — Features 5 and 6

## Feature 5: Rashi & Bhava Analysis

Added a dedicated analysis screen reachable from the Kundali result.

- Toggle between D1 Rashi (whole-sign houses) and Bhava Chalit.
- Lists all twelve houses.
- Shows the sign occupying each house and its traditional sign lord.
- Shows the house lord's placement in the selected house system.
- Lists planets occupying each house in the selected system.
- Includes concise traditional house-topic associations for all twelve houses.
- For Bhava Chalit, displays the sign at the Bhava Madhya and its degree.

Interpretation is intentionally descriptive, not deterministic. This screen does not yet calculate house-lord strength, aspects, dignity, Shadbala, yogas or divisional-chart confirmation. These are separate advanced analysis items.

## Feature 6: Vimshottari Dasha

Added a calculation service, timeline model, UI and tests.

- Uses the sidereal Moon longitude to find the birth Nakshatra and its Dasha lord.
- Implements the nine-lord sequence: Ketu, Venus, Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury.
- Uses the traditional Mahadasha year allocations (7, 20, 6, 10, 7, 18, 16, 19, 17; total 120).
- Calculates the balance of the birth Mahadasha from the untraversed portion of the birth Nakshatra.
- Calculates the subsequent Mahadasha dates.
- Calculates Antardasha periods proportionally within each full Mahadasha, reconstructing the pre-birth start of the first Mahadasha so the running Antardasha at birth is not incorrectly restarted.
- Shows the running Mahadasha/Antardasha and their date range, plus the Mahadasha timeline and Antardasha sequence.
- Includes English, Hindi and Gujarati labels.

## Date convention and accuracy

- One Dasha year is represented as 365.2425 days (mean tropical year) for calendar date conversion. Some Jyotish traditions/software use a different year-length convention; resulting dates can differ.
- Dasha calculations depend on the Moon longitude and therefore inherit the app's current GeoEngine and approximate Lahiri ayanamsha limitations. Validate important dates against a trusted Panchanga/ephemeris and the preferred tradition.
- The PDF describes the 120-year sequence, birth Nakshatra lord, proportional balance and Antardasha calculation on printed pages 68–72.
- This feature calculates periods; it does not provide deterministic event predictions or personalized Dasha interpretations.

## Verification

Added unit tests for Nakshatra lord selection, birth balance, Mahadasha order, Antardasha sequence and current-period lookup. Tests and Android build have not been executed in this environment. Run GitHub Actions Android APK workflow on `dev` before release.
