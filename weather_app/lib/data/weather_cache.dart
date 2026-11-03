import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import 'models/city.dart';
import 'models/weather_report.dart';

/// Local persistence: last successful report + recent searches.
class WeatherCache {
  WeatherCache(this._prefs);

  final SharedPreferences _prefs;

  Future<void> saveReport(WeatherReport report) =>
      _prefs.setString(StorageKeys.lastReport, jsonEncode(report.toJson()));

  /// Returns null when nothing is saved or the saved data is corrupt.
  Future<WeatherReport?> loadReport() async {
    final raw = _prefs.getString(StorageKeys.lastReport);
    if (raw == null) return null;
    try {
      return WeatherReport.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _prefs.remove(StorageKeys.lastReport);
      return null;
    }
  }

  List<City> loadHistory() {
    final raw = _prefs.getString(StorageKeys.searchHistory);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addToHistory(City city) async {
    final history = loadHistory()..removeWhere(city.isSameLocation);
    history.insert(0, city);
    final trimmed = history.take(StorageKeys.maxHistoryItems).toList();
    await _prefs.setString(
      StorageKeys.searchHistory,
      jsonEncode(trimmed.map((c) => c.toJson()).toList()),
    );
  }
}
