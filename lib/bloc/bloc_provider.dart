import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ease_life/bloc/user_bloc.dart';
import 'package:ease_life/main.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';
import 'package:ease_life/remote/dio_net.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

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
    final type = _typeOf<BlocProviders<T>>();
    BlocProviders<T> providers = context.ancestorWidgetOfExactType(type);
    return providers.bloc;
  }

  static Type _typeOf<T>() => T;
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
  }

  ApplicationBloc() {
    _getCurrentUserAndNotify();
  }

  void _getCurrentUserAndNotify() async {
    var userInfoStr = sharedPreferences.getString(PreferenceKeys.keyUserInfo);
    if (userInfoStr?.isNotEmpty == true) {
      _userInfoController.add(UserInfo.fromJson(json.decode(userInfoStr)));
    } else {
      _userInfoController.add(null);
    }
  }

  void login(UserInfo userInfo) async {
    _userInfoController.add(userInfo);
  }

  BehaviorSubject<UserInfo> _userInfoController = BehaviorSubject();

  Stream<UserInfo> get currentUser => _userInfoController.stream;

  void logout() async {
    sharedPreferences.setString(PreferenceKeys.keyUserInfo, null);
    sharedPreferences.setString(PreferenceKeys.keyAuthorization, null);
    _userInfoController.add(null);
  }
}

class LoginBloc extends BlocBase {


  @override
  void dispose() {
  }
}
