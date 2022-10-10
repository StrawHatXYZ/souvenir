import 'package:flutter/material.dart';

class ScannerStateProvider extends ChangeNotifier {
  bool _isinitialized = false;
  bool _process = false;

  bool get isprocessing => _process;
  bool get isinitialized => _isinitialized;

  void updateStatus(bool state) {
    _process = state;
    notifyListeners();
  }

  void updateIntializer(bool state) {
    _isinitialized = state;
    notifyListeners();
  }
}
