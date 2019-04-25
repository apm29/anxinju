import 'package:ease_life/index.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的"),
        centerTitle: true,
        actions: buildActions(context),
      ),
      body: StreamBuilder<UserInfo>(
        builder: (context, AsyncSnapshot<UserInfo> userSnap) {
          if (userSnap.hasError || !userSnap.hasData) {
            return buildMineVisitor();
          } else {
            return _buildMine(context, userSnap.data);
          }
        },
        stream: BlocProviders.of<ApplicationBloc>(context).currentUser,
      ),
    );
  }

  Widget buildMineVisitor() {
    return Center(
      child: Text("未登录"),
    );
  }

  Widget _buildMine(BuildContext context, UserInfo data) {
    return translateChild(data);
  }

  DefaultTextStyle translateChild(UserInfo data) {
    return DefaultTextStyle(
      style: TextStyle(color: Colors.grey[800]),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: ListView(
          key: PageStorageKey("mine"),
          children: <Widget>[
            DefaultTextStyle(
              style: TextStyle(
                color: Colors.white
              ),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Image.asset("images/ic_banner_mine.png",fit: BoxFit.fill,height: ScreenUtil().setHeight(350),),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IntrinsicWidth(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Text("天马花园"),
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
                          child: CircleAvatar(
                            child: Icon(Icons.person_outline),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${data.userName}',style: TextStyle(
                                        fontSize: 15
                                    ),),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 0.5
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(100))
                                    ),
                                    child: Text("切换用户",style: TextStyle(
                                        fontSize: 8
                                    )),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('天马花园15-2-1202'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(right: 8),
                    child: Column(
                      children: <Widget>[
                        Image.asset("images/ic_home_mine.png"),
                        Text("我的房屋")
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.people,
                          color: Colors.blue,
                        ),
                        Text("住所成员")
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(left: 8),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.directions_car,
                          color: Colors.blue,
                        ),
                        Text("我的爱车")
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 15),
              child: HomeTitleSliver(
                leadingIcon: Icon(
                  Icons.fiber_pin,
                  color: Colors.blue,
                ),
                mainTitle: "家庭通行码",
                subTitle: "",
                tailText: "",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "社区记录",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.perm_contact_calendar,
                          color: Colors.blue,
                        ),
                        Text("访客记录")
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.assignment_late,
                          color: Colors.blue,
                        ),
                        Text("投诉维修")
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.playlist_add,
                          color: Colors.blue,
                        ),
                        Text("缴费记录")
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "商业服务",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.view_list,
                          color: Colors.blue,
                        ),
                        Text("我的订单")
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.blue,
                        ),
                        Text("购物车")
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.favorite,
                          color: Colors.blue,
                        ),
                        Text("我的收藏")
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Table(
              border: TableBorder.all(color: Colors.grey[400]),
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(18),
                      color: Colors.white,
                      child: Text("我的设置"),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(18),
                      color: Colors.white,
                      child: Text("关于我们"),
                    )
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        BlocProviders.of<ApplicationBloc>(context).logout();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(18),
                        color: Colors.white,
                        child: Text("退出登录"),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      padding: EdgeInsets.all(18),
                      child: Text(
                        '空',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  buildActions(BuildContext context) {}
}
