import 'package:shared_preferences/shared_preferences.dart';

class Localstorage {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _userPhotoKey = 'userPhoto';

  static Future<void> saveuserdata({
    required String name,
    required String email,
    required String photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userPhotoKey, photoUrl);
  }

  static Future<Map<String, dynamic>> getuser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "isLoggedin": prefs.getBool(_isLoggedInKey) ?? false,
      "name": prefs.getString(_userNameKey) ?? '',
      "email": prefs.getString(_userEmailKey) ?? '',
      "photourl": prefs.getString(_userPhotoKey) ?? '',
    };
  }

  static Future<void> cleardata()async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
