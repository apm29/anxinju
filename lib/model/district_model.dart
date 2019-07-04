import 'dart:math';

import 'package:ai_life/remote/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'base_response.dart';
import 'package:ai_life/persistence/const.dart';
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

  DistrictDetail get currentDistrict => _currentDistrict;

  set currentDistrict(DistrictDetail newValue) {
    var old = _currentDistrict;
    if (newValue == _currentDistrict) {
      return;
    }
    _currentDistrict = newValue;
    sp.setInt(
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
    return Api.getCurrentDistricts().then((resp) {
      if (resp.success) {
        allDistricts = resp.data;
      }
      var index = sp.getInt(KEY_CURRENT_DISTRICT_INDEX) ?? 0;
      if (_allDistrictList.length > index && index >= 0) {
        currentDistrict = _allDistrictList[index];
      } else if (_allDistrictList.length > 1) {
        currentDistrict = _allDistrictList[0];
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
    return allDistricts.indexOf(currentDistrict);
  }

  static DistrictModel of(BuildContext context) {
    return Provider.of<DistrictModel>(context, listen: false);
  }
}
