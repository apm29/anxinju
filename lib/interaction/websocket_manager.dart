import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ease_life/res/configs.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/persistance/db_manager.dart';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:ease_life/remote/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:soundpool/soundpool.dart';

import '../utils.dart';

enum ConnectStatus { DISCONNECTED, WAIT, CONNECTED }

class ConnectResponse {
  int code;
  String msg;
  String messageType;
  Data data;

  ConnectResponse({this.code, this.msg, this.messageType, this.data});

  ConnectResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    messageType = json['message_type'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['message_type'] = this.messageType;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'ConnectResponse{code: $code, msg: $msg, messageType: $messageType, data: $data}';
  }
}

class Data {
  Msg msg;
  String appId;
  String kfId;
  String status;
  String kfName;
  String content;

  Data({this.msg, this.appId, this.kfId, this.kfName, this.content});

  Data.fromJson(Map<String, dynamic> json) {
    msg = json['msg'] != null ? new Msg.fromJson(json['msg']) : null;
    appId = json['app_id'];
    kfId = json['kf_id'];
    kfName = json['kf_name'];
    content = json['content'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.msg != null) {
      data['msg'] = this.msg.toJson();
    }
    data['app_id'] = this.appId;
    data['kf_id'] = this.kfId;
    data['kf_name'] = this.kfName;
    data['content'] = this.content;
    data['status'] = this.status;
    return data;
  }
}

class Msg {
  String id;
  String name;
  String avatar;
  String content;
  String time;

  Msg({this.id, this.name, this.avatar, this.content, this.time});

  Msg.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar'];
    content = json['content'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['content'] = this.content;
    data['time'] = this.time;
    return data;
  }
}

enum MessageType { TEXT, IMAGE, AUDIO, VIDEO, COMMAND }

class WSMessage {
  String content;
  MessageType type;
  ConnectStatus status;
  double duration;

  String fromId;
  String toId;

  String fromAvatar;
  String fromName;
  String toAvatar;

  String group;
  int sendTime;

  WSMessage(this.content,
      {this.type = MessageType.TEXT,
      this.status,
      this.duration,
      this.toId,
      this.fromId,
      this.fromAvatar,
      this.fromName,
      this.group,
      this.sendTime,
      this.toAvatar});

  @override
  String toString() {
    return 'Message{content: $content, type: $type, status: $status, duration: $duration, fromId: $fromId, toId: $toId, fromAvatar: $fromAvatar, fromName: $fromName, toAvatar: $toAvatar, group: $group}';
  }
}

class WebSocketManager {
  IOWebSocketChannel _channel;
  ChatRoomConfig config = ChatRoomConfig();
  ConnectStatus connectStatus = ConnectStatus.DISCONNECTED;
  StreamSubscription beatStreamSubscription;

  WebSocketManager(dynamic group, BuildContext context) {
    _commandController.add(WSMessage("初始化聊天室",
        type: MessageType.COMMAND, status: ConnectStatus.WAIT));
    //连接websocket
    try {
      //ws://220.191.225.209:7001 正式
      _channel = IOWebSocketChannel.connect(Configs.KF_EMERGENCY_WS_URL);
    } catch (e) {
      _sendDisconnectedCommand("连接聊天服务器失败");
    }

    //组信息
    config.group = group.toString();
    config.appId = Configs.KF_APP_ID;
    //监听
    _channel.stream.listen((data) {
      _processRawData(data);
    });
    //配置设置
    Api.getUserDetail().then((userDetail) {
      // ok 1
      if (userDetail.success) {
        config.userAvatar = userDetail.data.avatar;
        config.userName = userDetail.data.nickName;
        config.userId = userDetail.data.userId;
        print('${config.userId}');
      } else {
        // err 1
        _sendDisconnectedCommand("获取用户信息失败");
      }
      return Future.delayed(Duration(seconds: 1));
    }).then((_) {
      //发送登录信息
      // ok 2
      _sendLoginMessage(context);
    }).catchError((e) {
      _sendLoginMessage(context);
    });
  }

  void _sendLoginMessage(BuildContext context) {
    var token = UserModel.of(context).token;
    var data =
        '{"type":"userInit", "mytoken" : "$token", "group" : "${config.group}", "cAppId":"${config.appId}" , "userinfo_param":"$token"}';
    print(' <----------- $data');
    print(' ---config--- $config');
    _channel.sink.add(data);
    beatStreamSubscription?.cancel();
    beatStreamSubscription = Observable.periodic(Duration(seconds: 20), (i) {
      return i;
    }).listen((i) {
      //断线后重新连接一次
      if (ConnectStatus.DISCONNECTED == connectStatus) {
        _sendReconnectedCommand("正在重新连接..");
        _channel.sink.add(data);
      }
    });
  }

  ///发送连接失败信息
  void _sendDisconnectedCommand(String message) {
    return _commandController.add(WSMessage(message,
        type: MessageType.COMMAND, status: ConnectStatus.DISCONNECTED));
  }

  void _sendReconnectedCommand(String message) {
    return _commandController.add(WSMessage(message,
        type: MessageType.COMMAND, status: ConnectStatus.WAIT));
  }

  void _processRawData(String data) {
    //登录信息验证
    var response = ConnectResponse.fromJson(json.decode(data));
    print('-----------> ${json.decode(data)}');

    playMessageSound();

    //ok 3
    switch (response.messageType) {
      case "serviceLogOut":
        if ("1" == response.data.status) {
          connectStatus = ConnectStatus.DISCONNECTED;
          _sendDisconnectedCommand("客服系统已断开连接");
        }
        break;
      case "connect":
        if (response.code == 200) {
          config.kfId = response.data.kfId;
          config.kfName = response.data.kfName;
          connectStatus = ConnectStatus.CONNECTED;
          print(' ---config--- $config');
          _commandController.add(WSMessage("${response.toString()}",
              type: MessageType.COMMAND,
              status: ConnectStatus.CONNECTED,
              fromName: response.data.kfName,
              fromAvatar: response.data.msg?.avatar,
              fromId: config.kfId,
              group: config.group,
              toId: config.userId));
        } else {
          //err 2
          connectStatus = ConnectStatus.DISCONNECTED;
          _sendDisconnectedCommand("登录客服系统失败:${response.msg}");
        }
        break;
      case "chatMessage":
        //处理其他信息
        if (response.code == 200) {
          var messageType = MessageType.TEXT;
          var rawContent = response.data.msg.content;
          if (rawContent != null &&
              rawContent.startsWith("img[") &&
              rawContent.endsWith("]")) {
            messageType = MessageType.IMAGE;
          }
          var message = WSMessage(
            "${response.data.msg.content}",
            type: messageType,
            status: ConnectStatus.CONNECTED,
            fromName: response.data.kfName,
            fromAvatar: response.data.msg.avatar ?? "",
            fromId: config.kfId,
            group: config.group,
            toId: config.userId,
            sendTime: DateTime.now().millisecondsSinceEpoch,
          );
          _messageController.add(message);
          ChatMessageProvider().add(ChatMessage.fromMessage(message)).then((c) {
            print('数据库插入:$c');
          });
        }
        break;
      case "wait":
        _sendDisconnectedCommand("${response.data.content}");
        break;
      default:
        _sendDisconnectedCommand("$response");
        break;
    }
  }

  ///发送一个消息
  Future<bool> sendMessage(WSMessage message) async {
    String data = "";
    bool success = false;
    if (message.type == MessageType.TEXT) {
      data =
          '{"type": "chatMessage","data": {"to_id": "${config.kfId}", "to_name": "${config.kfName}", "content": "${message.content}", "from_name": "${config.userName}","from_id": "${config.userId}", "from_avatar": "${config.userAvatar}"}}';
      _channel.sink.add(data);
      success = true;
    } else if (message.type == MessageType.AUDIO) {
      data =
          '{"type": "chatMessage","data": {"to_id": "${config.kfId}", "to_name": "${config.kfName}", "content": "audio[${message.content}]", "from_name": "${config.userName}","from_id": "${config.userId}", "from_avatar": "${config.userAvatar}"}}';
      _channel.sink.add(data);
      success = true;
    } else if (message.type == MessageType.IMAGE) {
      data =
          '{"type": "chatMessage","data": {"to_id": "${config.kfId}", "to_name": "${config.kfName}", "content": "${message.content}", "from_name": "${config.userName}","from_id": "${config.userId}", "from_avatar": "${config.userAvatar}"}}';
      _channel.sink.add(data);
      success = true;
    }
    if (success) {
      message.fromId = config.userId;
      message.toId = config.kfId;
      message.fromName = config.userName;
      message.group = config.group;
      message.fromAvatar = config.userAvatar ?? "";
      message.sendTime = DateTime.now().millisecondsSinceEpoch;
      print('------------$message');
      ChatMessageProvider().add(ChatMessage.fromMessage(message)).then((c) {
        print('数据库插入:$c');
      });
    }
    return success;
  }

  BehaviorSubject<WSMessage> _commandController = BehaviorSubject();
  BehaviorSubject<WSMessage> _messageController = BehaviorSubject();

  Observable<WSMessage> get commandMessageStream => _commandController.stream;

  Observable<WSMessage> get messageStream => _messageController.stream;

  ///登出
  void dispose() {
    print('登出:$config');
    _commandController.close();
    _channel.sink.close();
    _messageController.close();
    beatStreamSubscription.cancel();
  }
}

/// 聊天室配置信息 , 来自 userDetail 和 login
class ChatRoomConfig {
  String kfId;
  String kfName;
  String userName;
  String userId;
  String group;
  String appId;
  String userAvatar;
  String kfAvatar;

  @override
  String toString() {
    return 'ChatRoomConfig{kfId: $kfId, kfName: $kfName, userName: $userName, userId: $userId, group: $group, appId: $appId, userAvatar: $userAvatar, kfAvatar: $kfAvatar}';
  }
}
