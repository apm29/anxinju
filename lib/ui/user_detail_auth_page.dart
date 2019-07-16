import 'package:ease_life/index.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:rxdart/rxdart.dart';

class UserDetailAuthPage extends StatefulWidget {
  static String routeName = "/preVerify";

  @override
  _UserDetailAuthPageState createState() => _UserDetailAuthPageState();
}

class _UserDetailAuthPageState extends State<UserDetailAuthPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _avatarController = TextEditingController();
  TextEditingController _idCardController = TextEditingController();
  TextEditingController _nickNameController = TextEditingController();
  PublishSubject<String> _avatarUploadController = PublishSubject();

  Observable<String> get _avatarStream => _avatarUploadController.stream;
  GlobalKey<LoadingStateWidgetState> submitButtonKey =
      GlobalKey(debugLabel: "sumbitUserDetail");
  GlobalKey<LoadingStateWidgetState> uploadImageKey =
      GlobalKey(debugLabel: "uploadImageAvatar");

  @override
  void dispose() {
    super.dispose();
    _avatarUploadController.close();
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
          bool isReAuth = (userModel.userDetail?.idCard ?? "").isNotEmpty;
          _idCardController.text = userModel.userDetail?.idCard;
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
                      maxLength: 18,
                      enabled: !isReAuth,
                      decoration: InputDecoration(
                          hintText: "请输入身份证",
                          labelText: "身份证",
                          border: OutlineInputBorder()),
                      controller: _idCardController,
                    ),
                  ),
                ),
//                SliverT
                SliverToBoxAdapter(
                  child: LoadingStateWidget(
                    key: submitButtonKey,
                    child: RaisedButton(
                      onPressed: () async {
                        Navigator.of(context).pushReplacementNamed(
                            FaceIdPage.routeName,
                            arguments: {
                              "idCard": _idCardController.text,
                              "isAgain": isReAuth
                            });
                        //}
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
