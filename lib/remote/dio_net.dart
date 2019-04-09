import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/persistance/shared_preferences.dart';

typedef DioErrorCallback = dynamic Function(DioError);

class DioApplication {
  static Dio _dioInstance;
  static bool inDebug = true;
  static SpUtil spUtil;

  static Future<int> init() async {
    spUtil = await SpUtil.getInstance();
    _dioInstance = Dio(BaseOptions(
      method: "POST",
      connectTimeout: 5000,
      receiveTimeout: 6000,
      baseUrl: inDebug ? "http://192.168.0.140:8080/permission/" : "",
      headers: {
        "Authorization": spUtil.getString(PreferenceKeys.keyAuthorization),
        "content-type": "application/x-www-form-urlencoded"
      },
    ));
    _dioInstance.interceptors.add(InterceptorsWrapper(
      onRequest: (req){
        print("""REQUEST:
        ===========================================
          Method:${req.method},Url:${req.baseUrl+req.path}
          Headers:${req.headers}
          QueryParams:${req.queryParameters}
          Data:${req.data}
        ===========================================
        """);
      },
      onResponse: (resp){
        print("""REQUEST:
        ===========================================
          Method:${resp.request.method},Url:${resp.request.baseUrl+resp.request.path}
          Headers:${resp.request.headers}
          QueryParams:${resp.request.queryParameters}
          Data:${resp.request.data}
          -------------------------
          RESULT:
            Headers:${resp.headers}
            Data:${resp.data}
            Redirect:${resp.redirects}
            StatusCode:${resp.statusCode}
            Extras:${resp.extra}
         ===========================================   
            
        """);
      },
      onError: (err){
        print("""ERROR:
        ===========================================
        Message:${err.message}
        Error:${err.error}
        Type:${err.type}
        Trace:${err.stackTrace}
        ===========================================
        """);
      }
    ));

    return 1;
  }

  ///
  /// {
  ///    "status": "1",
  ///    "data": {},
  ///    "token": "",
  ///    "text": ""
  /// }
  ///
  static Future<Response<Map>> sendSms(String mobile,
      {DioErrorCallback onError, VoidCallback onComplete}) {
    return post({
      "mobile": mobile,
    }, "/user/getVerifyCode",onError: onError,onComplete: onComplete);
  }

  static Future<Response<Map>> register(
      String mobile, String userName, password, code,
      {CancelToken cancelToken,
      ProgressCallback sendProgress,
      receiveProgress}) {
    return post({
      "mobile": mobile,
      "userName": userName,
      "password": password,
      "code": code,
    }, "/register",
        cancelToken: cancelToken,
        sendProgress: sendProgress,
        receiveProgress: receiveProgress);
  }

  static Future<Response<Map>> post(Map<String, String> formData, String path,
      {CancelToken cancelToken,
      ProgressCallback sendProgress,
      receiveProgress,
      DioErrorCallback onError,
      VoidCallback onComplete}) async {
    if (_dioInstance == null) {
      await init();
    }
    try {
      return await _dioInstance.post(path,
          data: formData,
          options: RequestOptions(
            contentType: ContentType.parse("application/x-www-form-urlencoded"),
          ),
          cancelToken: cancelToken,
          onSendProgress: sendProgress,
          onReceiveProgress: receiveProgress);
    } on DioError catch (e) {
      print(e);
      if (onError != null) {
        onError(e);
      }
      throw e;
    } finally {
      if (onComplete != null) {
        onComplete();
      }
    }
  }

  ///
  /// {
  /// "status": "1",
  /// "data": {
  ///   "userInfo": {
  ///     "userId": "15547121604619016242",
  ///     "userName": "apm29",
  ///     "mobile": "17376508275",
  ///     "isCertification": 0
  ///   }
  /// },
  /// "token": "eyJhbGciOiJIUzI1NiJ9.eyJhbnhpbmp1IjoiMTU1NDcxMjE2MDQ2MTkwMTYyNDIiLCJjcmVhdGVkIjoxNTU0NzEzNjMwOTY0LCJleHAiOjE5ODY3MTM2MzB9.WRVxO1U8mV-EDriA2hh71XFEDUy9rMVBTUau6fTENL8",
  /// "text": ""
  /// }
  ///
  static Future<Response<Map>> login(String userName, String password,
      {DioErrorCallback onError, VoidCallback onComplete}) async {
    var response = await post(
        {"userName": userName, "password": password}, "/login",
        onError: onError, onComplete: onComplete);
    return response;
  }

  static bool invalidateStatus(Response<Map> response) {
    return response.data["status"] == "1";
  }

  static Future<Response<Map>> fastLogin(String mobile, String code,
      {DioErrorCallback onError, VoidCallback onComplete}) async {
    var response = await post(
        {"mobile": mobile, "verifyCode": code}, "/fastLogin",
        onError: onError, onComplete: onComplete);
    return response;
  }

}
