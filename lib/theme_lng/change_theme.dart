import 'package:flutter/material.dart';
import 'package:meetcake/theme_lng/themes/dark_theme.dart';
import 'package:meetcake/theme_lng/themes/light_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = lightTheme;

  ThemeData get theme => _currentTheme;

  void toggleTheme() {
    _currentTheme = _currentTheme == lightTheme ? darkTheme : lightTheme;
    notifyListeners();
    print('тема должна поменяться');
  }
}
