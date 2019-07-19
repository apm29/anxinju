import 'package:ease_life/index.dart';
import 'package:ease_life/model/announcement_model.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';

import 'dispute_mediation_list_page.dart';
import 'dispute_mediation_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: ListView(
          key: PageStorageKey("HOME_PAGE"),
          physics: AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            Container(
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
                                        "${value.getCurrentDistrictName(ifError: "")}${Strings.appName}服务平台\n共建共享我们的家园",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            EaseIconButton(
                              onPressed: () {
                                toWebPage(
                                  context,
                                  WebIndexID.FANG_KE_GUAN_LI,
                                  checkHasHouse: true,
                                );
                              },
                              assetImageUrl: "images/ic_visitor_manager.png",
                              buttonLabel: "访客管理",
                            ),
                            EaseIconButton(
                              onPressed: () {
                                toWebPage(context, WebIndexID.ZHAO_WU_YE);
                              },
                              assetImageUrl: "images/ic_property_manager.png",
                              buttonLabel: "找物业",
                            ),
                            EaseIconButton(
                              onPressed: () {
                                toWebPage(context, WebIndexID.ZHAO_SHE_QU);
                              },
                              assetImageUrl: "images/ic_society_manage.png",
                              buttonLabel: "找社区",
                            ),
                            EaseIconButton(
                              onPressed: () {
                                toWebPage(context, WebIndexID.ZHAO_JING_CHA);
                              },
                              assetImageUrl: "images/ic_police_manage.png",
                              buttonLabel: "找警察",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
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
                            AnnouncementModel announcementModel, Widget child) {
                          if (announcementModel.announcements == null ||
                              announcementModel.announcements.length == 0) {
                            return Center(
                              child: Text(
                                "暂无消息",
                                style: Theme.of(context).textTheme.caption,
                              ),
                            );
                          }
                          return Wrap(
                            children: announcementModel.announcements.map((detail){
                              return Material(
                                color: Colors.white,
                                child: InkWell(
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
                                            style: Theme.of(context).textTheme.caption,
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
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

            HomeTitleSliver(
              indicatorColor: const Color(0xFF16A702),
              mainTitle: "智慧物业",
              subTitle: "Intelligent Property",
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
                    HomeChip(
                      color: const Color(0xFF16A702),
                      title: "通知公告",
                      indexId: WebIndexID.TONG_ZHI_TONG_GAO,
                      checkIsFaceVerified: false,
                    ),
                    HomeChip(
                      title: "访客系统",
                      indexId: WebIndexID.FANG_KE_XI_TONG,
                      checkIsFaceVerified: true,
                      checkHasHouse: true,
                    ),
                    HomeChip(
                      title: "车辆管理",
                      indexId: WebIndexID.CHE_LIANG_GUAN_LI,
                      checkIsFaceVerified: false,
                    ),
                    HomeChip(
                      title: "维护报修",
                      indexId: WebIndexID.WEI_HU_BAO_XIU,
                      checkIsFaceVerified: false,
                    ),
                    HomeChip(
                      title: "便民地图",
                      indexId: WebIndexID.BIAN_MIN_DI_TU,
                      checkIsFaceVerified: false,
                    ),
                    HomeChip(
                      title: "纠纷调解",
                      checkLogin: true,
                      onPressed: () {
                        var userVerifyStatusModel =
                            UserVerifyStatusModel.of(context);
                        var districtModel = DistrictModel.of(context);
                        if (!userVerifyStatusModel.isVerified()) {
                          showFaceVerifyDialog(context);
                          return;
                        }
                        if (!districtModel.hasHouse()) {
                          showApplyHouseDialog(context);
                          return;
                        }
                        Navigator.of(context)
                            .pushNamed(MediationListPage.routeName);
                      },
                    ),
                  ],
                ),
              ),
            ),

//

            HomeTitleSliver(
              mainTitle: "安全管家",
              subTitle: "Security Manager",
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
                    HomeChip(
                      color: const Color(0xFF000078),
                      title: "警务查询",
                      indexId: WebIndexID.JING_WU_CHA_XUN,
                      checkIsFaceVerified: false,
                    ),
                    HomeChip(
                      title: "巡更管理",
                      indexId: WebIndexID.XUN_GENG_GUAN_LI,
                      checkHasHouse: true,
                      checkIsFaceVerified: false,
                    ),
                  ],
                ),
              ),
            ),

            HomeTitleSliver(
              indicatorColor: const Color(0xFFCD0004),
              mainTitle: "共建共享",
              subTitle: "Co-construction & Sharing",
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
                    HomeChip(
                      color: const Color(0xFFCD0004),
                      title: "功德栏",
                      indexId: WebIndexID.GONG_DE_LAN,
                      checkIsFaceVerified: false,
                    ),
                    HomeChip(
                      title: "义警活动",
                      indexId: WebIndexID.YI_JING_HUO_DONG,
                      checkIsFaceVerified: false,
                    ),
                    HomeChip(
                      title: "慈善公益",
                      indexId: WebIndexID.CI_SHAN_GONG_YI,
                      checkIsFaceVerified: false,
                    ),
                    HomeChip(
                      title: "小区活动",
                      indexId: WebIndexID.XIAO_QU_HUO_DONG,
                      checkIsFaceVerified: false,
                    ),
                    HomeChip(
                      title: "闲置交换",
                      indexId: WebIndexID.XIAN_ZHI_JIAO_HUAN,
                      checkIsFaceVerified: false,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}

enum HomeAction { LOGOUT, LOGIN, INFO, RECOMMEND }
