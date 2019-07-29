import 'package:ease_life/remote/api.dart';
import 'package:ease_life/remote/kf_dio_utils.dart';
import 'package:ease_life/res/configs.dart';
import 'package:ease_life/ui/dispute_mediation_page.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'base_response.dart';
import 'district_model.dart';

class MediationRunningModel extends ChangeNotifier {
  MediationRunningModel(BuildContext context) {
    getRunningMediation(context, true);
  }

  List<MediationRecord> _running = [];

  int page = 1;
  int pageNum = 20;

  List<MediationRecord> get running => _running;

  set running(List<MediationRecord> value) {
    _running = value;
    notifyListeners();
  }

  bool noMore = false;
  bool loading = false;

  Future getRunningMediation(BuildContext context, bool refresh) async {
    var districtId = DistrictModel.of(context).getCurrentDistrictId();
    loading = true;
    notifyListeners();
    if (refresh) {
      page = 1;
      _running.clear();
    }

    var kfResp = await ApiKf.getMediationList(
      districtId.toString(),
      page,
      pageNum,
      false,
      ChatGroupConfig.APP_ID,
    );
    if (kfResp.success) {
      running.addAll(kfResp.data.rows ?? []);
      noMore = kfResp.data.rows.length < pageNum;
      page += 1;
    }
    loading = false;
    print('$running');
    notifyListeners();
  }
}

class MediationHistoryModel extends ChangeNotifier {
  MediationHistoryModel(BuildContext context) {
    getHistoryMediation(context, true);
  }

  List<MediationRecord> _history = [];

  int page = 1;
  int pageNum = 20;

  List<MediationRecord> get history => _history;

  set history(List<MediationRecord> value) {
    _history = value;
    notifyListeners();
  }

  bool noMore = false;
  bool loading = false;

  Future getHistoryMediation(BuildContext context, bool refresh) async {
    var districtId = DistrictModel.of(context).getCurrentDistrictId();
    loading = true;
    notifyListeners();
    if (refresh) {
      page = 1;
      _history.clear();
    }
    var kfResp = await ApiKf.getMediationList(
      districtId.toString(),
      page,
      pageNum,
      true,
      ChatGroupConfig.APP_ID,
    );
    if (kfResp.success) {
      history.addAll(kfResp.data.rows ?? []);
      noMore = kfResp.data.rows.length < pageNum;
      page += 1;
    }
    loading = false;

    notifyListeners();
  }
}

class MediationApplyModel extends ChangeNotifier {
  MediationApplyModel(BuildContext context) {
    getApplyMediation(context, true);
  }

  List<MediationApply> _apply = [];

  int page = 1;
  int pageNum = 20;

  List<MediationApply> get apply => _apply;

  set apply(List<MediationApply> value) {
    _apply = value;
    notifyListeners();
  }

  bool noMore = false;
  bool loading = false;

  Future getApplyMediation(BuildContext context, bool refresh) async {
    var districtId = DistrictModel.of(context).getCurrentDistrictId();
    loading = true;
    notifyListeners();
    if (refresh) {
      page = 1;
      _apply.clear();
    }
    var kfResp = await ApiKf.getMediationApplyList(
      districtId.toString(),
      page,
      pageNum,
      ChatGroupConfig.APP_ID,
    );
    if (kfResp.success) {
      apply.addAll(kfResp.data.rows ?? []);
      noMore = kfResp.data.rows.length < pageNum;
      page += 1;
    }
    loading = false;

    notifyListeners();
  }

  static MediationApplyModel of(BuildContext context) {
    return Provider.of(context, listen: false);
  }
}

class MediationApplicationAddModel extends ChangeNotifier {
  MediationApplicationAddModel(BuildContext context) {
      getMediatorList();
      getHouseList(context);
  }

  String desc;
  String title;

  List<UserInfo> _mediatorList = [];
  UserInfo _currentMediator;
  List<AppendContent> appendContent = [];
  String chatUser;
  String startTime;
  String endTime;

  List<UserInfo> get mediatorList => _mediatorList;

  set mediatorList(List<UserInfo> value) {
    _mediatorList = value;
    notifyListeners();
  }

  UserInfo get currentMediator => _currentMediator;

  set currentMediator(UserInfo value) {
    if (_mediatorList == null || _mediatorList.length == 0) {
      getMediatorList();
    }
    _currentMediator = value;
    notifyListeners();
  }

  HouseDetail get currentHouse => _currentHouse;

  set currentHouse(HouseDetail value) {
    _currentHouse = value;
    notifyListeners();
  }

  Future getMediatorList() async {
    var resp = await Api.getMediatorUserList();
    if (resp.success) {
      mediatorList = resp.data;
    } else {
      showToast(resp.text);
    }
  }

  Future getMediationApplyDetail(int id) async {
    var resp =
        await ApiKf.mediationApplyDetailQuery(id.toString(), Configs.KF_APP_ID);
    if (resp.success) {
      _currentMediator = UserInfo(
          userId: resp.data.acceptUserId, userName: resp.data.acceptUserName);
      _currentHouse = HouseDetail(addr: resp.data.address);
      _images = resp.data.images;
      desc = resp.data.description;
      title = resp.data.title;
      desc = resp.data.description;
      appendContent = resp.data.appendContent;
      chatUser = resp.data.chatUser;
      startTime = resp.data.startTime;
      endTime = resp.data.endTime;
    } else {
      showToast("获取调解申请失败:${resp.text}");
    }
  }

  List<String> _images = [];
  List<HouseDetail> _houseList = [];

  HouseDetail _currentHouse;

  List<HouseDetail> get houseList => _houseList;

  set houseList(List<HouseDetail> value) {
    _houseList = value;
    notifyListeners();
  }

  List<String> get images => _images;

  set images(List<String> value) {
    _images = value;
    notifyListeners();
  }

  Future uploadImage(String path) async {
    Api.uploadPic(path).then((resp) {
      if (resp.success) {
        _images.add(resp.data.orginPicPath);
        notifyListeners();
      }
    });
  }

  void remove(String url) {
    images.remove(url);
    notifyListeners();
  }

  bool validate() {
    var name = currentMediator != null;
    if (!name) {
      showToast("调解人不可为空");
    }
    return name;
  }

  void reset() {
    _images = [];
    _currentMediator = null;
    title = null;
    desc = null;
  }

  void getHouseList(BuildContext context) async {
    var districtId = DistrictModel.of(context).getCurrentDistrictId();
    var resp = await Api.getMyHouse(districtId);
    if (resp.success) {
      houseList.clear();
      houseList.addAll(resp.data);
      notifyListeners();
    }
  }

  static MediationApplicationAddModel of(BuildContext context) {
    return Provider.of<MediationApplicationAddModel>(context, listen: false);
  }
}
