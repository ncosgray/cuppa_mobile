/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    local_notifications.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa local notifications

import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notify =
    FlutterLocalNotificationsPlugin();

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
final Int64List notifyVibratePattern = Int64List.fromList(
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
  tz.TZDateTime notifyTime =
      tz.TZDateTime.now(tz.local).add(Duration(seconds: secs));

  // Request notification permissions
  if (appPlatform == TargetPlatform.iOS) {
    await notify
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  } else {
    await notify
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Configure and schedule the alarm
  NotificationDetails notifyDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      notifyChannel,
      AppString.notification_channel_name.translate(),
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      channelShowBadge: true,
      showWhen: true,
      enableLights: true,
      color: timerBackgroundColor,
      enableVibration: true,
      vibrationPattern: notifyVibratePattern,
      playSound: true,
      silent: silent,
      sound: const RawResourceAndroidNotificationSound(notifySound),
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: !silent,
      presentBanner: true,
      presentList: true,
      sound: notifySoundIOS,
      interruptionLevel: InterruptionLevel.timeSensitive,
    ),
  );
  await notify.zonedSchedule(
    notifyID,
    title,
    text,
    notifyTime,
    notifyDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
