import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_strings.dart';
import '../core/constants.dart';
import '../data/models/city.dart';
import 'weather_view_model.dart';
import 'widgets/message_view.dart';
import 'widgets/weather_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<WeatherViewModel>().search(_controller.text);
  }

  void _pick(City city) {
    _controller.text = city.name;
    FocusScope.of(context).unfocus();
    context.read<WeatherViewModel>().selectCity(city);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _submit(),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(SearchLimits.maxQueryLength),
                ],
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint,
                  errorText: vm.inputError,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    tooltip: AppStrings.searchHint,
                    onPressed: _submit,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBody(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(WeatherViewModel vm) {
    switch (vm.status) {
      case ScreenStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ScreenStatus.empty:
        return _EmptyState(history: vm.history, onTap: _pick);

      case ScreenStatus.choosingCity:
        return ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(AppStrings.chooseCityTitle),
            ),
            for (final city in vm.candidates)
              ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(city.name),
                subtitle: Text(city.subtitle),
                onTap: () => _pick(city),
              ),
          ],
        );

      case ScreenStatus.success:
        return WeatherView(
          report: vm.report!,
          isStale: vm.isStale,
          notice: vm.notice,
          onRefresh: vm.refresh,
        );

      case ScreenStatus.error:
        return MessageView(
          icon: Icons.error_outline,
          title: AppStrings.errorTitle,
          message: vm.errorMessage,
          action: vm.hasReport
              ? TextButton(
                  onPressed: vm.dismissError,
                  child: const Text(AppStrings.backToSaved),
                )
              : null,
        );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.history, required this.onTap});

  final List<City> history;
  final void Function(City) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: MessageView(
            icon: Icons.wb_sunny_outlined,
            title: AppStrings.emptyTitle,
            message: AppStrings.emptyHint,
          ),
        ),
        if (history.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.recentSearches,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final city in history)
                      ActionChip(label: Text(city.name), onPressed: () => onTap(city)),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
