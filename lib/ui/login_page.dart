import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController controllerMobile = TextEditingController();

  final TextEditingController controllerPassword = TextEditingController();

  bool _nameReady = false;
  bool _passReady = false;
  bool _fastLogin = false;
  bool _protocolChecked = true;

  @override
  Widget build(BuildContext context) {
    print('build');
    ApplicationBloc applicationBloc =
        BlocProviders.of<ApplicationBloc>(context);
    return StreamBuilder<UserInfo>(
        stream: applicationBloc.currentUser,
        builder: (context, userSnap) {
          Widget loginButton = buildLoginButton(userSnap, context, _fastLogin);
          if (userSnap.hasData && userSnap.data.normal()) {
            if (userSnap.data.isCertification == 0) {
              //登录成功,已认证
              Observable.just(1).delay(Duration(seconds: 1)).listen((i) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    "/verify", (r) => r.settings.name == "/");
              });
              return buildLoginSuccess();
            } else {
              //登录成功,已认证
              Observable.just(1).delay(Duration(seconds: 1)).listen((i) {
                Navigator.of(context).popUntil((r) => r.settings.name == "/");
              });
            }
          }
          return buildLogin(context, loginButton);
        });
  }

  Scaffold buildLogin(BuildContext context, Widget loginButton) {
    return Scaffold(
          appBar: AppBar(
            title: Text("登录"),
          ),
          body: Center(
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
                      controller: controllerPassword,
                      decoration: InputDecoration(
                          hintText: "输入${_fastLogin ? "验证码" : "密码"}"),
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
                        activeColor: Colors.blueGrey,
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
        );
  }

  Scaffold buildLoginSuccess() {
    return Scaffold(
              appBar: AppBar(
                title: Text("登录成功前往认证"),
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.check,size: 40,),
                    Text("登陆成功"),
                  ],
                ),
              ),
            );
  }

  Widget buildLoginButton(
      AsyncSnapshot<UserInfo> userSnap, BuildContext context, bool _fastLogin) {
    Widget loginButton;
    if (!userSnap.hasData) {
      loginButton = OutlineButton(
        onPressed: () {
          login(context, _fastLogin);
        },
        child: Text("登录"),
      );
    } else if (userSnap.hasData && userSnap.data.loading()) {
      loginButton = FlatButton(
        onPressed: () {},
        child: CircularProgressIndicator(),
      );
    } else {
      loginButton = OutlineButton(
        onPressed: () {
          login(context, _fastLogin);
        },
        child: Text("登录"),
      );
    }
    return loginButton;
  }

  Widget buildSmsButton(BuildContext context, bool fastLogin) {
    return StreamBuilder<int>(
      builder: (context, snapshot) {
        print('${snapshot.data}');
        if (!snapshot.hasData || snapshot.data == 0) {
          return FlatButton(
            child: Text(
              "发送短信",
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              sendSms(context, fastLogin);
            },
          );
        } else if (snapshot.data < 0) {
          return CircularProgressIndicator();
        } else {
          return FlatButton(
            onPressed: () {},
            child: Text(
              "(${snapshot.data})S",
              style: TextStyle(color: Colors.blue),
            ),
          );
        }
      },
      stream: BlocProviders.of<LoginBloc>(context).smsStream,
    );
  }

  void sendSms(BuildContext context, bool fastLogin) {
    if (!_nameReady) {
      Fluttertoast.showToast(msg: "请填写${fastLogin ? "电话" : "用户名"}");
      return;
    }
    BlocProviders.of<LoginBloc>(context).sendSms(
      controllerMobile.text,
    );
  }

  void login(BuildContext context, bool fastLogin) async {
    var applicationBloc = BlocProviders.of<ApplicationBloc>(context);
    if (!_protocolChecked) {
      Fluttertoast.showToast(msg: "请勾选协议");
      return;
    }
    if (!_nameReady) {
      Fluttertoast.showToast(msg: "请填写${_fastLogin? "电话" : "用户名"}");
      return;
    }
    if (!_passReady) {
      Fluttertoast.showToast(msg: "请输入${_fastLogin ? "验证码" : "密码"}");
      return;
    }
    _fastLogin
        ? applicationBloc.fastLogin(
            controllerMobile.text,
            controllerPassword.text,
          )
        : applicationBloc.login(
            controllerMobile.text,
            controllerPassword.text,
          );
  }
}
