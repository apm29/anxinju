
import 'index.dart';

SharedPreferences sharedPreferences;
List<CameraDescription> cameras;
JPush jPush = JPush();
void main() async {
  //sp初始化
  sharedPreferences = await SharedPreferences.getInstance();
  await AMap.init(Configs.AMapKey);
  //相机初始化
  cameras = await availableCameras();
//  runZoned(() {
//
//  }, onError: (e, s) {
//    debugPrint(e.toString());
//    debugPrint(s.toString());
//  });
  FlutterBugly.postCatchedException((){
    runApp(MyApp());
  });
}

// Platform messages are asynchronous, so we initialize in an async method.
Future<void> initPlatformState(BuildContext context) async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  jPush.getRegistrationID().then((rid) {
    print("flutter getRegistrationID: $rid");
  });
  jPush.applyPushAuthority(
      new NotificationSettingsIOS(sound: true, alert: true, badge: true));

  try {
    jPush.addEventHandler(
      onReceiveNotification: (Map<String, dynamic> message) async {
        print("flutter onReceiveNotification: $message");
      },
      onOpenNotification: (Map<String, dynamic> message) async {
        try {
          Map<dynamic, dynamic> extras = getExtrasByPlatform(message);
          Map<String, String> extrasMap = {};
          extras.forEach((k, v) {
            extrasMap.putIfAbsent(k.toString(), () => v.toString());
          });
          print('EXTRAS ===> $extras');
          if (extras != null) {
            Navigator.of(context).pushNamed(extrasMap['test']);
          }
        } catch (e, s) {
          print(e.toString());
          print(s.toString());
        }
      },
      onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
//        try {
//          var myExtras = message["message"];
//          print('EXTRAS ====> $myExtras');
//          print('EXTRAS ====> ${myExtras.runtimeType}');
//          Map<String, dynamic> myMap = json.decode(myExtras);
//          print('EXTRAS ====> $myMap');
//          var fireDate = DateTime.fromMillisecondsSinceEpoch(
//              DateTime.now().millisecondsSinceEpoch + 1000);
//          Map<String, String> extrasMap = {};
//          myMap.forEach((k, v) {
//            extrasMap.putIfAbsent(k, () => v.toString());
//          });
//          print('EXTRAS ====> $extrasMap');
//          var localNotification = LocalNotification(
//              id: DateTime.now().millisecondsSinceEpoch % 1000000,
//              title: myMap['title'],
//              buildId: 1,
//              content: myMap['content'],
//              fireTime: fireDate,
//              subtitle: myMap['subtitle'],
//              // 该参数只有在 iOS 有效
//              badge: 1,
//              // 该参数只有在 iOS 有效
//              extras:
//                  message['extras'] // 设置 extras ，extras 需要是 Map<String, String>
//              );
//          jPush.sendLocalNotification(localNotification).then((res) {
//            print('SEND ====> $res');
//          });
//        } catch (e) {
//          print(e);
//        }
      },
    );

    jPush.setup(
      appKey: Configs.JPushKey,
      channel: "developer-default",
      production: false,
      debug: true,
    );
  } catch (e) {
    print('$e');
  }
}

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MainIndexModel>(
          builder: (context)=>MainIndexModel(),
        ),
      ],
      child: BlocProviders<ApplicationBloc>(
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
            ChatRoomPage.routeName: (_) => ChatRoomPage(),
            ContactsSelectPage.routeName: (_) => BlocProviders<ContactsBloc>(
                  child: ContactsSelectPage(null),
                  bloc: ContactsBloc(),
                ),
          },
        ),
      ),
    );
  }
}

class PushNotification extends Notification {
  final Map<String, String> extras;

  PushNotification(this.extras);
}
