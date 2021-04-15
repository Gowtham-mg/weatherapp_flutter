import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBarColorChanger extends StatelessWidget {
  final Widget child;
  final Color androidStatusBarColor;
  final Brightness androidIconBrightness;
  final Brightness iosStatusBarBrightness;

  const StatusBarColorChanger({
    Key key,
    @required this.child,
    this.androidStatusBarColor,
    this.androidIconBrightness,
    this.iosStatusBarBrightness,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      child: child,
      value: SystemUiOverlayStyle(
        statusBarColor: androidStatusBarColor,
        statusBarIconBrightness: androidIconBrightness,
        statusBarBrightness: iosStatusBarBrightness,
      ),
    );
  }
}
