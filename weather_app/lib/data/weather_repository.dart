import 'models/city.dart';
import 'models/weather_report.dart';
import 'weather_api.dart';
import 'weather_cache.dart';

/// Single entry point for the view model: hides API + cache details.
class WeatherRepository {
  WeatherRepository({required WeatherApi api, required WeatherCache cache})
      : _api = api,
        _cache = cache;

  final WeatherApi _api;
  final WeatherCache _cache;

  Future<List<City>> searchCities(String query) => _api.searchCities(query);

  /// Fetches fresh data and saves it. A cache write failure never fails the request.
  Future<WeatherReport> fetchWeather(City city) async {
    final report = await _api.fetchForecast(city);
    try {
      await _cache.saveReport(report);
      await _cache.addToHistory(city);
    } catch (_) {/* caching is best-effort */}
    return report;
  }

  Future<WeatherReport?> cachedReport() => _cache.loadReport();

  List<City> history() => _cache.loadHistory();
}
