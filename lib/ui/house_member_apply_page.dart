import 'package:ease_life/index.dart';
import 'package:ease_life/res/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../utils.dart';
import 'main_page.dart';
import 'widget/loading_state_widget.dart';
import 'widget/room_picker.dart';

const kItemExtend = 80.0;

class MemberApplyPage extends StatefulWidget {
  static String routeName = "/memberApply";

  @override
  _MemberApplyPageState createState() => _MemberApplyPageState();
}

class _MemberApplyPageState extends State<MemberApplyPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _detailController = TextEditingController();
  int districtId;

  FixedExtentScrollController buildingScrollController =
      FixedExtentScrollController(initialItem: -1);
  FixedExtentScrollController unitScrollController =
      FixedExtentScrollController(initialItem: -1);
  FixedExtentScrollController roomScrollController =
      FixedExtentScrollController(initialItem: -1);

  GlobalKey<LoadingStateWidgetState> applyKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var findAllDistrict = Api.findAllDistrict();
    return Scaffold(
      appBar: AppBar(
        title: Text("${Strings.roomClass_2}成员申请"),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          return Container(
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
                    SizedBox(
                      height: 12,
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return FutureBuilder<
                                  BaseResponse<List<DistrictInfo>>>(
                                future: findAllDistrict,
                                builder: (context, districtSnap) {
                                  if (districtSnap.hasData &&
                                      !districtSnap.hasError &&
                                      districtSnap.data.success()) {
                                    return SizedBox(
                                      height: ScreenUtil().setHeight(800),
                                      child: ListView(
                                        shrinkWrap: true,
                                        children:
                                            districtSnap.data.data.map((d) {
                                          return FlatButton(
                                            onPressed: () {
                                              _nameController.text =
                                                  d.districtName;
                                              if (districtId != d.districtId) {
                                                _detailController.text = "";
                                              }
                                              districtId = d.districtId;
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              d.districtName,
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  } else {
                                    return Wrap(
                                      children: <Widget>[
                                        Container(
                                          alignment:
                                              AlignmentDirectional.center,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: <Widget>[
                                              CircularProgressIndicator(),
                                              Text(
                                                "获取${Strings.districtClass}列表..",
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              );
                              //return buildDistrictSelector();
                            });
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: "请选择${Strings.districtClass}",
                              labelText: "${Strings.districtClass}",
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
                        if (districtId == null) {
                          Fluttertoast.showToast(
                              msg: "请先选择${Strings.districtClass}");
                          return;
                        }
                        showRoomPicker(context, districtId).then((address) {
                          _detailController.text = address;
                        });
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: "请选择具体地址",
                              labelText: "具体地址",
                              border: OutlineInputBorder()),
                          controller: _detailController,
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(100)),
                      child: LoadingStateWidget(
                        key: applyKey,
                        child: FlatButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () async {
                            applyKey.currentState.startLoading();
                            var baseResponse = await Api.applyMember(
                                _detailController.text, districtId);
                            Fluttertoast.showToast(msg: baseResponse.text);
                            applyKey.currentState.stopLoading();
                            if (baseResponse.success()) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("申请成功"),
                                      content: Text.rich(TextSpan(children: [
                                        TextSpan(text: "您已经完成了${Strings.roomClass_2}成员申请,您可以在 "),
                                        TextSpan(
                                            text: "我的-${Strings.roomClass_2}成员",
                                            style:
                                                TextStyle(color: Colors.blue),
                                          recognizer: TapGestureRecognizer()..onTap=(){
                                              Navigator.of(context).pop();
                                          }
                                        ),
                                        TextSpan(text: " 页面查看申请进度"),
                                      ])),
                                      actions: <Widget>[
                                        FlatButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("确定"))
                                      ],
                                    );
                                  }).then((v) {
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          child: Text("发送申请"),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Subject<BaseResponse<List<String>>> buildingController = PublishSubject();

  Subject<BaseResponse<List<String>>> unitController = PublishSubject();

  Subject<BaseResponse<List<String>>> roomController = PublishSubject();

  @override
  void dispose() {
    super.dispose();
    buildingController.close();
    unitController.close();
    roomController.close();
  }

  String buildingAddress;
  String roomAddress;

  Widget buildRoomSelector() {
    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("确定"))
              ],
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: StreamBuilder<BaseResponse<List<String>>>(
                      stream: buildingController.stream,
                      builder: (context, building) {
                        var buildingList = building.data?.data ?? [];

                        if (buildingList.length == 0) {
                          return Container();
                        }
                        return CupertinoPicker.builder(
                          itemExtent: kItemExtend,
                          onSelectedItemChanged: (index) {
                            Api.getUnits(districtId, buildingList[index])
                                .then((baseResp) {
                              unitController.add(baseResp);
                            });
                            buildingAddress = buildingList[index];
                          },
                          itemBuilder: (context, index) {
                            return Center(child: Text(buildingList[index]));
                          },
                          scrollController: buildingScrollController,
                          childCount: buildingList.length,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<BaseResponse<List<String>>>(
                      stream: unitController.stream,
                      builder: (context, unit) {
                        var unitList = unit.data?.data ?? [];
                        print('$unitList');
                        if (unitList.length == 0) {
                          return Container();
                        }
                        return CupertinoPicker.builder(
                          itemExtent: kItemExtend,
                          onSelectedItemChanged: (index) {
                            print('$index');
                            Api.getRooms(districtId, buildingAddress,
                                    unitList[index])
                                .then((baseResp) {
                              roomController.add(baseResp);
                            });
                          },
//                          scrollController: unitScrollController,
                          backgroundColor: Colors.green,
                          itemBuilder: (context, index) {
                            return Center(child: Text(unitList[index]));
                          },
                          childCount: unitList.length,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<BaseResponse<List<String>>>(
                      stream: roomController.stream,
                      builder: (context, room) {
                        var roomList = room.data?.data ?? [];
                        print('$roomList');
                        if (roomList.length == 0) {
                          return Container();
                        }
                        return CupertinoPicker.builder(
                          itemExtent: kItemExtend,
                          onSelectedItemChanged: (index) {
                            roomAddress = roomList[index];
                          },
                          scrollController: roomScrollController,
                          backgroundColor: Colors.blue,
                          itemBuilder: (context, index) {
                            return Center(child: Text(roomList[index]));
                          },
                          childCount: roomList.length,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
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
                    child: Text(building.data?.text ??
                        "获取${Strings.districtClass}数据失败"),
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
