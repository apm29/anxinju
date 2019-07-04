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

class GlobalBloc extends BlocBase {
  @override
  void dispose() {
    _userInfoController.close();
  }

  BehaviorSubject<UserInfo> _userInfoController = BehaviorSubject();

  Observable<UserInfo> get userInfoStream => _userInfoController.stream;

  GlobalBloc() {
    var userInfoStr =
        sp.getString(PreferenceKeys.keyUserInfo) ?? "{}";
    var userInfo = UserInfo.fromJson(json.decode(userInfoStr));
    _userInfoController.add(userInfo);
  }
}

class ApplicationBloc extends BlocBase {
  @override
  void dispose() {
    _userInfoController.close();
    _districtInfoController.close();
    _noticeController.close();
    _noticeTypeController.close();
    _userTypeController.close();
    _controllerUserDetailData.close();
    _controllerMyHouseData.close();
    _userVerifyStatusController.close();
    subscription?.cancel();
  }

  StreamSubscription subscription;

  ApplicationBloc() {
    _getCurrentUserAndNotify();
    _getCurrentDistrictAndNotify();
    getIndexInfo();
    getNoticeInfo();
    _requestLocationPermission();
    getUserTypes();
    getUserDetail();
    getUserVerifyStatus();
    tryRefreshUserVerifyStatus();
  }

  void tryRefreshUserVerifyStatus() async {
    subscription?.cancel();
    subscription = Observable.periodic(
      Duration(seconds: 25),
    ).take(5).listen((_) {
      getUserVerifyStatus();
    });
  }

  void _getCurrentUserAndNotify() async {
    var userInfoStr = sp.getString(PreferenceKeys.keyUserInfo);
    if (userInfoStr?.isNotEmpty == true) {
      _userInfoController.add(UserInfo.fromJson(json.decode(userInfoStr)));
    } else {
      _userInfoController.add(null);
    }
  }

  void login(UserInfo userInfo) {
    sp.setString(
        PreferenceKeys.keyUserInfo, userInfo?.toString());
    _getCurrentUserAndNotify();
    clearDistrictAndGetCurrentDistrict();
  }

  void saveToken(String token) {
    sp.setString(
        PreferenceKeys.keyAuthorization, token?.toString());
  }

  void refreshMenuIndex(List<Index> indexInfo) {}

  BehaviorSubject<UserInfo> _userInfoController = BehaviorSubject();

  //Observable<UserInfo> get currentUser => _userInfoController.stream;

  BehaviorSubject<DistrictDetail> _districtInfoController = BehaviorSubject();





  BehaviorSubject<List<Announcement>> _noticeController = BehaviorSubject();
  BehaviorSubject<List<AnnouncementType>> _noticeTypeController = BehaviorSubject();



  BehaviorSubject<List<UserType>> _userTypeController = BehaviorSubject();


  PublishSubject<UserDetail> _controllerUserDetailData = PublishSubject();


  PublishSubject<List<HouseDetail>> _controllerMyHouseData = PublishSubject();


  BehaviorSubject<UserVerifyStatus> _userVerifyStatusController =
      BehaviorSubject();


  /*
   * 退出登录:
   * SP清空 userInfo/ token
   * 登录体系以SP中的 userInfo 作为唯一标识
   */
  void logout() {
    sp.setString(PreferenceKeys.keyUserInfo, null);
    sp.setString(PreferenceKeys.keyAuthorization, null);
    sp.setString(PreferenceKeys.keyCurrentDistrict, null);
    _userInfoController.add(null);
    _districtInfoController.add(null);
  }

  void getUserTypes() {
    Api.getUserInfo().then((base) {
      if (base.success) {
        _userInfoController.add(base.data);
      } else {
        throw Exception("用户未登录,获取角色列表失败");
      }
      return base.data.userId;
    }).then((userId) {
      print(userId);
      return Api.getUserType(userId);
    }).then((baseResp) {
      var data = baseResp.data[0];
      print(data);
      _userTypeController.add(baseResp.data);
    }).catchError((e, s) {
      print(e);
      //print(s);
      _userTypeController.add([]);
    });
  }

  void getMyUserTypes() {
    Api.getUserTypeWithOutId().then((baseResp) {
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
      if (baseResp.success) {
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
    var source = sp.getString(PreferenceKeys.keyCurrentDistrict);
    DistrictDetail districtInfo =
        source == null ? null : DistrictDetail.fromJson(json.decode(source));
    if (districtInfo == null) {
      BaseResponse<List<DistrictDetail>> baseResponse =
          await Api.findAllDistrict();
      //将取到的${Strings.districtClass}信息存入sp缓存
      sp.setString(PreferenceKeys.keyCurrentDistrict,
          baseResponse.data.first.toString());
      _districtInfoController.add(baseResponse.data.first);
      getMyHouseList();
    } else {
      _districtInfoController.add(districtInfo);
      getMyHouseList();
    }
  }

  ///清空小区缓存重新获取
  void clearDistrictAndGetCurrentDistrict() async {
    BaseResponse<List<DistrictDetail>> baseResponse = await Api.findAllDistrict();
    //将取到的${Strings.districtClass}信息存入sp缓存
    var string = baseResponse.data.first.toString();
    sp.setString(PreferenceKeys.keyCurrentDistrict, string);
    if (baseResponse.success) {
      sp.setString(PreferenceKeys.keyCurrentDistrict, string);
      _districtInfoController.add(baseResponse.data.first);
      getMyHouseList();
    } else {
      _districtInfoController.add(null);
      getMyHouseList();
    }
  }


  void setCurrentDistrict(DistrictDetail districtInfo) {
    //将取到的${Strings.districtClass}信息存入sp缓存
    sp.setString(
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
    }).then((BaseResponse<List<Announcement>> resp) {
      _noticeController.add(resp.data);
    }).catchError((e, s) {
      _noticeController.add(null);
    });
  }

  void getUserDetail() {
    Api.getUserDetail().then((baseResp) {
      if (baseResp.success) {
        _controllerUserDetailData.add(baseResp.data);
      }
    }).catchError((Object e, StackTrace s) {
      _controllerUserDetailData.addError(e, s);
    });
  }

  Future getUserVerifyStatus() async {
    return Api.getUserVerify().then((resp) {
      if (resp.success) {
        _userVerifyStatusController.add(resp.data);
        sp.setString(
            PreferenceKeys.keyUserVerify, resp.data.toString());
      } else {
        _userVerifyStatusController.addError(resp.text);
        sp.setString(PreferenceKeys.keyUserVerify, null);
      }
    }).catchError((e) {
      _userVerifyStatusController.addError(e);
      sp.setString(PreferenceKeys.keyUserVerify, null);
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


