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

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:live_activities/live_activities.dart';

const _liveActivityId = 'cuppa_tea_timer';

class LiveActivityService {
  final LiveActivities _liveActivities = LiveActivities();
  String? _activityId;
  bool _initialized = false;
  bool? _activitiesEnabled;

  Future<void> init() async {
    if (!Platform.isIOS) return;
    await _liveActivities.init(appGroupId: liveActivityAppGroupId);
    _initialized = true;

    // Clean up any orphaned activities from a previous app session
    await _liveActivities.endAllActivities();
  }

  Future<void> startOrUpdate(List<Tea> activeTeas) async {
    if (!_initialized) return;

    if (activeTeas.isEmpty) {
      await end();
      return;
    }

    _activitiesEnabled ??= await _liveActivities.areActivitiesEnabled();
    if (!_activitiesEnabled!) return;

    final data = _buildDataMap(activeTeas);

    try {
      if (_activityId == null) {
        _activityId = await _liveActivities.createActivity(
          _liveActivityId,
          data,
          iOSEnableRemoteUpdates: false,
        );
      } else {
        await _liveActivities.updateActivity(_activityId!, data);
      }
    } catch (e) {
      debugPrint('Live Activity error: $e');
      _activityId = null;
    }
  }

  Future<void> end() async {
    if (!_initialized || _activityId == null) return;
    await _liveActivities.endActivity(_activityId!);
    _activityId = null;
  }

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
