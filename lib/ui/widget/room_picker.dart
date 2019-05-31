import 'package:ease_life/res/strings.dart';
import 'package:flutter/material.dart';

import '../../index.dart';

Widget buildItem(String text) {
  return Container(
    child: Column(
      children: <Widget>[
        ListTile(
          title: Text(text),
        ),
        Container(
          color: Colors.blue[200],
          height: 0.5,
        )
      ],
    ),
  );
}

class BuildingPicker extends StatefulWidget {
  final int districtId;

  const BuildingPicker({Key key, this.districtId}) : super(key: key);

  @override
  _BuildingPickerState createState() => _BuildingPickerState();
}

class _BuildingPickerState extends State<BuildingPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("选择${Strings.buildingClass}"),
      ),
      body: FutureBuilder<BaseResponse<List<String>>>(
        future: Api.getBuildings(widget.districtId),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator());
          }
          var list = snapshot.data?.data ?? [];
          if(list.length == 0){
            return Center(
              child: Text("当前选择${Strings.districtClass}暂无数据"),
            );
          }
          return ListView.builder(
            itemBuilder: (_, index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return UnitPicker(
                      districtId: widget.districtId,
                      building: list[index],
                    );
                  })).then((address) {
                    Navigator.of(context).pop(address);
                  });
                },
                child: buildItem(list[index]),
              );
            },
            itemCount: list.length,
          );
        },
      ),
    );
  }
}

class UnitPicker extends StatefulWidget {
  final int districtId;
  final String building;

  const UnitPicker({Key key, this.districtId, this.building}) : super(key: key);

  @override
  _UnitPickerState createState() => _UnitPickerState();
}

class _UnitPickerState extends State<UnitPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("选择${Strings.unitClass}"),
      ),
      body: FutureBuilder<BaseResponse<List<String>>>(
        future: Api.getUnits(widget.districtId, widget.building),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator());
          }
          var list = snapshot.data?.data ?? [];
          if(list.length == 0){
            return Center(
              child: Text("当前选择${Strings.buildingClass}暂无数据"),
            );
          }
          return ListView.builder(
            itemBuilder: (_, index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return RoomPicker(
                      districtId: widget.districtId,
                      building: widget.building,
                      unit: list[index],
                    );
                  })).then((address) {
                    Navigator.of(context).pop(address);
                  });
                },
                child: buildItem(list[index]),
              );
            },
            itemCount: list.length,
          );
        },
      ),
    );
  }
}

class RoomPicker extends StatefulWidget {
  final int districtId;
  final String building;
  final String unit;

  const RoomPicker({Key key, this.districtId, this.building, this.unit})
      : super(key: key);

  @override
  _RoomPickerState createState() => _RoomPickerState();
}

class _RoomPickerState extends State<RoomPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("选择${Strings.roomClass}"),
      ),
      body: FutureBuilder<BaseResponse<List<String>>>(
        future: Api.getRooms(widget.districtId, widget.building, widget.unit),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator());
          }
          var list = snapshot.data?.data ?? [];
          if(list.length == 0){
            return Center(
              child: Text("当前选择${Strings.unitClass}暂无数据"),
            );
          }
          return ListView.builder(
            itemBuilder: (_, index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pop("${widget.building}${widget.unit}${list[index]}");
                },
                child: buildItem(list[index]),
              );
            },
            itemCount: list.length,
          );
        },
      ),
    );
  }
}
