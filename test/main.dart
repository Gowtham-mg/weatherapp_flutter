import 'dart:io';

import 'package:clima/bloc/current_weather.dart';
import 'package:clima/bloc/search_weather_by_location.dart';
import 'package:clima/repository/weather.dart';
import 'package:clima/repository/weather_db.dart';
import 'package:clima/repository/weather_offline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';
import 'package:bloc_test/bloc_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  final WeatherDB weatherDB = WeatherDB();
  final WeatherOffline weatherOffline = WeatherOffline(weatherDB);
  final WeatherRepository weatherRepository =
      WeatherRepository(weatherDB, weatherOffline);
  final Location location = Location();
  await weatherDB.openDB();

  checkWeatherBloc(weatherRepository, location);
}

void checkWeatherBloc(WeatherRepository weatherRepository, Location location) {
  blocTest(
    'Current Location Weather Bloc test passed',
    build: () => CurrentWeatherCubit(weatherRepository, location),
    act: (CurrentWeatherCubit bloc) => bloc.getWeatherByCurrentLocation(),
    verify: (CurrentWeatherCubit bloc) {
      stateExpectation(bloc);
    },
    errors: [],
  );

  blocTest(
    'Search by Cityname Weather Bloc test passed',
    build: () => SearchWeatherCubit(weatherRepository),
    act: (SearchWeatherCubit bloc) => bloc.getWeatherByCityName("Coimbatore"),
    verify: (SearchWeatherCubit bloc) {
      stateExpectation(bloc);
    },
    errors: [],
  );
}

void stateExpectation(bloc) {
  expect(bloc.state.forecastWeatherStatus == BlocStatus.Success, true);
  expect(bloc.state.currentWeatherStatus == BlocStatus.Success, true);

  expect(bloc.state.weather.city, isNotNull);
  expect(bloc.state.weather.condition, isNotNull);
  expect(bloc.state.weather.latitude, isNotNull);
  expect(bloc.state.weather.longitude, isNotNull);
  expect(bloc.state.weather.temperature, isNotNull);
  expect(bloc.state.weather.time, isNotNull);
  expect(bloc.state.weather.weatherLevel, isNotNull);

  final int dataLength = bloc.state.forecast.temperature.length;
  final bool isDataLengthEqual =
      ((bloc.state.forecast.condition.length == dataLength) &&
          (bloc.state.forecast.weatherLevel.length == dataLength) &&
          (bloc.state.forecast.time.length == dataLength));
  expect(isDataLengthEqual, true);
}
