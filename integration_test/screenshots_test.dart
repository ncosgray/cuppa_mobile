/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    screenshots_test.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Generate Cuppa screenshots

import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/cuppa_app.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/presets.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'dart:io';
import 'package:flex_color_picker/flex_color_picker.dart'
    show ColorIndicator, ColorPicker;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
    ..framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async {
    // Initialize app
    await initializeApp(testing: true);
    await Future.delayed(const Duration(seconds: 1));

    // Initialize Flutter bindings
    TestWidgetsFlutterBinding.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }
  });

  // Helper function to find a Container with a specific color
  Finder findWidgetWithContainerColor(Color color) {
    return find.byWidgetPredicate((widget) {
      if (widget is Container) {
        // Check for color set directly
        if (widget.color == color) {
          return true;
        }
        // Check for color set via BoxDecoration
        final decoration = widget.decoration;
        if (decoration is BoxDecoration && decoration.color == color) {
          return true;
        }
      }
      // Check for color_picker swatch
      else if (widget is ColorIndicator) {
        if (widget.color == color) {
          return true;
        }
      }
      return false;
    }, description: 'Finds a Container with color $color');
  }

  testWidgets('collect screenshots', ($) async {
    // Run app
    await $.pumpWidget(const CuppaApp());
    await $.pumpAndSettle();

    // Screenshot 1: Timing in progress
    await $.tap(find.text(AppString.tea_name_black.translate()));
    await $.pumpAndSettle();
    sleep(const Duration(seconds: 2));
    await binding.takeScreenshot('1-home');
    await $.tap(find.text(AppString.cancel_button.translate()));

    // Screenshot 3: Prefs page with customized teas
    await $.tap(find.byIcon(platformSettingsIcon.icon!, skipOffstage: false));
    await $.pumpAndSettle();
    await $.tap(find.byIcon(TeaIcon.timer.getIcon()).hitTestable().first);
    await $.pumpAndSettle();
    await $.tap(find.byIcon(TeaIcon.cup.getIcon()).hitTestable().first);
    await $.pumpAndSettle();
    await $.tap(find.byIcon(TeaIcon.timer.getIcon()).hitTestable().first);
    await $.pumpAndSettle();
    await $.tap(find.byIcon(TeaIcon.cup.getIcon()).hitTestable().first);
    await $.pumpAndSettle();
    await $.tap(find.byIcon(TeaIcon.timer.getIcon()).hitTestable().first);
    await $.pumpAndSettle();
    await $.tap(find.byIcon(TeaIcon.flower.getIcon()).hitTestable().first);
    await $.pumpAndSettle();
    await $.tap(
      findWidgetWithContainerColor(
        Presets.presetList
            .firstWhere((preset) => preset.key == AppString.tea_name_herbal)
            .color
            .color,
      ).first,
    );
    await $.pumpAndSettle();
    await $.tap(
      find
          .descendant(
            of: find.byType(ColorPicker),
            matching: find.byType(ColorIndicator),
          )
          .at(TeaColor.lavender.index),
    );
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.ok_button.translate()));
    await $.pumpAndSettle();
    await $.tap(find.byIcon(addIcon.icon!));
    await $.pumpAndSettle();
    final Finder rooibosPreset = find
        .text(AppString.tea_name_rooibos.translate(), skipOffstage: false)
        .last;
    await $.ensureVisible(rooibosPreset);
    await $.pumpAndSettle();
    await $.tap(rooibosPreset);
    await $.pumpAndSettle();
    await $.tap(
      findWidgetWithContainerColor(
        Presets.presetList
            .firstWhere((preset) => preset.key == AppString.tea_name_rooibos)
            .color
            .color,
      ).first,
    );
    await $.pumpAndSettle();
    await $.tap(
      find
          .descendant(
            of: find.byType(ColorPicker),
            matching: find.byType(ColorIndicator),
          )
          .at(TeaColor.red.index),
    );
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.ok_button.translate()));
    await $.pumpAndSettle();
    sleep(const Duration(seconds: 2));
    await binding.takeScreenshot('3-prefs');

    // Screenshot 3a: Settings page (phone only)
    final Finder settingsIconFinder = find.byIcon(navBarSettingsIcon.icon!);
    if (settingsIconFinder.evaluate().isNotEmpty) {
      await $.tap(settingsIconFinder);
      await $.pumpAndSettle();
      sleep(const Duration(seconds: 2));
      await binding.takeScreenshot('3a-settings');
    }

    // Screenshot 2: Dual timers with custom settings
    await $.tap(find.text(AppString.prefs_show_extra.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.prefs_extra_brew_time.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.prefs_extra_brew_temp.translate()));
    await $.pumpAndSettle();
    await $.tap(
      find.text(AppString.done_button.translate()).hitTestable().first,
    );
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.prefs_cup_style.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.prefs_cup_style_mug.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.prefs_app_theme.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.theme_black.translate()));
    await $.pumpAndSettle();
    final Finder statsEnable = find
        .text(AppString.stats_enable.translate(), skipOffstage: false)
        .last;
    await $.ensureVisible(statsEnable);
    await $.pumpAndSettle();
    await $.tap(statsEnable);
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.yes_button.translate()));
    await $.pumpAndSettle();
    if (Platform.isIOS) {
      await $.tap(
        find.text(AppString.done_button.translate()).hitTestable().first,
      );
    } else {
      await $.pageBack();
    }
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.tea_name_green.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.tea_name_herbal.translate()));
    await $.pumpAndSettle();
    sleep(const Duration(seconds: 2));
    await binding.takeScreenshot('2-dual');

    // Screenshot 4: Stats page with data
    await $.tap(find.text(AppString.cancel_button.translate()).first);
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.cancel_button.translate()).first);
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.tea_name_black.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.cancel_button.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.tea_name_black.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.cancel_button.translate()));
    await $.pumpAndSettle();
    final Finder rooibosTea = find.text(
      AppString.tea_name_rooibos.translate(),
      skipOffstage: false,
    );
    await $.ensureVisible(rooibosTea);
    await $.pumpAndSettle();
    await $.tap(rooibosTea);
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.cancel_button.translate()));
    await $.pumpAndSettle();
    await $.tap(find.byIcon(platformSettingsIcon.icon!, skipOffstage: false));
    await $.pumpAndSettle();
    if (settingsIconFinder.evaluate().isNotEmpty) {
      await $.tap(settingsIconFinder);
      await $.pumpAndSettle();
    }
    await $.tap(find.text(AppString.prefs_app_theme.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.theme_light.translate()));
    await $.pumpAndSettle();
    await $.tap(
      find.byIcon(platformStatsIcon.icon!, skipOffstage: false).first,
    );
    await $.pumpAndSettle();
    sleep(const Duration(seconds: 2));
    await binding.takeScreenshot('4-stats');
  });
}
