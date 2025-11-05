/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    globals.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa globals

import 'package:cuppa_mobile/common/constants.dart';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:region_settings/region_settings.dart';

// Test mode
bool skipNotify = false;
bool skipTutorial = false;

// Global navigator
final navigatorKey = GlobalKey<NavigatorState>();

// Device info
late RegionSettings regionSettings;

// Package info
PackageInfo packageInfo = PackageInfo(
  appName: unknownString,
  packageName: unknownString,
  version: unknownString,
  buildNumber: unknownString,
);

// App store review prompt
Function checkReviewPrompt = () {};
