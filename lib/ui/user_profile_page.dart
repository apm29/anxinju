import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../utils.dart';

class UserProfileModel extends ChangeNotifier {
  String nickName;
  String gender;

  String myName;

  String mobile;
  String idCard;
  String avatar;

  void getNewData(BuildContext context) {
    Api.getUserDetail().then((resp) {
      if (resp.success) {
        nickName = resp.data.nickName;
        gender = resp.data.sex;
        myName = resp.data.myName;
        mobile = resp.data.phone;
        idCard = resp.data.idCard;
        avatar = resp.data.avatar;

        UserModel.of(context).updateUserDetail(resp.data);

        notifyListeners();
      }
      showToast("${resp.text}");
    });
  }
}

class UserProfilePage extends StatelessWidget {
  static Future go(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            builder: (BuildContext context) {
              return UserProfileModel();
            },
          ),
          FutureProvider<BaseResponse<UserDetail>>(
            builder: (context) {
              return Api.getUserDetail();
            },
            initialData: BaseResponse.error(),
            catchError: (context, error) {
              return BaseResponse.error(message: error.toString());
            },
            updateShouldNotify: (old, newValue) {
              return old.data != newValue.data;
            },
          )
        ],
        child: UserProfilePage(),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProfileModel, BaseResponse<UserDetail>>(
      builder: (
        BuildContext context,
        UserProfileModel profileModel,
        BaseResponse<UserDetail> response,
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
                          buildAvatar(context,
                              profileModel.avatar ?? response.data?.avatar,
                              circleBorder: true,
                              showEditBanner: true, onPressed: () {
                            _doEditAvatar(context, response, profileModel);
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
                    desc: profileModel.nickName ??
                        response.data?.nickName ??
                        "未设置",
                    onPressed: () {
                      showEditDialog(
                          response, profileModel, context, "nickName",
                          title: "昵称",
                          desc: "填写新的昵称",
                          originText:
                              profileModel.nickName ?? response.data?.nickName);
                    },
                  ),
                  ProfileTile(
                    title: "性别",
                    desc: profileModel.gender ?? response.data?.sex ?? "未设置",
                    onPressed: () {
                      showPickerDialog(
                        response,
                        profileModel,
                        context,
                        "sex",
                        values: ["男", "女", "保密"],
                        title: "性别",
                        originText: profileModel.gender ?? response.data?.sex,
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
                    desc: profileModel.myName ?? response.data?.myName ?? "未设置",
                    onPressed: () {
                      showToast("姓名不可修改");
//                      showEditDialog(response, profileModel, context, "myName",
//                          title: "真实姓名",
//                          desc: "填写新的姓名",
//                          originText:
//                          profileModel.myName ?? response.data?.myName);
                    },
                  ),
                  ProfileTile(
                    title: "手机",
                    desc: getMaskedPhone(profileModel, response),
                    onPressed: () {
                      showToast("手机号码不可修改");
                    },
                  ),
                  ProfileTile(
                    title: "身份证",
                    desc: getMaskedIdCard(profileModel, response),
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

  String getMaskedIdCard(
      UserProfileModel profileModel, BaseResponse<UserDetail> response) {
    var raw = profileModel.idCard ?? response.data?.idCard;
    if (raw != null && raw.length > 12) {
      raw = raw.replaceRange(6, 12, "*" * 6);
    }
    return raw ?? "未设置";
  }

  String getMaskedPhone(
      UserProfileModel profileModel, BaseResponse<UserDetail> response) {
    var raw = profileModel.mobile ?? response.data?.phone;
    if (raw != null && raw.length > 7) {
      raw = raw.replaceRange(3, 7, "*" * 4);
    }
    return raw ?? "未设置";
  }

  void _doEditAvatar(BuildContext context, BaseResponse<UserDetail> response,
      UserProfileModel profileModel) {
    showImageSourceDialog(context).then((file) {
      Api.uploadPic(file.path).then((resp) {
        if (resp.success) {
          Api.saveUserDetailByMap(
            <String, String>{
              "userId": response.data.userId,
              "avatar": resp.data.orginPicPath,
            },
          ).then((respSave) {
            if (respSave.success) {
              profileModel.getNewData(context);
            } else {
              showToast("保存图片失败");
            }
          });
        } else {
          showToast("图片上传失败");
        }
      });
    });
  }

  Future showEditDialog(
    BaseResponse<UserDetail> response,
    UserProfileModel model,
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
            title: Text("$title"),
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
                  var dataMap = {
                    "userId": response.data?.userId,
                    dataKey: _controller.text,
                  };
                  Api.saveUserDetailByMap(dataMap).then((resp) {
                    if (resp.success) {
                      Navigator.of(context).pop(resp);
                    }
                    showToast(resp.text);
                  });
                },
                child: Text("修改"),
              )
            ],
          );
        }).then((v) {
      if (v != null) {
        model.getNewData(context);
      }
    });
  }

  Future showPickerDialog(
    BaseResponse<UserDetail> response,
    UserProfileModel model,
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
                      var dataMap = {
                        "userId": response.data?.userId,
                        dataKey: value,
                      };
                      Api.saveUserDetailByMap(dataMap).then((resp) {
                        if (resp.success) {
                          Navigator.of(context).pop(resp);
                        }
                        showToast(resp.text);
                      });
                    }),
                Text(
                  '$desc',
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
          );
        }).then((v) {
      if (v != null) {
        model.getNewData(context);
      }
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
