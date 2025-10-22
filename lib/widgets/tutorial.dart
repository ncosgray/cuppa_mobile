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

// Start the tutorial
void startTutorial() {
  ShowcaseView.get().startShowCase(
    tutorialSteps.keys.toList(),
    delay: Duration(milliseconds: 400),
  );
}

// Define a tutorial tooltip
Widget tutorialTooltip({
  required BuildContext context,
  required GlobalKey key,
  bool showArrow = true,
  bool showBorder = false,
  required Widget child,
}) {
  if (tutorialSteps.containsKey(key)) {
    Color backgroundColor = Theme.of(context).colorScheme.primaryContainer;
    Color foregroundColor = Theme.of(context).colorScheme.onPrimaryContainer;
    Color highlightColor = Theme.of(context).colorScheme.error;
    return Showcase(
      key: key,
      title: tutorialSteps[key]!.length == 2
          ? tutorialSteps[key]![1].translate()
          : null,
      titleTextStyle: textStyleTutorialTitle.copyWith(color: foregroundColor),
      titleAlignment: Alignment.centerLeft,
      description: tutorialSteps[key]![0].translate(),
      descTextStyle: textStyleTutorial.copyWith(color: foregroundColor),
      descriptionAlignment: Alignment.centerLeft,
      tooltipPadding: const EdgeInsets.all(12),
      tooltipBackgroundColor: backgroundColor,
      showArrow: showArrow,
      overlayOpacity: 0,
      blurValue: showArrow && !showBorder ? 2.5 : 0.0,
      targetShapeBorder: RoundedRectangleBorder(
        side: BorderSide(
          color: showBorder ? highlightColor : Colors.transparent,
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
            icon: key == tutorialSteps.keys.toList().last
                ? doneIcon(color: foregroundColor)
                : forwardIcon(color: foregroundColor),
          ),
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
        ),
      ],
      disableMovingAnimation: true,
      disableScaleAnimation: false,
      scaleAnimationDuration: longAnimationDuration,
      scaleAnimationAlignment: Alignment.center,
      onToolTipClick: () => ShowcaseView.get().next(),
      child: child,
    );
  } else {
    return Container(child: child);
  }
}
