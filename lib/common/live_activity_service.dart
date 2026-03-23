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

// Cuppa Live Activity service
// Manages the iOS Live Activity that displays active tea timer countdowns
// on the lock screen and in the Dynamic Island. Uses the live_activities
// plugin to communicate with the native widget extension
// (see CuppaLiveActivityLiveActivity.swift) via shared UserDefaults.

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:live_activities/live_activities.dart';

/// Identifier used when creating the Live Activity instance.
const _liveActivityId = 'cuppa_tea_timer';

/// Service that manages the lifecycle of an iOS Live Activity for tea timers.
/// Handles creating, updating, and ending the activity as timers start and stop.
/// Only one Live Activity is used at a time, with up to 2 timers displayed in it.
class LiveActivityService {
  final LiveActivities _liveActivities = LiveActivities();

  /// The ID of the currently active Live Activity, or null if none is running.
  String? _activityId;

  /// Whether the service has been initialized (iOS only).
  bool _initialized = false;

  /// Cached result of whether the user has enabled Live Activities for this app.
  bool? _activitiesEnabled;

  /// Initialize the Live Activity plugin with the app group ID.
  /// Must be called before any other methods. No-ops on non-iOS platforms.
  Future<void> init() async {
    if (!Platform.isIOS) return;
    await _liveActivities.init(appGroupId: liveActivityAppGroupId);
    _initialized = true;

    // Clean up any orphaned activities from a previous app session
    await _liveActivities.endAllActivities();
  }

  /// Create or update the Live Activity with the current active tea timers.
  /// If no teas are active, ends the Live Activity. If the activity doesn't
  /// exist yet, creates a new one; otherwise updates the existing one.
  Future<void> startOrUpdate(List<Tea> activeTeas) async {
    if (!_initialized) return;

    if (activeTeas.isEmpty) {
      await end();
      return;
    }

    // Check if the user has enabled Live Activities (cached after first check)
    _activitiesEnabled ??= await _liveActivities.areActivitiesEnabled();
    if (!_activitiesEnabled!) return;

    final data = _buildDataMap(activeTeas);

    try {
      if (_activityId == null) {
        // No existing activity — create a new one
        _activityId = await _liveActivities.createActivity(
          _liveActivityId,
          data,
          iOSEnableRemoteUpdates: false,
        );
      } else {
        // Update the existing activity with new timer data
        await _liveActivities.updateActivity(_activityId!, data);
      }
    } catch (e) {
      debugPrint('Live Activity error: $e');
      _activityId = null;
    }
  }

  /// End the current Live Activity and clear the tracked activity ID.
  Future<void> end() async {
    if (!_initialized || _activityId == null) return;
    await _liveActivities.endActivity(_activityId!);
    _activityId = null;
  }

  /// Build the data map that gets written to shared UserDefaults for the
  /// native widget extension to read. Keys are prefixed with "tea1" or "tea2"
  /// and include the tea name, end time (epoch seconds), icon, and RGB color.
  Map<String, dynamic> _buildDataMap(List<Tea> activeTeas) {
    final map = <String, dynamic>{
      'timerCount': activeTeas.length,
    };

    for (int i = 0; i < timersMaxCount; i++) {
      final prefix = 'tea${i + 1}';
      if (i < activeTeas.length) {
        final tea = activeTeas[i];
        final color = tea.getColor();
        map['${prefix}Name'] = tea.name;
        // Convert from milliseconds (Dart) to seconds (Swift Date)
        map['${prefix}EndTime'] = tea.timerEndTime / 1000.0;
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
