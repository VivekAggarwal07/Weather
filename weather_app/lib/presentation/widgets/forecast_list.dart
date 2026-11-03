import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/constants.dart';
import '../../core/date_format.dart';
import '../../core/weather_code.dart';
import '../../data/models/weather_report.dart';

class ForecastList extends StatelessWidget {
  const ForecastList({super.key, required this.days});

  final List<DailyForecast> days;

  String _label(int index, DailyForecast day) {
    if (index == 0) return AppStrings.today;
    if (index == 1) return AppStrings.tomorrow;
    return weekdayName(day.date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(AppStrings.forecastTitle,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          for (var i = 0; i < days.length; i++) _row(i, days[i]),
        ],
      ),
    );
  }

  Widget _row(int index, DailyForecast day) {
    final condition = conditionForCode(day.weatherCode);
    return ListTile(
      leading: Text(condition.icon, style: const TextStyle(fontSize: 28)),
      title: Text(_label(index, day)),
      subtitle: Text('${shortDate(day.date)} · ${condition.description}'),
      trailing: Text(
        '${day.minTemp.round()}${Units.temperature} / ${day.maxTemp.round()}${Units.temperature}',
      ),
    );
  }
}
