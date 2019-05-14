import 'package:ease_life/index.dart';

const kItemExtend = 80.0;

class MemberApplyPage extends StatefulWidget {
  static String routeName = "/memberApply";

  @override
  _MemberApplyPageState createState() => _MemberApplyPageState();
}

class _MemberApplyPageState extends State<MemberApplyPage> {
  TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("住所成员申请"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 12, left: 12, right: 12),
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
                        builder: (context) {
                          return buildDistrictSelector();
                        });
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "请选择小区",
                          labelText: "小区",
                          border: OutlineInputBorder()),
                      controller: _nameController,
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
                          hintText: "请选择具体地址",
                          labelText: "具体地址",
                          border: OutlineInputBorder()),
                      controller: _nameController,
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

  BottomSheet buildRoomSelector() {
    return BottomSheet(
        onClosing: () {},
        builder: (context) {
          return FutureBuilder(
            builder: (context, building) {
              return Text(building.data);
            },
            future: Future.value("123"),
          );
        });
  }

  Widget buildDistrictSelector() {
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
                    child: Text(building.data?.text ?? "获取小区数据失败"),
                  );
                }
              },
              future: Api.findAllDistrict(),
            ),
          );
        });
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
