import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/data/models/city.dart';
import 'package:weather_app/data/weather_api.dart';
import 'package:weather_app/data/weather_cache.dart';
import 'package:weather_app/data/weather_exceptions.dart';
import 'package:weather_app/data/weather_repository.dart';
import 'package:weather_app/presentation/weather_view_model.dart';

const _berlin = {
  'name': 'Berlin',
  'latitude': 52.52,
  'longitude': 13.41,
  'country': 'Germany',
  'admin1': 'Berlin',
};

final _forecastJson = {
  'current': {
    'temperature_2m': 11.6,
    'relative_humidity_2m': 70,
    'weather_code': 3,
    'wind_speed_10m': 14.2,
  },
  'daily': {
    'time': ['2026-11-03', '2026-11-04', '2026-11-05', '2026-11-06', '2026-11-07'],
    'weather_code': [3, 61, 0, 999, 71],
    'temperature_2m_max': [12.0, 10.0, 9.0, 8.0, 3.0],
    'temperature_2m_min': [6.0, 5.0, 2.0, 1.0, -2.0],
  },
};

http.Response _json(Object body) => http.Response(jsonEncode(body), 200);

Future<WeatherViewModel> _viewModel(MockClient client) async {
  final prefs = await SharedPreferences.getInstance();
  return WeatherViewModel(WeatherRepository(
    api: WeatherApi(client: client),
    cache: WeatherCache(prefs),
  ));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('WeatherApi', () {
    test('missing "results" field gives an empty list', () async {
      final api = WeatherApi(client: MockClient((_) async => _json({'generationtime_ms': 1})));
      expect(await api.searchCities('Nowhereville'), isEmpty);
    });

    test('parses forecast, including an unknown weather code', () async {
      final api = WeatherApi(client: MockClient((_) async => _json(_forecastJson)));
      final report = await api.fetchForecast(City.fromJson(_berlin));
      expect(report.temperature, 11.6);
      expect(report.daily, hasLength(5));
      expect(report.daily[3].weatherCode, 999);
    });

    test('server error becomes ApiException', () async {
      final api = WeatherApi(client: MockClient((_) async => http.Response('oops', 500)));
      expect(api.searchCities('Berlin'), throwsA(isA<ApiException>()));
    });

    test('network failure becomes NoConnectionException', () async {
      final api = WeatherApi(
          client: MockClient((_) async => throw http.ClientException('offline')));
      expect(api.searchCities('Berlin'), throwsA(isA<NoConnectionException>()));
    });
  });

  group('WeatherViewModel', () {
    test('blank or symbol-only input never calls the API', () async {
      var calls = 0;
      final vm = await _viewModel(MockClient((_) async {
        calls++;
        return _json({});
      }));

      await vm.search('   ');
      expect(vm.inputError, isNotNull);
      await vm.search('@#\$%');
      expect(vm.inputError, isNotNull);
      expect(calls, 0);
      expect(vm.status, ScreenStatus.empty);
    });

    test('unknown city shows an error state', () async {
      final vm = await _viewModel(MockClient((_) async => _json({})));
      await vm.search('asdfghjk');
      expect(vm.status, ScreenStatus.error);
      expect(vm.errorMessage, contains('asdfghjk'));
    });

    test('single match loads weather and caches it', () async {
      final client = MockClient((request) async {
        if (request.url.host.startsWith('geocoding')) {
          return _json({'results': [_berlin]});
        }
        return _json(_forecastJson);
      });
      final vm = await _viewModel(client);
      await vm.search('Berlin');
      expect(vm.status, ScreenStatus.success);
      expect(vm.isStale, isFalse);

      // A fresh view model with a dead network still shows the saved data.
      final offline = await _viewModel(
          MockClient((_) async => throw http.ClientException('offline')));
      await offline.init();
      expect(offline.status, ScreenStatus.success);
      expect(offline.isStale, isTrue);
      expect(offline.report!.city.name, 'Berlin');
    });

    test('several matches let the user choose', () async {
      final client = MockClient((_) async => _json({
            'results': [_berlin, {..._berlin, 'country': 'USA', 'admin1': 'New Hampshire', 'latitude': 44.4}]
          }));
      final vm = await _viewModel(client);
      await vm.search('Berlin');
      expect(vm.status, ScreenStatus.choosingCity);
      expect(vm.candidates, hasLength(2));
    });

    test('no internet and nothing cached shows an error', () async {
      final vm = await _viewModel(
          MockClient((_) async => throw http.ClientException('offline')));
      await vm.search('Berlin');
      expect(vm.status, ScreenStatus.error);
    });
  });
}
