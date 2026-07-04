/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    refactor_verify_test.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa timer flow integration tests
// - Drives increment, silence toggle, and cancel on a running timer
// - Drives multiple infusions setup and advancing a running infusion

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/cuppa_app.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/widgets/tea_brew_time_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_button.dart';
import 'package:cuppa_mobile/widgets/timer_countdown.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('timer increment and silence controls', ($) async {
    // Run app
    await initializeApp();
    await $.pumpWidgetAndSettle(const CuppaApp());

    // Tap through tutorials if shown
    for (final key in tutorialSteps.keys) {
      final Finder step = find.text(tutorialSteps[key]![0].translate());
      if ($.tester.any(step)) {
        await $.tap(step);
      }
    }

    // Read the countdown timer text, e.g. 3:59
    String readTimer() {
      final RegExp pattern = RegExp(r'^\d+:\d{2}$');
      final Finder texts = find.descendant(
        of: find.byType(TimerCountdownWidget),
        matching: find.byType(Text),
      );
      for (final element in texts.evaluate()) {
        final String? data = (element.widget as Text).data;
        if (data != null && pattern.hasMatch(data)) {
          return data;
        }
      }
      fail('No countdown timer text found');
    }

    int toSeconds(String timerText) {
      final List<String> parts = timerText.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    // Start the first tea timer
    await $.tester.tap(find.byType(TeaButton).first);
    await $.tester.pump(const Duration(seconds: 1));

    // Allow notification permission if prompted
    try {
      await $.platform.ios.tap(
        IOSSelector(text: 'Allow'),
        appId: 'com.apple.springboard',
      );
    } catch (_) {
      // Permission already granted
    }
    await $.tester.pump(const Duration(seconds: 1));

    // Timer is counting down
    final int secsStart = toSeconds(readTimer());
    expect(secsStart, greaterThan(0));

    // Reveal timer adjustment controls
    await $.tester.tapAt(
      $.tester.getCenter(find.byType(TimerCountdownWidget)),
    );
    await $.tester.pump(const Duration(milliseconds: 500));
    expect(find.byIcon(incrementPlusIcon), findsOneWidget);

    // Increment the timer by 10 seconds
    final int secsBefore = toSeconds(readTimer());
    await $.tester.tap(find.byIcon(incrementPlusIcon));
    await $.tester.pump(const Duration(seconds: 1));
    final int secsIncremented = toSeconds(readTimer());
    expect(secsIncremented, greaterThan(secsBefore + 4));

    // Decrement the timer by 10 seconds
    await $.tester.tap(find.byIcon(incrementMinusIcon));
    await $.tester.pump(const Duration(seconds: 1));
    final int secsDecremented = toSeconds(readTimer());
    expect(secsDecremented, lessThan(secsIncremented));

    // Toggle timer silence
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    await $.tester.tap(find.byIcon(Icons.volume_up));
    await $.tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(Icons.volume_off), findsOneWidget);

    // Cancel the timer
    await $.tester.tap(find.text(AppString.cancel_button.translate()));
    await $.tester.pump(const Duration(seconds: 1));
    expect(find.text(formatTimer(0)), findsOneWidget);

    // Open tea settings and enable multiple infusions
    await $.tester.longPress(find.byType(TeaButton).first);
    await $.tester.pumpAndSettle();
    await $.tap(find.text(formatTimer(defaultBrewTime)));
    expect(find.byType(TeaBrewTimeDialog), findsOneWidget);
    await $.tester.tap(find.byType(GlassSwitch));
    await $.tester.pumpAndSettle();
    await $.tap(find.text(AppString.ok_button.translate()));

    // Close the floating settings card via its barrier
    await $.tester.tapAt(const Offset(50, 120));
    await $.tester.pumpAndSettle();

    // Infusion badge appears on the tea button
    expect(find.byIcon(Icons.restart_alt), findsOneWidget);

    // Start the timer on infusion 1
    await $.tester.tap(find.byType(TeaButton).first);
    await $.tester.pump(const Duration(seconds: 1));
    final int secsInfusion1 = toSeconds(readTimer());
    expect(secsInfusion1, greaterThan(0));

    // Tap the active button to advance to infusion 2
    await $.tester.tap(find.byType(TeaButton).first);
    await $.tester.pump(const Duration(seconds: 1));
    final int secsInfusion2 = toSeconds(readTimer());
    expect(secsInfusion2, greaterThan(secsInfusion1 + 20));
    expect(
      find.descendant(of: find.byType(TeaButton), matching: find.text('2')),
      findsOneWidget,
    );

    // Cancel the timer
    await $.tester.tap(find.text(AppString.cancel_button.translate()));
    await $.tester.pump(const Duration(seconds: 1));
    expect(find.text(formatTimer(0)), findsOneWidget);
  });
}
