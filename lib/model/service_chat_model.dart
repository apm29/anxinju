import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ease_life/interaction/websocket_manager.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/remote/kf_dio_utils.dart';
import 'package:ease_life/res/configs.dart';
import 'package:ease_life/utils.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

import 'district_model.dart';

class ServiceChatModel extends ChangeNotifier {
  StreamSubscription streamSubscription;

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

  List<ServiceChatMessage> _messages = [];

  IOWebSocketChannel get currentChannel => _currentChannel;

  Set<IChatUser> get currentChatUsers => _currentChatUsers ?? Set();

  IChatUser get chatSelf => _chatSelf;

  List<ServiceChatMessage> messages(String userId) {
    return _messages
        .where((message) =>
            message.senderId == userId || message.receiverId == userId)
        .toList();
  }

  ServiceChatModel(BuildContext context) {
    reconnect(context);
  }

  int districtId;

  void reconnect(BuildContext context) async {
    disconnect();
    await DistrictModel.of(context).tryFetchCurrentDistricts();
    districtId = DistrictModel.of(context).getCurrentDistrictId();
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
      var userName = resp.data.userName;
      var nickName = respDetail.data.nickName;
      var userAvatar = respDetail.data.avatar;
      var userId = resp.data.userId;
      print('${respDetail.data.avatar}');
      _chatSelf = ChatUser(
        userId,
        userAvatar,
        nickName,
      );

      print('Connected to ${Configs.KF_EMERGENCY_WS_URL}');

      streamSubscription = _currentChannel.stream.listen((data) {
        print('<<<<< RECV <---- ${data.toString()}');
        _processRawData(data);
      });
      var map = {
        "type": "init",
        "uid": "KF$userId",
        "cAppId": "${Configs.KF_APP_ID}",
        "name": "$userName",
        "nick_name": "$nickName",
        "avatar": "$userAvatar",
        //"group": "3",//客服
        "group": "25", //紧急呼叫
        "district_id": "$districtId"
      };

      sendData(json.encode(map));
    } else {
      return;
    }
  }

  void getOnlineUsers(int districtId) async {
    var resp = await ApiKf.onlineChatUserQuery(
        districtId.toString(), Configs.KF_APP_ID);
    if (resp.success) {
      var userList = resp.data
          .map(
            (onlineChatUser) => ChatUser(
              onlineChatUser.userId,
              onlineChatUser.userAvatar,
              onlineChatUser.nickName,
            ),
          )
          .toList();
      userList.forEach((chatUser) {
        _historyConfigMap[chatUser.userId] = HistoryConfig();
      });
      currentChatUsers.addAll(userList);
      if (_currentChatUsers.length > 0)
        currentChatUser = _currentChatUsers.first;
      refresh(districtId);
    } else {
      showToast("获取在线用户失败");
    }
  }

  void refresh(int districtId) {
    _historyConfigMap.forEach((userId, config) {
      config.reset();
    });
    currentChatUsers.forEach((user) {
      loadHistory(user.userId, districtId);
    });
  }

  void disconnect() {
    streamSubscription?.cancel();
    _currentChannel?.sink?.close();
    _connectionState = ConnectStatus.DISCONNECTED;

    _messages = [];
    _currentChatUsers.clear();
    _historyConfigMap.clear();
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
          getOnlineUsers(districtId);
          break;
        case "connect":
          var userInfo = dataMap['data']['user_info'];
          var add = _currentChatUsers.add(
            ChatUser(
              userInfo['id'],
              userInfo['avatar'],
              userInfo['nick_name'],
            ),
          );
          _historyConfigMap[userInfo['id']] = HistoryConfig();
          _messages.removeWhere((message) {
            return message.receiverId ==userInfo['id'] ||
                message.senderId == userInfo['id'];
          });
          if (add) {
            loadHistory(userInfo['id'], districtId);
          }
          if (_currentChatUsers.length > 0)
            currentChatUser = _currentChatUsers.first;
          print('add user - $add:$userInfo');
          break;
        case "delUser":
          _currentChatUsers.removeWhere((user) {
            return user.userId == dataMap['data']['id'];
          });

          _messages.removeWhere((message) {
            return message.receiverId == dataMap['data']['id'] ||
                message.senderId == dataMap['data']['id'];
          });

          if (_currentChatUsers.length > 0)
            currentChatUser = _currentChatUsers.first;
          break;
        case "chatMessage":
          var message = dataMap['data']['msg'];
          var add = _currentChatUsers.add(
            ChatUser(
              message['id'],
              message['avatar'],
              message['nick_name'],
            ),
          );
          print('add user:$add');
          var userId2 = currentChatUser?.userId;
          var message2 = message['id'];
          _messages.insert(
            0,
            ServiceChatMessage(
              senderId: message['id'],
              receiverId: _chatSelf.userId,
              nickName: message['nick_name'],
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

  bool self(ServiceChatMessage chatMessage) {
    return chatMessage.senderId == _chatSelf.userId;
  }

  void addMessage(ServiceChatMessage message) {
    _messages.insert(
      0,
      message,
    );
    _inputText = false;
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

  Map<String, HistoryConfig> _historyConfigMap = {};

  Future loadHistory(String userId, var districtId) async {
    var page = _historyConfigMap[userId].page;
    var pageNum = _historyConfigMap[userId].pageNum;
    if (_historyConfigMap[userId].loadingHistory ||
        _historyConfigMap[userId].noMoreHistory) {
      return;
    }
    _historyConfigMap[userId].loadingHistory = true;
    var kfBaseResp = await ApiKf.propertyEmergencyHistoryMessagesQuery(
      districtId,
      Configs.KF_APP_ID,
      userId,
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
          receiverId: message.toId.replaceAll("KF", ""),
          senderId: message.fromId.replaceAll("KF", ""),
          read: true,
        );
      }).toList();
      _messages.addAll(list.reversed);
      if (list.length < pageNum) {
        _historyConfigMap[userId].noMoreHistory = true;
      }
      _historyConfigMap[userId].increase();
    } else {
      if(Platform.isAndroid)
      showToast("获取历史消息失败:${kfBaseResp.text}");
    }
    _historyConfigMap[userId].loadingHistory = false;
    notifyListeners();
    return;
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
      return "${Configs.KFBaseUrl}${userAvatar ?? ""}";
    }
  }

  @override
  String toString() {
    return 'IChatUser{userId: $userId, userAvatar: $userAvatar, userName: $userName}';
  }


}

class ServiceChatMessage {
  final String nickName;
  final String userAvatar;
  final String time;
  final String content;
  final String senderId;
  final String receiverId;
  bool read;

  ServiceChatMessage({
    this.nickName,
    this.userAvatar,
    this.time,
    this.content,
    this.senderId,
    this.receiverId,
    this.read = false,
  });

  String get userAvatarUrl {
    if (userAvatar?.startsWith("http") == true) {
      return userAvatar;
    } else {
      return "${Configs.KFBaseUrl}${userAvatar ?? ""}";
    }
  }

  @override
  String toString() {
    return 'ChatMessage{userName: $nickName, userAvatar: $userAvatar, time: $time, content: $content, senderId: $senderId, receiverId: $receiverId, read: $read}';
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
        ){
    print('==========> userName: $userName');
  }
}

class HistoryConfig {
  int page = 1;
  final int pageNum = 20;
  bool loadingHistory = false;
  bool noMoreHistory = false;

  void increase() {
    page += 1;
  }

  void reset() {
    page = 1;
    loadingHistory = false;
    noMoreHistory = false;
  }
}
