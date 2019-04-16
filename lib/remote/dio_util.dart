import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ease_life/main.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';

typedef DioErrorCallback = dynamic Function(DioError);
typedef ResponseCallback<T> = void Function(T);
typedef ValueCallback<T> = void Function(T value);
typedef ProcessRawJson<T> = T Function(Map<String, dynamic>);

const KEY_HEADER_TOKEN = "Authorization";
const VALUE_HEADER_CONTENT_TYPE = "application/x-www-form-urlencoded";

class DioUtil {
  Dio _dioInstance;
  bool inDebug = false;

  bool proxyHttp = true;

  DioUtil._() {
    init();
  }

  factory DioUtil() {
    return DioUtil.getInstance();
  }

  static DioUtil _dioApplication;

  static DioUtil getInstance() {
    if (_dioApplication == null) {
//      sp = await SharedPreferences.getInstance();
      _dioApplication = DioUtil._();
    }
    return _dioApplication;
  }

  Future<DioUtil> init() async {
    print('---------------dioInstance init------------------');
    _dioInstance = Dio(BaseOptions(
      method: "POST",
      connectTimeout: 5000,
      receiveTimeout: 15000,
      baseUrl: inDebug
          ? "http://api.junleizg.com.cn"
          : "http://192.168.0.140:8080/permission/",
    ));
    //设置代理
    if (proxyHttp)
      (_dioInstance.httpClientAdapter as DefaultHttpClientAdapter)
          .onHttpClientCreate = (client) {
        // config the http client
        client.findProxy = (uri) {
          //proxy all request to localhost:8888
          return "PROXY 192.168.1.181:8888";
        };
        // you can also create a new HttpClient to dio
        // return new HttpClient();
      };

    _dioInstance.interceptors.add(InterceptorsWrapper(onRequest: (req) {
      req.headers.update("Authorization", (old) {
        return sharedPreferences.getString(PreferenceKeys.keyAuthorization);
      });
      print("REQUEST:");
      print("===========================================");
      print("  Method:${req.method},Url:${req.baseUrl + req.path}");
      print("  Headers:${req.headers}");
      print("  QueryParams:${req.queryParameters}");
      print("  Data:${req.data}");
      print("===========================================");
    }, onResponse: (resp) {
      print("REQUEST:");
      print("===========================================");
      print(
          "  Method:${resp.request.method},Url:${resp.request.baseUrl + resp.request.path}");
      print("  Headers:${resp.request.headers}");
      print("  QueryParams:${resp.request.queryParameters}");
      print("  Data:${resp.request.data}");
      print("  -------------------------");
      print("  RESULT:");
      print("    Headers:${resp.headers}");
      print("    Data:${resp.data}");
      print("    Redirect:${resp.redirects}");
      print("    StatusCode:${resp.statusCode}");
      print("    Extras:${resp.extra}");
      print(" ===========================================");
    }, onError: (err) {
      print("ERROR:");
      print("===========================================");
      print("Message:${err.message}");
      print("Error:${err.error}");
      print("Type:${err.type}");
      print("Trace:${err.stackTrace}");
      print("===========================================");
    }));
    return this;
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
  ///

  Future<BaseResponse<T>> postAsync<T>(
      {String path,
      ProcessRawJson jsonProcessor,
      Map<String, String> data}) async {
    return _dioInstance
        .post<Map<String, dynamic>>(
      path,
      data: data,
      options: RequestOptions(
          contentType: ContentType.parse(VALUE_HEADER_CONTENT_TYPE),
          headers: {
            KEY_HEADER_TOKEN:
                sharedPreferences.getString(PreferenceKeys.keyAuthorization),
          }),
    )
        .then((Response<Map<String, dynamic>> response) {
      String _status, _text, _token;
      Map<String, dynamic> _data;
      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        _status = response.data["status"];
        _text = response.data["text"];
        _data = response.data['data'] is String ? {} : response.data['data'];
        return BaseResponse<T>(_status, _token, _text,
            jsonProcessor == null ? null : jsonProcessor(_data));
      } else {
        return BaseResponse<T>("0", null, "请求失败:${response.statusCode}", null);
      }
    }).catchError((Object error) {
      return BaseResponse<T>("0", null,
          "请求失败:${error is DioError ? error.message : error.toString()}", null);
    });
  }
}
