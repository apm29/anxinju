import 'package:ease_life/index.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
                      decoration: InputDecoration(hintText: "输入电话号码"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(6),
                    child: TextField(
                      key: ValueKey("pass"),
                      obscureText: true,
                      decoration: InputDecoration(hintText: "输入验证码"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(6),
                    child: TextField(
                      key: ValueKey("name"),
                      decoration: InputDecoration(hintText: "输入密码"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(6),
                    child: TextField(
                      key: ValueKey("pass"),
                      obscureText: true,
                      decoration: InputDecoration(hintText: "确认密码"),
                    ),
                  ),
                ],
              ),
            ),
            OutlineButton(
              onPressed: () {},
              child: Text("注册"),
            ),
          ],
        ),
      ),
    );
  }
}
