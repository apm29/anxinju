import 'dart:io';
import 'package:flutter/services.dart';

const platformChannel = const MethodChannel("anxinju.keyboard");

Future<void> showAndroidKeyboard() async {
  print('show keyboard');
  if (Platform.isAndroid) {
    int res = await platformChannel.invokeMethod("showKeyboard",1);
    print('$res');
  }
}

Future<void> hideAndroidKeyboard() async {
  print('show keyboard');
  if (Platform.isAndroid) {
    int res = await platformChannel.invokeMethod("showKeyboard",0);
    print('$res');
  }
}