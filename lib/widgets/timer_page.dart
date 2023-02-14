/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    timer_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa Timer page
// - Build interface and interactivity
// - Start, confirm, cancel timers

import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/data/tea_timer.dart';
import 'package:cuppa_mobile/widgets/cancel_button.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/prefs_page.dart';
import 'package:cuppa_mobile/widgets/tea_button.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'dart:async';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

// Cuppa Timer page
class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // State variables
  final TeaTimer _timer1 = TeaTimer(notifyID: notifyID1);
  final TeaTimer _timer2 = TeaTimer(notifyID: notifyID2);
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
        Duration.zero, () => _scrollToTeaButton(_timer1.tea ?? _timer2.tea));

    // Get device dimensions
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    bool isLargeDevice =
        (deviceWidth >= largeDeviceSize && deviceHeight >= largeDeviceSize);
    bool layoutPortrait = deviceHeight > deviceWidth || isLargeDevice;

    return PlatformAdaptiveScaffold(
        platform: appPlatform,
        isPoppable: false,
        textScaleFactor: appTextScale,
        title: appName,
        // Button to navigate to Preferences page
        actionIcon: getPlatformSettingsIcon(appPlatform),
        actionRoute: const PrefsWidget(),
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
                                ? const EdgeInsets.fromLTRB(
                                    48.0, 24.0, 48.0, 12.0)
                                : const EdgeInsets.all(12.0),
                            alignment: layoutPortrait
                                ? Alignment.center
                                : Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              alignment: Alignment.center,
                              child: _countdownTimer(),
                            )),
                      ),
                      // Teacup
                      Expanded(
                        flex: layoutPortrait ? 3 : 2,
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: deviceHeight * 0.6),
                          padding: layoutPortrait
                              ? const EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 12.0)
                              : const EdgeInsets.fromLTRB(
                                  48.0, 12.0, 48.0, 12.0),
                          alignment: layoutPortrait
                              ? Alignment.center
                              : Alignment.centerLeft,
                          child: _teacup(),
                        ),
                      ),
                    ]),
              ),
              // Tea brew start buttons
              SizedBox(
                height: 190.0,
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0),
                  alignment: Alignment.center,
                  child: _teaButtonList(),
                ),
              ),
            ],
          ),
        ));
  }

  // Countdown timer display
  Widget _countdownTimer() {
    return Container(
      width: max(_timer1.timerString.length, _timer2.timerString.length) > 4
          ? 480.0
          : 420.0,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Column(children: [
        // Timer 1
        Visibility(
          visible: _timer1.isActive || _timerCount == 0,
          child: _timerText(_timer1.timerString),
        ),
        // Separator
        Visibility(
            visible: _timerCount > 1,
            child: Container(
                margin: const EdgeInsets.only(left: 24.0, right: 24.0),
                height: 12.0,
                color: Colors.white)),
        // Timer 2
        Visibility(
          visible: _timer2.isActive,
          child: _timerText(_timer2.timerString),
        ),
      ]),
    );
  }

  // Countdown timer text
  Text _timerText(String text) {
    return Text(text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        textScaleFactor: 1.0,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 150.0,
          color: Colors.white,
        ));
  }

  // Teacup graphic
  Widget _teacup() {
    return Stack(children: [
      // Border color adjusted for theme darkness
      Selector<AppProvider, bool>(
          selector: (_, provider) => provider.appTheme.blackTheme,
          builder: (context, blackTheme, child) => ColorFiltered(
              colorFilter: ColorFilter.mode(
                blackTheme ? const Color(0xff323232) : Colors.black,
                BlendMode.srcIn,
              ),
              child: Image.asset(cupImageBorder,
                  fit: BoxFit.fitWidth, gaplessPlayback: true))),
      // Teacup image
      Image.asset(cupImageDefault, fit: BoxFit.fitWidth, gaplessPlayback: true),
      // While timing, gradually darken the tea in the cup
      Opacity(
          opacity: _timerCount == 0
              ? 0.0
              : min(_timer1.timerPercent, _timer2.timerPercent),
          child: Image.asset(cupImageTea,
              fit: BoxFit.fitWidth, gaplessPlayback: true)),
      // While timing, put a teabag in the cup
      Visibility(
          visible: _timerCount > 0,
          child: Image.asset(cupImageBag,
              fit: BoxFit.fitWidth, gaplessPlayback: true)),
    ]);
  }

  // Horizontally scrollable list of available tea buttons
  Widget _teaButtonList() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        controller: _scrollController,
        child: Consumer<AppProvider>(builder: (context, provider, child) {
          if (provider.teaCount > 0) {
            // Tea buttons
            return Row(
                children: provider.teaList.map<Padding>((Tea tea) {
              return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Column(children: [
                    // Start brewing button
                    TeaButton(
                        key: GlobalObjectKey(tea.id),
                        tea: tea,
                        fade: !(_timerCount < timersMaxCount || tea.isActive),
                        onPressed: _timerCount < timersMaxCount && !tea.isActive
                            ? (_) => _setTimer(tea)
                            : null),
                    // Cancel brewing button
                    Visibility(
                      visible: tea.isActive,
                      child: CancelButton(
                          active: tea.isActive,
                          onPressed: (_) => _cancelTimerForTea(tea)),
                    )
                  ]));
            }).toList());
          } else {
            // Add button if tea list is empty
            return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _addButton());
          }
        }));
  }

  // Add button linking to Prefs page
  Widget _addButton() {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const PrefsWidget()));
        },
        child: Container(
          constraints: const BoxConstraints(
              maxHeight: 100.0, minWidth: 80.0, maxWidth: double.infinity),
          margin: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppString.teas_title.translate().toUpperCase(),
                style: textStyleButton.copyWith(color: textColorWarn),
              ),
              Icon(Icons.arrow_circle_right, size: 28.0, color: textColorWarn),
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
      int secs, String title, String text, int notifyID) async {
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
          ?.requestPermission();
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
        color: Colors.green,
        enableVibration: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound(notifySound),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
      iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: notifySoundIOS),
    );
    await notify.zonedSchedule(notifyID, title, text, notifyTime, notifyDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  // Confirmation dialog
  Future _confirmTimer() {
    if (_timerCount > 0) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return PlatformAdaptiveDialog(
              platform: appPlatform,
              title: Text(AppString.confirm_title.translate()),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(AppString.confirm_message_line1.translate()),
                    Text(AppString.confirm_message_line2.translate()),
                  ],
                ),
              ),
              buttonTextTrue: AppString.yes_button.translate(),
              buttonTextFalse: AppString.no_button.translate(),
            );
          });
    } else {
      return Future.value(true);
    }
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
      if (!resume) {
        // Start a new timer
        Provider.of<AppProvider>(context, listen: false).activateTea(tea);
        _sendNotification(
            tea.brewTime,
            AppString.notification_title.translate(),
            AppString.notification_text.translate(teaName: tea.name),
            !_timer1.isActive ? _timer1.notifyID : _timer2.notifyID);
      }

      // Set up timer state
      if (!_timer1.isActive) {
        _timer1.start(tea, _handleTick(_timer1));
      } else {
        _timer2.start(tea, _handleTick(_timer2));
      }
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
      int? teaIndex = int.tryParse(shortcutType.replaceAll(shortcutPrefix, ''));
      if (teaIndex != null) {
        AppProvider provider = Provider.of<AppProvider>(context, listen: false);
        if (teaIndex >= 0 && teaIndex < provider.teaCount) {
          if (await _confirmTimer()) {
            _cancelAllTimers();
            _setTimer(provider.teaList[teaIndex]);
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
