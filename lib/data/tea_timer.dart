/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_timer.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Instance of a tea timer

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:async';
import 'package:wakelock/wakelock.dart';

class TeaTimer {
  // Fields
  late int notifyID;
  bool isActive = false;
  Tea? tea;
  int brewTime = 0;
  int timerSeconds = 0;
  Timer? ticker;

  // Constructor
  TeaTimer({required int notifyID}) {
    this.notifyID = notifyID;
  }

  // Start brewing
  void start(Tea newTea, void Function(Timer? timer) handleTick) {
    isActive = true;
    tea = newTea;
    brewTime = newTea.brewTime;
    ticker = Timer.periodic(const Duration(milliseconds: 100), handleTick);
    decrement();
  }

  // Decrement remaining brew time
  void decrement() {
    if (tea != null) {
      timerSeconds = tea!.brewTimeRemaining;
      Wakelock.enable();
    }
  }

  // Reset remaining brew time
  void reset() {
    timerSeconds = 0;
  }

  // Stop brewing
  void stop() {
    isActive = false;
    tea = null;
    brewTime = 0;
    timerSeconds = 0;
    if (ticker != null) {
      ticker!.cancel();
    }
    Wakelock.disable();
  }

  // Calculate percent complete
  double get timerPercent {
    return timerSeconds > 0 && brewTime > 0 ? timerSeconds / brewTime : 1.0;
  }

  // Formatted timer seconds
  String get timerString {
    return formatTimer(timerSeconds);
  }
}
