import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/core/weather_code.dart';

void main() {
  test('maps common WMO codes', () {
    expect(conditionForCode(0).description, 'Clear sky');
    expect(conditionForCode(63).description, 'Moderate rain');
    expect(conditionForCode(95).description, 'Thunderstorm');
    expect(conditionForCode(99).description, contains('hail'));
  });

  test('unknown codes fall back to "Unknown"', () {
    expect(conditionForCode(1234).description, 'Unknown');
    expect(conditionForCode(-1).description, 'Unknown');
  });
}
