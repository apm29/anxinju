import 'package:ease_life/index.dart';

import 'widget/loading_state_widget.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  GlobalKey<TickerWidgetState> ticker = GlobalKey();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _smsCodeController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  GlobalKey<LoadingStateWidgetState> register = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("注册"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 100,
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(6),
                    child: TextField(
                      key: ValueKey("name"),
                      controller: _mobileController,
                      decoration: InputDecoration(hintText: "输入电话号码"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(6),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            key: ValueKey("sms"),
                            controller: _smsCodeController,
                            obscureText: true,
                            decoration: InputDecoration(hintText: "输入验证码"),
                          ),
                        ),
                        TickerWidget(
                            key: ticker,
                            onPressed: () {
                              sendSms();
                            })
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(6),
                    child: TextField(
                      key: ValueKey("userName"),
                      controller: _userNameController,
                      decoration: InputDecoration(hintText: "输入用户名"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(6),
                    child: TextField(
                      key: ValueKey("pass"),
                      controller: _passwordController,
                      decoration: InputDecoration(hintText: "输入密码"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(6),
                    child: TextField(
                      key: ValueKey("paconfirm"),
                      obscureText: true,
                      controller: _confirmController,
                      decoration: InputDecoration(hintText: "确认密码"),
                    ),
                  ),
                ],
              ),
            ),
            LoadingStateWidget(
              key:register,
              child: OutlineButton(
                onPressed: () {
                  doRegister();
                },
                child: Text("注册"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendSms() async {
    if (_mobileController.text.isEmpty) {
      Fluttertoast.showToast(msg: "请填写电话");
      return;
    }
    ticker.currentState?.startLoading();
    BaseResponse<Object> baseResp = await Api.sendSms(_mobileController.text);
    Fluttertoast.showToast(msg: baseResp.text);
    ticker.currentState?.stopLoading();
    if (baseResp.success()) {
      //发送短信成功
      ticker.currentState.startTick();
    }
  }

  void doRegister() async {
    if (_mobileController.text.isEmpty) {
      Fluttertoast.showToast(msg: "请填写电话");
      return;
    }
    if (_smsCodeController.text.isEmpty) {
      Fluttertoast.showToast(msg: "请填写验证码");
      return;
    }

    if (_userNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "请填写用户名");
      return;
    }

    if (_passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "请填写密码");
      return;
    }
    if (_confirmController.text.isEmpty) {
      Fluttertoast.showToast(msg: "请确认密码");
      return;
    }

    if (_confirmController.text != _passwordController.text) {
      Fluttertoast.showToast(msg: "两次密码不一致");
      return;
    }

    register.currentState?.startLoading();
    BaseResponse<Object> baseResp = await Api.register(
      _mobileController.text, _smsCodeController.text, _passwordController.text,
        _userNameController.text);
    Fluttertoast.showToast(msg: baseResp.text.trim());
    register.currentState?.stopLoading();
    if (baseResp.success()) {
      //注册成功
      Navigator.of(context).pop();
    }
  }
}
