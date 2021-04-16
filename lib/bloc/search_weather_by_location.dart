import 'package:clima/app_response.dart';
import 'package:clima/bloc/current_weather.dart';
import 'package:clima/models/current_weather.dart';
import 'package:clima/models/forecast_weather.dart';
import 'package:clima/repository/weather.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchWeatherCubit extends Cubit<SearchWeatherState> {
  final WeatherRepository weatherRepository;

  SearchWeatherCubit(this.weatherRepository)
      : super(
            SearchWeatherState.named(currentWeatherStatus: BlocStatus.Initial));

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

  void reset() {
    emit(SearchWeatherState.named(
      forecastWeatherStatus: BlocStatus.Initial,
      currentWeatherStatus: BlocStatus.Initial,
    ));
  }
}

class SearchWeatherState extends Equatable {
  final BlocStatus currentWeatherStatus;
  final CurrentWeather weather;
  final String cityName;
  final String error;
  final ForecastWeather forecast;
  final BlocStatus forecastWeatherStatus;

  SearchWeatherState(
    this.currentWeatherStatus,
    this.weather,
    this.cityName,
    this.error,
    this.forecast,
    this.forecastWeatherStatus,
  );

  SearchWeatherState.named({
    this.currentWeatherStatus,
    this.weather,
    this.cityName,
    this.error,
    this.forecast,
    this.forecastWeatherStatus,
  });

  SearchWeatherState copyWith({
    BlocStatus currentWeatherStatus,
    CurrentWeather weather,
    String cityName,
    String error,
    ForecastWeather forecast,
    BlocStatus forecastWeatherStatus,
  }) {
    return SearchWeatherState.named(
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
