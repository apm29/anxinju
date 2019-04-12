import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeChip extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  HomeChip(
      {@required this.title,
      this.onPressed,
      this.color = Colors.white,
      this.textColor = const Color(0xFF616161)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(4)),
      height: ScreenUtil().setHeight(83),
      width: ScreenUtil().setWidth(221),
      child: Chip(
        avatar: Image.asset(
          "images/ic_shadowed_hole.png",
          height: ScreenUtil().setHeight(26),
        ),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(ScreenUtil().setWidth(15))),
            side: BorderSide(color: textColor, width: 0.1)),
        shadowColor: Colors.black,
        label: Text(
          title,
          style: TextStyle(
              color: color != Colors.white ? Colors.white : Colors.black,
              fontSize: ScreenUtil().setSp(26)),
        ),
      ),
    );
  }
}
