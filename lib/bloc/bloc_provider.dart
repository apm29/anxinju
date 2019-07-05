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

    subscription?.cancel();
  }

  StreamSubscription subscription;

  ApplicationBloc();

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


