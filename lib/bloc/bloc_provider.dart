import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ease_life/bloc/user_bloc.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/remote/dio_net.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

//class BlocProvider extends InheritedWidget {
//  final UserBloc bloc = UserBloc();
//
//  BlocProvider({Key key, Widget child}) : super(key: key, child: child);
//
//  @override
//  bool updateShouldNotify(InheritedWidget oldWidget) {
//    return true;
//  }
//
//  static UserBloc of(BuildContext context) {
//    return (context.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider)
//        .bloc;
//  }
//}

abstract class BlocBase {
  void dispose();
}

class BlocProviders<T extends BlocBase> extends StatefulWidget {
  final Widget child;
  final T bloc;

  BlocProviders({Key key, @required this.child, @required this.bloc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BlocProviderState();
  }

  static T of<T extends BlocBase>(BuildContext context) {
    final type = _typeOf<BlocProviders<T>>();
    BlocProviders<T> providers = context.ancestorWidgetOfExactType(type);
    return providers.bloc;
  }

  static Type _typeOf<T>() => T;
}

class _BlocProviderState extends State<BlocProviders> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}

class ApplicationBloc extends BlocBase {
  @override
  void dispose() {
    _userInfoController.close();
  }

  ApplicationBloc() {
    _getCurrentUserAndNotify();
  }

  void _getCurrentUserAndNotify() async {
    final sp = await SharedPreferences.getInstance();
    var userInfoStr = sp.getString(PreferenceKeys.keyUserInfo);
    if (userInfoStr?.isNotEmpty == true) {
      _userInfoController.add(UserInfo.fromJson(json.decode(userInfoStr)));
    } else {
      _userInfoController.add(null);
    }
  }

  void login(String userName, String password) async {
    //final sp = await SharedPreferences.getInstance();
    _userInfoController.add(UserInfo()..state = ActionState.LOADING);
    DioUtil.getInstance().then((dio) {
      return dio.postAsync<DataWrapper>(
          path: "/login",
          stringProcessor: (Map<String, dynamic> json) {
            return DataWrapper.fromJson(json);
          },
          data: {
            "userName": userName,
            "password": password
          }).then((BaseResponse<DataWrapper> baseResponse) {
        spInstance.setString(
            PreferenceKeys.keyUserInfo, baseResponse.data.userInfo.toString());
        if (baseResponse.success() && baseResponse.data != null) {
          Fluttertoast.showToast(msg: "登录成功");
        }
        _getCurrentUserAndNotify();
      });
    }).catchError((Object error) {
      var msg = error is DioError ? error.message : error.toString();
      Fluttertoast.showToast(msg: msg);
      _userInfoController.addError(msg);
    });
  }

  PublishSubject<UserInfo> _userInfoController = PublishSubject();

  Stream<UserInfo> get currentUser => _userInfoController.stream;

  void logout() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString(PreferenceKeys.keyUserInfo, null);
    _getCurrentUserAndNotify();
  }

  fastLogin(String mobile, String verifyCode) async {
    _userInfoController.add(UserInfo()..state = ActionState.LOADING);
    DioUtil.getInstance().then((dio) {
      return dio.postAsync<DataWrapper>(
          path: "/fastLogin",
          stringProcessor: (Map<String, dynamic> json) {
            return DataWrapper.fromJson(json);
          },
          data: {
            "mobile": mobile,
            "verifyCode": verifyCode
          }).then((BaseResponse<DataWrapper> baseResponse) {
        spInstance.setString(
            PreferenceKeys.keyUserInfo, baseResponse.data.userInfo.toString());
        if (baseResponse.success() && baseResponse.data != null) {
          Fluttertoast.showToast(msg: "登录成功");
        }
        _getCurrentUserAndNotify();
      });
    }).catchError((Object error) {
      var msg = error is DioError ? error.message : error.toString();
      Fluttertoast.showToast(msg: msg);
      _userInfoController.addError(msg);
    });
  }
}

class CheckData {
  bool checked;

  CheckData(this.checked);
}

class LoginBloc extends BlocBase {
  //-1 loading
  // 0 normal
  // 1-30 count down
  PublishSubject<int> _smsController = PublishSubject();

  Observable<int> get smsStream => _smsController.stream;

  PublishSubject<bool> _typeController = PublishSubject();

  Observable<bool> get typeStream => _typeController.stream;

  PublishSubject<CheckData> _serviceController = PublishSubject();

  Observable<CheckData> get serviceStream => _serviceController.stream;

  bool typeFast = false;
  bool serviceAgree = true;

  void switchType(bool on) {
    typeFast = on;
    _typeController.add(typeFast);
  }

  void switchService(bool on) {
    serviceAgree = on;
    _serviceController.add(CheckData(serviceAgree));
  }

  LoginBloc() {
    _typeController.add(typeFast);
    _serviceController.add(CheckData(serviceAgree));
  }

  void sendSms(String mobile) {
    _smsController.add(-1); //loading
    DioUtil.getInstance().then((dio) {
      return dio
          .postAsync(path: "/user/getVerifyCode", data: {"mobile": mobile});
    }).then((BaseResponse<dynamic> baseResp) {
      if (baseResp.success()) {
        Fluttertoast.showToast(msg: "短信发送成功");
        Observable.periodic(Duration(seconds: 1), (i) => 29 - i)
            .take(30)
            .listen((time) {
          print('$time');
          _smsController.add(time);
        });
      } else {
        _smsController.addError(baseResp.text);
      }
    }).catchError((Object error) {
      var msg = error is DioError ? error.message : error.toString();
      Fluttertoast.showToast(msg: msg);
      _smsController.addError(msg);
    });
  }

  @override
  void dispose() {
    _smsController.close();
    _typeController.close();
    _serviceController.close();
  }
}
