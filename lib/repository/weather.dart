import 'dart:async';
import 'dart:convert';

import 'package:clima/app_response.dart';
import 'package:clima/models/current_weather.dart';
import 'package:clima/models/forecast_weather.dart';
import 'package:clima/repository/weather_db.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';

const String apiKey = '8a615e769eec04422a333dc69171f25b';
const String currentWeather = 'https://api.openweathermap.org/data/2.5/weather';
const String forecastWeather =
    'https://api.openweathermap.org/data/2.5/forecast';
const String noRecentDataAvaiable =
    "No data available, We suggest you to connect to network";

class WeatherRepository {
  final WeatherDB weatherDB;
  final Connectivity connectivity = Connectivity();
  String _networkStatus1 = '';
  bool isActive = false;

  WeatherRepository(this.weatherDB);

  void checkConnectivity() async {
    StreamSubscription<ConnectivityResult> subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      var conn = getConnectionValue(result);
      _networkStatus1 = 'Check $conn Connection:: ';
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        isActive = true;
      } else {
        isActive = false;
      }
    });
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
      if (currentWeatherResp.isSuccess) {
        CurrentWeather currentWeather = currentWeatherResp.data;
        DateTime currentTime = DateTime.now();
        final bool isValidWeatherAvailable =
            currentTime.isBefore(currentWeather.time) &&
                (currentTime.difference(currentWeather.time).inHours < 4);
        if (isValidWeatherAvailable) {
          return currentWeatherResp;
        } else {
          return AppResponse.named(error: noRecentDataAvaiable);
        }
      } else {
        return currentWeatherResp;
      }
    }
  }

  Future<AppResponse<CurrentWeather>> getLocationWeather() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
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
      if (currentWeatherResp.isSuccess) {
        CurrentWeather currentWeather = currentWeatherResp.data;
        DateTime currentTime = DateTime.now();
        final bool isValidWeatherAvailable =
            currentTime.isBefore(currentWeather.time) &&
                (currentTime.difference(currentWeather.time).inHours < 4);
        if (isValidWeatherAvailable) {
          return currentWeatherResp;
        } else {
          return AppResponse.named(error: noRecentDataAvaiable);
        }
      } else {
        return currentWeatherResp;
      }
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
