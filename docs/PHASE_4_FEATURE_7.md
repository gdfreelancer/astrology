# Phase 4 — Feature 7: Divisional (Varga) Charts

## Implemented

Added a divisional-chart calculation service and a dedicated screen reachable from Kundali results. The selector provides all fifteen Varga charts listed in the roadmap:

- D2 Hora
- D3 Drekkana
- D4 Chaturthamsa
- D7 Saptamsa
- D9 Navamsa
- D10 Dasamsa
- D12 Dwadashamsa
- D16 Shodashamsa
- D20 Vimshamsa
- D24 Chaturvimshamsa
- D27 Saptavimshamsa
- D30 Trimshamsa
- D40 Khavedamsa
- D45 Akshavedamsa
- D60 Shashtiamsa

For each chart, the app maps the natal sidereal Ascendant and all nine grahas into divisional signs, recalculates houses from the divisional Ascendant, and shows the sign and planet occupants for all twelve houses. The D1 chart and its saved North/South/East display preference are unchanged.

## Calculation conventions

The service implements common Parashari sign-division conventions:
- D2: Hora split with Leo/Cancer assignment reversed for even signs.
- D3, D4, D12: sequential sign divisions with the traditional sign offsets.
- D7: odd signs counted from themselves; even signs from the seventh.
- D9: movable from itself, fixed from the ninth, dual from the fifth.
- D10: odd signs from themselves; even signs from the ninth.
- D16, D20, D45: modality-based starting signs.
- D24: odd signs from Leo and even signs from Cancer.
- D27: element-based starts (Aries, Cancer, Libra, Capricorn).
- D30: unequal planetary segments with traditional planetary own-sign assignments, separately for odd and even signs.
- D40: odd signs from Aries; even signs from Libra.
- D60: odd signs from Aries; even signs from Libra, proceeding sequentially.

Regional lineages and Jyotish schools can use variant rules, particularly for some higher Vargas. The implemented convention should be explicitly compared with the intended source/tradition before treating charts as authoritative.

## Accuracy limitations

All divisional positions inherit the app's existing GeoEngine planetary positions and approximate Lahiri ayanamsha. The current birth time is minute precision; higher divisions are especially sensitive to small birth-time and ephemeris differences. The screen displays placements only and does not add varga-specific interpretations, dignity, aspects, strength calculations or predictions.

## Verification

Added unit tests for the requested divisions, key sign rules, Trimshamsa unequal segments, boundary values, and divisional-house recalculation. Tests and Android build have not been executed in this environment. Run the GitHub Actions Android APK workflow on `dev` before release.
