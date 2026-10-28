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

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/pages/prefs_page.dart';
import 'package:cuppa_mobile/widgets/quick_timer_button.dart';
import 'package:cuppa_mobile/widgets/tea_button_list.dart';
import 'package:cuppa_mobile/widgets/teacup.dart';
import 'package:cuppa_mobile/widgets/timer_countdown.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

// Cuppa Timer page
class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  // Build Timer page
  @override
  Widget build(BuildContext context) {
    // Determine layout based on device orientation
    bool layoutPortrait = getDeviceSize(context).isPortrait;
    final GlassVerticalBarData? strip = verticalBarStrip(context);
    final bool inStrip = strip != null;

    return adaptiveScaffold(
      resizeToAvoidBottomInset: false,
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
                    builder: (context, hideCup, child) => SafeArea(
                      // Keep clear of iPhone Duo's vertical strip
                      left: inStrip,
                      top: false,
                      right: inStrip,
                      bottom: false,
                      child: Flex(
                        direction: layoutPortrait ? .vertical : .horizontal,
                        mainAxisAlignment: .center,
                        children: [
                          // Countdown timers
                          Expanded(
                            flex: layoutPortrait ? 4 : 3,
                            child: Container(
                              padding: timerLayoutPadding.add(
                                .only(top: navBarTopInset),
                              ),
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
                                    padding: timerLayoutPadding.add(
                                      .only(top: navBarTopInset),
                                    ),
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
                      ),
                    ),
                  ),
                ),
                // Tea brew start buttons
                SafeArea(
                  left: true,
                  top: false,
                  right: true,
                  bottom: false,
                  child:
                      Selector<
                        AppProvider,
                        ({double calculatedScale, bool stackedView})
                      >(
                        selector: (_, provider) => (
                          calculatedScale:
                              provider.buttonSize.scale +
                              (provider.showExtraList.isEmpty ? .6 : .8),
                          stackedView: provider.stackedView,
                        ),
                        builder: (context, listData, child) => Container(
                          constraints: BoxConstraints(
                            minHeight:
                                (teaButtonHeight * listData.calculatedScale) +
                                cancelButtonHeight,
                          ),
                          child: TeaButtonList(
                            stackedView: layoutPortrait && listData.stackedView,
                          ),
                        ),
                      ),
                ),
              ],
            ),
            // Floating buttons to start a Quick Timer and navigate to
            // Preferences page, moved into iPhone Duo's strip where it has one
            ..._floatingNavButtons(
              context,
              strip: strip,
              quickTimerButton: tutorialTooltip(
                context: context,
                key: tutorialKey6,
                showBorder: true,
                child: const QuickTimerButton(),
              ),
              prefsButton: tutorialTooltip(
                context: context,
                key: tutorialKey2,
                showBorder: true,
                child: adaptiveNavBarActionButton(
                  context,
                  icon: platformSettingsIcon,
                  semanticLabel: AppString.prefs_title.translate(),
                  onPressed: adaptiveOnPressed(
                    context,
                    route: const PrefsWidget(),
                    transitionUp: true,
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

// Positions the floating buttons in the top corners of the screen, or stacks
// them down iPhone Duo's strip as the pinned chrome on other pages is
List<Widget> _floatingNavButtons(
  BuildContext context, {
  required GlassVerticalBarData? strip,
  required Widget quickTimerButton,
  required Widget prefsButton,
}) {
  if (strip != null) {
    // Controls sit a fixed inset from the strip's inner edge
    final double edgeOffset =
        strip.width -
        GlassVerticalBarMetrics.inset -
        GlassVerticalBarMetrics.controlExtent;
    final bool stripOnRight =
        (strip.edge == .trailing) == (Directionality.of(context) == .ltr);
    return [
      Positioned(
        // The Stack is already inside a top SafeArea
        top: strip.top - MediaQuery.viewPaddingOf(context).top,
        left: stripOnRight ? null : edgeOffset,
        right: stripOnRight ? edgeOffset : null,
        child: Column(
          spacing: GlassVerticalBarMetrics.spacing,
          children: [quickTimerButton, prefsButton],
        ),
      ),
    ];
  }

  return [
    _floatingNavButton(isRight: false, child: quickTimerButton),
    _floatingNavButton(isRight: true, child: prefsButton),
  ];
}

// Positions a floating button in a top corner of the screen
Widget _floatingNavButton({required bool isRight, required Widget child}) {
  return Positioned(
    top: navBarTopInset,
    left: isRight ? null : 0,
    right: isRight ? 0 : null,
    child: SafeArea(
      top: false,
      left: !isRight,
      right: isRight,
      bottom: false,
      // Aligned with the pinned chrome; the Stack is already inside a SafeArea
      child: Padding(
        padding: EdgeInsets.only(
          left: isRight ? 0.0 : navBarChromeInset,
          right: isRight ? navBarChromeInset : 0.0,
        ),
        child: child,
      ),
    ),
  );
}
