import 'package:ease_life/remote/api.dart';

import '../index.dart';
import '../ui/home_page.dart';
import '../ui/message_page.dart';
import '../ui/mine_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'audio_record_page.dart';
import 'camera_page.dart';
import 'chat_room_page.dart';
import 'member_apply_page.dart';
import 'test_page.dart';
import 'user_detail_auth_page.dart';
import 'web_view_example.dart';

const int PAGE_HOME = 0;
const int PAGE_SEARCH = 11;
const int PAGE_MESSAGE = 21;
const int PAGE_MINE = 1;

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static int _currentIndex = 0;
  static DateTime _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    ScreenUtil(width: 1080, height: 2160)..init(context);
    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1)) {
          //两次点击间隔超过1秒则重新计时
          _lastPressedAt = DateTime.now();
          Fluttertoast.showToast(msg: "再按一次退出");
          return false;
        }
        return true;
      },
      child: StreamBuilder<int>(
          stream: BlocProviders.of<MainIndexBloc>(context).indexStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _currentIndex = snapshot.data ?? 0;
            }
            return Scaffold(
              body: Container(
                color: Colors.grey[200],
                child: buildContent(),
              ),
              bottomNavigationBar: buildBottomNavigationBar(),
            );
          }),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 24,
              color:
                  _currentIndex == PAGE_HOME ? Colors.blueAccent : Colors.grey,
            ),
            title: Text("主页")),
//        BottomNavigationBarItem(
//            icon: Image.asset(
//              "images/search.png",
//              width: 24,
//              height: 24,
//              color: _currentIndex == PAGE_SEARCH
//                  ? Colors.blueAccent
//                  : Colors.grey,
//            ),
//            title: Text("搜索")),
//        BottomNavigationBarItem(
//            icon: Icon(
//              Icons.message,
//              size: 24,
//              color: _currentIndex == PAGE_MESSAGE ? Colors.blueAccent : Colors.grey,
//            ),
//            title: Text("消息")),
        BottomNavigationBarItem(
            icon: Image.asset(
              "images/mine.png",
              width: 24,
              height: 24,
              color:
                  _currentIndex == PAGE_MINE ? Colors.blueAccent : Colors.grey,
            ),
            title: Text("我的")),
      ],
      onTap: (index) {
        if (_currentIndex != index) {
          _currentIndex = index;
          BlocProviders.of<MainIndexBloc>(context).toIndex(_currentIndex);
        }
      },
      currentIndex: _currentIndex,
      fixedColor: Colors.blue,
      type: BottomNavigationBarType.fixed,
    );
  }

  buildContent() {
    switch (_currentIndex) {
      case PAGE_HOME:
        return HomePage();
      case PAGE_SEARCH:
        return Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlineButton(
                  onPressed: () {
//                      Navigator.of(context).pushNamed("/preVerify");
//                      showAndroidKeyboard();
                    Navigator.of(context)
                        .pushNamed(UserDetailAuthPage.routeName);
                  },
                  child: Text("业主认证"),
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
                      return WebViewExample("http://axj.ciih.net/#/");
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
                OutlineButton(
                  onPressed: () {
//                      Navigator.of(context).pushNamed("/preVerify");
//                      showAndroidKeyboard();
                    Navigator.of(context)
                        .pushNamed(ChatRoomPage.routeName, arguments: {
                      "title": "CHAT",
                      "group": "1" //"ws://echo.websocket.org"//
                    });
                  },
                  child: Text("测试界面3"),
                ),
              ],
            ),
          ),
        );
      case PAGE_MESSAGE:
        return MessagePage();
      case PAGE_MINE:
        return MinePage();
    }
  }
}
