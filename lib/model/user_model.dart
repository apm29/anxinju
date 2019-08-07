import 'dart:convert';

import 'package:ease_life/model/service_chat_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/ui/notification_message_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
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

  String get userAvatar => _userInfo?.avatar;

  String get userNickname => _userInfo?.nickName;

  String get idCard => _userInfo?.idCard;

  String get mobile => _userInfo?.mobile;

  String get myName => _userInfo?.myName;

  String get gender => _userInfo?.sex;

  String get token => _token;

  bool get isLogin => userId != null && token != null;

  Future login(
    UserInfo info,
    String token,
    BuildContext context, {
    bool dispatchRole = false,
  }) async {
    _userInfo = info;
    _token = token;
    userSp.setString(KEY_USER_INFO, info.toString());
    userSp.setString(KEY_TOKEN, token);

    ///重新获取验证状态/获取小区
    if (context != null) {
      await refreshUserData(context);
    }
    if(dispatchRole){
      dispatchCurrentRole();
    }
    notifyListeners();
  }

  Future refreshUserData(BuildContext context) async {
    await UserVerifyStatusModel.of(context).tryFetchVerifyStatus();
    await DistrictModel.of(context).tryFetchCurrentDistricts();
    await UserVerifyStatusModel.of(context).tryFetchVerifyStatus();
    await MessageModel.of(context).refresh();
    try {
      if (hasPropertyPermission()) {
        ServiceChatModel.of(context).reconnect(this, DistrictModel.of(context));
      }
    } catch (e) {
      print(e);
    }
  }

  void logout(BuildContext context) {
    UserVerifyStatusModel.of(context).logout();
    _userInfo = null;
    _token = null;
    _currentRole = null;
    userSp.setString(KEY_USER_INFO, null);
    userSp.setString(KEY_TOKEN, null);
    DistrictModel.of(context).tryFetchCurrentDistricts();
    try {
      ServiceChatModel.of(context).disconnect();
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  UserModel() {
    tryLoginWithLocalToken();
    requestPermission();
  }

  void tryLoginWithLocalToken() {
    var userInfoStr = userSp.getString(KEY_USER_INFO);
    var token = userSp.getString(KEY_TOKEN);
    try {
      Map<String, dynamic> map =
          userInfoStr == null ? null : json.decode(userInfoStr);
      UserInfo userInfo = map == null ? null : UserInfo.fromJson(map);
      login(userInfo, token, null,dispatchRole: true);
    } catch (e) {
      print(e);
    }
  }

  static UserModel of(BuildContext context,{bool listen = false}) {
    return Provider.of<UserModel>(context, listen: listen);
  }

  Future tryFetchUserInfoAndLogin() async {
    return Api.getUserInfo().then((resp) {
      if (resp.success) {
        return login(resp.data, resp.token, null);
      }
      return null;
    });
  }

  Future _requestPermission(PermissionGroup group) async {
    try {
      var status = await PermissionHandler().checkPermissionStatus(group);
      if (status == PermissionStatus.granted) {
        return null;
      }
      return PermissionHandler().requestPermissions([group]);
    } catch (e) {
      print(e);
    }
  }

  void requestPermission() async {
    await _requestPermission(PermissionGroup.storage);
    await _requestPermission(PermissionGroup.camera);
  }

  ///-----------------------用户角色相关-------------------------------------
  void dispatchCurrentRole() {
    currentRole = getFirstRoleUserByCode("1",
        orElse: getFirstRoleUserByCode("3",
            orElse: getFirstRoleUserByCode("2,4,5,6")));
  }

  List<UserType> get types => _userInfo?.roles ?? [];

  ///是否有切换角色功能
  bool hasRoleSwitchFeature() {
    ///是否有物业或者民警角色
    var uncommonRole =
        getFirstRoleUserByCode("1", orElse: getFirstRoleUserByCode("3"));
    if (uncommonRole == null) {
      return false;
    }

    ///是否有未认证角色
    var unauthorizedRole = getFirstRoleUserByCode("6");
    if (unauthorizedRole != null) {
      return false;
    }

    ///并且还要有普通用户角色
    var commonRole = getFirstRoleUserByCode("2,4,5");
    if (commonRole != null && uncommonRole != null) {
      return true;
    }
    return false;
  }

  ///获取首个roleCode对应的userType,或者其他orElse
  UserType getFirstRoleUserByCode(String roleCode, {UserType orElse}) {
    orElse = orElse ?? null;
    return types.firstWhere((type) => roleCode.contains(type.roleCode),
        orElse: () => orElse);
  }

  ///
  /// 用户当前角色
  /// 包含物业,警察时优先显示物业/警察 页面
  /// 如果 是有房认证用户且含物业/警察 角色, 需要包含可切换回认证用户页面的功能
  ///
  /// @RoleCode
  ///物业人员 1
  ///有房认证用户 2
  ///民警 3
  ///无房认证用户 4
  ///家庭成员 5
  ///无认证用户 6
  UserType _currentRole;

  UserType get currentRole => _currentRole;

  set currentRole(UserType value) {
    if (value == _currentRole) {
      return;
    }
    _currentRole = value;
    //切换到物业人员时提示
    if (isOnPropertyDuty) {
      showToast("切换角色成功:${_currentRole.roleName}");
    }
    notifyListeners();
  }

  bool get hasSwitch  => hasRoleSwitchFeature();
  get switchString => (currentRole?.isPropertyRole() ?? false) ? "物业版" : "用户版";

  bool get isOnPropertyDuty {
    return currentRole?.isPropertyRole() ?? false;
    //return false;
  }

  bool isGuardianUser() {
    if (types == null || types.length == 0) {
      return false;
    }
    return types.any((role) {
      return role.roleCode == "1" || role.roleCode == "3";
    });
  }

  ///民警 或者 物业可以看社区记录
  bool hasSocietyRecordPermission() {
    if (types == null || types.length == 0) {
      return false;
    }
    return types.firstWhere((e) {
          return "1" == e.roleCode || "3" == e.roleCode;
        }, orElse: () => null) !=
        null;
  }

  ///是否是物业人员
  bool hasPropertyPermission() {
    if (types == null || types.length == 0) {
      return false;
    }
    return types.firstWhere((e) => "1" == e.roleCode, orElse: () => null) !=
        null;
  }

  ///是否是普通用户
  bool hasCommonUserPermission() {
    if (types == null || types.length == 0) {
      return true;
    }
    return types.firstWhere((e) {
          return ["1", "2", "3", "4", "5", "6"].contains(e.roleCode);
        }, orElse: () => null) !=
        null;
  }

  ///切换角色
  void switchRole() {
    if (currentRole.isPropertyRole()) {
      currentRole = getFirstRoleUserByCode("2,4,5");
    } else {
      currentRole = getFirstRoleUserByCode("1");
    }
  }

  Future changeUserDetailByKey(String value, String dataKey) async {
    var dataMap = {
      "userId": userId,
      dataKey: value,
    };
    var baseResponse = await Api.saveUserDetailByMap(dataMap);
    await tryFetchUserInfoAndLogin();
    showToast(baseResponse.text);
  }
}
