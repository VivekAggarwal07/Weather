# Weather App (Flutter)

Search for a city and see its current weather plus a 5-day forecast, using the free
[Open-Meteo](https://open-meteo.com/en/docs) API (no API key).

## Technology
- Flutter 3.x (Dart 3.3+). Tested target: Android and iOS.

## Setup
This repo contains `lib/`, `test/` and `pubspec.yaml`. Generate the platform folders once:

```bash
flutter create . --platforms=android,ios --project-name weather_app
flutter pub get
flutter run
flutter test
```

**Android release builds:** add `<uses-permission android:name="android.permission.INTERNET"/>`
to `android/app/src/main/AndroidManifest.xml` (debug builds have it automatically).

## Features
Must-haves
- City search; empty / symbols-only input is rejected without calling the API
- Two-step flow: geocoding, then forecast
- Current weather: city, country, temperature, condition (text + emoji), humidity, wind
- 5-day forecast: day/date, icon, min/max
- Loading indicator (async, UI never blocks), 10 s timeout
- Error states: city not found, no internet, timeout, API failure. No crashes.
- Empty state before the first search
- Offline support: last successful result is saved; shown with an "outdated" banner and
  last-updated time when the network fails

Edge cases
- Several matches (e.g. same city name in different countries): a list is shown to choose from
  (with region + country). A single match is used directly.
- Searching while a request is in flight: only the newest request can update the UI
- Unknown weather codes show "Unknown"
- Rotation: state lives in a view model above the widget tree, so nothing is lost
- Restart: cached report is shown immediately, then refreshed in the background
- Corrupt cache is detected and discarded

Bonus
- Pull-to-refresh
- Dark mode (follows system)
- Recent searches (last 5, shown as chips on the empty state)
- Unit tests (weather-code mapping, parsing, API errors, view-model flows, offline cache)

## Architecture
MVVM with `ChangeNotifier` + `provider`.
```
lib/
  core/          constants, strings, weather-code mapping, date helpers
  data/          models, WeatherApi (HTTP), WeatherCache (shared_preferences), WeatherRepository
  presentation/  WeatherViewModel (state), HomeScreen, widgets
```
- UI only reads state from the view model and calls its methods.
- The view model talks only to the repository; the repository hides API and cache.
- The API layer converts every low-level failure into a typed `WeatherException` with a
  user-friendly message.
- I chose Provider because the state is small and a single `ChangeNotifier` keeps it easy to read and test.

## Libraries
`http`, `provider`, `shared_preferences` (dev: `flutter_test`, `flutter_lints`).

## Assumptions and known limitations
- Metric units only (°C, km/h); no Fahrenheit toggle.
- Emoji are used as weather icons, so their look varies by platform.
- Only one report is cached (the last one). Searching a *new* city while offline can't work,
  since geocoding needs the network; the saved report stays visible instead.
- The forecast "Today" label is the first day returned for the city's own timezone.
- Search history entries are re-fetched when tapped (they are not cached individually).

## With more time
- Fahrenheit toggle, current-location lookup with permission handling
- Hourly forecast and a weekly temperature chart
- Cache several cities, widget tests for the screens, localization
