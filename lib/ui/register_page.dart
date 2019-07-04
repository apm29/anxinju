import 'package:ease_life/index.dart';

class RegisterPage extends StatefulWidget {

  static String routeName="/register";

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

            Card(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(6),
                      padding: EdgeInsets.all(6),
                      child: TextField(
                        key: ValueKey("name"),
                        controller: _mobileController,
                        maxLengthEnforced: true,
                        maxLength: 11,
                        decoration: InputDecoration(
                          hintText: "输入电话号码",
                          labelText: "电话号码",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(6),
                      padding: EdgeInsets.all(6),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              key: ValueKey("sms"),
                              controller: _smsCodeController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "输入验证码",
                                labelText: "验证码",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                                minWidth: ScreenUtil().setWidth(300)
                            ),
                            child: TickerWidget(
                                key: ticker,
                                textInitial: "发送验证码",
                                onPressed: () {
                                  sendSms();
                                }),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(6),
                      padding: EdgeInsets.all(6),
                      child: TextField(
                        key: ValueKey("userName"),
                        controller: _userNameController,
                        decoration: InputDecoration(
                          hintText: "输入用户名",
                          labelText: "用户名",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(6),
                      padding: EdgeInsets.all(6),
                      child: TextField(
                        key: ValueKey("pass"),
                        obscureText: true,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: "输入密码",
                          labelText: "输入密码",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(6),
                      padding: EdgeInsets.all(6),
                      child: TextField(
                        key: ValueKey("paconfirm"),
                        obscureText: true,
                        controller: _confirmController,
                        decoration: InputDecoration(
                          hintText: "确认密码",
                          labelText: "确认密码",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(12),
              child: LoadingStateWidget(
                key: register,
                child: RaisedButton(
                  onPressed: () {
                    doRegister();
                  },
                  color: Colors.blue,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:18.0),
                    child: Text("注册",style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                ),
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
    BaseResponse<Object> baseResp = await Api.sendSms(_mobileController.text,0);
    Fluttertoast.showToast(msg: baseResp.text);
    ticker.currentState?.stopLoading();
    if (baseResp.success) {
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
        _mobileController.text,
        _smsCodeController.text,
        _passwordController.text,
        _userNameController.text);
    Fluttertoast.showToast(msg: baseResp.text.trim());
    register.currentState?.stopLoading();
    if (baseResp.success) {
      //注册成功
      Navigator.of(context).pop();
    }
  }
}
