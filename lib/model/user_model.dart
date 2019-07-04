import 'dart:convert';

import 'package:ai_life/remote/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'base_response.dart';
import 'package:ai_life/persistence/const.dart';

import 'district_model.dart';
import 'user_role_model.dart';
import 'user_verify_status_model.dart';

class UserModel extends ChangeNotifier {
  UserInfo _userInfo;
  String _token;

  String get userId => _userInfo?.userId;

  String get userName => _userInfo?.userName;

  String get token => _token;

  bool get isLogin => userId != null && token != null;

  void login(UserInfo info, String token, BuildContext context) {
    _userInfo = info;
    _token = token;
    sp.setString(KEY_USER_INFO, info.toString());
    sp.setString(KEY_TOKEN, token);

    ///重新获取验证状态/获取小区
    if (context != null) {
      UserVerifyStatusModel.of(context).tryFetchVerifyStatus();
      DistrictModel.of(context).tryFetchCurrentDistricts();
      UserRoleModel.of(context).tryFetchUserRoleTypes();
    }
    notifyListeners();
  }

  void logout(BuildContext context) {
    UserVerifyStatusModel.of(context).logout();
    UserRoleModel.of(context).logout();
    _userInfo = null;
    _token = null;
    sp.setString(KEY_USER_INFO, null);
    sp.setString(KEY_TOKEN, null);
    sp.clear();
    DistrictModel.of(context).tryFetchCurrentDistricts();
    notifyListeners();
  }

  UserModel() {
    tryLoginWithLocalToken();
  }

  void tryLoginWithLocalToken() {
    var userInfoStr = sp.getString(KEY_USER_INFO);
    var token = sp.getString(KEY_TOKEN);
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
}
