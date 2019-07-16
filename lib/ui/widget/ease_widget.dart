import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EaseIconButton extends StatelessWidget {
  final String assetImageUrl;
  final String buttonLabel;
  final VoidCallback onPressed;
  final IconData iconData;
  final Color iconColor;

  const EaseIconButton({
    Key key,
    this.assetImageUrl,
    this.buttonLabel,
    this.onPressed,
    this.iconData,
    this.iconColor,
  })  : assert(iconData != null || assetImageUrl != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                width: ScreenUtil().setWidth(100),
                height: ScreenUtil().setWidth(100),
                child: assetImageUrl != null
                    ? Image.asset(
                        assetImageUrl,
                      )
                    : Icon(
                        iconData,
                        color: iconColor,
                      ),
              ),
              Text(buttonLabel)
            ],
          ),
        ),
      ),
    );
  }
}
