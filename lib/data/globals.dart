/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    globals.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa globals
// - Shared preferences, quick actions

import 'package:cuppa_mobile/data/constants.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared preferences
late SharedPreferences sharedPrefs;

// Device info
late TargetPlatform appPlatform;
double appTextScale = 1.0;
bool isLocaleMetric = true;

// Package info
PackageInfo packageInfo = PackageInfo(
  appName: unknownString,
  packageName: unknownString,
  version: unknownString,
  buildNumber: unknownString,
);

// Quick actions
final QuickActions quickActions = const QuickActions();

// Notifications
final FlutterLocalNotificationsPlugin notify =
    FlutterLocalNotificationsPlugin();
