import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ease_life/interaction/audio_recorder.dart';
import 'package:ease_life/model/service_chat_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/res/configs.dart';
import 'package:ease_life/ui/picture_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

import '../utils.dart';

class ServiceChatPage extends StatefulWidget {
  static const String routeName = "/service_chat";

  @override
  _ServiceChatPageState createState() => _ServiceChatPageState();
}

class _ServiceChatPageState extends State<ServiceChatPage>
    with TickerProviderStateMixin {
  TextEditingController _inputController = TextEditingController();
  FocusNode _editFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceChatModel>(
      builder: (BuildContext context, ServiceChatModel serviceChatModel,
          Widget child) {
        if (serviceChatModel.userCount == 0) {
          return SafeArea(
            child: Column(
              children: <Widget>[
                _buildConnectStatusBar(serviceChatModel.disconnected),
                Expanded(
                  child: Center(
                    child: Text("暂无用户连接"),
                  ),
                ),
              ],
            ),
          );
        }
        return DefaultTabController(
          length: serviceChatModel.userCount,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.blue,
                title: Text(
                  "正在与${serviceChatModel.currentChatUser.userName}交流",
                  style: TextStyle(color: Colors.white),
                ),
                brightness: Brightness.dark,
                iconTheme: IconThemeData(color: Colors.white),
                elevation: 3,
                centerTitle: false,
                bottom: TabBar(
                  labelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      )),
                  tabs: serviceChatModel.currentChatUsers
                      .map((user) => Tab(
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil().setHeight(60),
                          width: ScreenUtil().setHeight(60),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              user.userAvatarUrl,
                            ),
                          ),
                        ),
                        Text(
                          user.userName,
                        )
                      ],
                    ),
                  ))
                      .toList(),
                  isScrollable: serviceChatModel.userCount > 3,
                ),
                pinned: true,
              ),
              SliverFillRemaining(
                child: _buildContent(context, serviceChatModel),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
      BuildContext context, ServiceChatModel serviceChatModel) {
    final int userCount = ServiceChatModel.of(context).userCount;
    final bool disconnected = ServiceChatModel.of(context).disconnected;
    if (userCount == 0) {
      return Column(
        children: <Widget>[
          _buildConnectStatusBar(disconnected),
          Expanded(
            child: Center(
              child: Text("暂无用户连接"),
            ),
          ),
        ],
      );
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: TabBarView(
            children: serviceChatModel.currentChatUsers
                .map((user) => Stack(
                      children: <Widget>[
                        Container(
                          child: ListView(
                            shrinkWrap: true,
                            reverse: true,
                            children: serviceChatModel
                                .messages(user.userId)
                                .map((message) {
                              return buildMessage(serviceChatModel, message);
                            }).toList(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: AudioHintWidget(),
                        ),
                        Consumer<ServiceChatModel>(
                          builder: (BuildContext context,
                              ServiceChatModel value, Widget child) {
                            return Offstage(
                              offstage: !value.showUpload,
                              child: Align(
                                alignment: Alignment.center,
                                child: AlertDialog(
                                  title: Text(value.uploadingHint),
                                  content: LinearProgressIndicator(
                                    value: value.fraction,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ))
                .toList(),
          ),
        ),
        Container(
          color: Colors.grey[400],
          height: 0.3,
        ),
        _buildConnectStatusBar(disconnected),
        _buildInputPart(disconnected),
      ],
    );
  }

  Consumer<ServiceChatModel> _buildInputPart(bool disconnected) {
    return Consumer<ServiceChatModel>(
      builder: (BuildContext context, ServiceChatModel value, Widget child) {
        bool audio = value.audioInput;
        bool emoji = value.showEmoji;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AbsorbPointer(
              absorbing: disconnected,
              child: IntrinsicHeight(
                child: Container(
                  decoration: BoxDecoration(
                    color: disconnected ? Colors.grey : Colors.white,
                  ),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          _editFocusNode.unfocus();
                          value.switchAudio();
                        },
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  margin: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  child: Transform.rotate(
                                      angle: audio ? 0 : 3.14 / 2,
                                      child: Icon(!audio
                                          ? Icons.wifi
                                          : Icons.message))),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: audio
                            ? AudioInputWidget((recordDetail) {
                                _doSendAudio(context, recordDetail);
                              })
                            : SizedBox(
                                height: ScreenUtil().setHeight(120),
                                child: TextField(
                                  focusNode: _editFocusNode,
                                  enabled: !disconnected,
                                  controller: _inputController,
                                  maxLines: 100,
                                  textInputAction: TextInputAction.send,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(3),
                                    border: OutlineInputBorder(),
                                    fillColor: Colors.red,
                                  ),
                                  onSubmitted: (content) {
                                    _doSendMessage(context);
                                  },
                                ),
                              ),
                      ),
                      IconButton(
                          onPressed: () {
                            _doSendImage(context);
                          },
                          icon: Icon(Icons.image)),
                      audio
                          ? Container()
                          : IconButton(
                              onPressed: () {
                                _editFocusNode.unfocus();
                                value.switchEmoji();
                              },
                              padding: EdgeInsets.all(0),
                              icon: Icon(
                                Icons.insert_emoticon,
                                color: emoji ? Colors.lightBlue : Colors.black,
                              ),
                            ),
                      audio
                          ? Container()
                          : IconButton(
                              onPressed: () {
                                _doSendMessage(context);
                              },
                              padding: EdgeInsets.all(0),
                              icon: Text(
                                "发送",
                                style: TextStyle(
                                  color:
                                      disconnected ? Colors.grey : Colors.black,
                                ),
                              )),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: emoji,
              child: Wrap(
                children: faces.map((name) {
                  return InkWell(
                    onTap: () {
                      _inputController.text =
                          _inputController.text + "face" + name;
                    },
                    child: Container(
                      margin: EdgeInsets.all(ScreenUtil().setWidth(12)),
                      child:
                          Image.asset("images/face/${faces.indexOf(name)}.gif"),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        );
      },
    );
  }

  Container _buildConnectStatusBar(bool disconnected) {
    return Container(
      alignment: Alignment.center,
      color: disconnected ? Colors.red : Colors.white,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 12,
          ),
          disconnected
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
            disconnected ? "已断开连接" : "已连接客服服务",
            style: TextStyle(
              color: disconnected ? Colors.white : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessage(
      ServiceChatModel serviceChatModel, ChatMessage chatMessage) {
    var self = serviceChatModel.self(chatMessage);
    var messageTile;
    messageTile = <Widget>[
      Flexible(
        flex: 100,
        child: Container(),
      ),
      _buildMessageBody(chatMessage),
      _buildMessageUserName(chatMessage),
    ];
    //消息
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: self ? messageTile : messageTile.reversed.toList(),
    );
  }

  Widget _buildMessageBody(ChatMessage chatMessage) {
    var messageContent = chatMessage.content;
    if (messageContent.startsWith("img[") && messageContent.endsWith("]")) {
      ///图片
      var imageUrl = _getRemoteUrl(messageContent);
      return _buildMessageWrapper(
        InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return PicturePage(imageUrl);
            }));
          },
          child: Container(
            constraints: BoxConstraints(minWidth: 120),
            child: Hero(
              tag: imageUrl,
              child: Image.network(
                imageUrl,
                loadingBuilder: (context, child, chunk) {
                  if (chunk != null) {
                    return Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    );
                  }
                  return child;
                },
              ),
            ),
          ),
        ),
        chatMessage,
      );
    } else if (messageContent.startsWith("audio[") &&
        messageContent.endsWith("]")) {
      ///音频
      return _buildMessageWrapper(
        AudioMessageTile(
          _getAudioUrl(messageContent),
          0,
        ),
        chatMessage,
        noDecoration: true,
      );
    }
    var allMatches = RegExp(r"face\[.*?\]").allMatches(messageContent);
    List<Widget> children = [];
    int lastStart = 0;
    allMatches.toList().forEach((regMatcher) {
      if (regMatcher.start > 0) {
        children.add(Text(
          messageContent.substring(lastStart, regMatcher.start),
          style: TextStyle(fontFamily: "SoukouMincho"),
        ));
      }
      var index = faces.indexOf(
          messageContent.substring(regMatcher.start + 4, regMatcher.end));
      children.add(Image.asset("images/face/$index.gif"));

      lastStart = regMatcher.end;
    });
    if (lastStart < messageContent.length) {
      children.add(Text(messageContent.substring(lastStart)));
    }

    return _buildMessageWrapper(
      InkWell(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: messageContent)).then((_) {
            showToast("文字已复制");
          });
        },
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.white),
          child: Wrap(
            children: children,
          ),
        ),
      ),
      chatMessage,
    );
  }

  String _getRemoteUrl(String messageContent) {
    var raw = messageContent.substring(4, messageContent.length - 1);
    if (!raw.startsWith("http")) {
      raw = Configs.KFBaseUrl + raw;
      return raw;
    }
    return raw;
  }

  String _getAudioUrl(String messageContent) {
    var raw = messageContent.substring(6, messageContent.length - 1);
    if (!raw.startsWith("http")) {
      raw = Configs.KFBaseUrl + raw;
      return raw;
    }
    return raw;
  }

  String _getMessageSendTime(String timeStr) {
    var time;
    try {
      time = DateTime.parse(timeStr);
    } catch (e) {
      return timeStr;
    }
    if (isToday(time)) {
      return DateFormat("HH:mm:ss").format(time);
    } else {
      return DateFormat("yyyy-MM-dd HH:mm:ss").format(time);
    }
  }

  bool isToday(DateTime time) {
    return time.difference(DateTime.now()).inDays < 1;
  }

  Widget _buildMessageWrapper(Widget messageContent, ChatMessage chatMessage,
      {bool noDecoration = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(_getMessageSendTime(chatMessage.time)),
        Container(
          margin: noDecoration
              ? null
              : EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: noDecoration
              ? null
              : EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: noDecoration
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                  color: Colors.lightBlue),
          child: messageContent,
        ),
      ],
    );
  }

  Container _buildMessageUserName(ChatMessage chatMessage) {
    var name = chatMessage.userName;
    if (name == null || name.isEmpty) {
      name = "未命名用户";
    }
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      padding: EdgeInsets.all(6),
      child: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.w600, shadows: [
          Shadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 1)
        ]),
      ),
    );
  }

  void _doSendAudio(BuildContext context, RecordDetail recordDetail) async {
    var resp = await ApiKf.uploadAudio(File(recordDetail.path));
    if (resp.success) {
      var model = ServiceChatModel.of(context);
      ChatMessage chatMessage = ChatMessage(
        userName: model.chatSelf.userName,
        userAvatar: model.chatSelf.userAvatarUrl,
        time: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        content: "audio[${resp.data.url}]",
        senderId: model.chatSelf.userId,
        receiverId: model.currentChatUser.userId,
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
    var model = ServiceChatModel.of(context);
    ChatMessage chatMessage = ChatMessage(
      userName: model.chatSelf.userName,
      userAvatar: model.chatSelf.userAvatarUrl,
      time: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
      content: _inputController.text,
      senderId: model.chatSelf.userId,
      receiverId: model.currentChatUser.userId,
    );
    _sendFutureMessage(context, chatMessage);
    _inputController.clear();
  }

  void _doSendImage(BuildContext context) async {
    File image = await showImageSourceDialog(context);
    if (image == null) {
      return;
    }
    var model = ServiceChatModel.of(context);
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
      ChatMessage chatMessage = ChatMessage(
        userName: model.chatSelf.userName,
        userAvatar: model.chatSelf.userAvatarUrl,
        time: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        content: "img[${resp.data.orginPicPath}]",
        senderId: model.chatSelf.userId,
        receiverId: model.currentChatUser.userId,
      );
      _sendFutureMessage(context, chatMessage);
    } else {
      showToast("图片上传失败,请检查网络:${resp.text}");
    }
  }

  void _sendFutureMessage(BuildContext context, ChatMessage message) {
    var model = ServiceChatModel.of(context);
    var map = {
      "type": "chatMessage",
      "data": {
        "to_id": "${model.currentChatUser.userId}",
        "to_name": "${model.currentChatUser.userName}",
        "content": "${message.content}",
        "from_name": "${model.chatSelf.userName}",
        "from_id": "${model.chatSelf.userId}",
        "from_avatar": "${model.chatSelf.userAvatarUrl}"
      }
    };
    model.sendData(json.encode(map));
    model.addMessage(message);
  }
}
