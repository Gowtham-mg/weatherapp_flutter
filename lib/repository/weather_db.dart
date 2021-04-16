import 'package:clima/app_response.dart';
import 'package:clima/models/forecast_weather.dart';
import 'package:clima/repository/weather.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:clima/models/current_weather.dart';
import 'package:location/location.dart';

const String currentWeatherTable = "CurrentWeather";
const String forecastWeatherTable = "ForecastWeather";

class WeatherDB {
  Database db;
  Future<String> getPath() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'weather.db');
    return path;
  }

  Future<void> deleteDB() async {
    String path = await getPath();
    await deleteDatabase(path);
  }

  Future<void> openDB() async {
    String path = await getPath();
    db = await openDatabase(path);
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $currentWeatherTable (city TEXT PRIMARY KEY, latitude REAL, longitude REAL, temperature REAL, condition INTEGER, time TEXT, weatherLevel TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $forecastWeatherTable (city TEXT PRIMARY KEY, latitude REAL, longitude REAL, temperature TEXT, condition TEXT, time TEXT, weatherLevel TEXT)');
  }

  //
  // CURRENT Weather
  //

  Future<void> storeCurrentWeatherByCityName(CurrentWeather weather) async {
    List<Map<String, dynamic>> data = await db.query(
      "$currentWeatherTable",
      where: 'city = ?',
      whereArgs: [weather.city],
      columns: [
        'city',
        'latitude',
        'longitude',
        'temperature',
        'condition',
        'time',
        'weatherLevel'
      ],
      limit: 1,
    );
    if (data.length == 0) {
      await db.insert(
        "$currentWeatherTable",
        weather.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.update(
        "$currentWeatherTable",
        weather.toMap(),
        where: "city = ?",
        whereArgs: [weather.city],
      );
    }
  }

  Future<void> storeCurrentWeatherByLocation(CurrentWeather weather) async {
    List<Map<String, dynamic>> data = await db.query(
      "$currentWeatherTable",
      where: 'latitude = ? and longitude = ?',
      whereArgs: [weather.latitude, weather.longitude],
      columns: [
        'city',
        'latitude',
        'longitude',
        'temperature',
        'condition',
        'time',
        'weatherLevel'
      ],
      limit: 1,
    );
    debugPrint("storeCurrentWeatherByLocation $data");
    debugPrint("storeCurrentWeatherByLocation Data ${weather.toMap()}");
    if (data.length == 0) {
      await db.insert(
        "$currentWeatherTable",
        weather.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint("Inserting");
    } else {
      debugPrint("Updating");
      await db.update(
        "$currentWeatherTable",
        weather.toMap(),
        where: 'latitude = ? and longitude = ?',
        whereArgs: [weather.latitude, weather.longitude],
      );
    }
  }

  Future<AppResponse<CurrentWeather>> getCurrentWeatherByCityName(
      final String cityName) async {
    List<Map<String, dynamic>> data = await db.query(
      currentWeatherTable,
      where: "city = ?",
      whereArgs: [cityName],
      columns: [
        'city',
        'latitude',
        'longitude',
        'temperature',
        'condition',
        'time',
        'weatherLevel'
      ],
      limit: 1,
    );
    debugPrint('getCurrentWeatherByCityName Offline $data');
    if (data.length != 0) {
      return AppResponse.named(data: CurrentWeather.fromLocalMap(data.first));
    } else {
      return AppResponse.named(error: 'No data Avaialble');
    }
  }

  Future<AppResponse<CurrentWeather>> getCurrentWeatherByLocation(
      final LocationData position) async {
    List<Map<String, dynamic>> data = await db.query(
      "$currentWeatherTable",
      where: "latitude = ? and longitude = ?",
      whereArgs: [
        position.latitude,
        position.longitude,
      ],
      columns: [
        'city',
        'latitude',
        'longitude',
        'temperature',
        'condition',
        'time',
        'weatherLevel'
      ],
      limit: 1,
    );
    debugPrint('getCurrentWeatherByLocation Offline $data');
    if (data.length != 0) {
      return AppResponse.named(data: CurrentWeather.fromLocalMap(data.first));
    } else {
      return AppResponse.named(error: 'No data Avaialble');
    }
  }

  Future<void> storeForecastWeatherByCityName(ForecastWeather weather) async {
    List<Map<String, dynamic>> data = await db.query(
      "$forecastWeatherTable",
      where: 'city = ?',
      whereArgs: [weather.city],
      columns: [
        'city',
        'latitude',
        'longitude',
        'temperature',
        'condition',
        'time',
        'weatherLevel'
      ],
    );
    if (data.length == 0) {
      await db.insert(
        "$forecastWeatherTable",
        weather.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.update(
        "$forecastWeatherTable",
        weather.toMap(),
        where: "city = ?",
        whereArgs: [weather.city],
      );
    }
  }

  //
  // FORECAST Weather
  //

  Future<void> storeForecastWeatherByLocation(ForecastWeather weather) async {
    List<Map<String, dynamic>> data = await db.query(
      "$forecastWeatherTable",
      where: 'latitude = ? and longitude = ?',
      whereArgs: [weather.latitude, weather.longitude],
      columns: [
        'city',
        'latitude',
        'longitude',
        'temperature',
        'condition',
        'time',
        'weatherLevel'
      ],
    );
    if (data.length == 0) {
      await db.insert(
        "$forecastWeatherTable",
        weather.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.update(
        "$forecastWeatherTable",
        weather.toMap(),
        where: 'latitude = ? and longitude = ?',
        whereArgs: [weather.latitude, weather.longitude],
      );
    }
  }

  Future<AppResponse<ForecastWeather>> getForecastWeatherByCityName(
      final String cityName) async {
    List<Map<String, dynamic>> data = await db.query(
      forecastWeatherTable,
      where: "city = ?",
      whereArgs: [cityName],
      columns: [
        'city',
        'latitude',
        'longitude',
        'temperature',
        'condition',
        'time',
        'weatherLevel'
      ],
    );
    if (data.length != 0) {
      return AppResponse.named(data: ForecastWeather.fromLocalMap(data.first));
    } else {
      return AppResponse.named(error: 'No data Avaialble');
    }
  }

  Future<AppResponse<ForecastWeather>> getForecastWeatherByLocation(
      final LocationData position) async {
    List<Map<String, dynamic>> data = await db.query(
      forecastWeatherTable,
      where: "latitude = ? and longitude = ?",
      whereArgs: [
        position.latitude,
        position.longitude,
      ],
      columns: [
        'city',
        'latitude',
        'longitude',
        'temperature',
        'condition',
        'time',
        'weatherLevel'
      ],
    );
    debugPrint("getForecastWeatherByLocation $data");
    if (data.length != 0) {
      return AppResponse.named(data: ForecastWeather.fromLocalMap(data.first));
    } else {
      return AppResponse.named(error: 'No data Avaialble');
    }
  }
}
