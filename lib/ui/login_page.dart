import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:ease_life/remote/dio_net.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  @override
  Widget build(BuildContext context) {
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
                    _fastLogin?FlatButton(
                      child: Text(
                        "发送短信",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: sendSms,
                    ):Container(),
                    OutlineButton(
                      onPressed: login,
                      child: Text("登录"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendSms() async {
    if (!_nameReady) {
      Fluttertoast.showToast(msg: "请填写${_fastLogin ? "电话" : "用户名"}");
      return;
    }
    var response =
        await DioApplication.sendSms(controllerMobile.text, onError: (e) {
      Fluttertoast.showToast(msg: "请求失败:${e.message}");
    });
    if (response.data != null && response.data["status"] == "1") {
      Fluttertoast.showToast(msg: "发送成功");
    } else {
      Fluttertoast.showToast(msg: "请求失败:${response.data["data"]}");
    }
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
    var onError = (e) {
      Fluttertoast.showToast(msg: "请求失败:${e.message}");
    };
    var response = _fastLogin
        ? await DioApplication.fastLogin(
            controllerMobile.text, controllerPassword.text, onError: onError)
        : await DioApplication.login(
            controllerMobile.text, controllerPassword.text,
            onError: onError);
    if (response.data["status"] == "1") {
      var spUtil = await SpUtil.getInstance();
      spUtil.putString(PreferenceKeys.keyAuthorization, response.data["token"]);
      Fluttertoast.showToast(msg: "登录成功");
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(msg: "请求失败:${response.data["data"]}");
    }
  }
}
