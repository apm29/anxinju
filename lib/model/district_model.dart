import 'dart:math';

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
        KEY_CURRENT_DISTRICT_INDEX, _allDistrictList.indexOf(_currentDistrict));
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
      } else if (_allDistrictList.length > 1) {
        _mCurrentDistrict = _allDistrictList[0];
      }
      return;
    });
  }

  String getDistrictName(int index) {
    return allDistricts[index].districtName;
  }

  String getDistrictAddress(int index) {
    return allDistricts[index].districtAddr;
  }

  String getDistrictPic(int index) {
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

  void selectCurrentDistrict(int index, BuildContext context) {
    _mCurrentDistrict = allDistricts[index];
    UserVerifyStatusModel.of(context).tryFetchHouseList(getCurrentDistrictId());
  }

  int getCurrentDistrictId() {
    return _mCurrentDistrict?.districtId;
  }

  int countOfDistricts() {
    return allDistricts?.length??0;
  }
}
