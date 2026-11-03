import 'package:flutter/foundation.dart';

import '../core/app_strings.dart';
import '../data/models/city.dart';
import '../data/models/weather_report.dart';
import '../data/weather_exceptions.dart';
import '../data/weather_repository.dart';

enum ScreenStatus { empty, loading, choosingCity, success, error }

/// Holds all screen state. Lives above the widget tree, so it survives rotation.
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._repository);

  final WeatherRepository _repository;

  static final _searchable = RegExp(r'[\p{L}\p{N}]', unicode: true);

  ScreenStatus _status = ScreenStatus.empty;
  WeatherReport? _report;
  List<City> _candidates = const [];
  List<City> _history = const [];
  String? _errorMessage;
  String? _inputError;
  String? _notice;
  bool _isStale = false;

  /// Only the response of the newest request may update the UI.
  int _requestId = 0;

  ScreenStatus get status => _status;
  WeatherReport? get report => _report;
  List<City> get candidates => _candidates;
  List<City> get history => _history;
  String? get errorMessage => _errorMessage;
  String? get inputError => _inputError;
  String? get notice => _notice;
  bool get isStale => _isStale;
  bool get hasReport => _report != null;

  /// Call once at startup: shows cached data immediately, then tries to refresh it.
  Future<void> init() async {
    _history = _repository.history();
    final cached = await _repository.cachedReport();
    if (cached != null) {
      _report = cached;
      _isStale = true;
      _status = ScreenStatus.success;
    }
    notifyListeners();
    if (cached != null) await refresh();
  }

  Future<void> search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty || !_searchable.hasMatch(query)) {
      _inputError = query.isEmpty ? AppStrings.emptyInput : AppStrings.invalidInput;
      notifyListeners();
      return; // never hits the API
    }

    final id = _startRequest();
    try {
      final cities = await _repository.searchCities(query);
      if (!_isCurrent(id)) return;
      if (cities.isEmpty) throw CityNotFoundException(query);

      if (cities.length == 1) {
        await _loadCity(cities.first, id);
      } else {
        _candidates = cities; // several matches: let the user choose
        _status = ScreenStatus.choosingCity;
        notifyListeners();
      }
    } on WeatherException catch (e) {
      if (_isCurrent(id)) _handleFailure(e);
    }
  }

  Future<void> selectCity(City city) async {
    final id = _startRequest();
    try {
      await _loadCity(city, id);
    } on WeatherException catch (e) {
      if (_isCurrent(id)) _handleFailure(e);
    }
  }

  /// Pull-to-refresh for the city currently shown. Keeps old data if it fails.
  Future<void> refresh() async {
    final current = _report;
    if (current == null) return;
    final id = ++_requestId;
    try {
      final fresh = await _repository.fetchWeather(current.city);
      if (_isCurrent(id)) _showReport(fresh);
    } on WeatherException catch (e) {
      if (!_isCurrent(id)) return;
      _isStale = true;
      _notice = e.message;
      notifyListeners();
    }
  }

  /// Leave the error screen and go back to the last saved report.
  void dismissError() {
    if (_report == null) return;
    _status = ScreenStatus.success;
    notifyListeners();
  }

  // ---- internals ----

  int _startRequest() {
    final id = ++_requestId;
    _status = ScreenStatus.loading;
    _inputError = null;
    _notice = null;
    notifyListeners();
    return id;
  }

  bool _isCurrent(int id) => id == _requestId;

  Future<void> _loadCity(City city, int id) async {
    final report = await _repository.fetchWeather(city);
    if (!_isCurrent(id)) return;
    _history = _repository.history();
    _showReport(report);
  }

  void _showReport(WeatherReport report) {
    _report = report;
    _isStale = false;
    _notice = null;
    _candidates = const [];
    _status = ScreenStatus.success;
    notifyListeners();
  }

  void _handleFailure(WeatherException e) {
    final canFallBack = _report != null && e is! CityNotFoundException;
    if (canFallBack) {
      // Network trouble but we have saved data: keep showing it, flagged as outdated.
      _isStale = true;
      _notice = e.message;
      _status = ScreenStatus.success;
    } else {
      _errorMessage = e.message;
      _status = ScreenStatus.error;
    }
    notifyListeners();
  }
}
