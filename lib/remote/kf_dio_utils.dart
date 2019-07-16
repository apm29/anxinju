import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ease_life/res/configs.dart';
import 'package:ease_life/ui/dispute_mediation_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';

typedef JsonProcessor<T> = T Function(dynamic json);

const KEY_HEADER_TOKEN = "Authorization";

class KfDioUtil {
  KfDioUtil._() {
    init();
  }

  static bool proxyHttp = false;
  static bool printLog = false;
  static KfDioUtil _instance;

  static KfDioUtil getInstance() {
    if (_instance == null) {
      _instance = KfDioUtil._();
    }
    return _instance;
  }

  factory KfDioUtil() {
    return getInstance();
  }

  Dio _dio;

  void init() {
    _dio = Dio(BaseOptions(
      method: "POST",
      connectTimeout: 10000,
      receiveTimeout: 20000,
      baseUrl: Configs.KFBaseUrl,
    ));
    //设置代理
    if (proxyHttp)
      (_dio.httpClientAdapter as DefaultHttpClientAdapter)
          .onHttpClientCreate = (client) {
        // config the http client
        client.findProxy = (uri) {
          //proxy all request to localhost:8888
          return "PROXY 192.168.1.181:8888";
        };
        // you can also create a new HttpClient to dio
        // return new HttpClient();
      };
    if (printLog)
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (req) {
            debugPrint("REQUEST:");
            debugPrint("===========================================");
            debugPrint("  Method:${req.method},Url:${req.baseUrl + req.path}");
            debugPrint("  Headers:${req.headers}");
            debugPrint("  QueryParams:${req.queryParameters}");
            print('=======>${req.data.runtimeType}');
            if (req.data.runtimeType != FormData) {
              debugPrint("    Data:${req.data}");
            }else{
              debugPrint("  Data:${req.data}");
            }

            debugPrint("===========================================");
          },
          onResponse: (resp) {
            debugPrint("REQUEST:");
            debugPrint("===========================================");
            debugPrint(
                "  Method:${resp.request.method},Url:${resp.request.baseUrl +
                    resp.request.path}");
            debugPrint("  Headers:${resp.request.headers}");
            debugPrint("  QueryParams:${resp.request.queryParameters}");
            if (resp.request.data.runtimeType != FormData) {
              debugPrint("  Data:${resp.request.data}");
            } else{
              debugPrint("  Data:${resp.request.data}");
            }
            debugPrint("  -------------------------");
            debugPrint("  RESULT:");
            debugPrint("    Headers:${resp.headers}");
            debugPrint("  Data:${resp.data}");
            debugPrint("    Redirect:${resp.redirects}");
            debugPrint("    StatusCode:${resp.statusCode}");
            debugPrint("    Extras:${resp.extra}");
            debugPrint(" ===========================================");
          },
          onError: (err) {
            debugPrint("ERROR:");
            debugPrint("===========================================");
            debugPrint("Message:${err.message}");
            debugPrint("Error:${err.error}");
            debugPrint("Type:${err.type}");
            debugPrint("Trace:${err.stackTrace}");
            debugPrint("===========================================");
          },
        ),
      );
  }

  Future<KFBaseResp<T>> post<T>(String path, {
    @required JsonProcessor<T> processor,
    Map<String, dynamic> formData,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
    ProgressCallback onSendProgress,
    bool showProgress = false,
    String loadingText,
    bool toastMsg = false,
  }) async {
    assert(!showProgress || loadingText != null);
    assert(processor != null);
    processor = processor ?? (dynamic raw) => null;
    formData = formData ?? {};
    toastMsg = toastMsg ?? false;
    cancelToken = cancelToken ?? CancelToken();
    onReceiveProgress = onReceiveProgress ??
            (count, total) {
          ///默认接收进度
        };
    onSendProgress = onSendProgress ??
            (count, total) {
          ///默认发送进度
        };
    print('$path');
    ToastFuture toastFuture;
    if (showProgress) {
      toastFuture = showLoadingWidget(loadingText);
    }
    return _dio
        .post(
      path,
      data: formData,
      options: RequestOptions(
        responseType: ResponseType.json,
        headers: {KEY_HEADER_TOKEN: userSp.getString(KEY_TOKEN)},
        contentType:ContentType.json,
      ),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    )
        .then((resp) {
      return resp.data;
    }).then((map) {
      String status = map["status"];
      String text = map["text"];
      String token = map["token"];
      dynamic _rawData = map["data"];
      T data = processor(_rawData);
      return KFBaseResp<T>(status, data, token, text);
    }).catchError((e, StackTrace s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      if (e is DioError) {
        showToast(e.message);
      }
      return KFBaseResp.error(message: e.toString(), data: null as T);
    }).then((resp) {
      toastFuture?.dismiss();
      //debugPrint(resp.toString());
      if (toastMsg) {
        showToast(resp.text);
      }
      return resp;
    });
  }

  ToastFuture showLoadingWidget(String loadingText) {
    return showToastWidget(
        AbsorbPointer(
          absorbing: true,
          child: Stack(
            children: <Widget>[
              ModalBarrier(
                dismissible: false,
                color: Color(0x33333333),
              ),
              Align(
                alignment: Alignment.center,
                child: Material(
                  type: MaterialType.card,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  elevation: 6,
                  color: Colors.deepPurpleAccent,
                  shadowColor: Colors.black,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          loadingText,
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        position: ToastPosition.center,
        textDirection: TextDirection.ltr,
        duration: Duration(seconds: 100));
  }
}

class KFBaseResp<T> {
  String status;
  T data;
  String token;
  String text;

  KFBaseResp(this.status, this.data, this.token, this.text);

  KFBaseResp.error({String message = "失败", T data}) {
    this.status = "0";
    this.data = null;
    this.token = null;
    this.text = message;
  }

  KFBaseResp.success({String message = "成功"}) {
    this.status = "1";
    this.data = null;
    this.token = null;
    this.text = message;
  }

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('{\r\n');
    sb.write("\"status\":\"$status\"");
    sb.write(",\r\n\"token\":$token");
    sb.write(",\r\n\"text\":\"$text\"");
    sb.write(",\r\n\"data\":\"$data\"");
    sb.write('\r\n}');
    return sb.toString();
  }

  bool get success => status == "1";
}

class MediationRecordPageData {
  List<MediationRecord> rows;
  String page;
  String pageNum;
  int total;

  MediationRecordPageData({this.rows, this.page, this.pageNum, this.total});

  MediationRecordPageData.fromJson(Map<String, dynamic> json) {
    if (json['rows'] != null) {
      rows = new List<MediationRecord>();
      json['rows'].forEach((v) {
        rows.add(new MediationRecord.fromJson(v));
      });
    }
    page = json['page'];
    pageNum = json['pagenum'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rows != null) {
      data['rows'] = this.rows.map((v) => v.toJson()).toList();
    }
    data['page'] = this.page;
    data['pagenum'] = this.pageNum;
    data['total'] = this.total;
    return data;
  }
}

class MediationRecord {
  int id;
  String chatRoomId;
  String userId;
  String userName;
  String userType;
  String content;
  String districtId;
  String appId;
  String kfId;
  String title;
  String result;
  String description;
  String applyId;
  String startTime;
  String endTime;
  String finished;

  MediationRecord({this.id,
    this.chatRoomId,
    this.userId,
    this.userName,
    this.userType,
    this.content,
    this.districtId,
    this.appId,
    this.kfId,
    this.title,
    this.result,
    this.description,
    this.applyId,
    this.startTime,
    this.endTime,
    this.finished});

  MediationRecord.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatRoomId = json['chatroom_id'];
    userId = json['user_id'];
    userName = json['user_name'];
    userType = json['user_type'];
    content = json['content'];
    districtId = json['district_id'];
    appId = json['app_id'];
    kfId = json['kf_id'];
    title = json['title'];
    result = json['result'];
    description = json['description'];
    applyId = json['apply_id'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    finished = json['isfinish'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['chatroom_id'] = this.chatRoomId;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['user_type'] = this.userType;
    data['content'] = this.content;
    data['district_id'] = this.districtId;
    data['app_id'] = this.appId;
    data['kf_id'] = this.kfId;
    data['title'] = this.title;
    data['result'] = this.result;
    data['description'] = this.description;
    data['apply_id'] = this.applyId;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['isfinish'] = this.finished;
    return data;
  }

  @override
  String toString() {
    return 'Rows{id: $id, chatRoomId: $chatRoomId, userId: $userId, userName: $userName, userType: $userType, content: $content, districtId: $districtId, appId: $appId, kfId: $kfId, title: $title, result: $result, description: $description, applyId: $applyId, startTime: $startTime, endTime: $endTime, finished: $finished}';
  }

  bool get mediationFinished => finished == '1';


}

class MediationMessagePageData {
  List<MediationMessage> rows;
  String page;
  String pageNum;
  int total;

  MediationMessagePageData({this.rows, this.page, this.pageNum, this.total});

  MediationMessagePageData.fromJson(Map<String, dynamic> json) {
    if (json['rows'] != null) {
      rows = new List<MediationMessage>();
      json['rows'].forEach((v) {
        rows.add(new MediationMessage.fromJson(v));
      });
    }
    page = json['page'];
    pageNum = json['pagenum'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rows != null) {
      data['rows'] = this.rows.map((v) => v.toJson()).toList();
    }
    data['page'] = this.page;
    data['pagenum'] = this.pageNum;
    data['total'] = this.total;
    return data;
  }
}

class MediationMessage {
  int id;
  String userId;
  String userName;
  String districtId;
  String appId;
  String content;
  String chatRoomId;
  String avatar;
  String timeLine;

  MediationMessage({this.id,
    this.userId,
    this.userName,
    this.districtId,
    this.appId,
    this.content,
    this.chatRoomId,
    this.avatar,
    this.timeLine});

  MediationMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    districtId = json['district_id'];
    appId = json['app_id'];
    content = json['content'];
    chatRoomId = json['chatroom_id'];
    avatar = json['avatar'];
    timeLine = json['time_line'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['district_id'] = this.districtId;
    data['app_id'] = this.appId;
    data['content'] = this.content;
    data['chatroom_id'] = this.chatRoomId;
    data['avatar'] = this.avatar;
    data['time_line'] = this.timeLine;
    return data;
  }

  ChatMessage toChatMessage() {
    return ChatMessage(
      code: 200,
      msg: "发送成功",
      messageType: TEXT_TYPE,
      data: Data(
        userId: userId,
        userName: userName,
        chatroomId: chatRoomId,
        content: content,
        avatar: avatar,
        time: timeLine,
        duration: 0,
      ),
    );
  }
}

class MediationApplyPageData {
  List<MediationApply> rows;
  String page;
  String pagenum;
  int total;

  MediationApplyPageData({this.rows, this.page, this.pagenum, this.total});

  MediationApplyPageData.fromJson(Map<String, dynamic> json) {
    if (json['rows'] != null) {
      rows = new List<MediationApply>();
      json['rows'].forEach((v) {
        rows.add(new MediationApply.fromJson(v));
      });
    }
    page = json['page'];
    pagenum = json['pagenum'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rows != null) {
      data['rows'] = this.rows.map((v) => v.toJson()).toList();
    }
    data['page'] = this.page;
    data['pagenum'] = this.pagenum;
    data['total'] = this.total;
    return data;
  }
}

class MediationApply {
  int id;
  String applyUserName;
  String applyUserId;
  String acceptUserName;
  String acceptUserId;
  String title;
  List<String> images;
  String description;
  String status;
  String districtId;
  String appId;
  String date;
  String address;

  MediationApply(
      {this.id,
        this.applyUserName,
        this.applyUserId,
        this.acceptUserName,
        this.acceptUserId,
        this.title,
        this.images,
        this.description,
        this.status,
        this.districtId,
        this.appId,
        this.date,
        this.address});

  MediationApply.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    applyUserName = json['apply_user_name'];
    applyUserId = json['apply_user_id'];
    acceptUserName = json['accept_user_name'];
    acceptUserId = json['accept_user_id'];
    title = json['title'];
    images = json['images'].cast<String>();
    description = json['description'];
    status = json['status'];
    districtId = json['district_id'];
    appId = json['app_id'];
    date = json['date'];
    address = json['address'];
  }

  static const List<Color> colorList = [
    Colors.redAccent,
    Colors.lightGreen,
    Colors.lightBlue,
    Colors.deepOrange,
  ];

  Color get statusColor {
    switch(status){
      case "1":
        return colorList[0];
      case "2":
        return colorList[1];
      case "3":
        return colorList[2];
      default:
        return colorList[3];
    }
  }

  String get statusString {
    switch(status){
      case "1":
        return "未处理";
      case "2":
        return "正在处理";
      case "3":
        return "已完成";
      default:
        return "未知状态";
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['apply_user_name'] = this.applyUserName;
    data['apply_user_id'] = this.applyUserId;
    data['accept_user_name'] = this.acceptUserName;
    data['accept_user_id'] = this.acceptUserId;
    data['title'] = this.title;
    data['images'] = this.images;
    data['description'] = this.description;
    data['status'] = this.status;
    data['district_id'] = this.districtId;
    data['app_id'] = this.appId;
    data['date'] = this.date;
    data['address'] = this.address;
    return data;
  }

  @override
  String toString() {
    return 'MediationApply{id: $id, applyUserName: $applyUserName, applyUserId: $applyUserId, acceptUserName: $acceptUserName, acceptUserId: $acceptUserId, title: $title, images: $images, description: $description, status: $status, districtId: $districtId, appId: $appId, date: $date, address: $address}';
  }


}


