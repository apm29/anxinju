import 'dart:convert';

import 'package:ease_life/model/service_chat_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/ui/notification_message_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future login(UserInfo info, String token, BuildContext context) async{
    _userInfo = info;
    _token = token;
    userSp.setString(KEY_USER_INFO, info.toString());
    userSp.setString(KEY_TOKEN, token);

    ///重新获取验证状态/获取小区
    if (context != null) {
      await refreshUserData(context);
    }
    notifyListeners();
  }

  Future refreshUserData(BuildContext context) async{
    await UserVerifyStatusModel.of(context).tryFetchVerifyStatus();
    await DistrictModel.of(context).tryFetchCurrentDistricts();
    await UserVerifyStatusModel.of(context).tryFetchVerifyStatus();
    await UserRoleModel.of(context).tryFetchUserRoleTypes(context);
    await MessageModel.of(context).refresh();
    try {
      ServiceChatModel.of(context).reconnect(context);
    } catch (e) {
      print(e);
    }
    await tryFetchUserDetail();
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
    requestPermission();
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
        return login(resp.data, resp.token, null);
      }
      return null;
    });
  }

  Future _requestPermission(PermissionGroup group) async{
    try {
      var status = await PermissionHandler().checkPermissionStatus(group);
      if(status == PermissionStatus.granted){
            return null;
          }
      return PermissionHandler().requestPermissions([group]);
    } catch (e) {
      print(e);
    }
  }

  void requestPermission() async{
    await _requestPermission(PermissionGroup.storage);
    await _requestPermission(PermissionGroup.camera);
  }
}
