import 'dart:async';
import 'package:ease_life/index.dart';
import 'package:ease_life/res/strings.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class AudioRecordPage extends StatefulWidget {
  static String routeName = "/audio";

  @override
  _AudioRecordPageState createState() => _AudioRecordPageState();
}

class _AudioRecordPageState extends State<AudioRecordPage> {
  AudioController controller = AudioController();

  List<String> paths = [
  ];
  String currentRecordingPath;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.wait([
      PermissionHandler().checkPermissionStatus(PermissionGroup.microphone),
      PermissionHandler().checkPermissionStatus(PermissionGroup.storage),
    ]).then((status) {
      if (status[0] != PermissionStatus.granted ||
          status[1] != PermissionStatus.granted) {
        return PermissionHandler().requestPermissions(
            [PermissionGroup.microphone, PermissionGroup.storage]);
      } else {
        return null;
      }
    }).then((map) {
      if (map == null) {
        return;
      }
      if (map[PermissionGroup.microphone] != PermissionStatus.granted ||
          map[PermissionGroup.storage] != PermissionStatus.granted &&
              map[PermissionGroup.storage] != PermissionStatus.unknown) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("警告"),
                content: Text("您拒绝了一些必要权限,${Strings.appName}将无法正常运行"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                      },
                      child: Text("前往设置界面"))
                ],
              );
            });
      }
    });
    controller.recordingStatusStream.listen((recording) {
      print('$recording');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("语音"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("保安频道"),
            Expanded(
              child: ListView(
                children: paths.map((path) {
                  return GestureDetector(
                    onTap: () async {
                      if (controller.isPlaying) {
                        controller.stopPlay();
                      } else {
                        controller.startPlay(path);
                      }
                    },
                    child: StreamBuilder<bool>(
                        stream: controller.playingStatusStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data &&
                              controller.currentPlayPath == path) {
                            return Container(
                              margin: EdgeInsets.all(12),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.greenAccent),
                                color: Colors.lightGreen,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(child: Text(path)),
                                  Text("播放中..."),
                                  RotatedBox(
                                    child: Icon(
                                      Icons.wifi,
                                      color: Colors.white,
                                    ),
                                    quarterTurns: 1,
                                  )
                                ],
                              ),
                            );
                          } else {
                            return Container(
                              margin: EdgeInsets.all(12),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green),
                                color: Colors.lightGreen,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Text(path),
                            );
                          }
                        }),
                  );
                }).toList(),
              ),
            ),
            StreamBuilder<bool>(
                stream: controller.recordingStatusStream,
                builder: (context, snapshot) {
                  print('$snapshot');
                  var isRecording = snapshot.hasData && snapshot.data;
                  return GestureDetector(
                    onTapDown: (TapDownDetails tapDetail) async {
                      print('start');
                      var directory = await getApplicationDocumentsDirectory();
                      currentRecordingPath =
                          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
                      controller.startRecord(currentRecordingPath);
                    },
                    onTapUp: (TapUpDetails tapDetail) async {
                      print('stop');
                      controller.stopRecord();
                      Fluttertoast.showToast(msg: "语音时间太短");
                      setState(() {});
                    },
                    onLongPressUp: () async {
                      print('stop');
                      controller.stopRecord();
                      paths.add(currentRecordingPath);
                      setState(() {});
                    },
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueGrey,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              color:
                                  isRecording ? Colors.green : Colors.white70,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 9),
                            child: Icon(
                              Icons.mic,
                              color: isRecording ? Colors.white : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}

class AudioController {
  final FlutterSound flutterSound = FlutterSound();

  AudioController() {
    flutterSound.setSubscriptionDuration(0.1);
  }

  bool isRecording = false;
  String currentRecordingPath;
  bool isPlaying = false;
  String currentPlayPath;

  PublishSubject<bool> _recordingStatusController = PublishSubject();
  PublishSubject<bool> _playingStatusController = PublishSubject();

  Observable<bool> get recordingStatusStream =>
      _recordingStatusController.stream;

  Observable<bool> get playingStatusStream => _playingStatusController.stream;

  dispose() {
    _recordingStatusController.close();
    _playingStatusController.close();
  }

  void startRecord(String path) {
    if (isRecording) {
      stopRecord();
      return;
    }
    flutterSound.startRecorder(path).then((path) {
      flutterSound.onRecorderStateChanged.listen((RecordStatus recordStatus) {
        isRecording = recordStatus != null && recordStatus.currentPosition > 0;
        _recordingStatusController.add(isRecording);
        if ((recordStatus?.currentPosition ?? 0) > 2000) {
          stopRecord();
        }
      });
    }).catchError((e) {
      //start record fail
      print('Error:$e');
    });
  }

  void stopRecord() {
    if (!isRecording) return;
    flutterSound.stopRecorder().then((s) {
      isRecording = false;
      _recordingStatusController.add(isRecording);
    }).catchError((e) {
      //stop record fail
      print('Error:$e');
    });
  }

  void startPlay(String path) {
    if (isPlaying) {
      stopPlay();
      return;
    }
    flutterSound.startPlayer(path).then((s) {
      flutterSound.onPlayerStateChanged.listen((PlayStatus playStatus) {
        print('$playStatus');
        isPlaying = playStatus != null &&
            playStatus.currentPosition > 0 &&
            playStatus.currentPosition < playStatus.duration;
        currentPlayPath = isPlaying ? path : null;

        _playingStatusController.add(isPlaying);
      });
    }).catchError((e) {
      //start play fail
      print('Error:$e');
      stopPlay();
    });
  }

  void stopPlay() {
    if (!isPlaying) return;
    flutterSound.stopPlayer().then((s) {
      isPlaying = false;
      currentPlayPath = null;
      _playingStatusController.add(isPlaying);
    }).catchError((e) {
      //stop play fail
      print('Error:$e');
    });
  }
}
