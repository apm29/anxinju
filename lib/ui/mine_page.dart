import 'package:ease_life/index.dart';
import 'package:rxdart/rxdart.dart';
import '../utils.dart';
import 'main_page.dart';
import 'member_apply_page.dart';
import 'user_detail_auth_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  PublishSubject<UserDetail> _controllerUserDetailData = PublishSubject();
  Stream<UserDetail> userDetailData;

  @override
  void initState() {
    super.initState();
    if (!mounted) {
      return;
    }
    Api.getUserInfo().then((baseResp) {
      print('baseResp:$baseResp');
      if (baseResp.success()) {
        BlocProviders.of<ApplicationBloc>(context).login(baseResp.data);
      }
    });
    BlocProviders.of<ApplicationBloc>(context).getUserTypes();
    userDetailData = _controllerUserDetailData.stream;
    Api.getUserDetail().then((baseResp) {
      if (baseResp.success()) {
        print('$baseResp');
        _controllerUserDetailData.add(baseResp.data);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controllerUserDetailData.close();
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
          Api.getUserDetail().then((baseResp) {
            if (baseResp.success()) {
              print('$baseResp');
              _controllerUserDetailData.add(baseResp.data);
            }
          });
          BlocProviders.of<ApplicationBloc>(context).getUserTypes();
          return BlocProviders.of<ApplicationBloc>(context).getIndexInfo();
        },
        child: StreamBuilder<UserInfo>(
          builder: (context, AsyncSnapshot<UserInfo> userSnap) {
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
                                        return Text("未选择小区");
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: StreamBuilder<UserDetail>(
                                  builder: (context, snapshot) {
                                    String url = snapshot.data?.avatar;

                                    return CircleAvatar(
                                      backgroundImage: url != null
                                          ? CachedNetworkImageProvider(url)
                                          :null,
                                    );
                                  },
                                  stream: userDetailData,
                                ),
                              ),
                              Text(
                                '${userInfo.userName}',
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
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
                  ),
                  GestureDetector(
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
//                  SizedBox(
//                    height: 12,
//                  ),
//                  GestureDetector(
//                    onTap: () {
//                      Navigator.of(context).pushNamed(MemberApplyPage.routeName);
//                    },
//                    child: Container(
//                      color: Colors.white,
//                      padding: EdgeInsets.only(left: 15),
//                      child: HomeTitleSliver(
//                        leadingIcon: Icon(Icons.storage,size:ScreenUtil().setWidth(50),color: Color(0xff00007c),),
//                        mainTitle: "我的申请",
//                        subTitle: "",
//                        tailText: "",
//                      ),
//                    ),
//                  ),

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
//                          HomeChip(
//                            title: "投诉记录",
//                            indexId: 'tsjl',
//                            index: indexInfo,
//                          ),
//                          HomeChip(
//                            title: "缴费记录",
//                            indexId: 'jfjl',
//                            index: indexInfo,
//                          ),
//                          HomeChip(
//                            title: "调解档案",
//                            indexId: 'tjda',
//                            index: indexInfo,
//                          ),
//                          HomeChip(
//                            title: "网上110记录",
//                            indexId: 'ws110jl',
//                            wrap: true,
//                            index: indexInfo,
//                          ),
                                HomeChip(
                                  title: "巡逻记录",
                                  indexId: 'xljl',
                                  index: indexInfo,
                                ),
//                          HomeChip(
//                            title: "小区报修记录",
//                            indexId: 'xqbxjl',
//                            index: indexInfo,
//                            wrap: true,
//                          ),
                              ],
                            ),
                          ),
                        );
                      }),
//                  HomeTitleSliver(
//                    leadingIcon: Container(
//                      height: ScreenUtil().setHeight(70),
//                      width: ScreenUtil().setWidth(10),
//                      color: Color(0xffff6b00),
//                    ),
//                    mainTitle: "商业服务",
//                    subTitle: "Business Service",
//                    tailText: "更多",
//                  ),
//                  Material(
//                    type: MaterialType.card,
//                    elevation: 1,
//                    child: Container(
//                      padding: EdgeInsets.symmetric(
//                        vertical: ScreenUtil().setHeight(42),
//                        horizontal: ScreenUtil().setWidth(42),
//                      ),
//                      color: Colors.white,
//                      child: Wrap(
//                        children: <Widget>[
//                          HomeChip(
//                            color: const Color(0xffff6b00),
//                            title: "我的订单",
//                            indexId: 'wddd',
//                            index: indexInfo,
//                          ),
//                          HomeChip(
//                            title: "购物车",
//                            indexId: 'gwc',
//                            index: indexInfo,
//                          ),
//                          HomeChip(
//                            title: "我的收藏",
//                            indexId: 'wdsc',
//                            index: indexInfo,
//                          ),
//                        ],
//                      ),
//                    ),
//                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
//                        InkWell(
//                          onTap: (){
//                            Navigator.of(context).pushNamed(MemberApplyPage.routeName);
//                          },
//                          child: Column(
//                            children: <Widget>[
//                              Icon(
//                                Icons.person_outline,
//                                color: Colors.blue,
//                              ),
//                              Text("成员申请")
//                            ],
//                          ),
//                        ),
//                        Column(
//                          children: <Widget>[
//                            Icon(
//                              Icons.help_outline,
//                              color: Colors.green,
//                            ),
//                            Text("关于我们")
//                          ],
//                        ),
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

  buildActions(BuildContext context) {
    return <Widget>[
      //DistrictInfoButton(),
    ];
  }

  ///未认证
  Widget _buildUnauthorized(BuildContext context, UserInfo data) {
    var colorFaceButton = Colors.blue;
    return Stack(
      children: <Widget>[
        AbsorbPointer(
          absorbing: true,
          child: _buildMine(context, data),
        ),
        AlertDialog(
          title: Text(
            "您还未通过认证,只能使用首页功能",
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                BlocProviders.of<MainIndexBloc>(context).toIndex(PAGE_HOME);
              },
              textColor: Colors.blueGrey,
              child: Text(
                "暂不认证",
                maxLines: 1,
              ),
            ),
            FlatButton(
              onPressed: () {
                BlocProviders.of<ApplicationBloc>(context).logout();
              },
              textColor: Colors.blueGrey,
              child: Text(
                "退出登录",
                maxLines: 1,
              ),
            )
          ],
          content: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: colorFaceButton),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: ListTile(
              leading: Icon(
                Icons.fingerprint,
                size: 40,
                color: colorFaceButton,
              ),
              title: Text("录入人脸照片",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: colorFaceButton)),
              subtitle:
                  Text("一键录入,简单高效", style: TextStyle(color: colorFaceButton)),
              trailing: Icon(
                Icons.arrow_forward,
                color: colorFaceButton,
              ),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(UserDetailAuthPage.routeName)
                    .then((v) {
                  //获取当前用户信息
                  Future.delayed(Duration(milliseconds: 500), () {
                    return Api.getUserInfo().then((baseResp) {
                      print('baseResp:$baseResp');
                      if (baseResp.success()) {
                        BlocProviders.of<ApplicationBloc>(context)
                            .login(baseResp.data);
                      }
                    });
                  });
                });
              },
            ),
          ),
        )
      ],
    );
  }
}
