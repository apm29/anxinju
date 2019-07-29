import 'dart:math';

import 'package:ease_life/model/announcement_model.dart';
import 'package:ease_life/model/main_index_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:oktoast/oktoast.dart';

class DistrictModel extends ChangeNotifier {
  List<DistrictDetail> _allDistrictList = [];

  List<DistrictDetail> get allDistricts => _allDistrictList;

  bool get hasData => allDistricts != null && allDistricts.isNotEmpty;

  set allDistricts(List<DistrictDetail> newValue) {
    if (listEquals(newValue, _allDistrictList)) {
      return;
    }
    _allDistrictList = newValue;
    notifyListeners();
  }

  int randomId = 0;
  DistrictDetail _currentDistrict;

  DistrictDetail get _mCurrentDistrict => _currentDistrict;

  set _mCurrentDistrict(DistrictDetail newValue) {
    var old = _currentDistrict;
    if (newValue == _currentDistrict) {
      return;
    }
    _currentDistrict = newValue;
    userSp.setInt(
      KEY_CURRENT_DISTRICT_INDEX,
      _allDistrictList.indexOf(_currentDistrict),
    );
    if (old != null) {
      showToast("切换小区成功 ${_currentDistrict.districtName}",
          dismissOtherToast: true);
    }
    notifyListeners();
  }

  DistrictModel() {
    tryFetchCurrentDistricts();
  }

  Future tryFetchCurrentDistricts() async {
    return Api.findAllDistrict().then((resp) {
      if (resp.success) {
        allDistricts = resp.data;
      } else {
        showToast(resp.text);
      }
      var index = userSp.getInt(KEY_CURRENT_DISTRICT_INDEX) ?? 0;
      if (_allDistrictList.length > index && index >= 0) {
        _mCurrentDistrict = _allDistrictList[index];
      } else if (_allDistrictList.length >= 1) {
        _mCurrentDistrict = _allDistrictList[0];
      }
      notifyListeners();
      return;
    }).then((_){
      tryFetchHouseList(getCurrentDistrictId());
    });
  }

  String getDistrictName(int index) {
    return allDistricts[index].districtName;
  }

  String getDistrictAddress(int index) {
    return allDistricts[index].districtAddr;
  }

  String getDistrictPic(int index) {
    if(index<0||index>=allDistricts.length){
      return "http://files.ciih.net/M00/07/2B/wKjIo10VonaAVHnyACnnGqMJ8mQ375.png";
    }
    var pic = allDistricts[index]?.districtPic;
    return (pic == null || pic.isEmpty)
        ? "http://files.ciih.net/M00/07/2B/wKjIo10VonaAVHnyACnnGqMJ8mQ375.png"
        : pic;
  }

  int getCurrentDistrictIndex() {
    return allDistricts.indexOf(_mCurrentDistrict);
  }

  static DistrictModel of(BuildContext context) {
    return Provider.of<DistrictModel>(context, listen: false);
  }

  String getCurrentDistrictName({String ifError = "获取小区列表失败"}) {
    return _mCurrentDistrict?.districtName ?? ifError;
  }

  isSelected(int index) {
    return _mCurrentDistrict == allDistricts[index];
  }

  Future selectCurrentDistrict(int index, BuildContext context) async {
    _mCurrentDistrict = allDistricts[index];
    await tryFetchHouseList(getCurrentDistrictId());
    await UserModel.of(context).tryFetchUserInfoAndLogin();
    await UserVerifyStatusModel.of(context).tryFetchVerifyStatus();
    await MainIndexModel.of(context).tryGetCurrentLocation();
    await UserRoleModel.of(context).tryFetchUserRoleTypes(context,dispatchUser: false);
  }

  int getCurrentDistrictId() {
    return _mCurrentDistrict?.districtId;
  }

  int countOfDistricts() {
    return allDistricts?.length ?? 0;
  }

  List<HouseDetail> _housesInCurrentDistrict;

  List<HouseDetail> get housesInCurrentDistrict => _housesInCurrentDistrict;

  set housesInCurrentDistrict(List<HouseDetail> value) {
    if (listEquals(_housesInCurrentDistrict, value)) {
      return;
    }
    _housesInCurrentDistrict = value;
    notifyListeners();
  }

  ///身份证名下有房,或者当前小区有房子接纳user为成员
  bool hasHouse() {
    return (housesInCurrentDistrict != null &&
        housesInCurrentDistrict.length > 0);
  }

  Future tryFetchHouseList(int districtId) {
    return Api.getMyHouse(districtId).then((resp) {
      if (resp.success) {
        housesInCurrentDistrict = resp.data;
      }
      return;
    });
  }
}
