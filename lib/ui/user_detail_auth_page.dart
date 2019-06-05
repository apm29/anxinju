import 'package:ease_life/index.dart';
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

  PublishSubject<BaseResponse<UserDetail>> _controllerData = PublishSubject();
  Stream<BaseResponse<UserDetail>> initData;

  @override
  void initState() {
    super.initState();
    initData = _controllerData.stream;
    Api.getUserDetail().then((b) {
      _controllerData.add(b);
      if (b.success()) {
        UserDetail userDetail = b.data;
        _nameController.text = userDetail.myName;
        _genderController.text = userDetail.sex;
        _avatarController.text = userDetail.avatar;
        _nickNameController.text = userDetail.nickName;
        _idCardController.text = userDetail.idCard;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("用户信息"),
      ),
      body: StreamBuilder<BaseResponse<UserDetail>>(
        stream: initData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.data.success()) {
            return Center(
              child: Text(snapshot.data.text),
            );
          }
          bool isReAuth = (snapshot.data.data?.idCard??"").isNotEmpty;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 12,
                  ),
                ),
//                SliverToBoxAdapter(
//                  child: Padding(
//                    padding: const EdgeInsets.all(8.0),
//                    child: TextField(
//                      decoration: InputDecoration(
//                          hintText: "请输入姓名",
//                          labelText: "姓名",
//                          border: OutlineInputBorder()),
//                      controller: _nameController,
//                    ),
//                  ),
//                ),
//                SliverToBoxAdapter(
//                  child: Padding(
//                    padding: const EdgeInsets.all(8.0),
//                    child: TextField(
//                      decoration: InputDecoration(
//                          hintText: "请输入性别",
//                          labelText: "性别",
//                          border: OutlineInputBorder()),
//                      controller: _genderController,
//                    ),
//                  ),
//                ),
//
//                SliverToBoxAdapter(
//                  child: Padding(
//                    padding: const EdgeInsets.all(8.0),
//                    child: TextField(
//                      decoration: InputDecoration(
//                          hintText: "请输入昵称",
//                          labelText: "昵称",
//                          border: OutlineInputBorder()),
//                      controller: _nickNameController,
//                    ),
//                  ),
//                ),
                SliverToBoxAdapter(
                  child: isReAuth?Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("您已经经过认证,重新认证不可修改身份证信息"),
                  ):Container(),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      maxLength: 18,
                      enabled: (snapshot.data?.data?.idCard ?? "").isEmpty,
                      decoration: InputDecoration(
                          hintText: "请输入身份证",
                          labelText: "身份证",
                          border: OutlineInputBorder()),
                      controller: _idCardController,
                    ),
                  ),
                ),
//                SliverToBoxAdapter(
//                  child: Container(
//                    padding: const EdgeInsets.all(8.0),
//                    decoration: BoxDecoration(shape: BoxShape.rectangle),
//                    child: Row(
//                      children: <Widget>[
//                        SizedBox(
//                          width: ScreenUtil().setWidth(200),
//                          height: ScreenUtil().setWidth(200),
//                          child: StreamBuilder<String>(
//                              stream: _avatarStream,
//                              builder: (context, snapshot) {
//                                return CircleAvatar(
//                                  backgroundImage:NetworkImage(snapshot.data ?? _avatarController.text),
//                                );
//                              }),
//                        ),
//                        Expanded(
//                          child: LoadingStateWidget(
//                            key: uploadImageKey,
//                            child: FlatButton(
//                                child: Align(
//                                    alignment: Alignment.centerRight,
//                                    child: ListTile(
//                                      contentPadding: EdgeInsets.only(
//                                        top: 8,
//                                        bottom: 8,
//                                      ),
//                                      title: Text("选择头像"),
//                                      trailing:
//                                          Icon(Icons.arrow_drop_down_circle),
//                                    )),
//                                onPressed: () async {
//                                  var directory = await getTemporaryDirectory();
//                                  var file = File(directory.path +
//                                      "/compressed${DateTime.now().millisecondsSinceEpoch}.jpg");
//                                  showImageSourceDialog(file, context, (v) {},
//                                      (futureFile, localFile) {
//                                    futureFile.then((f) {
//                                      if (f == null) {
//                                        return null;
//                                      }
//                                      uploadImageKey.currentState
//                                          .startLoading();
//                                      return rotateWithExifAndCompress(f)
//                                          .then((compressed) {
//                                        return Api.uploadPic(compressed.path);
//                                      });
//                                    }).then((baseResp) {
//                                      if (baseResp == null) {
//                                        return null;
//                                      }
//                                      if (baseResp.success()) {
//                                        _avatarUploadController
//                                            .add(baseResp.data.thumbnailPath);
//                                        _avatarController.text =
//                                            baseResp.data.orginPicPath;
//                                      }
//                                      uploadImageKey.currentState.stopLoading();
//                                      Scaffold.of(context).showSnackBar(
//                                          SnackBar(
//                                              content: Text(baseResp.text)));
//                                    }).catchError((Object e, StackTrace trace) {
//                                      uploadImageKey.currentState.stopLoading();
//                                      Scaffold.of(context).showSnackBar(
//                                          SnackBar(
//                                              content: Text(e.toString())));
//                                    });
//                                  });
//                                }),
//                          ),
//                        )
//                      ],
//                    ),
//                  ),
//                ),
                SliverToBoxAdapter(
                  child: LoadingStateWidget(
                    key: submitButtonKey,
                    child: RaisedButton(
                      onPressed: () async {
                        //submitButtonKey.currentState.startLoading();
                        //var userId = snapshot.data.data.userId;
                        //var baseResponse = await Api.saveUserDetail(
                        //  userId: userId,
                        //  myName: null,
                        //  sex: null,
                        //  nickName: null,
                        //  avatar: null,
                        //  idCard: _idCardController.text,
                        //);
                        //Scaffold.of(context).showSnackBar(
                        //    SnackBar(content: Text(baseResponse.text)));
                        //submitButtonKey.currentState.stopLoading();
                        //if (baseResponse.success()) {
                          Navigator.of(context).pushReplacementNamed(
                              FaceIdPage.routeName,
                              arguments: {"idCard": _idCardController.text});
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
