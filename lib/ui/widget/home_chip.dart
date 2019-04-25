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
        width: ScreenUtil().setWidth(211),
        height: ScreenUtil().setHeight(83),
        decoration: BoxDecoration(
          color: color,
          borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(15))),
          border: Border.all(
            color: Colors.grey,
            width: 0.5
          )
        ),
        child: IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                "images/ic_shadowed_hole.png",
                height: ScreenUtil().setWidth(26),
                width: ScreenUtil().setWidth(26),
                fit: BoxFit.fill,
              ),
              Text(
                title,
                style: TextStyle(
                    color: color != Colors.white ? Colors.white : Colors.black,
                    fontSize: ScreenUtil().setSp(26)),
              ),
            ],
          ),
        ));
  }
}
