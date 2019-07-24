import 'package:ease_life/index.dart';
import 'package:ease_life/model/announcement_model.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/main_index_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';
import 'package:url_launcher/url_launcher.dart';

const int PAGE_HOME = 0;
const int PAGE_SEARCH = 11;
const int PAGE_MESSAGE = 21;
const int PAGE_MINE = 1;

class MainPage extends StatefulWidget {
  static String routeName = "/";

  MainPage({Key key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  static DateTime _lastPressedAt;

  @override
  void initState() {
    super.initState();
//    initPlatformState(context);

    if (Platform.isAndroid)
      FlutterBugly.init(
        androidAppId: "89b908154e",
        iOSAppId: "0d1433b494",
      ).then((result) {
        print('${result.message} ${result.isSuccess}');
        return FlutterBugly.checkUpgrade(isManual: false, isSilence: true)
            .then((_) {
          return FlutterBugly.getUpgradeInfo();
        });
      }).then((UpgradeInfo info) {
        //showAboutDialog(
        //  context: context,
        //  applicationName: Strings.appName,
        //  applicationVersion: info.versionName,
        //  children: [FlatButton(onPressed: () {}, child: Text("更新"))],
        //);
        PackageInfo.fromPlatform().then((packageInfo) {
          if (info != null &&
              int.parse(packageInfo.buildNumber) < info.versionCode) {
            showUpdateDialog(context, info);
          }
        });
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future _requestPermission(PermissionGroup group) async {
    var status = await PermissionHandler().checkPermissionStatus(group);
    if (status == PermissionStatus.granted) {
      return null;
    }
    return PermissionHandler().requestPermissions([group]);
  }

  void requestPermission() async {
    await _requestPermission(PermissionGroup.storage);
    await _requestPermission(PermissionGroup.camera);
  }

  @override
  Widget build(BuildContext context) {
    requestPermission();
    ScreenUtil(width: 1080, height: 2160)..init(context);
    return WillPopScope(onWillPop: () async {
      if (_lastPressedAt == null ||
          DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1)) {
        //两次点击间隔超过1秒则重新计时
        _lastPressedAt = DateTime.now();
        Fluttertoast.showToast(msg: "再按一次退出");
        return false;
      }
      return true;
    }, child: Consumer<MainIndexModel>(
      builder: (context, indexModel, child) {
        return RefreshIndicator(
          child: Scaffold(
            body: Container(
              color: Colors.grey[200],
              child: buildContent(context),
            ),
            floatingActionButton: Consumer2<UserModel,UserRoleModel>(
              builder:
                  (BuildContext context, UserModel userModel,UserRoleModel userRoleModel, Widget child) {
                return Offstage(
                  offstage: !userModel.isLogin || userRoleModel.isOnPropertyDuty,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        EmergencyCallPage.routeName,
                        //arguments: {"group": "25", "title": "紧急呼叫"},
                        arguments: {"group": "3", "title": "紧急呼叫"},
                      );
                    },
                    isExtended: true,
                    icon: Icon(Icons.chat,size: 12,),
                    label: Text("紧急呼叫",style: TextStyle(fontSize: 12),),
                  ),
                );
              },
            ),
            floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar:
                buildBottomNavigationBar(indexModel.currentIndex),
          ),
          onRefresh: () async {
            UserModel.of(context).tryLoginWithLocalToken();
            await UserModel.of(context).tryFetchUserInfoAndLogin();
            await AnnouncementModel.of(context).tryFetchAllAnnouncement();
            await DistrictModel.of(context).tryFetchCurrentDistricts();
            await UserVerifyStatusModel.of(context).tryFetchVerifyStatus();
            await MainIndexModel.of(context).tryFetchIndexJson(evict: true);
            await MainIndexModel.of(context).tryGetCurrentLocation();
            await UserRoleModel.of(context).tryFetchUserRoleTypes(context,dispatchUser: false);
            return;
          },
        );
      },
    ));
  }

  Widget buildBottomNavigationBar(int currentIndex) {
    return BottomBar(currentIndex);
  }

  buildContent(BuildContext context) {
    ///监听主页面切换
    return Consumer<MainIndexModel>(
      builder: (BuildContext context, MainIndexModel indexModel, Widget child) {
        return IndexedStack(
          children: <Widget>[
            HomePage(),
            MinePage(),
            buildTestPage(),
            MessagePage(),

          ],
          index: indexModel.currentIndex,
        );
      },
    );
  }

  Container buildTestPage() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlineButton(
              onPressed: () {
//                      Navigator.of(context).pushNamed("/preVerify");
//                      showAndroidKeyboard();
                Navigator.of(context).pushNamed(UserDetailAuthPage.routeName);
              },
              child: Text("${Strings.hostClass}认证"),
            ),
            OutlineButton(
              onPressed: () {
                Navigator.of(context).pushNamed(FaceIdPage.routeName);
              },
              child: Text("人脸识别界面"),
            ),
            OutlineButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return WebViewExample("http://zaxy.ciih.net/#/");
                }));
              },
              child: Text("WebView界面"),
            ),
            OutlineButton(
              onPressed: () {
//                      Navigator.of(context).pushNamed("/preVerify");
//                      showAndroidKeyboard();
                Navigator.of(context).pushNamed(MemberApplyPage.routeName);
              },
              child: Text("测试界面2"),
            ),
          ],
        ),
      ),
    );
  }
}
