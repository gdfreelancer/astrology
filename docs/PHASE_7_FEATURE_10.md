# Phase 7 — Advanced Kundali Matching

## Delivered
- Retains the existing 36-point Ashtakoota score.
- Adds Manglik/Kuja indicators independently from Lagna, Moon and Venus for each chart using Mars in houses 1, 2, 4, 7, 8 or 12.
- Adds a seventh-house profile for each person: seventh sign, occupants and seventh lord's D1 house.
- Shows a side-by-side comparison without adding unsupported compatibility points.
- Existing saved report payloads remain readable; advanced profiles are derived from the saved D1 placements when present.

## Boundaries
- Manglik rules, house lists and cancellation conventions vary by lineage and region. This implementation reports the three reference-point indicators separately and does not claim a final dosha verdict or calculate cancellation.
- Seventh-house placement is descriptive; it does not score marriage outcomes or evaluate full aspects, dignity, divisional charts, Upapada, Navamsa strength or timing.
- Existing GeoEngine / approximate mean Lahiri calculation limitations remain. Birth-time uncertainty can materially change Lagna and house results.
- This is a traditional astrology reference, not relationship advice or a prediction.
