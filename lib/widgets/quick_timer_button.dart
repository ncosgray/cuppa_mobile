/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    quick_timer_button.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Quick Timer button widget
// - Floating button to start or cancel a Quick Timer

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea_timer.dart';
import 'package:cuppa_mobile/widgets/tea_brew_time_dialog.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Floating button to start or cancel a Quick Timer
class QuickTimerButton extends StatelessWidget {
  const QuickTimerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppProvider, (bool, bool)>(
      selector: (_, provider) => (
        provider.isQuickTimerActive,
        provider.activeTeas.length < timersMaxCount,
      ),
      builder: (context, data, child) {
        final (isActive, canStart) = data;
        return adaptiveNavBarActionButton(
          context,
          icon: isActive
              ? getPlatformQuickTimerCancelIcon(
                  Theme.of(context).colorScheme.error,
                )
              : getPlatformQuickTimerIcon(),
          onPressed: isActive
              ? () => cancelQuickTimer(
                  Provider.of<AppProvider>(context, listen: false),
                )
              : canStart
              ? () => openQuickTimerDialog(context)
              : null,
        );
      },
    );
  }
}

// Display a Quick Timer dialog box
Future<Null> openQuickTimerDialog(BuildContext context) async {
  AppProvider provider = Provider.of<AppProvider>(context, listen: false);

  // Get last Quick Timer values
  int currentHours = provider.quickTimer.brewTimeHours;
  int currentMinutes = provider.quickTimer.brewTimeMinutes;
  int currentSeconds = provider.quickTimer.brewTimeSeconds;
  final String quickTimerLabel = AppString.quick_timer.translate();

  // Ask for Quick Timer brewing time
  final secs = await showAdaptiveDialog<int>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return TeaBrewTimeDialog(
        initialHours: currentHours,
        hourOptions: brewTimeHourOptions,
        hourLabel: AppString.unit_hours.translate(),
        initialMinutes: currentMinutes,
        minuteOptions: brewTimeMinuteOptions,
        minuteLabel: AppString.unit_minutes.translate(),
        initialSeconds: currentSeconds,
        secondOptions: brewTimeSecondOptions,
        buttonTextCancel: AppString.cancel_button.translate(),
        title: Text(quickTimerLabel),
        buttonTextOK: AppString.start_button.translate(),
      );
    },
  );

  if (secs != null && activeTimerCount < timersMaxCount) {
    // Save and start a timer
    provider.setQuickTimer(quickTimerLabel, secs);
    setTimer(provider.quickTimer, provider, isQuickTimer: true);
  }
}
