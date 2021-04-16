import 'dart:async';
import 'dart:convert';

import 'package:clima/app_response.dart';
import 'package:clima/models/current_weather.dart';
import 'package:clima/models/forecast_weather.dart';
import 'package:clima/repository/weather_db.dart';
import 'package:clima/repository/weather_offline.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

const String apiKey = '8a615e769eec04422a333dc69171f25b';
const String currentWeather = 'https://api.openweathermap.org/data/2.5/weather';
const String forecastWeather =
    'https://api.openweathermap.org/data/2.5/forecast';
const List<String> months = [
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

const Map<String, String> connectivityMsg = {
  "message": "Please check your Internet connection"
};

class WeatherRepository {
  final WeatherDB weatherDB;
  final WeatherOffline weatherOffline;
  WeatherRepository(this.weatherDB, this.weatherOffline);

  Future<AppResponse<ForecastWeather>> getForecastWeatherByLocation(
      LocationData position) async {
    try {
      debugPrint("getForecastWeatherByLocation");
      http.Response forecastWeatherNetworkResponse = await http
          .get(
              '$forecastWeather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey')
          .timeout(
            Duration(seconds: 5),
            onTimeout: onTimeOut,
          );
      AppResponse<ForecastWeather> forecastWeatherResponse =
          decodeForecastWeatherResponse(forecastWeatherNetworkResponse);
      debugPrint(
          "POSITION forecastWeatherResponse.isSuccess ${forecastWeatherResponse.isSuccess}");
      if (forecastWeatherResponse.isSuccess) {
        await weatherDB
            .storeForecastWeatherByLocation(forecastWeatherResponse.data);
      }
      return forecastWeatherResponse;
    } catch (e) {
      return weatherOffline.getForecastWeatherByLocation(position);
    }
  }

  Future<AppResponse<ForecastWeather>> getForecastWeatherByCity(
      final String cityName) async {
    try {
      http.Response forecastWeatherNetworkResponse = await http
          .get('$forecastWeather?q=$cityName&appid=$apiKey')
          .timeout(Duration(seconds: 5), onTimeout: onTimeOut);
      // if (forecastWeatherNetworkResponse.statusCode != 101) {
      AppResponse<ForecastWeather> forecastWeatherResponse =
          decodeForecastWeatherResponse(forecastWeatherNetworkResponse);
      if (forecastWeatherResponse.isSuccess) {
        debugPrint('POSITION storing forecast weather from online');
        await weatherDB
            .storeForecastWeatherByCityName(forecastWeatherResponse.data);
      }
      return forecastWeatherResponse;
    } catch (e) {
      return weatherOffline.getForecastWeatherByCity(cityName);
    }
  }

  Future<AppResponse<CurrentWeather>> getCurrentWeatherByCityName(
      String cityName) async {
    try {
      http.Response response = await http
          .get('$currentWeather?q=$cityName&appid=$apiKey')
          .timeout(Duration(seconds: 5), onTimeout: onTimeOut);
      AppResponse<CurrentWeather> currentWeatherResponse =
          decodeCurrentWeatherResponse(response);
      if (currentWeatherResponse.isSuccess) {
        await weatherDB
            .storeCurrentWeatherByCityName(currentWeatherResponse.data);
      }
      return currentWeatherResponse;
    } catch (e) {
      return weatherOffline.getCurrentWeatherByCityName(cityName);
    }
  }

  Future<AppResponse<CurrentWeather>> getCurrentWeatherByLocation(
      LocationData position) async {
    debugPrint('POSITION ${position.latitude} ${position.longitude}');
    try {
      http.Response response = await http
          .get(
              '$currentWeather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey')
          .timeout(Duration(seconds: 5), onTimeout: onTimeOut);
      AppResponse<CurrentWeather> currentWeatherResponse =
          decodeCurrentWeatherResponse(response);
      debugPrint(
          "POSITION currentWeatherResponse.isSuccess ${currentWeatherResponse.isSuccess}");
      if (currentWeatherResponse.isSuccess) {
        debugPrint('POSITION storing current weather from online');
        await weatherDB
            .storeCurrentWeatherByLocation(currentWeatherResponse.data);
      }
      return currentWeatherResponse;
    } catch (e) {
      return weatherOffline.getCurrentWeatherByLocation(position);
    }
  }

  AppResponse<CurrentWeather> decodeCurrentWeatherResponse(
      http.Response response) {
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

  Future<http.Response> onTimeOut() async {
    return http.Response(jsonEncode(connectivityMsg), 101);
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

  static double convertToCelsius(double temperatureInKelvin) {
    return temperatureInKelvin - 273.15;
  }
}
