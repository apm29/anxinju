import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../index.dart';
import '../main.dart';
import '../utils.dart';

void main() {
  runApp(MaterialApp(
    home: TestPage(),
  ));
}

class TestPage extends StatefulWidget {
  static String routeName = "/test";

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(maxHeight: 100),
            child: FutureBuilder(
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  return Container(
                    height: 200,
                    color: Colors.blueGrey,
                  );
                }else{
                  return Container(
                    height: 100,
                    color: Colors.blue,
                  );
                }
              },
              future: someFuture(),
            ),
          ),
        ],
      ),
    );
  }

  Future<int> someFuture()async{
    await Future.delayed(Duration(seconds: 2));
    return 1;
  }

  RefreshIndicator buildSliver() {
    return RefreshIndicator(
      onRefresh: () async {
        return Future.delayed(Duration(seconds: 2));
      },
      child: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverAppBar(
            centerTitle: true,
            floating: true,
            expandedHeight: 178,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "test".toUpperCase(),
                style: TextStyle(color: Colors.white70),
              ),
              background: Image.asset(
                "images/banner_home.webp",
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
