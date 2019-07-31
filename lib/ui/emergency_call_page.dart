import 'package:ease_life/index.dart';
import 'package:ease_life/interaction/audio_recorder.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class EmergencyCallPage extends StatefulWidget {
  static String routeName = "/emergency_call";

  final String group;
  final String title;

  EmergencyCallPage({Key key, this.group, this.title}) : super(key: key);

  @override
  _EmergencyCallPageState createState() => _EmergencyCallPageState();
}

class _EmergencyCallPageState extends State<EmergencyCallPage> {
  String title;
  String group;

  _EmergencyCallPageState();

  WebSocketManager manager;

  Observable<WSMessage> get commandMessageStream =>
      manager.commandMessageStream;

  TextEditingController _inputController = TextEditingController();
  ScrollController _listViewController = ScrollController();

  BehaviorSubject<bool> _emotionIconController = BehaviorSubject();

  Observable<bool> get _emotionVisibilityStream =>
      _emotionIconController.stream;
  FocusNode _editFocusNode = FocusNode();
  List<WSMessage> messages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var arguments = ModalRoute.of(context).settings.arguments;
    if (arguments is Map) {
      title = arguments['title'];
      group = arguments['group'];
    } else {
      title = widget.title;
      group = widget.group;
    }

    _editFocusNode.addListener(() {
      if (_editFocusNode.hasFocus) {
        emotionIcon = false;
        _emotionIconController.add(emotionIcon);
      }
    });
    if (manager == null) {
      initManager();
    }
  }

  void initManager() {
    manager = WebSocketManager(group, context);
    manager.messageStream.listen((message) {
      setState(() {
        messages.insert(0, message);
        _listViewController.animateTo(0,
            duration: Duration(seconds: 1), curve: Curves.ease);
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
    Api.getUserInfo().then((resp) {
      if (resp.success) {
        ChatMessageProvider().open().then((db) {
          db.getAll(group, resp.data.userId).then((list) {
            var added = list.map((chatMessage) {
              return chatMessage.toMessage();
            }).toList();
            setState(() {
              messages.addAll(added);
            });
          });
        });
      }
    });
  }

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
    _emotionIconController.close();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(fontFamily: "SoukouMincho"),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            FlatButton.icon(
              onPressed: () {
                manager?.dispose();
                initManager();
              },
              icon: Icon(Icons.repeat),
              label: Text("重连"),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            buildStatusPart(),
            buildMessageList(),
            Container(
              color: Colors.grey[400],
              height: 0.3,
            ),
            StreamBuilder<WSMessage>(
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
              },
              initialData: null,
            ),
            StreamBuilder<bool>(
              initialData: false,
              stream: _emotionVisibilityStream,
              builder: (context, snapshot) {
                bool visible = snapshot.data ?? false;
                return Offstage(
                  offstage: !visible,
                  child: Wrap(
                    children: faces.map((name) {
                      return InkWell(
                        onTap: () {
                          _inputController.text =
                              _inputController.text + "face" + name;
                        },
                        child: Container(
                          margin: EdgeInsets.all(ScreenUtil().setWidth(12)),
                          child: Image.asset(
                              "images/face/${faces.indexOf(name)}.gif"),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Expanded buildMessageList() {
    return Expanded(
      child: StreamBuilder<WSMessage>(
        stream: commandMessageStream,
        builder: (context, snapshot) {
          if ((snapshot.data?.status ?? ConnectStatus.WAIT) ==
              ConnectStatus.WAIT) {
            return Center(child: CircularProgressIndicator());
          }
          return GestureDetector(
            onTap: () {
              _editFocusNode.unfocus();
              emotionIcon = false;
              _emotionIconController.add(emotionIcon);
            },
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ListView.builder(
                    controller: _listViewController,
                    physics: AlwaysScrollableScrollPhysics(),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      var message = messages[index];
                      var child;
                      if (message.fromId == manager.config.kfId) {
                        child = Row(
                          children: <Widget>[
                            SizedBox(
                              width: 6,
                            ),
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  "${Configs.KFBaseUrl}${message.fromAvatar}"),
                            ),
                            Flexible(
                              child: buildMessageBody(context, message, false),
                            ),
                          ],
                        );
                      } else {
                        child = Row(
                          children: <Widget>[
                            Flexible(
                              flex: 1000,
                              child: Container(),
                            ),
                            buildMessageBody(context, message, true),
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(manager.config.userAvatar ?? ""),
                              child: manager.config.userAvatar == null
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
                      }
                      return child;
                    },
                  ),
                ),
                Align(
                  child: AudioHintWidget(),
                  alignment: Alignment.center,
                ),
              ],
            ),
          );
        },
        initialData: null,
      ),
    );
  }

  Widget buildMessageBody(BuildContext context, WSMessage message, bool send) {
    switch (message.type) {
      case MessageType.TEXT:
        return buildText(context, message, send);
        break;
      case MessageType.IMAGE:
        return buildImage(context, message, send);
        break;
      case MessageType.AUDIO:
        return buildAudio(context, message, send);
        break;
      case MessageType.VIDEO:
        break;
      case MessageType.COMMAND:
        break;
    }
    return buildText(context, message, send);
  }

  Widget buildText(BuildContext context, WSMessage message, bool send) {
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
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            send ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          _buildTimeText(message),
          Container(
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
            margin: EdgeInsets.only(
                left: send ? 16 : 4, right: send ? 4 : 16, top: 2, bottom: 4),
            child: Wrap(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  String _getMessageSendTime(WSMessage message) {
    var time = DateTime.fromMillisecondsSinceEpoch(message.sendTime);
    if (isToday(time)) {
      return DateFormat("HH:mm:ss").format(time);
    } else {
      return DateFormat("yyyy-MM-dd HH:mm:ss").format(time);
    }
  }

  bool isToday(DateTime time) {
    return time.difference(DateTime.now()).inDays < 1;
  }

  Widget buildAudio(BuildContext context, WSMessage message, bool send) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          send ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        _buildTimeText(message),
        AudioMessageTile(message.content, message.duration),
      ],
    );
  }

  Widget buildImage(BuildContext context, WSMessage message, bool send) {
    var rawUrl = message.content.substring(4, message.content.length - 1);
    var url;
    if (!rawUrl.startsWith("http")) {
      url = "${Configs.KFBaseUrl}$rawUrl";
    } else {
      url = rawUrl;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return PicturePage(url);
        }));
      },
      child: Column(
        crossAxisAlignment:
            send ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 6,
          ),
          _buildTimeText(message),
          Container(
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
              child: Image.network(
                url,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeText(WSMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        _getMessageSendTime(message),
        style: TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  StreamBuilder<WSMessage> buildStatusPart() {
    return StreamBuilder<WSMessage>(
      builder: (_, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data.type == MessageType.COMMAND) {
            return Container(
              alignment: Alignment.center,
              color: snapshot.data.status == ConnectStatus.CONNECTED
                  ? Colors.blue
                  : snapshot.data.status == ConnectStatus.WAIT
                      ? Colors.amberAccent
                      : Colors.blueGrey,
              child: Text(
                snapshot.data.status == ConnectStatus.CONNECTED
                    ? "正在与 ${snapshot.data.fromName} 交流"
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
      initialData: null,
    );
  }

  bool emotionIcon = false;
  bool audio = false;

  Widget buildInputPart({bool disabled = false}) {
    return IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.all(16),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      _doSendAudio(recordDetail);
                    })
                  : SizedBox(
                      height: ScreenUtil().setHeight(120),
                      child: TextField(
                        focusNode: _editFocusNode,
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
                      ),
                    ),
            ),
            IconButton(
                onPressed: () {
                  _doSendImage();
                },
                icon: Icon(Icons.image)),
            audio
                ? Container()
                : IconButton(
                    onPressed: () {
                      _editFocusNode.unfocus();
                      emotionIcon = !emotionIcon;
                      _emotionIconController.add(emotionIcon);
                    },
                    padding: EdgeInsets.all(0),
                    icon: StreamBuilder<bool>(
                      stream: _emotionVisibilityStream,
                      builder: (context, snapshot) {
                        bool visible = snapshot.data ?? false;
                        return Icon(
                          Icons.insert_emoticon,
                          color: visible ? Colors.lightBlue : Colors.black,
                        );
                      },
                      initialData: false,
                    )),
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
      ),
    );
  }

  void _doSendAudio(RecordDetail recordDetail) {
    ApiKf.uploadAudio(File(recordDetail.path)).then((resp) {
      if (resp.success) {
        var message = WSMessage(resp.data.url,
            type: MessageType.AUDIO, duration: recordDetail.duration);
        manager.sendMessage(message).then((success) {
          if (success) {
            setState(() {
              messages.insert(0, message);
            });
            _listViewController.animateTo(0.0,
                duration: Duration(seconds: 1), curve: Curves.ease);
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
  }

  void _doSendMessage() {
    if (_inputController.text == null || _inputController.text.isEmpty) {
      Fluttertoast.showToast(msg: "请输入文字");
      return;
    }
    var message = WSMessage(_inputController.text);
    _inputController.text = "";
    _editFocusNode.unfocus();
    manager.sendMessage(message).then((success) {
      if (success) {
        setState(() {
          messages.insert(0, message);
        });
        _listViewController.animateTo(0.0,
            duration: Duration(seconds: 1), curve: Curves.ease);
      }
    });
  }

  void _doSendImage() {
    showImageSourceDialog(context).then((sourceFile) {
      rotateWithExifAndCompress(sourceFile).then((f) {
        Api.uploadPic(f.path).then((resp) {
          if (resp.success) {
            var message = WSMessage("img[${resp.data.orginPicPath}]",
                type: MessageType.IMAGE);
            manager.sendMessage(message).then((success) {
              if (success) {
                setState(() {
                  messages.insert(0, message);
                });
                _listViewController.animateTo(0.0,
                    duration: Duration(seconds: 1), curve: Curves.ease);
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
  }
}