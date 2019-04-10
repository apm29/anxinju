import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/bloc/user_bloc.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/ui/authorization_page.dart';
import 'package:ease_life/ui/home_page.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/remote//dio_net.dart';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:ease_life/ui/interface_test.dart';
import 'package:ease_life/ui/login_page.dart';
import 'package:ease_life/ui/personal_info_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  DioApplication.init();
  try {
    var sp = await SharedPreferences.getInstance();
    var userInfoString = sp.getString(PreferenceKeys.keyUserInfo);
    Map userInfoMap = json.decode(userInfoString);
    var userInfoData = UserInfoData.fromJson(userInfoMap);
    UserBloc.userInfoData = userInfoData;
  } catch (e) {
    print(e);
  }
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
        theme: ThemeData(primarySwatch: Colors.red),
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
