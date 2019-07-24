import 'dart:convert';
import 'package:amap_base_location/amap_base_location.dart';
import 'package:oktoast/oktoast.dart';
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
    tryGetCurrentLocation();
  }

  static MainIndexModel of(BuildContext context) {
    return Provider.of<MainIndexModel>(context, listen: false);
  }

  List<Index> _index;

  List<Index> get index => _index ?? [];

  Future<List<Index>> tryFetchIndex() async {
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

  Future<List<Index>> tryFetchIndexJson({bool evict = true}) async {
    if (!evict) {
      return _readFromSpThenNet();
    } else {
      return _fetchIndexFromNet();
    }
  }

  Object _readFromSpThenNet() {
    var jsonStr = userSp.getString(KEY_JSON_MENU_INDEX);
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
    return Api.getIndex().then((list) {
      userSp.setString(KEY_JSON_MENU_INDEX, "[${list.join(",")}]");
      index = list;
      return list;
    });
  }

  Future tryGetCurrentLocation() async {
    try {
      var permissionStatus = await PermissionHandler()
              .checkPermissionStatus(PermissionGroup.location);
      if (permissionStatus != PermissionStatus.granted) {
            var status = await PermissionHandler()
                .requestPermissions([PermissionGroup.location]);
            if (status[PermissionGroup.location] == PermissionStatus.granted) {
              return _doLocate();
            }
          } else {
            return _doLocate();
          }
    } catch (e) {
      print(e);
    }
  }

  Future _doLocate() {
    return AMapLocation()
        .getLocation(
            LocationClientOptions(locationMode: LocationMode.Hight_Accuracy))
        .then((location) {
    });
  }
}
