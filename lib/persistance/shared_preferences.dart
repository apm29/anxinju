import 'dart:convert';

import 'package:ease_life/main.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';

bool isLogin() {
  return userSp.getString(PreferenceKeys.keyUserInfo) != null;
}

bool isCertificated() {
  return (UserInfo.fromJson(json.decode(
                  userSp.getString(PreferenceKeys.keyUserInfo) ??
                      "{}"))
              ?.isCertification ??
          0) ==
      1;
}

bool isVerified() {
  var str = userSp.getString(PreferenceKeys.keyUserVerify) ?? "{}";
  return UserVerifyStatus.fromJson(json.decode(str))?.isVerified() ?? false;
}

bool hasHouse() {
  var str = userSp.getString(PreferenceKeys.keyUserVerify) ?? "{}";
  return UserVerifyStatus.fromJson(json.decode(str))?.hasHouse() ?? false;
}

String getToken() {
  return userSp.getString(PreferenceKeys.keyAuthorization);
}

int getCurrentDistrictId() {
  if (!isLogin()) {
    return null;
  }
  var jsonString =
      userSp.getString(PreferenceKeys.keyCurrentDistrict);
  if (jsonString == null || jsonString.isEmpty) {
    return null;
  }
  var jsonMap = json.decode(jsonString);
  var districtInfo = DistrictDetail.fromJson(jsonMap);
  return districtInfo.districtId;
}

List<Index> getIndexInfo() {
  var indexString = userSp.getString(PreferenceKeys.keyIndexInfo);
  print('$indexString');
  var decode = json.decode(indexString);
  if (decode is List) {
    return decode.map((s) {
      return Index.fromJson(s);
    }).toList();
  }
  return [];
}
