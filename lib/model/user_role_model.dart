import 'package:ai_life/remote/api.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'base_response.dart';

class UserRoleModel extends ChangeNotifier {
  List<UserType> _types;

  List<UserType> get types => _types;

  set types(List<UserType> value) {
    _types = value;
    print('${types.join()}');
    notifyListeners();
  }

  UserRoleModel() {
    tryFetchUserRoleTypes();
  }

  Future tryFetchUserRoleTypes() async {
    return Api.getUserRoleTypes().then((resp) {
      if (resp.success) {
        types = resp.data;
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
      return role.roleCode == "1" || role.roleCode == "3" ;
    });
  }
}
