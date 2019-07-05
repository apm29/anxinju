import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeTitleSliver extends StatelessWidget {
  final Color indicatorColor;

  final String mainTitle;
  final String subTitle;
  final String tailText;
  final VoidCallback onPressed;
  final Widget leadingIcon;
  final bool notTitle;

  HomeTitleSliver({
    this.leadingIcon,
    this.indicatorColor = const Color(0xFF000078),
    this.mainTitle = "",
    this.subTitle = "",
    this.tailText = "更多",
    this.onPressed,
    this.notTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notTitle ? Colors.white : null,
      child: InkWell(
        onTap: onPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            notTitle
                ? SizedBox(
                    width: 15,
                  )
                : Container(),
            leadingIcon ??
                Container(
                  height: ScreenUtil().setHeight(70),
                  width: ScreenUtil().setWidth(10),
                  color: indicatorColor,
                ),
            SizedBox(
              width: 10,
              height: ScreenUtil().setHeight(140),
            ),
            Text(
              mainTitle,
              style: const TextStyle(fontSize: 16),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              subTitle,
              style: TextStyle(color: Colors.grey[400]),
            ),
            Expanded(
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
