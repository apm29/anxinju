import 'package:webview_flutter/webview_flutter.dart';

var simpleBridge = JavascriptChannel(name: "nativeBridge", onMessageReceived: (message){

});