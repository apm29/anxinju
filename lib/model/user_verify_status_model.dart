import 'dart:async';

import 'package:ease_life/remote/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'base_response.dart';

class UserVerifyStatusModel extends ChangeNotifier {
  UserVerifyStatus _status;

  UserVerifyStatus get status => _status;

  set status(UserVerifyStatus value) {
    var oldStatus = status;
    if (status != value) {
      _status = value;
      notifyListeners();
      if (oldStatus != null && status != null)
        showToast("人脸认证状态变化:${status.getVerifyText()}");
    }
  }

  UserVerifyStatusModel() {
    //tryFetchVerifyStatus();
  }

  Future tryFetchVerifyStatus() async {
    return Api.getUserVerify().then((resp) {
      if (resp.success) {
        status = resp.data;
      } else {
        showToast(resp.text);
      }
      return;
    });
  }

  StreamSubscription subscription;

  Future tryFetchVerifyStatusPeriodically(BuildContext context) async {
    subscription?.cancel();
    tryFetchVerifyStatus().then((_) {
      subscription = Observable.periodic(
        Duration(seconds: 15),
      ).take(5).listen((_) {
        tryFetchVerifyStatus();
      });
    });
    return _showHint(context);
  }

  Future _showHint(BuildContext context) async {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.message,
                  color: Colors.blue,
                ),
                Text("提醒"),
              ],
            ),
            content: Text("人脸比对耗时较长,请等待几分钟后刷新页面"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("确定"),
              )
            ],
          );
        });
  }

  static UserVerifyStatusModel of(BuildContext context) {
    return Provider.of<UserVerifyStatusModel>(context);
  }

  bool isVerified() {
    return status?.isVerified() ?? false;
  }

  void logout() {
    status = null;
  }

  String get verifyStatusDesc => status?.getDesc() ?? "未认证";

  String getVerifyText() {
    return status?.getVerifyText() ?? "未认证";
  }

  bool isNotVerified() {
    return (status?.code ?? -1) <= 0;
  }
}
