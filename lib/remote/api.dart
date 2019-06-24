import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ease_life/model/base_response.dart';
import '../index.dart';
import 'dio_util.dart';

class Api {
  static CancelToken defaultToken = CancelToken();

  static Future<BaseResponse<UserInfoWrapper>> login(String userName,
      String password,
      {CancelToken cancelToken}) async {
    return DioUtil().postAsync<UserInfoWrapper>(
        path: "/permission/login",
        jsonProcessor: (json) => UserInfoWrapper.fromJson(json),
        data: {
          "userName": userName,
          "password": password,
        },
        cancelToken: cancelToken);
  }

  static Future<BaseResponse<UserInfoWrapper>> fastLogin(String mobile,
      String verifyCode,
      {CancelToken cancelToken}) async {
    return DioUtil().postAsync<UserInfoWrapper>(
        path: "/permission/fastLogin",
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
        path: "/permission/user/getUserInfo",
        jsonProcessor: (json) => UserInfo.fromJson(json),
        cancelToken: cancelToken);
  }

  ///type  0 注册 ,其他登录
  static Future<BaseResponse<Object>> sendSms(String mobile, int type,
      {CancelToken cancelToken}) async {
    return DioUtil().postAsync<Object>(
        path: "/permission/user/getVerifyCode",
        jsonProcessor: (dynamic json) => null,
        data: {"mobile": mobile, "type": type},
        cancelToken: cancelToken);
  }

  static register(String mobile, String smsCode, String password,
      String userName) async {
    return DioUtil().postAsync<Object>(
      path: "/permission/user/register",
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
        path: "/business/district/findDistrictInfo",
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
  static Future<BaseResponse> verifyUserFace(String imageUrl,
      String idCard) async {
    return await DioUtil().postAsync(
        path: "/permission/userCertification/verify",
        data: {"photo": imageUrl, "idCard": idCard});
  }

  static Future<BaseResponse<UserVerifyInfo>> verify(String imageUrl,
      String idCard, bool isAgain) async {
    return await DioUtil().postAsync(
        path: "/permission/userCertification/verify",
        jsonProcessor: (j) {
          return UserVerifyInfo.fromJson(j);
        },
        data: {
          "photo": imageUrl,
          "idCard": idCard,
          "isAgain": isAgain ? 1 : 0
        });
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
  static Future<BaseResponse> saveUserDetail({String userId,
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
    var file = File(path);
    var baseResponse = await DioUtil().postAsync<ImageDetail>(
        path: "/business/upload/uploadPic",
        data: {"pic": UploadFileInfo(file, file.path)},
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
      List<NoticeType> list) async {
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

  static Future<List<Index>> getIndex() async {
    return DioUtil().getIndexJson();
  }

  static Future<BaseResponse<List<UserType>>> getUserType(String userId) {
    return DioUtil().postAsync(
        path: "/permission/UserRole/findUserRole",
        jsonProcessor: (json) {
          if (json is List) {
            return json.map((j) {
              return UserType.fromJson(j);
            }).toList();
          }
          return [];
        },
        dataType: DataType.LIST,
        data: {"userId": userId});
  }

  static Future<BaseResponse<List<String>>> getBuildings(int districtId) async {
    return DioUtil().postAsync(
        path: "/business/housedictInfo1/getAllBuilding1",
        jsonProcessor: (s) {
          if (s is List) {
            return s.map((i) => i.toString()).toList();
          }
          return [];
        },
        dataType: DataType.LIST,
        data: {"districtId": districtId});
  }

  static Future<BaseResponse<List<String>>> getUnits(int districtId,
      String building) async {
    return DioUtil().postAsync(
        path: "/business/housedictInfo1/getAllUnit1",
        jsonProcessor: (s) {
          if (s is List) {
            return s.map((i) => i.toString()).toList();
          }
          return [];
        },
        dataType: DataType.LIST,
        data: {
          "districtId": districtId,
          "building": building,
        });
  }

  static Future<BaseResponse<List<String>>> getRooms(int districtId,
      String building, String unit) async {
    return DioUtil().postAsync(
        path: "/business/housedictInfo1/getAllRoom1",
        jsonProcessor: (s) {
          if (s is List) {
            return s.map((i) => i.toString()).toList();
          }
          return [];
        },
        dataType: DataType.LIST,
        data: {
          "districtId": districtId,
          "building": building,
          "unit": unit,
        });
  }

  static Future<BaseResponse> applyMember(String address, int districtId,
      String name) async {
    return DioUtil().postAsync(path: "/business/member/applyMember", data: {
      "districtId": districtId,
      "addr": address,
      "name": name,
    });
  }

  static Future<BaseResponse<List<HouseDetail>>> getMyHouse(int districtId) {
    return DioUtil().postAsync<List<HouseDetail>>(
      path: "/business/houseInfo/getMyHouse",
      data: {
        "districtId": districtId,
      },
      jsonProcessor: (s) {
        if (s is List) {
          return s.map((i) => HouseDetail.fromJson(i)).toList();
        }
        return [];
      },
      dataType: DataType.LIST,
    );
  }

  static Future<BaseResponse<List<UserType>>> getUserTypeWithOutId() {
    return DioUtil().postAsync(
        path: "/permission/UserRole/findUserRole",
        jsonProcessor: (json) {
          if (json is List) {
            return json.map((j) {
              return UserType.fromJson(j);
            }).toList();
          }
          return [];
        },
        dataType: DataType.LIST,
        data: {});
  }

  static Future<BaseResponse<List>> getMyApplyList(
      {String status, int page, int row}) {
    var map = <String, dynamic>{
      "page": page,
      "row": row,
    };
    if (status != null) {
      map["status"] = status;
    }
    return DioUtil().postAsync(
        path: "/business/member/getMyApplyList",
        jsonProcessor: (jsonString) {
          if (jsonString is List) {
            return jsonString.map((j) {
              return UserType.fromJson(j);
            }).toList();
          }
          return [];
        },
        dataType: DataType.LIST,
        data: map);
  }

  static Future<BaseResponse> faceCompare(String imageBase64, String idCard) {
    return DioUtil().postAsync(
      path: "/facecompare/compare/",
      data: {"idNo": idCard, "imageBase64Str": imageBase64},
    );
  }

}

class ApiKf {
  static Future<BaseResponse<AudioUploadInfo>> uploadAudio(File file) {
    return DioUtil().postAsync(
        path: "/Php/Home/UploadFile/upVoiceFileAjax",
        data: {
          "upfile": UploadFileInfo(
              file, file.path, contentType: ContentType.binary),
        },
        jsonProcessor: (s) {
          return AudioUploadInfo.fromJson(s);
        },
        dataType: DataType.JSON,
        formData: true
    );
  }
}
