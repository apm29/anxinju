import 'package:dio/dio.dart';
import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/index.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/ui/widget/loading_state_widget.dart';
import 'package:ease_life/ui/widget/ticker_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'widget/lifecycle_widget.dart';

class LoginPage extends StatefulWidget {
  final String backRoute;

  LoginPage({this.backRoute});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends LifecycleWidgetState<LoginPage> {
  final TextEditingController controllerMobile = TextEditingController();

  final TextEditingController controllerPassword = TextEditingController();

  bool _nameReady = false;
  bool _passReady = false;
  bool _fastLogin = false;
  bool _protocolChecked = true;
  bool _loading = false;
  GlobalKey<TickerWidgetState> tickSmsKey = GlobalKey();
  GlobalKey<LoadingStateWidgetState> loadingLoginKey = GlobalKey();
  final cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    cancelToken.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    ApplicationBloc applicationBloc =
        BlocProviders.of<ApplicationBloc>(context);
    return StreamBuilder<UserInfo>(
        stream: applicationBloc.currentUser,
        builder: (context, AsyncSnapshot<UserInfo> userSnap) {
          Widget loginButton = buildLoginButton(userSnap, context, _fastLogin);
          print('userInfo:${userSnap.data}');
          if (userSnap.hasData && !userSnap.hasError) {
            return buildLoginSuccess(userSnap.data.isCertification == 0);
          } else {
            return buildLogin(context, loginButton);
          }
        });
  }

  Scaffold buildLogin(BuildContext context, Widget loginButton) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录"),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "安心居",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "智慧生活，安心陪伴",
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(6),
                    child: TextField(
                      key: ValueKey("name"),
                      controller: controllerMobile,
                      onChanged: (text) {
                        _nameReady = text.isNotEmpty;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: _fastLogin ? "电话号码" : "用户名",
                          hintText: "输入${_fastLogin ? "电话号码" : "用户名"}"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(6),
                    child: TextField(
                      key: ValueKey("pass"),
                      obscureText: true,
                      onChanged: (text) {
                        _passReady = text.isNotEmpty;
                      },
                      decoration: InputDecoration(
                          hintText: "输入${_fastLogin ? "验证码" : "密码"}",
                          labelText: "${_fastLogin ? "验证码" : "密码"}",
                          border: OutlineInputBorder()),
                      controller: controllerPassword,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Text("短信登录"),
                        Switch(
                            value: _fastLogin,
                            onChanged: (value) {
                              setState(() {
                                _fastLogin = value;
                              });
                            }),
                      ],
                    ),
                  ),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed("/register");
                      },
                      child: Text("注册")),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Checkbox(
                        value: _protocolChecked,
                        onChanged: (value) {
                          setState(() {
                            _protocolChecked = value;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                      FlatButton(
                        child: Text("我已阅读并同意安心居服务平台服务相关条例"),
                        onPressed: () {
                          setState(() {
                            _protocolChecked = !_protocolChecked;
                          });
                        },
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        _fastLogin
                            ? buildSmsButton(context, _fastLogin)
                            : Container(),
                        loginButton,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: _loading,
            child: LoadingDialog(),
          ),
        ],
      ),
    );
  }

  Widget buildLoginSuccess(bool isCertificated) {
    var colorFaceButton = Colors.blue;
    var colorHomeButton = Colors.blueGrey;
    if (widget.backRoute != null) {
      Future.delayed(Duration(seconds: 1)).then((v) {
        Navigator.of(context).pop(widget.backRoute);
      });
    }else{
      Future.delayed(Duration(seconds: 1)).then((v) {
        Navigator.of(context).pushReplacementNamed("/");
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "登录成功",
        ),
      ),
      body: Center(
//        child: Card(
//          elevation: 10,
//          margin: EdgeInsets.all(18),
//          child: Padding(
//            padding: const EdgeInsets.all(6.0),
//            child: Column(
//              mainAxisSize: MainAxisSize.min,
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>[
//                Container(
//                  color: Colors.grey[200],
//                  margin: EdgeInsets.only(bottom: 12),
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Icon(Icons.check, size: 40, color: Colors.blue),
//                      Text(
//                        "登陆成功!",
//                        style: TextStyle(fontSize: 20, color: Colors.blue),
//                      ),
//                    ],
//                  ),
//                ),
//                Text(
//                  "小区已采用智能门禁系统—刷脸出入\n录入脸部资料即可启用，也可在我的-人脸管理录入",
//                  textAlign: TextAlign.center,
//                ),
//                Divider(),
//                Container(
//                  margin: EdgeInsets.all(8),
//                  decoration: BoxDecoration(
//                    border: Border.all(color: colorFaceButton),
//                    borderRadius: BorderRadius.all(Radius.circular(10)),
//                  ),
//                  child: ListTile(
//                    leading: Icon(
//                      Icons.fingerprint,
//                      size: 40,
//                      color: colorFaceButton,
//                    ),
//                    title: Text("录入人脸照片",
//                        style: TextStyle(
//                            fontWeight: FontWeight.bold,
//                            color: colorFaceButton)),
//                    subtitle: Text("一键录入,简单高效",
//                        style: TextStyle(color: colorFaceButton)),
//                    trailing: Icon(
//                      Icons.arrow_forward,
//                      color: colorFaceButton,
//                    ),
//                    onTap: () {
//                      Navigator.of(context).pushReplacementNamed("/preVerify");
//                    },
//                  ),
//                ),
//                FlatButton(
//                  onPressed: () {
//                    Navigator.of(context).pushReplacementNamed("/");
//                  },
//                  padding: EdgeInsets.symmetric(horizontal: 80),
//                  textColor: colorHomeButton,
//                  child: Text(
//                    "放一放,先去首页",
//                    maxLines: 1,
//                  ),
//                )
//              ],
//            ),
//          ),
//        ),
        child: Text("即将跳转.."),
      ),
    );
  }

  Widget buildLoginButton(
      AsyncSnapshot<UserInfo> userSnap, BuildContext context, bool _fastLogin) {
    return LoadingStateWidget(
      key: loadingLoginKey,
      child: RaisedButton(
        onPressed: () {
          login(context, _fastLogin);
        },
        color: Colors.blue,
        child: Text(
          "登录",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget buildSmsButton(BuildContext context, bool fastLogin) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      child: TickerWidget(
        key: tickSmsKey,
        onPressed: () {
          sendSms(context, fastLogin);
        },
      ),
    );
  }

  void hideLoading() {
    setState(() {
      _loading = false;
    });
  }

  void showLoading() {
    setState(() {
      _loading = true;
    });
  }

  void sendSms(BuildContext context, bool fastLogin) async {
    if (!_nameReady) {
      Fluttertoast.showToast(msg: "请填写${fastLogin ? "电话" : "用户名"}");
      return;
    }
    tickSmsKey.currentState?.startLoading();
    BaseResponse<Object> baseResp =
        await Api.sendSms(controllerMobile.text, cancelToken: cancelToken);
    Fluttertoast.showToast(msg: baseResp.text);
    tickSmsKey.currentState?.stopLoading();
    if (baseResp.success()) {
      //发送短信成功
      tickSmsKey.currentState.startTick();
    }
  }

  void login(BuildContext context, bool fastLogin) async {
    var applicationBloc = BlocProviders.of<ApplicationBloc>(context);
    if (!_protocolChecked) {
      Fluttertoast.showToast(msg: "请勾选协议");
      return;
    }
    if (!_nameReady) {
      Fluttertoast.showToast(msg: "请填写${_fastLogin ? "电话" : "用户名"}");
      return;
    }
    if (!_passReady) {
      Fluttertoast.showToast(msg: "请输入${_fastLogin ? "验证码" : "密码"}");
      return;
    }
    loadingLoginKey.currentState?.startLoading();

    BaseResponse<UserInfoWrapper> baseResp = _fastLogin
        ? await Api.fastLogin(controllerMobile.text, controllerPassword.text,
            cancelToken: cancelToken)
        : await Api.login(controllerMobile.text, controllerPassword.text,
            cancelToken: cancelToken);
    print('${baseResp.text}');
    loadingLoginKey.currentState?.stopLoading();
    Fluttertoast.showToast(msg: baseResp.text);
    print('$baseResp');
    if (baseResp.success()) {
      applicationBloc.saveToken(baseResp.token);
      applicationBloc.login(baseResp.data.userInfo);
    } else {
      applicationBloc.login(null);
    }
  }
}
