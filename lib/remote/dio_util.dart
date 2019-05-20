import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ease_life/main.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:flutter/foundation.dart';

typedef DioErrorCallback = dynamic Function(DioError);
typedef ResponseCallback<T> = void Function(T);
typedef ValueCallback<T> = void Function(T value);
typedef ProcessRawJson<T> = T Function(dynamic);

const KEY_HEADER_TOKEN = "Authorization";
const VALUE_HEADER_CONTENT_TYPE = "application/x-www-form-urlencoded";
const VALUE_HEADER_CONTENT_TYPE_FORM = "multipart/form-data";
const BASE_URL = "http://axj.ciih.net/";
class DioUtil {
  Dio _dioInstance;
  bool inDebug = false;
  bool proxyHttp = false;
  bool printLog = true;

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

  init() {
    print('---------------dioInstance init------------------');
    _dioInstance = Dio(BaseOptions(
      method: "POST",
      connectTimeout: 20000,
      receiveTimeout: 55000,
      baseUrl: BASE_URL,
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
    if (printLog)
      _dioInstance.interceptors.add(InterceptorsWrapper(onRequest: (req) {
//      req.headers.update(KEY_HEADER_TOKEN, (old) {
//        return sharedPreferences.getString(PreferenceKeys.keyAuthorization);
//      });
        debugPrint("REQUEST:");
        debugPrint("===========================================");
        debugPrint("  Method:${req.method},Url:${req.baseUrl + req.path}");
        debugPrint("  Headers:${req.headers}");
        debugPrint("  QueryParams:${req.queryParameters}");
        print('=======>${req.data.runtimeType}');
        if (req.data.runtimeType != FormData) {
          debugPrint("    Data:${req.data}");
        }

        debugPrint("===========================================");
      }, onResponse: (resp) {
        debugPrint("REQUEST:");
        debugPrint("===========================================");
        debugPrint(
            "  Method:${resp.request.method},Url:${resp.request.baseUrl + resp.request.path}");
        debugPrint("  Headers:${resp.request.headers}");
        debugPrint("  QueryParams:${resp.request.queryParameters}");
        if (resp.request.data.runtimeType != FormData) {
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
      }, onError: (err) {
        debugPrint("ERROR:");
        debugPrint("===========================================");
        debugPrint("Message:${err.message}");
        debugPrint("Error:${err.error}");
        debugPrint("Type:${err.type}");
        debugPrint("Trace:${err.stackTrace}");
        debugPrint("===========================================");
      }));
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

  Future<BaseResponse<T>> postAsync<T>({
    String path,
    ProcessRawJson jsonProcessor,
    Map<String, dynamic> data,
    CancelToken cancelToken,
    DataType dataType = DataType.JSON,
    bool formData = false,
    bool addAuthorization = true,
  }) async {
    return _dioInstance
        .post<Map<String, dynamic>>(path,
            data: !formData ? data : FormData.from(data),
            options: RequestOptions(
                contentType: formData
                    ? ContentType.parse(VALUE_HEADER_CONTENT_TYPE_FORM)
                    : ContentType.parse(VALUE_HEADER_CONTENT_TYPE),
                headers: addAuthorization
                    ? {
                        KEY_HEADER_TOKEN: sharedPreferences
                            .getString(PreferenceKeys.keyAuthorization),
                      }
                    : {}),
            cancelToken: cancelToken)
        .then((Response<Map<String, dynamic>> response) {
      String _status, _text, _token;
      print('N${response.data.toString()}');
      dynamic _data;
      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        _status = response.data["status"];
        _text = response.data["text"];
        var _rawData = response.data['data'];
        if (dataType == DataType.LIST) {
          _data = response.data['data'] is String
              ? []
              : response.data['data'] ?? [];
        } else if (dataType == DataType.STRING) {
          _data = response.data['data'] is String
              ? response.data['data']
              : response.data['data'].toString();
        } else {
          _data = response.data['data'] is String
              ? <String, dynamic>{}
              : response.data['data'] ?? <String, dynamic>{};
        }
        _token = response.data['token'];
        BaseResponse<T> baseResponse = BaseResponse<T>(_status, _token, _text,
            jsonProcessor == null ? null : jsonProcessor(_data));
        //当请求失败的时候,吧data的String交给text,对后端的兼容...
        if (!baseResponse.success() && _rawData is String) {
          baseResponse.text = _rawData;
        } else if (baseResponse.success() && baseResponse.text.isEmpty) {
          baseResponse.text = "成功";
        }
        return baseResponse;
      } else {
        return BaseResponse<T>("0", null, "请求失败:${response.statusCode}", null);
      }
    }).catchError((Object error, StackTrace trace) {
      print(error);
      print(trace);
      return BaseResponse<T>("0", null,
          "请求失败:${error is DioError ? error.message : error.toString()}", null);
    });
  }

  Future<Response<String>> uploadFile(String key, String path) {
    var dio = Dio(BaseOptions(
      method: "POST",
      baseUrl: "http://zhdj.ciih.net/index.php",
    ));

    var data = FormData.from({
      "upfile":
          UploadFileInfo(File(path), path.substring(path.lastIndexOf("/")))
    });
    return dio.post<String>("/UploadFile/UploadFile/upFileAjax", data: data);
  }

  Future<List<Index>> getIndexJson() async {
    Response<String> response = await _dioInstance.get<String>(
      "/axj_menu.json",
      options: RequestOptions(
          contentType: ContentType.parse(VALUE_HEADER_CONTENT_TYPE),
          headers: {
            KEY_HEADER_TOKEN:
                sharedPreferences.getString(PreferenceKeys.keyAuthorization),
          }),
    );
    List<Index> res = [];
    if (response.statusCode == 200) {
      var jsonString = response.data;
      List list = json.decode(jsonString);
      var indexList = list.map((d) {
        return Index.fromJson(d);
      }).toList();
      res.addAll(indexList);
    }
    return res;
  }
}

enum DataType { STRING, LIST, JSON }
