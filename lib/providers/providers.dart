import 'package:flutter/foundation.dart';


import '../index.dart';

class HomePageModel extends ChangeNotifier {
  bool isFirstEntry = true;

  void markNotFirstEntry() {
    isFirstEntry = false;
    notifyListeners();
  }
}

class MainIndexModel extends ChangeNotifier {
  int currentIndex = 0;

  void changeIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }
}

