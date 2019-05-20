import 'package:ease_life/model/base_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ease_life/utils.dart';

class HomeChip extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final String indexId;
  final Index index;
  final bool intercept;
  final bool wrap;

  HomeChip(
      {@required this.title,
      this.onPressed,
      this.color = Colors.white,
      this.textColor = const Color(0xFF616161),
      this.indexId,
      this.index,
      this.intercept,
      this.wrap = false});

  void route(String id, Index index, BuildContext context) {
    if (intercept==true) {
      Fluttertoast.showToast(msg: "请先完成户主认证");
      return;
    }
    routeToWeb(context,id, index);
  }

  @override
  Widget build(BuildContext context) {
    if (index == null) {
      return Container();
    }

    return GestureDetector(
      onTap: () {
        route(indexId, index, context);
      },
      child: Container(
          margin: EdgeInsets.all(ScreenUtil().setWidth(8)),
          constraints: BoxConstraints.tightForFinite(
            width: wrap ? double.infinity : ScreenUtil().setWidth(211),
            height: ScreenUtil().setHeight(83),
          ),
          padding: EdgeInsets.only(right: wrap ? 6.0 : 0.0),
          decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.all(Radius.circular(ScreenUtil().setWidth(15))),
              border: Border.all(color: Colors.grey, width: 0.5)),
          child: IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(26)),
                  child: Image.asset(
                    "images/ic_shadowed_hole.png",
                    height: ScreenUtil().setWidth(26),
                    width: ScreenUtil().setWidth(26),
                    fit: BoxFit.fill,
                  ),
                ),
                Expanded(
                  child: Text(
                    getTitle(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                            color != Colors.white ? Colors.white : Colors.black,
                        fontSize: ScreenUtil().setSp(30)),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          )),
    );
  }

  String getTitle() {
    return index.menu.firstWhere((item) {
      return item.id == indexId;
    }, orElse: () {
      return MenuItem("", "未定义", "");
    }).remark;
  }
}
