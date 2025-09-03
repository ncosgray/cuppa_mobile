/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tutorial.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tutorial

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';

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
Widget tutorialTooltip({
  required BuildContext context,
  required GlobalKey key,
  bool showArrow = true,
  bool showBorder = false,
  required Widget child,
}) {
  if (tutorialSteps.containsKey(key)) {
    return Showcase(
      key: key,
      title: tutorialSteps[key]!.length == 2
          ? tutorialSteps[key]![1].translate()
          : null,
      titleTextStyle: textStyleTutorialTitle.copyWith(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      titleAlignment: Alignment.centerLeft,
      description: tutorialSteps[key]![0].translate(),
      descTextStyle: textStyleTutorial.copyWith(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      descriptionAlignment: Alignment.centerLeft,
      tooltipPadding: const EdgeInsets.all(12),
      tooltipBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
      showArrow: showArrow,
      overlayOpacity: 0,
      blurValue: showArrow && !showBorder ? 2.5 : 0.0,
      targetShapeBorder: RoundedRectangleBorder(
        side: BorderSide(
          color: showBorder
              ? Theme.of(context).colorScheme.error
              : Colors.transparent,
          width: 4,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      tooltipActionConfig: const TooltipActionConfig(
        alignment: MainAxisAlignment.end,
        position: TooltipActionPosition.inside,
        gapBetweenContentAndAction: 0,
      ),
      tooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: '',
          tailIcon: ActionButtonIcon(
            icon: forwardIcon(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          backgroundColor: Colors.transparent,
          textStyle: TextStyle(color: Theme.of(context).colorScheme.error),
          padding: EdgeInsets.zero,
        ),
      ],
      disableMovingAnimation: true,
      disableScaleAnimation: false,
      scaleAnimationDuration: longAnimationDuration,
      scaleAnimationAlignment: Alignment.center,
      disposeOnTap: false,
      onTargetClick: () => ShowCaseWidget.of(context).next(),
      onToolTipClick: () => ShowCaseWidget.of(context).next(),
      child: child,
    );
  } else {
    return Container(child: child);
  }
}
