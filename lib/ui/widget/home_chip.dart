import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/model/main_index_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ease_life/utils.dart';
import 'package:provider/provider.dart';

class HomeChip extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final String indexId;
  final bool checkIsFaceVerified;
  final bool checkHasHouse;
  final bool checkLogin;
  final bool wrap;

  HomeChip({
    @required this.title,
    this.onPressed,
    this.color = Colors.white,
    this.textColor = const Color(0xFF616161),
    this.indexId,
    this.checkIsFaceVerified = false,
    this.checkHasHouse = false,
    this.wrap = false,
    this.checkLogin = false,
  }) : assert(checkIsFaceVerified != null),assert(checkLogin!=null);

  void route(String id, BuildContext context) {
    toWebPage(
      context,
      indexId,
      checkHasHouse: checkHasHouse,
      checkFaceVerified: checkIsFaceVerified,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (checkLogin && !UserModel.of(context).isLogin) {
            Navigator.of(context).pushNamed(LoginPage.routeName).then((token) {
              if (token != null) {
                doOnPress(context);
              }
            });
          } else {
            doOnPress(context);
          }
        },
        child: Container(
            margin: EdgeInsets.all(ScreenUtil().setWidth(8)),
            constraints: BoxConstraints.tightForFinite(
              width: wrap ? double.infinity : ScreenUtil().setWidth(270),
              height: ScreenUtil().setHeight(108),
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
                    child: Consumer<MainIndexModel>(
                      builder: (BuildContext context, MainIndexModel value,
                          Widget child) {
                        return Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: color != Colors.white
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: ScreenUtil().setSp(40)),
                          maxLines: 3,
                        );
                      },
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  void doOnPress(BuildContext context) {
    (onPressed ??
            () {
              route(indexId, context);
            })
        .call();
  }
}
