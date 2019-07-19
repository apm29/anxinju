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

class MyApp extends StatelessWidget {
  MyApp();

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(builder: (context) => MainIndexModel()),
          ChangeNotifierProvider(builder: (context) => UserModel()),
          ChangeNotifierProvider(builder: (context) => AnnouncementModel()),
          ChangeNotifierProvider(builder: (context) => AppThemeModel()),
          ChangeNotifierProvider(builder: (context) => DistrictModel()),
          ChangeNotifierProvider(builder: (context) => HomeEndScrollModel()),
          ListenableProvider<NotificationModel>(
            builder: (BuildContext context) {
              return NotificationModel(context);
            },
            dispose: (context, value) {
              value.dispose();
            },
          ),
          ChangeNotifierProvider(builder: (context) => UserVerifyStatusModel()),
          ChangeNotifierProvider(builder: (context) => UserRoleModel(context)),
          ChangeNotifierProvider(builder: (context) => MessageModel()),
          ChangeNotifierProvider(builder: (context) => ChatRoomPageStatusModel()),
          ChangeNotifierProvider(builder: (context) => AppInfoModel()),
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
                      builder: (context) => MediationHistoryModel(context),
                    ),
                    ChangeNotifierProvider(
                      builder: (context) => MediationRunningModel(context),
                    ),
                    ChangeNotifierProvider(
                      builder: (context) => MediationApplyModel(context),
                    ),
                  ],
                  child: MediationListPage(),
                ),
            MediationApplyPage.routeName: (context) => ChangeNotifierProvider(
                  child: MediationApplyPage(),
                  builder: (context) {
                    return MediationApplicationAddModel(context);
                  },
                ),
          },
        ),
      ),
    );
  }
}
