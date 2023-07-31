/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tutorial.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tutorial

import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

// Tutorial widget keys
final GlobalKey tutorialKey1 = GlobalKey();
final GlobalKey tutorialKey2 = GlobalKey();
final GlobalKey tutorialKey3 = GlobalKey();
final GlobalKey tutorialKey4 = GlobalKey();
final GlobalKey tutorialKey5 = GlobalKey();
Map<GlobalKey, List<AppString>> tutorialSteps = {
  tutorialKey1: [AppString.tutorial_text1],
  tutorialKey2: [AppString.tutorial_text2, AppString.prefs_title],
  tutorialKey3: [AppString.tutorial_text3, AppString.teas_title],
  tutorialKey4: [AppString.tutorial_text4],
  tutorialKey5: [AppString.tutorial_text5],
};

// Define a tutorial tooltip
Widget tutorialTooltip(
    {required BuildContext context,
    required GlobalKey key,
    bool showArrow = true,
    required Widget child}) {
  if (tutorialSteps.containsKey(key)) {
    return Showcase(
        key: key,
        title: tutorialSteps[key]!.length == 2
            ? tutorialSteps[key]![1].translate()
            : null,
        titleTextStyle: textStyleTutorialTitle.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        description: tutorialSteps[key]![0].translate(),
        descTextStyle: textStyleTutorial.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer),
        tooltipPadding: const EdgeInsets.all(12.0),
        tooltipBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
        showArrow: showArrow,
        overlayOpacity: 0.0,
        blurValue: showArrow ? 2.5 : 0.0,
        disableMovingAnimation: true,
        disableScaleAnimation: false,
        scaleAnimationDuration: longAnimationDuration,
        scaleAnimationAlignment: Alignment.center,
        onToolTipClick: () => ShowCaseWidget.of(context).next(),
        child: child);
  } else {
    return Container(child: child);
  }
}
