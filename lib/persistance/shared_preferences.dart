import 'dart:convert';

import 'package:ease_life/main.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';

bool isLogin() {
  return sp.getString(PreferenceKeys.keyUserInfo) != null;
}

bool isCertificated() {
  return (UserInfo.fromJson(json.decode(
                  sp.getString(PreferenceKeys.keyUserInfo) ??
                      "{}"))
              ?.isCertification ??
          0) ==
      1;
}

bool isVerified() {
  var str = sp.getString(PreferenceKeys.keyUserVerify) ?? "{}";
  return UserVerifyStatus.fromJson(json.decode(str))?.isVerified() ?? false;
}

bool hasHouse() {
  var str = sp.getString(PreferenceKeys.keyUserVerify) ?? "{}";
  return UserVerifyStatus.fromJson(json.decode(str))?.hasHouse() ?? false;
}

String getToken() {
  return sp.getString(PreferenceKeys.keyAuthorization);
}

int getCurrentDistrictId() {
  if (!isLogin()) {
    return null;
  }
  var jsonString =
      sp.getString(PreferenceKeys.keyCurrentDistrict);
  if (jsonString == null || jsonString.isEmpty) {
    return null;
  }
  var jsonMap = json.decode(jsonString);
  var districtInfo = DistrictDetail.fromJson(jsonMap);
  return districtInfo.districtId;
}

List<Index> getIndexInfo() {
  var indexString = sp.getString(PreferenceKeys.keyIndexInfo);
  print('$indexString');
  var decode = json.decode(indexString);
  if (decode is List) {
    return decode.map((s) {
      return Index.fromJson(s);
    }).toList();
  }
  return [];
}
