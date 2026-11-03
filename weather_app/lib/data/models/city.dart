/// A geocoding result.
class City {
  const City({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String country;

  /// State or region, if the API provides one.
  final String? admin1;

  factory City.fromJson(Map<String, dynamic> json) => City(
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        country: (json['country'] as String?) ?? '',
        admin1: json['admin1'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'admin1': admin1,
      };

  /// "Berlin, Germany"
  String get displayName => country.isEmpty ? name : '$name, $country';

  /// Used to tell apart cities that share a name.
  String get subtitle => [if (admin1 != null && admin1!.isNotEmpty) admin1!, country]
      .where((s) => s.isNotEmpty)
      .join(', ');

  bool isSameLocation(City other) =>
      latitude == other.latitude && longitude == other.longitude;
}
