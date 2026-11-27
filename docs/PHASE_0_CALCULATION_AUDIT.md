# Phase 0 — Calculation foundation and verification

## Objective

Establish a safe, shared calculation foundation for the later Jyotish expansion phases while preserving all existing screens, saved profiles, chart preferences, reports, and offline behavior.

Phase 0 deliberately does **not** replace GeoEngine, change the selected astrology tradition, change existing chart formulas, or introduce new ephemeris dependencies. It adds input guards and automated regression coverage around the current calculation primitives.

## Existing foundation retained

The following implementations were already present on the `dev` branch and are retained:

- `AyanamshaService`: one shared Lahiri/Chitrapaksha mean-ayanamsha polynomial used by birth-chart, Panchang and Gochar calculations.
- `AstrologyMath`: longitude normalization, tropical-to-sidereal conversion, angular separation, Nakshatra/Pada, Tithi, Yoga and Karana indexing.
- Birth-chart calculation: local birth time is resolved through the IANA timezone database; the result includes tropical/sidereal Moon values, nine Grahas, Ascendant, MC and twelve Sripati-style Bhava boundaries.
- Whole-sign D1 house placement and a separate Bhava Chalit house number are retained as distinct values.
- Panchang calculations use the shared ayanamsha and angular helper functions.
- Mean Rahu and opposite Ketu are retained as the current node convention.

## Phase 0 changes

### 1. Shared input validation

Added `AstrologyInputValidator`:

- Validates finite latitude in the range -90° to +90°.
- Validates finite longitude in the range -180° to +180°.
- Validates 24-hour clock fields.
- Rejects empty timezone IDs.
- Validates supported calendar year range.
- Does not clamp, rewrite or silently normalize user-entered birth details.

Birth-chart calculations now validate date, time, coordinates and timezone ID before calculation. Panchang calculation entry points validate coordinates and timezone ID before requesting astronomical events.

Valid saved profiles and existing supported locations continue to use the same calculation path.

### 2. Regression tests added

Added Flutter unit tests for:

- Positive, negative and full-circle longitude normalization.
- Tropical-to-sidereal conversion.
- Nakshatra and Pada boundaries.
- Tithi indexing across the 0°/360° wrap.
- Yoga indexing.
- All 60 half-tithi Karana positions, including the four fixed Karana positions.
- Lahiri mean-ayanamsha J2000 reference epoch and UTC-instant equivalence.
- Coordinate, clock and timezone-ID validation.
- Birth-local-time to UTC conversion.
- Birth-chart output invariants: nine Grahas, twelve Bhava entries, normalized longitudes and valid sign/house indices.
- Invalid birth input rejection.

These tests protect mathematical invariants and current behavior. They are not a substitute for comparison against an independent astronomical ephemeris.

## Current calculation conventions and limitations

| Area | Current behavior | What remains unverified or out of scope |
|---|---|---|
| Ayanamsha | Mean Lahiri/Chitrapaksha polynomial | Not a full high-precision Lahiri implementation; no independent ephemeris comparison has been completed |
| Planet positions | GeoEngine geocentric/apparent ecliptic positions as used by the existing service | Must be benchmarked against a trusted ephemeris across dates and locations |
| Moon | GeoEngine geocentric Moon longitude | Reference comparison and boundary accuracy still required |
| Rahu/Ketu | Mean ascending node and exact opposite point | True-node option is not implemented |
| Retrograde | Estimated from a centered 24-hour longitude difference for visible planets; nodes use the mean-node convention | Motion estimate and station/retrograde boundary precision need reference validation |
| Ascendant/MC | Derived from GeoEngine sidereal time and obliquity, then corrected by mean Lahiri | Requires independent chart fixture validation at varied latitudes and near sign boundaries |
| Houses | Twelve Sripati-style Bhava Madhya boundaries are calculated; whole-sign D1 house and Bhava house remain separate | Must validate against trusted worked examples; high-latitude behavior requires special attention |
| Timezone | IANA timezone database resolves local birth date/time to UTC | Ambiguous and nonexistent local times around DST transitions need explicit UX and dedicated policy |
| Panchang | Sun/Moon angular calculations use shared math and mean Lahiri correction; sunrise/sunset use GeoEngine | Boundary and regional observance rules need reference fixtures |
| Divisional charts | Existing Varga service remains unchanged | Each Varga formula requires a separate tradition-specific audit |
| Gochar | Existing transit calculations use shared mean Lahiri correction | Transit event timing and retrograde boundaries need validation |

## Accuracy and licensing policy

- Do not describe the current engine as professionally or ephemeris-validated until independent reference fixtures have been checked.
- Do not silently switch astronomy libraries or add a commercial ephemeris dependency. Review license terms and redistribution obligations first.
- Keep the currently selected calculation conventions stable unless a separately reviewed change explicitly updates them.
- Any future calculation setting must be stored with the chart/report so a result can be reproduced.
- Keep astronomical calculation outputs separate from traditional interpretations.
- Do not treat a unit test that checks a mathematical invariant as proof that the underlying astronomical position is accurate.

## Non-regression policy

Phase 0 does not remove or redesign any existing feature. It preserves:

- Birth profile storage and selection.
- Existing timezone selection.
- North, South and East chart-style preference.
- Existing D1 and Bhava chart data structures.
- Existing Panchang and Gochar calculation entry points.
- Existing offline data and dependencies.

## Verification status

- Automated test files have been added under `test/`.
- No local Flutter commands were run.
- The manual GitHub Actions Android APK workflow has not been run as part of these source edits.
- Run the repository's existing manual-only workflow on `dev` to verify dependency resolution, static analysis and Android release packaging.

## Next validation milestone

Before a future advanced strength, Yoga or Dosha expansion, add independently sourced reference fixtures for:

1. Planetary longitudes at representative dates.
2. Moon longitude and Nakshatra/Pada boundary cases.
3. Ascendant and MC at low, mid and high latitudes.
4. Bhava Madhya and house boundary examples.
5. Sunrise/sunset and Panchang transition times.
6. DST transitions and historical timezone changes.

Each fixture must record its source, ephemeris/version, ayanamsha, node convention, house system, timezone and expected tolerance.
