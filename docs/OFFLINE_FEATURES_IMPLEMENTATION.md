# Offline feature implementation status

Branch: dev

All additions in this document are designed to run locally. They do not require Firebase, a REST API, a hosted database or a user account. Existing birth profiles and diary entries use device-local storage; astronomy calculations run in the app.

## Implemented or extended

- Ashtakavarga: unreduced Bhinna Ashtakavarga for Sun through Saturn and Sarvashtakavarga. The implementation checks the standard totals (48, 49, 39, 54, 56, 52, 39; combined 337). Rahu and Ketu are excluded from the classical tables. A documented table variant is used.
- Graha Drishti: whole-sign 7th aspects and the commonly used special aspects of Mars, Jupiter and Saturn. Rahu/Ketu 5th/9th aspects are marked tradition-dependent.
- Yoga screening: preliminary Budhaditya, Chandra-Mangala, Gajakesari, Raja Yoga, Dhana Yoga, Vipreet Raja Yoga (Harsha/Sarala/Vimala) and Neecha Bhanga checks. These are placement screens, not complete classical strength/cancellation judgements.
- Graha condition and strength reference: sign dignity, simplified Baladi Avastha, approximate combustion orbs, Naisargika Bala constants and a coarse directional-house indicator.
- Nested Vimshottari periods: Pratyantardasha, Sookshma and Prana periods are derived proportionally from the parent period.
- Gochar context: current Mahadasha/Antardasha and Ashtakavarga BAV/SAV scores are shown alongside transits. Saturn Dhaiya (4th/8th from natal Moon) is screened for a selected date.
- Transit calendar: 180-day local offline scan for sign ingresses and retrograde/direct state changes.
- Muhurat screening: selected date is calculated using the saved Panchang location. Tithi, Nakshatra, Yoga, Karana, Choghadiya windows and Rahu Kaal are shown.
- South Indian matching: directional 10-Porutham screening is shown separately from the 36-point Ashtakoota result. The report also compares D9 placements, Manglik indicators and seventh-house profiles.
- Offline personal tools: local astrology diary, introductory Jyotish learning library, mantra reference and saved-profile D1 comparison.
- PDF sharing: Kundali D1/house summary and matching summary can be shared locally through the platform share sheet.

## Deliberately not represented as complete

These require more classical-rule research, calculation validation or additional UI/data work before they can be described as complete:

1. Full Shadbala: current screen only shows selected strength indicators. It does not calculate all six Bala components or a total Shadbala.
2. Complete event-specific Muhurat: current screen is a Panchang/Choghadiya screening, not a final marriage, Griha Pravesh, vehicle or business Muhurat. Tara Bala, Chandra Bala, Lagna selection, regional rules and exceptions remain.
3. Exact Sade Sati timeline: current screen identifies the phase on a selected date and screens Dhaiya. It does not yet generate validated historical/future start and end timestamps for each Saturn ingress/retrograde re-entry.
4. Complete transit interpretation: the transit calendar reports approximate calendar-day sign/direction changes. It is not a high-precision ephemeris or a predictive transit report.
5. Full yoga judgement: classical strength, aspects, functional lordship, cancellation, divisional confirmation and all regional definitions are not implemented for every yoga.
6. Complete marriage compatibility: D9 placements, Manglik and seventh-house profiles are displayed, but Upapada Lagna, full dosha cancellation, comprehensive planetary aspects, Papasamyam and all regional variants remain.
7. Regional Hindu calendar: existing festival/observance coverage remains a limited offline set, not a complete state-wise calendar for all traditions.
8. Full report package: PDF exports currently contain concise D1/house or matching summaries, not every chart, divisional chart, Dasha and analysis page.
9. Notifications: reminders are not yet scheduled through the device notification service.

## Accuracy and tradition notes

- The app continues to use its existing GeoEngine astronomy calculations and approximate mean Lahiri ayanamsha. It has not been benchmarked against Swiss Ephemeris.
- Ashtakavarga table variants can differ by a few bindus while preserving their fixed totals.
- South Indian Porutham rules are directional and regional. Its 28-point score must not be compared with the 36-point Ashtakoota score.
- All Jyotish interpretations are traditional reference material, not scientifically validated predictions or guarantees.

## Verification

No Flutter analyzer or Android release build has been run for this set of commits. The repository's Android APK workflow remains manual-only and contains dependency resolution, static analysis and release APK build steps.