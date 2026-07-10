/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_timer.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Tea timer class and timer objects
// - Timer utility functions

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/local_notifications.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/stats.dart';
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
    brewTime = newTea.currentBrewTime;
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

// Start a new brewing timer
void setTimer(Tea tea, AppProvider provider, {bool resume = false}) {
  // Determine next available timer
  TeaTimer timer = !timer1.isActive ? timer1 : timer2;

  if (!resume) {
    // Start a new timer
    provider.activateTea(tea, timer.notifyID, provider.silentDefault);
    sendNotification(
      timer.notifyID,
      tea.name,
      tea.currentBrewTime,
      silent: provider.silentDefault,
      preNotify: provider.preNotify,
    );
    sendOngoingNotification(timer.notifyID, tea.name, tea.timerEndTime);

    // Update timer stats, if enabled
    if (provider.collectStats) {
      Stats.insertStat(Stat(tea: tea));
    }
  } else if (tea.timerNotifyID != null) {
    // Resume with same timer ID
    timer = tea.timerNotifyID == timer1.notifyID ? timer1 : timer2;
  }

  // Set up timer state
  timer.start(tea, handleTimerTick(timer, provider));
  provider.notifyTimerTick();

  // Update Live Activity
  liveActivityService.startOrUpdate(provider.activeTeas);
}

// Ticker handler for a TeaTimer
void Function(Timer? ticker) handleTimerTick(
  TeaTimer timer,
  AppProvider provider,
) {
  return (ticker) {
    if (timer.isActive) {
      int timerSeconds = timer.timerSeconds;
      if (timerSeconds > 0) {
        timer.decrement();
        if (timer.timerSeconds != timerSeconds) {
          // Only update UI if the timer countdown changed
          provider.notifyTimerTick();
        }
      } else {
        // Brewing complete
        if (timer.tea != null) {
          cancelOngoingNotification(timer.notifyID);
          provider.completeTea(timer.tea!);
        }
        timer.stop();
        provider.notifyTimerTick();

        // Update or end Live Activity
        liveActivityService.startOrUpdate(provider.activeTeas);
      }
    }
  };
}

// Cancel a timer
Future<void> cancelTimer(TeaTimer timer, AppProvider provider) async {
  // Capture active teas before async gap
  final activeTeas = provider.activeTeas;

  timer.stop();
  await notify.cancel(id: timer.notifyID);
  await cancelOngoingNotification(timer.notifyID);

  // Update or end Live Activity
  if (activeTeas.length <= 1) {
    await liveActivityService.end();
  } else {
    await liveActivityService.startOrUpdate(activeTeas);
  }
}

// Cancel the active Quick Timer
void cancelQuickTimer(AppProvider provider) {
  cancelTimerForTea(provider.quickTimer, provider);
}

// Cancel timer for a given tea
void cancelTimerForTea(Tea tea, AppProvider provider) {
  for (final timer in timerList) {
    if (timer.tea == tea) {
      cancelTimer(timer, provider);
    }
  }
  provider
    ..deactivateTea(tea)
    // Cancelling a timer abandons the session: restart the infusion cycle
    ..resetInfusion(tea)
    ..notifyTimerTick();
}

// Adjust a running timer by the given seconds and update notifications
void incrementRunningTimer(TeaTimer timer, int secs, AppProvider provider) {
  final Tea? tea = timer.tea;
  if (tea == null) return;

  if (provider.incrementTimer(tea, secs)) {
    // Reschedule notifications for the new end time
    sendNotification(
      timer.notifyID,
      tea.name,
      tea.brewTimeRemaining,
      silent: tea.isSilent,
      preNotify: provider.preNotify,
    );
    sendOngoingNotification(timer.notifyID, tea.name, tea.timerEndTime);

    // Update Live Activity with adjusted end time
    liveActivityService.startOrUpdate(provider.activeTeas);
  }
}

// Toggle silent status for a running timer and update its notification
void toggleTimerSilence(TeaTimer timer, AppProvider provider) {
  final Tea? tea = timer.tea;
  if (tea == null) return;

  provider.updateTea(tea, isSilent: !tea.isSilent);
  sendNotification(
    timer.notifyID,
    tea.name,
    tea.brewTimeRemaining,
    silent: tea.isSilent,
    preNotify: provider.preNotify,
  );
}

// Advance infusion for a running timer: update state, notification, and timer sync
void advanceRunningInfusion(Tea tea, AppProvider provider) {
  final TeaTimer? timer = timerList.firstWhereOrNull(
    (t) => t.isActive && t.tea == tea,
  );
  if (timer == null) return;

  provider.adjustTimerForInfusion(tea);

  // Sync progress arc denominator to the new infusion's brew time
  timer.brewTime = tea.currentBrewTime;

  // Reschedule notification for the new end time
  sendNotification(
    timer.notifyID,
    tea.name,
    tea.brewTimeRemaining,
    silent: tea.isSilent,
    preNotify: provider.preNotify,
  );
  sendOngoingNotification(timer.notifyID, tea.name, tea.timerEndTime);
}

// Force cancel and reset all timers
void cancelAllTimers(AppProvider provider) {
  for (final timer in timerList) {
    cancelTimer(timer, provider);
  }
  cancelTimerForTea(provider.quickTimer, provider);
  provider.clearActiveTea();
}
