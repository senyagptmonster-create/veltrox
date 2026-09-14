import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VeltroxStore extends ChangeNotifier {
  bool isRunning = false;
  int timeRemaining = 30;
  int currentSet = 1;
  int totalSets = 5;

  Future<void> init() async {
    await SharedPreferences.getInstance();
    // load saved routines
  }

  void toggleTimer() {
    isRunning = !isRunning;
    notifyListeners();
  }

  void stopTimer() {
    isRunning = false;
    timeRemaining = 30;
    currentSet = 1;
    notifyListeners();
  }
}
