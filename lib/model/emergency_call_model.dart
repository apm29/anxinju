import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ease_life/interaction/websocket_manager.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/service_chat_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/remote/kf_dio_utils.dart';
import 'package:ease_life/res/configs.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';

import '../utils.dart';

class EmergencyCallModel extends ChangeNotifier {
  void onUserModelReady() {
    print('onUserModelReady');
  }

  final UserModel userModel;

  ///聊天配置信息
  EmergencyRoomConfig config;

  String get kfNickName => (config.kfNickName?.isEmpty ?? false)
      ? config.kfUserName
      : config.kfNickName;

  ///WebSocket
  IOWebSocketChannel _channel;

  ///消息
  List<ServiceChatMessage> _messages = [];

  int get messageCount => _messages.length;

  bool self(int index) {
    return _messages[index].senderId == config.fromUserId;
  }

  ServiceChatMessage message(int index) {
    return _messages[index];
  }

  ///连接状态
  ConnectStatus _connectStatus = ConnectStatus.WAIT;

  ConnectStatus get connectStatus => _connectStatus;

  bool get isConnected => connectStatus == ConnectStatus.CONNECTED;

  bool get disconnected => connectStatus != ConnectStatus.CONNECTED;

  bool get waiting => connectStatus == ConnectStatus.WAIT;

  set connectStatus(ConnectStatus value) {
    if (value == _connectStatus) {
      return;
    }
    _connectStatus = value;
    notifyListeners();
  }

  EmergencyCallModel(
    String group,
    this.userModel,
    DistrictModel districtModel,
  ) {
    config = EmergencyRoomConfig(
        districtId: districtModel.getCurrentDistrictId(),
        group: group,
        fromUserId: userModel.userId,
        fromAvatar: userModel.userAvatar,
        fromNickName: userModel.userDetail.nickName,
        fromUserName: userModel.userName,
        token: userModel.token);
    _channel = IOWebSocketChannel.connect(Configs.KF_EMERGENCY_WS_URL);
    _channel.stream.listen((data) {
      _processRawData(json.decode(data));
    });

    connect();
  }

  @override
  void dispose() {
    super.dispose();
    disconnect();
  }

  StreamSubscription streamSubscription;

  Future connect() async {
    final token = config.token;
    final group = config.group;
    Map<String, dynamic> data = {
      "type": "userInit",
      "mytoken": "$token",
      "group": "$group",
      "cAppId": "${config.appId}",
      "userinfo_param": "$token",
    };
    sendData(json.encode(data).toString());

    streamSubscription = Observable.periodic(Duration(seconds: 5)).listen((_) {
      if (!isConnected) {
        connect();
      }
    });
  }

  void sendData(String data) {
    print(' SEND -----------> $data');
    _channel.sink.add(data);
  }

  Future disconnect() async {
    _channel.sink?.close();
    streamSubscription?.cancel();
  }

  ///接收WS信息
  void _processRawData(data) {
    print(' RECV <----------- $data');
    switch (data['message_type']) {
      case "serviceLogOut":
        connectStatus = ConnectStatus.DISCONNECTED;
        break;
      case "connect":
        config.kfNickName = data['data']['kf_nick_name'];
        config.kfUserName = data['data']['kf_name'];
        config.kfUserId = data['data']['kf_id'];
        print(' ---config--- $config');
        connectStatus = ConnectStatus.CONNECTED;
        loadHistory();
        break;

      case "chatMessage":
        connectStatus = ConnectStatus.CONNECTED;
        final messageBody = data['data']['msg'];
        final message = ServiceChatMessage(
          nickName: messageBody['nick_name'],
          userAvatar: messageBody['avatar'],
          time: messageBody['time'],
          content: messageBody['content'],
          senderId: config.kfUserId,
          receiverId: config.fromUserId,
          read: true,
        );
        _messages.insert(0, message);
        playMessageSound();
        break;
      case "wait":
        connectStatus = ConnectStatus.WAIT;
        break;
      default:
        return;
    }

    notifyListeners();
  }

  void sendMessage(ServiceChatMessage serviceChatMessage) {
    _messages.insert(0, serviceChatMessage);
    notifyListeners();
  }

  ///历史消息相关
  int page = 1;
  int pageNum = 20;
  bool loadingHistory = false;
  bool noMoreHistory = false;

  Future loadHistory() async {
    if (loadingHistory || noMoreHistory || disconnected || waiting) {
      return;
    }
    loadingHistory = true;
    var kfBaseResp = await ApiKf.userEmergencyCallHistoryMessage(
      config.districtId,
      Configs.KF_APP_ID,
      config.kfUserId?.replaceAll("KF", ""),
      page,
      pageNum,
    );
    if (kfBaseResp.success) {
      var list = kfBaseResp.data.map((EmergencyHistoryMessage message) {
        return ServiceChatMessage(
          nickName: message.senderNickName,
          userAvatar: message.fromAvatar,
          time: message.timeLine,
          content: message.content,
          receiverId: message.toId,
          senderId: message.fromId,
          read: true,
        );
      }).toList();
      _messages.addAll(list.reversed);
      if (list.length < pageNum) {
        noMoreHistory = true;
      }
      page++;
    } else {
      if(Platform.isAndroid)
      showToast("获取历史消息失败:${kfBaseResp.text}");
    }
    loadingHistory = false;
    notifyListeners();
    return;
  }

  ///输入框相关
  bool _audioInput = false;

  bool _showEmoji = false;
  bool _inputText = false;

  String _uploadingHint;

  bool get showUpload {
    bool show = (_progress > 0 && _progress < 100);
    return show;
  }

  bool get inputText => _inputText;

  set inputText(bool value) {
    _inputText = value;
    notifyListeners();
  }

  int _progress = 0;

  bool get showEmoji => _showEmoji;

  bool get audioInput => _audioInput;

  void switchEmoji() {
    _showEmoji = !_showEmoji;
    notifyListeners();
  }

  void closeEmoji() {
    _showEmoji = false;
    notifyListeners();
  }

  void switchAudio() {
    _audioInput = !_audioInput;
    _showEmoji = false;
    notifyListeners();
  }

  double get fraction => _progress / 100;

  set progress(int value) {
    _progress = value;
    notifyListeners();
  }

  String get uploadingHint => _uploadingHint ?? "加载中";

  set uploadingHint(String value) {
    _uploadingHint = value;
    notifyListeners();
  }

  static EmergencyCallModel of(BuildContext context) {
    return Provider.of<EmergencyCallModel>(context, listen: false);
  }
}

class EmergencyRoomConfig {
  String fromUserId;
  String kfUserId;
  String fromAvatar;
  String kfAvatar;
  String kfUserName;
  String fromUserName;
  String kfNickName;
  String fromNickName;

  String group;
  String token;

  final appId = Configs.KF_APP_ID;

  int districtId;

  EmergencyRoomConfig({
    this.fromUserId,
    this.kfUserId,
    this.fromAvatar,
    this.kfAvatar,
    this.kfUserName,
    this.fromUserName,
    this.kfNickName,
    this.fromNickName,
    this.group,
    this.token,
    this.districtId,
  });

  @override
  String toString() {
    return 'EmergencyRoomConfig{fromUserId: $fromUserId, toUserId: $kfUserId, fromAvatar: $fromAvatar, toAvatar: $kfAvatar, toUserName: $kfUserName, fromUserName: $fromUserName, toNickName: $kfNickName, fromNickName: $fromNickName, group: $group, token: $token, appId: $appId}';
  }
}
