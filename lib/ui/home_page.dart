import 'dart:math';
import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/bloc/user_bloc.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/remote//dio_net.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rxdart/rxdart.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static int _currentIndex = 0;
  static DateTime _lastPressedAt;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          centerTitle: true,
          title: Text(
            "安心居",
          ),
          actions: <Widget>[buildActions(context)],
        ),
        body: buildBody(context),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Image.asset(
                  "images/mine.png",
                  width: 24,
                  height: 24,
                  color: _currentIndex == 0 ? Colors.blueAccent : Colors.grey,
                ),
                title: Text("我的")),
            BottomNavigationBarItem(
                icon: Image.asset(
                  "images/society.png",
                  width: 24,
                  height: 24,
                  color: _currentIndex == 1 ? Colors.blueAccent : Colors.grey,
                ),
                title: Text("圈子")),
            BottomNavigationBarItem(
                icon: Image.asset(
                  "images/search.png",
                  width: 24,
                  height: 24,
                  color: _currentIndex == 2 ? Colors.blueAccent : Colors.grey,
                ),
                title: Text("搜索")),
            BottomNavigationBarItem(
                icon: Image.asset(
                  "images/help.png",
                  width: 24,
                  height: 24,
                  color: _currentIndex == 3 ? Colors.blueAccent : Colors.grey,
                ),
                title: Text("帮助")),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _pageController.animateToPage(index,
                  duration: Duration(milliseconds: 200), curve: Curves.ease);
            });
          },
          currentIndex: _currentIndex,
          fixedColor: Colors.blue,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget buildActions(BuildContext context) {
    Function onSelect = (value) {
      switch (value) {
        case 1:
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("登出"),
                  content: Text("确认退出登录?"),
                  actions: <Widget>[
                    OutlineButton(
                      onPressed: () {
                        BlocProvider.of(context).logout();
                        Navigator.of(context).pop();
                      },
                      child: Text("退出"),
                    )
                  ],
                );
              });
          break;
        case 2:
          Navigator.of(context).pushNamed("/login");
          break;
        case 3:
          Navigator.of(context).pushNamed("/personal");
          break;
      }
    };
    var logout = PopupMenuButton(
      itemBuilder: (context) {
        return <PopupMenuItem>[
          PopupMenuItem(value: 1, child: Text("登出")),
          PopupMenuItem(
            child: Text("个人信息"),
            value: 3,
          )
        ];
      },
      onSelected: onSelect,
    );
    var login = PopupMenuButton(
      itemBuilder: (context) {
        return <PopupMenuItem>[PopupMenuItem(value: 2, child: Text("登录"))];
      },
      onSelected: onSelect,
    );
    return StreamBuilder<BlocData<UserInfoModel>>(
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.success()) {
          if (snapshot.data.response is UserInfoModel &&
              snapshot.data.response != null) {
            return logout;
          } else {
            return login;
          }
        } else {
          return login;
        }
      },
      initialData: null,
      stream: Observable.merge([
        Stream.fromFuture(
            BlocProvider.of(context).getUserInfoData().then((wrapper) {
          return BlocData.success(UserInfoModel.success(wrapper));
        })),
        BlocProvider.of(context).loginStream
      ]),
    );
  }

  PageController _pageController = PageController(initialPage: _currentIndex);

  Widget buildBody(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          if (_currentIndex != index) {
            _currentIndex = index;
          }
        });
      },
      children: <Widget>[
        _buildMine(),
        Container(),
        Container(),
        Center(
          child: RaisedButton(
            onPressed: () async {
              Navigator.of(context).pushNamed("/test");
            },
            child: Text("test"),
          ),
        )
      ],
    );
  }

  Widget _buildMine() {
    return ListView(
      key: PageStorageKey("123"),
      children: <Widget>[
        Container(
          height: 200,
          margin: EdgeInsets.fromLTRB(18, 18, 18, 0),
          color: Colors.grey,
          child: PageView.builder(
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: "http://lorempixel.com/${800 + index * 20}/420",
                imageBuilder: (context, provider) {
                  return Image(
                    image: provider,
                    fit: BoxFit.fill,
                  );
                },
                placeholder: (_, __) {
                  return Center(child: CircularProgressIndicator());
                },
              );
            },
            itemCount: 3,
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(18, 0, 18, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          child: Icon(
                            Icons.people,
                            color: Colors.white,
                          )),
                      Text("访客管理")
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(
                            Icons.people,
                            color: Colors.white,
                          )),
                      Text("访客管理")
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                          backgroundColor: Colors.greenAccent,
                          child: Icon(
                            Icons.people,
                            color: Colors.white,
                          )),
                      Text("访客管理")
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                          backgroundColor: Colors.yellowAccent,
                          child: Icon(
                            Icons.people,
                            color: Colors.white,
                          )),
                      Text("访客管理")
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.all(18),
          padding: EdgeInsets.all(6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(Icons.notifications_active),
              Expanded(
                child: Text(
                  "诸暨市公安局发布电信网络新型犯罪案例" * 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                color: Colors.blueAccent,
                height: 30,
                width: 5,
              )
            ],
          ),
        )
      ],
    );
  }
}
