# Remedies implementation audit — second PDF

Source: uploaded *रत्न व ज्योतिषीय उपाय* (26 pages). The implementation uses the PDF's own terminology and tables. It deliberately does not convert traditional statements into medical claims or guaranteed predictions.

## Implemented on `dev`

### Phase 1 — Core remedies
- Remedies home screen and entry from the main home grid.
- Graha detail screens now include source-derived life-area associations, deity associations and worship references.
- Nine Graha mantras and the nine source-prescribed chanting counts.
- Navagraha Shanti Shloka with meaning and traditional worship sequence.
- Mantra progress, daily count, favourites, reset and multiple user-created chanting goals using a local SQLite database.

### Phase 2 — Gemstone guide
- Nine gemstone catalogue entries.
- Lagna-wise table with Jeevan Ratna, Karak Ratna and Bhagya Ratna for all 12 Lagnas.
- Traditional metal, finger, weekday, time, weight and lifespan information.
- Source-listed incompatible gemstone combinations.
- Navratna 3×3 arrangement.
- Finger-wise reference from PDF page 16.
- Unclear Diamond weight is left unspecified rather than guessed.
- Suitability warnings distinguish source table references from personal recommendations.

### Phase 3 — Personalized remedy assessment
- Saved BirthProfile selection and offline recalculation through the existing BirthChartService.
- Twelve source criteria are displayed with explicit Evaluated / Partial / Not evaluated status.
- Uses available Kendra/Trikona lord ownership, retrograde state, dignity, current Mahadasha and Antardasha.
- Does not invent combustion, house/planet affliction scores, complete friendship, Yogakaraka, Badhaka/Maraka or divisional-chart judgement.
- Basic Rahu–Ketu enclosure screening is labelled a candidate pattern, not a definitive Kaal Sarp Yoga diagnosis.
- No automatic gemstone prescription.

### Phase 4 — Yantra and Rudraksha
- Yantra reference screen with source material and preparation notes.
- Rudraksha catalogue names Gauri Shankar and 1–15 Mukhi.
- The PDF's page 8 contains a low-resolution plate of nine Yantra illustrations; page 20 contains Rudraksha photographs. Those page images have been inspected, but the original image assets have not yet been packaged into the Flutter assets directory. No Yantra grid or Mukhi-specific benefit has been recreated or invented.
- Detailed Mukhi-wise descriptions are not present in the PDF and remain intentionally unfilled.

### Phase 5 — Dosha remedies
- Shani Dhaiya three-phase table for all 12 Moon signs, transcribed from PDF page 21.
- Shani remedies from page 22, including the conditional Blue Sapphire / iron-ring note.
- Gochar screen links to Shani Dhaiya reference only when the existing transit calculation detects Dhaiya.
- Kaal Sarp traditional effects and remedies from pages 23–24.
- Snake-feeding advice is explicitly not endorsed; users are directed away from approaching or feeding wild snakes.

### Phase 6 — Integration
- Remedies home entry from main home screen.
- Graha details link to Mantra Library and Gemstone Guide.
- Kundali result links to Personalized Remedies and Remedies.
- Gochar links to Shani Dhaiya.
- Main Remedies navigation strings have English, Hindi and Gujarati translations.

## Source mapping

| PDF pages | App destination |
|---|---|
| 3–4 | Graha detail → traditional associations |
| 5 | Personalized Remedies → 12-factor assessment |
| 6 | Navagraha Worship → Shanti Shloka and sequence |
| 7–8 | Yantra Library → material/preparation note and source illustration reference |
| 9 | Mantra Library → nine mantras and counts |
| 10–11 | Gemstone Guide → principles and suitability cautions |
| 12 | Gemstone Guide → 12-Lagna table |
| 13–14 | Gemstone detail → wearing and lifespan references |
| 15–16 | Gemstone Guide → Navratna and finger references |
| 17–19 | Personalized gemstone cautions and source principles |
| 20 | Rudraksha Guide → Gauri Shankar and 1–15 catalogue |
| 21–22 | Shani Dhaiya → three-phase table and remedies |
| 23–24 | Kaal Sarp → traditional effects and remedies |
| 25 | Graha detail → source-specific deity associations |

## Remaining limitations requiring source assets or further validation

1. Bundle the exact PDF page 8 Yantra plate and page 20 Rudraksha plate as app image assets. The source images are low-resolution; use the original PDF or a clearer licensed source for production-quality artwork.
2. The exact source image assets are not yet bundled; the catalogue currently explains this limitation rather than displaying reconstructed or guessed artwork.
3. The deep reference prose is not yet fully translated line-by-line into Hindi and Gujarati; the main Remedies navigation and key entry labels are translated.
4. Complete gemstone suitability is not implemented. It requires a validated rule set for all Lagnas, full functional lordship, friendship, combustion, aspects, Dasha, Maraka/Badhaka and divisional charts.
5. The PDF's detailed Aries example is not generalised to all 12 Lagnas.
6. Kaal Sarp screening is a basic enclosure check and must not be treated as a definitive classification.
7. Yantra inscriptions and detailed Rudraksha benefits are not reliably readable or described in the PDF; do not fabricate them.

## Accuracy and safety
- Traditional gemstone weights, lifespans, incompatible combinations, deity mappings and remedies are attributed to this source and may differ by lineage.
- The PDF contains disease associations; the app intentionally does not display these as diagnoses or treatments.
- No gemstone is automatically recommended from Lagna, Sun sign, Moon sign or a single weak/retrograde planet.
- The app's existing astronomical calculations retain their existing accuracy caveats; this feature does not upgrade the ephemeris.
- All user-created mantra progress and favourites are stored locally. No backend or network service is required.

## Verification status
- Source files and translations are reviewed after the edits.
- JSON parse and required-key checks are performed before commit.
- Flutter analyzer and APK build have not been run in this environment. The existing Android workflow remains manual-only; run it manually after the changes and share any failure logs for correction.
