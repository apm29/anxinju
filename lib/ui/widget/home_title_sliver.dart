import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeTitleSliver extends StatelessWidget {

  final Color indicatorColor;

  final String mainTitle;
  final String subTitle;
  final String tailText;
  final VoidCallback onPressed;
  final Widget leadingIcon;
  HomeTitleSliver({this.leadingIcon,this.indicatorColor = const Color(0xFF000078),@required this.mainTitle,@required this.subTitle,
    this.tailText = "更多" ,this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        leadingIcon??Container(
          height: ScreenUtil().setHeight(70),
          width: ScreenUtil().setWidth(10),
          color: indicatorColor,
        ),
        SizedBox(
          width: 10,
          height: ScreenUtil().setHeight(140),
        ),
        Text(mainTitle,style:const TextStyle(
          fontSize: 16
        ),),
        SizedBox(
          width: 10,
        ),
        Text(subTitle,style: TextStyle(
          color: Colors.grey[400]
        ),),
        Expanded(
          child: Container(
            color: Colors.transparent,
          ),
        ),
//        RawMaterialButton(
//          constraints: BoxConstraints(
//            minHeight: 0,minWidth: 0
//          ),
//          child: Row(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              Container(width: 10,),
//              Text("",style:const TextStyle(
//                  fontSize: 16
//              ),),
//              //Icon(Icons.keyboard_arrow_right)
//            ],
//          ),
//          onPressed: onPressed,
//        )
      ],
    );
  }
}
