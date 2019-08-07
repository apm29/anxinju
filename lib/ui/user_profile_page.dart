import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../utils.dart';

class UserProfilePage extends StatelessWidget {
  static Future go(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return UserProfilePage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (
        BuildContext context,
        UserModel userModel,
        Widget child,
      ) {
        return Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: Theme.of(context).appBarTheme.copyWith(
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                color: Colors.blue,
                textTheme: TextTheme(
                    title: TextStyle(color: Colors.white, fontSize: 18))),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  AppBar(
                    actions: <Widget>[
//                      FlatButton.icon(
//                        icon: Icon(
//                          Icons.edit,
//                          size: 12,
//                          color: Colors.white,
//                        ),
//                        onPressed: () {},
//                        label: Text(
//                          "编辑",
//                          style: TextStyle(
//                            color: Colors.white,
//                          ),
//                        ),
//                      )
                    ],
                    title: Text("我的资料"),
                  ),
                  DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    child: Container(
                      color: Colors.blue,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          buildAvatar(context, userModel.userAvatar,
                              circleBorder: true,
                              showEditBanner: true, onPressed: () {
                            _doEditAvatar(context, userModel);
                          }),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(
                                width: ScreenUtil().setHeight(12),
                              ),
                              Consumer<DistrictModel>(
                                builder: (BuildContext context,
                                    DistrictModel districtModel, Widget child) {
                                  return Text(
                                    "${districtModel.getCurrentDistrictName()}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                          color: Colors.white,
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 12,
                  ),
                  ProfileTile(
                    title: "昵称",
                    desc: userModel.userNickname ?? "未设置",
                    onPressed: () {
                      showEditDialog(userModel, context, "nickName",
                          title: "昵称",
                          desc: "填写新的昵称",
                          originText: userModel.userNickname);
                    },
                  ),
                  ProfileTile(
                    title: "性别",
                    desc: userModel.gender ?? "未设置",
                    onPressed: () {
                      showPickerDialog(
                        userModel,
                        context,
                        "sex",
                        values: ["男", "女", "保密"],
                        title: "性别",
                        originText: userModel.gender,
                        desc: "选择性别",
                      );
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 12,
                  ),
                  ProfileTile(
                    title: "姓名",
                    desc: userModel.myName ?? "未设置",
                    onPressed: () {
                      showToast("姓名不可修改");
//                      showEditDialog(response, userModel, context, "myName",
//                          title: "真实姓名",
//                          desc: "填写新的姓名",
//                          originText:
//                          userModel.myName ?? response.data?.myName);
                    },
                  ),
                  ProfileTile(
                    title: "手机",
                    desc: getMaskedPhone(userModel),
                    onPressed: () {
                      showToast("手机号码不可修改");
                    },
                  ),
                  ProfileTile(
                    title: "身份证",
                    desc: getMaskedIdCard(userModel),
                    onPressed: () {
                      showToast("身份证不可修改");
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String getMaskedIdCard(UserModel userModel) {
    var raw = userModel.idCard;
    if (raw != null && raw.length > 12) {
      raw = raw.replaceRange(6, 12, "*" * 6);
    }
    return raw ?? "未设置";
  }

  String getMaskedPhone(UserModel userModel) {
    var raw = userModel.mobile;
    if (raw != null && raw.length > 7) {
      raw = raw.replaceRange(3, 7, "*" * 4);
    }
    return raw ?? "未设置";
  }

  void _doEditAvatar(BuildContext context, UserModel model) {
    showImageSourceDialog(context).then((file) {
      Api.uploadPic(file.path).then((resp) {
        if (resp.success) {
          model.changeUserDetailByKey(resp.data.orginPicPath, "avatar");
        } else {
          showToast("图片上传失败");
        }
      });
    });
  }

  Future showEditDialog(
    UserModel model,
    BuildContext context,
    String dataKey, {
    String originText,
    String title,
    String desc,
  }) {
    final TextEditingController _controller =
        TextEditingController(text: originText);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "$title",
              style: Theme.of(context).textTheme.title.copyWith(fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _controller,
                  maxLength: 20,
                  maxLengthEnforced: true,
                ),
                Text(
                  '$desc',
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  if (_controller.text.isEmpty) {
                    showToast("不可为空");
                    return;
                  }
                  model.changeUserDetailByKey(_controller.text, dataKey);
                  Navigator.of(context).pop();
                },
                child: Text("修改"),
              )
            ],
          );
        });
  }

  Future showPickerDialog(
    UserModel model,
    BuildContext context,
    String dataKey, {
    String title,
    String desc,
    String originText,
    @required List<String> values,
  }) {
    var value = values.contains(originText) ? originText : values[0];
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("$title"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButton<String>(
                  value: value,
                  items: values
                      .map(
                        (s) => DropdownMenuItem<String>(
                          child: Text(s),
                          value: s,
                        ),
                      )
                      .toList(),
                  isExpanded: true,
                  onChanged: (String value) {
                    model.changeUserDetailByKey(value, dataKey);
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  '$desc',
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
          );
        });
  }
}

class ProfileTile extends StatelessWidget {
  final String title;
  final String desc;
  final VoidCallback onPressed;

  const ProfileTile({Key key, this.title, this.desc, this.onPressed})
      : assert(title != null && desc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      child: InkWell(
        onTap: () {
          onPressed?.call();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                  minWidth: ScreenUtil().setWidth(200),
                ),
                child: Text(title),
              ),
              Text(
                desc,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
