import 'package:ease_life/index.dart';
import 'package:ease_life/model/app_info_model.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/main_index_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';
import 'package:oktoast/oktoast.dart';

import 'notification_message_page.dart';
import 'widget/gradient_button.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的"),
        automaticallyImplyLeading: false,
        actions: buildActions(context),
      ),
      body: Consumer4<UserModel, UserVerifyStatusModel, UserRoleModel,
          DistrictModel>(
        builder: (BuildContext context,
            UserModel userModel,
            UserVerifyStatusModel userVerifyStatus,
            UserRoleModel roleModel,
            DistrictModel districtModel,
            Widget child) {
          var isLogin = userModel.isLogin;
          if (!isLogin) {
            return buildVisitor(context);
          }
          return AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: roleModel.currentRole?.isPropertyRole() ?? false
                ? _buildPropertyMine(context, userModel, userVerifyStatus,
                    roleModel, districtModel)
                : _buildCommonMine(context, userModel, userVerifyStatus,
                    roleModel, districtModel),
            switchInCurve: Curves.fastOutSlowIn,
            switchOutCurve: Curves.fastOutSlowIn,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPropertyMine(
    BuildContext context,
    UserModel userModel,
    UserVerifyStatusModel userVerifyStatusModel,
    UserRoleModel roleModel,
    DistrictModel districtModel,
  ) {
    bool isVerified = userVerifyStatusModel.isVerified() ||
        roleModel.currentRole.isPropertyRole();
    String url = userModel.userDetail?.avatar;
    String userName =
        userModel.userName ?? userModel.userDetail?.nickName ?? "";
    return Container(
      color: Colors.grey[100],
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.blueGrey),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Container(
                    height: ScreenUtil().setHeight(420),
                    width: MediaQuery.of(context).size.width,
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      placeholder: "images/banner_home_back.webp",
                      image: districtModel.getDistrictPic(
                        districtModel.getCurrentDistrictIndex(),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setHeight(210), left: 16, right: 16),
                    height: 135,
                    width: MediaQuery.of(context).size.width,
                    child: Material(
                      elevation: 1,
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            EaseIconGradientButton(
                              1,
                              "我的设置",
                              () {
                                showToast("未完成");
                              },
                              Icons.settings,
                            ),
                            EaseIconGradientButton(
                              2,
                              "我的消息",
                              () {
                                Navigator.of(context)
                                    .pushNamed(NotificationMessagePage.routeName);
                              },
                              Icons.message,
                            ),
                            EaseIconGradientButton(
                              3,
                              "我的爱车",
                              () {
                                toWebPage(context, WebIndexID.WO_DE_AI_CHE,
                                    checkFaceVerified: false);
                              },
                              Icons.directions_car,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: ScreenUtil().setHeight(210) - ScreenUtil().setHeight(90),
                    left: 42,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints.tight(Size(
                            ScreenUtil().setHeight(180),
                            ScreenUtil().setHeight(180),
                          )),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[200],
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(width: 2, color: Colors.white),
                          ),
                          child: url != null
                              ? Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          userName,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                isVerified ? Icons.verified_user : Icons.error,
                                color: isVerified ? Colors.green : Colors.red,
                                size: 12,
                              ),
                              Text(
                                "物业人员",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueGrey[400]),
                              borderRadius: BorderRadius.all(Radius.circular(4))),
                          margin: EdgeInsets.only(left: 2),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 24,
              ),
              EaseTile(
                title: "出入记录",
                iconData: Icons.list,
                onPressed: () {
                  toWebPage(context, WebIndexID.CHU_RU_JI_LU,
                      checkFaceVerified: false);
                },
              ),
              EaseTile(
                title: "巡更管理",
                iconData: Icons.map,
                onPressed: () {
                  toWebPage(context, WebIndexID.XUN_GENG_GUAN_LI,
                      checkFaceVerified: false);
                },
              ),
              EaseTile(
                title: "出入记录",
                iconData: Icons.directions_run,
                onPressed: () {
                  toWebPage(context, WebIndexID.CHU_RU_JI_LU,
                      checkFaceVerified: false);
                },
              ),
              EaseTile(
                title: "访客系统",
                iconData: Icons.group_add,
                onPressed: () {
                  toWebPage(context, WebIndexID.FANG_KE_XI_TONG,
                      checkFaceVerified: false);
                },
              ),
              EaseTile(
                title: "检查更新",
                iconData: Icons.cached,
                onPressed: () {
                  _doCheckUpdate(context);
                },
              ),
              SizedBox(
                height: ScreenUtil().setHeight(16),
              ),
              _buildVersionInfo(),
              SizedBox(
                height: ScreenUtil().setHeight(80),
              ),
              GradientButton(
                Text("登出"),
                onPressed: () async {
                  await doLogout(context);
                },
              ),
              SizedBox(
                height: ScreenUtil().setHeight(700),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommonMine(
    BuildContext context,
    UserModel userModel,
    UserVerifyStatusModel userVerifyStatusModel,
    UserRoleModel roleModel,
    DistrictModel districtModel,
  ) {
    bool isVerified = userVerifyStatusModel.isVerified() ||
        (roleModel.currentRole?.isPropertyRole()??false);
    bool notVerify = userVerifyStatusModel.isNotVerified();
    bool hasHouse = districtModel.hasHouse();
    bool hasCommonPermission = roleModel.hasCommonUserPermission();
    bool hasRecordPermission = roleModel.hasSocietyRecordPermission();
    String verifyStatusDesc = userVerifyStatusModel.verifyStatusDesc;
    String url = userModel.userDetail?.avatar;
    String userName =
        userModel.userName ?? userModel.userDetail?.nickName ?? "";
    return Consumer<MainIndexModel>(
      builder: (BuildContext context, MainIndexModel value, Widget child) {
        return DefaultTextStyle(
          style: TextStyle(color: Colors.grey[800]),
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: ListView(
              key: PageStorageKey("MINE_PAGE"),
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
                          "images/banner_home_back.webp",
                          fit: BoxFit.fill,
                          height: ScreenUtil().setHeight(350),
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
                                  backgroundImage: url != null
                                      ? CachedNetworkImageProvider(url)
                                      : null,
                                )),
                            Icon(
                              isVerified ? Icons.verified_user : Icons.error,
                              color: isVerified ? Colors.green : Colors.red,
                              size: 12,
                            ),
                            Text(
                              '$userName',
                              style: TextStyle(fontSize: 15),
                            ),
                            InkWell(
                              onTap: () {
                                showReAuthDialog(context, notVerify);
                              },
                              child: Container(
                                child: Text(
                                  notVerify ? "未认证" : "重新认证",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                margin: EdgeInsets.only(left: 2),
                              ),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            Icon(
                              isVerified ? Icons.verified_user : Icons.error,
                              color: Colors.grey[400],
                              size: 12,
                            ),
                            Text(
                              '$verifyStatusDesc',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                hasCommonPermission
                    ? Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(top: 12, bottom: 16),
                        margin: EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                toWebPage(context, WebIndexID.WO_DE_FANG_WU,
                                    checkHasHouse: true);
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    "images/ic_home_mine.png",
                                    width: ScreenUtil().setWidth(96),
                                  ),
                                  Text("我的${Strings.roomClass}")
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                toWebPage(
                                    context, WebIndexID.ZHU_SUO_CHENG_YUAN);
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    "images/ic_member_mine.png",
                                    width: ScreenUtil().setWidth(96),
                                  ),
                                  Text("${Strings.roomClass_2}成员")
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                toWebPage(context, WebIndexID.WO_DE_AI_CHE,
                                    checkFaceVerified: false);
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    "images/ic_car_mine.png",
                                    width: ScreenUtil().setWidth(96),
                                  ),
                                  Text("我的爱车")
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                hasCommonPermission
                    ? HomeTitleSliver(
                        leadingIcon: Image.asset('images/ic_qrcode_mini.png',
                            width: ScreenUtil().setWidth(50)),
                        mainTitle: "家庭通行码",
                        onPressed: () {
                          toWebPage(context, WebIndexID.JIA_TING_TONG_XING_MA,
                              checkHasHouse: true);
                        },
                        notTitle: true,
                      )
                    : Container(),
                SizedBox(
                  height: 12,
                ),
                hasHouse
                    ? Container()
                    : HomeTitleSliver(
                        leadingIcon: Icon(
                          Icons.format_list_bulleted,
                          size: ScreenUtil().setWidth(56),
                          color: Color(0xff00007c),
                        ),
                        notTitle: true,
                        onPressed: () {
                          toWebPage(context, WebIndexID.SHEN_QING_JI_LU,
                              checkFaceVerified: false);
                        },
                        mainTitle: "历史申请记录",
                      ),
                !hasHouse
                    ? SizedBox(
                        height: 12,
                      )
                    : Container(),
                HomeTitleSliver(
                  leadingIcon: Icon(
                    Icons.history,
                    size: ScreenUtil().setWidth(56),
                    color: Color(0xff00007c),
                  ),
                  notTitle: true,
                  mainTitle: "历史消息",
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(NotificationMessagePage.routeName);
                  },
                ),
                SizedBox(
                  height: 12,
                ),
                HomeTitleSliver(
                  leadingIcon: Image.asset('images/ic_face_id.png',
                      width: ScreenUtil().setWidth(50)),
                  mainTitle: "出入记录",
                  notTitle: true,
                  onPressed: () {
                    toWebPage(context, WebIndexID.CHU_RU_JI_LU,
                        checkHasHouse: true);
                  },
                ),
                hasRecordPermission
                    ? HomeTitleSliver(
                        leadingIcon: Container(
                          height: ScreenUtil().setHeight(70),
                          width: ScreenUtil().setWidth(10),
                          color: Color(0xff00007c),
                        ),
                        mainTitle: "社区记录",
                        subTitle: "Society Records",
                        tailText: "更多",
                      )
                    : Container(),
                hasRecordPermission
                    ? Material(
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
                              const HomeChip(
                                color: const Color(0xff00007c),
                                title: "访客记录",
                                indexId: WebIndexID.FANG_KE_JI_LU,
                              ),
                              const HomeChip(
                                title: "巡逻记录",
                                indexId: WebIndexID.XUN_LUO_JI_LU,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Platform.isAndroid
                        ? Expanded(
                            child: EaseIconButton(
                            onPressed: () {
                              _doCheckUpdate(context);
                            },
                            iconData: Icons.cached,
                            buttonLabel: "检查更新",
                            iconColor: Colors.green,
                          ))
                        : Container(),
                    Expanded(
                      child: EaseIconButton(
                        onPressed: () {
                          doLogout(context);
                        },
                        buttonLabel: "退出登录",
                        iconData: Icons.exit_to_app,
                        iconColor: Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                _buildVersionInfo(),
                SizedBox(
                  height: 80,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _doCheckUpdate(BuildContext context) {
    FlutterBugly.checkUpgrade().then((_) {
      return FlutterBugly.getUpgradeInfo();
    }).then((info) {
      print('$info');
      PackageInfo.fromPlatform().then((packageInfo) {
        if (info != null &&
            int.parse(packageInfo.buildNumber) < info.versionCode) {
          showUpdateDialog(context, info);
        } else {
          showToast("已经是最新版本");
        }
      });
    });
  }

  Consumer<AppInfoModel> _buildVersionInfo() {
    return Consumer<AppInfoModel>(
      builder: (BuildContext context, AppInfoModel value, Widget child) {
        return Center(
          child: Text(
            value.appInfoString,
            style: Theme.of(context).textTheme.caption,
          ),
        );
      },
    );
  }

  Future doLogout(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("退出"),
            content: Text("确定退出安心居吗?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("取消")),
              FlatButton(
                  onPressed: () {
                    if (Navigator.of(context).pop()) {
                      UserModel.of(context).logout(context);
                    }
                  },
                  child: Text("退出")),
            ],
          );
        });
  }

  void showReAuthDialog(BuildContext context, bool notVerify) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: <Widget>[
                Icon(
                  Icons.warning,
                  color: Colors.blue,
                ),
                Text(notVerify ? "认证" : "重新认证")
              ],
            ),
            content: Text(notVerify
                ? "前往认证个人信息,身份证信息填写后不可修改,请谨慎操作"
                : "重新认证个人信息将会覆盖已认证信息,请谨慎操作!"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "取消",
                    style: TextStyle(color: Colors.blueGrey),
                  )),
              FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(UserDetailAuthPage.routeName);
                },
                child: Text(notVerify ? "认证" : "重新认证"),
              ),
            ],
          );
        });
  }

  ///动作条
  buildActions(BuildContext context) {
    return <Widget>[
      DistrictInfoButton(),
      Consumer<UserRoleModel>(
        builder: (BuildContext context, UserRoleModel roleModel, Widget child) {
          return roleModel.hasSwitch
              ? FlatButton.icon(
                  icon: Icon(
                    Icons.repeat,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    roleModel.switchRole();
                  },
                  label: Text("${roleModel.switchString}"),
                )
              : Container();
        },
      ),
    ];
  }
}
