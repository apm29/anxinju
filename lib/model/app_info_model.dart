import 'dart:io';

import 'package:ease_life/res/configs.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';

class AppInfoModel extends ChangeNotifier {
  String _versionCode;
  String _versionName;
  String _appName;

  String get appName => _appName??"安心居";

  set appName(String value) {
    if(value == _appName){
      return;
    }
    _appName = value;
    notifyListeners();
  }

  String get versionCode => _versionCode;

  set versionCode(String value) {
    if(value == _versionCode){
      return;
    }
    _versionCode = value;
    notifyListeners();
  }

  String get versionName => _versionName;

  set versionName(String value) {
    if(value == _versionName){
      return;
    }
    _versionName = value;
    notifyListeners();
  }

  AppInfoModel() {
    doGetDeviceInfo();
  }

  Future doGetDeviceInfo() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo deviceInfo = await DeviceInfoPlugin().androidInfo;
      print('$deviceInfo');
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
      print('$iosDeviceInfo');
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionName = packageInfo.version;
    versionCode = packageInfo.buildNumber;
    appName = packageInfo.appName;
  }

  String get appInfoString {
    return "$appName $versionName ($versionCode)${Configs.APP_DEBUG?"测试网":""}";
  }
}
