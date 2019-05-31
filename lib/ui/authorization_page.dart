import 'package:ease_life/index.dart';

class AuthorizationPage extends StatefulWidget {

  static String routeName = "/verify";

  @override
  _AuthorizationPageState createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("认证"),
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(100),
                vertical: ScreenUtil().setHeight(80)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        child: Text("姓名:"),
                        width: ScreenUtil().setWidth(200),
                      ),
                      Expanded(
                          child: TextField(
                        decoration: InputDecoration.collapsed(
                          hintText: "",
                          border: OutlineInputBorder(),
                        ),
                      )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        child: Text("身份证号:"),
                        width: ScreenUtil().setWidth(200),
                      ),
                      Expanded(
                          child: TextField(
                        decoration: InputDecoration.collapsed(
                          hintText: "",
                          border: OutlineInputBorder(),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        child: Text("${Strings.districtClass}:"),
                        width: ScreenUtil().setWidth(200),
                      ),
                      Expanded(
                        child:
                            TextPickerWidget(items: ["天马花园", "菲达壹品", "景城嘉苑"]),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  SizedBox(
                    child: Text("位置:(请在${Strings.districtClass}${Strings.roomClass_2}获取位置进行验证)"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: TextField(
                        decoration: InputDecoration.collapsed(
                          hintText: "",
                          border: OutlineInputBorder(),
                        ),
                      )),
                    ],
                  ),
                  OutlineButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/map");
                    },
                    child: Text("获取位置"),
                  )
                ],
              ),
            ),
          ),
          OutlineButton(
            onPressed: () {},
            color: Colors.greenAccent,
            child: Text("提交认证"),
          )
        ],
      ),
    );
  }
}
