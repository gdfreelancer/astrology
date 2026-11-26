# Phase 5 — Feature 8: Advanced Panchang & Lunar Events

## Implemented

The existing Panchang dashboard, five Panchang elements, sunrise/sunset and moonrise/moonset, Choghadiya, daily time windows, monthly Tithi calendar and observance finder remain available.

Added an Advanced Lunar & Solar Events screen, reachable from the Panchang explorer. It provides:
- Current selected-date Moon phase at local noon.
- Approximate illuminated fraction as a percentage.
- Upcoming 90-day event list with All, Lunar and Solar filters.
- New Moon, First Quarter, Full Moon and Last Quarter instants.
- Shukla and Krishna Ekadashi tithi start instants.
- Sidereal solar sign ingress (Sankranti), including the entered Rashi.
- Localized English, Hindi and Gujarati labels and location-timezone display.

## Calculation approach

The service scans the selected location's 90-day range in six-hour intervals. It detects crossings of lunar angular-separation boundaries (90-degree phase boundaries and 12-degree tithi boundaries) and sidereal solar 30-degree sign boundaries. Each detected crossing is refined by iterative bisection. The event timestamps are stored in UTC and rendered in the selected location's time zone.

Moon illumination is estimated geometrically from the Sun–Moon angular separation using (1 − cos(elongation)) / 2. The phase label uses angular-separation bands.

## Important limitations

- The calculation inherits GeoEngine positions and the app's approximate Lahiri ayanamsha. These event times are estimates, not Swiss Ephemeris-validated output.
- Ekadashi entries mark the astronomical start of the eleventh tithi. They do not decide the correct regional vrata date, which can depend on sunrise, Dashami/Vidhi overlap, local tradition and other rules.
- Full Moon and New Moon are astronomical angular events; regional observance dates may differ.
- Sankranti is based on the app's sidereal solar longitude and may differ slightly from authoritative Panchang almanacs.
- This phase does not add eclipse prediction, a complete regional festival database, Amanta/Purnimanta lunar-month naming, or sunrise-based vrata adjudication.

## Tests and verification

Added `test/advanced_lunar_events_test.dart` for illumination bounds, phase labels, chronological event ordering, event categories and Sankranti sign indexes. Tests and Android build have not been executed in this environment. Run the manual GitHub Actions Android APK workflow on `dev` before release.
