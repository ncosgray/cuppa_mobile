/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    globals.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa globals
// - Shared preferences, quick actions

import 'package:cuppa_mobile/common/constants.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared preferences
late SharedPreferences sharedPrefs;
int nextTeaID = 0;

// Device info
late TargetPlatform appPlatform;
bool isLocaleMetric = true;

// Package info
PackageInfo packageInfo = PackageInfo(
  appName: unknownString,
  packageName: unknownString,
  version: unknownString,
  buildNumber: unknownString,
);

// Quick actions
const QuickActions quickActions = QuickActions();

// Notifications
final FlutterLocalNotificationsPlugin notify =
    FlutterLocalNotificationsPlugin();
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
