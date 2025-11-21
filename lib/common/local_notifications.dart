/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    local_notifications.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa local notifications

import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';

import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notify = .new();

// Initialize notifications plugin
Future<void> initializeNotifications() async {
  await notify.initialize(
    const InitializationSettings(
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
          await notify.cancel(notifyID);
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
    ),
  );
  await notify.zonedSchedule(
    notifyID,
    title,
    text,
    notifyTime,
    notifyDetails,
    payload: silent ? notifyChannelSilent : notifyChannel,
    androidScheduleMode: .exactAllowWhileIdle,
  );
}
