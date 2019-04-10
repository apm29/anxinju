import 'package:flutter/material.dart';

final ThemeData defaultThemeData = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blueGrey,
  primaryColorBrightness: Brightness.light,
  appBarTheme: AppBarTheme(
    brightness: Brightness.light,
    color: Colors.white,
    elevation: 8,
    iconTheme: IconThemeData(
      color: Colors.blue,
      size: 12
    ),
    actionsIconTheme: IconThemeData(
      color: Colors.blue
    )
  )
);
