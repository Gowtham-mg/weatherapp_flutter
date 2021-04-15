import 'dart:convert';

import 'package:clima/app_response.dart';
import 'package:clima/models/current_weather.dart';
import 'package:clima/models/forecast_weather.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

const String apiKey = '8a615e769eec04422a333dc69171f25b';
const String currentWeather = 'https://api.openweathermap.org/data/2.5/weather';
const String forecastWeather =
    'https://api.openweathermap.org/data/2.5/forecast';

class WeatherRepository {
  Future<AppResponse<CurrentWeather>> getCityCurrentWeather(
      String cityName) async {
    var response = await http.get('$currentWeather?q=$cityName&appid=$apiKey');
    AppResponse<CurrentWeather> currentWeatherResponse =
        decodeWeatherResponse(response);
    // if (currentWeatherResponse.isSuccess) {
    //   weatherBox.add(currentWeatherResponse.data);
    // }
    return currentWeatherResponse;
  }

  Future<AppResponse<CurrentWeather>> getLocationWeather() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    var currentWeatherResponse = await http.get(
        '$currentWeather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey');
    return decodeWeatherResponse(currentWeatherResponse);
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

  Future<AppResponse<ForecastWeather>> getLocationForecastWeather() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    var forecastWeatherResponse = await http.get(
        '$forecastWeather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey');
    return decodeForecastWeatherResponse(forecastWeatherResponse);
  }

  Future<AppResponse<ForecastWeather>> getForecastWeatherByCity(
      final String cityName) async {
    var forecastWeatherResponse =
        await http.get('$forecastWeather?q=$cityName&appid=$apiKey');
    return decodeForecastWeatherResponse(forecastWeatherResponse);
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
