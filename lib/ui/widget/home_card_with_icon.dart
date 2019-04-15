import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeCardWithIcon extends StatelessWidget {
  final String mainTitle;
  final String subTitle;
  final String imagePath;
  final bool rightAlign;

  HomeCardWithIcon(
      this.mainTitle, this.subTitle, this.imagePath, this.rightAlign);

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            rightAlign ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            mainTitle,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          Text(subTitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
              )),
        ],
      ),
      Image.asset(
        imagePath,
        width: ScreenUtil().setWidth(90),
      ),
      SizedBox(
        width: ScreenUtil().setWidth(10),
      ),
    ];
    if (rightAlign) {
      children.insert(0, children.removeAt(1));
      children.insert(0, children.removeAt(2));
    }
    return Container(
      width: ScreenUtil().setWidth(506),
      constraints: BoxConstraints.tightFor(
        height: ScreenUtil().setHeight(252),
      ),
      margin: EdgeInsets.only(
          left: (!rightAlign)
              ? ScreenUtil().setWidth(0)
              : ScreenUtil().setWidth(17),
          right: (rightAlign)
              ? ScreenUtil().setWidth(0)
              : ScreenUtil().setWidth(17),
          top: ScreenUtil().setWidth(8),
          bottom: ScreenUtil().setWidth(8)),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
