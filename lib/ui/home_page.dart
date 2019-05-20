import 'dart:math';

import 'package:ease_life/index.dart';
import 'package:ease_life/ui/web_view_example.dart';

import '../utils.dart';
import 'contacts_select_page.dart';
import 'login_page.dart';
import 'widget/district_info_button.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var topIndex = 0;

  @override
  Widget build(BuildContext context) {
    print('home rebuild');
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "安心居",
        ),
        actions: <Widget>[
          DistrictInfoButton(),
//          buildActions(context),
        ],
      ),
      body: StreamBuilder<Index>(
          stream: BlocProviders.of<ApplicationBloc>(context).homeIndex,
          builder: (context, snapshot) {
            var indexInfo = snapshot.data;
            if (indexInfo == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return StreamBuilder<UserInfo>(
              stream: BlocProviders.of<ApplicationBloc>(context).currentUser,
              builder: (context, snapshot) {
                UserInfo userInfo = snapshot.data;
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(17)),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      return BlocProviders.of<ApplicationBloc>(context).getIndexInfo();
                    },
                    child: CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
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
                                  color: Colors.white,
                                  child: Column(
                                    children: <Widget>[
                                      Stack(
                                        children: <Widget>[
                                          Image.asset(
                                            "images/banner_home_back.webp",
                                            fit: BoxFit.fill,
                                          ),
                                          Positioned.fill(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Image.asset(
                                                  "images/ic_police.png",
                                                  height: ScreenUtil().setHeight(108),
                                                ),
                                                SizedBox(
                                                  height: 6,
                                                ),
                                                StreamBuilder<DistrictInfo>(
                                                    stream: BlocProviders.of<
                                                            ApplicationBloc>(context)
                                                        .currentDistrict,
                                                    builder: (context, snapshot) {
                                                      return Text(
                                                        "${snapshot.data?.districtName ?? ""}安心居服务平台\n共建共享我们的家园",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18),
                                                      );
                                                    }),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              if(userInfo==null||userInfo.isCertification == 0){
                                                Fluttertoast.showToast(msg: "请先完成业主认证");
                                                return;
                                              }
                                              routeToWeb(context,"fkgl", indexInfo);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: <Widget>[
                                                  SizedBox(
                                                      width:
                                                          ScreenUtil().setWidth(100),
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
                                            onTap: () {
                                              routeToWeb(context,"zwy", indexInfo);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: <Widget>[
                                                  SizedBox(
                                                      width:
                                                          ScreenUtil().setWidth(100),
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
                                            onTap: () {
                                              routeToWeb(context,"zsq", indexInfo);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: <Widget>[
                                                  SizedBox(
                                                      width:
                                                          ScreenUtil().setWidth(100),
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
                                            onTap: () {
                                              routeToWeb(context,"zjc", indexInfo);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: <Widget>[
                                                  SizedBox(
                                                      width:
                                                          ScreenUtil().setWidth(100),
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
                                  ),
                                ),
//                          Container(
//                            padding: EdgeInsets.all(8),
//                            color: Colors.white,
//                            child: IntrinsicWidth(
//                              child: Row(
//                                mainAxisSize: MainAxisSize.min,
//                                children: buildPagerIndicator(),
//                              ),
//                            ),
//                          )
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white),
                            margin: EdgeInsets.symmetric(
                                vertical: ScreenUtil().setHeight(20)),
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
                                          fontWeight: FontWeight.w800),
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
                                    child: StreamBuilder<List<NoticeDetail>>(
                                        stream:
                                            BlocProviders.of<ApplicationBloc>(context)
                                                .homeNoticeStream,
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Container();
                                          }
                                          return Column(
                                            children: snapshot.data.map((detail) {
                                              return GestureDetector(
                                                onTap: (){
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                            return WebViewExample(
                                                                "$BASE_URL#/contentDetails?contentId=${detail.noticeId}");
                                                          }));
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(7.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: 8),
                                                        child: StreamBuilder<
                                                                List<NoticeType>>(
                                                            stream: BlocProviders.of<
                                                                        ApplicationBloc>(
                                                                    context)
                                                                .noticeTypeStream,
                                                            builder:
                                                                (context, snapshot) {
                                                              if (!snapshot.hasData) {
                                                                return Container();
                                                              }
                                                              return Text(
                                                                snapshot.data
                                                                    .firstWhere(
                                                                        (type) {
                                                                  return type
                                                                          .typeId ==
                                                                      detail
                                                                          .noticeType;
                                                                }).typeName,
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 10,
                                                                ),
                                                              );
                                                            }),
                                                        decoration: BoxDecoration(
                                                            color: colors[
                                                                detail.noticeType %
                                                                    colors.length],
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        8))),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          detail.noticeTitle,
                                                          style:
                                                              TextStyle(fontSize: 14),
                                                          textAlign: TextAlign.start,
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
//                      SliverToBoxAdapter(
//                        child: Container(
//                          color: Colors.white,
//                          padding: EdgeInsets.all(12),
//                          child: Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                            children: <Widget>[
//                              GestureDetector(
//                                onTap: () {
//                                  routeToWeb("spjk", indexInfo);
//                                },
//                                child: Column(
//                                  children: <Widget>[
//                                    Image.asset(
//                                      'images/ic_video.png',
//                                      height: ScreenUtil().setHeight(86),
//                                      width: ScreenUtil().setWidth(67),
//                                    ),
//                                    Padding(
//                                      padding: const EdgeInsets.only(top: 8.0),
//                                      child: Text("视频监控"),
//                                    )
//                                  ],
//                                ),
//                              ),
//                              GestureDetector(
//                                onTap: () {
//                                  routeToWeb("jjhj", indexInfo);
//                                },
//                                child: Column(
//                                  children: <Widget>[
//                                    Image.asset(
//                                      'images/ic_mic.png',
//                                      color: Color(0xff00006e),
//                                      height: ScreenUtil().setHeight(88),
//                                      width: ScreenUtil().setWidth(62),
//                                    ),
//                                    Padding(
//                                      padding: const EdgeInsets.only(top: 8.0),
//                                      child: Text("紧急呼救"),
//                                    )
//                                  ],
//                                ),
//                              ),
//                              GestureDetector(
//                                onTap: () {
//                                  routeToWeb("llq", indexInfo);
//                                },
//                                child: Column(
//                                  children: <Widget>[
//                                    Image.asset(
//                                      'images/ic_co_construction.png',
//                                      height: ScreenUtil().setHeight(89),
//                                      width: ScreenUtil().setWidth(89),
//                                    ),
//                                    Padding(
//                                      padding: const EdgeInsets.only(top: 8.0),
//                                      child: Container(child: Text("邻里圈")),
//                                    )
//                                  ],
//                                ),
//                              ),
//                            ],
//                          ),
//                        ),
//                      ),

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
                                  HomeChip(
                                      color: const Color(0xFF16A702),
                                      title: "通知公告",
                                      indexId: "tztg",
                                      index: indexInfo),
                                  HomeChip(
                                      title: "访客系统",
                                      indexId: "fkxt",
                                      index: indexInfo,
                                      intercept:userInfo==null||userInfo.isCertification == 0),
//                                  HomeChip(
//                                      title: "在线缴费",
//                                      indexId: "zxjf",
//                                      index: indexInfo),
                                  HomeChip(
                                      title: "车辆管理",
                                      indexId: "clgl",
                                      index: indexInfo),
                                  HomeChip(
                                      title: "维护报修",
                                      indexId: "whbx",
                                      index: indexInfo),
//                                  HomeChip(
//                                      title: "暂住申报",
//                                      indexId: "zzsb",
//                                      index: indexInfo),
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

//                        SliverToBoxAdapter(
//                          child: HomeTitleSliver(
//                            indicatorColor: const Color(0xFFFD6B07),
//                            mainTitle: "商业服务",
//                            subTitle: "Business Service",
//                            onPressed: () {},
//                          ),
//                        ),
//                        SliverToBoxAdapter(
//                          child: Material(
//                            type: MaterialType.card,
//                            elevation: 1,
//                            child: Container(
//                              padding: EdgeInsets.symmetric(
//                                vertical: ScreenUtil().setHeight(58),
//                                horizontal: ScreenUtil().setWidth(58),
//                              ),
//                              color: Colors.white,
//                              child: Wrap(
//                                children: <Widget>[
//                                  HomeChip(
//                                      color: const Color(0xFFFD6B07),
//                                      title: "附近商家",
//                                      indexId: "fjsj",
//                                      index: indexInfo),
//                                  HomeChip(
//                                      title: "加盟商家",
//                                      indexId: "jmsj",
//                                      index: indexInfo),
//                                  HomeChip(
//                                      title: "促销活动",
//                                      indexId: "cxhd",
//                                      index: indexInfo),
//                                  HomeChip(
//                                      title: "保安公司",
//                                      indexId: "bags",
//                                      index: indexInfo),
//                                ],
//                              ),
//                            ),
//                          ),
//                        ),

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
//                                  HomeChip(
//                                      color: const Color(0xFF000078),
//                                      title: "网上110",
//                                      indexId: "ws110",
//                                      index: indexInfo),
//                                  HomeChip(
//                                      title: "暨阳警方",
//                                      indexId: "jyjf",
//                                      index: indexInfo),
//                                  HomeChip(
//                                      title: "越警管家",
//                                      indexId: "yjgj",
//                                      index: indexInfo),
                                  HomeChip(
                                      color: const Color(0xFF000078),
                                      title: "警务查询",
                                      indexId: "jwcx",
                                      index: indexInfo),
//                                  HomeChip(
//                                      title: "便民地图",
//                                      indexId: "bmdt",
//                                      index: indexInfo),
                                  HomeChip(
                                      title: "巡更管理",
                                      indexId: "xggl",
                                      index: indexInfo),
//                                  HomeChip(
//                                      title: "纠纷化解",
//                                      indexId: "jfhj",
//                                      index: indexInfo),
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
//                                  HomeChip(
//                                      color: const Color(0xFFCD0004),
//                                      title: "业主问政",
//                                      indexId: "yzwz",
//                                      index: indexInfo),
                                  HomeChip(
                                      color: const Color(0xFFCD0004),
                                      title: "功德栏", indexId: "gdl", index: indexInfo),
                                  HomeChip(
                                      title: "义警活动",
                                      indexId: "yjhd",
                                      index: indexInfo),
//                                  HomeChip(
//                                      title: "闲置交换",
//                                      indexId: "xzjh",
//                                      index: indexInfo),
                                  HomeChip(
                                      title: "慈善公益",
                                      indexId: "csgy",
                                      index: indexInfo),
                                  HomeChip(
                                      title: "小区活动",
                                      indexId: "xqhd",
                                      index: indexInfo),
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
            );
          }),
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
          Navigator.of(context).pushNamed(LoginPage.routeName);
          break;
        case HomeAction.INFO:
          Navigator.of(context).pushNamed("/personal");
          break;
        case HomeAction.RECOMMEND:
          Navigator.of(context).pushNamed(ContactsSelectPage.routeName);
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

enum HomeAction { LOGOUT, LOGIN, INFO, RECOMMEND }
