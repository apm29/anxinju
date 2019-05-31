import 'package:ease_life/index.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  void initState() {
    super.initState();
    if (!mounted) {
      return;
    }
    print('mine init');

    ///认证相关,每次进入刷新
    Api.getUserInfo().then((baseResp) {
      if (baseResp.success()) {
        BlocProviders.of<ApplicationBloc>(context).login(baseResp.data);
      }
    });
    BlocProviders.of<ApplicationBloc>(context).getMyHouseList();
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
      body: RefreshIndicator(
        onRefresh: () async {
          BlocProviders.of<ApplicationBloc>(context).getUserDetail();
          BlocProviders.of<ApplicationBloc>(context).getUserTypes();
          BlocProviders.of<ApplicationBloc>(context).getMyHouseList();
          return BlocProviders.of<ApplicationBloc>(context).getIndexInfo();
        },
        child: StreamBuilder<UserInfo>(
          builder: (_, AsyncSnapshot<UserInfo> userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!userSnap.hasData) {
              return buildVisitor(context);
            } else if (userSnap.hasError) {
              return buildError(context, userSnap.error);
            } else if (userSnap.data.isCertification == 1) {
              return _buildMine(context, userSnap.data);
            } else if (userSnap.data.isCertification == 0) {
              return _buildUnauthorized(context, userSnap.data);
            } else {
              return buildVisitor(context);
            }
          },
          stream: BlocProviders.of<ApplicationBloc>(context).currentUser,
        ),
      ),
    );
  }

  Widget _buildMine(BuildContext context, UserInfo userInfo) {
    return StreamBuilder<List<HouseDetail>>(
      stream: BlocProviders.of<ApplicationBloc>(context).myHouseStream,
      builder: (context, houseListData) {
        List<HouseDetail> houseList = houseListData.data ?? [];
        bool hasHouse = houseList != null && houseList.length > 0;
        return StreamBuilder<Index>(
            stream: BlocProviders.of<ApplicationBloc>(context).mineIndex,
            builder: (context, snapshot) {
              var indexInfo = snapshot.data;
              return DefaultTextStyle(
                style: TextStyle(color: Colors.grey[800]),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(24)),
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
                              child: StreamBuilder<UserDetail>(
                                  stream:
                                      BlocProviders.of<ApplicationBloc>(context)
                                          .userDetailStream,
                                  builder: (context, snapshot) {
                                    String url = snapshot.data?.avatar;
                                    //String userName = snapshot.data?.nickName ??
                                    //    userInfo.userName;
                                    String userName = userInfo.userName;
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircleAvatar(
                                              backgroundImage: url != null
                                                  ? CachedNetworkImageProvider(
                                                      url)
                                                  : null,
                                            )),
                                        Icon(
                                          userInfo.isCertification == 1 ?Icons.verified_user : Icons.error,
                                          color:userInfo.isCertification == 1 ?  Colors.green : Colors.red,
                                          size: 12,
                                        ),
                                        Text(
                                          '$userName',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        InkWell(
                                          onTap:(){
                                            showReAuthDialog(context);
                                          },
                                          child: Container(
                                            child: Text(
                                              "重新认证",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white
                                              ),
                                              borderRadius: BorderRadius.all(Radius.circular(4))
                                            ),
                                            margin: EdgeInsets.only(left: 2),
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder<bool>(
                          stream: hasCommonUserPermission(context),
                          builder: (context, snapshot) {
                            if (snapshot.data != true) {
                              return Container();
                            }
                            return Container(
                              color: Colors.white,
                              padding: EdgeInsets.only(top: 12, bottom: 16),
                              margin: EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      if (hasHouse)
                                        routeToWeb(context, WebIndexID.WO_DE_FANG_WU, indexInfo);
                                      else {
                                        showAuthDialog(context, indexInfo);
                                      }
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Image.asset(
                                          "images/ic_home_mine.png",
                                          width: ScreenUtil().setWidth(96),
                                        ),
                                        Text("我的房屋")
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
//                                        if (hasHouse)
                                      routeToWeb(context, WebIndexID.ZHU_SUO_CHENG_YUAN, indexInfo);
//                                        else {
//                                          showAuthDialog(context);
//                                        }
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
                                      routeToWeb(context, WebIndexID.WO_DE_AI_CHE, indexInfo);
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
                            );
                          }),
                      StreamBuilder<bool>(
                          stream: hasCommonUserPermission(context),
                          builder: (context, snapshot) {
                            if (snapshot.data != true) {
                              return Container();
                            }
                            return GestureDetector(
                              onTap: () {
                                if (hasHouse)
                                  routeToWeb(context, WebIndexID.JIA_TING_TONG_XING_MA, indexInfo);
                                else {
                                  showAuthDialog(context, indexInfo);
                                }
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
                            );
                          }),
                      SizedBox(
                        height: 12,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (hasHouse)
                            routeToWeb(context, WebIndexID.CHU_RU_JI_LU, indexInfo);
                          else {
                            showAuthDialog(context, indexInfo);
                          }
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
                      StreamBuilder<bool>(
                          stream: hasSocietyRecordPermission(context),
                          builder: (context, snapshot) {
                            if (snapshot.data != true) {
                              return Container();
                            }
                            return HomeTitleSliver(
                              leadingIcon: Container(
                                height: ScreenUtil().setHeight(70),
                                width: ScreenUtil().setWidth(10),
                                color: Color(0xff00007c),
                              ),
                              mainTitle: "社区记录",
                              subTitle: "Society Records",
                              tailText: "更多",
                            );
                          }),
                      StreamBuilder<bool>(
                          stream: hasSocietyRecordPermission(context),
                          builder: (context, snapshot) {
                            if (snapshot.data != true) {
                              return Container();
                            }
                            return Material(
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
                                      index: indexInfo,
                                    ),
                                    HomeChip(
                                      title: "巡逻记录",
                                      indexId: WebIndexID.XUN_LUO_JI_LU,
                                      index: indexInfo,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                BlocProviders.of<ApplicationBloc>(context)
                                    .logout();
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
                      ),
                    ],
                  ),
                ),
              );
            });
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
                  child: Text("前往认证")),
            ],
          );
        });
  }



  ///民警 或者 物业可以看社区记录
  Stream<bool> hasSocietyRecordPermission(BuildContext context) {
    return BlocProviders.of<ApplicationBloc>(context)
        .userTypeStream
        .map((list) {
      return list.firstWhere((e) {
            return "1" == e.roleCode || "3" == e.roleCode;
          }, orElse: null) !=
          null;
    });
  }

  ///是否是物业人员
  Stream<bool> hasPropertyPermission(BuildContext context) {
    return BlocProviders.of<ApplicationBloc>(context)
        .userTypeStream
        .map((list) {
      return list.firstWhere((e) => "1" == e.roleCode, orElse: null) != null;
    });
  }

  ///是否是普通用户 "2", "4", "5", "6"
  Stream<bool> hasCommonUserPermission(BuildContext context) {
    return BlocProviders.of<ApplicationBloc>(context)
        .userTypeStream
        .map((list) {
      return list.firstWhere((e) {
            return ["1", "3", "2", "4", "5", "6"].contains(e.roleCode);
          }, orElse: null) !=
          null;
    });
  }

  ///动作条
  buildActions(BuildContext context) {
    return <Widget>[
      DistrictInfoButton(
        callback: (district) {
          BlocProviders.of<ApplicationBloc>(context).getMyHouseList();
        },
      ),
    ];
  }

  ///未认证
  Widget _buildUnauthorized(BuildContext context, UserInfo data) {
    return Stack(
      children: <Widget>[
        AbsorbPointer(
          absorbing: true,
          child: _buildMine(context, data),
        ),
        buildCertificationDialog(context, () {
          //BlocProviders.of<MainIndexBloc>(context).toIndex(PAGE_HOME);
          IndexNotification(PAGE_HOME).dispatch(context);
        })
      ],
    );
  }

}
