import 'package:ease_life/index.dart';
import 'package:dio/dio.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:oktoast/oktoast.dart';

import 'widget/gradient_button.dart';

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
    return buildLogin(context);
  }

  Scaffold buildLogin(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: <Widget>[
          Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        bottom: 6,
                        top: MediaQuery.of(context).padding.top + 32,
                        left: 12,
                        right: 12),
                    child: Material(
                      elevation: 8,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.transparent,
                                ),
                                onPressed: null,
                              ),
                              Expanded(
                                child: Text(
                                  _fastLogin ? "短信登录" : "用户名登录",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.title,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Image.asset(
                            "images/ic_launcher.png",
                            width: ScreenUtil().setWidth(200),
                          ),
                          Text(
                            "智慧生活，安心陪伴",
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: 6, left: 12, right: 12),
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
                              buildCounter: (_,
                                  {currentLength, maxLength, isFocused}) {
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
                                    SystemSound.play(SystemSoundType.click);
                                  },
                                  child: Icon(Icons.clear),
                                ),
                                contentPadding: EdgeInsets.all(6),
                              ),
                              textInputAction: TextInputAction.next,
                              onSubmitted: (s) {
                                _focusNodePass.requestFocus();
                              },
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: 6, left: 12, right: 12),
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
                                    SystemSound.play(SystemSoundType.click);
                                  },
                                  child: Icon(_showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                                contentPadding: EdgeInsets.all(6),
                              ),
                              controller: controllerPassword,
                              textInputAction: TextInputAction.go,
                              onSubmitted: (s) {
                                login(context, _fastLogin, showLoading: true);
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
                                _fastLogin
                                    ? buildSmsButton(context, _fastLogin)
                                    : Container(),
                              ],
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              buildLoginButton(context, _fastLogin),
                            ],
                          ),
                        ],
                      ),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Checkbox(
                        value: _protocolChecked,
                        onChanged: (value) {
                          setState(() {
                            _protocolChecked = value;
                          });
                        },
                        activeColor: Colors.blueAccent,
                      ),
                      Expanded(
                        child: InkWell(
                          child: IntrinsicWidth(
                            child: Text(
                              "我已阅读并同意${Strings.appName}服务平台服务用户协议",
                              style: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _protocolChecked = !_protocolChecked;
                            });
                            SystemSound.play(SystemSoundType.click);
                          },
                        ),
                      )
                    ],
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

  Widget buildLoginButton(BuildContext context, bool _fastLogin) {
    return Expanded(
      child: GradientButton(
        Text(
          "登录",
          style: TextStyle(fontSize: 18),
        ),
        unconstrained: false,
        borderRadius: 0,
        gradient: LinearGradient(
          colors: [Colors.blue[500], Colors.blueAccent[700]],
        ),
        onPressed: () async {
          await login(context, _fastLogin);
        },
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
        await Api.sendSms(controllerMobile.text, 1, cancelToken: cancelToken);
    Fluttertoast.showToast(msg: baseResp.text);
    tickSmsKey.currentState?.stopLoading();
    if (baseResp.success) {
      //发送短信成功
      tickSmsKey.currentState.startTick();
    }
  }

  Future login(BuildContext context, bool fastLogin,
      {bool showLoading = false}) async {
    if (!_protocolChecked) {
      showToast("请勾选协议");
      return;
    }
    if (!_nameReady) {
      showToast("请填写${_fastLogin ? "电话" : "用户名"}");
      return;
    }
    if (!_passReady) {
      showToast("请输入${_fastLogin ? "验证码" : "密码"}");
      return;
    }
    var toastFuture = showToastWidget(
      LoadingDialog(),
      duration: Duration(seconds: 25),
    );
    BaseResponse<UserInfoWrapper> baseResp = _fastLogin
        ? await Api.fastLogin(controllerMobile.text, controllerPassword.text,
            cancelToken: cancelToken)
        : await Api.login(controllerMobile.text, controllerPassword.text,
            cancelToken: cancelToken);

    if (baseResp.success) {
      await UserModel.of(context)
          .login(baseResp.data.userInfo, baseResp.token, context);
      Navigator.of(context).pop(baseResp.token);
    } else {
      showToast(baseResp.text);
    }
    toastFuture?.dismiss(showAnim: true);
    return;
  }
}
