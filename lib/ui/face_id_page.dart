import 'package:ease_life/index.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';
import 'package:ease_life/ui/face_verify_hint_page.dart';
import 'package:ease_life/ui/widget/gradient_button.dart';
import 'package:oktoast/oktoast.dart';

class FaceIdPage extends StatefulWidget {
  static String routeName = "/faceId";

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
      ),
      backgroundColor: Colors.blueGrey[200],
      body: fullScreen
          ? Stack(
              children: <Widget>[
                LayoutBuilder(builder: (_, constraint) {
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
                    return SizedBox(
                      width: constraint.biggest.width,
                      child: ClipOval(
                        clipper: ClipperCamera(constraint.biggest.width * 0.8,
                            controller.value.aspectRatio, constraint.biggest),
                        child: AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: StreamBuilder<CAMERA_STATUS>(
                            stream: BlocProviders.of<CameraBloc>(context)
                                .statusStream,
                            builder: (context, snapshot) {
                              if (snapshot.data == null ||
                                  snapshot.data == CAMERA_STATUS.PREVIEW) {
                                return CameraPreview(controller);
                              } else {
                                //镜像照片
                                return Transform(
                                  origin:
                                      Offset(constraint.biggest.width / 2, 0),
                                  transform: Matrix4.rotationY(3.14),
                                  child: Image.file(
                                    currentPic,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                            },
                            initialData: CAMERA_STATUS.PREVIEW,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Align(
                  alignment: Alignment(0, 0.9),
                  child: LayoutBuilder(
                    builder: (_, constraint) {
                      return LoadingStateWidget(
                        key: faceRecognizeKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.warning,
                                  color: Colors.yellow[600],
                                ),
                                Text(
                                  "注意:匹配人脸时请将脸部对准圆形采集框",
                                  style: TextStyle(color: Colors.deepOrange),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            SizedBox(
                              width: constraint.biggest.width * 0.6,
                              child: GradientButton(
                                Text(
                                  "匹配",
                                ),
                                unconstrained: false,
                                onPressed: () async {
                                  takePicture();
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  File currentPic;
  bool inVerify = false;

  void takePicture() async {
    var argument = ModalRoute.of(context).settings.arguments;
    if (argument is Map) {
      ///认证
      if (argument['idCard'] != null) {
        faceRecognizeKey.currentState.startLoading();
        Directory directory = await getTemporaryDirectory();
        var file = File(directory.path +
            "/faceId${DateTime.now().millisecondsSinceEpoch}.jpg");
        await controller.takePicture(file.path);
        file = await rotateWithExifAndCompress(file);
        currentPic = file;
        BlocProviders.of<CameraBloc>(context)
            .changeStatus(CAMERA_STATUS.PICTURE_STILL);
        faceRecognizeKey.currentState.stopLoading();
        BlocProviders.of<CameraBloc>(context)
            .changeStatus(CAMERA_STATUS.PREVIEW);
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ChangeNotifierProvider<FaceVerifyHintModel>(
            child: FaceVerifyHintPage(),
            builder: (context) {
              return FaceVerifyHintModel(
                  file, argument['isAgain'], argument['idCard']);
            },
          );
        }));
      }
    }
  }

  Future verify(File file, Map argument) async {
    var fileResp = await Api.uploadPic(file.path);
    //var base64 = await getImageBase64(file);
    BaseResponse<UserVerifyInfo> baseResponse = await Api.verify(
        fileResp.data.orginPicPath, argument['idCard'], argument['isAgain']);
    faceRecognizeKey.currentState.stopLoading();
    Fluttertoast.showToast(msg: baseResponse.text);
    if (baseResponse.success) {
      //Navigator.of(context).pop(baseResponse.text);
      UserVerifyInfo userVerifyInfo = baseResponse.data;

      ///有房认证
      if (userVerifyInfo.rows != null && userVerifyInfo.rows.length > 0) {
        return showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.all(12),
                title: Text("恭喜"),
                children: userVerifyInfo.rows.map((houseInfo) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "您已经成为${houseInfo.addr}的${houseInfo.isHouseOwner ? "${Strings.hostClass}" : "成员"}",
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList()
                  ..add(Padding(
                    padding: EdgeInsets.all(2),
                    child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text("返回主页")),
                  )),
              );
            }).then((v) => v);
      } else {
        ///无房用户,导向成员申请
        return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("没有数据"),
                content: Text(baseResponse.text),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text("返回主页"),
                  ),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(MemberApplyPage.routeName);
                      },
                      child: Text("申请成为成员")),
                ],
              );
            }).then((v) => v);
      }
    } else {
      ///认证出错
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text("错误"),
              content: Text(baseResponse.text),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text("好的"))
              ],
            );
          }).then((v) => v);
    }
  }

  void refreshUserState() async {
    var toastFuture = showToastWidget(
      AlertDialog(
        title: Text("正在获取新的人脸认证状态.."),
        content: LinearProgressIndicator(),
      ),
      context: context,
      duration: Duration(
        seconds: 150,
      ),
      dismissOtherToast: true,
    );

    int count = 5;
    while (count >= 0) {
      try {
        count--;
        var response = await Api.getUserVerify();
        if (response.success && !response.data.isInVerify()) {
          continue;
        }
        Future.delayed(Duration(milliseconds: 1200));
      } catch (e) {
        print(e);
        continue;
      }
    }
    UserVerifyStatusModel.of(context).tryFetchVerifyStatus();

    ///认证之后不管是否成功都更新userInfo 和 房屋列表
    var baseResp = await Api.getUserInfo();

    if (baseResp.success) {
      await UserModel.of(context).login(baseResp.data, baseResp.token, context);
      await DistrictModel.of(context).tryFetchCurrentDistricts();
    }
    toastFuture?.dismiss(showAnim: true);
    //await UserVerifyStatusModel.of(context)
    //    .tryFetchVerifyStatusPeriodically(context);
    Navigator.of(context)
        .popUntil((r) => r.settings.name == MainPage.routeName);
  }

  Future showHint(BuildContext context) async {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.message,
                  color: Colors.blue,
                ),
                Text("提醒"),
              ],
            ),
            content: Text("人脸比对耗时较长,请等待几分钟后刷新页面"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("确定"),
              )
            ],
          );
        });
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
