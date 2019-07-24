import 'package:ease_life/remote/api.dart';
import 'package:flutter/foundation.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'base_response.dart';
import 'district_model.dart';

class UserRoleModel extends ChangeNotifier {
  List<UserType> _types = [];

  List<UserType> get types => _types ?? [];

  get switchString => (currentRole?.isPropertyRole() ?? false) ? "物业版" : "用户版";

  set types(List<UserType> value) {
    if(listEquals(value,_types)){
      return;
    }
    _types = value;
    notifyListeners();
  }

  UserRoleModel(BuildContext context) {
    tryFetchUserRoleTypes(context);
  }

  Future<bool> tryFetchUserRoleTypes(BuildContext context,
      {bool dispatchUser = true}) async {
    return Api.getUserTypeWithOutId().then((resp) {
      if (resp.success) {
        types = resp.data;
        types.forEach((type) {
          print(type);
        });
        if (dispatchUser) {
          dispatchCurrentRole(types);
        }
      }
      return null;
    }).then((_) {
      return hasRoleSwitchFeature(context).then((res) {
        hasSwitch = res;
        return res;
      });
    });
  }

  void dispatchCurrentRole(List<UserType> types) {
    currentRole = getFirstRoleUserByCode("1",
        orElse: getFirstRoleUserByCode("3",
            orElse: getFirstRoleUserByCode("2,4,5,6")));
  }

  Future<bool> hasRoleSwitchFeature(BuildContext context) async {
    var uncommonRole =
        getFirstRoleUserByCode("1", orElse: getFirstRoleUserByCode("3"));
    if (uncommonRole == null) {
      return false;
    }
    var unauthorizedRole = getFirstRoleUserByCode("6");
    if (unauthorizedRole != null) {
      return false;
    }
    var commonRole = getFirstRoleUserByCode("2,4,5");
    if (commonRole != null && uncommonRole != null) {
      return true;
    }
    return false;
  }

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
    if(value == _currentRole){
      return;
    }
    _currentRole = value;
    //切换到物业人员时提示
    if(isOnPropertyDuty) {
      showToast("切换角色成功:${_currentRole.roleName}");
    }
    notifyListeners();
  }

  bool _hasSwitch = false;

  bool get hasSwitch {
    return _hasSwitch;
    //return false;
  }

  bool get isOnPropertyDuty {
    return currentRole?.isPropertyRole() ?? false;
    //return false;
  }

  set hasSwitch(bool value) {
    if (value == _hasSwitch) {
      return;
    }
    _hasSwitch = value;
    notifyListeners();
  }

  static UserRoleModel of(BuildContext context, {bool listen = false}) {
    return Provider.of<UserRoleModel>(context, listen: listen);
  }

  void logout() {
    types = [];
    _hasSwitch = false;
    _currentRole = null;
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
    if (_types == null || _types.length == 0) {
      return false;
    }
    return _types.firstWhere((e) {
          return "1" == e.roleCode || "3" == e.roleCode;
        }, orElse: () => null) !=
        null;
  }

  ///是否是物业人员
  bool hasPropertyPermission() {
    if (_types == null || _types.length == 0) {
      return false;
    }
    return _types.firstWhere((e) => "1" == e.roleCode, orElse: () => null) !=
        null;
  }

  ///是否是普通用户
  bool hasCommonUserPermission() {
    if (_types == null || _types.length == 0) {
      return true;
    }
    return _types.firstWhere((e) {
          return ["1", "2", "3", "4", "5", "6"].contains(e.roleCode);
        }, orElse: () => null) !=
        null;
  }

  void switchRole() {
    if (currentRole.isPropertyRole()) {
      currentRole = getFirstRoleUserByCode("2,4,5");
    } else {
      currentRole = getFirstRoleUserByCode("1");
    }
  }
}
