/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    live_activity_service.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa Live Activity service (iOS only)

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Native method channel for iOS Live Activity management
const _channel = MethodChannel('cuppa_live_activity');

// Service that manages the lifecycle of an iOS Live Activity for tea timers
class LiveActivityService {
  // The ID of the currently active Live Activity, or null if none is running
  String? _activityId;

  // Whether the service has been initialized
  bool _initialized = false;

  // Cached result of whether the user has enabled Live Activities for this app
  bool? _activitiesEnabled;

  // Initialize the Live Activity service with the app group ID
  Future<void> init() async {
    if (!Platform.isIOS) return;
    await _channel.invokeMethod<void>('init', {
      'appGroupId': liveActivityAppGroupId,
    });
    _initialized = true;

    // Clean up any orphaned activities from a previous app session
    await _channel.invokeMethod<void>('endAllActivities');
  }

  // Create/update the Live Activity with the current active tea timers
  // or, if no teas are active, end the Live Activity
  Future<void> startOrUpdate(List<Tea> activeTeas) async {
    if (!_initialized) return;

    if (activeTeas.isEmpty) {
      await end();
      return;
    }

    // Check if the user has enabled Live Activities (cached after first check)
    _activitiesEnabled ??=
        await _channel.invokeMethod<bool>('areActivitiesEnabled') ?? false;
    if (!_activitiesEnabled!) return;

    final data = _buildDataMap(activeTeas);

    try {
      if (_activityId == null) {
        // No existing activity - create a new one
        _activityId = await _channel.invokeMethod<String>('createActivity', {
          'data': data,
        });
      } else {
        // Update the existing activity with new timer data
        await _channel.invokeMethod<void>('updateActivity', {
          'activityId': _activityId!,
          'data': data,
        });
      }
    } catch (e) {
      debugPrint('Live Activity error: $e');
      _activityId = null;
    }
  }

  // End the current Live Activity and clear the tracked activity ID
  Future<void> end() async {
    if (!_initialized || _activityId == null) return;
    await _channel.invokeMethod<void>('endActivity', {
      'activityId': _activityId!,
    });
    _activityId = null;
  }

  // Build the data map that gets written to shared UserDefaults for the
  // native widget extension to read
  Map<String, dynamic> _buildDataMap(List<Tea> activeTeas) {
    final map = <String, dynamic>{'timerCount': activeTeas.length};

    for (int i = 0; i < timersMaxCount; i++) {
      final prefix = 'tea${i + 1}';
      if (i < activeTeas.length) {
        final tea = activeTeas[i];
        final color = tea.getColor();
        map['${prefix}Name'] = tea.name;
        // Convert from milliseconds (Dart) to seconds (Swift Date),
        // adjusting for the extra second added in Tea.activate()
        map['${prefix}EndTime'] = (tea.timerEndTime / 1000.0) - 1;
        map['${prefix}Icon'] = tea.icon.value;
        map['${prefix}ColorRed'] = color.r;
        map['${prefix}ColorGreen'] = color.g;
        map['${prefix}ColorBlue'] = color.b;
        map['${prefix}Active'] = true;
      } else {
        map['${prefix}Active'] = false;
      }
    }

    return map;
  }
}
