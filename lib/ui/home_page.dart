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

  var topIndex = 0;

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
        child: CustomScrollView(
          key: PageStorageKey("home_body"),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: ScreenUtil().setWidth(690),
                      color: Colors.white,
                      child: PageView.builder(
                        onPageChanged: (index) {
                          setState(() {
                            topIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              Image.asset(
                                "images/banner_home.jpg",
                                fit: BoxFit.fill,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                              width: ScreenUtil().setWidth(100),
                                              height:
                                                  ScreenUtil().setWidth(100),
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
                                              height:
                                                  ScreenUtil().setWidth(100),
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
                                              height:
                                                  ScreenUtil().setWidth(100),
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
                                              height:
                                                  ScreenUtil().setWidth(100),
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
                            ],
                          );
                        },
                        itemCount: 4,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.white,
                      child: IntrinsicWidth(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: buildPagerIndicator(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                margin:
                    EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '社\n区\n头\n条',
                          style: TextStyle(
                            color: Color(0xff00007c),
                            fontWeight: FontWeight.w800
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.blueAccent,
                        height: ScreenUtil().setHeight(225),
                        width: ScreenUtil().setWidth(1),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      "物业通知",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xff09aa00),
                                      borderRadius: BorderRadius.all(Radius.circular(8))
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "物业费用缴纳通知——本季度物业费用可缴纳...",
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      "暨阳警方",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color: Color(0xff00007c),
                                        borderRadius: BorderRadius.all(Radius.circular(8))
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "扫黑除恶丨关于深入开展扫黑除恶专项斗争的通知",style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      "功德榜",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color: Color(0xffd00000),
                                        borderRadius: BorderRadius.all(Radius.circular(8))
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "热心社区公益，好人张大妈热心助人" ,style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      "业主问政",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color: Color(0xffd00000),
                                        borderRadius: BorderRadius.all(Radius.circular(8))
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "业主1：三、四号楼外墙渗水，希望能尽快处理" * 3,style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.grey,
                        height: ScreenUtil().setHeight(225),
                        width: ScreenUtil().setWidth(1),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              "images/ic_loud_speaker.png",
                              width: ScreenUtil().setWidth(100),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              child: Text("更多..",style: TextStyle(fontSize: 11),),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
//            SliverToBoxAdapter(
//              child: Stack(
//                alignment: AlignmentDirectional.center,
//                children: <Widget>[
//                  Column(
//                    children: <Widget>[
//                      Row(
//                        mainAxisSize: MainAxisSize.max,
//                        children: <Widget>[
//                          HomeCardWithIcon(
//                            "安全管家",
//                            "SecurityManager",
//                            "images/ic_safe_manager.png",
//                            false,
//                          ),
//                          HomeCardWithIcon(
//                            "智慧物业",
//                            "Intelligent Property",
//                            "images/ic_intelli_prop.png",
//                            true,
//                          ),
//                        ],
//                      ),
//                      Row(
//                        mainAxisSize: MainAxisSize.max,
//                        children: <Widget>[
//                          HomeCardWithIcon(
//                            "共建共享",
//                            "Co-Construction",
//                            "images/ic_co_construction.png",
//                            false,
//                          ),
//                          HomeCardWithIcon(
//                            "商业服务",
//                            "Business Service",
//                            "images/ic_business_service.png",
//                            true,
//                          ),
//                        ],
//                      ),
//                    ],
//                  ),
//                  Positioned(
//                      child: Container(
//                    width: ScreenUtil().setWidth(266),
//                    height: ScreenUtil().setWidth(266),
//                    decoration: BoxDecoration(
//                      shape: BoxShape.circle,
//                      color: Colors.grey[200],
//                    ),
//                  )),
//                  Positioned(
//                      child: Container(
//                    width: ScreenUtil().setWidth(220),
//                    height: ScreenUtil().setWidth(220),
//                    decoration: BoxDecoration(
//                      shape: BoxShape.circle,
//                      color: Colors.white,
//                    ),
//                  )),
//                  Positioned(
//                      child: Container(
//                    width: ScreenUtil().setWidth(180),
//                    height: ScreenUtil().setWidth(180),
//                    decoration: BoxDecoration(
//                      shape: BoxShape.circle,
//                      color: Colors.grey[200],
//                    ),
//                  )),
//                  Positioned(
//                      child: Container(
//                    width: ScreenUtil().setWidth(120),
//                    height: ScreenUtil().setWidth(120),
//                    decoration: BoxDecoration(
//                      shape: BoxShape.circle,
//                      color: Colors.white,
//                    ),
//                  )),
//                  Positioned(
//                      child: Image.asset(
//                    "images/ic_mic.png",
//                    width: ScreenUtil().setWidth(77),
//                  )),
//                ],
//              ),
//            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Image.asset('images/ic_video.png',height: ScreenUtil().setHeight(86),width: ScreenUtil().setWidth(67),),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text("视频监控"),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Image.asset('images/ic_mic.png',color:Color(0xff00006e),height: ScreenUtil().setHeight(88),width: ScreenUtil().setWidth(62),),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text("视频监控"),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Image.asset('images/ic_co_construction.png',height: ScreenUtil().setHeight(89),width: ScreenUtil().setWidth(89),),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Container(child: Text("视频监控")),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
//            SliverToBoxAdapter(child: Divider()),

            SliverToBoxAdapter(
              child: HomeTitleSliver(
                indicatorColor: const Color(0xFF16A702),
                mainTitle: "智慧物业",
                subTitle: "Intelligent Property",
                onPressed: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: Material(
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
                      HomeChip(title: "车位管理"),
                      HomeChip(title: "暂住申报"),
//                      Container(
//                        height: 12,
//                      ),
//                      Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: <Widget>[
//                          Column(
//                            mainAxisAlignment: MainAxisAlignment.start,
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            children: list2.map((s) {
//                              return Text(
//                                s,
//                                style:
//                                    TextStyle(fontSize: ScreenUtil().setSp(30)),
//                              );
//                            }).toList(),
//                          ),
//                          Image.asset(
//                            "images/ic_intelli_prop.png",
//                            color: Color(0xFF8BFF87),
//                            width: ScreenUtil().setWidth(185),
//                          ),
//                        ],
//                      )
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: HomeTitleSliver(
                indicatorColor: const Color(0xFFFD6B07),
                mainTitle: "商业服务",
                subTitle: "Business Service",
                onPressed: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: Material(
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
                      HomeChip(title: "加盟商家"),
                      HomeChip(title: "促销活动"),
                      HomeChip(title: "保安公司"),
//                      Container(
//                        height: 12,
//                      ),
//                      Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: <Widget>[
//                          Column(
//                            mainAxisAlignment: MainAxisAlignment.start,
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            children: list4.map((s) {
//                              return Text(
//                                s,
//                                style:
//                                    TextStyle(fontSize: ScreenUtil().setSp(30)),
//                              );
//                            }).toList(),
//                          ),
//                          Image.asset(
//                            "images/ic_business_service.png",
//                            color: const Color(0xFFFEE087),
//                            width: ScreenUtil().setWidth(185),
//                          ),
//                        ],
//                      )
                    ],
                  ),
                ),
              ),
            ),




            SliverToBoxAdapter(
              child: HomeTitleSliver(
                mainTitle: "安全管家",
                subTitle: "Security Manager",
                onPressed: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: Material(
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
                      HomeChip(color: const Color(0xFF000078), title: "网上110"),
                      HomeChip(title: "暨阳警方"),
                      HomeChip(title: "越警管家"),
                      HomeChip(title: "警务查询"),
                      HomeChip(title: "便民地图"),
                      HomeChip(title: "巡更管理"),
                      HomeChip(title: "纠纷化解"),
//                      Container(
//                        height: 12,
//                      ),
//                      Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: <Widget>[
//                          Column(
//                            mainAxisAlignment: MainAxisAlignment.start,
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            children: list1.map((s) {
//                              return Text(
//                                s,
//                                style:
//                                    TextStyle(fontSize: ScreenUtil().setSp(30)),
//                              );
//                            }).toList(),
//                          ),
//                          Image.asset(
//                            "images/ic_safe_manager.png",
//                            color: Colors.blue[300],
//                            width: ScreenUtil().setWidth(185),
//                          ),
//                        ],
//                      )
                    ],
                  ),
                ),
              ),
            ),


            SliverToBoxAdapter(
              child: HomeTitleSliver(
                indicatorColor: const Color(0xFFCD0004),
                mainTitle: "共建共享",
                subTitle: "Co-construction & Sharing",
                onPressed: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: Material(
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
                      HomeChip(title: "功德栏"),
                      HomeChip(title: "义警活动"),
                      HomeChip(title: "闲置交换"),
                      HomeChip(title: "慈善公益"),
                      HomeChip(title: "小区活动"),
//                      Container(
//                        height: 12,
//                      ),
//                      Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: <Widget>[
//                          Column(
//                            mainAxisAlignment: MainAxisAlignment.start,
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            children: list3.map((s) {
//                              return Text(
//                                s,
//                                style:
//                                    TextStyle(fontSize: ScreenUtil().setSp(30)),
//                              );
//                            }).toList(),
//                          ),
//                          Image.asset(
//                            "images/ic_co_construction.png",
//                            color: Color(0xFFFEAFB2),
//                            width: ScreenUtil().setWidth(185),
//                          ),
//                        ],
//                      )
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildPagerIndicator() {
    return [0, 1, 2, 3].map((index) {
      bool current = index == topIndex;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 3),
        width: current ? 14 : 8,
        height: 4,
        decoration: BoxDecoration(
            color: current ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(4))),
      );
    }).toList();
  }

  Widget buildActions(BuildContext context) {
    var applicationBloc = BlocProviders.of<ApplicationBloc>(context);
    Function onSelect = (value) {
      switch (value) {
        case HomeAction.LOGOUT:
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
        case HomeAction.LOGIN:
          Navigator.of(context).pushNamed("/login");
          break;
        case HomeAction.INFO:
          Navigator.of(context).pushNamed("/personal");
          break;
        case HomeAction.RECOMMEND:
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
                        value: HomeAction.LOGOUT,
                      ),
                      PopupMenuItem(
                        child: Text("信息"),
                        value: HomeAction.INFO,
                      ),
                      PopupMenuItem(
                        child: Text("推荐给好友"),
                        value: HomeAction.RECOMMEND,
                      )
                    ]
                  : [
                      PopupMenuItem(
                        child: Text("登录"),
                        value: HomeAction.LOGIN,
                      )
                    ];
            });
      },
    );
  }
}
enum HomeAction{
  LOGOUT,LOGIN,INFO,RECOMMEND
}
