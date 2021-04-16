import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final Function onRetry;
  final String error;

  const AppErrorWidget({Key key, @required this.error, @required this.onRetry})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          error,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        IconButton(
          onPressed: onRetry,
          icon: Icon(Icons.refresh),
        )
      ],
    );
  }
}
