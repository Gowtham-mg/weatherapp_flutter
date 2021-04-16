import 'package:clima/bloc/current_weather.dart';
import 'package:clima/bloc/search_weather_by_location.dart';
import 'package:clima/repository/weather.dart';
import 'package:clima/widgets/current_weather_widget.dart';
import 'package:clima/widgets/status_bar_color_changer.dart';
import 'package:flutter/material.dart';
import 'package:clima/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchCityScreen extends StatefulWidget {
  @override
  _SearchCityScreenState createState() => _SearchCityScreenState();
}

class _SearchCityScreenState extends State<SearchCityScreen> {
  bool showSuggestion = false;
  String cityName = '';
  void search(String city) {
    BlocProvider.of<SearchWeatherCubit>(context).getWeatherByCityName(city);
  }

  @override
  void deactivate() {
    if (mounted) {
      BlocProvider.of<SearchWeatherCubit>(context).reset();
    }
    super.deactivate();
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
        appBar: AppBar(
          title: Text('Search for city', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 25.0,
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      hintText: 'Enter city name',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (String name) {
                      setState(() {
                        cityName = name.trim();
                      });
                    },
                    onTap: () {
                      if (!showSuggestion) {
                        setState(() {
                          showSuggestion = true;
                        });
                      }
                    },
                    onSubmitted: (String val) {
                      search(cityName);
                    },
                  ),
                  Expanded(
                    child: Listener(
                      onPointerUp: (_) {
                        if (showSuggestion) {
                          setState(() {
                            showSuggestion = false;
                          });
                        }
                      },
                      child: RefreshIndicator(
                        onRefresh: () async {
                          search(cityName);
                        },
                        child:
                            BlocBuilder<SearchWeatherCubit, SearchWeatherState>(
                          builder:
                              (BuildContext context, SearchWeatherState state) {
                            if (state.currentWeatherStatus ==
                                BlocStatus.Loading) {
                              return Center(child: CircularProgressIndicator());
                            } else if (state.currentWeatherStatus ==
                                BlocStatus.Success) {
                              return ListView(
                                children: [
                                  CurrentWeatherWidget(
                                    temperature:
                                        '${state.weather.temperature}°C',
                                    weatherIcon:
                                        WeatherRepository.getWeatherIcon(
                                            state.weather.condition),
                                    weatherLevel: state.weather.weatherLevel,
                                    tempFontSize: _width * 0.3,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 30,
                                        bottom: 15,
                                        left: _width * 0.1),
                                    child: Text(
                                      'Forecasted data:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  if (state.forecastWeatherStatus ==
                                      BlocStatus.Success)
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 20),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 0,
                                        crossAxisSpacing: 5,
                                      ),
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
                                                  state.forecast
                                                      .condition[index]),
                                              style: TextStyle(
                                                  fontSize: 30, height: 2),
                                            ),
                                            Text(
                                              state
                                                  .forecast.weatherLevel[index],
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
                                      itemCount:
                                          state.forecast?.temperature?.length ??
                                              0,
                                    )
                                  else if (state.forecastWeatherStatus ==
                                      BlocStatus.Loading)
                                    Center(child: CircularProgressIndicator())
                                  else if (state.forecastWeatherStatus ==
                                      BlocStatus.Error)
                                    Text(state.error)
                                  else
                                    Container()
                                ],
                              );
                            } else if (state.currentWeatherStatus ==
                                BlocStatus.Error) {
                              return Center(child: Text(state.error));
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  // ),
                ],
              ),
              Visibility(
                visible: showSuggestion,
                child: Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.only(
                    top: 60.0,
                    left: _width * 0.05,
                    right: _width * 0.05,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      if (cityName.length != 0)
                        ListTile(
                          tileColor: Colors.white,
                          title: Text(
                            cityName,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            search(cityName);
                            setState(() {
                              showSuggestion = false;
                            });
                          },
                        ),
                      Container(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 10),
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        color: Colors.white,
                        child: Text(
                          'Popular Locations',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ...locations
                          .map((location) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: ListTile(
                                  tileColor: Colors.white,
                                  title: Text(
                                    location,
                                    style: TextStyle(color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                  onTap: () {
                                    final String selectedLocation =
                                        location.split(',').first;
                                    cityName = selectedLocation;
                                    search(selectedLocation);
                                    setState(() {
                                      showSuggestion = false;
                                    });
                                  },
                                ),
                              ))
                          .toList()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
