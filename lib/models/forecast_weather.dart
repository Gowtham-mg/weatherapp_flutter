import 'dart:convert';

class ForecastWeather {
  final String city;
  final double latitude;
  final double longitude;
  final List<double> temperature;
  final List<int> condition;
  final List<DateTime> time;
  final List<String> weatherLevel;

  ForecastWeather.named({
    this.city,
    this.latitude,
    this.longitude,
    this.temperature,
    this.condition,
    this.time,
    this.weatherLevel,
  });

  ForecastWeather(
    this.city,
    this.latitude,
    this.longitude,
    this.temperature,
    this.condition,
    this.time,
    this.weatherLevel,
  );

  ForecastWeather copyWith({
    String city,
    double latitude,
    double longitude,
    List<double> temperature,
    List<int> condition,
    List<DateTime> time,
    List<String> weatherLevel,
  }) {
    return ForecastWeather.named(
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
      'time': time.map((e) => e.toIso8601String()).toList(),
      'weatherLevel': weatherLevel,
    };
  }

  factory ForecastWeather.fromMap(Map<String, dynamic> map) {
    return ForecastWeather.named(
      city: (map['city']['name'] as String),
      latitude: (map['city']['coord']['lat'] as num)?.toDouble(),
      longitude: (map['city']['coord']['lon'] as num)?.toDouble(),
      temperature: (map['list']
          .map<double>((val) => (val['main']['temp'] as num)?.toDouble())
          .toList()),
      condition: (map['list']
          .map<int>((val) => (val['weather'][0]['id'] as int) ?? 0)
          .toList()),
      time: (map['list']
          .map<DateTime>((val) =>
              DateTime.tryParse((val['dt_txt'] as String ?? '')) ??
              DateTime.now())
          .toList()),
      weatherLevel: (map['list']
          .map<String>((val) => (val['weather'][0]['main'] as String))
          .toList() as List<String>),
    );
  }

  factory ForecastWeather.fromLocalMap(Map<String, dynamic> map) {
    return ForecastWeather.named(
      city: (map['city'] as String),
      latitude: (map['latitude'] as num)?.toDouble(),
      longitude: (map['longitude'] as num)?.toDouble(),
      temperature: (map['temperature']
          .map<double>((val) => (val as num)?.toDouble())
          .toList()),
      condition:
          (map['condition'].map<int>((val) => (val as int) ?? 0).toList()),
      time: (map['time']
          .map<DateTime>((val) =>
              DateTime.tryParse((val as String ?? '')) ?? DateTime.now())
          .toList()),
      weatherLevel: (map['weatherLevel']
          .map<String>((val) => (val as String))
          .toList() as List<String>),
    );
  }

  String toJson() => json.encode(toMap());

  factory ForecastWeather.fromJson(String source) =>
      ForecastWeather.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Weather(city: $city, latitude: $latitude, longitude: $longitude, temperature: $temperature)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ForecastWeather &&
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
