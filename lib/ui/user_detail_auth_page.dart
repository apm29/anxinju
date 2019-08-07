import 'package:ease_life/index.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:oktoast/oktoast.dart';

class UserDetailAuthPage extends StatefulWidget {
  static String routeName = "/preVerify";

  @override
  _UserDetailAuthPageState createState() => _UserDetailAuthPageState();
}

class _UserDetailAuthPageState extends State<UserDetailAuthPage> {
  TextEditingController _idCardController = TextEditingController();
  GlobalKey _keyEdit = GlobalKey();
  GlobalKey<LoadingStateWidgetState> submitButtonKey =
      GlobalKey(debugLabel: "sumbitUserDetail");

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("用户信息"),
      ),
      body: Consumer<UserModel>(
        builder: (BuildContext context, UserModel userModel, Widget child) {
          bool isReAuth = (userModel.idCard ?? "").isNotEmpty;
          if (isReAuth) {
            _idCardController.text = userModel.idCard;
          }
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 12,
                  ),
                ),
                SliverToBoxAdapter(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(isReAuth
                      ? "您已经经过认证,重新认证不可修改身份证信息"
                      : "身份证一旦进入认证环节将不可修改,请谨慎填写"),
                )),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      key: _keyEdit,
                      maxLength: 18,
                      enabled: !isReAuth,
                      decoration: InputDecoration(
                        hintText: "请输入身份证",
                        labelText: "身份证",
                        border: OutlineInputBorder(),
                      ),
                      controller: _idCardController,
                      autocorrect: false,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: LoadingStateWidget(
                    key: submitButtonKey,
                    child: RaisedButton(
                      onPressed: () async {
                        if (_idCardController.text?.isEmpty ?? true) {
                          showToast("身份证不可为空");
                          return;
                        }
                        Navigator.of(context).pushReplacementNamed(
                            FaceIdPage.routeName,
                            arguments: {
                              "idCard": _idCardController.text,
                              "isAgain": isReAuth
                            });
                        SystemSound.play(SystemSoundType.click);
                      },
                      color: Colors.blue,
                      child: Text(
                        "下一步",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
