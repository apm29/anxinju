import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ease_life/model/base_response.dart';
import '../index.dart';
import 'dio_util.dart';
import 'kf_dio_utils.dart';

class Api {
  static CancelToken defaultToken = CancelToken();

  static Future<BaseResponse<UserInfoWrapper>> login(
      String userName, String password,
      {CancelToken cancelToken}) async {
    return DioUtil().postAsync<UserInfoWrapper>(
      path: "/permission/login",
      jsonProcessor: (json) => UserInfoWrapper.fromJson(json),
      data: {
        "userName": userName,
        "password": password,
      },
      desc: "登录",
      cancelToken: cancelToken,
    );
  }

  static Future<BaseResponse<UserInfoWrapper>> fastLogin(
      String mobile, String verifyCode,
      {CancelToken cancelToken}) async {
    return DioUtil().postAsync<UserInfoWrapper>(
      path: "/permission/fastLogin",
      jsonProcessor: (json) => UserInfoWrapper.fromJson(json),
      data: {
        "mobile": mobile,
        "verifyCode": verifyCode,
      },
      desc: "登录",
      cancelToken: cancelToken,
    );
  }

  static Future<BaseResponse<UserInfo>> getUserInfo(
      {CancelToken cancelToken}) async {
    return DioUtil().postAsync<UserInfo>(
      path: "/permission/user/getUserInfo",
      jsonProcessor: (json) => UserInfo.fromJson(json),
      desc: "获取用户信息",
      cancelToken: cancelToken,
    );
  }

  ///type  0 注册 ,其他登录
  static Future<BaseResponse<Object>> sendSms(String mobile, int type,
      {CancelToken cancelToken}) async {
    return DioUtil().postAsync<Object>(
        path: "/permission/user/getVerifyCode",
        jsonProcessor: (dynamic json) => null,
        data: {"mobile": mobile, "type": type},
        desc: "发送短信",
        cancelToken: cancelToken);
  }

  static register(
      String mobile, String smsCode, String password, String userName) async {
    return DioUtil().postAsync<Object>(
      path: "/permission/user/register",
      jsonProcessor: (dynamic json) => null,
      data: {
        "userName": userName,
        "mobile": mobile,
        "password": password,
        "code": smsCode,
      },
      desc: "注册",
    );
  }

  static Future<BaseResponse<List<DistrictDetail>>> findAllDistrict() async {
    BaseResponse<List<DistrictDetail>> baseResponse =
        await DioUtil().postAsync<List<DistrictDetail>>(
            path: "/business/district/findDistrictInfo",
            jsonProcessor: (dynamic json) {
              if (json is List) {
                return json.map((j) {
                  return DistrictDetail.fromJson(j);
                }).toList();
              }
              return null;
            },
            data: {},
            desc: "获取小区列表",
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
      data: {"photo": imageUrl, "idCard": idCard},
      desc: "验证用户身份",
    );
  }

  static Future<BaseResponse<UserVerifyInfo>> verify(
      String imageUrl, String idCard, bool isAgain) async {
    return await DioUtil().postAsync(
      path: "/permission/userCertification/verify",
      jsonProcessor: (j) {
        return UserVerifyInfo.fromJson(j);
      },
      data: {
        "photo": imageUrl,
        "idCard": idCard,
        "isAgain": isAgain ? 1 : 0,
      },
      desc: "验证用户身份",
    );
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
      desc: "获取用户详情",
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
    } else if (myName != null) {
      dataMap["myName"] = myName;
    } else if (sex != null) {
      dataMap["sex"] = sex;
    } else if (phone != null) {
      dataMap["phone"] = phone;
    } else if (nickName != null) {
      dataMap["nickName"] = nickName;
    } else if (avatar != null) {
      dataMap["avatar"] = avatar;
    } else if (idCard != null) {
      dataMap["idCard"] = idCard;
    }
    return await DioUtil().postAsync(
      path: "/permission/userDetail/saveUserDetail",
      data: dataMap,
      desc: "保存用户信息",
    );
  }

  static Future<BaseResponse> saveUserDetailByMap(Map dataMap) async {
    return await DioUtil().postAsync(
      path: "/permission/userDetail/saveUserDetail",
      data: dataMap,
      desc: "保存用户信息",
    );
  }

  static Future<BaseResponse<FileDetail>> uploadFile(String path) async {
    var baseResponse = await DioUtil().postAsync<FileDetail>(
      path: "/business/upload/uploadFile",
      data: {"file": UploadFileInfo(File(path), "file")},
      jsonProcessor: (s) => FileDetail.fromJson(s),
      dataType: DataType.JSON,
      formData: true,
      desc: "上传文件",
    );
    return baseResponse;
  }

  static Future<BaseResponse<ImageDetail>> uploadPic(String path,
      {ProgressCallback onSendProgress}) async {
    print('file path : $path');
    var file = File(path);
    var baseResponse = await DioUtil().postAsync<ImageDetail>(
        path: "/business/upload/uploadPic",
        data: {"pic": UploadFileInfo(file, file.path)},
        jsonProcessor: (s) => ImageDetail.fromJson(s),
        dataType: DataType.JSON,
        formData: true,
        desc: "上传图片",
        onSendProgress: onSendProgress);
    return baseResponse;
  }

  static Future<BaseResponse<List<AnnouncementType>>> getAllNoticeType() async {
    return DioUtil().postAsync(
      path: "/business/noticeDict/getAllType",
      jsonProcessor: (json) {
        if (json is List) {
          return json.map((j) {
            return AnnouncementType.fromJson(j);
          }).toList();
        }
        return null;
      },
      dataType: DataType.LIST,
      desc: "获取通知公告类型",
    );
  }

  static Future<BaseResponse<List<Announcement>>> getNewNotice(
      List<AnnouncementType> list) async {
    return DioUtil().postAsync(
      path: "/business/notice/getAllNewNotice",
      jsonProcessor: (json) {
        if (json is List) {
          return json.map((j) {
            return Announcement.fromJson(j);
          }).toList();
        }
        return null;
      },
      data: {
        "noticeType": (list ?? [])
            .map((notice) {
              return notice.typeId;
            })
            .toList()
            .join(",")
      },
      desc: "获取通知公告",
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
      data: {"userId": userId},
      desc: "获取用户类型",
    );
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
      data: {"districtId": districtId},
      desc: "获取建筑列表",
    );
  }

  static Future<BaseResponse<List<String>>> getUnits(
      int districtId, String building) async {
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
      },
      desc: "获取单元列表",
    );
  }

  static Future<BaseResponse<List<String>>> getRooms(
      int districtId, String building, String unit) async {
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
      },
      desc: "获取房间列表",
    );
  }

  static Future<BaseResponse> applyMember(
      String address, int districtId, String name) async {
    return DioUtil().postAsync(
      path: "/business/member/applyMember",
      data: {
        "districtId": districtId,
        "addr": address,
        "name": name,
      },
      desc: "申请成为成员",
    );
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
      desc: "获取当前小区房屋列表",
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
      data: {},
      desc: "确认用户类型",
    );
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
      data: map,
      desc: "获取申请列表",
    );
  }

  static Future<BaseResponse> faceCompare(String imageBase64, String idCard) {
    return DioUtil().postAsync(
      path: "/facecompare/compare/",
      data: {"idNo": idCard, "imageBase64Str": imageBase64},
    );
  }

  static Future<BaseResponse<UserVerifyStatus>> getUserVerify() {
    return DioUtil().postAsync(
      path: "/permission/userCertification/getMyVerify",
      jsonProcessor: (s) {
        return UserVerifyStatus.fromJson(s);
      },
      desc: "获取用户验证状态",
    );
  }

  static Future<BaseResponse<List<NotificationMessage>>> getNotificationMessage(
      int page, int rows) {
    return DioUtil().postAsync(
      path: "/business/MessageCenter/getMyMessage",
      data: {
        "page": page,
        "rows": rows,
      },
      jsonProcessor: (s) {
        if (s is List) {
          return s.map((json) {
            return NotificationMessage.fromJson(json);
          }).toList();
        }
        return [];
      },
      dataType: DataType.LIST,
      desc: "获取用户通知",
    );
  }

  static Future<BaseResponse<List<UserInfo>>> getMediatorUserList() {
    return DioUtil().postAsync(
      path: "/permission/UserRole/findUserRole",
      data: {"roleCode": "20"},
      jsonProcessor: (s) {
        if (s is List) {
          return s.map((json) {
            return UserInfo.fromJson(json);
          }).toList();
        }
        return [];
      },
      dataType: DataType.LIST,
      desc: "获取调解员列表",
    );
  }
}

class ApiKf {
  static Future<BaseResponse<AudioUploadInfo>> uploadAudio(File file) async {
    return DioUtil().postAsync(
      path: "/Php/Home/UploadFile/upVoiceFileAjax",
      data: {
        "upfile":
            UploadFileInfo(file, file.path, contentType: ContentType.binary),
      },
      jsonProcessor: (s) {
        return AudioUploadInfo.fromJson(s);
      },
      dataType: DataType.JSON,
      formData: true,
      desc: "上传音频",
    );
  }

  static Future<KFBaseResp<MediationMessagePageData>> getMediationChatLog(
    String districtId,
    int page,
    int pageNum,
    String cAppId,
    String chatRoomId,
  ) async {
    return KfDioUtil().post(
      "/admin/custRoomApi/roomChatLog",
      processor: (s) {
        return MediationMessagePageData.fromJson(s);
      },
      formData: {
        "district_id": districtId,
        "page": page,
        "pagenum": pageNum,
        "cAppId": cAppId,
        "chatroom_id": chatRoomId,
      },
    );
  }

  static Future<KFBaseResp<MediationRecordPageData>> getMediationList(
    String districtId,
    int page,
    int pageNum,
    bool completedMediation,
    String cAppId,
  ) async {
    return KfDioUtil().post(
      "/admin/custRoomApi/roomLogCustlist",
      processor: (s) {
        return MediationRecordPageData.fromJson(s);
      },
      formData: {
        "district_id": districtId,
        "page": page,
        "pagenum": pageNum,
        "isfinish": completedMediation ? 1 : 0,
        "cAppId": cAppId,
      },
    );
  }

  static Future<KFBaseResp<MediationApplyPageData>> getMediationApplyList(
    String districtId,
    int page,
    int pageNum,
    String cAppId,
  ) async {
    return KfDioUtil().post(
      "/admin/custRoomApi/applyMediateCustList",
      processor: (s) {
        return MediationApplyPageData.fromJson(s);
      },
      formData: {
        "district_id": districtId,
        "page": page,
        "pagenum": pageNum,
        "cAppId": cAppId,
      },
    );
  }

  static Future<KFBaseResp> mediationApply(
    String districtId,
    String cAppId,
    String acceptUserName,
    String acceptUserId,
    String nickName,
    String title,
    String description,
    String address,
    List<String> images,
  ) async {
    return KfDioUtil().post(
      "/admin/custRoomApi/applyMediateAdd",
      processor: (s) {
        return null;
      },
      formData: {
        "district_id": districtId,
        "accept_user_name": acceptUserName,
        "accept_user_id": acceptUserId,
        "accept_nick_name": nickName,
        "cAppId": cAppId,
        "title": title,

        "description": description,
        "address": address,
        "images": images,
      },
    );
  }

  static Future<KFBaseResp> mediationAppend(
    String mediationId,
    String cAppId,
    String description,
  ) async {
    return KfDioUtil().post(
      "/admin/Custroomapi/applyAppendContent",
      processor: (s) {
        return null;
      },
      formData: {
        "id": mediationId,
        "cAppId": cAppId,
        "append_content": description,
      },
    );
  }

  static Future<KFBaseResp<MediationApply>> mediationApplyDetailQuery(
    String mediationId,
    String cAppId,
  ) async {
    return KfDioUtil().post(
      "/admin/Custroomapi/applyMediateCustSearch",
      processor: (s) {
        if (s is List && s.length > 0) {
          return MediationApply.fromJson(s[0]);
        }
        return null;
      },
      formData: {
        "id": mediationId,
        "cAppId": cAppId,
      },
    );
  }

  static Future<KFBaseResp<MediationRunningStatus>> mediationChatRoomQuery(
    String chatRoomId,
    String cAppId,
  ) async {
    return KfDioUtil().post<MediationRunningStatus>(
      "/admin/custRoomApi/roomChatSingleSearch",
      processor: (s) {
        return MediationRunningStatus.fromJson(s);
      },
      formData: {
        "chatroom_id": chatRoomId,
        "cAppId": cAppId,
      },
    );
  }

  static Future<KFBaseResp<List<OnlineChatUser>>> onlineChatUserQuery(
    String districtId,
    String cAppId,
  ) async {
    return KfDioUtil().post(
      "/admin/custRoomApi/onLineUserInfo",
      processor: (s) {
        if (s is List) {
          return s.map((json) => OnlineChatUser.fromJson(json)).toList();
        } else {
          return [];
        }
      },
      formData: {
        "district_id": districtId,
        "cAppId": cAppId,
      },
    );
  }

  static Future<KFBaseResp<List<EmergencyHistoryMessage>>>
      propertyEmergencyHistoryMessagesQuery(
    int districtId,
    String cAppId,
    String userId,
    int page,
    int pageNum,
  ) async {
    return KfDioUtil().post(
      "/admin/custRoomApi/getChatLog",
      processor: (s) {
        if (s is List) {
          return s
              .map((json) => EmergencyHistoryMessage.fromJson(json))
              .toList();
        } else {
          return [];
        }
      },
      formData: {
        "district_id": districtId,
        "cAppId": cAppId,
        "user_id": userId,
        "page": page,
        "pagenum": pageNum,
      },
    );
  }

  static Future<KFBaseResp<List<EmergencyHistoryMessage>>>
      userEmergencyCallHistoryMessage(
    int districtId,
    String cAppId,
    String kfUserId,
    int page,
    int pageNum,
  ) async {
    return KfDioUtil().post(
      "/admin/custRoomApi/getChatLogCust",
      processor: (s) {
        print(s);
        if (s is List) {
          return s
              .map((json) => EmergencyHistoryMessage.fromJson(json))
              .toList();
        } else {
          return [];
        }
      },
      formData: {
        "district_id": districtId,
        "cAppId": cAppId,
        "user_id": kfUserId,
        "page": page,
        "pagenum": pageNum,
      },
    );
  }
}
