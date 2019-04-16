import 'package:ease_life/model/base_response.dart';

import 'dio_util.dart';

class Api{
  static Future<BaseResponse<UserInfoWrapper>> login(String userName, String password) async {
    return DioUtil().postAsync<UserInfoWrapper>(
        path: "/login",
        jsonProcessor: (json) => UserInfoWrapper.fromJson(json),
        data: {
          "userName": userName,
          "password": password,
        });
  }

  static Future<BaseResponse<UserInfoWrapper>> fastLogin(
      String mobile, String verifyCode) async {
    return DioUtil().postAsync<UserInfoWrapper>(
        path: "/fastLogin",
        jsonProcessor: (json) => UserInfoWrapper.fromJson(json),
        data: {
          "mobile": mobile,
          "verifyCode": verifyCode,
        });
  }

  static Future<BaseResponse<Object>> sendSms(String mobile) async {
    return DioUtil().postAsync<Object>(
        path: "/user/getVerifyCode",
        jsonProcessor: (Map<String, dynamic> json) => null,
        data: {"mobile": mobile});
  }
}

