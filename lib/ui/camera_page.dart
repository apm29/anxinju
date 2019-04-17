import 'package:ease_life/index.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    if(cameras.length==0){
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
    if (controller==null||!controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("人脸录入"),
        ),
        body: Center(child: Text("没有检测到相机设备"),),
      );
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("人脸录入"),
//        actions: <Widget>[
//          FlatButton.icon(
//              onPressed: () {
//                setState(() {
//                  fullScreen = !fullScreen;
//                });
//              },
//              icon: Icon(Icons.swap_horizontal_circle),
//              label: Text("切换全屏"))
//        ],
      ),
      body: fullScreen
          ? Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
              ],
            )
          : Stack(
              children: <Widget>[
                LayoutBuilder(builder: (_, constraint) {
                  print('$constraint');
                  return SizedBox(
                    height: constraint.biggest.height,
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: LayoutBuilder(
                    builder: (_, constraint) {
                      return SizedBox(
                        width: constraint.biggest.width*0.6,
                        child: OutlineButton(
                          color: Colors.white,
                          shape: Border.all(
                            color: Colors.greenAccent
                          ),
                          borderSide: BorderSide(
                            color: Colors.green
                          ),
                          splashColor: Colors.greenAccent,
                          child: Text("匹配",style: TextStyle(
                            color: Colors.green
                          ),),
                          highlightedBorderColor: Colors.greenAccent,
                          onPressed: () {},
                        ),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: LayoutBuilder(builder: (context, constraint) {
                    return SizedBox(
                      child: Container(
                        width: constraint.biggest.width -
                            constraint.biggest.width * 0.2 +
                            10,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.indigo,
                              width: 5,
                            )),
                      ),
                    );
                  }),
                )
              ],
            ),
    );
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
    var top = constraint.height / 2 - width / 2;
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
