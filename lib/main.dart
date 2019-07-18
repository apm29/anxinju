import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';
import 'package:ease_life/ui/dispute_mediation_list_page.dart';
import 'package:ease_life/ui/notification_message_page.dart';
import 'package:oktoast/oktoast.dart';

import 'index.dart';
import 'model/announcement_model.dart';
import 'model/app_info_model.dart';
import 'model/district_model.dart';
import 'model/home_end_scroll_model.dart';
import 'model/main_index_model.dart';
import 'model/mediation_model.dart';
import 'model/notification_model.dart';
import 'model/theme_model.dart';
import 'model/user_model.dart';

import 'package:fake_push/fake_push.dart';

import 'ui/dispute_mediation_page.dart';

List<CameraDescription> cameras;
//JPush jPush = JPush();

void main() async {
  //sp初始化
  userSp = await SharedPreferences.getInstance();
  await AMap.init(Configs.AMapKey);
  //相机初始化
  cameras = await availableCameras();
  FlutterBugly.postCatchedException(() {
    runApp(MyApp());
  });
}

// Platform messages are asynchronous, so we initialize in an async method.
//Future<void> initPlatformState(BuildContext context) async {
//  // Platform messages may fail, so we use a try/catch PlatformException.
//  jPush.getRegistrationID().then((rid) {
//    print("flutter getRegistrationID: $rid");
//    userSp.setString(KEY_REGISTRATION_ID, rid);
//  });
//  jPush.applyPushAuthority(
//    new NotificationSettingsIOS(sound: true, alert: true, badge: true),
//  );
//
//  try {
//    jPush.addEventHandler(
//      onReceiveNotification: (Map<String, dynamic> message) async {
//        print("flutter onReceiveNotification: $message");
//      },
//      onOpenNotification: (Map<String, dynamic> message) async {
//        try {
//          Map<dynamic, dynamic> extras = getExtrasByPlatform(message);
//          Map<String, String> extrasMap = {};
//          extras.forEach((k, v) {
//            extrasMap.putIfAbsent(k.toString(), () => v.toString());
//          });
//          print('EXTRAS ===> $extras');
//
//          /// "extra":{
//          ///   "type":"web",
//          ///   "data":{"url":"fkgl"},
//          /// }
//          if (extras != null && extras["type"] == "web") {
//            Api.getIndex().then((resp) {
//              resp.forEach((index) {
//                index.menu.forEach((menu) {
//                  if (menu.id == extras['data']['url']) {
//                    Navigator.of(context)
//                        .push(MaterialPageRoute(builder: (context) {
//                      return WebViewExample(menu.url);
//                    }));
//                  }
//                });
//              });
//            });
//          }
//        } catch (e, s) {
//          print(e.toString());
//          print(s.toString());
//        }
//      },
//      onReceiveMessage: (Map<String, dynamic> message) async {
//        print("flutter onReceiveMessage: $message");
////        try {
////          var myExtras = message["message"];
////          print('EXTRAS ====> $myExtras');
////          print('EXTRAS ====> ${myExtras.runtimeType}');
////          Map<String, dynamic> myMap = json.decode(myExtras);
////          print('EXTRAS ====> $myMap');
////          var fireDate = DateTime.fromMillisecondsSinceEpoch(
////              DateTime.now().millisecondsSinceEpoch + 1000);
////          Map<String, String> extrasMap = {};
////          myMap.forEach((k, v) {
////            extrasMap.putIfAbsent(k, () => v.toString());
////          });
////          print('EXTRAS ====> $extrasMap');
////          var localNotification = LocalNotification(
////              id: DateTime.now().millisecondsSinceEpoch % 1000000,
////              title: myMap['title'],
////              buildId: 1,
////              content: myMap['content'],
////              fireTime: fireDate,
////              subtitle: myMap['subtitle'],
////              // 该参数只有在 iOS 有效
////              badge: 1,
////              // 该参数只有在 iOS 有效
////              extras:
////                  message['extras'] // 设置 extras ，extras 需要是 Map<String, String>
////              );
////          jPush.sendLocalNotification(localNotification).then((res) {
////            print('SEND ====> $res');
////          });
////        } catch (e) {
////          print(e);
////        }
//      },
//    );
//
//    jPush.setup(
//      appKey: Configs.JPushKey,
//      channel: "developer-default",
//      production: false,
//      debug: true,
//    );
//  } catch (e) {
//    print('$e');
//  }
//}

getExtrasByPlatform(Map<String, dynamic> message) {
  if (Platform.isAndroid) {
    return json.decode(message['extras'][getExtras()]);
  } else {
    return message['extras'];
  }
}

String getExtras() {
  return 'cn.jpush.android.EXTRA';
}

class MyApp extends StatelessWidget {
  MyApp();

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: MainIndexModel()),
          ChangeNotifierProvider.value(value: UserModel()),
          ChangeNotifierProvider.value(value: AnnouncementModel()),
          ChangeNotifierProvider.value(value: AppThemeModel()),
          ChangeNotifierProvider.value(value: DistrictModel()),
          ChangeNotifierProvider.value(value: HomeEndScrollModel()),
          ListenableProvider<NotificationModel>(
            builder: (BuildContext context) {
              return NotificationModel(context);
            },
            dispose: (context, value) {
              value.dispose();
            },
          ),
          ChangeNotifierProvider.value(value: UserVerifyStatusModel()),
          ChangeNotifierProvider.value(value: UserRoleModel()),
          ChangeNotifierProvider.value(value: MessageModel()),
          ChangeNotifierProvider.value(value: ChatRoomPageStatusModel()),
          ChangeNotifierProvider.value(value: AppInfoModel()),
        ],
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
              bool firstEntry = userSp.getBool(KEY_FIRST_ENTRY_TAG) ?? true;
              return firstEntry ? SplashPage() : MainPage();
            },
            LoginPage.routeName: (_) => BlocProviders<LoginBloc>(
                  child: LoginPage(),
                  bloc: LoginBloc(),
                ),
            RegisterPage.routeName: (_) => RegisterPage(),
            MemberApplyPage.routeName: (_) {
              return MemberApplyPage();
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
            ChatRoomPage.routeName: (_) => ChatRoomPage(),
            NotificationMessagePage.routeName: (_) => NotificationMessagePage(),
            ContactsSelectPage.routeName: (_) => BlocProviders<ContactsBloc>(
                  child: ContactsSelectPage(null),
                  bloc: ContactsBloc(),
                ),
            MediationListPage.routeName: (context) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      builder: (context)=>MediationHistoryModel(context),
                    ),
                    ChangeNotifierProvider(
                      builder: (context)=>MediationRunningModel(context),
                    ),
                    ChangeNotifierProvider(
                      builder: (context)=>MediationApplyModel(context),
                    ),
                  ],
                  child: MediationListPage(),
                ),
            MediationApplyPage.routeName: (context) => ChangeNotifierProvider(child: MediationApplyPage(),builder: (context){
              return MediationApplicationAddModel(context);
            },),
          },
        ),
      ),
    );
  }
}
