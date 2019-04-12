import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/ui/authorization_page.dart';
import 'package:ease_life/ui/home_page.dart';
import 'package:ease_life/remote//dio_net.dart';
import 'package:ease_life/ui/login_page.dart';
import 'package:ease_life/ui/personal_info_page.dart';
import 'package:ease_life/ui/style.dart';
import 'package:ease_life/ui/test_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  DioUtil.sp = await SharedPreferences.getInstance();
  DioUtil.sp.setString("app", "app");

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
        routes: {
          "/": (_) => HomePage(),
          "/login": (_) => BlocProviders<LoginBloc>(
                child: LoginPage(),
                bloc: LoginBloc(),
              ),
          "/personal": (_) => PersonalInfoPage(),
          "/verify": (_) => AuthorizationPage(),
        },
      ),
    );
  }
}
