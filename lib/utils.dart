import 'index.dart';
import 'model/main_index_model.dart';
import 'model/user_model.dart';
import 'model/user_verify_status_model.dart';

//List<Color> colors = [
//  Color(0xfffb333d),
//  Color(0xff3d5ffe),
//  Color(0xff16a723),
//  Color(0xfffebf1f),
//];

typedef OnFileProcess = Function(Future<File>);

Future<File> showImageSourceDialog(
    BuildContext context, VoidCallback onValue) async {
  FocusScope.of(context).requestFocus(FocusNode());
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
                            showPicker().then((f){
                              Navigator.of(context).pop(f);
                            });

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
                              showCameraPicker().then((f){
                                Navigator.of(context).pop(f);
                              });
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
    onValue();
    return v;
  });
}

Future<File> showPicker() {
  return ImagePicker.pickImage(source: ImageSource.gallery);
}

Future<File> showCameraPicker() {
  return ImagePicker.pickImage(source: ImageSource.camera);
}

void startAudioRecord() {}

///只能作用于带exif的image
///旋转Android图片并压缩
Future<File> rotateWithExifAndCompress(File file) async {
  if (!Platform.isWindows) {
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
    return FlutterExifRotation.rotateImage(path: file.path);
  }).then((f) {
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
  return GestureDetector(
    onTap: () {
      Navigator.of(context).pushNamed(LoginPage.routeName);
    },
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
  );
}

Widget buildError(BuildContext context, Object err) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).pushNamed(LoginPage.routeName);
    },
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            "$err",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Colors.grey[700]),
          ),
        ],
      ),
    ),
  );
}

Future<Location> getLocation() async {
  return AMapLocation().getLocation(LocationClientOptions());
}

///
/// 先获取index数据在导航到指定的webview
///
void routeToWebIndex(BuildContext context, String indexId,
    {bool refresh = true}) {
  getIndex(refresh).then((list) {
    return list.firstWhere((index) {
      return index.area == "mine";
    }, orElse: () {
      return null;
    });
  }).then((index) {
    if (index == null) {
      Fluttertoast.showToast(msg: "获取路由数据失败");
    } else {
      routeToWeb(context, indexId, index);
    }
  });
}

List<Index> indexInfo;

Future<List<Index>> getIndex(bool refresh) {
  return (refresh || indexInfo == null || indexInfo.length == 0)
      ? Api.getIndex().then((v) {
          indexInfo = v;
          return v;
        })
      : Future.value(indexInfo);
}

void routeToWeb(BuildContext context, String id, Index index) {
  var indexWhere = index.menu.indexWhere((i) => i.id == id);
  if (indexWhere < 0) {
    Fluttertoast.showToast(msg: "无效路由");
    return;
  }
  var url = index.menu[indexWhere].url;
  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    return WebViewExample(url);
  }));
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
                  BlocProviders.of<ApplicationBloc>(context)
                      .login(baseResp.data);
                }
              });
            });
          });
        },
      ),
    ),
  );
}

///显示未认证弹框
showCertificationDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return buildCertificationDialog(context, () {
          Navigator.of(context).popUntil((r) {
            return r.settings.name == MainPage.routeName;
          });
        }, showQuit: false);
      });
}

///先检查是否登录,再检查是否认证,未认证用户会弹出认证弹框
bool checkIfCertificated(BuildContext context) {
  if (!isLogin()) {
    Navigator.of(context).pushNamed(LoginPage.routeName);
    return false;
  }
  if (!isVerified()) {
    Fluttertoast.showToast(msg: "请先完成${Strings.hostClass}认证");
    showCertificationDialog(context);
    return false;
  } else {
    return true;
  }
}

void showAuthDialog(BuildContext context, Index indexInfo) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Icon(
                Icons.warning,
                color: Colors.blue,
              ),
              Text("无可用${Strings.roomClass}")
            ],
          ),
          content: Text.rich(TextSpan(children: [
            TextSpan(
              text:
                  "您当前选择的${Strings.districtClass},名下还没有认证${Strings.roomClass},请选择重新认证,申请成为成员或者切换${Strings.districtClass}\r\n如果您已经申请,请在",
            ),
            TextSpan(
                text: "申请记录",
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    var indexWhere = indexInfo.menu
                        .indexWhere((i) => i.id == WebIndexID.SHEN_QING_JI_LU);
                    if (indexWhere < 0) {
                      ///先pop再路由,否则dialog的context找不到listener
                      Navigator.of(context).pop(WebIndexID.SHEN_QING_JI_LU);
                    } else {
                      Navigator.of(context).pop();
                      routeToWeb(
                          context, WebIndexID.SHEN_QING_JI_LU, indexInfo);
                    }
                  }),
            TextSpan(
              text: "查看申请进度",
            ),
          ])),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "取消",
                  style: TextStyle(color: Colors.blueGrey),
                )),
            FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(UserDetailAuthPage.routeName);
                },
                child: Text("重新认证")),
            FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(MemberApplyPage.routeName);
                },
                child: Text("前往申请")),
          ],
        );
      }).then((value) {
    if (value == WebIndexID.SHEN_QING_JI_LU) {
      routeToWebByCache(context, PAGE_MINE,
          indexId: WebIndexID.SHEN_QING_JI_LU);
    }
    //获取当前用户信息
    Future.delayed(Duration(milliseconds: 500), () {
      return Api.getUserInfo().then((baseResp) {
        if (baseResp.success) {
          BlocProviders.of<ApplicationBloc>(context).login(baseResp.data);
        }
      });
    });
  });
}

///导航到指定页面
/// 发起者Widget ---> MainPage(NotificationListener) --> WebView
void routeToWebByCache(BuildContext context, int mainIndex, {String indexId}) {
  (IndexNotification(mainIndex)..indexId = indexId).dispatch(context);
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
    if (!userVerifyStatusModel.hasHouse()) {
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
        return Navigator.of(context)
            .push(MaterialPageRoute(builder: (_){
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
              },
              child: Text("取消"),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed("/apply");
              },
              child: Text("前往申请"),
            ),
          ],
        );
      });
}

Future showFaceVerifyDialog(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提醒"),
          content: Text("您还未通过人脸对比,点击实名验证按钮前往认证"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("取消"),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(UserDetailAuthPage.routeName);
              },
              child: Text("实名验证"),
            ),
          ],
        );
      });
}