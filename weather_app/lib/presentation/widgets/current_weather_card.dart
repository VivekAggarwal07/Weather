import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/constants.dart';
import '../../core/weather_code.dart';
import '../../data/models/weather_report.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({super.key, required this.report});

  final WeatherReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final condition = conditionForCode(report.weatherCode);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(report.city.displayName,
                style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            if (report.city.admin1 != null)
              Text(report.city.admin1!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(condition.icon, style: const TextStyle(fontSize: 64)),
            Text('${report.temperature.round()}${Units.temperature}',
                style: theme.textTheme.displayMedium),
            Text(condition.description, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(
                  label: AppStrings.humidity,
                  value: '${report.humidity}${Units.humidity}',
                ),
                _Stat(
                  label: AppStrings.wind,
                  value: '${report.windSpeed.round()} ${Units.windSpeed}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}
