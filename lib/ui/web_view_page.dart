import 'package:ease_life/index.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  String _title = "";

  WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: WebView(
        onWebViewCreated: (WebViewController controller){
          _webViewController = controller;
        },
        initialUrl: "http://www.baidu.com",
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: Set.of([]),
        navigationDelegate: (NavigationRequest navigationRequest){
          //return NavigationDecision.prevent;//阻止跳转
          return NavigationDecision.navigate;//允许跳转
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        _webViewController.loadUrl("http://www.baidu.com");
      }),
    );
  }
}
