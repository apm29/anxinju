import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ease_life/interaction/audio_recorder.dart';
import 'package:ease_life/model/service_chat_model.dart';
import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/res/configs.dart';
import 'package:ease_life/ui/picture_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

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
    return Consumer<ServiceChatModel>(
      builder: (BuildContext context, ServiceChatModel serviceChatModel,
          Widget child) {
        var userCount = serviceChatModel.currentChatUsers.length;
        if (userCount == 0) {
          return SafeArea(
            child: Column(
              children: <Widget>[
                AppBar(
                  title: Text("物业客服"),
                  actions: _buildActions(),
                ),
                Container(
                  height: 0.1,
                  color: Colors.grey,
                ),
                _buildConnectStatusBar(serviceChatModel.disconnected),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey[300],
                    child: Text("暂无用户连接"),
                  ),
                ),
                buildChatInputPart(disconnected: true),
              ],
            ),
          );
        }
        var tabController = TabController(
          length: userCount,
          vsync: this,
          initialIndex: serviceChatModel.currentIndex,
        );
        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.blue,
              title: Text(
                "正在与${serviceChatModel.currentChatUser.userName}交流",
                style: TextStyle(color: Colors.white),
              ),
              actions: _buildActions(white: true),
              brightness: Brightness.light,
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 3,
              centerTitle: false,
              bottom: TabBar(
                key: PageStorageKey(1090),
                controller: tabController,

                indicatorSize: TabBarIndicatorSize.tab,
                onTap: (index) {
                  serviceChatModel.currentChatUser =
                      serviceChatModel.currentChatUsers.toList()[index];
                },
                indicator: BoxDecoration(
                    color: Colors.red[200],
                    shape: BoxShape.rectangle,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8))),
                tabs: serviceChatModel.currentChatUsers.map((user) {
                  var unread = serviceChatModel.unread(user.userId);
                  return Tab(
                    child: Stack(
                      children: <Widget>[
                        Align(
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
                              SizedBox(
                                width: ScreenUtil().setHeight(20),
                              ),
                              Text(
                                user.userName,
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        Positioned.fill(
                          child: unread == 0
                              ? Container()
                              : Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: Text(
                                      unread.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                isScrollable: true, //serviceChatModel.userCount > 3,
              ),
              pinned: true,
            ),
            SliverFillRemaining(
              child: _buildContent(
                context,
                serviceChatModel,
                tabController,
              ),
            )
          ],
        );
      },
    );
  }

  List<Widget> _buildActions({bool white = false}) {
    return <Widget>[
      Consumer<UserRoleModel>(
        builder: (BuildContext context, UserRoleModel roleModel, Widget child) {
          return roleModel.hasSwitch
              ? FlatButton.icon(
                  icon: Icon(
                    Icons.repeat,
                    color: white ? Colors.white : Colors.blue,
                  ),
                  onPressed: () {
                    roleModel.switchRole();
                    SystemSound.play(SystemSoundType.click);
                  },
                  label: Text(
                    "${roleModel.switchString}",
                    style: TextStyle(
                        color: white ? Colors.white : Colors.grey[700]),
                  ),
                )
              : Container();
        },
      ),
    ];
  }

  Widget _buildContent(BuildContext context, ServiceChatModel serviceChatModel,
      TabController tabController) {
    final int userCount = ServiceChatModel.of(context).currentChatUsers.length;
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
        _buildConnectStatusBar(disconnected),
        Expanded(
          child: TabBarView(
            controller: tabController,
            key: PageStorageKey(1090),
            physics: NeverScrollableScrollPhysics(),
            children: serviceChatModel.currentChatUsers
                .map((user) => Stack(
                      children: <Widget>[
                        Container(
                          color: Colors.grey[200],
                          child: ListView(
                            reverse: true,
                            children: serviceChatModel
                                .messages(user.userId)
                                .map((message) {
                              return buildMessage(context,
                                  serviceChatModel.self(message), message);
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
                            return buildUploadDialog(!value.showUpload,
                                value.uploadingHint, value.fraction);
                          },
                        ),
                      ],
                    ))
                .toList(),
          ),
        ),
        buildChatInputPart(
          disconnected: disconnected,
          showAudio: serviceChatModel.audioInput,
          showEmoji: serviceChatModel.showEmoji,
          textInputMode: serviceChatModel.inputText,
          onSwitchEmoji: () {
            _editFocusNode.unfocus();
            serviceChatModel.switchEmoji();
          },
          onSwitchAudio: () {
            _editFocusNode.unfocus();
            serviceChatModel.switchAudio();
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
              serviceChatModel.inputText = true;
            } else {
              serviceChatModel.inputText = false;
            }
          },
          onSelectEmoji: (s) {
            _inputController.value = TextEditingValue(
              text: _inputController.text + s,
            );
            serviceChatModel.inputText = true;
          },
          textFocusNode: _editFocusNode,
          textInputController: _inputController,
        ),
      ],
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
          disconnected
              ? FlatButton.icon(
                  onPressed: () {
                    ServiceChatModel.of(context).reconnect(context);
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

  void _doSendAudio(BuildContext context, RecordDetail recordDetail) async {
    var resp = await ApiKf.uploadAudio(File(recordDetail.path));
    if (resp.success) {
      var model = ServiceChatModel.of(context);
      ServiceChatMessage chatMessage = ServiceChatMessage(
        userName: model.chatSelf.userName,
        userAvatar: model.chatSelf.userAvatarUrl,
        time: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        content: "audio[${resp.data.url}]",
        senderId: model.chatSelf.userId,
        receiverId: model.currentChatUser.userId,
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
    var model = ServiceChatModel.of(context);
    ServiceChatMessage chatMessage = ServiceChatMessage(
      userName: model.chatSelf.userName,
      userAvatar: model.chatSelf.userAvatarUrl,
      time: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
      content: _inputController.text,
      senderId: model.chatSelf.userId,
      receiverId: model.currentChatUser.userId,
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
      ServiceChatMessage chatMessage = ServiceChatMessage(
        userName: model.chatSelf.userName,
        userAvatar: model.chatSelf.userAvatarUrl,
        time: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        content: "img[${resp.data.orginPicPath}]",
        senderId: model.chatSelf.userId,
        receiverId: model.currentChatUser.userId,
        read: true,
      );
      _sendFutureMessage(context, chatMessage);
    } else {
      showToast("图片上传失败,请检查网络:${resp.text}");
    }
  }

  void _sendFutureMessage(BuildContext context, ServiceChatMessage message) {
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
