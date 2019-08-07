import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ease_life/interaction/audio_recorder.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/service_chat_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/res/configs.dart';
import 'package:ease_life/ui/picture_page.dart';
import 'package:flutter/gestures.dart';
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
//                AppBar(
//                  title: Text("物业客服"),
//                  actions: _buildActions(),
//                ),
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
        return _buildContent(
          context,
          serviceChatModel,
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ServiceChatModel serviceChatModel,
  ) {
    final int userCount = ServiceChatModel.of(context).currentChatUsers.length;
    final bool disconnected = ServiceChatModel.of(context).disconnected;
    if (userCount == 0) {
      return Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text("暂无用户连接"),
            ),
          ),
        ],
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _editFocusNode.unfocus();
              ServiceChatModel.of(context).closeEmoji();
            },
            child: Stack(
              children: <Widget>[
                Container(
                  color: Colors.grey[200],
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if ((notification.metrics.outOfRange ||
                              notification.metrics.atEdge) &&
                          notification.metrics.pixels > 0) {
                        serviceChatModel.loadHistory(
                          serviceChatModel.currentChatUser.userId,
                          DistrictModel.of(context).getCurrentDistrictId(),
                        );
                      }

                      return true;
                    },
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      reverse: true,
                      padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(220)),
                      children: serviceChatModel
                          .messages(serviceChatModel.currentChatUser.userId)
                          .map((message) {
                        return buildMessage(
                          context,
                          serviceChatModel.self(message),
                          message,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: AudioHintWidget(),
                ),
                Consumer<ServiceChatModel>(
                  builder: (BuildContext context, ServiceChatModel value,
                      Widget child) {
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
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              _buildConnectStatusBar(serviceChatModel.disconnected),
              _buildConnectedChatUsers(serviceChatModel)
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: buildChatInputPart(
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
          Consumer2<UserModel,DistrictModel>(
            builder: (context,userModel,districtModel,child){
              return  disconnected
                  ? FlatButton.icon(
                  onPressed: () {
                    ServiceChatModel.of(context).reconnect(userModel,districtModel);
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
                  : Container();
            },
          ),
        ],
      ),
    );
  }

  void _doSendAudio(BuildContext context, RecordDetail recordDetail) async {
    var resp = await ApiKf.uploadAudio(File(recordDetail.path));
    if (resp.success) {
      var model = ServiceChatModel.of(context);
      ServiceChatMessage chatMessage = ServiceChatMessage(
        nickName: model.chatSelf.userNickName,
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
      nickName: model.chatSelf.userNickName,
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
        nickName: model.chatSelf.userNickName,
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
        "to_nick_name": "${model.currentChatUser.userNickName}",
        "content": "${message.content}",
        "from_name": "${model.chatSelf.userName}",
        "from_nick_name": "${model.chatSelf.userNickName}",
        "from_id": "${model.chatSelf.userId}",
        "from_avatar": "${model.chatSelf.userAvatarUrl}"
      }
    };
    model.sendData(json.encode(map));
    model.addMessage(message);
    model.inputText = false;
  }

  _buildConnectedChatUsers(ServiceChatModel serviceChatModel) {
    List<Widget> users = [];
    users.add(Text("在线用户:"));
    users.addAll(serviceChatModel.currentChatUsers.map((user) {
      var unread = serviceChatModel.unread(user.userId);
      return InkWell(
        onTap: () {
          //tabController.animateTo(
          //    serviceChatModel.currentChatUsers.toList().indexOf(user));
          serviceChatModel.currentChatUser = user;
        },
        child: Container(
          height: ScreenUtil().setHeight(160),
          width: ScreenUtil().setHeight(160),
          decoration: BoxDecoration(
              color: serviceChatModel.currentChatUser == user
                  ? Colors.greenAccent
                  : Colors.lightGreen.withAlpha(88),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(6), bottom: Radius.circular(6))),
          margin: EdgeInsets.symmetric(horizontal: 3),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: ScreenUtil().setHeight(100),
                  width: ScreenUtil().setHeight(100),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      user.userAvatarUrl,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: unread == 0
                    ? Container()
                    : Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.all(ScreenUtil().setHeight(12)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Text(unread.toString(),
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
              ),
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(70)),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(6)),
                    color: Colors.black.withAlpha(0x56),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "${user.userNickName}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }).toList());

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Colors.blueGrey[100],
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
          )),
          child: Row(mainAxisSize: MainAxisSize.max, children: users),
        ),
      ),
    );
  }
}
