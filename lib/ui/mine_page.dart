import 'package:ease_life/index.dart';
import 'package:ease_life/res/strings.dart';
import 'package:rxdart/rxdart.dart';
import '../utils.dart';
import 'main_page.dart';
import 'user_detail_auth_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'widget/district_info_button.dart';

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
    Api.getUserInfo().then((baseResp) {
      if (baseResp.success()) {
        BlocProviders.of<ApplicationBloc>(context).login(baseResp.data);
      }
    });
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
          return BlocProviders.of<ApplicationBloc>(context).getIndexInfo();
        },
        child: StreamBuilder<UserInfo>(
          builder: (_, AsyncSnapshot<UserInfo> userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (userSnap.hasError || !userSnap.hasData) {
              return buildVisitor(context);
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
    return StreamBuilder<Index>(
        stream: BlocProviders.of<ApplicationBloc>(context).mineIndex,
        builder: (context, snapshot) {
          var indexInfo = snapshot.data;
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
                          child: StreamBuilder<UserDetail>(
                              stream: BlocProviders.of<ApplicationBloc>(context).userDetailStream,
                              builder: (context, snapshot) {
                                String url = snapshot.data?.avatar;
                                //snapshot.data?.nickName??userInfo.userName
                                String userName = userInfo.userName;
                                return Row(
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
                                    Text(
                                      '$userName',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: hasCommonUserPermission(context),
                    builder: (context, snapshot) {
                      if(snapshot.data != true){
                        return Container();
                      }
                      return Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(top: 12, bottom: 16),
                        margin: EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                routeToWeb(context, 'wdfw', indexInfo);
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
                                routeToWeb(context, 'zscy', indexInfo);
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    "images/ic_member_mine.png",
                                    width: ScreenUtil().setWidth(96),
                                  ),
                                  Text("住所成员")
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                routeToWeb(context, 'wdac', indexInfo);
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
                    }
                  ),
                  StreamBuilder<bool>(
                    stream: hasCommonUserPermission(context),
                    builder: (context, snapshot) {
                      if(snapshot.data!=true){
                        return Container();
                      }
                      return GestureDetector(
                        onTap: () {
                          routeToWeb(context, 'jttxm', indexInfo);
                        },
                        child: Container(
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
                      );
                    }
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      routeToWeb(context, 'crgl', indexInfo);
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
                  ),
                ],
              ),
            ),
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

  ///是否是普通用户
  Stream<bool> hasCommonUserPermission(BuildContext context) {
    return BlocProviders.of<ApplicationBloc>(context)
        .userTypeStream
        .map((list) {
      return list.firstWhere((e) {
            return ["2","4","5","6"].contains(e.roleCode);
          }, orElse: null) !=
          null;
    });
  }

  ///动作条
  buildActions(BuildContext context) {
    return <Widget>[
      DistrictInfoButton(),
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
        buildCertificationDialog(context,(){
            //BlocProviders.of<MainIndexBloc>(context).toIndex(PAGE_HOME);
            IndexNotification(PAGE_HOME).dispatch(context);
        })
      ],
    );
  }

  ///物业人员版本
  Widget _buildPropertyUserMin(BuildContext context, UserInfo userInfo) {
    return StreamBuilder<Index>(
        stream: BlocProviders.of<ApplicationBloc>(context).mineIndex,
        builder: (context, snapshot) {
          var indexInfo = snapshot.data;
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
                        Align(
                          alignment: Alignment.topRight,
                          child: IntrinsicWidth(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  StreamBuilder<DistrictInfo>(
                                      stream: BlocProviders.of<ApplicationBloc>(
                                              context)
                                          .currentDistrict,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            !snapshot.hasError) {
                                          return Text(
                                              snapshot.data.districtName);
                                        }
                                        return Text("未选择${Strings.districtClass}");
                                      }),
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
                          child: StreamBuilder<UserDetail>(
                              stream: BlocProviders.of<ApplicationBloc>(context).userDetailStream,
                              builder: (context, snapshot) {
                                String url = snapshot.data?.avatar;
                                //snapshot.data?.nickName??userInfo.userName
                                String userName = userInfo.userName;
                                return Row(
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
                                    Text(
                                      '$userName',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      routeToWeb(context, 'crgl', indexInfo);
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
                                  indexId: 'fkjl',
                                  index: indexInfo,
                                ),
                                HomeChip(
                                  title: "巡逻记录",
                                  indexId: 'xljl',
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
                        InkWell(
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
                  ),
                ],
              ),
            ),
          );
        });
  }
}
