import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';
import 'package:ease_life/ui/dispute_mediation_list_page.dart';
import 'package:ease_life/ui/notification_message_page.dart';
import 'package:ease_life/ui/service_chat_page.dart';
import 'package:ease_life/ui/setting_page.dart';
import 'package:ease_life/ui/video_nineoneone_page.dart';
import 'package:ease_life/ui/face_verify_hint_page.dart';
import 'package:oktoast/oktoast.dart';

import 'index.dart';
import 'model/announcement_model.dart';
import 'model/app_info_model.dart';
import 'model/district_model.dart';
import 'model/home_end_scroll_model.dart';
import 'model/main_index_model.dart';
import 'model/mediation_model.dart';
import 'model/notification_model.dart';
import 'model/service_chat_model.dart';
import 'model/theme_model.dart';
import 'model/user_model.dart';
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
          ChangeNotifierProvider(builder: (context) => UserModel()),
        ],
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(builder: (context) => MainIndexModel()),
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
            ChangeNotifierProvider(
                builder: (context) => UserVerifyStatusModel()),
            ChangeNotifierProvider(
                builder: (context) => UserRoleModel(context)),
            ChangeNotifierProvider(builder: (context) => MessageModel()),
            ChangeNotifierProvider(
                builder: (context) => ChatRoomPageStatusModel()),
            ChangeNotifierProvider(builder: (context) => AppInfoModel()),
            ChangeNotifierProvider(
              builder: (context) {
                return ServiceChatModel(context);
              },
            )
          ],
          child: MaterialApp(
            theme: defaultThemeData,
//            supportedLocales: [
//              const Locale.fromSubtags(languageCode: 'zh'), // generic Chinese 'zh'
//              const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), // generic simplified Chinese 'zh_Hans'
//              const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), // generic traditional Chinese 'zh_Hant'
//              const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'), // 'zh_Hans_CN'
//              const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'), // 'zh_Hant_TW'
//              const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'), // 'zh_Hant_HK'
//            ],
            debugShowCheckedModeBanner: Configs.APP_DEBUG,
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
              EmergencyCallPage.routeName: (_) => EmergencyCallPage(),
              SettingPage.routeName: (_) => SettingPage(),
              NotificationMessagePage.routeName: (_) =>
                  NotificationMessagePage(),
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
              VideoNineOneOnePage.routeName: (context) =>
                  ChangeNotifierProvider(
                    child: VideoNineOneOnePage(
                      channelName: Configs.AGORA_CHANNEL_POLICE,
                    ),
                    builder: (context) {
                      return VideoNineOneOneModel();
                    },
                  )
            },
          ),
        ),
      ),
    );
  }
}
