import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeEndScrollModel extends ChangeNotifier{

  bool _atHomeEnd = false;

  set atHomeEnd(bool newValue){
    if(newValue == _atHomeEnd){
      return;
    }
    _atHomeEnd = newValue;
    notifyListeners();
  }

  bool get atHomeEnd => _atHomeEnd;



  static HomeEndScrollModel of(BuildContext context) {
    return Provider.of<HomeEndScrollModel>(context, listen: false);
  }


}