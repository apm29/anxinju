import 'package:ease_life/ui/home_page.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/remote//dio_net.dart';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:ease_life/ui/interface_test.dart';
import 'package:ease_life/ui/login_page.dart';
import 'package:flutter/material.dart';

void main() async {
  DioApplication.init();
  var spUtil = await SpUtil.getInstance();
  var token = spUtil.getString(PreferenceKeys.keyAuthorization);
  runApp(MyApp(token != null));
}

class MyApp extends StatelessWidget {
  final bool hasLocalToken;

  MyApp(this.hasLocalToken);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        "/": (_) => MyHomePage(),
        "/test": (_) => InterfacePage(),
        "/login": (_) => LoginPage()
      },
    );
  }
}
