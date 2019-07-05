import 'dart:convert';

import 'package:ease_life/remote/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';

import 'district_model.dart';
import 'user_role_model.dart';
import 'user_verify_status_model.dart';

class UserModel extends ChangeNotifier {
  UserInfo _userInfo;
  String _token;

  String get userId => _userInfo?.userId;

  String get userName => _userInfo?.userName;

  UserDetail _userDetail;

  UserDetail get userDetail => _userDetail;

  set userDetail(UserDetail value) {
    _userDetail = value;
    notifyListeners();
  }

  String get token => _token;

  bool get isLogin => userId != null && token != null;

  void login(UserInfo info, String token, BuildContext context) {
    _userInfo = info;
    _token = token;
    userSp.setString(KEY_USER_INFO, info.toString());
    userSp.setString(KEY_TOKEN, token);

    ///重新获取验证状态/获取小区
    if (context != null) {
      UserVerifyStatusModel.of(context).tryFetchVerifyStatus();
      DistrictModel.of(context).tryFetchCurrentDistricts();
      UserRoleModel.of(context).tryFetchUserRoleTypes();
      UserVerifyStatusModel.of(context).tryFetchVerifyStatus();
      tryFetchUserDetail();
    }
    notifyListeners();
  }

  void logout(BuildContext context) {
    UserVerifyStatusModel.of(context).logout();
    UserRoleModel.of(context).logout();
    _userInfo = null;
    _token = null;
    _userDetail = null;
    userSp.setString(KEY_USER_INFO, null);
    userSp.setString(KEY_TOKEN, null);
    DistrictModel.of(context).tryFetchCurrentDistricts();
    notifyListeners();
  }

  UserModel() {
    tryLoginWithLocalToken();
    tryFetchUserDetail();
  }

  void tryLoginWithLocalToken() {
    var userInfoStr = userSp.getString(KEY_USER_INFO);
    var token = userSp.getString(KEY_TOKEN);
    Map<String, dynamic> map =
        userInfoStr == null ? null : json.decode(userInfoStr);
    UserInfo userInfo = map == null ? null : UserInfo.fromJson(map);
    login(userInfo, token, null);
  }

  @override
  String toString() {
    return 'UserModel{_userInfo: $_userInfo, _token: $_token}';
  }

  static UserModel of(BuildContext context) {
    return Provider.of<UserModel>(context, listen: false);
  }

  Future tryFetchUserDetail() async {
    return Api.getUserDetail().then((resp) {
      if(resp.success){
        userDetail = resp.data;
      }
      return null;
    });
  }

  Future tryFetchUserInfoAndLogin() async{
    return Api.getUserInfo().then((resp){
      if(resp.success){
        login(resp.data, resp.token, null);
      }
      return;
    });
  }
}
