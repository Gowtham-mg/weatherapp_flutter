import 'dart:async';
import 'dart:convert';

import 'package:clima/app_response.dart';
import 'package:clima/models/current_weather.dart';
import 'package:clima/models/forecast_weather.dart';
import 'package:clima/repository/weather_db.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:connectivity/connectivity.dart';

const String apiKey = '8a615e769eec04422a333dc69171f25b';
const String currentWeather = 'https://api.openweathermap.org/data/2.5/weather';
const String forecastWeather =
    'https://api.openweathermap.org/data/2.5/forecast';
const String noRecentDataAvaiable =
    "No data available, We suggest you to connect to network";

class WeatherRepository {
  final WeatherDB weatherDB;
  final Connectivity connectivity;
  String _networkStatus1 = '';
  bool isActive = false;

  WeatherRepository(this.weatherDB, this.connectivity);

  void checkConnectivity() async {
    // ConnectivityResult connectivityResult =
    //     await connectivity.checkConnectivity();
    // setConnectivityStatus(connectivityResult);
    // connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
    //   var conn = getConnectionValue(result);
    //   setConnectivityStatus(result);
    //   _networkStatus1 = 'Check $conn Connection:: ';
    // });
  }

  void setConnectivityStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      isActive = true;
    } else {
      isActive = false;
    }
  }

  String getConnectionValue(var connectivityResult) {
    switch (connectivityResult) {
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.none:
        return 'Internet';
      default:
        return 'Internet';
    }
  }

  Future<AppResponse<ForecastWeather>> getLocationForecastWeather(
      LocationData position) async {
    if (isActive) {
      var forecastWeatherNetworkResponse = await http.get(
          '$forecastWeather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey');
      AppResponse<ForecastWeather> forecastWeatherResponse =
          decodeForecastWeatherResponse(forecastWeatherNetworkResponse);
      if (forecastWeatherResponse.isSuccess) {
        await weatherDB
            .storeForecastWeatherByLocation(forecastWeatherResponse.data);
      }
      return forecastWeatherResponse;
    } else {
      AppResponse<ForecastWeather> forecastWeatherResponse =
          await weatherDB.getForecastWeatherByLocation(position);
      return getForecastWeatherOffline(forecastWeatherResponse);
    }
  }

  Future<AppResponse<ForecastWeather>> getForecastWeatherByCity(
      final String cityName) async {
    if (isActive) {
      var forecastWeatherNetworkResponse =
          await http.get('$forecastWeather?q=$cityName&appid=$apiKey');
      AppResponse<ForecastWeather> forecastWeatherResponse =
          decodeForecastWeatherResponse(forecastWeatherNetworkResponse);
      if (forecastWeatherResponse.isSuccess) {
        await weatherDB
            .storeForecastWeatherByCityName(forecastWeatherResponse.data);
      }
      return forecastWeatherResponse;
    } else {
      AppResponse<ForecastWeather> forecastWeatherResponse =
          await weatherDB.getForecastWeatherByCityName(cityName);
      return getForecastWeatherOffline(forecastWeatherResponse);
    }
  }

  AppResponse<ForecastWeather> getForecastWeatherOffline(
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

  Future<AppResponse<CurrentWeather>> getCurrentWeatherOffline(
      {String cityName,
      LocationData position,
      @required AppResponse<CurrentWeather> currentWeatherResp}) async {
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
        return getCurrentWeatherFromForecastResponse(forecastWeatherResponse);
      }
    } else {
      return currentWeatherResp;
    }
  }

  Future<AppResponse<CurrentWeather>> getCityCurrentWeather(
      String cityName) async {
    if (isActive) {
      var response =
          await http.get('$currentWeather?q=$cityName&appid=$apiKey');
      AppResponse<CurrentWeather> currentWeatherResponse =
          decodeWeatherResponse(response);
      if (currentWeatherResponse.isSuccess) {
        await weatherDB
            .storeCurrentWeatherByCityName(currentWeatherResponse.data);
      }
      return currentWeatherResponse;
    } else {
      AppResponse<CurrentWeather> currentWeatherResp =
          await weatherDB.getCurrentWeatherByCityName(cityName);
      return getCurrentWeatherOffline(
          cityName: cityName, currentWeatherResp: currentWeatherResp);
    }
  }

  AppResponse<CurrentWeather> getCurrentWeatherFromForecastResponse(
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

  Future<AppResponse<CurrentWeather>> getLocationWeather(
      LocationData position) async {
    print('${position.latitude} ${position.longitude}');
    if (isActive) {
      var response = await http.get(
          '$currentWeather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey');
      AppResponse<CurrentWeather> currentWeatherResponse =
          decodeWeatherResponse(response);
      if (currentWeatherResponse.isSuccess) {
        await weatherDB
            .storeCurrentWeatherByLocation(currentWeatherResponse.data);
      }
      return currentWeatherResponse;
    } else {
      AppResponse<CurrentWeather> currentWeatherResp =
          await weatherDB.getCurrentWeatherByLocation(position);
      return getCurrentWeatherOffline(
          position: position, currentWeatherResp: currentWeatherResp);
    }
  }

  AppResponse<CurrentWeather> decodeWeatherResponse(http.Response response) {
    final decodedData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      CurrentWeather weather =
          CurrentWeather.fromMap(decodedData as Map<String, dynamic>);
      return AppResponse.named(data: weather);
    } else {
      return AppResponse.named(error: decodedData['message'].toString());
    }
  }

  AppResponse<ForecastWeather> decodeForecastWeatherResponse(
      http.Response response) {
    final Map<String, dynamic> decodedData =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return AppResponse.named(data: ForecastWeather.fromMap(decodedData));
    } else {
      return AppResponse.named(error: decodedData['message'].toString());
    }
  }

  static String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  static String getMessage(double temp) {
    if (temp > 25.0) {
      return 'It\'s 🍦 time';
    } else if (temp > 20.0) {
      return 'Time for shorts and 👕';
    } else if (temp < 10.0) {
      return 'You\'ll need 🧣 and 🧤';
    } else {
      return 'Bring a 🧥 just in case';
    }
  }

  static String getTime(DateTime date) {
    return '${convertTwoDigitString(date.day)}-${getMonthAsString(date.month)}-${date.year}\n${convertTwoDigitString(date.hour)}:${convertTwoDigitString(date.minute)} ${date.hour < 12 ? 'am' : 'pm'}';
  }

  static String getMonthAsString(int month) {
    return months[month - 1].substring(0, 3);
  }

  static String convertTwoDigitString(int val) {
    if (val < 10) {
      return '0$val';
    } else {
      return val.toString();
    }
  }

  static const List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
}
