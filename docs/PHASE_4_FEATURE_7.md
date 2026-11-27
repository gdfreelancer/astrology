# Phase 4 — Feature 7: Divisional (Varga) Charts

## Implemented

The existing divisional chart selector continues to provide all fifteen divisional charts (D2, D3, D4, D7, D9, D10, D12, D16, D20, D24, D27, D30, D40, D45 and D60). It maps the natal sidereal Ascendant and all nine grahas into divisional signs, recalculates houses from the divisional Ascendant, and displays all twelve houses. D1 and its saved North/South/East display preference are unchanged.

Phase 4 strength work is now integrated into the Divisional Charts screen:

- Vimsopaka Bala for the seven classical planets, with selectable Shadvarga, Saptavarga, Dashavarga and Shodashavarga schemes.
- The selected scheme's per-varga weights and component scores are displayed. Each scheme is checked to total exactly 20.
- Each component displays its divisional sign, sign lord, dignity relationship and Vimsopaka points.
- The Vimsopaka relationship ladder is Own 20, Great Friend 18, Friend 15, Neutral 10, Enemy 7 and Great Enemy 5. Natural friendship and temporary friendship are combined using the natal D1 sign relationship to the divisional sign lord.
- Per-varga dignity labels include exalted, debilitated, Moolatrikona, own, friendly, neutral and enemy sign. Moolatrikona uses the mapped degree within each division.
- Cross-varga indicators compare D1 with D9 (Vargottama) and D1 with D10. Each planet's complete selected-scheme breakdown is expandable.
- Pushkara Navamsa and Pushkara Bhaga flags are shown separately from Vimsopaka points and Shadbala.

## Selected calculation conventions

### Vimsopaka Bala weights

The implemented BPHS chapter 7 weight tables are:

| Varga | Shadvarga | Saptavarga | Dashavarga | Shodashavarga |
|---|---:|---:|---:|---:|
| D1 | 6 | 5 | 3 | 3.5 |
| D2 | 2 | 2 | 1.5 | 1 |
| D3 | 4 | 3 | 1.5 | 1 |
| D4 | — | — | — | 0.5 |
| D7 | — | 1 | 1.5 | 0.5 |
| D9 | 5 | 2.5 | 1.5 | 3 |
| D10 | — | — | 1.5 | 0.5 |
| D12 | 2 | 4.5 | 1.5 | 0.5 |
| D16 | — | — | 1.5 | 2 |
| D20 | — | — | — | 0.5 |
| D24 | — | — | — | 0.5 |
| D27 | — | — | — | 0.5 |
| D30 | 1 | 2 | 1.5 | 1 |
| D40 | — | — | — | 0.5 |
| D45 | — | — | — | 0.5 |
| D60 | — | — | 5 | 4 |
| **Total** | **20** | **20** | **20** | **20** |

The Saptavarga D9/D12 weights follow the verse order in the selected BPHS translation (D9 = 2.5, D12 = 4.5). Other published tables swap those weights; results from those tables are not numerically interchangeable. The selected convention is exposed in the scheme description rather than silently mixing tables.

The seven classical planets are scored. Rahu and Ketu are not assigned a classical Vimsopaka score in this implementation.

### Dignity and friendship

Vimsopaka grades are based on the relationship of each graha to the lord of its sign in the relevant Varga. Natural and temporary relationships are combined using the D1 natal sign placements. This is a selected Parashari-style convention; some software and Jyotish lineages use different relationship tables or dignity ladders.

### Vargottama and Pushkara

- Vargottama is flagged when a planet occupies the same sign in D1 and D9.
- Pushkara Navamsa uses the commonly used later degree table: fire signs 7th/9th, earth 3rd/5th, air 6th/8th and water 1st/3rd Navamsas. This list is tradition-specific and not universally standardized.
- Pushkara Bhaga uses the Jataka Parijata degree list, interpreted as the one-degree interval immediately below the named integer degree. The source verse directly discusses the Moon; applying the table to all grahas is a common modern extension. A point-orb interpretation is a different convention.
- D1/D10 sign repetition is shown as a comparison flag only; it is not called Vargottama.

## Relationship to Shadbala

Vimsopaka Bala is kept separate from Shadbala. Phase 2's full Shadbala engine has not yet been completed, so this feature does not fabricate or combine a Shadbala value. The Vimsopaka calculation can be used independently and later displayed alongside validated Shadbala results.

## Accuracy limitations

All divisional positions inherit the app's existing GeoEngine planetary positions and approximate Lahiri ayanamsha. Higher divisions, especially D60, are highly sensitive to birth-time and ephemeris errors. The birth time and ephemeris limitations remain visible in the UI. Varga strength is a traditional calculation, not a deterministic prediction.

## Verification

Added regression coverage for all four scheme totals, component counts, score bounds, Pushkara flags and D1/D9 repetition. The GitHub Actions Android workflow and Flutter test suite have not been executed from this environment. Run the manual Android APK workflow on `dev` before release.
