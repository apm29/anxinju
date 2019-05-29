import 'package:ease_life/remote/api.dart';
import 'package:ease_life/res/strings.dart';

import '../index.dart';
import '../ui/home_page.dart';
import '../ui/message_page.dart';
import '../ui/mine_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'audio_record_page.dart';
import 'camera_page.dart';
import 'house_member_apply_page.dart';
import 'user_detail_auth_page.dart';
import 'web_view_example.dart';
import 'widget/bottom_bar.dart';

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
  PageController _pageController = PageController();
  GlobalKey<BottomBarState> bottomKey = GlobalKey();
  PageStorageKey<String> pagerKey = PageStorageKey("main");

  @override
  void initState() {
    super.initState();
    initPlatformState(context);
    if (mounted) BlocProviders.of<ApplicationBloc>(context).getUserTypes();
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
    return WillPopScope(
        onWillPop: () async {
          if (_lastPressedAt == null ||
              DateTime.now().difference(_lastPressedAt) >
                  Duration(seconds: 1)) {
            //两次点击间隔超过1秒则重新计时
            _lastPressedAt = DateTime.now();
            Fluttertoast.showToast(msg: "再按一次退出");
            return false;
          }
          return true;
        },
        child: Scaffold(
          key: appKey,
          body: Container(
            color: Colors.grey[200],
            child: buildContent(),
          ),
          bottomNavigationBar: buildBottomNavigationBar(),
        ));
  }

  Widget buildBottomNavigationBar() {
    return BottomBar(bottomKey, _pageController);
  }

  void changePage(BuildContext context, int pageIndex) {
    _pageController.jumpToPage(pageIndex);
    bottomKey.currentState.changePage(pageIndex);
  }

  buildContent() {
    return NotificationListener<IndexNotification>(
      onNotification: (notification) {
        changePage(context, notification.index);
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
          }
        },
        onPageChanged: (index) {
          bottomKey.currentState.changePage(index);
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
                Navigator.of(context).pushNamed(AudioRecordPage.routeName);
              },
              child: Text("语音录入界面"),
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

  IndexNotification(this.index);
}
