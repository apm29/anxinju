import 'dart:convert';

import 'package:ease_life/main.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';

bool isLogin() {
  return sharedPreferences.getString(PreferenceKeys.keyUserInfo) != null;
}

String getToken(){
  return sharedPreferences.getString(PreferenceKeys.keyAuthorization);
}


int getCurrentSocietyId(){
  if(!isLogin()){
    return null;
  }
  var jsonString = sharedPreferences.getString(PreferenceKeys.keyCurrentDistrict);
  var jsonMap = json.decode(jsonString);
  var districtInfo = DistrictInfo.fromJson(jsonMap);
  return districtInfo.districtId;
}