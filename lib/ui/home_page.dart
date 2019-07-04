import 'package:ease_life/index.dart';
import 'package:ease_life/model/announcement_model.dart';
import 'package:ease_life/model/district_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  var topIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  GlobalKey<ScaffoldState> homeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeKey,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          Strings.appName,
        ),
        actions: <Widget>[
          DistrictInfoButton(),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(17)),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      "images/ic_police.png",
                                      height: ScreenUtil().setHeight(108),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Consumer<DistrictModel>(
                                      builder: (BuildContext context,
                                          DistrictModel value, Widget child) {
                                        return Text(
                                          "${value.currentDistrict?.districtName ?? ""}${Strings.appName}服务平台\n共建共享我们的家园",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  toWebPage(
                                      context, WebIndexID.FANG_KE_GUAN_LI);
                                },
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
                                onTap: () {
                                  toWebPage(context, WebIndexID.ZHAO_WU_YE);
                                },
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
                                onTap: () {
                                  toWebPage(context, WebIndexID.ZHAO_SHE_QU);
                                },
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
                                onTap: () {
                                  toWebPage(context, WebIndexID.ZHAO_JING_CHA);
                                },
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
                        ],
                      ),
                    ),
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
                        child: Consumer<AnnouncementModel>(
                          builder: (BuildContext context,
                              AnnouncementModel announcementModel,
                              Widget child) {
                            return Column(
                              children:
                                  announcementModel.announcements.map((detail) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
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
                                          child: Text(
                                            announcementModel
                                                .typeTitleByDetail(detail),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                              color: colors[detail.noticeType %
                                                  colors.length],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            detail.noticeTitle,
                                            style: TextStyle(fontSize: 14),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

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
                        indexId: WebIndexID.TONG_ZHI_TONG_GAO,
                      ),
                      HomeChip(
                        title: "访客系统",
                        indexId: WebIndexID.FANG_KE_XI_TONG,
                        checkIsFaceVerified: true,
                        checkHasHouse: true,
                      ),
//                                  HomeChip(
//                                      title: "在线缴费",
//                                      indexId: "zxjf",
//                                      index: indexInfo),
                      HomeChip(
                        title: "车辆管理",
                        indexId: WebIndexID.CHE_LIANG_GUAN_LI,
                        checkIsFaceVerified: true,
                      ),
                      HomeChip(
                        title: "维护报修",
                        indexId: WebIndexID.WEI_HU_BAO_XIU,
                        checkIsFaceVerified: true,
                      ),
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
                        indexId: WebIndexID.JING_WU_CHA_XUN,
                      ),
//                                  HomeChip(
//                                      title: "便民地图",
//                                      indexId: "bmdt",
//                                      index: indexInfo),
                      HomeChip(
                        title: "巡更管理",
                        indexId: WebIndexID.XUN_GENG_GUAN_LI,
                      ),
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
                        title: "功德栏",
                        indexId: WebIndexID.GONG_DE_LAN,
                      ),
                      HomeChip(
                        title: "义警活动",
                        indexId: WebIndexID.YI_JING_HUO_DONG,
                      ),
//                                  HomeChip(
//                                      title: "闲置交换",
//                                      indexId: "xzjh",
//                                      index: indexInfo),
                      HomeChip(
                        title: "慈善公益",
                        indexId: WebIndexID.CI_SHAN_GONG_YI,
                      ),
                      HomeChip(
                          title: "小区活动", indexId: WebIndexID.XIAO_QU_HUO_DONG),
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
}

enum HomeAction { LOGOUT, LOGIN, INFO, RECOMMEND }
