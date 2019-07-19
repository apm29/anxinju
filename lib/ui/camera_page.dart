import 'package:ease_life/index.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';

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
                                  //翻转照片
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
                              }),
                        ),
                      ),
                    );
                  }),
                ),
                Align(
                  alignment: Alignment(0, 0.5),
                  child: Text(
                    "注意:匹配人脸时请将脸部对准圆形采集框",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
                Align(
                  alignment: Alignment(0, 0.9),
                  child: LayoutBuilder(
                    builder: (_, constraint) {
                      return LoadingStateWidget(
                        key: faceRecognizeKey,
                        child: SizedBox(
                          width: constraint.biggest.width * 0.6,
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

  File currentPic;

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
        currentPic = file;
        BlocProviders.of<CameraBloc>(context)
            .changeStatus(CAMERA_STATUS.PICTURE_STILL);
        await verify(file, argument);
        refreshUserState();
      } else if (argument['takePic'] == true) {
        faceRecognizeKey.currentState.startLoading();
        Directory directory = await getTemporaryDirectory();
        var file = File(directory.path +
            "/faceId${DateTime.now().millisecondsSinceEpoch}.jpg");
        await controller.takePicture(file.path);
        currentPic = file;
        BlocProviders.of<CameraBloc>(context)
            .changeStatus(CAMERA_STATUS.PICTURE_STILL);
        file = await rotateWithExifAndCompress(file);
        BaseResponse<ImageDetail> resp = await Api.uploadPic(file.path);
        faceRecognizeKey.currentState.stopLoading();
        Navigator.of(context).pop(resp.data);
      }
    }
  }

  Future verify(File file, Map argument) async {
    file = await rotateWithExifAndCompress(file);
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
                          Navigator.of(context).pop();
                        },
                        child: Text("返回主页")),
                  )),
              );
            });
      } else {
        ///无房用户,导向成员申请
        return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("没有数据"),
                content: Text("您的名下没有${Strings.roomClass}"),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
            });
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
                      Navigator.of(context).pop();
                    },
                    child: Text("好的"))
              ],
            );
          });
    }
  }

  void refreshUserState() async {
    ///认证之后不管是否成功都更新userInfo 和 房屋列表
    var baseResp = await Api.getUserInfo();

    if (baseResp.success) {
      await UserModel.of(context).login(baseResp.data, baseResp.token, context);
      await UserRoleModel.of(context).tryFetchUserRoleTypes(context);
      await DistrictModel.of(context).tryFetchCurrentDistricts();
    }
    await UserVerifyStatusModel.of(context)
        .tryFetchVerifyStatusPeriodically(context);
    Navigator.of(context)
        .popUntil((r) => r.settings.name == MainPage.routeName);
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
