import 'package:ease_life/remote/api.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'base_response.dart';

class UserRoleModel extends ChangeNotifier {
  List<UserType> _types;

  List<UserType> get types => _types;

  set types(List<UserType> value) {
    _types = value;
    notifyListeners();
  }

  UserRoleModel() {
    tryFetchUserRoleTypes();
  }

  Future tryFetchUserRoleTypes() async {
    return Api.getUserTypeWithOutId().then((resp) {
      if (resp.success) {
        types = resp.data;
        print('${types.join()}');
      }
      return null;
    });
  }

  static UserRoleModel of(BuildContext context) {
    return Provider.of<UserRoleModel>(context, listen: false);
  }

  void logout() {
    types = [];
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
        }, orElse: ()=>null) !=
        null;
  }

  ///是否是物业人员
  bool hasPropertyPermission() {
    if (_types == null || _types.length == 0) {
      return false;
    }
    return _types.firstWhere((e) => "1" == e.roleCode, orElse: ()=>null) != null;
  }

  ///是否是普通用户
  bool hasCommonUserPermission() {
    if (_types == null || _types.length == 0) {
      return true;
    }
    return _types.firstWhere((e) {
          return ["1", "2", "3", "4", "5", "6"].contains(e.roleCode);
        }, orElse: ()=>null) !=
        null;
  }
}
