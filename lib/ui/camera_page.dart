import 'dart:convert';
import 'dart:io';

import 'package:ease_life/index.dart';
import 'package:camera/camera.dart';

import 'widget/loading_state_widget.dart';

class CameraPage extends StatefulWidget {
  final File capturedFile;

  CameraPage({this.capturedFile});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
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
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  controller
                      .takePicture(widget.capturedFile.absolute.path)
                      .then((v) {
                    Navigator.of(context).pop(widget.capturedFile);
                  });
                },
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
  }
}

class FaceIdPage extends StatefulWidget {
  @override
  _FaceIdPageState createState() => _FaceIdPageState();
}

class _FaceIdPageState extends State<FaceIdPage> {
  CameraController controller;
  GlobalKey<LoadingStateWidgetState> faceRecognizeKey =
      GlobalKey(debugLabel: "faceIdSubmit");

  @override
  void initState() {
    super.initState();
    if (cameras.length == 0) {
      return;
    }
    var cameraFront = cameras[0];
    cameras.forEach((c) {
      if (c.lensDirection == CameraLensDirection.front) {
        cameraFront = c;
      }
    });
    controller = CameraController(cameraFront, ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  bool fullScreen = false;

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
        title: Text("人脸录入"),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () {
                setState(() {
                  fullScreen = !fullScreen;
                });
              },
              icon: Icon(Icons.swap_horizontal_circle),
              label: Text("切换全屏"))
        ],
      ),
      body: fullScreen
          ? Stack(
              children: <Widget>[
                LayoutBuilder(builder: (_, constraint) {
                  print('$constraint');
                  return SizedBox(
                    width: constraint.biggest.width,
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: CameraPreview(controller),
                    ),
                  );
                }),
              ],
            )
          : Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: LayoutBuilder(builder: (_, constraint) {
                    print('$constraint');
                    return SizedBox(
                      width: constraint.biggest.width,
                      child: ClipOval(
                        clipper: ClipperCamera(constraint.biggest.width * 0.8,
                            controller.value.aspectRatio, constraint.biggest),
                        child: AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: CameraPreview(controller),
                        ),
                      ),
                    );
                  }),
                ),
                Align(
                  alignment: Alignment(0,0.9),
                  child: LayoutBuilder(
                    builder: (_, constraint) {
                      return LoadingStateWidget(
                        key: faceRecognizeKey,
                        child: SizedBox(
                          width:  constraint.biggest.width * 0.6,
                          child: OutlineButton(
                            color: Colors.white,
                            shape: Border.all(color: Colors.greenAccent),
                            borderSide: BorderSide(color: Colors.green),
                            splashColor: Colors.greenAccent,
                            child: Text(
                              "匹配",
                              style: TextStyle(color: Colors.green),
                            ),
                            highlightedBorderColor: Colors.greenAccent,
                            onPressed: () {
                              takePicture();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void takePicture() async {
    var idCard = ModalRoute.of(context).settings.arguments;
    faceRecognizeKey.currentState.startLoading();
    Directory directory = await getTemporaryDirectory();
    var file = File(
        directory.path + "/faceId${DateTime.now().millisecondsSinceEpoch}.jpg");
    await controller.takePicture(file.path);
    var resp = await Api.uploadPic(file.path);
    var baseResponse = await Api.verifyUserFace(resp.data.orginPicPath, idCard);
    faceRecognizeKey.currentState.stopLoading();
    Fluttertoast.showToast(msg: baseResponse.text);
  }
}

class ClipperCamera extends CustomClipper<Rect> {
  final double width;
  final double ratio;
  final Size constraint;

  ClipperCamera(this.width, this.ratio, this.constraint);

  @override
  Rect getClip(Size size) {
    var left = constraint.width / 2 - width / 2;
    var top = constraint.height * 0.1;
    return Rect.fromLTWH(left, top, width, width);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }

  @override
  Rect getApproximateClipRect(Size size) {
    var left = constraint.width / 2 - width / 2;
    return Rect.fromLTWH(left, 0, width, width);
  }
}
