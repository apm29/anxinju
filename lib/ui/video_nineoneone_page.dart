import 'package:camera/camera.dart';
import 'package:ease_life/res/configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import '../main.dart';
import '../utils.dart';

import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class VideoNineOneOnePage extends StatefulWidget {
  static String routeName = "/911";
  final String channelName;

  VideoNineOneOnePage({this.channelName});

  @override
  _VideoNineOneOnePageState createState() => _VideoNineOneOnePageState();
}

class _VideoNineOneOnePageState extends State<VideoNineOneOnePage> {
  CameraController controller;
  GlobalKey _keyCall = GlobalKey();
  GlobalKey _keyMute = GlobalKey();
  GlobalKey _keySwitchCamera = GlobalKey();
  GlobalKey _keyLocation = GlobalKey();
  GlobalKey _keyMessage = GlobalKey();
  GlobalKey _keyImage = GlobalKey();
  GlobalKey _keyPreview = GlobalKey();
  GlobalKey _keyPreviewPolice = GlobalKey();

  List<TargetFocus> targets = [];
  TutorialCoachMark tutorialCoachMark;
  bool _finishTutorial = true;

  @override
  void initState() {
    super.initState();
    if (cameras.length == 0) {
      return;
    }
    initCameraController();
    initializeAgora();

    initTutorial();
  }

  void initCameraController({bool front = true}) {
    var cameraFront = cameras[0];
    cameras.forEach((c) {
      if (c.lensDirection ==
          (front ? CameraLensDirection.front : CameraLensDirection.back)) {
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
    // clean up native views & destroy sdk
    _sessions.forEach((session) {
      AgoraRtcEngine.removeNativeView(session.uid);
    });
    _sessions.clear();
    AgoraRtcEngine.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _finishTutorial;
      },
      child: Consumer<VideoNineOneOneModel>(
        builder:
            (BuildContext context, VideoNineOneOneModel model, Widget child) {
          return Scaffold(
            body: Stack(
              children: _viewRows()
                ..add(_toolbar()),
            ),
          );
        },
      ),
    );
  }

  void initializeAgora() {
    _initializeAgoraEngine();
    _initializeAgoraEventHandler();
    _addRenderView(0, (viewId) {
      // local view setup & preview
      AgoraRtcEngine.setupLocalVideo(viewId, VideoRenderMode.Fit);
      AgoraRtcEngine.startPreview();
      // state can access widget directly
      //AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
    });
  }

  void _initializeAgoraEngine() async {
    AgoraRtcEngine.create(Configs.AGORA_APP_ID);
    AgoraRtcEngine.enableVideo();
  }

  void _initializeAgoraEventHandler() {
    AgoraRtcEngine.onError = (int code) {
      // sdk error
      print("sdk error:$code");
    };

    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      // join channel success
      print("onJoinChannelSuccess:channel $channel,uid:$uid ,elapsed:$elapsed");
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      print("onUserJoined:uid:$uid ,elapsed:$elapsed");
      setState(() {
        _addRenderView(uid, (viewId) {
          AgoraRtcEngine.setupRemoteVideo(viewId, VideoRenderMode.Fit, uid);
        });
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      print("onUserOffline:uid:$uid ,reason:$reason");
      setState(() {
        _removeRenderView(uid);
      });
    };
  }

  List<VideoSession> _sessions = [];

  /// Create a native view and add a new video session object
  /// The native viewId can be used to set up local/remote view
  void _addRenderView(int uid, Function(int viewId) finished) {
    Widget view = AgoraRtcEngine.createNativeView(uid, (viewId) {
      setState(() {
        _getVideoSession(uid).viewId = viewId;
        if (finished != null) {
          finished(viewId);
        }
      });
    });
    VideoSession session = VideoSession(uid, view);
    _sessions.add(session);
  }

  /// Remove a native view and remove an existing video session object
  void _removeRenderView(int uid) {
    VideoSession session = _getVideoSession(uid);
    if (session != null) {
      _sessions.remove(session);
    }
    AgoraRtcEngine.removeNativeView(session.uid);
  }

  VideoSession _getVideoSession(int uid) {
    return _sessions.firstWhere((session) => session.uid == uid);
  }

  List<Widget> _getRenderViews() {
    return _sessions.map((session) => session.view).toList();
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video layout wrapper
  List<Widget> _viewRows() {
    List<Widget> views = _getRenderViews();
    switch (views.length) {
      case 1:
        return [
          Positioned.fill(
            key: _keyPreviewPolice,
            child: Image.asset(
              "images/110.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: MediaQuery
                .of(context)
                .padding
                .top +
                ScreenUtil().setHeight(125),
            right: 15,
            child: SizedBox(
              key: _keyPreview,
              height: ScreenUtil().setHeight(250 * 1.4),
              width: ScreenUtil().setHeight(250),
              child: views[0],
            ),
          ),
        ];
      case 2:
        return [
          Positioned.fill(
            key: _keyPreviewPolice,
            child: views[1],
          ),
          Positioned(
            top: MediaQuery
                .of(context)
                .padding
                .top +
                ScreenUtil().setHeight(125),
            right: 15,
            child: SizedBox(
              key: _keyPreview,
              height: ScreenUtil().setHeight(250 * 1.4),
              width: ScreenUtil().setHeight(250),
              child: views[0],
            ),
          ),
        ];
      default:
    }
    return [];
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                key: _keyMute,
                onPressed: () => _onToggleMute(),
                child: new Icon(
                  muted ? Icons.mic : Icons.mic_off,
                  color: muted ? Colors.white : Colors.blueAccent,
                  size: 20.0,
                ),
                shape: new CircleBorder(),
                elevation: 2.0,
                fillColor: muted ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              RawMaterialButton(
                key: _keyCall,
                onPressed: () => _onCallEnd(context),
                child: new Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35.0,
                ),
                shape: new CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
              ),
              RawMaterialButton(
                key: _keySwitchCamera,
                onPressed: () => _onSwitchCamera(),
                child: new Icon(
                  Icons.switch_camera,
                  color: Colors.blueAccent,
                  size: 20.0,
                ),
                shape: new CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(12.0),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              BWIconButton(
                key: _keyLocation,
                icon: Icons.location_on,
                onPressed: () {
                  showToast("正在获取当前位置信息...");
                  getLocation().then((location) {
                    showToast(
                      location.address,
                      dismissOtherToast: true,
                    );
                  });
                },
              ),
              BWIconButton(
                key: _keyMessage,
                icon: Icons.message,
                onPressed: () {},
              ),
              BWIconButton(
                key: _keyImage,
                icon: Icons.image,
                onPressed: () {
                  showImageSourceDialog(context);
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    doLogout(context);
  }
  Future doLogout(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("退出"),
            content: Text("确定退出吗?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("取消")),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("退出")),
            ],
          );
        }).then((v){
          if(v){
            Navigator.of(context).pop();
          }
    });
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  bool muted = false;

  void initTutorial() {
    targets.add(TargetFocus(
      keyTarget: _keyMute,
      contents: [
        ContentTarget(
          align: AlignContent.top,
          child: Text(
            "点击按钮静音🔇",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ));
    targets.add(TargetFocus(
      keyTarget: _keySwitchCamera,
      contents: [
        ContentTarget(
          align: AlignContent.top,
          child: Text(
            "点击按钮切换前后摄像头",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ));
    targets.add(TargetFocus(
      keyTarget: _keyLocation,
      contents: [
        ContentTarget(
          align: AlignContent.top,
          child: Text(
            "点击按钮向接线员发送您的当前位置",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ));
    targets.add(TargetFocus(
      keyTarget: _keyMessage,
      contents: [
        ContentTarget(
          align: AlignContent.top,
          child: Text(
            "点击消息按钮发送文字消息",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ));
    targets.add(TargetFocus(
      keyTarget: _keyImage,
      contents: [
        ContentTarget(
          align: AlignContent.top,
          child: Text(
            "点击图片按钮发送图片消息",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ));
    targets.add(TargetFocus(
      keyTarget: _keyPreview,
      contents: [
        ContentTarget(
          align: AlignContent.bottom,
          child: Text(
            "该区域是本人预览区域",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ));
    targets.add(TargetFocus(
      keyTarget: _keyCall,
      contents: [
        ContentTarget(
          align: AlignContent.top,
          child: Text(
            "点击红色按钮结束当前报警",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ));
    //targets.add(TargetFocus(
    //  keyTarget: _keyPreviewPolice,
    //  contents: [
    //    ContentTarget(
    //      align: AlignContent.right,
    //      child: Text(
    //        "该区域是接警员视频区域",
    //        style: TextStyle(color: Colors.white),
    //      ),
    //    ),
    //  ],
    //  targetPosition: TargetPosition(
    //    Size(100, 160), Offset.zero,
    //  ),
    //  shape: ShapeLightFocus.RRect,
    //));
    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      // List<TargetFocus>
      colorShadow: Colors.grey[800],
      // DEFAULT Colors.black
      // alignSkip: Alignment.bottomRight,
      textSkip: "下一步",
      // paddingFocus: 10,
      finish: () {
        print("finish");
        _finishTutorial = true;
      },
      clickTarget: (target) {
        print(target);
      },
      clickSkip: () {
        print("skip");
      },
    );

    Future.delayed(Duration(seconds: 1)).then((_) {
      _finishTutorial = false;
      tutorialCoachMark.show();
    });
  }
}

class VideoSession {
  int uid;
  Widget view;
  int viewId;

  VideoSession(int uid, Widget view) {
    this.uid = uid;
    this.view = view;
  }
}

class BWIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const BWIconButton({
    Key key,
    this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPressed?.call();
        SystemSound.play(SystemSoundType.click);
      },
      child: Container(
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0x88111111),
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(6),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}

class VideoNineOneOneModel extends ChangeNotifier {}
