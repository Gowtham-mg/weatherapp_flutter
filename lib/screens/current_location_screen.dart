import 'package:clima/bloc/current_weather.dart';
import 'package:clima/repository/weather.dart';
import 'package:clima/constants.dart';
import 'package:clima/widgets/status_bar_color_changer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'search_city_screen.dart';

class CurrentLocationScreen extends StatefulWidget {
  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getCurrentLocation();
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
                return RefreshIndicator(
                  child: Center(child: Text(state.error)),
                  onRefresh: getCurrentLocation,
                );
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
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return SearchCityScreen();
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
                    Text(
                      WeatherRepository.getWeatherIcon(state.weather.condition),
                      style: TextStyle(fontSize: _width * 0.3),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      state.weather.weatherLevel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        height: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${state.weather.temperature}°',
                      style: TextStyle(
                        fontSize: 65.0,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      height: 150,
                      child: state.forecastWeatherStatus == BlocStatus.Loading
                          ? Center(child: CircularProgressIndicator())
                          : state.forecastWeatherStatus == BlocStatus.Success
                              ? ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.forecast.temperature.length,
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
                                              state.forecast.condition[index]),
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
                                          '${state.forecast.temperature[index]}°',
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
                              : state.forecastWeatherStatus == BlocStatus.Error
                                  ? Text(state.error)
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
    );
  }
}
