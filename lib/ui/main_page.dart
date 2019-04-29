import 'package:ease_life/interaction/simple_bridge.dart';
import 'package:ease_life/remote/api.dart';

import '../ui/home_page.dart';
import '../ui/message_page.dart';
import '../ui/mine_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:fzxing/fzxing.dart';
import 'web_view_example.dart';
import 'package:ease_life/main.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static int _currentIndex = 0;
  static DateTime _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    ScreenUtil(width: 1080, height: 2160)
      ..init(context);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
      child: Scaffold(
        body: Builder(builder: (context) {
          return buildBody(context);
        }),
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 24,
              color: _currentIndex == 0 ? Colors.blueAccent : Colors.grey,
            ),
            title: Text("主页")),
        BottomNavigationBarItem(
            icon: Image.asset(
              "images/search.png",
              width: 24,
              height: 24,
              color: _currentIndex == 1 ? Colors.blueAccent : Colors.grey,
            ),
            title: Text("搜索")),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.message,
              size: 24,
              color: _currentIndex == 2 ? Colors.blueAccent : Colors.grey,
            ),
            title: Text("消息")),
        BottomNavigationBarItem(
            icon: Image.asset(
              "images/mine.png",
              width: 24,
              height: 24,
              color: _currentIndex == 3 ? Colors.blueAccent : Colors.grey,
            ),
            title: Text("我的")),
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          _pageController.jumpToPage(index);
        });
      },
      currentIndex: _currentIndex,
      fixedColor: Colors.blue,
      type: BottomNavigationBarType.fixed,
    );
  }

  PageController _pageController = PageController(initialPage: _currentIndex);
  TextEditingController controller = TextEditingController(
      text: sharedPreferences.getString("lastUrl") ?? "http://axj.ciih.net/#/");

  Widget buildBody(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(),
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            if (_currentIndex != index) {
              _currentIndex = index;
            }
          });
        },
        children: <Widget>[
          HomePage(),
          Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  OutlineButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/preVerify");
//                      showAndroidKeyboard();
                    },
                    child: Text("测试界面"),
                  ),
                  OutlineButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/camera");
                    },
                    child: Text("人脸识别界面"),
                  ),
                  OutlineButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/audio");
                    },
                    child: Text("语音录入界面"),
                  ),
                  OutlineButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return WebViewExample("http://axj.ciih.net/#/");
                          }));
                    },
                    child: Text("WebView界面"),
                  ),
                ],
              ),
            ),
          ),
          MessagePage(),
          MinePage(),
        ],
      ),
    );
  }
}
