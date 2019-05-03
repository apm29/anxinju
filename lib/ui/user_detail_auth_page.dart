import 'dart:io';

import 'package:ease_life/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rxdart/rxdart.dart';

import '../utls.dart';
import 'widget/loading_state_widget.dart';

class UserDetailAuthPage extends StatefulWidget {
  @override
  _UserDetailAuthPageState createState() => _UserDetailAuthPageState();
}

class _UserDetailAuthPageState extends State<UserDetailAuthPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _avatarController = TextEditingController();
  TextEditingController _idCardController = TextEditingController();
  TextEditingController _nickNameController = TextEditingController();
  PublishSubject<String> _avatarUploadController = PublishSubject();
  Observable<String> get _avatarStream  => _avatarUploadController.stream;
  GlobalKey<LoadingStateWidgetState> submitButtonKey = GlobalKey(debugLabel:"sumbitUserDetail");
  GlobalKey<LoadingStateWidgetState> uploadImageKey = GlobalKey(debugLabel:"uploadImageAvatar");
  @override
  void dispose() {
    super.dispose();
    _avatarUploadController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("用户信息"),
      ),
      body: FutureBuilder<BaseResponse<UserDetail>>(
        future: Api.getUserDetail(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data.success()) {
            UserDetail userDetail = snapshot.data.data;
            _nameController.text = userDetail.myName;
            _genderController.text = userDetail.sex;
            _phoneController.text = userDetail.phone;
            _avatarController.text = userDetail.avatar;
            _nickNameController.text = userDetail.nickName;
            _idCardController.text = userDetail.idCard;
          } else {
            return Center(
              child: Text(snapshot.data.text),
            );
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
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "请输入姓名",
                          labelText: "姓名",
                          border: OutlineInputBorder()),
                      controller: _nameController,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "请输入性别",
                          labelText: "性别",
                          border: OutlineInputBorder()),
                      controller: _genderController,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "请输入电话",
                          labelText: "电话",
                          border: OutlineInputBorder()),
                      controller: _phoneController,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "请输入昵称",
                          labelText: "昵称",
                          border: OutlineInputBorder()),
                      controller: _nickNameController,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "请输入身份证",
                          labelText: "身份证",
                          border: OutlineInputBorder()),
                      controller: _idCardController,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(shape: BoxShape.rectangle),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setWidth(200),
                          child: StreamBuilder<String>(
                            stream: _avatarStream,
                            builder: (context, snapshot) {
                              return CachedNetworkImage(
                                imageUrl: snapshot.data??_avatarController.text,
                                placeholder: (context, url) {
                                  return CircleAvatar();
                                },
                              );
                            }
                          ),
                        ),
                        Expanded(
                          child: LoadingStateWidget(
                            key: uploadImageKey,
                            child: FlatButton(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.only(
                                        top: 8,
                                        bottom: 8,
                                      ),
                                      title: Text("选择头像"),
                                      trailing:
                                          Icon(Icons.arrow_drop_down_circle),
                                    )),
                                onPressed: () async {
                                  var directory = await getTemporaryDirectory();
                                  var file = File(directory.path +
                                      "/compressed${DateTime.now().millisecondsSinceEpoch}.jpg");
                                  showImageSourceDialog(file, context, (v) {},
                                      (futureFile, localFile) {
                                        futureFile.then((f){
                                          uploadImageKey.currentState.startLoading();
                                          return Api.uploadPic(f.path);
                                        }).then((baseResp){
                                          if(baseResp.success()){
                                            _avatarUploadController.add(baseResp.data.thumbnailPath);
                                            _avatarController.text = baseResp.data.orginPicPath;
                                          }
                                          uploadImageKey.currentState.stopLoading();
                                          Scaffold.of(context).showSnackBar(SnackBar(content: Text(baseResp.text)));
                                        });
                                      });
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: LoadingStateWidget(
                    key: submitButtonKey,
                    child: RaisedButton(
                      onPressed: () async {
                        submitButtonKey.currentState.startLoading();
                        var userId = snapshot.data.data.userId;
                        var baseResponse = await Api.saveUserDetail(
                          userId: userId,
                          myName: _nameController.text,
                          sex: _genderController.text,
                          phone: _phoneController.text,
                          nickName: _nickNameController.text,
                          avatar: _avatarController.text,
                          idCard: _idCardController.text,
                        );
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text(baseResponse.text)));
                        submitButtonKey.currentState.stopLoading();
                        if (baseResponse.success()) {
                          Navigator.of(context).pushReplacementNamed("/camera",arguments: _idCardController.text);
                        }
                      },
                      color: Colors.blue,
                      child: Text("提交",style: TextStyle(
                        color: Colors.white
                      ),),
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
