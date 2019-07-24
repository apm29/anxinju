import 'dart:async';
import 'dart:convert';

import 'package:ease_life/interaction/websocket_manager.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/res/configs.dart';
import 'package:ease_life/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

import 'district_model.dart';

class ServiceChatModel extends ChangeNotifier {
  StreamSubscription streamSubscription;

  bool _audioInput = false;

  bool _showEmoji = false;

  String _uploadingHint;

  bool get showUpload {
    bool show = (_progress > 0 && _progress < 100);
    return show;
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

  bool get connected => connectionState == ConnectStatus.CONNECTED;

  bool get disconnected => connectionState == ConnectStatus.DISCONNECTED;

  static ServiceChatModel of(BuildContext context) {
    return Provider.of<ServiceChatModel>(context, listen: false);
  }

  IOWebSocketChannel _currentChannel;

  Set<IChatUser> _currentChatUsers = Set();
  IChatUser _chatSelf;
  IChatUser _currentChatUser;

  IChatUser get currentChatUser {
    if (_currentChatUsers.length == 0) {
      return null;
    }
    return _currentChatUser ?? _currentChatUsers.first;
  }

  int get currentIndex {
    if (currentChatUsers.length == 0) {
      return 0;
    }
    return currentChatUsers.toList().indexOf(currentChatUser);
  }

  set currentChatUser(IChatUser value) {
    _currentChatUser = value;
    read(value);
    notifyListeners();
  }

  ConnectStatus _connectionState = ConnectStatus.WAIT;

  ConnectStatus get connectionState => _connectionState;

  List<ChatMessage> _messages = [];

  IOWebSocketChannel get currentChannel => _currentChannel;

  Set<IChatUser> get currentChatUsers => _currentChatUsers ?? Set();

  IChatUser get chatSelf => _chatSelf;

  List<ChatMessage> messages(String userId) {
    return _messages
        .where((message) =>
            message.senderId == userId || message.receiverId == userId)
        .toList();
  }

  ServiceChatModel(BuildContext context) {
    reconnect(context);
  }

  void reconnect(BuildContext context) async {
    disconnect();
    try {
      _currentChannel = IOWebSocketChannel.connect(
        Configs.KF_EMERGENCY_WS_URL,
      );
    } catch (e) {
      print(e);
    }
    var resp = await Api.getUserInfo();
    var respDetail = await Api.getUserDetail();
    if (respDetail.success && resp.success) {
      var userName = respDetail.data.nickName ?? resp.data.userName;
      var userAvatar = respDetail.data.avatar;
      var userId = resp.data.userId;
      _chatSelf = ChatUser(
        userId,
        userAvatar,
        userName,
      );

      print('Connected to ${Configs.KF_EMERGENCY_WS_URL}');

      streamSubscription = _currentChannel.stream.listen((data) {
        print('<<<<< RECV <---- ${data.toString()}');
        _processRawData(data);
      });
      var districtId = DistrictModel.of(context).getCurrentDistrictId();

      var map = {
        "type": "init",
        "uid": "KF$userId",
        "cAppId": "${Configs.KF_APP_ID}",
        "name": "$userName",
        "avatar": "$userAvatar",
        "group": "3",
        "district_id": "$districtId"
      };

      sendData(json.encode(map));
    } else {
      return;
    }
  }

  void disconnect() {
    streamSubscription?.cancel();
    _currentChannel?.sink?.close();
    _connectionState = ConnectStatus.DISCONNECTED;
    notifyListeners();
  }

  void sendData(dynamic map) {
    print('<<<<< SEND <---- ${map.toString()}');
    _currentChannel.sink.add(map.toString());
  }

  void _processRawData(dynamic data) {
    var dataMap = json.decode(data);
    if (dataMap['code'] == 200) {
      switch (dataMap['message_type']) {
        case "isConnect":
          break;
        case "connect":
          var userInfo = dataMap['data']['user_info'];
          var add = _currentChatUsers.add(
            ChatUser(
              userInfo['id'],
              userInfo['avatar'],
              userInfo['name'],
            ),
          );
          print('add user:$add');
          break;
        case "delUser":
          _currentChatUsers
              .removeWhere((user) => user.userId == dataMap['data']['id']);
          if (_currentChatUsers.length > 0)
            currentChatUser = _currentChatUsers.first;
          break;
        case "chatMessage":
          var message = dataMap['data']['msg'];
          var add = _currentChatUsers.add(
            ChatUser(
              message['id'],
              message['avatar'],
              message['name'],
            ),
          );
          print('add user:$add');
          var userId2 = currentChatUser?.userId;
          var message2 = message['id'];
          print('${userId2 == message2}');
          _messages.insert(
            0,
            ChatMessage(
              senderId: message['id'],
              receiverId: _chatSelf.userId,
              userName: message['name'],
              userAvatar: message['avatar'],
              time: message['time'],
              content: message['content'],
              read: userId2 == message2,
            ),
          );
          playMessageSound();
          break;
      }
      _connectionState = ConnectStatus.CONNECTED;
    }
    notifyListeners();
  }

  bool self(ChatMessage chatMessage) {
    return chatMessage.senderId == _chatSelf.userId;
  }

  void addMessage(ChatMessage message) {
    _messages.insert(
      0,
      message,
    );
    notifyListeners();
  }

  int unread(String userId) {
    return messages(userId)
        .where((message) => message.read == false)
        .toList()
        .length;
  }

  void read(IChatUser value) {
    messages(value.userId).forEach((msg) {
      msg.read = true;
    });
  }
}

abstract class IChatUser {
  String userId;
  String userAvatar;
  String userName;

  IChatUser(this.userId, this.userAvatar, this.userName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IChatUser &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  String get userAvatarUrl {
    if (userAvatar?.startsWith("http") == true) {
      return userAvatar;
    } else {
      return "${Configs.KFBaseUrl}$userAvatar";
    }
  }
}

class ChatMessage {
  final String userName;
  final String userAvatar;
  final String time;
  final String content;
  final String senderId;
  final String receiverId;
  bool read;

  ChatMessage({
    this.userName,
    this.userAvatar,
    this.time,
    this.content,
    this.senderId,
    this.receiverId,
    this.read = false,
  });

  @override
  String toString() {
    return 'ChatMessage{userName: $userName, userAvatar: $userAvatar, time: $time, content: $content, senderId: $senderId, receiverId: $receiverId, read: $read}';
  }
}

class ChatUser extends IChatUser {
  ChatUser(
    String userId,
    String userAvatar,
    String userName,
  ) : super(
          userId,
          userAvatar,
          userName,
        );
}
