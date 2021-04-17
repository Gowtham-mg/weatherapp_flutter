import 'package:clima/app_response.dart';
import 'package:clima/models/current_weather.dart';
import 'package:clima/models/forecast_weather.dart';
import 'package:clima/repository/weather_db.dart';
import 'package:location/location.dart';
import 'package:flutter/foundation.dart';

const String noRecentDataAvaiable =
    "No data available, We suggest you to connect to network";

class WeatherOffline {
  final WeatherDB weatherDB;

  WeatherOffline(this.weatherDB);

  //
  // Forecast Weather Data from DB By Location
  //

  Future<AppResponse<ForecastWeather>> getForecastWeatherByLocation(
      LocationData position) async {
    // debugPrint('POSITION getting forecast weather from offline');
    AppResponse<ForecastWeather> forecastWeatherResponse =
        await weatherDB.getForecastWeatherByLocation(position);
    return decodeForecastWeatherResponse(forecastWeatherResponse);
  }

  //
  // Forecast Weather Data from DB By CityName
  //

  Future<AppResponse<ForecastWeather>> getForecastWeatherByCity(
      final String cityName) async {
    AppResponse<ForecastWeather> forecastWeatherResponse =
        await weatherDB.getForecastWeatherByCityName(cityName);
    return decodeForecastWeatherResponse(forecastWeatherResponse);
  }

  //
  // Current Weather Data from DB By CityName
  //

  Future<AppResponse<CurrentWeather>> getCurrentWeatherByCityName(
      String cityName) async {
    AppResponse<CurrentWeather> currentWeatherResp =
        await weatherDB.getCurrentWeatherByCityName(cityName);
    return decodeCurrentWeatherFromCurrentWeatherResponse(
        cityName: cityName, currentWeatherResp: currentWeatherResp);
  }

  //
  // Forecast Weather Data from DB By Location
  //

  Future<AppResponse<CurrentWeather>> getCurrentWeatherByLocation(
      LocationData position) async {
    // debugPrint('POSITION getting current weather from offline');
    AppResponse<CurrentWeather> currentWeatherResp =
        await weatherDB.getCurrentWeatherByLocation(position);
    return decodeCurrentWeatherFromCurrentWeatherResponse(
        position: position, currentWeatherResp: currentWeatherResp);
  }

  AppResponse<ForecastWeather> decodeForecastWeatherResponse(
    AppResponse<ForecastWeather> forecastWeatherResponse,
  ) {
    if (forecastWeatherResponse.isSuccess) {
      ForecastWeather data = forecastWeatherResponse.data;
      int forecastIndex =
          forecastWeatherResponse.data.time.indexWhere((element) {
        final int forecastTimeDiffInSecond =
            element.difference(DateTime.now()).inSeconds;
        if (forecastTimeDiffInSecond < 10800 &&
            forecastTimeDiffInSecond > -10800) {
          return true;
        } else {
          return false;
        }
      });
      if (forecastIndex == -1) {
        return AppResponse.named(error: noRecentDataAvaiable);
      } else {
        return AppResponse.named(
          data: data.copyWith(
            condition: data.condition.sublist(forecastIndex),
            temperature: data.temperature.sublist(forecastIndex),
            weatherLevel: data.weatherLevel.sublist(forecastIndex),
            time: data.time.sublist(forecastIndex),
          ),
        );
      }
    } else {
      return forecastWeatherResponse;
    }
  }

  Future<AppResponse<CurrentWeather>>
      decodeCurrentWeatherFromCurrentWeatherResponse({
    String cityName,
    LocationData position,
    @required AppResponse<CurrentWeather> currentWeatherResp,
  }) async {
    if (currentWeatherResp.isSuccess) {
      CurrentWeather currentWeather = currentWeatherResp.data;
      int timediffInSeconds =
          DateTime.now().difference(currentWeather.time).inSeconds;
      final bool isValidWeatherAvailable =
          (timediffInSeconds < 21600 && timediffInSeconds > -21600);
      if (isValidWeatherAvailable) {
        return currentWeatherResp;
      } else {
        AppResponse<ForecastWeather> forecastWeatherResponse;
        if (position == null) {
          forecastWeatherResponse =
              await weatherDB.getForecastWeatherByCityName(cityName);
        } else {
          forecastWeatherResponse =
              await weatherDB.getForecastWeatherByLocation(position);
        }
        return decodeCurrentWeatherFromForecastResponse(
            forecastWeatherResponse);
      }
    } else {
      return currentWeatherResp;
    }
  }

  AppResponse<CurrentWeather> decodeCurrentWeatherFromForecastResponse(
      final AppResponse<ForecastWeather> forecastWeatherResponse) {
    if (forecastWeatherResponse.isSuccess) {
      int forecastIndex =
          forecastWeatherResponse.data.time.indexWhere((element) {
        final int forecastTimeDiffInSecond =
            element.difference(DateTime.now()).inSeconds;
        if (forecastTimeDiffInSecond < 10800 &&
            forecastTimeDiffInSecond > -10800) {
          return true;
        } else {
          return false;
        }
      });
      if (forecastIndex == -1) {
        return AppResponse.named(error: noRecentDataAvaiable);
      } else {
        return AppResponse.named(
          data: CurrentWeather.named(
            city: forecastWeatherResponse.data.city,
            condition: forecastWeatherResponse.data.condition[forecastIndex],
            latitude: forecastWeatherResponse.data.latitude,
            longitude: forecastWeatherResponse.data.longitude,
            temperature:
                forecastWeatherResponse.data.temperature[forecastIndex],
            time: forecastWeatherResponse.data.time[forecastIndex],
            weatherLevel:
                forecastWeatherResponse.data.weatherLevel[forecastIndex],
          ),
        );
      }
    } else {
      return AppResponse.named(error: noRecentDataAvaiable);
    }
  }
}
