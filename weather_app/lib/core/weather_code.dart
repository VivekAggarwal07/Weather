import 'app_strings.dart';

/// A human readable description plus an emoji icon for a WMO weather code.
class WeatherCondition {
  const WeatherCondition(this.description, this.icon);
  final String description;
  final String icon;
}

const WeatherCondition _unknown = WeatherCondition(AppStrings.unknownCondition, '❓');

const Map<int, WeatherCondition> _conditions = {
  0: WeatherCondition('Clear sky', '☀️'),
  1: WeatherCondition('Mainly clear', '🌤️'),
  2: WeatherCondition('Partly cloudy', '⛅'),
  3: WeatherCondition('Overcast', '☁️'),
  45: WeatherCondition('Fog', '🌫️'),
  48: WeatherCondition('Depositing rime fog', '🌫️'),
  51: WeatherCondition('Light drizzle', '🌦️'),
  53: WeatherCondition('Moderate drizzle', '🌦️'),
  55: WeatherCondition('Dense drizzle', '🌧️'),
  56: WeatherCondition('Light freezing drizzle', '🌧️'),
  57: WeatherCondition('Dense freezing drizzle', '🌧️'),
  61: WeatherCondition('Slight rain', '🌧️'),
  63: WeatherCondition('Moderate rain', '🌧️'),
  65: WeatherCondition('Heavy rain', '🌧️'),
  66: WeatherCondition('Light freezing rain', '🌧️'),
  67: WeatherCondition('Heavy freezing rain', '🌧️'),
  71: WeatherCondition('Slight snow fall', '🌨️'),
  73: WeatherCondition('Moderate snow fall', '🌨️'),
  75: WeatherCondition('Heavy snow fall', '❄️'),
  77: WeatherCondition('Snow grains', '❄️'),
  80: WeatherCondition('Slight rain showers', '🌦️'),
  81: WeatherCondition('Moderate rain showers', '🌧️'),
  82: WeatherCondition('Violent rain showers', '🌧️'),
  85: WeatherCondition('Slight snow showers', '🌨️'),
  86: WeatherCondition('Heavy snow showers', '🌨️'),
  95: WeatherCondition('Thunderstorm', '⛈️'),
  96: WeatherCondition('Thunderstorm with slight hail', '⛈️'),
  99: WeatherCondition('Thunderstorm with heavy hail', '⛈️'),
};

/// Maps a WMO code to a condition. Unhandled codes fall back to "Unknown".
WeatherCondition conditionForCode(int code) => _conditions[code] ?? _unknown;
