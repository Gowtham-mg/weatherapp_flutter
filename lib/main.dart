import 'package:clima/bloc/current_weather.dart';
import 'package:clima/bloc/search_weather_by_location.dart';
import 'package:clima/repository/weather.dart';
import 'package:clima/screens/current_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final WeatherRepository weatherRepository = WeatherRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider<CurrentWeatherCubit>(
          create: (BuildContext context) =>
              CurrentWeatherCubit(weatherRepository),
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
