import 'package:flutter/material.dart';

class CurrentWeatherWidget extends StatelessWidget {
  final String weatherIcon;
  final String weatherLevel;
  final String temperature;
  final double tempFontSize;

  const CurrentWeatherWidget({
    Key key,
    @required this.weatherIcon,
    @required this.weatherLevel,
    @required this.temperature,
    @required this.tempFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          weatherIcon,
          style: TextStyle(fontSize: tempFontSize),
          textAlign: TextAlign.center,
        ),
        Text(
          weatherLevel,
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w500,
            height: 2,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          temperature,
          style: TextStyle(
            fontSize: 65.0,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
