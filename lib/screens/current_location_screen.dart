import 'package:clima/bloc/current_weather.dart';
import 'package:clima/repository/weather.dart';
import 'package:clima/widgets/app_error_widgets.dart';
import 'package:clima/widgets/current_weather_widget.dart';
import 'package:clima/widgets/status_bar_color_changer.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart';
import 'package:clima/screens/search_city_screen.dart';

class CurrentLocationScreen extends StatefulWidget {
  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  final Location location = Location();
  final Connectivity connectivity = Connectivity();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getCurrentLocation();
      connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
        if (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi) {
          BlocProvider.of<CurrentWeatherCubit>(context).getWeatherIfNeeded();
        }
      });
    });
    super.initState();
  }

  void getCurrentLocation() {
    BlocProvider.of<CurrentWeatherCubit>(context).getWeatherByCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return StatusBarColorChanger(
      androidStatusBarColor: Colors.black,
      androidIconBrightness: Brightness.dark,
      iosStatusBarBrightness: Brightness.dark,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              getCurrentLocation();
            },
            child: BlocBuilder<CurrentWeatherCubit, CurrentWeatherState>(
              builder: (BuildContext context, CurrentWeatherState state) {
                if (state.currentWeatherStatus == BlocStatus.Loading) {
                  return Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 100.0,
                    ),
                  );
                } else if (state.currentWeatherStatus == BlocStatus.Error) {
                  if (state.error == enableLocation) {
                    return Center(
                        child: Row(
                      children: [
                        Text(
                          state.error,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            getCurrentLocation();
                          },
                          child: Text(
                            "Allow",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ));
                  } else {
                    return Center(
                      child: AppErrorWidget(
                        error: state.error,
                        onRetry: () {
                          getCurrentLocation();
                        },
                      ),
                    );
                  }
                } else if (state.currentWeatherStatus == BlocStatus.Success) {
                  return ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: _width * 0.05,
                      vertical: 20,
                    ),
                    children: <Widget>[
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              BlocProvider.of<CurrentWeatherCubit>(context)
                                  .getWeatherByCurrentLocation();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                Text(
                                  '  ${state.weather.city}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SearchCityScreen(
                                      connectivity: connectivity,
                                    );
                                  },
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.location_city,
                              size: 30.0,
                            ),
                          ),
                        ],
                      ),
                      CurrentWeatherWidget(
                        temperature:
                            '${WeatherRepository.convertToCelsius(state.weather.temperature)}??C',
                        weatherIcon: WeatherRepository.getWeatherIcon(
                            state.weather.condition),
                        weatherLevel: state.weather.weatherLevel,
                        tempFontSize: _width * 0.3,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30, bottom: 15),
                        child: Text(
                          'Forecasted data:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        width: _width,
                        child: state.forecastWeatherStatus == BlocStatus.Loading
                            ? Center(child: CircularProgressIndicator())
                            : state.forecastWeatherStatus == BlocStatus.Success
                                ? ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        state.forecast?.temperature?.length ??
                                            0,
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(width: 20);
                                    },
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          Text(
                                            WeatherRepository.getTime(
                                                state.forecast.time[index]),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            WeatherRepository.getWeatherIcon(
                                                state
                                                    .forecast.condition[index]),
                                            style: TextStyle(
                                                fontSize: 30, height: 2),
                                          ),
                                          Text(
                                            state.forecast.weatherLevel[index],
                                            style: TextStyle(
                                              fontSize: 16,
                                              height: 1.25,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            '${WeatherRepository.convertToCelsius(state.forecast.temperature[index])}??C',
                                            style: TextStyle(
                                              fontSize: 16,
                                              height: 1.5,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                : state.forecastWeatherStatus ==
                                        BlocStatus.Error
                                    ? AppErrorWidget(
                                        error: state.error,
                                        onRetry: () {
                                          getCurrentLocation();
                                        },
                                      )
                                    : Container(),
                      )
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
