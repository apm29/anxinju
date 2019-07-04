import 'package:flutter/foundation.dart';
import 'package:ai_life/persistence/const.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppThemeModel extends ChangeNotifier {
  List<ThemeData> _appCurrentTheme = [
    ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: "Weiruanyahei",
      iconTheme: IconThemeData(
        color: Colors.purple,
        size: 24,
      ),
      accentColor: Colors.blueAccent,
      primaryColor: Colors.blue,
      platform: TargetPlatform.iOS,
      colorScheme: ColorScheme(
        primary: Colors.purple,
        primaryVariant: Colors.blueAccent,
        secondary: Colors.blue,
        secondaryVariant: Colors.deepPurpleAccent,
        surface: Colors.white,
        background: Colors.grey[300],
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.blueGrey[600],
        onBackground: Colors.blueGrey[700],
        onError: Colors.grey[200],
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(
        body1: TextStyle(
          color: Colors.blueGrey[800],
        ),
        body2: TextStyle(
          color: Colors.blueGrey[600],
        ),
        headline: TextStyle(
          color: Colors.black,
        ),
        title: TextStyle(
          color: Colors.blue,
        ),
        subtitle: TextStyle(
          color: Colors.blueGrey[900],
        ),
        subhead: TextStyle(
          color: Colors.blueGrey[700],
        ),
        caption: TextStyle(
          color: Colors.grey[500],
        ),
        button: TextStyle(
          color: Colors.purple[600],
        ),
        overline: TextStyle(
          color: Colors.purple[700],
        ),
        display1: TextStyle(
          color: Colors.blueGrey[200],
        ),
        display2: TextStyle(
          color: Colors.blueGrey[300],
        ),
        display3: TextStyle(
          color: Colors.blueGrey[400],
        ),
        display4: TextStyle(
          color: Colors.blueGrey[600],
        ),
      ),
    ),
    ThemeData(
      primarySwatch: Colors.purple,
      fontFamily: "Determination",
      iconTheme: IconThemeData(
        color: Colors.blue,
        size: 24,
      ),
      platform: TargetPlatform.iOS,
      accentColor: Colors.purple,
    ),
    ThemeData(
      primarySwatch: Colors.teal,
      fontFamily: "Determination",
      iconTheme: IconThemeData(
        color: Colors.blue,
        size: 24,
      ),
      platform: TargetPlatform.iOS,
      accentColor: Colors.blueAccent,
    ),
  ];
  int _currentThemeIndex = 0;

  int get currentThemeIndex => _currentThemeIndex;

  set currentThemeIndex(int newValue) {
    if (_currentThemeIndex == newValue) {
      return;
    }
    _currentThemeIndex = newValue;
    sp.setInt(KEY_CURRENT_THEME_INDEX, _currentThemeIndex);
    notifyListeners();
  }

  ThemeData get appTheme => _appCurrentTheme[currentThemeIndex];

  void changeTheme() {
    if (currentThemeIndex == 0) {
      currentThemeIndex = 1;
    } else if (currentThemeIndex == 1) {
      currentThemeIndex = 2;
    } else {
      currentThemeIndex = 0;
    }
  }

  AppThemeModel() {
    int index = sp.getInt(KEY_CURRENT_THEME_INDEX) ?? 0;
    currentThemeIndex = index;
  }

  static AppThemeModel of(BuildContext context) {
    return Provider.of<AppThemeModel>(context, listen: false);
  }
}
