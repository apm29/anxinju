import 'package:flutter/material.dart';

final ThemeData defaultThemeData = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  primaryColorBrightness: Brightness.light,
  platform: TargetPlatform.iOS,
  appBarTheme: AppBarTheme(
    brightness: Brightness.light,
    color: Colors.white,
    elevation: 8,
    iconTheme: IconThemeData(color: Colors.blue, size: 12),
    textTheme: TextTheme(
      body1: TextStyle(fontSize: 11, color: Colors.grey),
      body2: TextStyle(fontSize: 11),
      subtitle: TextStyle(
        color: Colors.grey[200],
      ),
    ),
  ),
  iconTheme: IconThemeData(
    color: Colors.blue
  ),
);
