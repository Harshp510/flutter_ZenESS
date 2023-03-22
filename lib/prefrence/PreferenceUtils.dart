import 'dart:async' show Future;
import 'dart:ffi';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {

  static SharedPreferences? _prefs;



  // call this method from iniState() function of mainApp().
  static  init() async {
    _prefs = await SharedPreferences.getInstance();

  }

  static setString(String key, String value) {
    if (_prefs != null) _prefs!.setString(key, value);
  }

  static String getString(String key) {
    return _prefs == null ? 'DEFAULT_VALUE' : _prefs!.getString(key) ?? "";
  }

  static Clear_Preferences() async {
    /*SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();*/
    await _prefs?.clear();
  }
  static contain(String key){
    return _prefs?.containsKey(key);
  }


}