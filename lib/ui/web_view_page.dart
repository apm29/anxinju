import 'package:ease_life/index.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {


  @override
  Widget build(BuildContext context) {
    var webviewPlugin = FlutterWebviewPlugin();
    return WebviewScaffold(
      url: "http://axj.ciih.net/#/",
      appBar: AppBar(
        title: Text("WebView"),
      ),
      withJavascript: true,
      withZoom: false,
      withLocalStorage: true,
      withLocalUrl: true,
      supportMultipleWindows: true,
      appCacheEnabled: true,
      allowFileURLs: true,
    );
  }
}
