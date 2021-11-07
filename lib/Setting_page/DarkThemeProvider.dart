import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';

class DarkThemeProvider with ChangeNotifier {
  SharedPreferencesHelper darkThemePreferences = SharedPreferencesHelper();
  bool _darkTheme = false;
  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreferences.setDarkTheme(value);
    notifyListeners();
  }
}
