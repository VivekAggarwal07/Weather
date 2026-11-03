import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/date_format.dart';
import '../../data/models/weather_report.dart';
import 'current_weather_card.dart';
import 'forecast_list.dart';

/// Success state: current weather + forecast, with pull-to-refresh.
class WeatherView extends StatelessWidget {
  const WeatherView({
    super.key,
    required this.report,
    required this.isStale,
    required this.notice,
    required this.onRefresh,
  });

  final WeatherReport report;
  final bool isStale;
  final String? notice;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (isStale) _StaleBanner(notice: notice, fetchedAt: report.fetchedAt),
          CurrentWeatherCard(report: report),
          const SizedBox(height: 12),
          ForecastList(days: report.daily),
        ],
      ),
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.notice, required this.fetchedAt});

  final String? notice;
  final DateTime fetchedAt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: scheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${notice ?? AppStrings.staleDefault}\n'
              '${AppStrings.lastUpdated(timestamp(fetchedAt))}',
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
