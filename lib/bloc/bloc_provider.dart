import 'dart:async';
import 'dart:convert';

//import 'package:amap_base_location/amap_base_location.dart';
//import 'package:amap_base/amap_base.dart';
import 'package:ease_life/main.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/remote/dio_util.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

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
  }

  ApplicationBloc() {
    _getCurrentUserAndNotify();
    _getCurrentDistrictAndNotify();
    _getIndexInfo();
  }

  void _getCurrentUserAndNotify() async {
    var userInfoStr = sharedPreferences.getString(PreferenceKeys.keyUserInfo);
    if (userInfoStr?.isNotEmpty == true) {
      _userInfoController.add(UserInfo.fromJson(json.decode(userInfoStr)));
    } else {
      _userInfoController.add(null);
    }
    debugPrint("===----> inject user info");
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

  BehaviorSubject<UserInfo> _userInfoController = BehaviorSubject();

  Stream<UserInfo> get currentUser => _userInfoController.stream;

  BehaviorSubject<DistrictInfo> _districtInfoController = BehaviorSubject();

  Observable<DistrictInfo> get currentDistrict =>
      _districtInfoController.stream;

  BehaviorSubject<Index> _homeIndexController = BehaviorSubject();
  BehaviorSubject<Index> _mineIndexController = BehaviorSubject();

  Observable<Index> get homeIndex => _homeIndexController.stream;
  Observable<Index> get mineIndex => _mineIndexController.stream;

  /*
   * 退出登录:
   * SP清空 userInfo/ token
   * 登录体系以SP中的 userInfo 作为唯一标识
   */
  void logout() {
    sharedPreferences.setString(PreferenceKeys.keyUserInfo, null);
    sharedPreferences.setString(PreferenceKeys.keyAuthorization, null);
    _userInfoController.add(null);
    debugPrint("===----> inject user info");
  }

  /*
   * 优先取SP缓存的小区信息
   * 然后取后端返回的小区的第一个
   */
  void _getCurrentDistrictAndNotify() async {
    var source = sharedPreferences.getString(PreferenceKeys.keyCurrentDistrict);
    DistrictInfo districtInfo =
        source == null ? null : DistrictInfo.fromJson(json.decode(source));
    if(districtInfo == null) {
      BaseResponse<List<DistrictInfo>> baseResponse = await Api
          .findAllDistrict();
      //将取到的小区信息存入sp缓存
      sharedPreferences.setString(PreferenceKeys.keyCurrentDistrict, baseResponse.data.first.toString());
      _districtInfoController.add(baseResponse.data.first);
    }else{
      _districtInfoController.add(districtInfo);
    }
    debugPrint("===----> inject district info");
  }




  /*
   * 获取json map,标记主页按钮的去向url
   */
  void _getIndexInfo() async{
    List<Index> list = await DioUtil().getIndexJson();
    _homeIndexController.add(list.firstWhere((index)=>index.area=="index"));
    _mineIndexController.add(list.firstWhere((index)=>index.area=="mine"));
    debugPrint("===----> inject index info");
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
    await Future.delayed(Duration(seconds: 2));
    return null;
  }
}
