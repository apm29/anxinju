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
    return Scaffold(
      appBar: AppBar(
        title: Text("住所成员申请"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 12, left: 12, right: 12),
        margin: EdgeInsets.only(top: 12, left: 12, right: 12),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight -
                    30),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (_) {
                          return buildDistrictSelector(context);
                        });
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "请选择小区", border: OutlineInputBorder()),
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
                        context: context,
                        builder: (context) {
                          return buildRoomSelector();
                        });
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "请选择具体地址", border: OutlineInputBorder()),
                      controller: _detailTextController,
                    ),
                  ),
                ),
                Expanded(child: SizedBox()),
                FlatButton(onPressed: () {}, child: Text("发送申请"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRoomSelector() {
    return SizedBox(
      height: ScreenUtil().setHeight(720),
      width: ScreenUtil().setWidth(1080),
      child: StreamBuilder<DistrictInfo>(
          stream: BlocProviders.of<MemberApplyBloc>(context).districtInfo,
          builder: (context, snapshot) {
            return BottomSheet(
                onClosing: () {},
                builder: (context) {
                  return FutureBuilder<DistrictInfo>(
                    builder: (context, building) {
                      return Stack(
                        children: <Widget>[
                          Table(
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey
                                ),
                                children: [
                                  Container(
                                    color: Colors.blue,
                                  ),
                                  Container(
                                    color: Colors.green,
                                  ),
                                  Container(
                                    color: Colors.red,
                                  ),
                                ]
                              )
                            ],
                          ),
                          buildForeground()
                        ],
                      );
                    },
                    future: Future.value(null),
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
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Stack(
                      children: <Widget>[
                        ListWheelScrollView.useDelegate(
                          itemExtent: kItemExtend,
                          onSelectedItemChanged: (index) {
                            BlocProviders.of<MemberApplyBloc>(parentContext)
                                .selectDistrict(list[index]);
                            _districtTextController.text =
                                list[index].districtName;
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: list.length,
                            builder: (context, index) {
                              return Center(
                                  child: Text(list[index].districtName));
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
