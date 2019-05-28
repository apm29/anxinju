import 'dart:async';

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
import 'package:amap_base_location/amap_base_location.dart';

import 'res/strings.dart';
import 'ui/chat_room_page.dart';
import 'ui/house_member_apply_page.dart';

SharedPreferences sharedPreferences;
List<CameraDescription> cameras;

void main() async {
  //sp初始化
  sharedPreferences = await SharedPreferences.getInstance();
  await AMap.init(Configs.AMapKey);
  //相机初始化
  cameras = await availableCameras();
  runZoned((){
    runApp(MyApp());
  },onError: (e,s){
    debugPrint(e.toString());
    debugPrint(s.toString());
  });
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
          MainPage.routeName: (_) {
            bool firstEntry =
                sharedPreferences.getBool(PreferenceKeys.keyFirstEntryTag) ??
                    true;
            return BlocProviders<MainIndexBloc>(
              child: firstEntry ? SplashPage() : MainPage(),
              bloc: MainIndexBloc(),
            );
          },
          LoginPage.routeName: (_) => BlocProviders<LoginBloc>(
                child: LoginPage(),
                bloc: LoginBloc(),
              ),
          RegisterPage.routeName: (_) => RegisterPage(),
          MemberApplyPage.routeName: (_) {
            return BlocProviders<MemberApplyBloc>(
              bloc: MemberApplyBloc(),
              child: MemberApplyPage(),
            );
          },
          PersonalInfoPage.routeName: (_) => PersonalInfoPage(),
          AuthorizationPage.routeName: (_) => AuthorizationPage(),
          UserDetailAuthPage.routeName: (_) => UserDetailAuthPage(),
          FaceIdPage.routeName: (_) {
            return BlocProviders<CameraBloc>(
              child: FaceIdPage(),
              bloc: CameraBloc(),
            );
          },
          AudioRecordPage.routeName: (_) => AudioRecordPage(),
          TestPage.routeName: (_) => TestPage(),
          ChatRoomPage.routeName: (_) => ChatRoomPage(),
          ContactsSelectPage.routeName: (_) => BlocProviders<ContactsBloc>(
                child: ContactsSelectPage(null),
                bloc: ContactsBloc(),
              ),
        },
      ),
    );
  }
}
