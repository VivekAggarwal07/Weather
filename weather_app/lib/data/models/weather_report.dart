import 'city.dart';

int _code(Object? raw) => (raw as num?)?.toInt() ?? -1;

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
  });

  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        date: DateTime.parse(json['date'] as String),
        weatherCode: _code(json['weatherCode']),
        maxTemp: (json['maxTemp'] as num).toDouble(),
        minTemp: (json['minTemp'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weatherCode': weatherCode,
        'maxTemp': maxTemp,
        'minTemp': minTemp,
      };
}

/// Current weather + daily forecast for one city. Also the unit we cache.
class WeatherReport {
  const WeatherReport({
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.daily,
    required this.fetchedAt,
  });

  final City city;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;

  /// Parses the Open-Meteo forecast response.
  factory WeatherReport.fromApiJson(
    City city,
    Map<String, dynamic> json, {
    required DateTime fetchedAt,
  }) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final dates = (daily['time'] as List).cast<String>();
    final codes = daily['weather_code'] as List;
    final maxes = daily['temperature_2m_max'] as List;
    final mins = daily['temperature_2m_min'] as List;

    return WeatherReport(
      city: city,
      temperature: (current['temperature_2m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).round(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: _code(current['weather_code']),
      fetchedAt: fetchedAt,
      daily: [
        for (var i = 0; i < dates.length; i++)
          DailyForecast(
            date: DateTime.parse(dates[i]),
            weatherCode: _code(codes[i]),
            maxTemp: (maxes[i] as num).toDouble(),
            minTemp: (mins[i] as num).toDouble(),
          ),
      ],
    );
  }

  factory WeatherReport.fromJson(Map<String, dynamic> json) => WeatherReport(
        city: City.fromJson(json['city'] as Map<String, dynamic>),
        temperature: (json['temperature'] as num).toDouble(),
        humidity: (json['humidity'] as num).toInt(),
        windSpeed: (json['windSpeed'] as num).toDouble(),
        weatherCode: _code(json['weatherCode']),
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        daily: (json['daily'] as List)
            .map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'city': city.toJson(),
        'temperature': temperature,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'weatherCode': weatherCode,
        'fetchedAt': fetchedAt.toIso8601String(),
        'daily': daily.map((d) => d.toJson()).toList(),
      };
}
