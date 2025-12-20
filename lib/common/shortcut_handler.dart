/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    shortcut_handler.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa shortcut handler
// - Quick actions
// - Integration with Apple AppIntents

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:io';
import 'package:intelligence/intelligence.dart';
import 'package:intelligence/model/representable.dart';
import 'package:quick_actions/quick_actions.dart';

// Shortcut plugins wrapper including platform checks
abstract class ShortcutHandler {
  static const QuickActions quickActions = .new();
  static final Intelligence intelligence = .new();

  // Populate tea shortcuts
  static Future<void> populate({
    required List<Tea> teaList,
    required List<Tea> favoritesList,
  }) async {
    // Create a quick action item for each favorite tea
    await quickActions.setShortcutItems([
      for (final Tea tea in favoritesList)
        ShortcutItem(
          type: shortcutPrefixID + tea.id.toString(),
          localizedTitle: tea.name,
          icon: tea.shortcutIcon,
        ),
    ]);

    // Create an intelligence item for each tea (iOS only)
    if (Platform.isIOS) {
      await intelligence.populate([
        for (final Tea tea in teaList)
          Representable(representation: tea.name, id: tea.id.toString()),
      ]);
    }
  }

  // Listen for selections
  static void listen(Function(String) onData) {
    quickActions.initialize(onData);

    if (Platform.isIOS) {
      intelligence.selectionsStream().listen(onData);
    }
  }
}
