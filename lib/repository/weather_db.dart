import 'package:clima/app_response.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:clima/models/current_weather.dart';

const String currentWeatherTable = "CurrentWeather";

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
        'CREATE TABLE $currentWeatherTable (city TEXT PRIMARY KEY, latitude REAL, longitude REAL, temperature REAL, condition INTEGER, time TEXT, weatherLevel TEXT)');
  }

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
      await db.insert("$currentWeatherTable", weather.toMap());
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
      where: 'latitude = ?, longitude = ?',
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
    if (data.length == 0) {
      await db.insert("$currentWeatherTable", weather.toMap());
    } else {
      await db.update(
        "$currentWeatherTable",
        weather.toMap(),
        where: "city = ?",
        whereArgs: [weather.city],
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
    if (data.length != 0) {
      return AppResponse.named(data: CurrentWeather.fromLocalMap(data.first));
    } else {
      return AppResponse.named(error: 'No data Avaialble');
    }
  }

  Future<AppResponse<CurrentWeather>> getCurrentWeatherByLocation(
      final Position position) async {
    List<Map<String, dynamic>> data = await db.query(
      currentWeatherTable,
      where: "latitude = ?, longitude = ?",
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
    if (data.length != 0) {
      return AppResponse.named(data: CurrentWeather.fromLocalMap(data.first));
    } else {
      return AppResponse.named(error: 'No data Avaialble');
    }
  }
}
