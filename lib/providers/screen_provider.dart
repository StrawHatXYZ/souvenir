import 'package:flutter/material.dart';
import 'package:souvenir/components/views/screens.dart';

class ScreenProvider extends ChangeNotifier {
  Screens _currentScreen = Screens.home;

  Screens get currentScreen => _currentScreen;

  void changeScreen(Screens screen) {
    _currentScreen = screen;
    notifyListeners();
  }
}
