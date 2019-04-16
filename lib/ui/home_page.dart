import 'package:ease_life/index.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var list1 = <String>[
    "● 诸暨市公安局发布电信网络新型犯罪案例...",
    "● 本小区发生一起入室盗窃事件...",
    "● 暨阳老娘舅化解邻里纠纷，暖心邻里人居...",
    "● 关于小区快递临时接收点暂停使用的通知...",
  ];
  var list2 = <String>[
    "● 2019年度物业费开始收缴，请点击“在线缴费”...",
    "● 5月1日开始全国文明城市复检，请注意以下事项...",
    "● 小区垃圾分类效果良好，请各住户继续保持...",
    "● 本小区有部分停车位出租，有意者请联系...",
  ];
  var list3 = <String>[
    "● 业主A发起问政：10幢前面路面破损，啥时能...",
    "● 业主B发起表扬：我要表扬李XX，帮我及时解...",
    "● 业主C发起互动：明天同山摘枇杷，谁一起？...",
    "● 业主D发起交换：刚钓到鲫鱼三尾，2斤，换...",
  ];
  var list4 = <String>[
    "● 雄风永利5周年店庆，全场打折促销...",
    "● 山东烟台优质苹果直销店开业，地点：暨东路...",
    "● 伟明汽修庆元宵，到店前10名提供免费洗车服...",
    "● 家政服务，催乳师，育婴师，专业资格持证上...",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        centerTitle: true,
        title: Text(
          "安心居",
        ),
        actions: <Widget>[buildActions(context)],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(17)),
        child: ListView(
          key: PageStorageKey("home_body"),
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: <Widget>[
                  Container(
                    height: ScreenUtil().setWidth(450),
                    color: Colors.grey,
                    child: PageView.builder(
                      itemBuilder: (context, index) {
                        return Image.asset(
                          "images/banner_home.jpg",
                          fit: BoxFit.fill,
                        );
                      },
                      itemCount: 3,
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                    width: ScreenUtil().setWidth(100),
                                    height: ScreenUtil().setWidth(100),
                                    child: Image.asset(
                                      "images/ic_visitor_manager.png",
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
                                SizedBox(
                                    width: ScreenUtil().setWidth(100),
                                    height: ScreenUtil().setWidth(100),
                                    child: Image.asset(
                                      "images/ic_property_manager.png",
                                    )),
                                Text("找物业")
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                    width: ScreenUtil().setWidth(100),
                                    height: ScreenUtil().setWidth(100),
                                    child: Image.asset(
                                      "images/ic_society_manage.png",
                                    )),
                                Text("找社区")
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                    width: ScreenUtil().setWidth(100),
                                    height: ScreenUtil().setWidth(100),
                                    child: Image.asset(
                                      "images/ic_police_manage.png",
                                    )),
                                Text("找警察")
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white),
              margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Image.asset(
                      "images/ic_loud_speaker.png",
                      width: ScreenUtil().setWidth(100),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        "诸暨市公安局发布电信网络新型犯罪案例" * 3,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(5))),
                      height: ScreenUtil().setHeight(50),
                      width: ScreenUtil().setWidth(10),
                    ),
                  ],
                ),
              ),
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        HomeCardWithIcon(
                          "安全管家",
                          "SecurityManager",
                          "images/ic_safe_manager.png",
                          false,
                        ),
                        HomeCardWithIcon(
                          "智慧物业",
                          "Intelligent Property",
                          "images/ic_intelli_prop.png",
                          true,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        HomeCardWithIcon(
                          "共建共享",
                          "Co-Construction",
                          "images/ic_co_construction.png",
                          false,
                        ),
                        HomeCardWithIcon(
                          "商业服务",
                          "Business Service",
                          "images/ic_business_service.png",
                          true,
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                    child: Container(
                  width: ScreenUtil().setWidth(266),
                  height: ScreenUtil().setWidth(266),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                )),
                Positioned(
                    child: Container(
                  width: ScreenUtil().setWidth(220),
                  height: ScreenUtil().setWidth(220),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                )),
                Positioned(
                    child: Container(
                  width: ScreenUtil().setWidth(180),
                  height: ScreenUtil().setWidth(180),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                )),
                Positioned(
                    child: Container(
                  width: ScreenUtil().setWidth(120),
                  height: ScreenUtil().setWidth(120),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                )),
                Positioned(
                    child: Image.asset(
                  "images/ic_mic.png",
                  width: ScreenUtil().setWidth(77),
                )),
              ],
            ),
            Divider(),
            HomeTitleSliver(
              mainTitle: "安全管家",
              subTitle: "Security Manager",
              onPressed: () {},
            ),
            Material(
              type: MaterialType.card,
              elevation: 1,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setHeight(58),
                  horizontal: ScreenUtil().setWidth(58),
                ),
                color: Colors.white,
                child: Wrap(
                  children: <Widget>[
                    HomeChip(color: const Color(0xFF000078), title: "网上警署"),
                    HomeChip(title: "暨阳警方"),
                    HomeChip(title: "网上办事"),
                    HomeChip(title: "违法举报"),
                    HomeChip(title: "小区保安"),
                    HomeChip(title: "纠纷化解"),
                    HomeChip(title: "视频监控"),
                    HomeChip(title: "巡更管理"),
                    Container(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: list1.map((s) {
                            return Text(
                              s,
                              style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                            );
                          }).toList(),
                        ),
                        Image.asset(
                          "images/ic_safe_manager.png",
                          color: Colors.blue[300],
                          width: ScreenUtil().setWidth(185),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            HomeTitleSliver(
              indicatorColor: const Color(0xFF16A702),
              mainTitle: "智慧物业",
              subTitle: "Intelligent Property",
              onPressed: () {},
            ),
            Material(
              type: MaterialType.card,
              elevation: 1,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setHeight(58),
                  horizontal: ScreenUtil().setWidth(58),
                ),
                color: Colors.white,
                child: Wrap(
                  children: <Widget>[
                    HomeChip(color: const Color(0xFF16A702), title: "通知公告"),
                    HomeChip(title: "访客系统"),
                    HomeChip(title: "在线缴费"),
                    HomeChip(title: "物品寄存"),
                    HomeChip(title: "租房申报"),
                    HomeChip(title: "赞助申报"),
                    HomeChip(title: "车位管理"),
                    HomeChip(title: "消防设施"),
                    Container(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: list2.map((s) {
                            return Text(
                              s,
                              style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                            );
                          }).toList(),
                        ),
                        Image.asset(
                          "images/ic_intelli_prop.png",
                          color: Color(0xFF8BFF87),
                          width: ScreenUtil().setWidth(185),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            HomeTitleSliver(
              indicatorColor: const Color(0xFFCD0004),
              mainTitle: "共建共享",
              subTitle: "Co-construction & Sharing",
              onPressed: () {},
            ),
            Material(
              type: MaterialType.card,
              elevation: 1,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setHeight(58),
                  horizontal: ScreenUtil().setWidth(58),
                ),
                color: Colors.white,
                child: Wrap(
                  children: <Widget>[
                    HomeChip(color: const Color(0xFFCD0004), title: "业主问政"),
                    HomeChip(title: "表扬批评"),
                    HomeChip(title: "邻里互动"),
                    HomeChip(title: "闲置交换"),
                    Container(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: list3.map((s) {
                            return Text(
                              s,
                              style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                            );
                          }).toList(),
                        ),
                        Image.asset(
                          "images/ic_co_construction.png",
                          color: Color(0xFFFEAFB2),
                          width: ScreenUtil().setWidth(185),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            HomeTitleSliver(
              indicatorColor: const Color(0xFFFD6B07),
              mainTitle: "商业服务",
              subTitle: "Business Service",
              onPressed: () {},
            ),
            Material(
              type: MaterialType.card,
              elevation: 1,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setHeight(58),
                  horizontal: ScreenUtil().setWidth(58),
                ),
                color: Colors.white,
                child: Wrap(
                  children: <Widget>[
                    HomeChip(color: const Color(0xFFFD6B07), title: "附近商家"),
                    HomeChip(title: "专业商家"),
                    HomeChip(title: "促销活动"),
                    HomeChip(title: "保安公司"),
                    Container(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: list4.map((s) {
                            return Text(
                              s,
                              style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                            );
                          }).toList(),
                        ),
                        Image.asset(
                          "images/ic_business_service.png",
                          color: const Color(0xFFFEE087),
                          width: ScreenUtil().setWidth(185),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActions(BuildContext context) {
    var applicationBloc = BlocProviders.of<ApplicationBloc>(context);
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
                        applicationBloc.logout();
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
        case 4:
          Navigator.of(context).pushNamed("/contacts");
          break;
      }
    };
    return StreamBuilder<UserInfo>(
      stream: applicationBloc.currentUser,
      builder: (BuildContext context, AsyncSnapshot<UserInfo> snapshot) {
        return PopupMenuButton(
            onSelected: onSelect,
            itemBuilder: (context) {
              return snapshot.hasData && snapshot.data != null
                  ? [
                      PopupMenuItem(
                        child: Text("登出"),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: Text("信息"),
                        value: 3,
                      ),
                      PopupMenuItem(
                        child: Text("推荐给好友"),
                        value: 4,
                      )
                    ]
                  : [
                      PopupMenuItem(
                        child: Text("登录"),
                        value: 2,
                      )
                    ];
            });
      },
    );
  }
}
