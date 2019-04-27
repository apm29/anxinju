import 'package:ease_life/index.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的"),
        centerTitle: true,
        actions: buildActions(context),
      ),
      body: StreamBuilder<UserInfo>(
        builder: (context, AsyncSnapshot<UserInfo> userSnap) {
          if (userSnap.hasError || !userSnap.hasData) {
            return buildMineVisitor();
          } else {
            return _buildMine(context, userSnap.data);
          }
        },
        stream: BlocProviders.of<ApplicationBloc>(context).currentUser,
      ),
    );
  }

  Widget buildMineVisitor() {
    return Center(
      child: Text("未登录"),
    );
  }

  Widget _buildMine(BuildContext context, UserInfo data) {
    return translateChild(data);
  }

  DefaultTextStyle translateChild(UserInfo data) {
    return DefaultTextStyle(
      style: TextStyle(color: Colors.grey[800]),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: ListView(
          key: PageStorageKey("mine"),
          children: <Widget>[
            SizedBox(
              height: 12,
            ),
            DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Image.asset(
                      "images/ic_banner_mine.png",
                      fit: BoxFit.fill,
                      height: ScreenUtil().setHeight(350),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IntrinsicWidth(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Text("天马花园"),
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            child: FlutterLogo(),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${data.userName}',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white, width: 0.5),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100))),
                                    child: Text("切换用户",
                                        style: TextStyle(fontSize: 8)),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('天马花园15-2-1202'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 12, bottom: 16),
              margin: EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Image.asset(
                        "images/ic_home_mine.png",
                        width: ScreenUtil().setWidth(96),
                      ),
                      Text("我的房屋")
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Image.asset(
                        "images/ic_member_mine.png",
                        width: ScreenUtil().setWidth(96),
                      ),
                      Text("住所成员")
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Image.asset(
                        "images/ic_car_mine.png",
                        width: ScreenUtil().setWidth(96),
                      ),
                      Text("我的爱车")
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 15),
              child: HomeTitleSliver(
                leadingIcon: Image.asset('images/ic_qrcode_mini.png',
                    width: ScreenUtil().setWidth(50)),
                mainTitle: "家庭通行码",
                subTitle: "",
                tailText: "",
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 15),
              child: HomeTitleSliver(
                leadingIcon: Image.asset('images/ic_face_id.png',
                    width: ScreenUtil().setWidth(50)),
                mainTitle: "出入管理",
                subTitle: "",
                tailText: "",
              ),
            ),
            HomeTitleSliver(
              leadingIcon: Container(
                height: ScreenUtil().setHeight(70),
                width: ScreenUtil().setWidth(10),
                color: Color(0xff00007c),
              ),
              mainTitle: "社区记录",
              subTitle: "Society Records",
              tailText: "更多",
            ),
            Material(
              type: MaterialType.card,
              elevation: 1,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setHeight(42),
                  horizontal: ScreenUtil().setWidth(42),
                ),
                color: Colors.white,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: <Widget>[
                    HomeChip(color: const Color(0xff00007c), title: "访客记录"),
                    HomeChip(title: "投诉记录"),
                    HomeChip(title: "缴费记录"),
                    HomeChip(title: "调解档案"),
                    HomeChip(title: "网上110记录"),
                    HomeChip(title: "巡逻记录"),
                    HomeChip(title: "小区保修记录"),
                  ],
                ),
              ),
            ),

            HomeTitleSliver(
              leadingIcon: Container(
                height: ScreenUtil().setHeight(70),
                width: ScreenUtil().setWidth(10),
                color: Color(0xffff6b00),
              ),
              mainTitle: "商业服务",
              subTitle: "Business Service",
              tailText: "更多",
            ),
            Material(
              type: MaterialType.card,
              elevation: 1,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setHeight(42),
                  horizontal: ScreenUtil().setWidth(42),
                ),
                color: Colors.white,
                child: Wrap(
                  children: <Widget>[
                    HomeChip(color: const Color(0xffff6b00), title: "我的订单"),
                    HomeChip(title: "购物车"),
                    HomeChip(title: "我的收藏"),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Icon(
                        Icons.person_outline,
                        color: Colors.blue,
                      ),
                      Text("我的设置")
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Icon(
                        Icons.help_outline,
                        color: Colors.green,
                      ),
                      Text("关于我们")
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      BlocProviders.of<ApplicationBloc>(context).logout();
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                        ),
                        Text("退出登录")
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  buildActions(BuildContext context) {}
}
