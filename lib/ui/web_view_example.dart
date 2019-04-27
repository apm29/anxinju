import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:convert/convert.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ease_life/index.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import 'login_page.dart';

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Navigation Delegate Example</title>
</head>
<body>
<script type="text/javascript">
    function showToast() {
        Toaster.postMessage(123);
    }
    
    function showSimpleDialog() {
        DialogMaker.postMessage(JSON.stringify({"title":"标题","content":"内容"}));
    }
    
    function selectFile(){
      Filer.postMessage('showToastMessage');
    }
    
    function showToastMessage(message){
      Toaster.postMessage(message);
    }
    
    function funcThreeParams(message1,message2,message3){
      Toaster.postMessage(message1+message2+message3);
    }
    
    function funcTwoParams(message1,message2){
      Toaster.postMessage(message1+message2);
    }
    
    function funcOneParams(message1){
      Toaster.postMessage(typeof message1);
      document.getElementsByTagName("button")[4].innerText = message1.field1
    }
    
    function getNativeToken(){
      
      var json = {
        "funcName":"getToken",
        "data":{
           "callbackName": "funcThreeParams",
            "backRoute":"/home" 
        }
      };
      
      var param = JSON.stringify(json);
      
      UserState.postMessage(param);
    }
    
    function showNativeDialog(){
      
      var json = {
        "funcName":"showDialog",
        "data":{
            "content":"内容",
            "title":"标题",
            "callbackName": "funcOneParams",//一个String参数的callback, 回调返回参数
            "callbackParam":{
              "field1":"123",
              "field2":"123"
              //....
            } //返回参数,任意指定
        }
      };
      
      var param = JSON.stringify(json);
      
      UserState.postMessage(param);
    }
    
    function showNativeToast(){
      
      var json = {
        "funcName":"showToast",
        "data":{
            "content":"内容",
        }
      };
      
      var param = JSON.stringify(json);
      
      UserState.postMessage(param);
    }
    
    function showNativeSnackbar(){
      
      var json = {
        "funcName":"showSnackbar",
        "data":{
            "content":"内容",
        }
      };
      
      var param = JSON.stringify(json);
      
      UserState.postMessage(param);
    }
    
    function callNativeUploadImage(){
      var json = {
        "funcName":"uploadImage",
        "data":{
            "callbackName": "funcTwoParams",//2个String参数的callback, 回调 url 和 原图片本地路径
        }
      };
      
      var param = JSON.stringify(json);
      
      UserState.postMessage(param);
    }

</script>
<h>------------------</h></br>
<button  onClick = "showToast()">Snackbar</button>

<button  onClick = "showSimpleDialog()">Dialog</button>

<button  onClick = "selectFile()">File</button>

<button  onClick = "getNativeToken()">Token</button>

<button  onClick = "showNativeDialog()">Dialog</button>

<button  onClick = "showNativeToast()">Toast</button>

<button  onClick = "showNativeSnackbar()">Snackbar</button>

<button  onClick = "callNativeUploadImage()">ImageUpload</button>

</body>
</html>
''';

class WebViewExample extends StatefulWidget {
  final String initUrl;

  WebViewExample(this.initUrl);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  WebViewController controller;

  final PublishSubject<String> titleController = PublishSubject();

  @override
  void dispose() {
    super.dispose();
    titleController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<Object>(
            stream: titleController.stream,
            builder: (context, snapshot) {
              return Text(snapshot.data ?? "");
            }),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[
          NavigationControls(_controller.future),
          SampleMenu(_controller.future),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.initUrl ?? 'https://flutter.dev',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
            controller = webViewController;
          },
          // ignore: prefer_collection_literals
          javascriptChannels: <JavascriptChannel>[
            _toasterJavascriptChannel(context),
            _dialogJavascriptChannel(context),
            _filerJavascriptChannel(context),
            _userJavascriptChannel(context)
          ].toSet(),
          navigationDelegate: (NavigationRequest request) {
            print('allowing navigation to $request');
//            if(!request.url.startsWith("http")){
//              return NavigationDecision.prevent;
//            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            controller
                .evaluateJavascript(
                    'document.getElementsByTagName("title")[0].innerText')
                .then((title) {
              print('$title');
              titleController.add(title.replaceAll('"', ""));
            });
          },
        );
      }),
      floatingActionButton: favoriteButton(),
    );
  }


  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
                content: Text(
              message.message,
              maxLines: 100,
            )),
          );
        });
  }

  /*
      {
        "funcName":"getToken",
        "data":{
           "callbackName": "funcThreeParams",//3个String参数的callback, token,当前小区 , 登录返回路由
            "backRoute":"http://www.baidu.com" //登录返回路由
        }
      }

       {
        "funcName":"showDialog",
        "data":{
            "content":"内容",
            "title":"标题",
            "callbackName": "funcOneParams",//一个String参数的callback, 回调返回参数
            "callBackParam":"xxx" //返回参数
        }
       }

       {
        "funcName":"uploadImage",
        "data":{
            "callbackName": "funcTwoParams",//2个String参数的callback, 回调缩略图url,原图local path
        }
       }
   */
  JavascriptChannel _userJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'UserState',
        onMessageReceived: (JavascriptMessage message) {
          Map<String, dynamic> jsonMap = json.decode(message.message);
          switch (jsonMap['funcName']) {
            case "getToken":
              doGetToken(jsonMap["data"]);
              break;
            case "showDialog":
              doShowSimpleDialog(jsonMap["data"]);
              break;
            case "showToast":
              Fluttertoast.showToast(msg: jsonMap["data"]["content"]);
              break;
            case "showSnackbar":
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                jsonMap["data"]["content"],
                maxLines: 100,
              )));
              break;
            case "uploadImage":
              doUploadImage(jsonMap['data']);
              break;
            default:
              break;
          }
        });
  }

  JavascriptChannel _filerJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Filer',
        onMessageReceived: (JavascriptMessage message) {
          compressAndUpload(message);
        });
  }

  void compressAndUpload(JavascriptMessage message) async {
    var directory = await getTemporaryDirectory();
    ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
      return FlutterImageCompress.compressWithFile(file.path,
          minWidth: 1080, minHeight: 768, quality: 60);
    }).then((listInt) {
      var file = File(directory.path + "/compressed.jpg");
      print('${file.absolute.path}');
      file.writeAsBytesSync(listInt, flush: true, mode: FileMode.write);
      return file;
    }).then((compressed) {
      print('${message.message}');
      DioUtil().uploadFile("upfile", compressed.absolute.path).then((resp) {
        var data = resp.data;
        Map<String, dynamic> jsonMap = json.decode(data);
        print('$data');
        controller.evaluateJavascript(
            '${message.message}("${jsonMap["data"]["url"]}")');
        controller.loadUrl(jsonMap["data"]["url"]);
      });
    });
  }

  JavascriptChannel _dialogJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'DialogMaker',
        onMessageReceived: (JavascriptMessage message) {
          Map<String, dynamic> map = json.decode(
            message.message,
          );
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text(map['content']),
                  title: Text(map['title']),
                );
              });
        });
  }

  Widget favoriteButton() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
            return FloatingActionButton(
              onPressed: () async {
                controller.data.evaluateJavascript(
                    "Toaster.postMessage('${await controller.data.currentUrl()}')");
              },
              child: const Icon(Icons.message),
            );
          }
          return Container();
        });
  }

  void doGetToken(dynamic data) {
    if (isLogin()) {
      var javascriptString =
          '${data["callbackName"]}("${getToken()}","${getCurrentSocietyId()}","${data["backRoute"]}")';
      print('$javascriptString');
      controller.evaluateJavascript(javascriptString);
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return LoginPage(
          backRoute: data["backRoute"],
        );
      })).then((backRoute) {
        var javascriptString =
            '${data["callbackName"]}("${getToken()}","${getCurrentSocietyId()}","${data["backRoute"]}")';

        controller.evaluateJavascript(javascriptString);
      });
    }
  }

  void doShowSimpleDialog(dynamic data) {
    String content = data['content'];
    String title = data['title'];
    String callbackName = data['callbackName'];
    dynamic callbackParam = data['callbackParam'];
    print('${callbackParam.runtimeType}');
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              OutlineButton(
                onPressed: () {
                  Navigator.of(context).pop(callbackParam);
                },
                child: Text("确定"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: Text("取消"),
              )
            ],
          );
        }).then((param) {
      controller.evaluateJavascript('$callbackName($param)');
    });
  }

  /*
   * {
      "callbackName": "funcOneParams",//一个String参数的callback, 回调返回参数
      }
   */
  void doUploadImage(Map<String, dynamic> jsData) async {
    var directory = await getTemporaryDirectory();
    var localCompressedPath = directory.path + "/compressed.jpg";
    String localPath;
    ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
      localPath = file.absolute.path;
      return FlutterImageCompress.compressWithFile(file.path,
          minWidth: 1080, minHeight: 768, quality: 60);
    }).then((listInt) {
      var file = File(localCompressedPath);
      print('${file.absolute.path}');
      file.writeAsBytesSync(listInt, flush: true, mode: FileMode.write);
      return file;
    }).then((compressed) {
      DioUtil().uploadFile("upfile", compressed.absolute.path).then((resp) {
        if (resp.statusCode == 200) {
          var data = resp.data;
          Map<String, dynamic> jsonMap = json.decode(data);
          var javascriptString =
              '${jsData['callbackName']}("${jsonMap['data']['url']}","$localPath")';
          print('$javascriptString');
          controller.evaluateJavascript(javascriptString);
        }
      });
    });
  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);

  final Future<WebViewController> controller;
  final CookieManager cookieManager = CookieManager();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<MenuOptions>(
          onSelected: (MenuOptions value) {
            switch (value) {
              case MenuOptions.showUserAgent:
                _onShowUserAgent(controller.data, context);
                break;
              case MenuOptions.listCookies:
                _onListCookies(controller.data, context);
                break;
              case MenuOptions.clearCookies:
                _onClearCookies(context);
                break;
              case MenuOptions.addToCache:
                _onAddToCache(controller.data, context);
                break;
              case MenuOptions.listCache:
                _onListCache(controller.data, context);
                break;
              case MenuOptions.clearCache:
                _onClearCache(controller.data, context);
                break;
              case MenuOptions.navigationDelegate:
                _onNavigationDelegateExample(controller.data, context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
                PopupMenuItem<MenuOptions>(
                  value: MenuOptions.showUserAgent,
                  child: const Text('Show user agent'),
                  enabled: controller.hasData,
                ),
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.listCookies,
                  child: Text('List cookies'),
                ),
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.clearCookies,
                  child: Text('Clear cookies'),
                ),
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.addToCache,
                  child: Text('Add to cache'),
                ),
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.listCache,
                  child: Text('List cache'),
                ),
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.clearCache,
                  child: Text('Clear cache'),
                ),
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.navigationDelegate,
                  child: Text('Example'),
                ),
              ],
        );
      },
    );
  }

  void _onShowUserAgent(
      WebViewController controller, BuildContext context) async {
    // Send a message with the user agent string to the Toaster JavaScript channel we registered
    // with the WebView.
    controller.evaluateJavascript(
        'Toaster.postMessage("User Agent: " + navigator.userAgent);');
  }

  void _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies =
        await controller.evaluateJavascript('document.cookie');
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }

  void _onAddToCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  void _onListCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript('caches.keys()'
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Toaster.postMessage(caches))');
  }

  void _onClearCache(WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text("Cache cleared."),
    ));
  }

  void _onClearCookies(BuildContext context) async {
    final bool hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
    controller.loadUrl('data:text/html;base64,$contentBase64');
//    var loadString = await rootBundle.loadString("images/example.html");
//    controller.loadUrl(Uri.dataFromString(loadString,
//            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
//        .toString());
  }

  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
        cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoBack()) {
                        controller.goBack();
                      } else {
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("No back history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoForward()) {
                        controller.goForward();
                      } else {
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("No forward history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}
