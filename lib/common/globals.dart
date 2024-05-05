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

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:region_settings/region_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global navigator
final navigatorKey = GlobalKey<NavigatorState>();

// Shared preferences
late SharedPreferences sharedPrefs;
int nextTeaID = 0;

// Device info
late TargetPlatform appPlatform;
late RegionSettings regionSettings;

// Package info
PackageInfo packageInfo = PackageInfo(
  appName: unknownString,
  packageName: unknownString,
  version: unknownString,
  buildNumber: unknownString,
);

// Quick actions
const QuickActions quickActions = QuickActions();
