import 'package:clima/app_response.dart';
import 'package:clima/models/current_weather.dart';
import 'package:clima/models/forecast_weather.dart';
import 'package:clima/repository/weather.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location/location.dart';

const String enableLocation = "Enable location permissions to continue";

class CurrentWeatherCubit extends Cubit<CurrentWeatherState> {
  final WeatherRepository weatherRepository;
  final Location location;

  CurrentWeatherCubit(this.weatherRepository, this.location)
      : super(CurrentWeatherState.named(
            currentWeatherStatus: BlocStatus.Initial));

  void getWeatherByCityName(final String cityName) async {
    emit(state.copyWith(
      currentWeatherStatus: BlocStatus.Loading,
      forecastWeatherStatus: BlocStatus.Loading,
    ));
    AppResponse<CurrentWeather> weatherResponse =
        await weatherRepository.getCurrentWeatherByCityName(cityName);
    if (weatherResponse.isError) {
      emit(state.copyWith(
        currentWeatherStatus: BlocStatus.Error,
        error: weatherResponse.error,
      ));
    } else {
      emit(state.copyWith(
        currentWeatherStatus: BlocStatus.Success,
        weather: weatherResponse.data,
      ));
    }

    AppResponse<ForecastWeather> forecastResponse =
        await weatherRepository.getForecastWeatherByCity(cityName);
    if (weatherResponse.isError) {
      emit(state.copyWith(
        forecastWeatherStatus: BlocStatus.Error,
        error: forecastResponse.error,
      ));
    } else {
      emit(state.copyWith(
        forecastWeatherStatus: BlocStatus.Success,
        forecast: forecastResponse.data,
      ));
    }
  }

  void getWeatherByCurrentLocation() async {
    emit(state.copyWith(
      currentWeatherStatus: BlocStatus.Loading,
      forecastWeatherStatus: BlocStatus.Loading,
    ));
    // PermissionStatus hasPermission = await location.hasPermission();
    PermissionStatus status = await location.requestPermission();
    if (status == PermissionStatus.granted) {
      LocationData position = await location.getLocation();

      AppResponse<CurrentWeather> weatherResponse =
          await weatherRepository.getCurrentWeatherByLocation(position);
      if (weatherResponse.isError) {
        emit(state.copyWith(
          currentWeatherStatus: BlocStatus.Error,
          error: weatherResponse.error,
        ));
      } else {
        emit(state.copyWith(
          currentWeatherStatus: BlocStatus.Success,
          weather: weatherResponse.data,
        ));
      }

      AppResponse<ForecastWeather> forecastResponse =
          await weatherRepository.getForecastWeatherByLocation(position);
      if (weatherResponse.isError) {
        emit(state.copyWith(
          forecastWeatherStatus: BlocStatus.Error,
          error: forecastResponse.error,
        ));
      } else {
        emit(state.copyWith(
          forecastWeatherStatus: BlocStatus.Success,
          forecast: forecastResponse.data,
        ));
      }
    } else {
      emit(CurrentWeatherState.named(
        currentWeatherStatus: BlocStatus.Error,
        error: enableLocation,
        forecastWeatherStatus: BlocStatus.Initial,
      ));
    }
  }
}

class CurrentWeatherState extends Equatable {
  final BlocStatus currentWeatherStatus;
  final CurrentWeather weather;
  final String cityName;
  final String error;
  final ForecastWeather forecast;
  final BlocStatus forecastWeatherStatus;

  CurrentWeatherState(
    this.currentWeatherStatus,
    this.weather,
    this.cityName,
    this.error,
    this.forecast,
    this.forecastWeatherStatus,
  );

  CurrentWeatherState.named({
    this.currentWeatherStatus,
    this.weather,
    this.cityName,
    this.error,
    this.forecast,
    this.forecastWeatherStatus,
  });

  CurrentWeatherState copyWith({
    BlocStatus currentWeatherStatus,
    CurrentWeather weather,
    String cityName,
    String error,
    ForecastWeather forecast,
    BlocStatus forecastWeatherStatus,
  }) {
    return CurrentWeatherState.named(
      currentWeatherStatus: currentWeatherStatus ?? this.currentWeatherStatus,
      weather: weather ?? this.weather,
      cityName: cityName ?? this.cityName,
      error: error ?? this.error,
      forecast: forecast ?? this.forecast,
      forecastWeatherStatus:
          forecastWeatherStatus ?? this.forecastWeatherStatus,
    );
  }

  @override
  List<Object> get props => [
        this.cityName,
        this.error,
        this.currentWeatherStatus,
        this.weather,
        this.forecast,
        this.forecastWeatherStatus,
      ];
}

enum BlocStatus {
  Initial,
  Loading,
  Success,
  Error,
}
