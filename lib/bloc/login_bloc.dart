import 'dart:async';

import 'package:ease_life/remote//dio_net.dart';

class UserLoginLogic{
  StreamController<Map> _controller;
  Map init;
  UserLoginLogic(){
    init = {};
    _controller = StreamController();
  }

  Stream<Map> get value  => _controller.stream;

  void login(String userName,String password)async{
    var response = await DioApplication.login(userName, password);
    _controller.sink.add(response.data);
  }

  void dispose(){
    _controller.close();
  }

}