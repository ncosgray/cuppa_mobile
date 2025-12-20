/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_timer.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Tea timer class and timer objects
// - Timer utility functions

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// Tea timers
final TeaTimer timer1 = .new(notifyID: notifyID1);
final TeaTimer timer2 = .new(notifyID: notifyID2);
final List<TeaTimer> timerList = [timer1, timer2];

// Tea timer definition
class TeaTimer {
  TeaTimer({required this.notifyID});

  // Fields
  late int notifyID;
  bool isActive = false;
  Tea? tea;
  int brewTime = 0;
  int timerSeconds = 0;
  Timer? ticker;

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
      WakelockPlus.enable();
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
    WakelockPlus.disable();
  }

  // Calculate percent complete
  double get timerPercent {
    return brewTime > 0 ? timerSeconds / brewTime : 1.0;
  }

  // Formatted timer seconds
  String get timerString {
    return formatTimer(timerSeconds);
  }
}

// Get timer from ID
TeaTimer? getTimerFromID(int id) {
  return timerList.firstWhereOrNull((timer) => timer.notifyID == id);
}

// Count of currently active timers
int get activeTimerCount {
  return timerList.where((timer) => timer.isActive).length;
}
