import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            return Future.delayed(Duration(seconds: 2));
          },
          child: CustomScrollView(
            controller: controller,
            slivers: <Widget>[
              SliverAppBar(
                centerTitle: true,
                floating: true,
                expandedHeight: 178,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text("test".toUpperCase(),style: TextStyle(color: Colors.white70),),
                  background: Image.asset(
                    "images/banner_home.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
                snap: true,
              ),
              SliverPersistentHeader(
                delegate: _HeaderDelegate(
                  60.0,
                  60.0,
                  Container(
                    color: Colors.lightBlue,
                    child: Center(child: Text("GRID")),
                  ),
                ),
                pinned: false,
              ),
              SliverGrid.count(
                crossAxisCount: 2,
                children: <Widget>[
                  Container(
                    height: 200,
                    color: randomColor(),
                  ),
                  Container(
                    height: 200,
                    color: randomColor(),
                  )
                ],
              ),
              SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Container(
                    color: randomColor(),
                  );
                }, childCount: 11),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              ),
              SliverPersistentHeader(
                delegate: _HeaderDelegate(
                  60.0,
                  60.0,
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      color: Colors.lightBlue,
                      child: Center(child: Text("LIST")),
                    ),
                  ),
                ),
                pinned: false,
              ),
              SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                return Container(
                  height: 200,
                  color: randomColor(),
                );
              }))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.animateTo(0,
              duration: Duration(seconds: 1),
              curve: Curves.fastLinearToSlowEaseIn);
        },
        child: Icon(Icons.arrow_upward),
      ),
    );
  }

  Color randomColor() => Color(Random().nextInt(0xffffffff) | 0xff808080);
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  final double minHeight;
  final double maxHeight;
  final Widget child;

  _HeaderDelegate(this.minHeight, this.maxHeight, this.child);

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_HeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
