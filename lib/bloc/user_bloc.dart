//import 'dart:async';
//import 'dart:convert';
//import 'package:dio/dio.dart';
//import 'package:ease_life/persistance/shared_preference_keys.dart';
//import 'package:ease_life/ui/style.dart';
//import 'package:flutter/material.dart';
//import 'package:rxdart/rxdart.dart';
//import 'package:ease_life/remote//dio_net.dart';
//import 'package:ease_life/model/base_response.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//
//enum BlocState { LOADING, INIT, SUCCESS, ERROR }
//
//class BlocData<T> {
//  BlocState state;
//  T response;
//
//  BlocData(this.state, this.response);
//
//  factory BlocData.success(T data) {
//    return BlocData(BlocState.SUCCESS, data);
//  }
//
//  factory BlocData.error(T data) {
//    return BlocData(BlocState.ERROR, data);
//  }
//
//  factory BlocData.loading() {
//    return BlocData(BlocState.LOADING, null);
//  }
//
//  factory BlocData.init() {
//    return BlocData(BlocState.INIT, null);
//  }
//
//  bool init() => state == BlocState.INIT;
//
//  bool success() => state == BlocState.SUCCESS;
//
//  bool error() => state == BlocState.ERROR;
//
//  bool loading() => state == BlocState.LOADING;
//}
//
//class UserBloc {
//  UserBloc() {
//    _loginController = PublishSubject();
//    _smsController = PublishSubject();
//    _verifyController = PublishSubject();
//    _themeController = PublishSubject();
//  }
//
//  PublishSubject<BlocData<UserInfoModel>> _loginController;
//
//  Observable<BlocData<UserInfoModel>> get loginStream =>
//      _loginController.stream;
//
//  void login(String userName, String password) async {
//    DioApplication.postSync<UserInfoModel>(
//        "/login", {"userName": userName, "password": password},
//        (UserInfoModel data) {
//      saveUserInfoData(data.data);
//      _loginController.add(BlocData.success(data));
//    }, (String errMsg) {
//      _loginController.add(BlocData.error(UserInfoModel.error(errMsg)));
//    }, () {
//      _loginController.add(BlocData.error(UserInfoModel.error("空结果")));
//    }, (json) {
//      return UserInfoModel.fromJson(json);
//    });
//  }
//
//
//  void fastLogin<UserInfoData>(String mobile, String verifyCode) {
//    DioApplication.postSync(
//        "/fastLogin", {"mobile": mobile, "verifyCode": verifyCode},
//        (UserInfoModel data) {
//      saveUserInfoData(data.data);
//      _loginController.add(BlocData.success(data));
//    }, (String errMsg) {
//      _loginController.add(BlocData.error(UserInfoModel.error(errMsg)));
//    }, () {
//      _loginController.add(BlocData.error(UserInfoModel.error("空结果")));
//    }, (json) {
//      return UserInfoModel.fromJson(json);
//    });
//  }
//
//  processError(Object error) {
//    return error is DioError ? error.message : error.toString();
//  }
//
//  void dispose() {
//    _loginController.close();
//    _smsController.close();
//    _verifyController.close();
//    _themeController.close();
//  }
//
//  PublishSubject<BlocData> _smsController;
//
//  Observable<BlocData> get smsStream => _smsController.stream;
//
//  void sendSms(String mobile) {
//    DioApplication.postSync("/user/getVerifyCode", {
//      "mobile": mobile,
//    }, (BaseResponse data) {
//      _verifyController.add(BlocData.success(data));
//    }, (String errMsg) {
//      _verifyController.add(BlocData.error(errMsg));
//    }, () {
//      _verifyController.add(BlocData.error("空结果"));
//    }, (json) {
//      return UserInfoModel.fromJson(json);
//    });
//  }
//
//  void logout() {
//    SharedPreferences.getInstance().then((sp) {
//      sp.setString(PreferenceKeys.keyAuthorization, null);
//      return sp;
//    }).then((sp) {
//      return sp.setString(PreferenceKeys.keyUserInfo, null);
//    }).then((success) {
//      print('$success');
//      _loginController.add(null);
//    });
//  }
//
//  void saveUserInfoData(UserInfoWrapper data) {
//    String encode = json.encode(data.toJson());
//    SharedPreferences.getInstance().then((sp) {
//      return sp.setString(PreferenceKeys.keyUserInfo, encode);
//    }).then((success) {
//      print('$success');
//    });
//  }
//
//  Future<UserInfoWrapper> getUserInfoData() async {
//    String userInfoString = (await SharedPreferences.getInstance())
//        .getString(PreferenceKeys.keyUserInfo);
//    Map userInfoMap = json.decode(userInfoString);
//    var userInfoData = UserInfoWrapper.fromJson(userInfoMap);
//    return userInfoData;
//  }
//
//  PublishSubject<BlocData> _verifyController;
//
//  Observable<BlocData> get verifyStream => _verifyController.stream;
//
//  void verify(String idCard, String imageUrl) {
//    _verifyController.add(BlocData.loading());
//    DioApplication.postSync("/userCertification/getMyVerify", {
//      "idCard": idCard,
//      "photo": imageUrl,
//    }, (data) {
//      _verifyController.add(BlocData.success(data));
//    }, (errMsg) {
//      _verifyController.add(BlocData.error(errMsg));
//    }, () {
//      _verifyController.add(BlocData.error("空结果"));
//    }, (json) {
//      return UserInfoModel.fromJson(json);
//    });
//  }
//
//  PublishSubject<ThemeData> _themeController;
//  Observable<ThemeData> get themeStream => _themeController.stream;
//
//  void changeTheme(){
//    _themeController.add(defaultThemeData);
//  }
//}
