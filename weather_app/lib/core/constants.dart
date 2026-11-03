/// All network-related constants live here (no magic values elsewhere).
class ApiConstants {
  static const geocodingHost = 'geocoding-api.open-meteo.com';
  static const geocodingPath = '/v1/search';
  static const forecastHost = 'api.open-meteo.com';
  static const forecastPath = '/v1/forecast';

  static const maxCityResults = 5;
  static const forecastDays = 5;
  static const requestTimeout = Duration(seconds: 10);

  static const currentFields =
      'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m';
  static const dailyFields =
      'weather_code,temperature_2m_max,temperature_2m_min';
}

class StorageKeys {
  static const lastReport = 'last_weather_report';
  static const searchHistory = 'search_history';
  static const maxHistoryItems = 5;
}

class Units {
  static const temperature = '°C';
  static const humidity = '%';
  static const windSpeed = 'km/h';
}

class SearchLimits {
  static const maxQueryLength = 60;
}
