import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import 'models/city.dart';
import 'models/weather_report.dart';
import 'weather_exceptions.dart';

/// Talks to Open-Meteo. Translates every low-level failure into a [WeatherException].
class WeatherApi {
  WeatherApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Step 1: city name -> candidate cities. Returns an empty list if nothing matches.
  Future<List<City>> searchCities(String name) async {
    final uri = Uri.https(ApiConstants.geocodingHost, ApiConstants.geocodingPath, {
      'name': name,
      'count': '${ApiConstants.maxCityResults}',
      'language': 'en',
      'format': 'json',
    });
    final json = await _getJson(uri);

    // When nothing matches, the API omits the "results" field entirely.
    final results = json['results'];
    if (results == null) return const [];

    return _parse(() => (results as List)
        .map((e) => City.fromJson(e as Map<String, dynamic>))
        .toList());
  }

  /// Step 2: coordinates -> current weather + 5-day forecast.
  Future<WeatherReport> fetchForecast(City city) async {
    final uri = Uri.https(ApiConstants.forecastHost, ApiConstants.forecastPath, {
      'latitude': '${city.latitude}',
      'longitude': '${city.longitude}',
      'current': ApiConstants.currentFields,
      'daily': ApiConstants.dailyFields,
      'forecast_days': '${ApiConstants.forecastDays}',
      'timezone': 'auto',
    });
    final json = await _getJson(uri);
    return _parse(
        () => WeatherReport.fromApiJson(city, json, fetchedAt: DateTime.now()));
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(ApiConstants.requestTimeout);
      if (response.statusCode != 200) throw const ApiException();
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) throw const ApiException();
      return decoded;
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on SocketException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    } on FormatException {
      throw const ApiException();
    }
  }

  /// Wraps JSON-shape problems (wrong types, missing fields) into [ApiException].
  T _parse<T>(T Function() parser) {
    try {
      return parser();
    } catch (_) {
      throw const ApiException();
    }
  }
}
