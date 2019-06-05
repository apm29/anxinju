import 'package:ease_life/index.dart';
import 'package:dio/dio.dart';
class LoginPage extends StatefulWidget {
  final String backRoute;
  static String routeName = "/login";

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
  bool _showPassword = false;
  GlobalKey<TickerWidgetState> tickSmsKey = GlobalKey();
  GlobalKey<LoadingStateWidgetState> loadingLoginKey = GlobalKey();
  final cancelToken = CancelToken();
  FocusNode _focusNodePass = FocusNode();
  FocusNode _focusNodeMobile = FocusNode();

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
            return buildLoginSuccess(
                userSnap.data.isCertification == 0, context);
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
//                  Text(
//                    Strings.appName,
//                    style: TextStyle(fontSize: 24,color: Colors.indigo),
//                    textAlign: TextAlign.center,
//                  ),
                  Image.asset("images/ic_launcher.png",width: ScreenUtil().setWidth(200),),
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
                      focusNode: _focusNodeMobile,
                      controller: controllerMobile,
                      onChanged: (text) {
                        _nameReady = text.isNotEmpty;
                      },
                      maxLength: _fastLogin ? 11 : 32,
                      maxLengthEnforced: true,
                      buildCounter: (_, {currentLength, maxLength, isFocused}) {
                        return Container();
                      },
                      keyboardType: _fastLogin
                          ? TextInputType.number
                          : TextInputType.text,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: _fastLogin ? "电话号码" : "用户名",
                          hintText: "输入${_fastLogin ? "电话号码" : "用户名"}",
                          suffixIcon: InkWell(
                            onTap: () {
                              controllerMobile.clear();
                            },
                            child: Icon(Icons.clear),
                          )),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (s) {
                        _focusNodePass.requestFocus();
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(6),
                    child: TextField(
                      key: ValueKey("pass"),
                      focusNode: _focusNodePass,
                      obscureText: !_showPassword,
                      onChanged: (text) {
                        _passReady = text.isNotEmpty;
                      },
                      keyboardType: _fastLogin
                          ? TextInputType.number
                          : TextInputType.text,
                      decoration: InputDecoration(
                          hintText: "输入${_fastLogin ? "验证码" : "密码"}",
                          labelText: "${_fastLogin ? "验证码" : "密码"}",
                          border: OutlineInputBorder(),
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            child: Icon(_showPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                          )),
                      controller: controllerPassword,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (s) {
                        login(context, _fastLogin);
                      },
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
                                controllerMobile.clear();
                                controllerPassword.clear();
                              });
                            }),
                      ],
                    ),
                  ),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(RegisterPage.routeName);
                      },
                      child: Text(
                        "注册",
                        style: TextStyle(color: Colors.blue, fontSize: 18),
                      )),
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
                      Expanded(
                        child: FlatButton(
                          child: Text("我已阅读并同意${Strings.appName}服务平台服务相关条例"),
                          onPressed: () {
                            setState(() {
                              _protocolChecked = !_protocolChecked;
                            });
                          },
                        ),
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

  Widget buildLoginSuccess(bool isCertificated, BuildContext context) {
    if (widget.backRoute != null) {
      Future.delayed(Duration(seconds: 1)).then((v) {
        Navigator.of(context).pop(widget.backRoute);
      });
    } else {
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
        await Api.sendSms(controllerMobile.text,1, cancelToken: cancelToken);
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
