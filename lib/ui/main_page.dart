import 'package:ease_life/index.dart';

const int PAGE_HOME = 0;
const int PAGE_SEARCH = 1;
const int PAGE_MESSAGE = 21;
const int PAGE_MINE = 2;

class MainPage extends StatefulWidget {
  static String routeName = "/";

  MainPage({Key key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  static DateTime _lastPressedAt;
  PageController _pageController = PageController();
  GlobalKey<BottomBarState> bottomKey = GlobalKey();
  PageStorageKey<String> pagerKey = PageStorageKey("main");

  @override
  void initState() {
    super.initState();
    initPlatformState(context);
    if (mounted) {
      BlocProviders.of<ApplicationBloc>(context).getUserTypes();
    }
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
    var mainIndexBloc = BlocProviders.of<MainIndexBloc>(context);
    mainIndexBloc.indexStream.listen((index) {
      changePage(context, index);
    }).onError((e) {
      print(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
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
      builder: (context, model, child) {
        _pageController = PageController(initialPage: model.currentIndex);
        return Scaffold(
          body: Container(
            color: Colors.grey[200],
            child: buildContent(context),
          ),
          bottomNavigationBar: buildBottomNavigationBar(),
        );
      },
    ));
  }

  Widget buildBottomNavigationBar() {
    return Consumer<MainIndexModel>(
      builder: (context, value, child) {
        return BottomBar(bottomKey, _pageController, value.currentIndex);
      },
    );
  }

  void changePage(BuildContext context, int pageIndex) {
    _pageController.jumpToPage(pageIndex);
    bottomKey.currentState.changePage(pageIndex);
  }

  buildContent(BuildContext context) {
    ///监听主页面切换
    return NotificationListener<IndexNotification>(
      onNotification: (notification) {
        changePage(context, notification.index);
        if (notification.indexId != null) {
          print('$notification');
          Index index = getIndexInfo().firstWhere((index) =>
              index.area ==
              (notification.index == PAGE_HOME ? 'index' : 'mine'));
          routeToWeb(context, notification.indexId, index);
        }
        return true;
      },
      child: PageView.builder(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        key: pagerKey,
        itemBuilder: (context, index) {
          switch (index) {
            case PAGE_HOME:
              return HomePage();
            case PAGE_SEARCH:
              return buildTestPage();
            case PAGE_MESSAGE:
              return MessagePage();
            case PAGE_MINE:
              return MinePage();
            default:
              throw Exception("无效索引");
          }
        },
        onPageChanged: (index) {
          //bottomKey.currentState.changePage(index);
          Provider.of<MainIndexModel>(context).changeIndex(index);
        },
      ),
    );
//    switch (_currentIndex) {
//      case PAGE_HOME:
//        return HomePage();
//      case PAGE_SEARCH:
//        return buildTestPage();
//      case PAGE_MESSAGE:
//        return MessagePage();
//      case PAGE_MINE:
//        return MinePage();
//    }
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
                Navigator.of(context).pushNamed(ChatRoomPage.routeName,arguments: {
                  "group":"1",
                  "title":"紧急呼救"
                });
              },
              child: Text("紧急呼救"),
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

class IndexNotification extends Notification {
  final int index;
  String indexId;

  IndexNotification(this.index);

  @override
  String toString() {
    return 'IndexNotification{index: $index, indexId: $indexId}';
  }
}
