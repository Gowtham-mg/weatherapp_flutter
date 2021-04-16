import 'package:clima/app_response.dart';
import 'package:clima/models/current_weather.dart';
import 'package:clima/repository/weather.dart';
import 'package:clima/repository/weather_db.dart';
import 'package:connectivity/connectivity.dart';
import 'package:test/test.dart';

void main() {
  // group('Weather network', () {
  final WeatherDB weatherDB = WeatherDB();
  final Connectivity connectivity = Connectivity();
  WeatherRepository weatherRepository =
      WeatherRepository(weatherDB, connectivity);

  test(
      'Weather data is fetched by cityname from network and parsed, its not equal to null',
      () async {
    await weatherDB.openDB();
    await weatherRepository.checkConnectivity();
    final AppResponse<CurrentWeather> currentWeather =
        await weatherRepository.getCityCurrentWeather("Coimbatore");
    expect(currentWeather.isSuccess, true);
    expect(currentWeather.data.city, isNotNull);
    expect(currentWeather.data.condition, isNotNull);
    expect(currentWeather.data.latitude, isNotNull);
    expect(currentWeather.data.longitude, isNotNull);
    expect(currentWeather.data.temperature, isNotNull);
    expect(currentWeather.data.time, isNotNull);
    expect(currentWeather.data.weatherLevel, isNotNull);
  });

  // test(
  //     'Weather data is fetched by Current Location from network and parsed, its not equal to null',
  //     () async {
  //   final AppResponse<CurrentWeather> currentWeather =
  //       await weatherRepository.getLocationWeather();
  //   expect(currentWeather.isSuccess, true);
  //   expect(currentWeather.data.city, isNotNull);
  //   expect(currentWeather.data.condition, isNotNull);
  //   expect(currentWeather.data.latitude, isNotNull);
  //   expect(currentWeather.data.longitude, isNotNull);
  //   expect(currentWeather.data.temperature, isNotNull);
  //   expect(currentWeather.data.time, isNotNull);
  //   expect(currentWeather.data.weatherLevel, isNotNull);
  // });

  // test(
  //     'Forecast Current loction Weather data is fetched from network and parsed, its not equal to null',
  //     () async {
  //   final AppResponse<ForecastWeather> forecastWeather =
  //       await weatherRepository.getLocationForecastWeather();
  //   expect(forecastWeather.isSuccess, true);
  //   expect(forecastWeather.data.city, isNotNull);
  //   expect(forecastWeather.data.condition, isNotNull);
  //   expect(forecastWeather.data.latitude, isNotNull);
  //   expect(forecastWeather.data.longitude, isNotNull);
  //   expect(forecastWeather.data.temperature, isNotNull);
  //   expect(forecastWeather.data.time, isNotNull);
  //   expect(forecastWeather.data.weatherLevel, isNotNull);
  //   final int dataLength = forecastWeather.data.temperature.length;
  //   final bool isDataLengthEqual =
  //       ((forecastWeather.data.condition.length == dataLength) &&
  //           (forecastWeather.data.weatherLevel.length == dataLength) &&
  //           (forecastWeather.data.time.length == dataLength));
  //   expect(isDataLengthEqual, true);
  // });

  // test(
  //     'Forecast Weather data by city name is fetched from network and parsed, its not equal to null',
  //     () async {
  //   final AppResponse<ForecastWeather> forecastWeather =
  //       await weatherRepository.getLocationForecastWeather();
  //   expect(forecastWeather.isSuccess, true);
  //   expect(forecastWeather.data.city, isNotNull);
  //   expect(forecastWeather.data.condition, isNotNull);
  //   expect(forecastWeather.data.latitude, isNotNull);
  //   expect(forecastWeather.data.longitude, isNotNull);
  //   expect(forecastWeather.data.temperature, isNotNull);
  //   expect(forecastWeather.data.time, isNotNull);
  //   expect(forecastWeather.data.weatherLevel, isNotNull);
  //   final int dataLength = forecastWeather.data.temperature.length;
  //   final bool isDataLengthEqual =
  //       ((forecastWeather.data.condition.length == dataLength) &&
  //           (forecastWeather.data.weatherLevel.length == dataLength) &&
  //           (forecastWeather.data.time.length == dataLength));
  //   expect(isDataLengthEqual, true);
  // });
  // });
}
