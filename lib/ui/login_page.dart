import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/bloc/user_bloc.dart';
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
  bool _serviceProtocolChecked = true;
  bool _nameReady = false;
  bool _passReady = false;
  bool _fastLogin = false;

  final Subject<int> smsController = BehaviorSubject();

  @override
  Widget build(BuildContext context) {
    return buildLogin();
  }

  @override
  void dispose() {
    super.dispose();
    smsController.close();
  }

  Widget buildLogin() {
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
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueGrey)),
                child: TextField(
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
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueGrey)),
                child: TextField(
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
                    value: _serviceProtocolChecked,
                    onChanged: (value) {
                      setState(() {
                        _serviceProtocolChecked = value;
                      });
                    },
                    activeColor: Colors.blueGrey,
                  ),
                  FlatButton(
                    child: Text("我已阅读并同意安心居服务平台服务相关条例"),
                    onPressed: () {
                      setState(() {
                        _serviceProtocolChecked = !_serviceProtocolChecked;
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
                    _fastLogin ? buildSmsButton() : Container(),
                    StreamBuilder<BlocData<UserInfoModel>>(
                        stream: BlocProvider.of(context).loginStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && !snapshot.data.loading()) {
                            if (snapshot.data.error()) {
                              Fluttertoast.showToast(msg: snapshot.data.response.text);
                            } else if (snapshot.data.success()) {
                              Fluttertoast.showToast(msg: "登录成功");
                              if (snapshot.data.response.data.userInfo.isCertification >
                                  0) {
                                Navigator.of(context).popUntil((r) {
                                  return r.settings.name == "/";
                                });
                              } else {
                                Navigator.of(context).popAndPushNamed("/verify",
                                    arguments: snapshot.data.response.data);
                              }
                            }
                            return OutlineButton(
                              onPressed: login,
                              child: Text("登录"),
                            );
                          } else if (!snapshot.hasData) {
                            return OutlineButton(
                              onPressed: login,
                              child: Text("登录"),
                            );
                          } else {
                            return OutlineButton(
                              onPressed: login,
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
  }

  Widget buildSmsButton() {
    return StreamBuilder<int>(
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data <= 0) {
          return FlatButton(
            child: Text(
              "发送短信",
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: sendSms,
          );
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
      stream: smsController.stream,
    );
  }

  void sendSms() async {
    if (!_nameReady) {
      Fluttertoast.showToast(msg: "请填写${_fastLogin ? "电话" : "用户名"}");
      return;
    }
    BlocProvider.of(context).sendSms(
      controllerMobile.text,
    );

    BlocProvider.of(context).smsStream.listen((BlocData data) {
      if (data.success()) {
        Fluttertoast.showToast(msg: "发送成功");
        Observable.periodic(Duration(seconds: 1), (i) => (30 - i))
            .take(31)
            .listen((time) {
          print(time);
          if (!smsController.isClosed) smsController.add(time);
        });
      }
    }, onError: (err) {
      Fluttertoast.showToast(msg: err);
    });
  }

  void login() async {
    if (!_serviceProtocolChecked) {
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
    _fastLogin
        ? BlocProvider.of(context).fastLogin(
            controllerMobile.text,
            controllerPassword.text,
          )
        : BlocProvider.of(context).login(
            controllerMobile.text,
            controllerPassword.text,
          );
//    BlocProvider.of(context).loginStream.listen((userInfo) {
//      Fluttertoast.showToast(msg: "登陆成功");
//      if (userInfo.userInfo.isCertification > 0) {
//        Navigator.of(context).popUntil((r) {
//          return r.settings.name == "/";
//        });
//      } else {
//        Navigator.of(context).popAndPushNamed("/verify", arguments: userInfo);
//      }
//    }, onError: (err) {
//      Fluttertoast.showToast(msg: err);
//    });
  }
}
