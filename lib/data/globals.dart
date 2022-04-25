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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared preferences
late SharedPreferences sharedPrefs;

// Device info
late TargetPlatform appPlatform;
late double deviceWidth;
late double deviceHeight;
bool isLocaleMetric = true;

// Package info
PackageInfo packageInfo = PackageInfo(
  appName: 'Unknown',
  packageName: 'Unknown',
  version: 'Unknown',
  buildNumber: 'Unknown',
);

// Quick actions
final QuickActions quickActions = const QuickActions();

// Notification channel
final MethodChannel notifyPlatform = const MethodChannel(notifyChannel);
