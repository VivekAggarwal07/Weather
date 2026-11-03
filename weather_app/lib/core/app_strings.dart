/// User-facing text in one place.
class AppStrings {
  static const appTitle = 'Weather';
  static const searchHint = 'Search for a city';

  static const emptyTitle = 'Search for a city to see its weather';
  static const emptyHint = 'Try "Berlin" or "Tokyo".';
  static const recentSearches = 'Recent searches';

  static const emptyInput = 'Please enter a city name.';
  static const invalidInput = 'Please enter a valid city name (letters or numbers).';

  static const chooseCityTitle = 'Which city did you mean?';

  static String cityNotFound(String query) =>
      'We couldn\'t find a city called "$query". Check the spelling and try again.';
  static const noConnection =
      'No internet connection. Please check your network and try again.';
  static const timeout = 'The request took too long. Please try again.';
  static const apiFailure = 'Something went wrong while loading the weather. Please try again.';

  static const errorTitle = 'Oops';
  static const backToSaved = 'Show saved weather';

  static const humidity = 'Humidity';
  static const wind = 'Wind';
  static const today = 'Today';
  static const tomorrow = 'Tomorrow';
  static const forecastTitle = '5-day forecast';
  static const unknownCondition = 'Unknown';

  static const staleDefault = 'Showing saved data. It may be outdated.';
  static String lastUpdated(String when) => 'Last updated: $when';
}
