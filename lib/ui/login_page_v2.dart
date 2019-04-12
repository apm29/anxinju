import 'package:ease_life/ui/widget/ticker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPageV2 extends StatefulWidget {
  @override
  _LoginPageV2State createState() => _LoginPageV2State();
}

class _LoginPageV2State extends State<LoginPageV2> {
  TextEditingController nameController;
  TextEditingController passController;
  bool protocolChecked = true;
  bool nameReady = false;
  bool passReady = false;
  GlobalKey<TickerWidgetState> ticker = GlobalKey();
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    passController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20,),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "输入用户名"
              ),
            ),
            TextField(
              controller: passController,
              decoration: InputDecoration(
                  hintText: "输入密码"
              ),
            ),
            Row(
              children: <Widget>[
                Checkbox(value: protocolChecked , onChanged: (v){
                  setState(() {
                    protocolChecked = v;
                  });
                }),
                Text("同意App服务协议"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TickerWidget(
                    key: ticker,
                    onPressed: (){
                      ticker.currentState.startTick();
                    },
                ),
                RaisedButton(
                  onPressed: () {},
                  child: Text("Login"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
