# Phase 1 — Jyotish Dashboard and Birth Profile Management

## Objective

Make the selected birth profile the shared offline input for the app, surface useful daily chart context on the home dashboard, and preserve recent Kundali report entries for quick reopening. Existing screens and calculation services remain available.

## Dashboard work

### Existing dashboard retained
- Greeting and localized date.
- Create Kundali action.
- Today's Panchang summary and full Panchang navigation.
- Feature cards for horoscope, Rashi, Graha, matching, Muhurat, remedies, learning, transit calendar and other existing modules.
- Existing settings and saved Panchang location.

### Additions
- Active birth-profile card showing profile name, birthplace, recorded birth time and time-accuracy label.
- Direct navigation to manage/select saved profiles.
- Current Vimshottari Mahadasha and Antardasha summary for the selected profile.
- Current Saturn Gochar summary, showing Sade Sati or Dhaiya status from the existing transit service.
- Recent Kundali report list (latest three displayed; eight retained locally). Selecting an entry reopens the Kundali form with the exact stored birth details.

## Birth profile management

### Active profile selection
- Persist the selected profile ID separately from the profile collection.
- First saved profile becomes active when no active profile exists.
- Selecting another profile updates the active selection.
- Deleting the active profile selects the next available profile; deleting the final profile clears selection.
- The dashboard and Create Kundali screen reuse the active profile.

### More precise birth details
- Birth time now stores hour, minute and second.
- Time accuracy is stored as Exact, Approximate or Unknown.
- Existing saved profiles remain readable: missing seconds default to 00 and missing accuracy defaults to Unknown.
- The Birth Chart service accepts seconds and uses them when converting local birth time to UTC.
- Kundali history stores a complete profile snapshot, so recent reports can be reopened without creating duplicate saved profiles.

### Location and timezone
- Birthplace geocoding and coordinate verification remain unchanged.
- The existing IANA timezone picker remains available and is used to resolve the historical local birth time.
- Automatic location-to-IANA-timezone resolution is not added in this phase. A reliable offline coordinate-to-timezone database is not currently part of the project; the app does not guess a timezone from the device's current offset.

## Local storage

- Existing birth profiles remain in SharedPreferences under the existing versioned key.
- The active profile ID uses a separate preference key.
- Recent Kundali report history uses its own versioned preference key and retains up to eight entries.
- Existing profile JSON remains backward-compatible.

## Localization

New profile-selection, time-accuracy, seconds and recent-report labels are added to English, Hindi and Gujarati translation files. Existing translation keys are retained.

## Tests added

- Birth profile JSON round-trip with seconds and time accuracy.
- Backward compatibility for older profiles without the new fields.
- Active profile defaults, explicit selection, deletion fallback and final deletion.
- Recent report persistence and retention limit.
- Birth-time seconds validation and timezone conversion.

## Known remaining work

- Automatic timezone lookup from coordinates needs an offline timezone polygon/database or a supported platform timezone provider; no approximate offset guessing is used.
- Daily horoscope content remains the existing general Rashi-based feature; it is not silently re-labelled as a personalized transit prediction.
- Recent reports are local calculation-history entries, not exported PDF files. PDF export remains available from the Kundali result screen.
- A dedicated profile-based baby-name prefill can be connected in a later pass if desired; the existing baby-name flow remains unchanged.

## Non-regression

- Existing birth profiles without seconds/accuracy metadata are migrated at read time using safe defaults.
- Existing profile IDs and stored JSON fields are retained.
- Existing chart-style preference, Panchang location, language selection, D1/Bhava calculations, report PDF generation and all feature navigation remain unchanged.
- No backend or network service is introduced for profile storage or report history.

## Verification status

- Phase 1 source changes and regression tests are committed on `dev`.
- No Flutter tests, analyzer or Android build have been executed in this environment.
- The Android APK workflow remains manual-only. Run it on `dev` to validate dependency resolution, static analysis and release packaging before release.
