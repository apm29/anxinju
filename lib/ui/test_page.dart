import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../index.dart';
import '../main.dart';
import '../utils.dart';

class TestPage extends StatefulWidget {
  static String routeName = "/test";

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  ScrollController scrollController = ScrollController();
  CameraController controller;

  @override
  void initState() {
    super.initState();
    if (cameras.length == 0) {
      return;
    }
    var cameraInstance = cameras[0];
    //默认打开后置
    cameras.forEach((c) {
      if (c.lensDirection == CameraLensDirection.back) {
        cameraInstance = c;
      }
    });
    controller = CameraController(cameraInstance, ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("人脸录入"),
        ),
        body: Center(
          child: Text("没有检测到相机设备"),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("相机"),
        ),
        body: Stack(
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: AspectRatio(
                aspectRatio: 1/3,
                child: CameraPreview(controller),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                child: Container(
                  height: 70,
                  width: 70,
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 1.5, color: Colors.grey[600])),
                ),
              ),
            )
          ],
        ));
//    return Scaffold(
//      body: Center(
//        child: RaisedButton(onPressed: ()async{
//          var argument = ModalRoute.of(context).settings.arguments;
//          Directory directory = await getTemporaryDirectory();
//          var file = File(directory.path +
//              "/faceId${DateTime.now().millisecondsSinceEpoch}.jpg");
//          await controller.takePicture(file.path);
//          file = await rotateWithExifAndCompress(file);
//          var resp = await Api.uploadPic(file.path);
//          var baseResponse = await Api.verifyUserFace(
//              resp.data.orginPicPath, argument['idCard']);
//          Fluttertoast.showToast(msg: baseResponse.text);
//          if (baseResponse.success()) {
//            //注册成功
//            print(baseResponse.text);
//            Navigator.of(context).pop(baseResponse.text);
//          }
//        }),
//      ),
//    );
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
