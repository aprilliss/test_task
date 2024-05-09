class GeoData {
  final double latitude;
  final double longitude;
  final String country;
  final String countryCode;
  final String city;
  final String timezone;
  final String ip;

  GeoData(this.latitude, this.longitude, this.country, this.countryCode,
      this.city, this.timezone, this.ip);

  factory GeoData.fromJson(Map<String, dynamic> json) {
    return GeoData(
      json['lat'],
      json['lon'],
      json['country'],
      json['countryCode'],
      json['city'],
      json['timezone'],
      json['query'],
    );
  }

  @override
  String toString() {
    return 'GeoData{latitude: $latitude, longitude: $longitude, country: $country, countryCode: $countryCode, city: $city, timezone: $timezone, ip: $ip}';
  }
}
