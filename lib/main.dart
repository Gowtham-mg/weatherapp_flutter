import 'package:clima/bloc/current_weather.dart';
import 'package:clima/bloc/search_weather_by_location.dart';
import 'package:clima/repository/weather.dart';
import 'package:clima/repository/weather_db.dart';
import 'package:clima/repository/weather_offline.dart';
import 'package:clima/screens/current_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final WeatherDB weatherDB = WeatherDB();
  final WeatherOffline weatherOffline = WeatherOffline(weatherDB);
  await weatherDB.openDB();
  final WeatherRepository weatherRepository =
      WeatherRepository(weatherDB, weatherOffline);
  runApp(MyApp(weatherRepository: weatherRepository));
}

class MyApp extends StatelessWidget {
  final WeatherRepository weatherRepository;
  final Location location = Location();

  MyApp({Key key, @required this.weatherRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CurrentWeatherCubit>(
          create: (BuildContext context) =>
              CurrentWeatherCubit(weatherRepository, location),
        ),
        BlocProvider<SearchWeatherCubit>(
          create: (BuildContext context) =>
              SearchWeatherCubit(weatherRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: CurrentLocationScreen(),
      ),
    );
  }
}
