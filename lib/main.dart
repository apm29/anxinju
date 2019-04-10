import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/ui/authorization_page.dart';
import 'package:ease_life/ui/home_page.dart';
import 'package:ease_life/remote//dio_net.dart';
import 'package:ease_life/ui/interface_test.dart';
import 'package:ease_life/ui/login_page.dart';
import 'package:ease_life/ui/personal_info_page.dart';
import 'package:ease_life/ui/style.dart';
import 'package:flutter/material.dart';


void main() async {
  DioApplication.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      child: MaterialApp(
        theme: defaultThemeData,
        routes: {
          "/": (_) => MyHomePage(),
          "/test": (_) => InterfacePage(),
          "/login": (_) => LoginPage(),
          "/personal": (_) => PersonalInfoPage(),
          "/verify": (_) => AuthorizationPage(),
        },
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
    BlocProvider.of(context).dispose();
  }
}
