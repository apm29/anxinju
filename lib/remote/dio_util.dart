import 'package:ease_life/index.dart';
import 'package:dio/dio.dart';

typedef DioErrorCallback = dynamic Function(DioError);
typedef ResponseCallback<T> = void Function(T);
typedef ValueCallback<T> = void Function(T value);
typedef ProcessRawJson<T> = T Function(dynamic);

const KEY_HEADER_TOKEN = "Authorization";
const KEY_HEADER_REGISTRATION_ID = "RegistrationId";
const KEY_HEADER_DEVICE_TOKEN = "DeviceToken";
const VALUE_HEADER_CONTENT_TYPE = "application/x-www-form-urlencoded";
const VALUE_HEADER_CONTENT_TYPE_FORM = "multipart/form-data";
const BASE_URL = Configs.BaseUrl;

class DioUtil {
  Dio _dioInstance;
  bool inDebug = false;
  bool proxyHttp = false;
  bool printLog = false;

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
      connectTimeout: 15000,
      receiveTimeout: 20000,
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

  Future<BaseResponse<T>> postAsync<T>(
      {String path,
      ProcessRawJson jsonProcessor,
      Map<String, dynamic> data,
      CancelToken cancelToken,
      DataType dataType = DataType.JSON,
      bool formData = false,
      bool addAuthorization = true,
      String desc = "",
      ProgressCallback onSendProgress}) async {
    return _dioInstance
        .post<Map<String, dynamic>>(path,
            onSendProgress: onSendProgress,
            data: !formData ? data : FormData.from(data),
            options: RequestOptions(
                contentType: formData
                    ? ContentType.parse(VALUE_HEADER_CONTENT_TYPE_FORM)
                    : ContentType.parse(VALUE_HEADER_CONTENT_TYPE),
                headers: addAuthorization
                    ? {
                        KEY_HEADER_TOKEN: userSp.getString(KEY_TOKEN),
                        KEY_HEADER_REGISTRATION_ID:
                            userSp.getString(KEY_REGISTRATION_ID),
                        "isIOS": Platform.isIOS,
                        KEY_HEADER_DEVICE_TOKEN:
                            userSp.getString(KEY_DEVICE_TOKEN),
                      }
                    : {
                        KEY_HEADER_REGISTRATION_ID:
                            userSp.getString(KEY_REGISTRATION_ID),
                        "isIOS": Platform.isIOS,
                        KEY_HEADER_DEVICE_TOKEN:
                            userSp.getString(KEY_DEVICE_TOKEN),
                      }),
            cancelToken: cancelToken)
        .then((Response<Map<String, dynamic>> response) {
      debugPrint("$BASE_URL$path");
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String prettyStr = encoder.convert(response.data);
      debugPrint(prettyStr);
      String _status, _text, _token;
      dynamic _data;
      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        _status = response.data["status"];
        _text = response.data["text"];
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
        //if (!baseResponse.success && _rawData is String) {
        //  baseResponse.text = _rawData;
        if (baseResponse.success &&
            (baseResponse.text == null || baseResponse.text.isEmpty)) {
          baseResponse.text = "成功";
        }
        return baseResponse;
      } else {
        return BaseResponse<T>(
            "0", null, "$desc 请求失败:${response.statusCode}", null);
      }
    }).catchError((Object error, StackTrace trace) {
      debugPrint(error.toString());
      return BaseResponse<T>(
          "0", null, "$desc 请求失败:${getErrorHint(error)}", null);
    });
  }

  String getErrorHint(Object error) {
    String errMessage;
    if (error is DioError && error.error != null) {
      switch (error.error.runtimeType) {
        case FormatException:
          errMessage = "服务器响应格式错误";
          break;
        default:
          errMessage = error.message;
      }
    } else if (error is DioError) {
      errMessage = error.message.toString();
    }
    return error is DioError ? (errMessage) : error.toString();
  }

  Future<List<Index>> getIndexJson() async {
    List<Index> res = [];
    try {
      Response<String> response = await _dioInstance.get<String>(
        "/axj_menu.json",
        options: RequestOptions(
          contentType: ContentType.parse(VALUE_HEADER_CONTENT_TYPE),
        ),
      );
      if (response.statusCode == 200) {
        var jsonString = response.data;
        List list = json.decode(jsonString);
        var indexList = list.map((d) {
          return Index.fromJson(d);
        }).toList();
        res.addAll(indexList);
      }
    } catch (e) {
      print(e);
    }
    return res;
  }

  void downloadFile(String apkUrl, Function onProgress) async {
    var status = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (status == PermissionStatus.granted) {
      await _doDownload(apkUrl, onProgress);
    } else {
      var map = await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);
      if (map[PermissionGroup.storage] == PermissionStatus.granted) {
        await _doDownload(apkUrl, onProgress);
      }
    }
  }

  Future _doDownload(String apkUrl, Function onProgress) async {
    var directory = await getTemporaryDirectory();
    File savePath = File("${directory.path}/app.apk");
    if (!await savePath.exists()) {
      savePath.create(recursive: true);
    }
    _dioInstance.download(apkUrl, savePath.path,
        onReceiveProgress: (count, total) {
      onProgress(count, total, savePath.path);
    });
  }
}

enum DataType { STRING, LIST, JSON }
