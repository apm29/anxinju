import 'dart:convert';

import '../index.dart';

class MainIndexModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }

  MainIndexModel() {
    tryFetchIndexJson();
  }

  static MainIndexModel of(BuildContext context) {
    return Provider.of<MainIndexModel>(context, listen: false);
  }

  List<Index> _index;

  Future<List<Index>> getIndex() async {
    if (_index == null) {
      return _readFromSpThenNet();
    } else {
      return _index;
    }
  }

  set index(List<Index> value) {
    _index = value;
    notifyListeners();
  }

  Future<List<Index>> tryFetchIndexJson({bool evictCache = true}) async {
    if (!evictCache) {
      return _readFromSpThenNet();
    } else {
      return _fetchIndexFromNet();
    }
  }

  Object _readFromSpThenNet() {
    var jsonStr = sp.getString(KEY_JSON_MENU_INDEX);
    if (jsonStr == null || jsonStr.isEmpty) {
      return _fetchIndexFromNet();
    } else {
      List tmp = json.decode(jsonStr);
      var list = tmp.map((s) => Index.fromJson(s)).toList();
      index = list;
      return list;
    }
  }

  Future<List<Index>> _fetchIndexFromNet() async {
    return Api.getIndexMenu().then((list) {
      sp.setString(KEY_JSON_MENU_INDEX, "[${list.join(",")}]");
      index = list;
      return list;
    });
  }
}
