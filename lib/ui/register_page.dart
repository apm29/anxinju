import 'package:ease_life/index.dart';
import 'package:ease_life/ui/widget/gradient_button.dart';

class RegisterPage extends StatefulWidget {
  static String routeName = "/register";

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
  static const double kInputHeight = 158;
  static const double kMarginHorizontal = 18;
  static const double kInputContentPadding = 8;

  @override
  Widget build(BuildContext context) {
    TextStyle kInputLabelTheme = Theme.of(context)
        .textTheme
        .caption
        .copyWith(fontSize: 15, color: Colors.blueGrey[800]);

    TextStyle kInputHintTheme =
        Theme.of(context).textTheme.caption.copyWith(fontSize: 15);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Card(
              margin: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(100),
                  vertical: MediaQuery.of(context).padding.top + 32),
              elevation: 12,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    height: 16,
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
                          "新用户注册",
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
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: ScreenUtil().setHeight(kInputHeight) + 32),
                    margin: EdgeInsets.only(
                        left: kMarginHorizontal,
                        top: 32,
                        right: kMarginHorizontal),
                    child: TextField(
                      key: ValueKey("USER_MOBILE"),
                      controller: _mobileController,
                      maxLengthEnforced: true,
                      maxLength: 11,
                      decoration: InputDecoration(
                        hintText: "输入手机号",
                        labelText: "手机号",
                        contentPadding: EdgeInsets.all(kInputContentPadding),
                        labelStyle: kInputLabelTheme,
                        hintStyle: kInputHintTheme,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Divider(
                    indent: 16,
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: ScreenUtil().setHeight(kInputHeight)),
                    margin: EdgeInsets.only(
                        left: kMarginHorizontal,
                        top: 12,
                        right: kMarginHorizontal),
                    child: TextField(
                      key: ValueKey("USER_NAME"),
                      controller: _userNameController,
                      decoration: InputDecoration(
                        hintText: "输入用户名",
                        labelText: "用户名",
                        contentPadding: EdgeInsets.all(kInputContentPadding),
                        labelStyle: kInputLabelTheme,
                        hintStyle: kInputHintTheme,
                        border: OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: InkWell(
                          onTap: () {
                            _userNameController.clear();
                          },
                          child: Icon(
                            Icons.close,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: ScreenUtil().setHeight(kInputHeight)),
                    margin: EdgeInsets.only(
                        left: kMarginHorizontal,
                        top: 12,
                        right: kMarginHorizontal),
                    child: TextField(
                      key: ValueKey("pass"),
                      obscureText: true,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: "输入密码",
                        labelText: "输入密码",
                        contentPadding: EdgeInsets.all(kInputContentPadding),
                        labelStyle: kInputLabelTheme,
                        hintStyle: kInputHintTheme,
                        border: OutlineInputBorder(),
                        suffixIcon: InkWell(
                          onTap: () {
                            _passwordController.clear();
                          },
                          child: Icon(
                            Icons.close,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: ScreenUtil().setHeight(kInputHeight)),
                    margin: EdgeInsets.only(
                        left: kMarginHorizontal,
                        top: 12,
                        right: kMarginHorizontal),
                    child: TextField(
                      key: ValueKey("PASS_CONFIRM"),
                      obscureText: true,
                      controller: _confirmController,
                      decoration: InputDecoration(
                        hintText: "重复密码",
                        labelText: "重复密码",
                        contentPadding: EdgeInsets.all(kInputContentPadding),
                        labelStyle: kInputLabelTheme,
                        hintStyle: kInputHintTheme,
                        border: OutlineInputBorder(),
                        suffixIcon: InkWell(
                          onTap: () {
                            _confirmController.clear();
                          },
                          child: Icon(
                            Icons.close,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    indent: 16,
                    height: 32,
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: ScreenUtil().setHeight(kInputHeight)),
                    margin: EdgeInsets.only(
                        left: kMarginHorizontal,
                        top: 12,
                        right: kMarginHorizontal,
                        bottom: 32),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            key: ValueKey("sms"),
                            controller: _smsCodeController,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: "输入验证码",
                              labelText: "验证码",
                              contentPadding:
                                  EdgeInsets.all(kInputContentPadding),
                              labelStyle: kInputLabelTheme,
                              hintStyle: kInputHintTheme,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                              minWidth: ScreenUtil().setWidth(300)),
                          child: TickerWidget(
                              key: ticker,
                              textInitial: "发送验证码",
                              onPressed: () {
                                sendSms();
                              }),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GradientButton(
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: kInputContentPadding),
                            child: Text(
                              "注册",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          unconstrained: false,
                          borderRadius: 0,
                          onPressed: () async {
                            await doRegister();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              "注册即视为同意${Strings.appName}服务平台用户协议",
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.start,
            )
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
    BaseResponse<Object> baseResp =
        await Api.sendSms(_mobileController.text, 0);
    Fluttertoast.showToast(msg: baseResp.text);
    ticker.currentState?.stopLoading();
    if (baseResp.success) {
      //发送短信成功
      ticker.currentState.startTick();
    }
  }

  Future doRegister() async {
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
    return;
  }
}
