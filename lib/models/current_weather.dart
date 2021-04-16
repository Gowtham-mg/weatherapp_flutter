import 'dart:convert';

class CurrentWeather {
  final String city;
  final double latitude;
  final double longitude;
  final double temperature;
  final int condition;
  final DateTime time;
  final String weatherLevel;

  CurrentWeather.named({
    this.city,
    this.latitude,
    this.longitude,
    this.temperature,
    this.condition,
    this.time,
    this.weatherLevel,
  });

  CurrentWeather(
    this.city,
    this.latitude,
    this.longitude,
    this.temperature,
    this.condition,
    this.time,
    this.weatherLevel,
  );

  CurrentWeather copyWith({
    String city,
    double latitude,
    double longitude,
    double temperature,
    int condition,
    DateTime time,
    String weatherLevel,
  }) {
    return CurrentWeather.named(
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      time: time ?? this.time,
      weatherLevel: weatherLevel ?? this.weatherLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
      'condition': condition,
      'time': time.toIso8601String(),
      'weatherLevel': weatherLevel,
    };
  }

  factory CurrentWeather.fromMap(Map<String, dynamic> map) {
    return CurrentWeather.named(
      city: (map['name'] as String),
      latitude: (map['coord']['lat'] as num)?.toDouble(),
      longitude: (map['coord']['lon'] as num)?.toDouble(),
      temperature: (map['main']['temp'] as num)?.toDouble(),
      condition: (map['weather'][0]['id'] as int) ?? 0,
      time:
          DateTime.tryParse((map['dt_txt'] as String ?? '')) ?? DateTime.now(),
      weatherLevel: (map['weather'][0]['main'] as String) ?? '',
    );
  }

  factory CurrentWeather.fromLocalMap(Map<String, dynamic> map) {
    return CurrentWeather.named(
      city: (map['city'] as String),
      latitude: (map['latitude'] as num)?.toDouble(),
      longitude: (map['longitude'] as num)?.toDouble(),
      temperature: (map['temperature'] as num)?.toDouble(),
      condition: (map['condition'] as int) ?? 0,
      time: DateTime.tryParse((map['time'] as String ?? '')) ?? DateTime.now(),
      weatherLevel: (map['weatherLevel'] as String ?? ''),
    );
  }

  String toJson() => json.encode(toMap());

  factory CurrentWeather.fromJson(String source) =>
      CurrentWeather.fromMap(json.decode(source));


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CurrentWeather &&
        other.city == city &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.temperature == temperature &&
        other.condition == condition &&
        other.time == time &&
        other.weatherLevel == weatherLevel;
  }

  @override
  int get hashCode {
    return city.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        temperature.hashCode ^
        condition.hashCode ^
        time.hashCode ^
        weatherLevel.hashCode;
  }
}
