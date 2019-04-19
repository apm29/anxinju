import 'dart:io';

import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/ui/audio_record_page.dart';
import 'package:ease_life/ui/authorization_page.dart';
import 'package:ease_life/ui/camera_page.dart';
import 'package:ease_life/ui/contacts_select_page.dart';
import 'package:ease_life/ui/main_page.dart';
import 'package:ease_life/ui/login_page.dart';
import 'package:ease_life/ui/map_locate_page.dart';
import 'package:ease_life/ui/personal_info_page.dart';
import 'package:ease_life/ui/register_page.dart';
import 'package:ease_life/ui/splash_page.dart';
import 'package:ease_life/ui/style.dart';
import 'package:ease_life/ui/test_page.dart';
import 'package:ease_life/ui/web_view_example.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amap_base/amap_base.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

SharedPreferences sharedPreferences;
List<CameraDescription> cameras;

void main() async{
//  FlutterBugly.postCatchedException(() async {
    //sp初始化
    sharedPreferences = await SharedPreferences.getInstance();
    await AMap.init("d712d41f19e76ca74b673f9d5637af8a");
    cameras = await availableCameras();
    sharedPreferences.setString(PreferenceKeys.keyAuthorization,
        "eyJhbGciOiJIUzI1NiJ9.eyJhbnhpbmp1IjoiMTU1NDcxMjE2MDQ2MTkwMTYyNDIiLCJjcmVhdGVkIjoxNTU0ODkwODk4MzIwLCJleHAiOjE5ODY4OTA4OTh9.VYwQw-3io7XxgQHvtuKrB7RyVSQgnue1zfGGC6rFDbI");
    sharedPreferences.setString(PreferenceKeys.keyUserInfo,
        '{"userId": "723672", "userName": "应佳伟", "mobile": "17376508275", "isCertification": 0}');
    runApp(MyApp());
//  });
//  FlutterBugly.init(androidAppId: "89b908154e", iOSAppId: "0d1433b494");
}

class MyApp extends StatelessWidget {
  MyApp();

  @override
  Widget build(BuildContext context) {
    return BlocProviders<ApplicationBloc>(
      bloc: ApplicationBloc(),
      child: MaterialApp(
        theme: defaultThemeData,
        debugShowCheckedModeBanner: false,
        routes: {
          "/": (_) {
            bool firstEntry =
                sharedPreferences.getBool(PreferenceKeys.keyFirstEntryTag) ??
                    true;
            return firstEntry ? SplashPage() : MainPage();
          },
          "/login": (_) => BlocProviders<LoginBloc>(
                child: LoginPage(),
                bloc: LoginBloc(),
              ),
          "/register": (_) => RegisterPage(),
          "/personal": (_) => PersonalInfoPage(),
          "/verify": (_) => AuthorizationPage(),
          "/map": (_) => MapAndLocatePage(),
          "/camera": (_) => CameraPage(),
          "/webview": (_) => WebViewExample(),
          "/audio": (_) => AudioRecordPage(),
          "/test": (_) => TestPage(),
          "/contacts": (_) => BlocProviders<ContactsBloc>(
                child: ContactsSelectPage(),
                bloc: ContactsBloc(),
              ),
        },
      ),
    );
  }
}
