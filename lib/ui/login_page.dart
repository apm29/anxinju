import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController controllerMobile = TextEditingController();

  final TextEditingController controllerPassword = TextEditingController();

  bool _nameReady = false;

  bool _passReady = false;

  @override
  Widget build(BuildContext context) {
    print('build');
    LoginBloc loginBloc = BlocProviders.of<LoginBloc>(context);
    return StreamBuilder<bool>(
        stream: loginBloc.typeStream,
        builder: (context, snapshot) {
          bool _fastLogin = snapshot.hasData ? snapshot.data : false;
          return Scaffold(
            appBar: AppBar(
              title: Text("登录"),
            ),
            body: SingleChildScrollView(
              child: Center(
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
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey)),
                      child: TextField(
                        key: ValueKey("name"),
                        controller: controllerMobile,
                        onChanged: (text) {
                          _nameReady = text.isNotEmpty;
                        },
                        decoration: InputDecoration.collapsed(
                            hintText: "输入${_fastLogin ? "电话号码" : "用户名"}"),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey)),
                      child: TextField(
                        key: ValueKey("pass"),
                        obscureText: true,
                        onChanged: (text) {
                          _passReady = text.isNotEmpty;
                        },
                        controller: controllerPassword,
                        decoration: InputDecoration.collapsed(
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
                                print('$value');
                                loginBloc.switchType(value);
                              }),
                        ],
                      ),
                    ),
                    StreamBuilder<CheckData>(
                        stream: loginBloc.serviceStream,
                        builder: (context, snapshot) {
                          bool _checked = snapshot?.data?.checked ?? true;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Checkbox(
                                value: _checked,
                                onChanged: (value) {
                                  loginBloc.switchService(value);
                                },
                                activeColor: Colors.blueGrey,
                              ),
                              FlatButton(
                                child: Text("我已阅读并同意安心居服务平台服务相关条例"),
                                onPressed: () {
                                  loginBloc.switchService(!_checked);
                                },
                              )
                            ],
                          );
                        }),
                    Container(
                      margin: EdgeInsets.only(right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          _fastLogin ? buildSmsButton(context,_fastLogin) : Container(),
                          StreamBuilder<UserInfo>(
                              stream: BlocProviders.of<ApplicationBloc>(context)
                                  .currentUser,
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    !snapshot.data.loading()) {
                                  if (snapshot.data.isCertification > 0) {
                                    Navigator.of(context).popUntil((r) {
                                      return r.settings.name == "/";
                                    });
                                  } else {
                                    Navigator.of(context).popAndPushNamed(
                                        "/verify",
                                        arguments: snapshot.data);
                                  }
                                  return OutlineButton(
                                    onPressed: () {
                                      login(context,_fastLogin);
                                    },
                                    child: Text("登录"),
                                  );
                                } else if (!snapshot.hasData) {
                                  return OutlineButton(
                                    onPressed: () {
                                      login(context,_fastLogin);
                                    },
                                    child: Text("登录"),
                                  );
                                } else if (snapshot.hasData &&
                                    snapshot.data.loading()) {
                                  return FlatButton(
                                    onPressed: () {},
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget buildSmsButton(BuildContext context,bool fastLogin) {
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
              sendSms(context,fastLogin);
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

  void sendSms(BuildContext context,bool fastLogin) {
    if (!_nameReady) {
      Fluttertoast.showToast(msg: "请填写${fastLogin ? "电话" : "用户名"}");
      return;
    }
    BlocProviders.of<LoginBloc>(context).sendSms(
      controllerMobile.text,
    );
  }

  void login(BuildContext context,bool fastLogin) async {
    LoginBloc loginBloc = BlocProviders.of<LoginBloc>(context);
    var applicationBloc = BlocProviders.of<ApplicationBloc>(context);
    if (!loginBloc.serviceAgree) {
      Fluttertoast.showToast(msg: "请勾选协议");
      return;
    }
    if (!_nameReady) {
      Fluttertoast.showToast(msg: "请填写${loginBloc.typeFast ? "电话" : "用户名"}");
      return;
    }
    if (!_passReady) {
      Fluttertoast.showToast(msg: "请输入${loginBloc.typeFast ? "验证码" : "密码"}");
      return;
    }
    loginBloc.typeFast
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
