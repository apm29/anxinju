import 'package:ease_life/index.dart';
import 'package:ease_life/model/main_index_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';

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
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: buildActions(context),
      ),
      body: Consumer3<UserModel, UserVerifyStatusModel, UserRoleModel>(
        builder: (BuildContext context,
            UserModel userModel,
            UserVerifyStatusModel userVerifyStatus,
            UserRoleModel roleModel,
            Widget child) {
          if (!userModel.isLogin) {
            return buildVisitor(context);
          } else if (userVerifyStatus.isVerified()) {
            return _buildMine(context, userModel, userVerifyStatus, roleModel);
          } else if (!userVerifyStatus.isVerified()) {
            return _buildUnauthorized(
                context, userModel, userVerifyStatus, roleModel);
          } else {
            return buildVisitor(context);
          }
        },
      ),
    );
  }

  Widget _buildMine(BuildContext context, UserModel userModel,
      UserVerifyStatusModel userVerifyStatus, UserRoleModel roleModel) {
    bool isVerified = userVerifyStatus.isVerified();
    bool hasHouse = userVerifyStatus.hasHouse();
    bool hasCommonPermission = roleModel.hasCommonUserPermission();
    bool hasRecordPermission = roleModel.hasSocietyRecordPermission();
    return Consumer<MainIndexModel>(
      builder: (BuildContext context, MainIndexModel value, Widget child) {
        String url = userModel.userDetail?.avatar;
        String userName = userModel.userDetail?.nickName??userModel.userName??"";
        return DefaultTextStyle(
          style: TextStyle(color: Colors.grey[800]),
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
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
                              isVerified
                                  ? Icons.verified_user
                                  : Icons.error,
                              color:
                              isVerified ? Colors.green : Colors.red,
                              size: 12,
                            ),
                            Text(
                              '$userName',
                              style: TextStyle(fontSize: 15),
                            ),
                            InkWell(
                              onTap: () {
                                showReAuthDialog(context);
                              },
                              child: Container(
                                child: Text(
                                  "重新认证",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                padding:
                                EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                    border:
                                    Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(4))),
                                margin: EdgeInsets.only(left: 2),
                              ),
                            )
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
                                toWebPage(context, WebIndexID.WO_DE_AI_CHE);
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
                    ? GestureDetector(
                        onTap: () {
                          toWebPage(context, WebIndexID.JIA_TING_TONG_XING_MA,
                              checkHasHouse: true);
                        },
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.only(left: 15),
                          child: HomeTitleSliver(
                            leadingIcon: Image.asset(
                                'images/ic_qrcode_mini.png',
                                width: ScreenUtil().setWidth(50)),
                            mainTitle: "家庭通行码",
                            subTitle: "",
                            tailText: "",
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 12,
                ),
                hasHouse
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          toWebPage(context, WebIndexID.SHEN_QING_JI_LU);
                        },
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.only(left: 15),
                          child: HomeTitleSliver(
                            leadingIcon: Icon(
                              Icons.format_list_bulleted,
                              size: ScreenUtil().setWidth(56),
                              color: Color(0xff00007c),
                            ),
                            mainTitle: "历史申请记录",
                            subTitle: "",
                            tailText: "",
                          ),
                        ),
                      ),
                !hasHouse
                    ? SizedBox(
                        height: 12,
                      )
                    : Container(),
                GestureDetector(
                  onTap: () {
                    toWebPage(context, WebIndexID.CHU_RU_JI_LU,
                        checkHasHouse: true);
                  },
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 15),
                    child: HomeTitleSliver(
                      leadingIcon: Image.asset('images/ic_face_id.png',
                          width: ScreenUtil().setWidth(50)),
                      mainTitle: "出入记录",
                      subTitle: "",
                      tailText: "",
                    ),
                  ),
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
                              HomeChip(
                                color: const Color(0xff00007c),
                                title: "访客记录",
                                indexId: WebIndexID.FANG_KE_JI_LU,
                              ),
                              HomeChip(
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
                            child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    FlutterBugly.checkUpgrade().then((_) {
                                      return FlutterBugly.getUpgradeInfo();
                                    }).then((info) {
                                      PackageInfo.fromPlatform()
                                          .then((packageInfo) {
                                        if (int.parse(packageInfo.buildNumber) <
                                            info.versionCode) {
                                          showUpdateDialog(context, info);
                                        }
                                      });
                                    });
                                  },
                                  splashColor: Colors.lightGreen,
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.autorenew,
                                          color: Colors.lightGreen,
                                        ),
                                        Text("检查更新")
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                        : Container(),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                UserModel.of(context).logout(context);
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
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showReAuthDialog(BuildContext context) {
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
                Text("重新认证")
              ],
            ),
            content: Text("重新认证个人信息将会覆盖已认证信息,请谨慎操作!"),
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
                  child: Text("重新认证")),
            ],
          );
        });
  }

  ///动作条
  buildActions(BuildContext context) {
    return <Widget>[
      DistrictInfoButton(),
    ];
  }

  ///未认证
  Widget _buildUnauthorized(
    BuildContext context,
    UserModel userModel,
    UserVerifyStatusModel userVerifyStatus,
    UserRoleModel roleModel,
  ) {
    return Stack(
      children: <Widget>[
        AbsorbPointer(
          absorbing: true,
          child: _buildMine(context, userModel, userVerifyStatus, roleModel),
        ),
        buildCertificationDialog(context, () {
          MainIndexModel.of(context).currentIndex = PAGE_HOME;
        })
      ],
    );
  }
}
