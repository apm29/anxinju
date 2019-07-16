import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/android_encoder.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:rxdart/rxdart.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';

import '../index.dart';

class AudioRecorder {
  FlutterSound _flutterSound = FlutterSound();


  FlutterSound get flutterSound => _flutterSound;
  static AudioRecorder _instance;

  AudioRecorder._() {
    _flutterSound.setSubscriptionDuration(0.1);
  }

  factory AudioRecorder.getInstance() {
    if (_instance == null) {
      _instance = AudioRecorder._();
    }
    return _instance;
  }

  factory AudioRecorder() {
    return AudioRecorder.getInstance();
  }

  Observable<RecordStatus> get _recordStatus =>
      Observable(_flutterSound.onRecorderStateChanged);

  Observable<PlayStatus> get _playStatus =>
      Observable(_flutterSound.onPlayerStateChanged);

  Future<Observable<RecordStatus>> startRecorder(File recordFile) async {
    var permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permissionStatus == PermissionStatus.granted) {
      return await doStartRecord(recordFile);
    } else {
      var map = await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);
      if (map[PermissionGroup.storage] == PermissionStatus.granted ||
          map[PermissionGroup.storage] == PermissionStatus.unknown) {
        return await doStartRecord(recordFile);
      } else {
        throw Exception("未获得权限");
      }
    }
  }

  bool get isRecording => _isRecording;

  //以recordStatus.currentPosition>0为true
  bool _isRecording = false;
  StreamSubscription<RecordStatus> _recordSubscription;

  BehaviorSubject<RecordInfo> _recordInfoController = BehaviorSubject();

  Observable<RecordInfo> get recordInfoStream => _recordInfoController.stream;

  void dispose() {
    _recordInfoController.close();
    _playInfoController.close();
//    _playCompleteController.close();
//    _recordCompleteController.close();
  }

  doStartRecord(File recordFile) async {
    recordFile = await getRecordFile(recordFile);
    if (_isRecording) {
      _recordSubscription?.cancel();
      await _flutterSound.stopRecorder();
    }
    return _flutterSound
        .startRecorder(recordFile.path, androidEncoder: AndroidEncoder.AAC)
        .then((path) {
      _currentRecordPath = path;
      _listenOnRecord();
      return _recordStatus;
    });
  }

//  BehaviorSubject<PlayInfo> _playCompleteController = BehaviorSubject();
//  BehaviorSubject<RecordInfo> _recordCompleteController = BehaviorSubject();
//
//  Observable<PlayInfo> get playCompleteStream => _playCompleteController.stream;
//
//  Observable<RecordInfo> get recordCompleteStream =>
//      _recordCompleteController.stream;

  void _listenOnRecord() {
    _recordSubscription = _recordStatus.listen((recordStatus) {
      _isRecording = (recordStatus?.currentPosition ?? 0) > 0;
      var info = RecordInfo(_isRecording, recordStatus?.currentPosition ?? 0);
      _recordInfoController.add(info);
    });
  }

  Future<File> getRecordFile(File recordFile) async {
    if (recordFile == null) {
      var path = (await getTemporaryDirectory()).path +
          '/${DateTime.now().millisecondsSinceEpoch}_axj.' +
          (Platform.isAndroid ? 'mp4' : 'm4a');
      recordFile = File(path);
    }
    if (!recordFile.existsSync()) {
      recordFile.createSync();
    }
    return recordFile;
  }

  //返回uri
  Future<String> stopRecorder() async {
    print('$_isRecording');
    if (!_isRecording) {
      return Future.value(null);
    }
    return _flutterSound.stopRecorder().then((uri) {
      return Platform.isIOS ? uri : _currentRecordPath;
    });
  }

  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;
  StreamSubscription _playSubscription;

  BehaviorSubject<PlayInfo> _playInfoController = BehaviorSubject();

  Observable<PlayInfo> get playInfoStream => _playInfoController.stream;
  String _currentPlayPath;
  String _currentRecordPath;

  Future<Stream<PlayStatus>> startPlay(String path) async {
    if (_isPlaying) {
      _playSubscription?.cancel();
      await _flutterSound.stopPlayer();
    }
    return _flutterSound.startPlayer(path).then((path) {
      _currentPlayPath = path;
      _startListenOnPlay();
      return _playStatus;
    });
  }

  void _startListenOnPlay() {
    _playSubscription = _flutterSound.onPlayerStateChanged.listen((playStatus) {
      var position = playStatus?.currentPosition ?? 0;
      _isPlaying = position > 0 && position < playStatus.duration;
      var playInfo = PlayInfo(_isPlaying, playStatus?.currentPosition ?? 0,
          playStatus?.duration ?? 0, _currentPlayPath);
      _playInfoController.add(playInfo);
    });
  }

  Future<String> stopPlay() async {
    if (!_isPlaying) {
      return Future.value(null);
    }
    return _flutterSound.stopPlayer();
  }
}

class RecordInfo {
  static String initText = "00:00:00";
  bool recording;
  double duration;

  String get durationText =>
      DateFormat('mm:ss:SS').format(
          DateTime.fromMillisecondsSinceEpoch(duration?.floor() ?? 0)) ??
      initText;

  RecordInfo(this.recording, this.duration);
}

class PlayInfo {
  static String initText = "00:00:00";
  bool playing;
  double currentPosition;
  double duration;
  String path;

  String get positionText =>
      DateFormat('mm:ss:SS').format(
          DateTime.fromMillisecondsSinceEpoch(currentPosition?.floor() ?? 0)) ??
      initText;

  String get durationText =>
      DateFormat('mm:ss:SS').format(
          DateTime.fromMillisecondsSinceEpoch(duration?.floor() ?? 0)) ??
      initText;

  PlayInfo(this.playing, this.currentPosition, this.duration, this.path);
}

class RecordDetail {
  String path;
  double duration;

  RecordDetail(this.path, this.duration); //milli

}

class AudioInputWidget extends StatefulWidget {
  final ValueChanged<RecordDetail> onStopRecord;

  AudioInputWidget(this.onStopRecord);

  @override
  _AudioInputWidgetState createState() => _AudioInputWidgetState();
}

class _AudioInputWidgetState extends State<AudioInputWidget> {
  @override
  void initState() {
    super.initState();
  }

  double _duration = 0;

  double _minRecordDuration = 800;
  double _maxRecordDuration = 45000;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RecordInfo>(
        stream: AudioRecorder().recordInfoStream,
        builder: (context, snapshot) {
          var recording = snapshot.data?.recording ?? false;
          if (recording) {
            _duration = snapshot.data?.duration ?? 0;
            if (_duration > _maxRecordDuration) {
              stopRecord();
            }
          }
          return GestureDetector(
            onTap: () {
              Fluttertoast.showToast(msg: "长按按钮录音");
            },
            onLongPressUp: () async {
              print('onLongPressUp');
              await stopRecord();
            },
            onLongPressStart: (longPressDetail) {
              print('onLongPressStart');
              startRecord();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: recording ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: Colors.lightBlue, width: 0.5)),
              alignment: Alignment.center,
              child: Text(
                recording ? "松开结束" : "按住说话",
                style:
                    TextStyle(color: recording ? Colors.white : Colors.black),
              ),
            ),
          );
        });
  }

  void startRecord() {
    if (!AudioRecorder().isRecording) AudioRecorder().startRecorder(null);
  }

  Future<void> stopRecord() async{
    return AudioRecorder().stopRecorder().then((uri) {
      if (_duration < _minRecordDuration || uri == null) {
        Fluttertoast.showToast(msg: "录音时间过短");
        return;
      }
      widget.onStopRecord(RecordDetail(Uri.parse(uri).toFilePath(), _duration));
    });
  }
}

class AudioHintWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RecordInfo>(
      builder: (context, snapshot) {
        var recording = snapshot.data?.recording ?? false;
        var duration = snapshot.data?.duration ?? 0;
        var durationText = DateFormat('ss').format(
            DateTime.fromMillisecondsSinceEpoch(duration?.floor() ?? 0));
        return Offstage(
          offstage: !recording,
          child: Container(
            height: MediaQuery.of(context).size.width / 2.5,
            width: MediaQuery.of(context).size.width / 2.5,
            decoration: BoxDecoration(
                color: Color(0x99333333),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.mic,
                  size: 56,
                  color: Colors.white,
                ),
                Text(
                  "$durationText S",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                Text(
                  "正在录音",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
      stream: AudioRecorder().recordInfoStream,
    );
  }
}

class AudioMessageTile extends StatefulWidget {
  final String path;
  final double duration;

  AudioMessageTile(this.path, this.duration);

  @override
  _AudioMessageTileState createState() => _AudioMessageTileState();
}

class _AudioMessageTileState extends State<AudioMessageTile> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayInfo>(
        stream: AudioRecorder().playInfoStream,
        builder: (context, snapshot) {
          var position = snapshot.data?.currentPosition ?? 0;
          var duration = snapshot.data?.duration ?? 0;
          var path = snapshot.data?.path;
          var playing =
              position > 0 && position <= duration && widget.path == path;
          var messageLength = MediaQuery.of(context).size.width /
              3.5 *
              (widget.duration / 1000 / 30 + 0.8);
          if (messageLength > MediaQuery.of(context).size.width / 1.5) {
            messageLength = MediaQuery.of(context).size.width / 1.5;
          }
          return GestureDetector(
            onTap: () {
              if (playing) {
                AudioRecorder().stopPlay();
              } else {
                AudioRecorder().startPlay(widget.path);
              }
            },
            child: Container(
              constraints: BoxConstraints.tight(
                  Size(messageLength, ScreenUtil().setHeight(130))),
              decoration: BoxDecoration(
                  color: playing
                      ? Colors.lightBlueAccent
                      : Colors.lightGreenAccent,
                  border: Border.all(
                    color: Colors.lightGreen,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              padding: EdgeInsets.symmetric(horizontal: 16),
              margin: EdgeInsets.only(right: 16, left: 16, top: 4, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(getTimeText(playing, position)),
                  Expanded(child: Container()),
                  Transform.rotate(
                    child: Icon(Icons.wifi),
                    angle: 3.14 / 2,
                  )
                ],
              ),
            ),
          );
        });
  }

  String getTimeText(bool playing, position) {
    if (playing) {
      return DateFormat('ss').format(
              DateTime.fromMillisecondsSinceEpoch(position?.floor() ?? 0)) +
          '"';
    }
    if(widget.duration == null || widget.duration == 0){
      return "点击播放";
    }
    return DateFormat('ss').format(DateTime.fromMillisecondsSinceEpoch(
            widget.duration?.floor() ?? 0)) +
        '"';
  }
}
