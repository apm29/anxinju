import 'dart:convert';

import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../index.dart';
import 'widget/audio_input_widget.dart';

class ChatRoomPage extends StatefulWidget {
  static String routeName = "/chat";

  ChatRoomPage({Key key}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  String title;
  String group;

  _ChatRoomPageState();

  WebSocketManager manager;

  Observable<Message> get commandMessageStream => manager.commandMessageStream;

  TextEditingController _inputController = TextEditingController();
  ScrollController _messagesController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }

  List<Message> messages = [];

  @override
  Widget build(BuildContext context) {
    var arguments = ModalRoute.of(context).settings.arguments;
    if (arguments is Map) {
      title = arguments['title'];
      group = arguments['group'];
      if (manager == null) {
        manager = WebSocketManager(group);
        manager.messageStream.listen((message) {
          setState(() {
            messages.insert(0, message);
          });
          switch (message.type) {
            case MessageType.TEXT:
              break;
            case MessageType.IMAGE:
              break;
            case MessageType.AUDIO:
              break;
            case MessageType.VIDEO:
              break;
            case MessageType.COMMAND:
              break;
          }
        });
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: <Widget>[
          buildStatusPart(),
          buildMessageList(),
          Container(
            color: Colors.grey[400],
            height: 0.3,
          ),
          StreamBuilder<Message>(
              stream: commandMessageStream,
              builder: (context, snapshot) {
                if ((snapshot.data?.data ?? ConnectStatus.WAIT) !=
                    ConnectStatus.CONNECTED) {
                  return AbsorbPointer(
                    child: Container(
                      color: Color(0x33333333),
                      child: buildInputPart(disabled: true),
                    ),
                  );
                }
                return buildInputPart(disabled: false);
              })
        ],
      ),
    );
  }

  Expanded buildMessageList() {
    return Expanded(
      child: ListView.builder(
        controller: _messagesController,
        physics: AlwaysScrollableScrollPhysics(),
        reverse: true,
        itemBuilder: (context, index) {
          var message = messages[index];
          if (message.response != null) {
            return Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      border: Border.all(
                        color: Colors.lightBlue,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  child: Text(message.content),
                ),
                Expanded(child: Container()),
              ],
            );
          }
          return Row(
            children: <Widget>[
              Expanded(child: Container()),
              Container(
                decoration: BoxDecoration(
                    color: Colors.lightGreenAccent,
                    border: Border.all(
                      color: Colors.lightGreen,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                child: Text(message.content),
              ),
            ],
          );
        },
        itemCount: messages.length,
      ),
    );
  }

  StreamBuilder<Message> buildStatusPart() {
    return StreamBuilder<Message>(
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.type == MessageType.COMMAND) {
            return Container(
              alignment: Alignment.center,
              color: snapshot.data.data == ConnectStatus.CONNECTED
                  ? Colors.blue
                  : Colors.blueGrey,
              child: Text(
                snapshot.data.data == ConnectStatus.CONNECTED
                    ? "正在与 ${snapshot.data.response.data.kfName} 交流"
                    : snapshot.data.content,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return Container();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
      stream: commandMessageStream,
    );
  }

  bool audio = false;

  Widget buildInputPart({bool disabled = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      height: ScreenUtil().setHeight(240),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                audio = !audio;
              });
            },
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Transform.rotate(
                          angle: audio?0:3.14/2,
                          child: Icon(!audio ? Icons.wifi : Icons.message))),
                ),
              ],
            ),
          ),
          Expanded(
              child: audio
                  ? AudioInputWidget()
                  : TextField(
                enabled: !disabled,
                controller: _inputController,
                maxLines: 100,
                decoration: InputDecoration(border: OutlineInputBorder()),
              )),
          FlatButton.icon(
              onPressed: () {
                var message = Message(_inputController.text);
                _inputController.text = "";
                manager.sendMessage(message);
                setState(() {
                  messages.insert(0, message);
                  _messagesController.animateTo(0.0,
                      duration: Duration(seconds: 1), curve: Curves.ease);
                });
              },
              icon: Icon(
                Icons.send,
                size: 48,
                color: disabled ? Colors.blueGrey : Colors.blue,
              ),
              label: Text(
                "发送",
                style: TextStyle(
                  color: disabled ? Colors.grey : Colors.black,
                ),
              ))
        ],
      ),
    );
  }
}

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
  String kfId;
  String kfName;

  Data(
      {this.kfId,
        this.kfName,
        this.id,
        this.name,
        this.avatar,
        this.content,
        this.time});

  String id;
  String name;
  String avatar;
  String content;
  String time;

  Data.fromJson(Map<String, dynamic> json) {
    kfId = json['kf_id'];
    kfName = json['kf_name'];
    id = json['id'];
    name = json['name'];
    avatar = json['avatar'];
    content = json['content'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kf_id'] = this.kfId;
    data['kf_name'] = this.kfName;
    data['id'] = this.id;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['content'] = this.content;
    data['time'] = this.time;
    return data;
  }

  @override
  String toString() {
    return 'Data{kfId: $kfId, kfName: $kfName, id: $id, name: $name, avatar: $avatar, content: $content, time: $time}';
  }
}

enum MessageType { TEXT, IMAGE, AUDIO, VIDEO, COMMAND }

class Message {
  String content;
  MessageType type;
  ConnectStatus data;
  ConnectResponse response;

  Message(this.content,
      {this.type = MessageType.TEXT, this.data, this.response});
}

class WebSocketManager {
  IOWebSocketChannel _channel;
  ChatRoomConfig config = ChatRoomConfig();
  ConnectStatus connectStatus = ConnectStatus.DISCONNECTED;
  StreamSubscription beatStreamSubscription;

  WebSocketManager(dynamic group) {
    _commandController.add(
        Message("初始化聊天室", type: MessageType.COMMAND, data: ConnectStatus.WAIT));
    //连接websocket
    Future.sync(() {
      return _channel = IOWebSocketChannel.connect("ws://60.190.188.139:9508");
    }).then((c) {}).catchError((e) {
      _sendDisconnectedCommand("连接聊天服务器失败:${e.toString()}");
    });

    //组信息
    config.group = group.toString();
    //监听
    _channel.stream.listen((data) {
      _processRawData(data);
    });
    //配置设置
    Api.getUserDetail().then((userDetail) {
      // ok 1
      if (userDetail.success()) {
        config.fromAvatar = userDetail.data.avatar;
        config.fromName = userDetail.data.nickName;
        config.fromId = userDetail.data.userId;
      } else {
        // err 1
        _sendDisconnectedCommand("获取用户信息失败");
      }
      return Future.delayed(Duration(seconds: 1));
    }).then((_) {
      //发送登录信息
      // ok 2
      _sendLoginMessage();
    });
  }

  void _sendLoginMessage() {
    var data =
        '{"type":"userInit", "mytoken" : "${getToken()}", "group" : "${config.group}"}';
    print(' <----------- $data');
    beatStreamSubscription = Observable.periodic(Duration(seconds: 1), (i) {
      return i;
    }).listen((i) {});

    _channel.sink.add(data);
  }

  ///发送连接失败信息
  void _sendDisconnectedCommand(String message) {
    return _commandController.add(Message(message,
        type: MessageType.COMMAND, data: ConnectStatus.DISCONNECTED));
  }

  void _processRawData(String data) {
    //登录信息验证
    var response = ConnectResponse.fromJson(json.decode(data));
    print('-----------> ${json.decode(data)}');
    //ok 3
    switch (response.messageType) {
      case "connect":
        if (response.code == 200) {
          config.toId = response.data.kfId;
          config.toName = response.data.kfName;
          connectStatus = ConnectStatus.CONNECTED;

          _commandController.add(Message("${response.toString()}",
              type: MessageType.COMMAND,
              data: ConnectStatus.CONNECTED,
              response: response));
        } else {
          //err 2
          _sendDisconnectedCommand("登录客服系统失败:${response.msg}");
        }
        break;
      case "chatMessage":
      //处理其他信息
        if (response.code == 200) {
          _messageController.add(Message("${response.data.content}",
              type: MessageType.TEXT,
              data: ConnectStatus.CONNECTED,
              response: response));
        }
        break;
      default:
        break;
    }
  }

  ///发送一个消息
  void sendMessage(Message message) {
    String data = "";
    if (message.type == MessageType.TEXT) {
      data =
      '{"type": "chatMessage","data": {"to_id": "${config.toId}", "to_name": "${config.toName}", "content": "${message.content}", "from_name": "${config.fromName}","from_id": "${config.fromId}", "from_avatar": "${config.fromAvatar}"}}';
    }
    _channel.sink.add(data);
  }

  BehaviorSubject<Message> _commandController = BehaviorSubject();
  BehaviorSubject<Message> _messageController = BehaviorSubject();

  Observable<Message> get commandMessageStream => _commandController.stream;

  Observable<Message> get messageStream => _messageController.stream;

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
  String toId;
  String toName;
  String fromName;
  String fromId;
  String group;
  String fromAvatar;

  @override
  String toString() {
    return 'ChatRoomConfig{toId: $toId, toName: $toName, fromName: $fromName, fromId: $fromId, group: $group, fromAvatar: $fromAvatar}';
  }
}
