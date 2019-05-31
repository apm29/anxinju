import 'dart:async';
import 'dart:convert';

//import 'package:amap_base_location/amap_base_location.dart';
//import 'package:amap_base/amap_base.dart';
import 'package:amap_base_location/amap_base_location.dart';
import 'package:ease_life/main.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/remote/dio_util.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

import '../index.dart';

//class BlocProvider extends InheritedWidget {
//  final UserBloc bloc = UserBloc();
//
//  BlocProvider({Key key, Widget child}) : super(key: key, child: child);
//
//  @override
//  bool updateShouldNotify(InheritedWidget oldWidget) {
//    return true;
//  }
//
//  static UserBloc of(BuildContext context) {
//    return (context.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider)
//        .bloc;
//  }
//}

abstract class BlocBase {
  void dispose();
}

class BlocProviders<T extends BlocBase> extends StatefulWidget {
  final Widget child;
  final T bloc;

  BlocProviders({Key key, @required this.child, @required this.bloc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BlocProviderState();
  }

  static T of<T extends BlocBase>(BuildContext context) {
    final type = typeOf<BlocProviders<T>>();
    BlocProviders<T> providers = context.ancestorWidgetOfExactType(type);
    return providers.bloc;
  }

  static Type typeOf<T>() => T;
}

class _BlocProviderState extends State<BlocProviders> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}

class ApplicationBloc extends BlocBase {
  @override
  void dispose() {
    _userInfoController.close();
    _districtInfoController.close();
    _homeIndexController.close();
    _mineIndexController.close();
    _noticeController.close();
    _noticeTypeController.close();
    _userTypeController.close();
    _controllerUserDetailData.close();
    _controllerMyHouseData.close();
  }

  ApplicationBloc() {
    _getCurrentUserAndNotify();
    _getCurrentDistrictAndNotify();
    getIndexInfo();
    getNoticeInfo();
    _requestLocationPermission();
    getUserTypes();
    getUserDetail();
  }

  void _getCurrentUserAndNotify() async {
    var userInfoStr = sharedPreferences.getString(PreferenceKeys.keyUserInfo);
    if (userInfoStr?.isNotEmpty == true) {
      _userInfoController.add(UserInfo.fromJson(json.decode(userInfoStr)));
    } else {
      _userInfoController.add(null);
    }
  }

  void login(UserInfo userInfo) {
    sharedPreferences.setString(
        PreferenceKeys.keyUserInfo, userInfo?.toString());
    _getCurrentUserAndNotify();
  }

  void saveToken(String token) {
    sharedPreferences.setString(
        PreferenceKeys.keyAuthorization, token?.toString());
  }

  void refreshMenuIndex(List<Index> indexInfo) {}

  BehaviorSubject<UserInfo> _userInfoController = BehaviorSubject();

  Observable<UserInfo> get currentUser => _userInfoController.stream;

  BehaviorSubject<DistrictInfo> _districtInfoController = BehaviorSubject();

  Observable<DistrictInfo> get currentDistrict =>
      _districtInfoController.stream;

  BehaviorSubject<Index> _homeIndexController = BehaviorSubject();
  BehaviorSubject<Index> _mineIndexController = BehaviorSubject();

  Observable<Index> get homeIndex => _homeIndexController.stream;

  Observable<Index> get mineIndex => _mineIndexController.stream;

  BehaviorSubject<List<NoticeDetail>> _noticeController = BehaviorSubject();
  BehaviorSubject<List<NoticeType>> _noticeTypeController = BehaviorSubject();

  Observable<List<NoticeDetail>> get homeNoticeStream =>
      _noticeController.stream;

  Observable<List<NoticeType>> get noticeTypeStream =>
      _noticeTypeController.stream;

  BehaviorSubject<List<UserType>> _userTypeController = BehaviorSubject();

  Observable<List<UserType>> get userTypeStream => _userTypeController.stream;

  PublishSubject<UserDetail> _controllerUserDetailData = PublishSubject();

  Observable<UserDetail> get userDetailStream =>
      _controllerUserDetailData.stream;

  PublishSubject<List<HouseDetail>> _controllerMyHouseData = PublishSubject();

  Observable<List<HouseDetail>> get myHouseStream =>
      _controllerMyHouseData.stream;

  /*
   * 退出登录:
   * SP清空 userInfo/ token
   * 登录体系以SP中的 userInfo 作为唯一标识
   */
  void logout() {
    sharedPreferences.setString(PreferenceKeys.keyUserInfo, null);
    sharedPreferences.setString(PreferenceKeys.keyAuthorization, null);
    _userInfoController.add(null);
  }

  void getUserTypes() {
    Api.getUserInfo().then((base) {
      if (base.success()) {
        _userInfoController.add(base.data);
      }
      return base.data.userId;
    }).then((userId) {
      print(userId);
      return Api.getUserType(userId);
    }).then((baseResp) {
      print('$baseResp');
      var data = baseResp.data[0];
      print(data);
      _userTypeController.add(baseResp.data);
    }).catchError((e, s) {
      print(e);
      print(s);
      _userTypeController.add([]);
    });
  }

  void getMyHouseList() {
    Api.getMyHouse(getCurrentDistrictId()).then((baseResp) {
      if (baseResp.success()) {
        _controllerMyHouseData.add(baseResp.data);
      } else {
        _controllerMyHouseData.addError(baseResp.text);
      }
    }).catchError((e, s) {
      _controllerMyHouseData.addError(e);
    });
  }

  /*
   * 优先取SP缓存的${Strings.districtClass}信息
   * 然后取后端返回的${Strings.districtClass}的第一个
   */
  void _getCurrentDistrictAndNotify() async {
    var source = sharedPreferences.getString(PreferenceKeys.keyCurrentDistrict);
    DistrictInfo districtInfo =
        source == null ? null : DistrictInfo.fromJson(json.decode(source));
    if (districtInfo == null) {
      BaseResponse<List<DistrictInfo>> baseResponse =
          await Api.findAllDistrict();
      //将取到的${Strings.districtClass}信息存入sp缓存
      sharedPreferences.setString(PreferenceKeys.keyCurrentDistrict,
          baseResponse.data.first.toString());
      _districtInfoController.add(baseResponse.data.first);
    } else {
      _districtInfoController.add(districtInfo);
    }
    getMyHouseList();
  }

  /*
   * 获取json map,标记主页按钮的去向url
   */
  void getIndexInfo() async {
    try {
      List<Index> list = await Api.getIndex();
      _homeIndexController
          .add(list.firstWhere((index) => index.area == "index"));
      _mineIndexController
          .add(list.firstWhere((index) => index.area == "mine"));
      var content = list.map((index){
        return index.toString();
      }).toList().join(",");
      sharedPreferences.setString(PreferenceKeys.keyIndexInfo,"[$content]");
      getMyHouseList();
    } catch (e,s) {
      print(e);
      print(s);
      Fluttertoast.showToast(msg: "获取网页索引失败");
      _homeIndexController.add(null);
      _mineIndexController.add(null);
    }
  }

  void setCurrentDistrict(DistrictInfo districtInfo) {
    //将取到的${Strings.districtClass}信息存入sp缓存
    sharedPreferences.setString(
        PreferenceKeys.keyCurrentDistrict, districtInfo.toString());
    _districtInfoController.add(districtInfo);
  }

  void _requestLocationPermission() async {
    var permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);
    if (permissionStatus != PermissionStatus.granted) {
      var status = await PermissionHandler()
          .requestPermissions([PermissionGroup.location]);
      if (status[PermissionGroup.location] == PermissionStatus.granted) {
        locationStream();
      }
    } else {
      locationStream();
    }
  }

  void locationStream() {
    AMapLocation()
        .startLocate(LocationClientOptions(interval: 20000))
        .listen((p) {
      //print(p.toString());
    });
  }

  void getNoticeInfo() {
    Api.getAllNoticeType().then((baseResp) {
      _noticeTypeController.add(baseResp.data);
      return Api.getNewNotice(baseResp.data);
    }).then((BaseResponse<List<NoticeDetail>> resp) {
      _noticeController.add(resp.data);
    }).catchError((e, s) {
      _noticeController.add(null);
    });
  }

  void getUserDetail() {
    Api.getUserDetail().then((baseResp) {
      if (baseResp.success()) {
        _controllerUserDetailData.add(baseResp.data);
      }
    }).catchError((Object e, StackTrace s) {
      _controllerUserDetailData.addError(e, s);
    });
  }
}

class LoginBloc extends BlocBase {
  @override
  void dispose() {}
}

class ContactsBloc extends BlocBase {
  BehaviorSubject<List<Contact>> _contactsController = BehaviorSubject();

  Observable<List<Contact>> get contactsStream => _contactsController.stream;

  @override
  void dispose() {
    _contactsController.close();
  }

  ContactsBloc() {
    getContactsAndNotify();
  }

  Future<void> getContactsAndNotify() async {
    var map = await PermissionHandler()
        .requestPermissions([PermissionGroup.contacts]);
    if (map[PermissionGroup.contacts] == PermissionStatus.granted) {
      var contacts = await ContactsService.getContacts();
      _contactsController.add(contacts.toList());
    }
    return null;
  }
}

class MainIndexBloc extends BlocBase {
  PublishSubject<int> _indexController = PublishSubject();

  Observable<int> get indexStream => _indexController.stream;

  MainIndexBloc() {
    _indexController.add(0);
  }

  @override
  void dispose() {
    _indexController.close();
  }

  void toIndex(int index) {
    _indexController.add(index);
  }
}

enum CAMERA_STATUS { PREVIEW, PICTURE_STILL, VIDEO_RECORD }

class CameraBloc extends BlocBase {
  PublishSubject<CAMERA_STATUS> _statusController = PublishSubject();

  Observable<CAMERA_STATUS> get statusStream => _statusController.stream;

  @override
  void dispose() {
    _statusController.close();
  }

  void changeStatus(CAMERA_STATUS status) {
    _statusController.add(status);
  }
}

class MemberApplyBloc extends BlocBase {
  @override
  void dispose() {
    _districtController.close();
  }

  BehaviorSubject<DistrictInfo> _districtController = BehaviorSubject();

  Observable<DistrictInfo> get districtInfo => _districtController.stream;

  void selectDistrict(DistrictInfo district) {
    _districtController.add(district);
  }
}
