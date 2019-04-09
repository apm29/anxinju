import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget {
  final String title;

  final baseTextStyle = TextStyle();

  GradientAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return new Container(
      color: Colors.blue,
      height: 60.0 + statusBarHeight,
      padding: new EdgeInsets.only(top: statusBarHeight),
      child: new DecoratedBox(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                const Color(0xFF3366FF),
                const Color(0xFF00CCFF),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Icon(Icons.menu),
            ),
            new Center(
              child: new Text(
                title,
                style: baseTextStyle.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 26.0),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }
}