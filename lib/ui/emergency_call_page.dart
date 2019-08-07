import 'package:ease_life/index.dart';
import 'package:ease_life/interaction/audio_recorder.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/emergency_call_model.dart';
import 'package:ease_life/model/service_chat_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class EmergencyCallPage2 extends StatefulWidget {
  final String group;
  final String title;

  EmergencyCallPage2(this.group, this.title);

  @override
  _EmergencyCallPage2State createState() => _EmergencyCallPage2State();
}

class _EmergencyCallPage2State extends State<EmergencyCallPage2> {
  final FocusNode _editFocusNode = FocusNode();
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editFocusNode.addListener(() {
      if (_editFocusNode.hasFocus) {
        ServiceChatModel.of(context).closeEmoji();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserModel, DistrictModel>(
      builder: (context, userModel, districtModel, child) {
        return ListenableProvider<EmergencyCallModel>(
          builder: (context) {
            return EmergencyCallModel(widget.group, userModel, districtModel);
          },
          dispose: (context, emergencyModel) {
            emergencyModel.dispose();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text("${widget.title}"),
            ),
            body: Consumer<EmergencyCallModel>(
              builder: (context, emergencyModel, child) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if ((notification.metrics.outOfRange ||
                            notification.metrics.atEdge) &&
                        notification.metrics.pixels > 0) {
                      emergencyModel.loadHistory();
                    }

                    return true;
                  },
                  child: Column(
                    children: <Widget>[
                      _buildConnectStatusBar(
                          context,
                          emergencyModel.connectStatus,
                          emergencyModel.kfNickName),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _editFocusNode.unfocus();
                            EmergencyCallModel.of(context).closeEmoji();
                          },
                          child: Stack(
                            children: <Widget>[
                              ListView.builder(
                                reverse: true,
                                itemCount: emergencyModel.messageCount,
                                itemBuilder: (context, index) {
                                  return buildMessage(
                                    context,
                                    emergencyModel.self(index),
                                    emergencyModel.message(index),
                                  );
                                },
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: AudioHintWidget(),
                              ),
                              Consumer<EmergencyCallModel>(
                                builder: (BuildContext context,
                                    EmergencyCallModel value, Widget child) {
                                  return buildUploadDialog(
                                    !value.showUpload,
                                    value.uploadingHint,
                                    value.fraction,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      buildChatInputPart(
                        disconnected: emergencyModel.disconnected,
                        showAudio: emergencyModel.audioInput,
                        showEmoji: emergencyModel.showEmoji,
                        textInputMode: emergencyModel.inputText,
                        onSwitchEmoji: () {
                          _editFocusNode.unfocus();
                          emergencyModel.switchEmoji();
                        },
                        onSwitchAudio: () {
                          _editFocusNode.unfocus();
                          emergencyModel.switchAudio();
                        },
                        onStopRecord: (detail) {
                          _doSendAudio(context, detail);
                        },
                        onSendText: () {
                          _doSendMessage(context);
                        },
                        onSendImage: () {
                          _doSendImage(context);
                        },
                        onTextChange: (s) {
                          if (s != null && s.isNotEmpty) {
                            emergencyModel.inputText = true;
                          } else {
                            emergencyModel.inputText = false;
                          }
                        },
                        onSelectEmoji: (s) {
                          _inputController.value = TextEditingValue(
                            text: _inputController.text + s,
                          );
                          emergencyModel.inputText = true;
                        },
                        textFocusNode: _editFocusNode,
                        textInputController: _inputController,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _doSendAudio(BuildContext context, RecordDetail recordDetail) async {
    var resp = await ApiKf.uploadAudio(File(recordDetail.path));
    if (resp.success) {
      var model = EmergencyCallModel.of(context);
      ServiceChatMessage chatMessage = ServiceChatMessage(
        nickName: model.config.fromNickName,
        userAvatar: model.config.fromAvatar,
        time: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        content: "audio[${resp.data.url}]",
        senderId: model.config.fromUserId,
        receiverId: model.config.kfUserId,
        read: true,
      );
      _sendFutureMessage(
        context,
        chatMessage,
      );
    } else {
      showToast(resp.text);
      showToast("语音上传失败,请检查网络");
    }
  }

  void _doSendMessage(BuildContext context) {
    if (_inputController.text == null || _inputController.text.isEmpty) {
      showToast("不能发送空消息!");
      return;
    }
    var model = EmergencyCallModel.of(context);
    ServiceChatMessage chatMessage = ServiceChatMessage(
      nickName: model.config.fromNickName,
      userAvatar: model.config.fromAvatar,
      time: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
      content: _inputController.text,
      senderId: model.config.fromUserId,
      receiverId: model.config.kfUserId,
      read: true,
    );
    _sendFutureMessage(context, chatMessage);
    _inputController.clear();
  }

  void _doSendImage(BuildContext context) async {
    File image = await showImageSourceDialog(context);
    if (image == null) {
      return;
    }
    var model = EmergencyCallModel.of(context);
    model.uploadingHint = "正在压缩图片..";
    model.progress = 20;
    File compressed = await rotateWithExifAndCompress(image);
    model.uploadingHint = "正在上传图片..";
    model.progress = 40;
    var resp =
        await Api.uploadPic(compressed.path, onSendProgress: (count, total) {
      model.progress = 60 * count ~/ total + 40;
    });
    model.progress = 100;
    if (resp.success) {
      ServiceChatMessage chatMessage = ServiceChatMessage(
        nickName: model.config.fromNickName,
        userAvatar: model.config.fromAvatar,
        time: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        content: "img[${resp.data.orginPicPath}]",
        senderId: model.config.fromUserId,
        receiverId: model.config.kfUserId,
        read: true,
      );
      _sendFutureMessage(context, chatMessage);
    } else {
      showToast("图片上传失败,请检查网络:${resp.text}");
    }
  }

  void _sendFutureMessage(BuildContext context, ServiceChatMessage message) {
    EmergencyCallModel model = EmergencyCallModel.of(context);
    var map = {
      "type": "chatMessage",
      "data": {
        "to_id": "${model.config.kfUserId}",
        "to_name": "${model.config.kfUserName}",
        "to_nick_name": "${model.config.kfNickName}",
        "content": "${message.content}",
        "from_name": "${model.config.fromNickName}",
        "from_id": "${model.config.fromUserId}",
        "from_avatar": "${model.config.fromAvatar}"
      }
    };
    model.sendData(json.encode(map).toString());
    model.sendMessage(message);
    model.inputText = false;
  }

  Container _buildConnectStatusBar(
      BuildContext context, ConnectStatus status, String kfNickName) {
    return Container(
      alignment: Alignment.center,
      color: status == ConnectStatus.DISCONNECTED ? Colors.red : Colors.white,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 12,
          ),
          status == ConnectStatus.DISCONNECTED
              ? Container()
              : Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  height: 4,
                  width: 4,
                ),
          SizedBox(
            width: 12,
          ),
          Text(
            status == ConnectStatus.DISCONNECTED
                ? "已断开连接"
                : status == ConnectStatus.CONNECTED
                    ? "正在与$kfNickName交流"
                    : "暂无客服接待",
            style: TextStyle(
              color: status == ConnectStatus.DISCONNECTED
                  ? Colors.white
                  : Colors.green,
            ),
          ),
          status == ConnectStatus.DISCONNECTED
              ? FlatButton.icon(
                  onPressed: () {
                    EmergencyCallModel.of(context).connect();
                  },
                  icon: Icon(
                    Icons.cached,
                    color: Colors.white,
                  ),
                  label: Text(
                    "重连",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ))
              : Container(),
        ],
      ),
    );
  }
}
