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

  static Future<BaseResponse<UserInfo>> getUserInfo(
      {CancelToken cancelToken}) async {
    return DioUtil().postAsync<UserInfo>(
        path: "permission/user/getUserInfo",
        jsonProcessor: (json) => UserInfo.fromJson(json),
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
   *  前端发送photo、idCard，
   */
  static Future<BaseResponse> verifyUserFace(
      String imageUrl, String idCard) async {
    return await DioUtil().postAsync(
        path: "/permission/userCertification/verify",
        data: {"photo": imageUrl, "idCard": idCard});
  }

  static Future<BaseResponse<UserVerifyInfo>> verify(
      String imageUrl, String idCard) async {
    return await DioUtil().postAsync(
        path: "/permission/userCertification/verify",
        jsonProcessor: (j){
          return UserVerifyInfo.fromJson(j);
        },
        data: {"photo": imageUrl, "idCard": idCard});
  }

  /*
   * 获取用户认证状态
   * 返回的都为正确结果,显示text
   */
  static Future<BaseResponse> getUserVerification() async {
    return await DioUtil()
        .postAsync(path: "/permission/userCertification/getMyVerify");
  }

  /*
   * 获取用户详情
   */
  static Future<BaseResponse<UserDetail>> getUserDetail() async {
    return await DioUtil().postAsync<UserDetail>(
      path: "/permission/userDetail/getUserDetail",
      jsonProcessor: (jsonMap) {
        return UserDetail.fromJson(jsonMap);
      },
    );
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
    var dataMap = {
      "myName": myName,
      "sex": sex,
      "phone": phone,
      "nickName": nickName,
      "avatar": avatar,
      "idCard": idCard
    };
    if (userId != null) {
      dataMap["userId"] = userId;
    }
    return await DioUtil().postAsync(
        path: "/permission/userDetail/saveUserDetail", data: dataMap);
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

  static Future<BaseResponse<List<NoticeType>>> getAllNoticeType() async {
    return DioUtil().postAsync(
        path: "/business/noticeDict/getAllType",
        jsonProcessor: (json) {
          if (json is List) {
            return json.map((j) {
              return NoticeType.fromJson(j);
            }).toList();
          }
          return null;
        },
        dataType: DataType.LIST);
  }

  static Future<BaseResponse<List<NoticeDetail>>> getNewNotice(
      List<NoticeType> list) {
    return DioUtil().postAsync(
      path: "/business/notice/getAllNewNotice",
      jsonProcessor: (json) {
        if (json is List) {
          return json.map((j) {
            return NoticeDetail.fromJson(j);
          }).toList();
        }
        return null;
      },
      data: {
        "noticeType": list
            .map((notice) {
              return notice.typeId;
            })
            .toList()
            .join(",")
      },
      dataType: DataType.LIST,
      addAuthorization: false,
    );
  }

  static Future<List<Index>> getIndex() {
    return DioUtil().getIndexJson();
  }
}
