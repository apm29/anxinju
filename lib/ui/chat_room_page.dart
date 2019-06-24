import 'package:ease_life/index.dart';
import 'package:ease_life/interaction/audio_recorder.dart';
import 'package:rxdart/rxdart.dart';

List<String> faces = [
  "[微笑]",
  "[嘻嘻]",
  "[哈哈]",
  "[可爱]",
  "[可怜]",
  "[挖鼻]",
  "[吃惊]",
  "[害羞]",
  "[挤眼]",
  "[闭嘴]",
  "[鄙视]",
  "[爱你]",
  "[泪]",
  "[偷笑]",
  "[亲亲]",
  "[生病]",
  "[太开心]",
  "[白眼]",
  "[右哼哼]",
  "[左哼哼]",
  "[嘘]",
  "[衰]",
  "[委屈]",
  "[吐]",
  "[哈欠]",
  "[抱抱]",
  "[怒]",
  "[疑问]",
  "[馋嘴]",
  "[拜拜]",
  "[思考]",
  "[汗]",
  "[困]",
  "[睡]",
  "[钱]",
  "[失望]",
  "[酷]",
  "[色]",
  "[哼]",
  "[鼓掌]",
  "[晕]",
  "[悲伤]",
  "[抓狂]",
  "[黑线]",
  "[阴险]",
  "[怒骂]",
  "[互粉]",
  "[心]",
  "[伤心]",
  "[猪头]",
  "[熊猫]",
  "[兔子]",
  "[ok]",
  "[耶]",
  "[good]",
  "[NO]",
  "[赞]",
  "[来]",
  "[弱]",
  "[草泥马]",
  "[神马]",
  "[囧]",
  "[浮云]",
  "[给力]",
  "[围观]",
  "[威武]",
  "[奥特曼]",
  "[礼物]",
  "[钟]",
  "[话筒]",
  "[蜡烛]",
  "[蛋糕]"
];

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
    return DefaultTextStyle(
      style: TextStyle(fontFamily: "SoukouMincho"),
      child: Scaffold(
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
                  if ((snapshot.data?.status ?? ConnectStatus.WAIT) !=
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
      ),
    );
  }

  Expanded buildMessageList() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ListView.builder(
              controller: _messagesController,
              physics: AlwaysScrollableScrollPhysics(),
              reverse: true,
              itemBuilder: (context, index) {
                var message = messages[index];
                if (message.response != null) {
                  return Row(
                    children: <Widget>[
                      SizedBox(
                        width: 6,
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            "${WebSocketManager.kfBaseUrl}${message.response.data.msg.avatar}"),
                      ),
                      Flexible(
                        child: buildMessageBody(context, message),
                      ),
                    ],
                  );
                }
                return Row(
                  children: <Widget>[
                    Flexible(
                      flex: 1000,
                      child: Container(),
                    ),
                    buildMessageBody(context, message),
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(manager.config.fromAvatar ?? ""),
                      child: manager.config.fromAvatar == null
                          ? Icon(
                              Icons.perm_identity,
                              color: Colors.white,
                            )
                          : Container(),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                  ],
                );
              },
              itemCount: messages.length,
            ),
          ),
          Align(
            child: AudioHintWidget(),
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }

  Widget buildMessageBody(BuildContext context, Message message) {
    switch (message.type) {
      case MessageType.TEXT:
        return buildText(context, message);
        break;
      case MessageType.IMAGE:
        return buildImage(context, message);
        break;
      case MessageType.AUDIO:
        return buildAudio(context, message);
        break;
      case MessageType.VIDEO:
        break;
      case MessageType.COMMAND:
        break;
    }
    return buildText(context, message);
  }

  Widget buildText(BuildContext context, Message message) {
    var allMatches = RegExp(r"face\[.*?\]").allMatches(message.content);
    List<Widget> children = [];
    int lastStart = 0;
    allMatches.toList().forEach((regMatcher) {
      if (regMatcher.start > 0) {
        children.add(Text(
          message.content.substring(lastStart, regMatcher.start),
          style: TextStyle(fontFamily: "SoukouMincho"),
        ));
      }
      var index = faces.indexOf(
          message.content.substring(regMatcher.start + 4, regMatcher.end));
      children.add(Image.asset("images/face/$index.gif"));

      lastStart = regMatcher.end;
    });
    if (lastStart < message.content.length) {
      children.add(Text(message.content.substring(lastStart)));
    }

    return InkWell(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message.content)).then((_) {
          Fluttertoast.showToast(msg: "文字已复制");
        });
      },
      child: Container(
        constraints: BoxConstraints.loose(
            Size.fromWidth(MediaQuery.of(context).size.width - 140)),
        decoration: BoxDecoration(
          color: Colors.lightGreenAccent,
          border: Border.all(
            color: Colors.lightGreen,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(16),
        child: Wrap(
          children: children,
        ),
      ),
    );
  }

  Widget buildAudio(BuildContext context, Message message) {
    return AudioMessageTile(message.content, message.duration);
  }

  Widget buildImage(BuildContext context, Message message) {
    var rawUrl = message.content.substring(4, message.content.length - 1);
    var url;
    if (!rawUrl.startsWith("http")) {
      url = "${WebSocketManager.kfBaseUrl}$rawUrl";
    } else {
      url = rawUrl;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return PicturePage(url);
        }));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightGreenAccent,
          border: Border.all(
            color: Colors.lightGreen,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        constraints: BoxConstraints.tightFor(
            width: MediaQuery.of(context).size.width * 0.7),
        padding: EdgeInsets.all(4),
        child: Hero(
          tag: url,
          child: Image.network(url),
        ),
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
              color: snapshot.data.status == ConnectStatus.CONNECTED
                  ? Colors.blue
                  : Colors.blueGrey,
              child: Text(
                snapshot.data.status == ConnectStatus.CONNECTED
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
      height: ScreenUtil().setHeight(200),
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
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Transform.rotate(
                          angle: audio ? 0 : 3.14 / 2,
                          child: Icon(!audio ? Icons.wifi : Icons.message))),
                ),
              ],
            ),
          ),
          Expanded(
              child: audio
                  ? AudioInputWidget((recordDetail) {
                      var message = Message(recordDetail.path,
                          type: MessageType.AUDIO,
                          duration: recordDetail.duration);
                      manager.sendMessage(message).then((success) {
                        if (success)
                          setState(() {
                            messages.insert(0, message);
                            _messagesController.animateTo(0.0,
                                duration: Duration(seconds: 1),
                                curve: Curves.ease);
                          });
                      });
                    })
                  : TextField(
                      enabled: !disabled,
                      controller: _inputController,
                      maxLines: 100,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(3),
                          border: OutlineInputBorder(),
                          fillColor: Colors.red),
                      onSubmitted: (content) {
                        _doSendMessage();
                      },
                    )),
          IconButton(
              onPressed: () {
                _doSendImage();
              },
              icon: Icon(Icons.image)),
          audio
              ? Container()
              : IconButton(
                  onPressed: () {
                    _doSendMessage();
                  },
                  padding: EdgeInsets.all(0),
                  icon: Text(
                    "发送",
                    style: TextStyle(
                      color: disabled ? Colors.grey : Colors.black,
                    ),
                  )),
        ],
      ),
    );
  }

  void _doSendMessage() {
    if (_inputController.text == null || _inputController.text.isEmpty) {
      Fluttertoast.showToast(msg: "请输入文字");
      return;
    }
    var message = Message(_inputController.text);
    _inputController.text = "";
    manager.sendMessage(message).then((success) {
      if (success)
        setState(() {
          messages.insert(0, message);
          _messagesController.animateTo(0.0,
              duration: Duration(seconds: 1), curve: Curves.ease);
        });
    });
  }

  void _doSendImage() {
    showImageSourceDialog(context, (file) {}, (f) {
      f.then((file) {
        rotateWithExifAndCompress(file).then((f) {
          Api.uploadPic(f.path).then((resp) {
            if (resp.success()) {
              var message = Message("img[${resp.data.orginPicPath}]",
                  type: MessageType.IMAGE);
              manager.sendMessage(message).then((success) {
                if (success) {
                  setState(() {
                    messages.insert(0, message);
                    _messagesController.animateTo(0.0,
                        duration: Duration(seconds: 1), curve: Curves.ease);
                  });
                } else {
                  Fluttertoast.showToast(msg: "发送失败");
                }
              });
            } else {
              Fluttertoast.showToast(msg: "发送失败");
            }
          }).catchError((e) {
            Fluttertoast.showToast(msg: "发送失败");
          });
        });
      });
    });
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
  Msg msg;
  String appId;
  String kfId;
  String kfName;
  String content;

  Data({this.msg, this.appId, this.kfId, this.kfName, this.content});

  Data.fromJson(Map<String, dynamic> json) {
    msg = json['msg'] != null ? new Msg.fromJson(json['msg']) : null;
    appId = json['app_id'];
    kfId = json['kf_id'];
    kfName = json['kf_name'];
    content = json['content'];
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

class Message {
  String content;
  MessageType type;
  ConnectStatus status;
  ConnectResponse response;
  double duration;

  Message(this.content,
      {this.type = MessageType.TEXT,
      this.status,
      this.response,
      this.duration});

  @override
  String toString() {
    return 'Message{content: $content, type: $type, data: $status, response: $response}';
  }
}

class WebSocketManager {
  static String kfBaseUrl = "http://axjkf.ciih.net/";
  IOWebSocketChannel _channel;
  ChatRoomConfig config = ChatRoomConfig();
  ConnectStatus connectStatus = ConnectStatus.DISCONNECTED;
  StreamSubscription beatStreamSubscription;

  WebSocketManager(dynamic group) {
    _commandController.add(Message("初始化聊天室",
        type: MessageType.COMMAND, status: ConnectStatus.WAIT));
    //连接websocket
    try {
      _channel = IOWebSocketChannel.connect("ws://220.191.225.209:7001");
    } catch (e) {
      _sendDisconnectedCommand("连接聊天服务器失败");
    }

    //组信息
    config.group = group.toString();
    config.appId = "YW54aW5qdS0oKSo=";
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
        '{"type":"userInit", "mytoken" : "${getToken()}", "group" : "${config.group}", "cAppId":"${config.appId}" , "userinfo_param":"${getToken()}"}';
    print(' <----------- $data');
    print(' ---config--- $config');
    beatStreamSubscription = Observable.periodic(Duration(seconds: 1), (i) {
      return i;
    }).listen((i) {});

    _channel.sink.add(data);
  }

  ///发送连接失败信息
  void _sendDisconnectedCommand(String message) {
    return _commandController.add(Message(message,
        type: MessageType.COMMAND, status: ConnectStatus.DISCONNECTED));
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
              status: ConnectStatus.CONNECTED,
              response: response));
        } else {
          //err 2
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
          _messageController.add(Message("${response.data.msg.content}",
              type: messageType,
              status: ConnectStatus.CONNECTED,
              response: response));
        }
        break;
      case "wait":
        _sendDisconnectedCommand("${response.data.content}");
        break;
      default:
        break;
    }
  }

  ///发送一个消息
  Future<bool> sendMessage(Message message) async {
    String data = "";
    if (message.type == MessageType.TEXT) {
      data =
          '{"type": "chatMessage","data": {"to_id": "${config.toId}", "to_name": "${config.toName}", "content": "${message.content}", "from_name": "${config.fromName}","from_id": "${config.fromId}", "from_avatar": "${config.fromAvatar}"}}';
      _channel.sink.add(data);
      return true;
    } else if (message.type == MessageType.AUDIO) {
      return ApiKf.uploadAudio(File(message.content)).then((resp) {
        if (resp.success()) {
          data =
              '{"type": "chatMessage","data": {"to_id": "${config.toId}", "to_name": "${config.toName}", "content": "audio[${resp.data.url}]", "from_name": "${config.fromName}","from_id": "${config.fromId}", "from_avatar": "${config.fromAvatar}"}}';
          _channel.sink.add(data);
          return true;
        } else {
          Fluttertoast.showToast(msg: "发送失败");
          return false;
        }
      }).catchError((e) {
        return false;
      });
    } else if (message.type == MessageType.IMAGE) {
      data =
          '{"type": "chatMessage","data": {"to_id": "${config.toId}", "to_name": "${config.toName}", "content": "${message.content}", "from_name": "${config.fromName}","from_id": "${config.fromId}", "from_avatar": "${config.fromAvatar}"}}';
      _channel.sink.add(data);
      return true;
    }
    return false;
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
  String appId;
  String fromAvatar;

  @override
  String toString() {
    return 'ChatRoomConfig{toId: $toId, toName: $toName, fromName: $fromName, fromId: $fromId, group: $group, fromAvatar: $fromAvatar,appId : $appId}';
  }
}
