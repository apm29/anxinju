import 'package:ease_life/ui/user_profile_page.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:soundpool/soundpool.dart';
import 'package:url_launcher/url_launcher.dart';

import 'index.dart';
import 'interaction/audio_recorder.dart';
import 'model/district_model.dart';
import 'model/main_index_model.dart';
import 'model/service_chat_model.dart';
import 'model/user_model.dart';
import 'dart:math';
import 'model/user_role_model.dart';
import 'model/user_verify_status_model.dart';

//List<Color> colors = [
//  Color(0xfffb333d),
//  Color(0xff3d5ffe),
//  Color(0xff16a723),
//  Color(0xfffebf1f),
//];
Future _requestPermission(PermissionGroup group) async {
  var status = await PermissionHandler().checkPermissionStatus(group);
  if (status == PermissionStatus.granted) {
    return null;
  }
  return PermissionHandler().requestPermissions([group]);
}

Future requestPermission() async {
  await _requestPermission(PermissionGroup.storage);
  await _requestPermission(PermissionGroup.camera);
  return null;
}

Future<File> showImageSourceDialog(BuildContext context,
    {VoidCallback onValue}) async {
  FocusScope.of(context).requestFocus(FocusNode());
  await requestPermission();
  return showModalBottomSheet<File>(
      context: context,
      builder: (context) {
        return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return LayoutBuilder(
                builder: (context, constraint) {
                  return IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            showPicker().then((f) {
                              Navigator.of(context).pop(f);
                            });
                            SystemSound.play(SystemSoundType.click);
                          },
                          child: Container(
                            width: constraint.biggest.width,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(18.0),
                            child: Text("相册"),
                          ),
                        ),
                        InkWell(
                            onTap: () {
                              showCameraPicker().then((f) {
                                Navigator.of(context).pop(f);
                              });
                              SystemSound.play(SystemSoundType.click);
                            },
                            child: Container(
                              width: constraint.biggest.width,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(18.0),
                              child: Text("拍照"),
                            )),
                      ],
                    ),
                  );
                },
              );
            });
      }).then((v) {
    if (onValue != null) onValue.call();
    return v;
  });
}

Future<File> showPicker() {
  return ImagePicker.pickImage(source: ImageSource.gallery);
}

Future<File> showCameraPicker() {
  return ImagePicker.pickImage(source: ImageSource.camera);
}

///只能作用于带exif的image
///旋转Android图片并压缩
Future<File> rotateWithExifAndCompress(File file) async {
  if (!Platform.isWindows) {
    if (file == null) {
      return null;
    }
    return FlutterImageCompress.compressAndGetFile(file.path, file.path,
        quality: 70);
//    return FlutterImageCompress.compressWithFile(file.path,quality: 30,minHeight: 768,minWidth: 1080).then((listInt) {
//      if (listInt == null) {
//        return null;
//      }
//      file.writeAsBytesSync(listInt, flush: true, mode: FileMode.write);
//      return file;
//    });
  }
  return Future.value(file).then((file) {
    if (file == null) {
      return null;
    }
    //通过exif旋转图片
    //return FlutterExifRotation.rotateImage(path: file.path);
    return file;
  }).then((f) {
    if (f == null) {
      return null;
    }
    //压缩图片
    return FlutterImageCompress.compressWithFile(
      f.path,
      quality: 80,
    );
  }).then((listInt) {
    if (listInt == null) {
      return null;
    }
    file.writeAsBytesSync(listInt, flush: true, mode: FileMode.write);
    return file;
  });
}

Widget buildVisitor(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    child: InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(LoginPage.routeName);
        SystemSound.play(SystemSoundType.click);
      },
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Icon(
                  Icons.sms_failed,
                  color: Colors.blue,
                  size: 40,
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "未登录,点击登录",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Future<Location> getLocation() async {
  return AMapLocation()
      .getLocation(LocationClientOptions(isOnceLocation: true));
}

///选择住房 幢-单元-房间号
Future<String> showRoomPicker(BuildContext context, int districtId) async {
  return Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    return BuildingPicker(
      districtId: districtId,
    );
  })).then((address) {
    return address;
  });
}

Future<String> getImageBase64(File file) async {
  return file.readAsBytes().then((bytes) {
    return "data:image/jpeg;base64,${base64Encode(bytes)}";
  });
}

Widget buildCertificationDialog(BuildContext context, VoidCallback onCancel,
    {bool showQuit = true}) {
  var colorFaceButton = Colors.blue;
  return AlertDialog(
    title: Text(
      "人脸核验未通过,只能使用首页功能",
      style: TextStyle(
        fontSize: 16,
        color: Colors.blueGrey,
      ),
    ),
    actions: <Widget>[
      FlatButton(
        onPressed: onCancel,
        textColor: Colors.blueGrey,
        child: Text(
          "暂不认证",
          maxLines: 1,
        ),
      ),
      showQuit
          ? FlatButton(
              onPressed: () {
                UserModel.of(context).logout(context);
              },
              textColor: Colors.blueGrey,
              child: Text(
                "退出登录",
                maxLines: 1,
              ),
            )
          : Container()
    ],
    content: Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: colorFaceButton),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: ListTile(
        leading: Icon(
          Icons.fingerprint,
          size: 40,
          color: colorFaceButton,
        ),
        title: Text("录入人脸照片",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: colorFaceButton)),
        subtitle: Text("一键录入,简单高效", style: TextStyle(color: colorFaceButton)),
        trailing: Icon(
          Icons.arrow_forward,
          color: colorFaceButton,
        ),
        onTap: () {
          Navigator.of(context)
              .pushNamed(UserDetailAuthPage.routeName)
              .then((v) {
            //获取当前用户信息
            Future.delayed(Duration(milliseconds: 500), () {
              return Api.getUserInfo().then((baseResp) {
                if (baseResp.success) {
                  UserModel.of(context)
                      .login(baseResp.data, baseResp.token, context);
                }
              });
            });
          });
          SystemSound.play(SystemSoundType.click);
        },
      ),
    ),
  );
}

GlobalKey<UpdateDialogState> updateDialogKey = GlobalKey();

void showUpdateDialog(BuildContext context, UpgradeInfo info) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            //强制更新时不让取消
            return info.updateType == 2 ? false : true;
          },
          child: UpdateDialog(
            key: updateDialogKey,
            info: info,
            onClickWhenDownload: () {
              Fluttertoast.showToast(msg: "正在下载");
            },
            onClickWhenNotDownload: () {
              DioUtil().downloadFile(info.apkUrl, (count, total, path) {
                var _progress = count / total;
                updateDialogKey.currentState.progress = _progress;
                if (_progress >= 1) {
                  Fluttertoast.showToast(msg: "下载完成");
                  OpenFile.open(path);
                }
              });
            },
          ),
        );
      });
}

///----------------------------------------------------NEW FUNCTION------------------------------------------------///

Future toWebPage(BuildContext context, String indexId,
    {Map<String, dynamic> params,
    bool checkHasHouse = false,
    bool checkFaceVerified = true}) async {
  var userVerifyStatusModel = UserVerifyStatusModel.of(context);
  var userModel = UserModel.of(context);
  var districtModel = DistrictModel.of(context);
  if (checkFaceVerified || checkHasHouse) {
    if (!userModel.isLogin) {
      return Navigator.of(context).pushNamed("/login");
    }
  }
  if (checkFaceVerified) {
    if (!userVerifyStatusModel.isVerified()) {
      return showFaceVerifyDialog(context);
    }
  }
  if (checkHasHouse) {
    if (!districtModel.hasHouse()) {
      return showApplyHouseDialog(context);
    }
  }

  return routeDirectlyToWebPage(context, params, indexId);
}

Future routeDirectlyToWebPage(
    BuildContext context, Map<String, dynamic> params, String indexId) {
  return MainIndexModel.of(context).tryFetchIndex().then((list) {
    for (var index in list) {
      var menuItem = index.menu.firstWhere((menu) {
        return menu.id == indexId;
      }, orElse: () => null);
      if (menuItem != null) {
        return Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return WebViewExample(menuItem.url);
        }));
      }
    }
    return Navigator.of(context).pushNamed(indexId, arguments: params);
  });
}

Future showApplyHouseDialog(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提醒"),
          content: Text.rich(
            TextSpan(children: [
              TextSpan(text: "您身份证名下还未拥有当前小区房屋,您可以申请成为房屋成员,若您已经提交申请,请在"),
              TextSpan(
                  text: "申请记录",
                  style: TextStyle(
                    color: Colors.blueAccent,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      routeDirectlyToWebPage(context, {}, "sqjl");
                      SystemSound.play(SystemSoundType.click);
                    }),
              TextSpan(
                text: "中查看已提交的申请",
              ),
            ]),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemSound.play(SystemSoundType.click);
              },
              child: Text("取消"),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context)
                    .pushReplacementNamed(MemberApplyPage.routeName);
                SystemSound.play(SystemSoundType.click);
              },
              child: Text("前往申请"),
            ),
          ],
        );
      });
}

Future showFaceVerifyDialog(BuildContext context) async {
  var colorFaceButton = Colors.blue;

  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "人脸核验未通过,只能使用部分功能",
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              textColor: Colors.blueGrey,
              child: Text(
                "暂不认证",
                maxLines: 1,
              ),
            ),
          ],
          content: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: colorFaceButton),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: ListTile(
              leading: Icon(
                Icons.fingerprint,
                size: 40,
                color: colorFaceButton,
              ),
              title: Text("录入人脸照片",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: colorFaceButton)),
              subtitle:
                  Text("一键录入,简单高效", style: TextStyle(color: colorFaceButton)),
              trailing: Icon(
                Icons.arrow_forward,
                color: colorFaceButton,
              ),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(UserDetailAuthPage.routeName);
                SystemSound.play(SystemSoundType.click);
              },
            ),
          ),
        );
      });
}

Future makePhoneCall(String number) async {
  var urlString = "tel:$number";
  if (await canLaunch(urlString)) {
    return launch(urlString, enableJavaScript: true, enableDomStorage: true);
  }
  return showToast("无法呼叫 $number");
}

Future playMessageSound() async {
  if ((userSp.getBool(KEY_MESSAGE_SOUND) ?? true) != true) {
    return;
  }
  Soundpool pool = Soundpool(streamType: StreamType.notification);
  int soundId = await rootBundle
      .load("images/message_arrive.mp3")
      .then((ByteData soundData) {
    return pool.load(soundData);
  }).catchError((e) {
    print(e.toString());
  });
  int streamId = await pool.play(soundId);
}

Function imagePlaceHolder =
    (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
  if (loadingProgress == null) return child;
  return Center(
    child: CircularProgressIndicator(
      value: loadingProgress.expectedTotalBytes != null
          ? loadingProgress.cumulativeBytesLoaded /
              loadingProgress.expectedTotalBytes
          : null,
    ),
  );
};

/// CHAT

Offstage buildUploadDialog(bool offstage, String hint, double progress) {
  return Offstage(
    offstage: offstage,
    child: Align(
      alignment: Alignment.center,
      child: AlertDialog(
        title: Text(hint),
        content: LinearProgressIndicator(
          value: progress,
        ),
      ),
    ),
  );
}

Widget buildChatInputPart({
  bool disconnected,
  bool showAudio = false,
  bool showEmoji = false,
  bool textInputMode = true,
  VoidCallback onSwitchEmoji,
  VoidCallback onSwitchAudio,
  ValueChanged<RecordDetail> onStopRecord,
  VoidCallback onSendText,
  VoidCallback onSendImage,
  ValueChanged<String> onTextChange,
  ValueChanged<String> onSelectEmoji,
  TextEditingController textInputController,
  FocusNode textFocusNode,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      AbsorbPointer(
        absorbing: disconnected,
        child: IntrinsicHeight(
          child: Container(
            decoration: BoxDecoration(
              color: disconnected ? Colors.grey[300] : Colors.transparent,
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Material(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    color: disconnected ? Colors.white54 : Colors.white,
                    elevation: 3,
                    child: Row(
                      children: <Widget>[
                        showAudio
                            ? Container()
                            : IconButton(
                                onPressed: () {
                                  onSwitchEmoji?.call();
                                },
                                padding: EdgeInsets.all(0),
                                icon: Icon(
                                  Icons.insert_emoticon,
                                  color: showEmoji
                                      ? Colors.lightBlue
                                      : disconnected
                                          ? Colors.blueGrey
                                          : Colors.grey[800],
                                ),
                              ),
                        Expanded(
                          child: showAudio
                              ? AudioInputWidget(
                                  (recordDetail) {
                                    onStopRecord?.call(recordDetail);
                                  },
                                  showBorder: false,
                                )
                              : Container(
                                  height: ScreenUtil().setHeight(105),
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(
                                          Platform.isAndroid ? 25 : 16)),
                                  child: TextField(
                                    focusNode: textFocusNode,
                                    enabled: !disconnected,
                                    controller: textInputController,
                                    maxLines: 100,
                                    textInputAction: TextInputAction.send,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(0),
                                      hintText: disconnected ? "等待中.." : "说点什么",
                                      isDense: false,
                                      alignLabelWithHint: true,
                                    ),
                                    onSubmitted: (content) {
                                      onSendText?.call();
                                    },
                                    onChanged: (s) {
                                      onTextChange?.call(s);
                                    },
                                  ),
                                ),
                        ),
                        IconButton(
                          onPressed: () {
                            textInputMode
                                ? onSendText?.call()
                                : onSendImage?.call();
                          },
                          icon: Icon(
                            textInputMode ? Icons.send : Icons.camera_alt,
                            color: disconnected
                                ? Colors.blueGrey
                                : Colors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(6),
                  child: Material(
                    elevation: 3,
                    shape: CircleBorder(),
                    color: disconnected ? Colors.blueGrey : Colors.lightBlue,
                    child: InkWell(
                      onTap: () {
                        onSwitchAudio?.call();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          !showAudio ? Icons.mic : Icons.message,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Visibility(
        visible: showEmoji,
        child: Container(
          color: Colors.white,
          child: Wrap(
            children: faces.map((name) {
              return InkWell(
                onTap: () {
                  onSelectEmoji?.call("face" + name);
                },
                child: Container(
                  margin: EdgeInsets.all(ScreenUtil().setWidth(12)),
                  child: Image.asset("images/face/${faces.indexOf(name)}.gif"),
                ),
              );
            }).toList(),
          ),
        ),
      )
    ],
  );
}

Widget buildMessage(
    BuildContext context, bool self, ServiceChatMessage chatMessage) {
  var messageTile;
  messageTile = <Widget>[
    Flexible(
      flex: 100,
      child: Container(),
    ),
    _buildMessageBody(context, chatMessage, self: self),
    _buildMessageUserName(chatMessage, self: self),
  ];
  //消息
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: self ? messageTile : messageTile.reversed.toList(),
  );
}

Widget _buildMessageBody(BuildContext context, ServiceChatMessage chatMessage,
    {bool self = true}) {
  var messageContent = chatMessage.content;
  if (messageContent.startsWith("img[") && messageContent.endsWith("]")) {
    ///图片
    var imageUrl = _getRemoteUrl(messageContent);
    return _buildMessageWrapper(
      context,
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
      self: self,
    );
  } else if (messageContent.startsWith("audio[") &&
      messageContent.endsWith("]")) {
    ///音频
    return _buildMessageWrapper(
        context,
        AudioMessageTile(
          _getAudioUrl(messageContent),
          0,
        ),
        chatMessage,
        noDecoration: true,
        self: self);
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
    context,
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
    self: self,
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
  return (time.difference(DateTime.now()).inDays.abs()) < 1;
  //return false;
}

Widget _buildMessageWrapper(
  BuildContext context,
  Widget messageContent,
  ServiceChatMessage chatMessage, {
  bool noDecoration = false,
  bool self = true,
}) {
  var name = chatMessage.nickName;
  if (name == null || name.isEmpty) {
    name = "未命名用户";
  }
  var nameTimeRow = <Widget>[
    SizedBox(
      width: 10,
    ),
    Text(
      name,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        shadows: [
          Shadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 1)
        ],
      ),
    ),
    SizedBox(
      width: 2,
    ),
    Text(_getMessageSendTime(chatMessage.time)),
  ];
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: self ? MainAxisAlignment.end : MainAxisAlignment.start,
    crossAxisAlignment:
        self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: <Widget>[
      DefaultTextStyle(
        style: Theme.of(context).textTheme.caption,
        child: Row(
          children: self ? (nameTimeRow.reversed.toList()) : nameTimeRow,
        ),
      ),
      Container(
        margin: noDecoration
            ? null
            : EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        padding: noDecoration
            ? null
            : EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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

Widget _buildMessageUserName(ServiceChatMessage chatMessage, {self = true}) {
  var avatar = chatMessage.userAvatarUrl;
  var noAvatar = avatar == null || avatar.isEmpty;
  return Container(
    margin: EdgeInsets.only(
      left: self ? 0 : 6,
      bottom: 6,
      right: self ? 6 : 0,
    ),
    decoration: BoxDecoration(
        border: Border.all(
          color: Colors.green,
          width: 1,
        ),
        shape: BoxShape.circle),
    child: CircleAvatar(
      backgroundImage: NetworkImage(avatar),
      child:
          noAvatar ? Text(chatMessage.nickName.substring(0, 1)) : Container(),
    ),
  );
}

Container buildAvatar(
  BuildContext context,
  String url, {
  bool circleBorder = false,
  VoidCallback onPressed,
  showEditBanner = false,
}) {
  onPressed = onPressed ??
      () {
        UserProfilePage.go(context);
      };
  return Container(
    constraints: BoxConstraints.tight(Size(
      ScreenUtil().setHeight(180),
      ScreenUtil().setHeight(180),
    )),
    child: Material(
      color: Colors.blueGrey[200],
      borderRadius: circleBorder
          ? null
          : BorderRadius.all(
              Radius.circular(5),
            ),
      elevation: 6,
      shape: circleBorder ? CircleBorder() : null,
      type: MaterialType.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          onPressed?.call();
          SystemSound.play(SystemSoundType.click);
        },
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: url != null
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.person_outline,
                      size: 32,
                      color: Colors.white,
                    ),
            ),
            showEditBanner
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      alignment: Alignment.center,
                      height: ScreenUtil().setHeight(70),
                      width: ScreenUtil().setHeight(180),
                      color: Colors.black.withAlpha(100),
                      child: Text(
                        "修改",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    ),
  );
}

Consumer<UserModel> buildRoleSwitchButton() {
  return Consumer<UserModel>(
    builder: (BuildContext context, UserModel userModel, Widget child) {
      return userModel.hasSwitch
          ? FlatButton.icon(
              icon: Icon(
                Icons.repeat,
                color: Colors.blue,
              ),
              onPressed: () {
                userModel.switchRole();
                SystemSound.play(SystemSoundType.click);
              },
              label: Text("${userModel.switchString}"),
            )
          : Container();
    },
  );
}
