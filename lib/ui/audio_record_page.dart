import 'dart:async';
import 'dart:collection';

import 'package:ease_life/index.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordPage extends StatefulWidget {
  @override
  _AudioRecordPageState createState() => _AudioRecordPageState();
}

class _AudioRecordPageState extends State<AudioRecordPage> {
  bool isRecording = false;
  FlutterSound soundController = FlutterSound();
  List<Object> paths = ["/storage/emulated/0/default.m4a"];
  String currentRecordingPath;
  StreamSubscription _recordSubscription;
  StreamSubscription _playSubscription;

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
                content: Text("您拒绝了一些必要权限,安心居将无法正常运行"),
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
  }

  @override
  Widget build(BuildContext context) {
    print('$paths');
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
                    onTap: () async{
                      _playSubscription?.cancel();
                      print('start play');
                      await soundController.startPlayer(path);
                       _playSubscription =  soundController.onPlayerStateChanged
                          .listen((playStatus) {
                        if (playStatus == null) return;
                        if (playStatus.duration == playStatus.currentPosition) {
                          print('stop play');
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(12),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        color: Colors.lightGreen,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Text(path),
                    ),
                  );
                }).toList(),
              ),
            ),
            GestureDetector(
              onTapDown: (TapDownDetails tapDetail) async {
                print('start');
                var directory = await getApplicationDocumentsDirectory();
                currentRecordingPath =
                    '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
                await soundController.startRecorder(currentRecordingPath);

                _recordSubscription = soundController.onRecorderStateChanged
                    .listen((recordState) {
                  if (recordState == null) return;
                  var dateTime = DateTime.fromMillisecondsSinceEpoch(
                      recordState.currentPosition.toInt());
                });
                setState(() {
                  isRecording = true;
                });
              },
              onTapUp: (TapUpDetails tapDetail) async {
                print('stop');
                await soundController.stopRecorder();
                paths.add(currentRecordingPath);
                print('$paths');
                _recordSubscription?.cancel();
                Fluttertoast.showToast(msg: "语音时间太短");
                setState(() {
                  isRecording = false;
                });
              },
              onLongPressUp: () async {
                print('stop');
                await soundController.stopRecorder();
                paths.add(currentRecordingPath);
                print('$paths');
                _recordSubscription?.cancel();
                setState(() {
                  isRecording = false;
                });
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: isRecording ? Colors.green : Colors.indigo,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 9),
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
