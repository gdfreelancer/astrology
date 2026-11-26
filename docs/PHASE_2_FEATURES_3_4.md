# Phase 2 — Features 3 and 4

## Feature 3: Advanced Kundali generation

- Retains the existing birth-profile flow, saved North/South/East preference, and whole-sign D1 Rashi chart.
- Adds a sidereal Midheaven (10th Bhava Madhya) alongside the calculated Ascendant.
- Calculates twelve Bhava Madhyas by dividing each quadrant (MC→Ascendant, Ascendant→IC, IC→Descendant, Descendant→MC) into three equal intervals.
- Calculates Bhava Sandhi boundaries halfway between adjacent Bhava Madhyas.
- Assigns each graha independently to its whole-sign D1 house and its Bhava Chalit house.
- Displays a Bhava Chalit overview and an expandable table of all twelve start boundary, Bhava Madhya, and end boundary longitudes.

This follows the house-midpoint and Sandhi workflow described in the supplied reference PDF (printed pages 54–60 and 65–67). The implemented quadrant division is a Sripati-style midpoint construction; it is not a claim that every historical regional house system is identical.

## Feature 4: Graha analysis

For the nine grahas (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu and Ketu), the app now presents:
- Sidereal longitude down to degrees, minutes and seconds.
- Rashi and degree within the sign.
- Nakshatra and Pada.
- Whole-sign D1 house and Bhava Chalit house.
- Estimated daily longitude motion and direct/retrograde status.

Planetary positions use the existing GeoEngine geocentric/apparent position calls and the app's mean Lahiri ayanamsha approximation. Rahu/Ketu use a mean-node model. Daily motion is estimated from positions twelve hours before and after birth time.

## Accuracy and validation limits

- The mean Lahiri polynomial is still an approximation; no Swiss Ephemeris or other externally validated ephemeris was introduced.
- Ascendant and Midheaven depend on the current sidereal-time and obliquity routines. These calculations have not yet been independently benchmarked against a trusted reference chart.
- Bhava Chalit boundaries are derived from the PDF's equal-division method; the resulting house assignment should be compared with worked examples in the book before release.
- Motion is a finite-difference estimate, not a full ephemeris velocity solution. Rahu/Ketu are mean nodes.
- This phase does not add divisional charts, Bhava Chalit interpretations, planetary dignity/shadbala, aspects, combustion, or Vimshottari Dasha.

## Verification

Added unit tests for twelve-house construction, total 360-degree coverage, midpoint assignment, and longitude-to-house mapping. Tests and Android build were not executed in this environment. Run the repository's GitHub Actions Android APK workflow on `dev` before merging or release.
