import '../core/app_strings.dart';

/// Every failure the UI needs to know about, each with a user-friendly message.
abstract class WeatherException implements Exception {
  const WeatherException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CityNotFoundException extends WeatherException {
  CityNotFoundException(String query) : super(AppStrings.cityNotFound(query));
}

class NoConnectionException extends WeatherException {
  const NoConnectionException() : super(AppStrings.noConnection);
}

class RequestTimeoutException extends WeatherException {
  const RequestTimeoutException() : super(AppStrings.timeout);
}

class ApiException extends WeatherException {
  const ApiException() : super(AppStrings.apiFailure);
}
