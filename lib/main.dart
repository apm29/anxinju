import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/ui/audio_record_page.dart';
import 'package:ease_life/ui/authorization_page.dart';
import 'package:ease_life/ui/camera_page.dart';
import 'package:ease_life/ui/contacts_select_page.dart';
import 'package:ease_life/ui/main_page.dart';
import 'package:ease_life/ui/login_page.dart';
import 'package:ease_life/ui/not_found_page.dart';
import 'package:ease_life/ui/personal_info_page.dart';
import 'package:ease_life/ui/register_page.dart';
import 'package:ease_life/ui/splash_page.dart';
import 'package:ease_life/ui/style.dart';
import 'package:ease_life/ui/test_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'package:ease_life/ui/user_detail_auth_page.dart';
SharedPreferences sharedPreferences;
List<CameraDescription> cameras;

void main() async {
//  FlutterBugly.postCatchedException(() async {
  //sp初始化
  sharedPreferences = await SharedPreferences.getInstance();
//    await AMap.init("d712d41f19e76ca74b673f9d5637af8a");
  //相机初始化
  cameras = await availableCameras();
//    sharedPreferences.setString(PreferenceKeys.keyAuthorization,
//        "eyJhbGciOiJIUzI1NiJ9.eyJhbnhpbmp1IjoiMTU1NDcxMjE2MDQ2MTkwMTYyNDIiLCJjcmVhdGVkIjoxNTU0ODkwODk4MzIwLCJleHAiOjE5ODY4OTA4OTh9.VYwQw-3io7XxgQHvtuKrB7RyVSQgnue1zfGGC6rFDbI");
//    sharedPreferences.setString(PreferenceKeys.keyUserInfo,
//        '{"userId": "723672", "userName": "应佳伟", "mobile": "17376508275", "isCertification": 0}');
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
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) {
            return NotFoundPage(routeName: settings.name);
          });
        },
        routes: {
          "/": (_) {
            bool firstEntry =
                sharedPreferences.getBool(PreferenceKeys.keyFirstEntryTag) ??
                    true;
            return firstEntry ? SplashPage() : MainPage();
          },
          LoginPage.routeName: (_) => BlocProviders<LoginBloc>(
                child: LoginPage(),
                bloc: LoginBloc(),
              ),
          RegisterPage.routeName: (_) => RegisterPage(),
          PersonalInfoPage.routeName: (_) => PersonalInfoPage(),
          AuthorizationPage.routeName: (_) => AuthorizationPage(),
          UserDetailAuthPage.routeName: (_) => UserDetailAuthPage(),
          FaceIdPage.routeName: (_) => FaceIdPage(),
          AudioRecordPage.routeName: (_) => AudioRecordPage(),
          TestPage.routeName: (_) => TestPage(),
          ContactsSelectPage.routeName: (_) => BlocProviders<ContactsBloc>(
                child: ContactsSelectPage(null),
                bloc: ContactsBloc(),
              ),
        },
      ),
    );
  }
}
