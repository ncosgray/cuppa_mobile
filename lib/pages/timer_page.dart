/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    timer_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa Timer page
// - Build interface and interactivity

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/pages/prefs_page.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/tea_button_list.dart';
import 'package:cuppa_mobile/widgets/teacup.dart';
import 'package:cuppa_mobile/widgets/timer_countdown.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Cuppa Timer page
class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  // Build Timer page
  @override
  Widget build(BuildContext context) {
    // Determine layout based on device orientation
    bool layoutPortrait = getDeviceSize(context).isPortrait;

    return Scaffold(
      appBar: PlatformAdaptiveNavBar(
        isPoppable: false,
        title: appName,
        buttonTextDone: AppString.done_button.translate(),
        // Button to navigate to Preferences page
        actionIcon: tutorialTooltip(
          context: context,
          key: tutorialKey2,
          child: getPlatformSettingsIcon(),
        ),
        actionRoute: const PrefsWidget(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Flex(
                direction: layoutPortrait ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Countdown timers
                  Expanded(
                    flex: layoutPortrait ? 4 : 3,
                    child: Container(
                      padding: layoutPortrait
                          ? wideTimerLayoutPadding
                          : narrowTimerLayoutPadding,
                      alignment: layoutPortrait
                          ? Alignment.center
                          : Alignment.centerRight,
                      child: tutorialTooltip(
                        context: context,
                        key: tutorialKey1,
                        showArrow: false,
                        child: tutorialTooltip(
                          context: context,
                          key: tutorialKey5,
                          showArrow: false,
                          child: const FittedBox(
                            fit: BoxFit.fitHeight,
                            alignment: Alignment.center,
                            child: TimerCountdownWidget(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Teacup
                  Selector<AppProvider, bool>(
                    selector: (_, provider) => provider.stackedView,
                    builder: (context, stackedView, child) {
                      return Expanded(
                        flex: layoutPortrait && !stackedView ? 5 : 3,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: getDeviceSize(context).height * 0.45,
                          ),
                          padding: layoutPortrait
                              ? narrowTimerLayoutPadding
                              : wideTimerLayoutPadding,
                          alignment: layoutPortrait
                              ? Alignment.center
                              : Alignment.centerLeft,
                          child: teacup(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Tea brew start buttons
            const TeaButtonList(),
          ],
        ),
      ),
    );
  }
}
