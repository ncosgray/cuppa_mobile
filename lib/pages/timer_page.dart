/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    timer_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa Timer page
// - Build interface and interactivity

import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/pages/prefs_page.dart';
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

    return adaptiveScaffold(
      body: SafeArea(
        left: false,
        top: true,
        right: false,
        bottom: false,
        child: Stack(
          children: [
            // Main page layout
            Column(
              children: [
                Expanded(
                  child: Selector<AppProvider, bool>(
                    selector: (_, provider) =>
                        provider.cupStyle == CupStyle.none,
                    builder: (context, hideCup, child) {
                      return Flex(
                        direction: layoutPortrait ? .vertical : .horizontal,
                        mainAxisAlignment: .center,
                        children: [
                          // Countdown timers
                          Expanded(
                            flex: layoutPortrait ? 4 : 3,
                            child: Container(
                              padding: timerLayoutPadding,
                              alignment: layoutPortrait || hideCup
                                  ? .center
                                  : .centerRight,
                              child: tutorialTooltip(
                                context: context,
                                key: tutorialKey1,
                                showArrow: false,
                                child: tutorialTooltip(
                                  context: context,
                                  key: tutorialKey5,
                                  showArrow: false,
                                  child: const FittedBox(
                                    fit: .fitHeight,
                                    alignment: .center,
                                    child: TimerCountdownWidget(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Teacup
                          Visibility(
                            visible: !hideCup,
                            child: Selector<AppProvider, bool>(
                              selector: (_, provider) => provider.stackedView,
                              builder: (context, stackedView, child) {
                                return Expanded(
                                  flex: layoutPortrait && !stackedView ? 5 : 3,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          getDeviceSize(context).height * 0.45,
                                    ),
                                    padding: timerLayoutPadding,
                                    alignment: layoutPortrait
                                        ? .center
                                        : .centerLeft,
                                    child: teacup(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Tea brew start buttons
                SafeArea(
                  left: true,
                  top: false,
                  right: true,
                  bottom: false,
                  child: const TeaButtonList(),
                ),
              ],
            ),
            // Floating button to navigate to Preferences page
            Positioned(
              top: layoutPortrait ? xsmallSpacing : largeSpacing,
              right: layoutPortrait ? smallSpacing : largeSpacing,
              child: tutorialTooltip(
                context: context,
                key: tutorialKey2,
                showBorder: true,
                child: adaptiveNavBarActionButton(
                  context,
                  icon: platformSettingsIcon,
                  onPressed: adaptiveOnPressed(
                    context,
                    route: const PrefsWidget(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
