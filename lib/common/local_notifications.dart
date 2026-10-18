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
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/toast.dart';
import 'package:cuppa_mobile/data/localization.dart';

import 'dart:async' show Completer;
import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
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

// Request notification permissions
Completer<void>? _permissionsCompleter;
Future<void> requestNotifyPermissions() async {
  if (_permissionsCompleter != null) {
    return _permissionsCompleter!.future;
  }
  _permissionsCompleter = Completer<void>();
  try {
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
    _permissionsCompleter!.complete();
  } catch (e) {
    _permissionsCompleter!.completeError(e);
    rethrow;
  } finally {
    _permissionsCompleter = null;
  }
}

// Send or update a brewing complete notification
Future<void> sendNotification(
  int notifyID,
  String teaName,
  int secs, {
  bool silent = false,
  bool preNotify = false,
}) async {
  if (skipNotify) {
    return;
  }

  // Configure notification
  String title;
  String text;
  if (preNotify && secs > preNotifySeconds) {
    secs -= preNotifySeconds;
    title = AppString.notification_pre_title.translate();
    text = AppString.notification_pre_text.translate(teaName: teaName);
  } else {
    title = AppString.notification_title.translate();
    text = AppString.notification_text.translate(teaName: teaName);
  }
  final tz.TZDateTime notifyTime = tz.TZDateTime.now(tz.local)
      .add(Duration(seconds: secs));

  await requestNotifyPermissions();

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

// Show or update an ongoing countdown notification (Android only)
Future<void> sendOngoingNotification(
  int notifyID,
  String teaName,
  int timerEndTime,
) async {
  if (skipNotify || !Platform.isAndroid) {
    return;
  }

  int ongoingID = notifyID == notifyID1 ? notifyOngoingID1 : notifyOngoingID2;

  // Auto-dismiss the notification when the timer completes
  int timeoutMs = timerEndTime - DateTime.now().millisecondsSinceEpoch;
  if (timeoutMs <= 0) {
    return;
  }

  await requestNotifyPermissions();

  NotificationDetails notifyDetails = .new(
    android: AndroidNotificationDetails(
      notifyOngoingChannel,
      AppString.notification_channel_ongoing.translate(),
      importance: .low,
      priority: .low,
      ongoing: true,
      autoCancel: false,
      showWhen: true,
      usesChronometer: true,
      chronometerCountDown: true,
      when: timerEndTime,
      timeoutAfter: timeoutMs,
      playSound: false,
      enableVibration: false,
      icon: notifyIcon,
      color: notifyColor,
    ),
  );

  await notify.show(
    id: ongoingID,
    title: teaName,
    body: null,
    notificationDetails: notifyDetails,
  );
}

// Cancel an ongoing countdown notification (Android only)
Future<void> cancelOngoingNotification(int notifyID) async {
  if (skipNotify || !Platform.isAndroid) {
    return;
  }

  int ongoingID = notifyID == notifyID1 ? notifyOngoingID1 : notifyOngoingID2;
  await notify.cancel(id: ongoingID);
}

// Open OS notification settings for the app
Future<bool?> openNotificationSettings() =>
    notify.openAppNotificationSettings();

// Native method channels for notification settings
const _audioChannel = MethodChannel('cuppa_audio');
const _notifyChannel = MethodChannel('cuppa_notifications');

// Device settings that can keep timer alerts from being heard
enum NotifyIssue {
  disabled,
  muted,
  timeSensitive,
  alarmVolume;

  // Localized description of the issue
  String get message => switch (this) {
    .disabled => AppString.notify_issue_disabled.translate(),
    .muted => AppString.notify_issue_muted.translate(),
    .timeSensitive => AppString.notify_issue_time_sensitive.translate(),
    .alarmVolume => AppString.notify_issue_alarm_volume.translate(),
  };

  // Take the user to the setting that fixes the issue
  Future<void> resolve() async => switch (this) {
    .alarmVolume => await showAlarmVolume(),
    _ => await openNotificationSettings(),
  };
}

// Check for the most severe notification issue, if any, ignoring sound issues
// if timers default to silent
Future<NotifyIssue?> checkNotifyIssue({bool silent = false}) async {
  if (skipNotify) {
    return null;
  }

  try {
    return Platform.isIOS
        ? await checkNotifyIssueIOS(silent: silent)
        : await _checkNotifyIssueAndroid(silent: silent);
  } catch (e) {
    debugPrint('Notification check error: $e');
    return null;
  }
}

@visibleForTesting
Future<NotifyIssue?> checkNotifyIssueIOS({bool silent = false}) async {
  final Map<String, dynamic>? settings = await _notifyChannel
      .invokeMapMethod<String, dynamic>('getNotificationSettings');
  if (settings == null) {
    return null;
  }

  // Permission is requested when the first timer starts
  if (settings['status'] == 'denied') {
    return .disabled;
  }
  if (settings['status'] == 'notDetermined') {
    return null;
  }
  if (!silent && settings['soundEnabled'] == false) {
    return .muted;
  }
  if (settings['timeSensitiveEnabled'] == false) {
    return .timeSensitive;
  }
  return null;
}

Future<NotifyIssue?> _checkNotifyIssueAndroid({bool silent = false}) async {
  final AndroidFlutterLocalNotificationsPlugin? android = notify
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  return notifyIssueAndroid(
    enabled: await android?.areNotificationsEnabled(),
    channel: (await android?.getNotificationChannels())?.firstWhereOrNull(
      (channel) => channel.id == notifyChannel,
    ),
    alarmVolumeLow: await isAlarmVolumeLow(),
    silent: silent,
  );
}

@visibleForTesting
NotifyIssue? notifyIssueAndroid({
  required bool? enabled,
  required AndroidNotificationChannel? channel,
  required bool alarmVolumeLow,
  bool silent = false,
}) {
  if (enabled == false) {
    return .disabled;
  }
  if (silent) {
    return null;
  }

  // The channel only exists once a timer has run
  if (channel != null &&
      (!channel.playSound ||
          channel.importance.value < Importance.defaultImportance.value)) {
    return .muted;
  }
  if (alarmVolumeLow) {
    return .alarmVolume;
  }
  return null;
}

// Whether alarm volume is at its minimum (Android only)
Future<bool> isAlarmVolumeLow() async {
  if (skipNotify || !Platform.isAndroid) {
    return false;
  }

  try {
    final Map<String, int>? volume = await _audioChannel
        .invokeMapMethod<String, int>('getAlarmVolume');
    return volume != null && volume['current']! <= volume['min']!;
  } catch (e) {
    debugPrint('Alarm volume error: $e');
    return false;
  }
}

// Show the system alarm volume slider (Android only)
Future<void> showAlarmVolume() async {
  if (!Platform.isAndroid) {
    return;
  }

  await _audioChannel.invokeMethod<void>('showAlarmVolume');
}

// Warn once per session if a timer alert would be inaudible
bool _alarmVolumeWarned = false;
Future<void> warnIfAlarmVolumeLow() async {
  if (_alarmVolumeWarned || !await isAlarmVolumeLow()) {
    return;
  }

  final OverlayState? overlay = navigatorKey.currentState?.overlay;
  if (overlay == null || !overlay.mounted) {
    return;
  }

  _alarmVolumeWarned = true;
  Toast.show(
    overlay.context,
    overlay: overlay,
    message: AppString.notify_issue_alarm_volume.translate(),
    actionLabel: AppString.adjust_button.translate(),
    actionIcon: launchIcon.icon,
    onActionPressed: showAlarmVolume,
    duration: const Duration(seconds: 6),
  );
}
