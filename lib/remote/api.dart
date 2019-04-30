import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ease_life/model/base_response.dart';
import 'dio_util.dart';

class Api {
  static CancelToken defaultToken = CancelToken();

  static Future<BaseResponse<UserInfoWrapper>> login(
      String userName, String password,
      {CancelToken cancelToken}) async {
    return DioUtil().postAsync<UserInfoWrapper>(
        path: "permission/login",
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
    return DioUtil().postAsync<UserInfoWrapper>(
        path: "permission/fastLogin",
        jsonProcessor: (json) => UserInfoWrapper.fromJson(json),
        data: {
          "mobile": mobile,
          "verifyCode": verifyCode,
        },
        cancelToken: cancelToken);
  }

  static Future<BaseResponse<Object>> sendSms(String mobile,
      {CancelToken cancelToken}) async {
    return DioUtil().postAsync<Object>(
        path: "permission/user/getVerifyCode",
        jsonProcessor: (dynamic json) => null,
        data: {"mobile": mobile},
        cancelToken: cancelToken);
  }

  static register(
      String mobile, String smsCode, String password, String userName) async {
    return DioUtil().postAsync<Object>(
      path: "permission/user/register",
      jsonProcessor: (dynamic json) => null,
      data: {
        "userName": userName,
        "mobile": mobile,
        "password": password,
        "code": smsCode,
      },
    );
  }

  static Future<BaseResponse<List<DistrictInfo>>> findAllDistrict() async {
    BaseResponse<List<DistrictInfo>> baseResponse =
        await DioUtil().postAsync<List<DistrictInfo>>(
            path: "business/district/findDistrictInfo",
            jsonProcessor: (dynamic json) {
              if (json is List) {
                return json.map((j) {
                  return DistrictInfo.fromJson(j);
                }).toList();
              }
              return null;
            },
            data: {},
            dataType: DataType.LIST);

    return baseResponse;
  }

  /*
   *  前端发送photo、idCard，后端接收处理，返回错误时表示该用户已通过认证，不需要重新发起认证
   */
  static Future<BaseResponse> verifyUserFace(
      String imageUrl, String idCard) async {
    return await DioUtil().postAsync(
        path: "/permission/userCertification/verify",
        data: {"photo": imageUrl, "idCard": idCard});
  }

  /*
   * 获取用户认证状态
   * 返回的都为正确结果,显示text
   */
  static Future<BaseResponse> verifyUserVerify() async {
    return await DioUtil()
        .postAsync(path: "/permission/userCertification/getMyVerify");
  }

  /*
   * 获取用户详情
   */
  static Future<BaseResponse<UserDetail>> getUserDetail() async {
    return await DioUtil()
        .postAsync<UserDetail>(path: "/userDetail/getUserDetail");
  }

  /*
   * 保存用户详情
   * userId,用户id:带上id为修改,不带id为新增详情
   * myName
   */
  static Future<BaseResponse> saveUserDetail(
      {String userId,
      String myName,
      String sex,
      String phone,
      String nickName,
      String avatar,
      String idCard}) async {
    return await DioUtil().postAsync(path: "/userDetail/saveUserDetail", data: {
      "userId": userId,
      "myName": myName,
      "sex": sex,
      "phone": phone,
      "nickName": nickName,
      "avatar": avatar,
      "idCard": idCard
    });
  }

  static Future<BaseResponse<FileDetail>> uploadFile(String path) async {
    var baseResponse = await DioUtil().postAsync<FileDetail>(
        path: "/business/upload/uploadFile",
        data: {"file": UploadFileInfo(File(path), "file")},
        jsonProcessor: (s) => FileDetail.fromJson(s),
        dataType: DataType.JSON,
        formData: true);
    return baseResponse;
  }

  static Future<BaseResponse<ImageDetail>> uploadPic(String path) async {
    print('file path : $path');
    var baseResponse = await DioUtil().postAsync<ImageDetail>(
        path: "/business/upload/uploadPic",
        data: {"pic": UploadFileInfo(File(path), "pic")},
        jsonProcessor: (s) => ImageDetail.fromJson(s),
        dataType: DataType.JSON,
        formData: true);
    return baseResponse;
  }

}
