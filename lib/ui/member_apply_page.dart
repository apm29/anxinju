import 'package:ease_life/index.dart';

const kItemExtend = 80.0;

class MemberApplyPage extends StatefulWidget {
  static String routeName = "/memberApply";

  @override
  _MemberApplyPageState createState() => _MemberApplyPageState();
}

class _MemberApplyPageState extends State<MemberApplyPage> {
  TextEditingController _districtTextController = TextEditingController();
  TextEditingController _detailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return buildApply();
  }

  Scaffold buildApply() {
    return Scaffold(
      appBar: AppBar(
        title: Text("住所成员申请"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (parentContext, _) {
          return Container(
            padding: EdgeInsets.only(top: 12, left: 12, right: 12),
            margin: EdgeInsets.only(top: 12, left: 12, right: 12),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(parentContext).size.height -
                          MediaQuery.of(parentContext).padding.top -
                          kToolbarHeight -
                          30),
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: parentContext,
                              builder: (_) {
                                return buildDistrictSelector(parentContext);
                              });
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                                hintText: "请选择小区",
                                border: OutlineInputBorder()),
                            controller: _districtTextController,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: parentContext,
                              builder: (context) {
                                return buildRoomSelector(context);
                              });
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                                hintText: "请选择具体地址",
                                border: OutlineInputBorder()),
                            controller: _detailTextController,
                          ),
                        ),
                      ),
                      FlatButton(onPressed: () {}, child: Text("发送申请"))
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildRoomSelector(BuildContext parentContext) {
    return SizedBox(
      height: ScreenUtil().setHeight(720),
      width: ScreenUtil().setWidth(1080),
      child: StreamBuilder<DistrictInfo>(
          stream: BlocProviders.of<MemberApplyBloc>(context).districtInfo,
          builder: (context, snapshot) {
            return BottomSheet(
                onClosing: () {},
                builder: (context) {
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: StreamBuilder<DistrictInfo>(
                                stream: BlocProviders.of<MemberApplyBloc>(parentContext).districtInfo,
                                builder: (context, snapshot) {
                                  return ListWheelScrollView.useDelegate(
                                    itemExtent: kItemExtend,
                                    childDelegate:
                                        ListWheelChildLoopingListDelegate(
                                            children: []),
                                  );
                                }
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return Text(index.toString());
                                },
                                itemCount: 10,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return Text(index.toString());
                                },
                                itemCount: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                });
          }),
    );
  }

  Widget buildDistrictSelector(BuildContext parentContext) {
    return BottomSheet(
        onClosing: () {},
        builder: (context) {
          return SizedBox(
            height: ScreenUtil().setHeight(720),
            child: FutureBuilder<BaseResponse<List<DistrictInfo>>>(
              builder: (context, building) {
                if (building.hasData &&
                    building.data != null &&
                    building.data.success()) {
                  var list = building.data.data;
                  return Container(
                    margin: const EdgeInsets.all(32.0),
                    child: Stack(
                      children: <Widget>[
                        ListWheelScrollView.useDelegate(
                          itemExtent: kItemExtend,
                          onSelectedItemChanged: (index) {
                            selectDistrict(parentContext, list, index);
                          },
                          controller: new FixedExtentScrollController(),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: list.length,
                            builder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  print('tap');
                                  selectDistrict(parentContext, list, index);
                                },
                                child: Center(
                                    child: Text(list[index].districtName)),
                              );
                            },
                          ),
                          physics: const FixedExtentScrollPhysics(),
                        ),
                        buildForeground()
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Text(building.data?.text ?? "获取小区中.."),
                  );
                }
              },
              future: getAllDistrict(),
            ),
          );
        });
  }

  void selectDistrict(
      BuildContext parentContext, List<DistrictInfo> list, int index) {
    BlocProviders.of<MemberApplyBloc>(parentContext)
        .selectDistrict(list[index]);
    _districtTextController.text = list[index].districtName;
  }

  Future<BaseResponse<List<DistrictInfo>>> getAllDistrict() {
//    var mock = Future.value(BaseResponse("1", "", "", [
//      DistrictInfo(1,"天马1","通天塔","","12"),
//      DistrictInfo(2,"天马2","通天塔","","12"),
//      DistrictInfo(3,"天马3","通天塔","","12"),
//      DistrictInfo(4,"天马4","通天塔","","12"),
//      DistrictInfo(5,"天马5","通天塔","","12"),
//    ]));
    return Api.findAllDistrict();
//    return mock;
  }

  Widget buildForeground() {
    return IgnorePointer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.0, color: Colors.blue),
                bottom: BorderSide(width: 0.0, color: Colors.blue),
              ),
            ),
            constraints: BoxConstraints.expand(
              height: kItemExtend,
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
