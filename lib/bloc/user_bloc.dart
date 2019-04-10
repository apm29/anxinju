import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ease_life/remote//dio_net.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BlocState { LOADING, INIT, SUCCESS, ERROR }

class BlocData<T> {
  BlocState state;
  T data;

  BlocData(this.state, this.data);

  factory BlocData.success(T data) {
    return BlocData(BlocState.SUCCESS, data);
  }

  factory BlocData.error(T data) {
    return BlocData(BlocState.ERROR, data);
  }

  factory BlocData.loading() {
    return BlocData(BlocState.LOADING, null);
  }

  factory BlocData.init() {
    return BlocData(BlocState.INIT, null);
  }

  bool init() => state == BlocState.INIT;

  bool success() => state == BlocState.SUCCESS;

  bool error() => state == BlocState.ERROR;

  bool loading() => state == BlocState.LOADING;
}

class UserBloc {
  UserBloc() {
    _loginController = PublishSubject();
    _smsController = PublishSubject();
    _verifyController = PublishSubject();
  }

  PublishSubject<BlocData<BaseResponse<UserInfoData>>> _loginController;

  Observable<BlocData<BaseResponse<UserInfoData>>> get loginStream => _loginController.stream;

  void login(String userName, String password) async {
    DioApplication.postSync<UserInfoData>(
        "/login", {"userName": userName, "password": password}, (BaseResponse<UserInfoData> data) {
      saveUserInfoData(data.data);
      _loginController.add(BlocData.success(data));
    }, (String errMsg) {
      _loginController.add(BlocData.error(BaseResponse.error(errMsg)));
    }, () {
      _loginController.add(BlocData.error(BaseResponse.error("空结果")));
    });
  }

  static UserInfoData userInfoData;

  void fastLogin<UserInfoData>(String mobile, String verifyCode) {
    DioApplication.postSync(
        "/fastLogin", {"mobile": mobile, "verifyCode": verifyCode},
        (BaseResponse data) {
      saveUserInfoData(data.data);
      _loginController.add(BlocData.success(data));
    }, (String errMsg) {
      _loginController.add(BlocData.error(BaseResponse.error(errMsg)));
    }, () {
      _loginController.add(BlocData.error(BaseResponse.error("空结果")));
    });
  }

  processError(Object error) {
    return error is DioError ? error.message : error.toString();
  }

  void dispose() {
    _loginController.close();
    _smsController.close();
    _verifyController.close();
  }

  static const _EMPTY = "没有返回数据";

  Widget streamBuilder<T>(Stream<T> stream,
      {T initialData,
      Function success,
      Function error,
      Function empty,
      Function loading,
      Function finished}) {
    return StreamBuilder(
        stream: stream,
        initialData: initialData,
        builder: (context, AsyncSnapshot snapshot) {
          if (finished != null) {
            finished();
          }
          if (snapshot.hasData) {
            if (success != null) return success(snapshot.data);
          } else if (snapshot.hasError) {
            final errorStr = snapshot.error;
            if (errorStr == _EMPTY) {
              if (empty != null) return empty();
            } else {
              if (error != null) return error(errorStr);
            }
          } else {
            if (loading != null) return loading();
          }
        });
  }

  PublishSubject<BlocData> _smsController;

  Observable<BlocData> get smsStream => _smsController.stream;

  void sendSms(String mobile) {
    DioApplication.postSync("/user/getVerifyCode", {
      "mobile": mobile,
    }, (BaseResponse data) {
      _verifyController.add(BlocData.success(data));
    }, (String errMsg) {
      _verifyController.add(BlocData.error(errMsg));
    }, () {
      _verifyController.add(BlocData.error("空结果"));
    });
  }

  void logout() {
    SharedPreferences.getInstance().then((sp) {
      sp.setString(PreferenceKeys.keyAuthorization, null);
      return sp;
    }).then((sp) {
      return sp.setString(PreferenceKeys.keyUserInfo, null);
    }).then((success) {
      print('$success');
      _loginController.add(null);
    });
  }

  void saveUserInfoData(UserInfoData data) {
    String encode = json.encode(data.toJson());
    SharedPreferences.getInstance().then((sp) {
      return sp.setString(PreferenceKeys.keyUserInfo, encode);
    }).then((success) {
      print('$success');
    });
  }

  Future<UserInfoData> getUserInfoData() async {
    String userInfoString = (await SharedPreferences.getInstance())
        .getString(PreferenceKeys.keyUserInfo);
    print('$userInfoString');
    Map userInfoMap = json.decode(userInfoString);
    var userInfoData = UserInfoData.fromJson(userInfoMap);
    return userInfoData;
  }

  PublishSubject<BlocData> _verifyController;

  Observable<BlocData> get verifyStream => _verifyController.stream;

  void verify(String idCard, String imageUrl) {
    _verifyController.add(BlocData.loading());
    DioApplication.postSync("/userCertification/getMyVerify", {
      "idCard": idCard,
      "photo": imageUrl,
    }, (data) {
      _verifyController.add(BlocData.success(data));
    }, (errMsg) {
      _verifyController.add(BlocData.error(errMsg));
    }, () {
      _verifyController.add(BlocData.error("空结果"));
    });
  }
}
