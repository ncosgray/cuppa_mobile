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
// - Start, confirm, cancel timers

import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/dialogs.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/local_notifications.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/data/tea_timer.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/cancel_button.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/prefs_page.dart';
import 'package:cuppa_mobile/widgets/tea_button.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'dart:async';
import 'dart:math';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

// Cuppa Timer page
class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // State variables
  bool _showTimerIncrements = false;
  int _hideTimerIncrementsDelay = 0;
  final ScrollController _scrollController = ScrollController();
  bool _doScroll = false;

  // Timer page state
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppProvider provider = Provider.of<AppProvider>(context, listen: false);

      // Set default brew temp units based on locale
      provider.useCelsius = Prefs.loadUseCelsius() ?? isLocaleMetric;

      // Add default presets if no custom teas have been set
      if (provider.teaCount == 0 && !Prefs.teaPrefsExist()) {
        provider.loadDefaults();

        // Start a tutorial for new users
        if (Prefs.showTutorial) {
          ShowCaseWidget.of(context).startShowCase(tutorialSteps.keys.toList());
          Prefs.setSkipTutorial();
        }
      }

      // Manage timers
      _checkNextTimer();
      _checkShortcutTimer();
    });
  }

  // Build Timer page
  @override
  Widget build(BuildContext context) {
    // Process tea list scroll request after build
    Future.delayed(
      Duration.zero,
      () => _scrollToTeaButton(timer1.tea ?? timer2.tea),
    );

    // Delay before hiding increments buttons
    if (_hideTimerIncrementsDelay > 0) {
      _hideTimerIncrementsDelay--;
      if (_hideTimerIncrementsDelay <= 0) {
        setState(() => _showTimerIncrements = false);
      }
    }

    // Determine layout based on device orientation
    bool layoutPortrait = getDeviceSize(context).isPortrait;

    return Scaffold(
      appBar: PlatformAdaptiveNavBar(
        isPoppable: false,
        title: appName,
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
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            alignment: Alignment.center,
                            child: _countdownTimer(layoutPortrait),
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
                          child: _teacup(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Tea brew start buttons
            _teaButtonList(layoutPortrait),
          ],
        ),
      ),
    );
  }

  // Countdown timer display adjusted for orientation
  Widget _countdownTimer(bool layoutPortrait) {
    return Container(
      decoration: BoxDecoration(
        color: timerBackgroundColor,
        // Apply background colors to distinguish timers
        gradient: activeTimerCount > 0
            ? LinearGradient(
                begin:
                    layoutPortrait ? Alignment.topCenter : Alignment.centerLeft,
                end: layoutPortrait
                    ? Alignment.bottomCenter
                    : Alignment.centerRight,
                stops: List<double>.filled(
                  activeTimerCount,
                  !layoutPortrait && activeTimerCount > 1
                      ? timer1.timerString.length /
                          (timer1.timerString.length +
                              timer2.timerString.length)
                      : 0.5,
                ),
                colors: [
                  for (TeaTimer timer in timerList)
                    if (timer.tea != null) timer.tea!.getColor(),
                ],
              )
            : null,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: AnimatedSize(
        duration: shortAnimationDuration,
        curve: Curves.linear,
        child: activeTimerCount == 0
            ?
            // Idle timer
            _timerText()
            : Flex(
                // Determine layout by orientation
                direction: layoutPortrait ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Timer 1
                  AnimatedSize(
                    duration: longAnimationDuration,
                    curve: Curves.easeInOut,
                    child: timer1.isActive
                        ? _timerText(timer1)
                        : const SizedBox.shrink(),
                  ),
                  // Separator for timers with the same color
                  Visibility(
                    visible: activeTimerCount > 1 &&
                        timer1.tea?.color == timer2.tea?.color &&
                        timer1.tea?.colorShade == timer2.tea?.colorShade,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                      width: layoutPortrait ? 420.0 : 12.0,
                      height: layoutPortrait ? 12.0 : 140.0,
                      color: timerForegroundColor,
                    ),
                  ),
                  // Timer 2
                  AnimatedSize(
                    duration: longAnimationDuration,
                    curve: Curves.easeInOut,
                    child: timer2.isActive
                        ? _timerText(timer2)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
      ),
    );
  }

  // Countdown timer text with optional timer adjustment buttons
  Widget _timerText([TeaTimer? timer]) {
    String text = timer?.timerString ?? formatTimer(0);
    int secs = (timer?.timerSeconds ?? 0) > 3600
        ? 60 * incrementSeconds // minute increments for longer timer
        : incrementSeconds;

    return Selector<AppProvider, bool>(
      selector: (_, provider) => provider.hideIncrements,
      builder: (context, hideIncrements, child) => Row(
        children: [
          // Silence button
          timer != null && (_showTimerIncrements || !hideIncrements)
              ? _silenceButton(timer)
              : spacerWidget,
          IgnorePointer(
            ignoring: timer == null || !hideIncrements,
            child: GestureDetector(
              // Toggle display of timer increment buttons
              onTap: () => setState(() {
                _showTimerIncrements = !_showTimerIncrements;
                _hideTimerIncrementsDelay = hideTimerIncrementsDelay;
              }),
              // Timer time remaining
              child: SizedBox(
                width: text.length * 96.0,
                child: Container(
                  padding: timerPadding,
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    textScaler: TextScaler.noScaling,
                    style: textStyleTimer,
                  ),
                ),
              ),
            ),
          ),
          // Increment +/- buttons
          timer != null && (_showTimerIncrements || !hideIncrements)
              ? Column(
                  children: [
                    _incrementButton(timer, secs),
                    _incrementButton(timer, -secs),
                  ],
                )
              : spacerWidget,
        ],
      ),
    );
  }

  // Silence timer button
  Widget _silenceButton(TeaTimer timer) {
    return Container(
      margin: smallDefaultPadding,
      child: TextButton(
        // Toggle silent status for this timer
        onPressed: () {
          if (timer.tea != null) {
            setState(() => timer.toggleSilent());

            // Update the notification
            sendNotification(
              timer.tea!.brewTimeRemaining,
              AppString.notification_title.translate(),
              AppString.notification_text.translate(teaName: timer.tea!.name),
              timer.notifyID,
              silent: timer.isSilent,
            );
          }
          _hideTimerIncrementsDelay = hideTimerIncrementsDelay;
        },
        // Button with speaker icon
        child: Icon(
          timer.isSilent ? Icons.volume_off : Icons.volume_up,
          color: timerForegroundColor,
          size: 28.0,
        ),
      ),
    );
  }

  // Increment timer button
  Widget _incrementButton(TeaTimer timer, int secs) {
    int buttonValue = secs.abs() > 60 ? secs.abs() ~/ 60 : secs.abs();
    String buttonValueUnit = secs.abs() > 60
        ? AppString.unit_minutes.translate()
        : AppString.unit_seconds.translate();

    return Container(
      margin: smallDefaultPadding,
      child: TextButton(
        // Increment this timer
        onPressed: () {
          if (timer.tea != null) {
            if (Provider.of<AppProvider>(context, listen: false)
                .incrementTimer(timer.tea!, secs)) {
              // If adjustment was successful, update the notification
              sendNotification(
                timer.tea!.brewTimeRemaining,
                AppString.notification_title.translate(),
                AppString.notification_text.translate(teaName: timer.tea!.name),
                timer.notifyID,
                silent: timer.isSilent,
              );
            }
          }
          _hideTimerIncrementsDelay = hideTimerIncrementsDelay;
        },
        // Button with +/- icon and increment amount
        child: Column(
          children: [
            Icon(
              secs > 0 ? incrementPlusIcon : incrementMinusIcon,
              color: timerForegroundColor,
              size: 28.0,
            ),
            Text(
              '$buttonValue$buttonValueUnit',
              style: textStyleTimerIncrement,
            ),
          ],
        ),
      ),
    );
  }

  // Teacup graphic
  Widget _teacup() {
    return Stack(
      children: [
        // Border color adjusted for theme darkness
        Selector<AppProvider, bool>(
          selector: (_, provider) => provider.appTheme.blackTheme,
          builder: (context, blackTheme, child) => ColorFiltered(
            colorFilter: ColorFilter.mode(
              blackTheme ? const Color(0xff323232) : Colors.black,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              cupImageBorder,
              fit: BoxFit.fitWidth,
              gaplessPlayback: true,
            ),
          ),
        ),
        // Teacup image
        Image.asset(
          cupImageDefault,
          fit: BoxFit.fitWidth,
          gaplessPlayback: true,
        ),
        // While timing, gradually darken the tea in the cup
        Opacity(
          opacity: activeTimerCount == 0
              ? 0.0
              : min(timer1.timerPercent, timer2.timerPercent),
          child: Image.asset(
            cupImageTea,
            fit: BoxFit.fitWidth,
            gaplessPlayback: true,
          ),
        ),
        // While timing, put a teabag in the cup
        Visibility(
          visible: activeTimerCount > 0,
          child: Image.asset(
            cupImageBag,
            fit: BoxFit.fitWidth,
            gaplessPlayback: true,
          ),
        ),
      ],
    );
  }

  // List/grid of available tea buttons
  Widget _teaButtonList(bool layoutPortrait) {
    return Selector<AppProvider, ({List<Tea> teaList, bool stackedView})>(
      selector: (_, provider) => (
        teaList: provider.teaList,
        stackedView: provider.stackedView,
      ),
      builder: (context, buttonData, child) {
        List<Widget> teaButtonRows = [];

        if (buttonData.teaList.isNotEmpty) {
          if (buttonData.stackedView && getDeviceSize(context).isLargeDevice) {
            // Arrange into two rows of tea buttons for large screens
            int topRowLength = (buttonData.teaList.length / 2).floor();
            teaButtonRows.add(
              _teaButtonRow(buttonData.teaList.sublist(0, topRowLength)),
            );
            teaButtonRows.add(
              _teaButtonRow(buttonData.teaList.sublist(topRowLength)),
            );
          } else if (buttonData.stackedView && layoutPortrait) {
            // Arrange into multiple rows for small screens
            for (List<Tea> teaRow
                in buttonData.teaList.slices(stackedViewTeaCount)) {
              teaButtonRows.add(_teaButtonRow(teaRow));
            }
          } else {
            // Single row of tea buttons
            teaButtonRows.add(_teaButtonRow(buttonData.teaList));
          }
        } else {
          // Add button if tea list is empty
          teaButtonRows.add(_addButton());
        }

        // Build tea button list/grid container
        return Container(
          padding: noPadding,
          height: teaButtonRows.length > 1 ? 376.0 : null,
          alignment: Alignment.center,
          child: tutorialTooltip(
            context: context,
            key: tutorialKey3,
            child: tutorialTooltip(
              context: context,
              key: tutorialKey4,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    smallSpacerWidget,
                    ...teaButtonRows,
                    smallSpacerWidget,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Horizontally scrollable list of tea buttons
  Widget _teaButtonRow(List<Tea> teas) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      controller: _scrollController,
      child: Row(
        children: [
          smallSpacerWidget,
          ...teas.map<Widget>((Tea tea) => _teaButton(tea)),
          smallSpacerWidget,
        ],
      ),
    );
  }

  // Tea button paired with cancel button
  Widget _teaButton(Tea tea) {
    return Column(
      children: [
        // Start brewing button
        TeaButton(
          key: GlobalObjectKey(tea.id),
          tea: tea,
          fade: !(activeTimerCount < timersMaxCount || tea.isActive),
          onPressed: activeTimerCount < timersMaxCount && !tea.isActive
              ? (_) => _setTimer(tea)
              : null,
        ),
        // Cancel brewing button
        Container(
          constraints: const BoxConstraints(
            minHeight: 34.0,
          ),
          child: Visibility(
            visible: tea.isActive,
            child: CancelButton(
              active: tea.isActive,
              onPressed: (_) => _cancelTimerForTea(tea),
            ),
          ),
        ),
      ],
    );
  }

  // Add button linking to Prefs page
  Widget _addButton() {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: largeDefaultPadding,
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const PrefsWidget())),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 106.0,
            minWidth: 88.0,
          ),
          margin: largeDefaultPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppString.teas_title.translate(),
                style: textStyleButton.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              navigateIcon(color: Theme.of(context).colorScheme.error),
            ],
          ),
        ),
      ),
    );
  }

  // Ticker handler for a TeaTimer
  void Function(Timer? ticker) _handleTick(TeaTimer timer) {
    return (ticker) {
      if (timer.isActive) {
        int timerSeconds = timer.timerSeconds;
        if (timerSeconds > 0) {
          timer.decrement();
          if (timer.timerSeconds != timerSeconds) {
            // Only update UI if the timer countdown changed
            setState(() {});
          }
        } else {
          setState(() {
            // Brewing complete
            if (timer.tea != null) {
              Provider.of<AppProvider>(context, listen: false)
                  .deactivateTea(timer.tea!);
            }
            timer.stop();
          });
        }
      }
    };
  }

  // Start a new brewing timer
  void _setTimer(Tea tea, {bool resume = false}) {
    setState(() {
      // Determine next available timer
      TeaTimer timer = !timer1.isActive ? timer1 : timer2;

      if (!resume) {
        AppProvider provider = Provider.of<AppProvider>(context, listen: false);

        // Start a new timer
        provider.activateTea(tea, timer.notifyID);
        sendNotification(
          tea.brewTime,
          AppString.notification_title.translate(),
          AppString.notification_text.translate(teaName: tea.name),
          timer.notifyID,
        );

        // Update timer stats, if enabled
        if (provider.collectStats) {
          Stats.insertStat(Stat(tea: tea));
        }
      } else if (tea.timerNotifyID != null) {
        // Resume with same timer ID
        timer = tea.timerNotifyID == timer1.notifyID ? timer1 : timer2;
      }

      // Set up timer state
      timer.start(tea, _handleTick(timer));
    });
  }

  // Cancel a timer
  void _cancelTimer(TeaTimer timer) async {
    timer.reset();
    await notify.cancel(timer.notifyID);
  }

  // Cancel timer for a given tea
  void _cancelTimerForTea(Tea tea) {
    for (TeaTimer timer in timerList) {
      if (timer.tea == tea) {
        _cancelTimer(timer);
      }
    }
  }

  // Force cancel and reset all timers
  void _cancelAllTimers() {
    setState(() {
      Provider.of<AppProvider>(context, listen: false).clearActiveTea();
      for (TeaTimer timer in timerList) {
        _cancelTimer(timer);
      }
    });
  }

  // Start timer from stored prefs
  void _checkNextTimer() {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);

    // Load saved brewing timer info from prefs
    for (Tea tea in provider.activeTeas) {
      if (tea.brewTimeRemaining > 0) {
        // Resume timer from stored prefs
        _setTimer(tea, resume: true);
        _doScroll = true;
      } else {
        provider.deactivateTea(tea);
      }
    }
  }

  // Start a timer from shortcut selection
  void _checkShortcutTimer() {
    quickActions.initialize((String shortcutType) async {
      AppProvider provider = Provider.of<AppProvider>(context, listen: false);
      int? teaID = int.tryParse(shortcutType.replaceAll(shortcutPrefixID, ''));
      int? teaIndex = int.tryParse(shortcutType.replaceAll(shortcutPrefix, ''));
      if (teaID != null) {
        // Prefer lookup by tea ID
        teaIndex = provider.teaList.indexWhere((tea) => tea.id == teaID);
      }
      if (teaIndex != null) {
        if (teaIndex >= 0 && teaIndex < provider.teaCount) {
          Tea tea = provider.teaList[teaIndex];
          if (!tea.isActive) {
            if (activeTimerCount >= timersMaxCount) {
              // Ask to cancel and free a timer slot if needed
              if (await showConfirmDialog(
                context: context,
                body: Text(AppString.confirm_message_line1.translate()),
                bodyExtra: Text(AppString.confirm_message_line2.translate()),
              )) {
                _cancelAllTimers();
              } else {
                return;
              }
            }

            // Start timer from shortcut
            _setTimer(tea);
            _doScroll = true;
          }
        }
      }
    });
  }

  // Autoscroll tea button list to specified tea
  void _scrollToTeaButton(Tea? tea) {
    if (tea != null && _doScroll) {
      // Ensure we are on the home screen
      Navigator.of(context).popUntil((route) => route.isFirst);

      BuildContext? target = GlobalObjectKey(tea.id).currentContext;
      if (target != null) {
        Scrollable.ensureVisible(target);
      }
    }
    _doScroll = false;
  }
}
