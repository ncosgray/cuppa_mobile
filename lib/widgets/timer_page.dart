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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

// Cuppa Timer page
class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // State variables
  final TeaTimer _timer1 = TeaTimer(notifyID: notifyID1);
  final TeaTimer _timer2 = TeaTimer(notifyID: notifyID2);
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
      () => _scrollToTeaButton(_timer1.tea ?? _timer2.tea),
    );

    // Delay before hiding increments buttons
    if (_hideTimerIncrementsDelay > 0) {
      _hideTimerIncrementsDelay--;
      if (_hideTimerIncrementsDelay <= 0) {
        setState(() => _showTimerIncrements = false);
      }
    }

    // Determine layout based on device size
    bool layoutPortrait = getDeviceSize(context).isPortrait ||
        getDeviceSize(context).isLargeDevice;

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
              flex: layoutPortrait ? 8 : 2,
              child: Flex(
                // Determine layout by device size
                direction: layoutPortrait ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Countdown timers
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: layoutPortrait
                          ? const EdgeInsets.fromLTRB(48.0, 18.0, 48.0, 0.0)
                          : const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
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
                  Expanded(
                    flex: layoutPortrait ? 3 : 2,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: getDeviceSize(context).height * 0.6,
                      ),
                      padding: layoutPortrait
                          ? const EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 0.0)
                          : const EdgeInsets.fromLTRB(48.0, 12.0, 12.0, 0.0),
                      alignment: layoutPortrait
                          ? Alignment.center
                          : Alignment.centerLeft,
                      child: _teacup(),
                    ),
                  ),
                ],
              ),
            ),
            // Tea brew start buttons
            Container(
              margin: largeDefaultPadding,
              alignment: Alignment.center,
              child: _teaButtonList(),
            ),
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
        gradient: _timerCount > 0
            ? LinearGradient(
                begin:
                    layoutPortrait ? Alignment.topCenter : Alignment.centerLeft,
                end: layoutPortrait
                    ? Alignment.bottomCenter
                    : Alignment.centerRight,
                stops: List<double>.filled(
                  _timerCount,
                  !layoutPortrait && _timerCount > 1
                      ? _timer1.timerString.length /
                          (_timer1.timerString.length +
                              _timer2.timerString.length)
                      : 0.5,
                ),
                colors: [
                  for (Tea? tea in [_timer1.tea, _timer2.tea])
                    if (tea != null) tea.getColor(),
                ],
              )
            : null,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: AnimatedSize(
        duration: shortAnimationDuration,
        curve: Curves.linear,
        child: _timerCount == 0
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
                    child: _timer1.isActive
                        ? _timerText(_timer1)
                        : const SizedBox.shrink(),
                  ),
                  // Separator for timers with the same color
                  Visibility(
                    visible: _timerCount > 1 &&
                        _timer1.tea?.color == _timer2.tea?.color &&
                        _timer1.tea?.colorShade == _timer2.tea?.colorShade,
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
                    child: _timer2.isActive
                        ? _timerText(_timer2)
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
          spacerWidget,
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
                width: text.length * 90.0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 150.0,
                      color: timerForegroundColor,
                    ),
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
              _sendNotification(
                timer.tea!.brewTimeRemaining,
                AppString.notification_title.translate(),
                AppString.notification_text.translate(teaName: timer.tea!.name),
                timer.notifyID,
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
              style: const TextStyle(
                color: timerForegroundColor,
                fontSize: 16.0,
              ),
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
          opacity: _timerCount == 0
              ? 0.0
              : min(_timer1.timerPercent, _timer2.timerPercent),
          child: Image.asset(
            cupImageTea,
            fit: BoxFit.fitWidth,
            gaplessPlayback: true,
          ),
        ),
        // While timing, put a teabag in the cup
        Visibility(
          visible: _timerCount > 0,
          child: Image.asset(
            cupImageBag,
            fit: BoxFit.fitWidth,
            gaplessPlayback: true,
          ),
        ),
      ],
    );
  }

  // Horizontally scrollable list of available tea buttons
  Widget _teaButtonList() {
    return tutorialTooltip(
      context: context,
      key: tutorialKey3,
      child: tutorialTooltip(
        context: context,
        key: tutorialKey4,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          controller: _scrollController,
          child: Consumer<AppProvider>(
            builder: (context, provider, child) {
              if (provider.teaCount > 0) {
                // Tea buttons
                return Row(
                  children: provider.teaList.map<Widget>((Tea tea) {
                    return Column(
                      children: [
                        // Start brewing button
                        Padding(
                          padding: largeDefaultPadding,
                          child: TeaButton(
                            key: GlobalObjectKey(tea.id),
                            tea: tea,
                            fade:
                                !(_timerCount < timersMaxCount || tea.isActive),
                            onPressed:
                                _timerCount < timersMaxCount && !tea.isActive
                                    ? (_) => _setTimer(tea)
                                    : null,
                          ),
                        ),
                        // Cancel brewing button
                        Container(
                          constraints: const BoxConstraints(
                            minHeight: 48.0,
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
                  }).toList(),
                );
              } else {
                // Add button if tea list is empty
                return _addButton();
              }
            },
          ),
        ),
      ),
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
            minHeight: 116.0,
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

  // Count of currently active timers
  int get _timerCount {
    return [_timer1.isActive, _timer2.isActive]
        .where((active) => active)
        .length;
  }

  // Set up the brewing complete notification
  Future<void> _sendNotification(
    int secs,
    String title,
    String text,
    int notifyID,
  ) async {
    tz.TZDateTime notifyTime =
        tz.TZDateTime.now(tz.local).add(Duration(seconds: secs));

    // Request notification permissions
    if (appPlatform == TargetPlatform.iOS) {
      await notify
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else {
      await notify
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // Configure and schedule the alarm
    NotificationDetails notifyDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        notifyChannel,
        AppString.notification_channel_name.translate(),
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        channelShowBadge: true,
        showWhen: true,
        enableLights: true,
        color: timerBackgroundColor,
        enableVibration: true,
        vibrationPattern: notifyVibratePattern,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound(notifySound),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
        sound: notifySoundIOS,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
    await notify.zonedSchedule(
      notifyID,
      title,
      text,
      notifyTime,
      notifyDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
      TeaTimer timer = !_timer1.isActive ? _timer1 : _timer2;

      if (!resume) {
        AppProvider provider = Provider.of<AppProvider>(context, listen: false);

        // Start a new timer
        provider.activateTea(tea, timer.notifyID);
        _sendNotification(
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
        timer = tea.timerNotifyID == _timer1.notifyID ? _timer1 : _timer2;
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
    if (_timer1.tea == tea) {
      _cancelTimer(_timer1);
    } else if (_timer2.tea == tea) {
      _cancelTimer(_timer2);
    }
  }

  // Force cancel and reset all timers
  void _cancelAllTimers() {
    setState(() {
      Provider.of<AppProvider>(context, listen: false).clearActiveTea();
      _cancelTimer(_timer1);
      _cancelTimer(_timer2);
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
            if (_timerCount >= timersMaxCount) {
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
