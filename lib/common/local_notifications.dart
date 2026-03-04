/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    local_notifications.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa local notifications

import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notify = .new();

// Initialize notifications plugin
Future<void> initializeNotifications() async {
  await notify.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings(notifyIcon),
      iOS: DarwinInitializationSettings(
        // Wait to request permissions when user starts a timer
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      ),
    ),
  );
}

// Notification pattern
const List<int> notifyVibrateDelay = [0];
const List<int> notifyVibrateSubpattern = [400, 200, 400];
const List<int> notifyVibratePause = [1000];
final Int64List notifyVibratePattern = .fromList(
  notifyVibrateDelay +
      notifyVibrateSubpattern +
      notifyVibratePause +
      notifyVibrateSubpattern +
      notifyVibratePause +
      notifyVibrateSubpattern,
);

// Send or update a brewing complete notification
Future<void> sendNotification(
  int secs,
  String title,
  String text,
  int notifyID, {
  bool silent = false,
  int? badgeCount,
}) async {
  if (skipNotify) {
    return;
  }

  tz.TZDateTime notifyTime = tz.TZDateTime.now(
    tz.local,
  ).add(Duration(seconds: secs));

  // Request notification permissions
  if (Platform.isIOS) {
    await notify
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  } else {
    await notify
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // Cancel existing notification if channel needs to be changed (Android only)
  if (Platform.isAndroid) {
    List<PendingNotificationRequest> pendingNotifications = await notify
        .pendingNotificationRequests();
    for (final notification in pendingNotifications) {
      // Check for mismatch between channel and silent status
      if (notification.payload != null && notification.id == notifyID) {
        if ((notification.payload == notifyChannel && silent) ||
            (notification.payload == notifyChannelSilent && !silent)) {
          await notify.cancel(id: notifyID);
        }
      }
    }
  }

  // Configure and schedule the alarm
  NotificationDetails notifyDetails = .new(
    android: AndroidNotificationDetails(
      silent ? notifyChannelSilent : notifyChannel,
      silent
          ? AppString.notification_channel_silent.translate()
          : AppString.notification_channel_name.translate(),
      importance: .high,
      priority: .high,
      visibility: .public,
      channelShowBadge: true,
      showWhen: true,
      enableLights: true,
      color: notifyColor,
      enableVibration: true,
      vibrationPattern: notifyVibratePattern,
      playSound: !silent,
      sound: silent
          ? null
          : const RawResourceAndroidNotificationSound(notifySound),
      audioAttributesUsage: .alarm,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: !silent,
      presentBanner: true,
      presentList: true,
      sound: silent ? null : notifySoundIOS,
      interruptionLevel: .timeSensitive,
      badgeNumber: badgeCount,
    ),
  );
  await notify.zonedSchedule(
    id: notifyID,
    title: title,
    body: text,
    scheduledDate: notifyTime,
    notificationDetails: notifyDetails,
    payload: silent ? notifyChannelSilent : notifyChannel,
    androidScheduleMode: .exactAllowWhileIdle,
  );
}

// Reschedule all active timer notifications with correct badge counts
// based on completion order (iOS only — Android ignores badgeCount)
Future<void> rescheduleNotifications(List<Tea> activeTeas) async {
  if (skipNotify) {
    return;
  }

  // Sort by end time to determine completion order
  List<Tea> sorted = List.from(activeTeas)
    ..sort((a, b) => a.timerEndTime.compareTo(b.timerEndTime));

  for (int i = 0; i < sorted.length; i++) {
    Tea tea = sorted[i];
    if (tea.timerNotifyID != null && tea.brewTimeRemaining > 0) {
      await sendNotification(
        tea.brewTimeRemaining,
        AppString.notification_title.translate(),
        AppString.notification_text.translate(teaName: tea.name),
        tea.timerNotifyID!,
        silent: tea.isSilent,
        // Badge shows how many timers remain active after this one completes
        badgeCount: sorted.length - 1 - i,
      );
    }
  }
}

// Update the iOS app icon badge count
const MethodChannel _badgeChannel = MethodChannel('com.nathanatos.Cuppa/badge');

Future<void> updateBadgeCount(int count) async {
  if (skipNotify || !Platform.isIOS) {
    return;
  }

  await _badgeChannel.invokeMethod('setBadge', count);
}
