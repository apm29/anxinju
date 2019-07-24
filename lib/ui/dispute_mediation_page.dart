import 'dart:async';
import 'dart:io';

import 'package:ease_life/interaction/audio_recorder.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/remote/kf_dio_utils.dart';
import 'package:ease_life/res/configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:ease_life/utils.dart';

import 'picture_page.dart';
import 'widget/refresh_hint_widget.dart';

class DisputeMediationPage extends StatefulWidget {
  final String chatRoomId;
  final bool isFinished;
  final String title;

  const DisputeMediationPage({Key key, this.chatRoomId, this.isFinished, this.title})
      : super(key: key);

  @override
  _DisputeMediationPageState createState() => _DisputeMediationPageState();
}

class ChatUser {
  String userId;
  String userName;
  String userAvatar;

  ChatUser({@required this.userId, @required this.userName, this.userAvatar});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatUser &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

const TEXT_TYPE = "chatRoomMessage";
const COMMAND_LOGOUT = "custRoomLogOut";
const COMMAND_LOGIN = "chatConnect";

enum ChatStatus { CONNECTED, DISCONNECTED, WAIT }

class ChatGroupRoomData {
  ChatStatus _roomConnectStatus;
  Set<ChatUser> _users = Set();
  ChatUser _currentUser;
  List<ChatMessage> _messages = [];

  String get title {
    if (messages == null || messages.length == 0) {
      return "纠纷化解";
    } else {
      return messages.firstWhere((message) {
        return message.data.title != null && message.data.title.isNotEmpty;
      }, orElse: () => null)?.data?.title??"纠纷化解";
    }
  }

  ChatGroupRoomData(
      this._roomConnectStatus, this._users, this._currentUser, this._messages);

  void addMessage(ChatMessage chatGroupMessage) {
    _messages.insert(0, chatGroupMessage);
  }

  ChatStatus get roomConnectStatus => _roomConnectStatus;

  List<ChatMessage> get messages => _messages ?? [];

  Set<ChatUser> get users => _users;

  ChatUser get currentUser => _currentUser;

  set messages(List<ChatMessage> value) {
    _messages = value;
  }

  set currentUser(ChatUser value) {
    _currentUser = value;
  }

  set users(Set<ChatUser> value) {
    _users = value;
  }

  set roomConnectStatus(ChatStatus value) {
    _roomConnectStatus = value;
  }

  bool addUser(ChatUser newUser) {
    return users.add(newUser);
  }

  void logout() {
    users?.clear();
    messages?.clear();
    roomConnectStatus = ChatStatus.DISCONNECTED;
    currentUser = null;
  }

  void removeUser(ChatUser chatUser) {
    users?.remove(chatUser);
  }
}

class ChatGroupConfig {
  static const String APP_ID = Configs.KF_APP_ID;
  String wsUrl = Configs.KF_EMERGENCY_WS_URL;
  final String userToken;
  final String chatRoomId;
  String appID = APP_ID;
  final String districtId;
  final String userInfoParams;

  final String userId;

  ChatGroupConfig({
    this.userToken,
    this.chatRoomId,
    this.districtId,
    this.userInfoParams,
    this.userId,
  });

  @override
  String toString() {
    return 'ChatGroupConfig{wsUrl: $wsUrl, userToken: $userToken, chatRoomId: $chatRoomId, appID: $appID, districtID: $districtId, userInfoParams: $userInfoParams}';
  }
}

class DisputeMediationModel extends ChangeNotifier {
  IOWebSocketChannel _currentChannel;
  ChatGroupRoomData _roomData;
  ChatGroupConfig _config;

  ChatUser get currentUser {
    return _roomData.currentUser;
  }

  set currentChannel(IOWebSocketChannel value) {
    _currentChannel = value;
  }

  ChatGroupRoomData get roomData => _roomData;
  StreamSubscription _subscription;

  DisputeMediationModel.connect({
    @required ChatGroupConfig config,
    @required ChatUser currentUser,
  }) {
    reconnect(config, currentUser);
  }

  bool self(ChatMessage message) {
    return _roomData.currentUser.userId == message.data.userId;
  }

  Future login() async {
    _refresh();
    Map<String, String> map = {};
    map['type'] = "chatUserInit";
    map['myToken'] = "${_config.userToken}";
    map['chatroom_id'] = "${_config.chatRoomId}";
    map['cAppId'] = "${_config.appID}";
    map['district_id'] = "${_config.districtId}";
    map['userinfo_param'] = "${_config.userInfoParams}";
    _sendData(json.encode(map));
  }

  void _sendData(String data) {
    print('>>>>> SEND ----> $data');
    _currentChannel.sink.add(data);
  }

  void _onReceive(data) {
    print('<<<<< RECV <---- ${data.toString()}');
    Map<String, dynamic> map = json.decode(data);
    ChatMessage chatMessage = ChatMessage.fromJson(map);

    playMessageSound();

    if (chatMessage.code == 200) {
      switch (chatMessage.messageType) {
        case "chatConnect":
          //登录成功
          _roomData.roomConnectStatus = ChatStatus.CONNECTED;
          _roomData.addUser(
            ChatUser(
              userId: chatMessage.data.userId,
              userName: chatMessage.data.userName,
            ),
          );
          break;
        case "custRoomLogOut":
          //有用户登出
          _roomData.removeUser(
            ChatUser(
              userId: chatMessage.data.userId,
              userName: chatMessage.data.userName,
            ),
          );

          break;
      }
    }
    addMessage(chatMessage);
  }

  void _refresh() {
    page = 1;
    noMoreHistory = false;
    loadingHistory = false;
    loadHistory();
  }

  void reconnect(ChatGroupConfig config, ChatUser currentUser) {
    this._config = config;
    try {
      _currentChannel = IOWebSocketChannel.connect(config.wsUrl);
    } catch (e) {
      print(e);
    }
    roomData = ChatGroupRoomData(ChatStatus.WAIT, Set(), currentUser, []);
    startListen();
    login();
  }

  void startListen() async {
    _subscription?.cancel();
    _subscription = _currentChannel.stream.listen((dynamic data) {
      _onReceive(data);
    }, onError: (e) {
      print('CHAT LINKER ERR: ${e.toString()}');
      //连接错误
    }, onDone: () {
      print('CHAT LINKER DONE');
      //连接断开
      _roomData.logout();
      if (!isDisposed) notifyListeners();
    });
  }

  void disconnect() {
    _currentChannel?.sink?.close();
  }

  ChatGroupRoomData get roomConnectStatus => _roomData;

  ChatGroupConfig get config => _config;

  set roomData(ChatGroupRoomData value) {
    _roomData = value;
    notifyListeners();
  }

  bool isDisposed = false;

  @override
  void dispose() {
    super.dispose();
    print('LINK DISPOSED');
    disconnect();
    isDisposed = true;
  }

  static DisputeMediationModel of(BuildContext context) {
    return Provider.of(context, listen: false);
  }

  void addMessage(ChatMessage message) {
    _roomData.addMessage(message);
    notifyListeners();
  }

  int page = 1;
  int pageNum = 20;
  bool loadingHistory = false;
  bool noMoreHistory = false;

  Future loadHistory() async {
    if (loadingHistory || noMoreHistory) {
      return null;
    }
    loadingHistory = true;
    var kfBaseResp = await ApiKf.getMediationChatLog(
      config.districtId,
      page,
      pageNum,
      config.appID,
      config.chatRoomId,
    );
    if (kfBaseResp.success) {
      var list = kfBaseResp.data.rows.map((MediationMessage message) {
        return message.toChatMessage();
      }).toList();
      _roomData._messages.addAll(list);
      if (list.length < pageNum) {
        noMoreHistory = true;
      }
      page += 1;
    }
    loadingHistory = false;
    return notifyListeners();
  }
}

class ChatRoomPageStatusModel extends ChangeNotifier {
  bool _audioInput = false;
  bool _showEmoji = false;

  bool get audioInput => _audioInput;
  String _uploadingHint;
  int _progress = 0;

  bool get showUpload {
    bool show = (_progress > 0 && _progress < 100);
    return show;
  }

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

  bool get showEmoji => _showEmoji;

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

  static ChatRoomPageStatusModel of(BuildContext context) {
    return Provider.of(context, listen: false);
  }
}

class _DisputeMediationPageState extends State<DisputeMediationPage> {
  FocusNode _editFocusNode = FocusNode();
  TextEditingController _inputController = TextEditingController();
  ScrollController _messageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _editFocusNode.addListener(() {
      if (_editFocusNode.hasFocus) {
        ChatRoomPageStatusModel.of(context).closeEmoji();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel userModel, Widget child) {
        return MultiProvider(
          providers: [
            ListenableProvider<DisputeMediationModel>(
              builder: (context) {
                return DisputeMediationModel.connect(
                  config: ChatGroupConfig(
                    userToken: userModel.token,
                    chatRoomId: widget.chatRoomId,
                    districtId: DistrictModel.of(context)
                        .getCurrentDistrictId()
                        .toString(),
                    userInfoParams: userModel.token,
                    userId: userModel.userId,
                  ),
                  currentUser: ChatUser(
                    userId: userModel.userId,
                    userName: userModel.userName,
                  ),
                );
              },
              dispose: (context, value) {
                value.dispose();
              },
            ),
          ],
          child: Consumer<DisputeMediationModel>(
            builder: (BuildContext context, DisputeMediationModel dmModel,
                Widget child) {
              bool disconnected =
                  dmModel.roomData.roomConnectStatus != ChatStatus.CONNECTED;
              bool loading =
                  dmModel.roomData.roomConnectStatus == ChatStatus.WAIT;
              return Scaffold(
                resizeToAvoidBottomInset: true,
                resizeToAvoidBottomPadding: true,
                appBar: AppBar(
                  title:
                      Text( widget.title ?? dmModel.roomData.title),
                ),
                body: Column(
                  children: <Widget>[
                    widget.isFinished
                        ? Container()
                        : Container(
                            alignment: Alignment.center,
                            color: disconnected ? Colors.red : Colors.blue,
                            child: Text(
                              disconnected ? "已断开" : "已连接",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                    Expanded(
                      child: loading && !widget.isFinished
                          ? RefreshHintWidget(
                              onPress: () async {
                                dmModel.login();
                              },
                            )
                          : GestureDetector(
                              onTap: () {
                                _editFocusNode.unfocus();
                                ChatRoomPageStatusModel.of(context)
                                    .closeEmoji();
                              },
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: NotificationListener<
                                        ScrollNotification>(
                                      child: ListView.builder(
                                        reverse: true,
                                        controller: _messageScrollController,
                                        shrinkWrap: true,
                                        itemBuilder: (_, index) {
                                          return buildMessage(dmModel, index);
                                        },
                                        itemCount:
                                            dmModel.roomData.messages.length,
                                      ),
                                      onNotification:
                                          (ScrollNotification notification) {
                                        if ((notification.metrics.outOfRange ||
                                                notification.metrics.atEdge) &&
                                            notification.metrics.pixels != 0) {
                                          dmModel.loadHistory();
                                        }
                                        return false;
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: AudioHintWidget(),
                                  ),
                                  Consumer<ChatRoomPageStatusModel>(
                                    builder: (BuildContext context,
                                        ChatRoomPageStatusModel value,
                                        Widget child) {
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
                              ),
                            ),
                    ),
                    Container(
                      color: Colors.grey[400],
                      height: 0.3,
                    ),
                    Consumer<ChatRoomPageStatusModel>(
                      builder: (BuildContext context,
                          ChatRoomPageStatusModel value, Widget child) {
                        bool audio = value.audioInput;
                        bool emoji = value.showEmoji;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AbsorbPointer(
                              absorbing: disconnected || widget.isFinished,
                              child: IntrinsicHeight(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: disconnected || widget.isFinished
                                        ? Colors.grey
                                        : Colors.white,
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
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  margin: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(8),
                                                    ),
                                                  ),
                                                  child: Transform.rotate(
                                                      angle:
                                                          audio ? 0 : 3.14 / 2,
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
                                                _doSendAudio(
                                                    context, recordDetail);
                                              })
                                            : SizedBox(
                                                height:
                                                    ScreenUtil().setHeight(120),
                                                child: TextField(
                                                  focusNode: _editFocusNode,
                                                  enabled: !disconnected,
                                                  controller: _inputController,
                                                  maxLines: 100,
                                                  textInputAction:
                                                      TextInputAction.send,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(3),
                                                    border:
                                                        OutlineInputBorder(),
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
                                                color: emoji
                                                    ? Colors.lightBlue
                                                    : Colors.black,
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
                                                  color: disconnected
                                                      ? Colors.grey
                                                      : Colors.black,
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
                                      margin: EdgeInsets.all(
                                          ScreenUtil().setWidth(12)),
                                      child: Image.asset(
                                          "images/face/${faces.indexOf(name)}.gif"),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          ],
                        );
                      },
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildMessage(DisputeMediationModel dmModel, int index) {
    var chatMessage = dmModel.roomData.messages[index];

    var self = dmModel.self(chatMessage);
    switch (chatMessage.messageType) {
      case COMMAND_LOGIN:
        //登录成功
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${chatMessage.data.userName} 进入群聊",
            textAlign: TextAlign.center,
          ),
        );
      case TEXT_TYPE:
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
      case COMMAND_LOGOUT:
        //有用户登出
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${chatMessage.data.userName} 退出群聊",
            textAlign: TextAlign.center,
          ),
        );
    }
    return Text("$chatMessage");
  }

  Widget _buildMessageBody(ChatMessage chatMessage) {
    var messageContent = chatMessage.data.content;
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
          chatMessage.data.duration,
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
    var time = DateTime.parse(timeStr);
    //if (isToday(time)) {
    //  return DateFormat("HH:mm:ss").format(time);
    //} else {
      return DateFormat("yyyy-MM-dd HH:mm:ss").format(time);
    //}
  }

  bool isToday(DateTime time) {
    return time.difference(DateTime.now()).inDays < 1;
  }

  Widget _buildMessageWrapper(Widget messageContent, ChatMessage chatMessage,
      {bool noDecoration = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(_getMessageSendTime(chatMessage.data.time)),
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
    var name = chatMessage.data.userName;
    if(name ==null || name.isEmpty){
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
      var mediationModel = DisputeMediationModel.of(context);
      _sendFutureMessage(
        context,
        ChatMessage.audio(
          resp.data.url,
          mediationModel.currentUser,
          mediationModel.config,
          recordDetail.duration,
        ),
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
    var mediationModel = DisputeMediationModel.of(context);
    ChatMessage chatMessage = ChatMessage.text(_inputController.text,
        mediationModel.currentUser, mediationModel.config);
    _sendFutureMessage(context, chatMessage);
    _inputController.clear();
  }

  void _doSendImage(BuildContext context) async {
    File image = await showImageSourceDialog(context);
    if (image == null) {
      return;
    }
    var model = ChatRoomPageStatusModel.of(context);
    var mediationModel = DisputeMediationModel.of(context);
    model.uploadingHint = "正在压缩图片..";
    model.progress = 20;
    File compressed = await rotateWithExifAndCompress(image);
    model.uploadingHint = "正在上传图片..";
    model.progress = 40;
    BaseResponse<ImageDetail> resp =
        await Api.uploadPic(compressed.path, onSendProgress: (count, total) {
      model.progress = 60 * count ~/ total + 40;
    });
    model.progress = 100;
    if (resp.success) {
      _sendFutureMessage(
          context,
          ChatMessage.image(
            resp.data.orginPicPath,
            mediationModel.currentUser,
            mediationModel.config,
          ));
    } else {
      showToast(resp.text);
      showToast("图片上传失败,请检查网络");
    }
  }

  void _sendFutureMessage(BuildContext context, ChatMessage message) {
    var model = DisputeMediationModel.of(context);
    var config = model.config;

    Map<String, dynamic> map = {};
    map['type'] = "chatRoomMessage";
    map['data'] = {
      "content": message.data.content,
      "chatroom_id": config.chatRoomId,
//      "duration":message.data.duration,
    };

    model._sendData(json.encode(map));
    model.addMessage(message);
    _messageScrollController.animateTo(0.0,
        duration: Duration(seconds: 1), curve: Curves.ease);
  }
}

enum ChatMessageType { TEXT, AUDIO, IMAGE, COMMAND }

class ChatMessage {
  int code;
  String msg;
  String messageType;
  Data data;

  ChatMessage({this.code, this.msg, this.messageType, this.data});

  ChatMessage.fromJson(Map<String, dynamic> json) {
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
    return 'ChatMessage{code: $code, msg: $msg, messageType: $messageType, data: $data}';
  }

  ChatMessage.text(String content, ChatUser user, ChatGroupConfig config) {
    this.code = 200;
    this.msg = "发送成功";
    this.messageType = TEXT_TYPE;
    this.data = Data(
      userId: user.userId,
      userName: user.userName,
      chatroomId: config.chatRoomId,
      content: content,
      time: DateTime.now().toIso8601String(),
    );
  }

  ChatMessage.image(String content, ChatUser user, ChatGroupConfig config) {
    this.code = 200;
    this.msg = "发送成功";
    this.messageType = TEXT_TYPE;
    this.data = Data(
      userId: user.userId,
      userName: user.userName,
      chatroomId: config.chatRoomId,
      content: "img[$content]",
      time: DateTime.now().toIso8601String(),
    );
  }

  ChatMessage.audio(
      String content, ChatUser user, ChatGroupConfig config, double duration) {
    this.code = 200;
    this.msg = "发送成功";
    this.messageType = TEXT_TYPE;
    this.data = Data(
        userId: user.userId,
        userName: user.userName,
        chatroomId: config.chatRoomId,
        content: "audio[$content]",
        time: DateTime.now().toIso8601String(),
        duration: duration);
  }
}

class Data {
  ///command
  String userId;
  String userName;
  String title;
  String chatroomId;

  ///消息
  String avatar;
  String content;
  String time;
  double duration;

  Data({
    this.userId,
    this.userName,
    this.title,
    this.chatroomId,
    this.content,
    this.avatar,
    this.time,
    this.duration,
  });

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] ?? json['id'].toString();
    userName = json['user_name'] ?? json['name'].toString();
    title = json['title'].toString();
    chatroomId = json['chatroom_id'].toString();

    ///消息
    avatar = json['avatar'].toString();
    content = json['content'].toString();
    time = json['time'].toString();
    duration = json['duration'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['id'] = this.userId;
    data['name'] = this.userName;
    data['user_name'] = this.userName;
    data['title'] = this.title;
    data['chatroom_id'] = this.chatroomId;

    data['avatar'] = this.avatar;
    data['content'] = this.content;
    data['time'] = this.time;
    data['duration'] = this.duration;
    return data;
  }

  @override
  String toString() {
    return 'Data{userId: $userId, userName: $userName, title: $title, chatroomId: $chatroomId, avatar: $avatar, content: $content, time: $time, duration: $duration}';
  }
}
