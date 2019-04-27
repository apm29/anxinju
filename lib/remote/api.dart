import 'package:dio/dio.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:flutter/src/widgets/editable_text.dart';
import 'dio_util.dart';

class Api {
  static CancelToken defaultToken = CancelToken();

  static Future<BaseResponse<UserInfoWrapper>> login(
      String userName, String password,
      {CancelToken cancelToken}) async {
    await Future.delayed(Duration(seconds: 2));
    return DioUtil().postAsync<UserInfoWrapper>(
        path: "/login",
        jsonProcessor: (json) => UserInfoWrapper.fromJson(json),
        data: {
          "userName": userName,
          "password": password,
        },
        cancelToken: cancelToken);
  }

  static Future<BaseResponse<UserInfoWrapper>> fastLogin(
      String mobile, String verifyCode,
      {CancelToken cancelToken}) async {
    await Future.delayed(Duration(seconds: 2));
    return DioUtil().postAsync<UserInfoWrapper>(
        path: "/fastLogin",
        jsonProcessor: (json) => UserInfoWrapper.fromJson(json),
        data: {
          "mobile": mobile,
          "verifyCode": verifyCode,
        },
        cancelToken: cancelToken);
  }

  static Future<BaseResponse<Object>> sendSms(String mobile,
      {CancelToken cancelToken}) async {
    await Future.delayed(Duration(seconds: 2));
    return DioUtil().postAsync<Object>(
        path: "/user/getVerifyCode",
        jsonProcessor: (Map<String, dynamic> json) => null,
        data: {"mobile": mobile},
        cancelToken: cancelToken);
  }

  static register(
      String mobile, String smsCode, String password, String userName) async {
    await Future.delayed(Duration(seconds: 2));
    return DioUtil().postAsync<Object>(
      path: "/user/register",
      jsonProcessor: (Map<String, dynamic> json) => null,
      data: {
        "userName":userName,
        "mobile": mobile,
        "password": password,
        "code": smsCode,
      },
    );
  }
}
