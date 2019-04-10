import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef DioErrorCallback = dynamic Function(DioError);
typedef BaseResponseCallback<T> = void Function(BaseResponse<T>);
typedef ValueCallback<T> = void Function(T value);

class DioApplication {
  static Dio _dioInstance;
  static bool inDebug = true;
  static SharedPreferences spUtil;

  static Future<int> init() async {
    print('---------------dioInstance init------------------');
    spUtil = await SharedPreferences.getInstance();
    _dioInstance = Dio(BaseOptions(
      method: "POST",
      connectTimeout: 5000,
      receiveTimeout: 6000,
      baseUrl: inDebug ? "http://192.168.0.140:8080/permission/" : "",
//      headers: {
//        "Authorization": spUtil.getString(PreferenceKeys.keyAuthorization),
//        "content-type": "application/x-www-form-urlencoded"
//      },
    ));
    _dioInstance.interceptors.add(InterceptorsWrapper(onRequest: (req) {
      req.headers.update("Authorization", (old) {
        return spUtil.getString(PreferenceKeys.keyAuthorization);
      });
      print("""REQUEST:
        ===========================================
          Method:${req.method},Url:${req.baseUrl + req.path}
          Headers:${req.headers}
          QueryParams:${req.queryParameters}
          Data:${req.data}
        ===========================================
        """);
    }, onResponse: (resp) {
      print("""REQUEST:
        ===========================================
          Method:${resp.request.method},Url:${resp.request.baseUrl + resp.request.path}
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
    }, onError: (err) {
      print("""ERROR:
        ===========================================
        Message:${err.message}
        Error:${err.error}
        Type:${err.type}
        Trace:${err.stackTrace}
        ===========================================
        """);
    }));

    return 1;
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

  static void postSync<T>(
      String path,
      Map<String, String> data,
      BaseResponseCallback<T> success,
      ValueCallback<String> error,
      VoidCallback empty,
      {VoidCallback onComplete}) {
    _dioInstance
        .post(
      path,
      data: data,
      options: RequestOptions(
          contentType: ContentType.parse("application/x-www-form-urlencoded"),
          headers: {
            "Authorization": spUtil.getString(PreferenceKeys.keyAuthorization),
          }),
    )
        .then((response) {
      int code = response.statusCode;
      if (code >= 200 && code <= 300) {
        Map<String, dynamic> json = response.data;
        if (data == null) {
          empty();
        } else {
          BaseResponse<T> baseResponse = BaseResponse.fromJson(json);
          if (baseResponse.requestSuccess()) {
            if (baseResponse.token != null && baseResponse.token.isNotEmpty) {
              spUtil
                  .setString(
                      PreferenceKeys.keyAuthorization, baseResponse.token)
                  .then((success) {
                print('set token : $success ${baseResponse.token}');
              });
            }
            success(baseResponse);
          } else {
            error((baseResponse.data is String)
                ? baseResponse.data
                : baseResponse.text);
          }
        }
      } else {
        error("请求失败:$code");
      }
    }).catchError((Error err) {
      error(err.toString());
    }).whenComplete(() {
      if (onComplete != null) {
        onComplete();
      }
    });
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

}
