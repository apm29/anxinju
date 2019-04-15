import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/ui/authorization_page.dart';
import 'package:ease_life/ui/main_page.dart';
import 'package:ease_life/remote//dio_net.dart';
import 'package:ease_life/ui/login_page.dart';
import 'package:ease_life/ui/personal_info_page.dart';
import 'package:ease_life/ui/register_page.dart';
import 'package:ease_life/ui/splash_page.dart';
import 'package:ease_life/ui/style.dart';
import 'package:ease_life/ui/test_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

SharedPreferences sharedPreferences;

void main() async {
  sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString(PreferenceKeys.keyAuthorization,
      "eyJhbGciOiJIUzI1NiJ9.eyJhbnhpbmp1IjoiMTU1NDcxMjE2MDQ2MTkwMTYyNDIiLCJjcmVhdGVkIjoxNTU0ODkwODk4MzIwLCJleHAiOjE5ODY4OTA4OTh9.VYwQw-3io7XxgQHvtuKrB7RyVSQgnue1zfGGC6rFDbI");
  sharedPreferences.setString(PreferenceKeys.keyUserInfo,
      '{"userId": "723672", "userName": "应佳伟", "mobile": "17376508275", "isCertification": 0}');
  runApp(MyApp());
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
            bool firstEntry = sharedPreferences.getBool(PreferenceKeys.keyFirstEntryTag) ?? true;
            return firstEntry ? SplashPage() : MainPage();
          },
          "/login": (_) => BlocProviders<LoginBloc>(
                child: LoginPage(),
                bloc: LoginBloc(),
              ),
          "/register":(_)=>RegisterPage(),
          "/personal": (_) => PersonalInfoPage(),
          "/verify": (_) => AuthorizationPage(),
        },
      ),
    );
  }
}
