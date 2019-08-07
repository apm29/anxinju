import 'package:ease_life/index.dart';
import 'package:ease_life/model/announcement_model.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/service_chat_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';
import 'package:ease_life/ui/service_chat_page.dart';
import 'package:ease_life/ui/video_nineoneone_page.dart';
import 'dispute_mediation_list_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel roleModel, Widget child) {
        final isOnPropertyDuty = roleModel.isOnPropertyDuty;
        return Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            centerTitle: false,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Consumer<ServiceChatModel>(
              builder:
                  (BuildContext context, ServiceChatModel value, Widget child) {
                return Text(
                  isOnPropertyDuty
                      ? value.currentChatUser != null
                          ? "正在与${value.currentChatUser.userNickName}交谈"
                          : "当前无人连接客服"
                      : Strings.appName,
                );
              },
            ),
            actions: <Widget>[
              buildRoleSwitchButton(),
            ],
          ),
          body: AnimatedSwitcher(
            child: isOnPropertyDuty
                ? _buildPropertyUser()
                : _buildCommonUserHome(context),
            duration: Duration(seconds: 1),
            switchInCurve: Curves.fastOutSlowIn,
            switchOutCurve: Curves.fastOutSlowIn,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPropertyUser() {
    return ServiceChatPage();
  }

  Widget _buildCommonUserHome(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(17)),
      color: Colors.grey[200],
      child: ListView(
        key: PageStorageKey("HOME_PAGE"),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Material(
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
            margin: EdgeInsets.only(top: 12),
            child: Material(
              elevation: 0,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Platform.isIOS
                      ? Container()
                      : EaseIconButton(
                          onPressed: () {
                            _go911(context);
                          },
                          iconData: Icons.video_call,
                          buttonLabel: "视频报警",
                        ),
                  Consumer<UserModel>(
                    builder: (BuildContext context, UserModel userModel,
                        Widget child) {
                      return Offstage(
                        offstage: !userModel.isLogin ||
                            userModel.isOnPropertyDuty,
                        child: EaseIconButton(
                          onPressed: () {
                            _goEmergencyCall(context);
                          },
                          iconData: Icons.call,
                          buttonLabel: "紧急呼叫",
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white),
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
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
                        return Column(
                          children:
                              announcementModel.announcements.map((detail) {
                            return _buildAnnouncementTile(
                                context, detail, announcementModel);
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
                  const HomeChip(
                    color: const Color(0xFF16A702),
                    title: "通知公告",
                    indexId: WebIndexID.TONG_ZHI_TONG_GAO,
                    checkIsFaceVerified: false,
                  ),
                  const HomeChip(
                    title: "访客管理",
                    indexId: WebIndexID.FANG_KE_XI_TONG,
                    checkIsFaceVerified: true,
                    checkHasHouse: true,
                  ),
                  const HomeChip(
                    title: "车辆管理",
                    indexId: WebIndexID.CHE_LIANG_GUAN_LI,
                    checkIsFaceVerified: false,
                  ),
                  const HomeChip(
                    title: "维护报修",
                    indexId: WebIndexID.WEI_HU_BAO_XIU,
                    checkIsFaceVerified: false,
                  ),
                  const HomeChip(
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
                  const HomeChip(
                    color: const Color(0xFF000078),
                    title: "警务查询",
                    indexId: WebIndexID.JING_WU_CHA_XUN,
                    checkIsFaceVerified: false,
                  ),
                  Platform.isIOS
                      ? Container()
                      : const HomeChip(
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
                  const HomeChip(
                    color: const Color(0xFFCD0004),
                    title: "公德栏",
                    indexId: WebIndexID.GONG_DE_LAN,
                    checkIsFaceVerified: false,
                  ),
                  const HomeChip(
                    title: "义警活动",
                    indexId: WebIndexID.YI_JING_HUO_DONG,
                    checkIsFaceVerified: false,
                  ),
                  const HomeChip(
                    title: "慈善公益",
                    indexId: WebIndexID.CI_SHAN_GONG_YI,
                    checkIsFaceVerified: false,
                  ),
                  const HomeChip(
                    title: "小区活动",
                    indexId: WebIndexID.XIAO_QU_HUO_DONG,
                    checkIsFaceVerified: false,
                  ),
                  HomeChip(
                    title: "闲置交换",
                    indexId: WebIndexID.XIAN_ZHI_JIAO_HUAN,
                    checkIsFaceVerified: false,
                  ),
                  HomeChip(
                    title: "业主问政",
                    indexId: WebIndexID.YE_ZHU_WEN_ZHENG,
                    checkHasHouse: false,
                  ),
                  HomeChip(
                    title: "邻里圈",
                    indexId: WebIndexID.LIN_LI_QUAN,
                    checkHasHouse: false,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 80,
          ),
        ],
      ),
    );
  }

  void _go911(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提醒"),
            content: Text("该功能只作为模拟视频报警使用"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "点错了",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(VideoNineOneOnePage.routeName);
                },
                child: Text("继续前往"),
              ),
            ],
          );
        });
  }

  void _goEmergencyCall(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("警告 ⚠️"),
            content: Text.rich(
              TextSpan(
                  text: "本功能适用于遇到偷窃、火灾等紧急情况时联系小区安保人员，不可随意使用",
                  children: [
                    //TextSpan(
                    //  text: "法律条款",
                    //  recognizer: TapGestureRecognizer()
                    //    ..onTap = () {
                    //      //showToast("暂未添加");
                    //      toWebPage(context, "fltk",
                    //          checkHasHouse: false, checkFaceVerified: false);
                    //    },
                    //  style: TextStyle(
                    //    color: Colors.blue,
                    //  ),
                    //)
                  ],
                  style: TextStyle(
                    fontSize: 13,
                  )),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "点错了",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
              FlatButton(
                onPressed: () {
//                  Navigator.of(context).pushReplacementNamed(
//                    EmergencyCallPage.routeName,
//                    //arguments: {"group": "25", "title": "紧急呼叫"},
//                    arguments: {"group": "25", "title": "紧急呼叫"},
//                  );
                  Navigator.of(context).pushReplacement(
                    new MaterialPageRoute(
                      builder: (context) {
                        return EmergencyCallPage2("25", "紧急呼叫");
                      },
                    ),
                  );
                },
                child: Text("确认使用"),
              ),
            ],
          );
        });
  }

  Material _buildAnnouncementTile(BuildContext context, Announcement detail,
      AnnouncementModel announcementModel) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return WebViewExample(
                  "$BASE_URL#/contentDetails?contentId=${detail.noticeId}",
                );
              },
            ),
          );
          SystemSound.play(SystemSoundType.click);
        },
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  announcementModel.typeTitleByDetail(detail),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
                decoration: BoxDecoration(
                  color: colors[detail.noticeType % colors.length],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
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
  }
}

enum HomeAction { LOGOUT, LOGIN, INFO, RECOMMEND }
