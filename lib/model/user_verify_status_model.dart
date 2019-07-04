import 'package:ai_life/remote/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'base_response.dart';

class UserVerifyStatusModel extends ChangeNotifier {
  UserVerifyStatus _status;

  UserVerifyStatus get status => _status;

  set status(UserVerifyStatus value) {
    _status = value;
    print('$status');
    notifyListeners();
  }

  UserVerifyStatusModel() {
    tryFetchVerifyStatus();
  }

  Future tryFetchVerifyStatus() async {
    return Api.getUserVerifyStatus().then((resp) {
      if (resp.success) {
        status = resp.data;
      }
      return;
    });
  }

  static UserVerifyStatusModel of(BuildContext context) {
    return Provider.of<UserVerifyStatusModel>(context);
  }

  bool isVerified() {
    return status?.isVerified() ?? false;
  }

  bool hasHouse() {
    return status?.hasHouse() ?? false;
  }

  void logout() {
    status = null;
  }
}
