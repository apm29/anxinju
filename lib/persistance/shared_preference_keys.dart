import 'package:shared_preferences/shared_preferences.dart';

class PreferenceKeys{
  static const String keyAuthorization = "authorization_sp";
  static const String keyRegistrationId = "registration_id_sp";
  static const String keyUserInfo = "user_info_sp";
  static const String keyUserVerify = "user_info_verify_sp";
  static const String keyFirstEntryTag = "first_enter_222222";
  static const String keyCurrentDistrict = "current_society_id";
  static const String keyIndexInfo = "key_index_info";
}

SharedPreferences sp;

const String KEY_TOKEN = "key_token";
const String KEY_USER_INFO = "key_user_info";
const String KEY_CURRENT_DISTRICT_INDEX = "key_current_district_index";
const String KEY_JSON_MENU_INDEX = "key_json_menu_index";
const String KEY_CURRENT_THEME_INDEX = "key_current_theme_index";