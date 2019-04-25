import 'package:ease_life/main.dart';
import 'package:ease_life/persistance/shared_preference_keys.dart';

bool isLogin() {
  return sharedPreferences.getString(PreferenceKeys.keyUserInfo) != null;
}
