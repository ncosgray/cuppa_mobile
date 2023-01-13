/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    timer_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa Timer page
// - Build interface and interactivity
// - Start, confirm, cancel timers

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/cancel_button.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/prefs_page.dart';
import 'package:cuppa_mobile/widgets/tea_button.dart';

import 'dart:async';
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
  bool _timerActive = false;
  int _timerSeconds = 0;
  DateTime? _timerEndTime;
  Timer? _timer;
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
      if (provider.teaCount == 0) {
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
        Duration.zero,
        () => _scrollToTeaButton(
            Provider.of<AppProvider>(context, listen: false).activeTea));

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
                      // Countdown timer
                      Expanded(
                        flex: 2,
                        child: Container(
                            padding: layoutPortrait
                                ? const EdgeInsets.fromLTRB(
                                    48.0, 12.0, 48.0, 12.0)
                                : const EdgeInsets.all(12.0),
                            alignment: layoutPortrait
                                ? Alignment.center
                                : Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              alignment: Alignment.center,
                              child: Container(
                                width: (formatTimer(_timerSeconds)).length > 4
                                    ? 480.0
                                    : 420.0,
                                clipBehavior: Clip.hardEdge,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                ),
                                child: Center(
                                  child: Text(
                                    formatTimer(_timerSeconds),
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.clip,
                                    textScaleFactor: 1.0,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 150.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ),
                      // Teacup
                      Expanded(
                        flex: layoutPortrait ? 3 : 2,
                        child: Container(
                            constraints:
                                BoxConstraints(maxWidth: deviceHeight * 0.6),
                            padding: layoutPortrait
                                ? const EdgeInsets.fromLTRB(
                                    18.0, 12.0, 18.0, 12.0)
                                : const EdgeInsets.fromLTRB(
                                    48.0, 12.0, 48.0, 12.0),
                            alignment: layoutPortrait
                                ? Alignment.center
                                : Alignment.centerLeft,
                            child: Stack(children: [
                              // Border color adjusted for theme darkness
                              Selector<AppProvider, bool>(
                                  selector: (_, provider) =>
                                      provider.appTheme.blackTheme,
                                  builder: (context, blackTheme, child) =>
                                      ColorFiltered(
                                          colorFilter: ColorFilter.mode(
                                            blackTheme
                                                ? Colors.grey.shade900
                                                : Colors.black,
                                            BlendMode.srcIn,
                                          ),
                                          child: Image.asset(cupImageBorder,
                                              fit: BoxFit.fitWidth,
                                              gaplessPlayback: true))),
                              // Teacup image
                              Image.asset(cupImageDefault,
                                  fit: BoxFit.fitWidth, gaplessPlayback: true),
                              // While timing, gradually darken the tea in the cup
                              Selector<AppProvider, Tea?>(
                                  selector: (_, provider) => provider.activeTea,
                                  builder: (context, tea, child) => Opacity(
                                      opacity: _timerActive && tea != null
                                          ? (_timerSeconds / tea.brewTime)
                                          : 0.0,
                                      child: Image.asset(cupImageTea,
                                          fit: BoxFit.fitWidth,
                                          gaplessPlayback: true))),
                              // While timing, put a teabag in the cup
                              Visibility(
                                  visible: _timerActive,
                                  child: Image.asset(cupImageBag,
                                      fit: BoxFit.fitWidth,
                                      gaplessPlayback: true)),
                            ])),
                      ),
                    ]),
              ),
              // Tea brew start buttons
              SizedBox(
                height: 140.0,
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      controller: _scrollController,
                      child: Consumer<AppProvider>(
                          builder: (context, provider, child) => Row(
                                  children: provider.teaList
                                      .map<TeaButton>((Tea tea) {
                                return TeaButton(
                                    key: GlobalObjectKey(tea.id),
                                    tea: tea,
                                    fade: !_timerActive || tea.isActive
                                        ? false
                                        : true,
                                    onPressed: (bool newValue) async {
                                      if (!tea.isActive) {
                                        if (await _confirmTimer()) {
                                          _setTimer(tea);
                                        }
                                      }
                                    });
                              }).toList()))),
                ),
              ),
              // Cancel brewing button
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CancelButton(
                        active: _timerActive ? true : false,
                        onPressed: (bool newValue) {
                          // Stop timing and reset
                          _timerActive = false;
                          _timerEndTime = DateTime.now();
                          _decrementTimer(_timer);
                          _cancelNotification();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // Set up the brewing complete notification
  Future<void> _sendNotification(int secs, String title, String text) async {
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

  // Cancel the notification
  Future<void> _cancelNotification() async {
    await notify.cancel(notifyID);
  }

  // Confirmation dialog
  Future _confirmTimer() {
    if (_timerActive) {
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

  // Update timer and handle brew finish
  void _decrementTimer(Timer? t) {
    setState(() {
      if (_timerEndTime != null) {
        _timerSeconds = _timerEndTime!.difference(DateTime.now()).inSeconds;
      } else {
        _timerSeconds = 0;
      }
      if (_timerSeconds <= 0) {
        AppProvider provider = Provider.of<AppProvider>(context, listen: false);

        // Brewing complete
        _timerActive = false;
        provider.clearActiveTea();
        _timerSeconds = 0;
        _timerEndTime = null;
        if (t != null) {
          t.cancel();
        }

        // Notify the rest of the app that the timer ended
        provider.notify();
      }
    });
  }

  // Start a new brewing timer
  void _setTimer(Tea tea, [int secs = 0]) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);

    setState(() {
      _timerActive = true;
      provider.clearActiveTea();
      provider.updateTea(tea, isActive: true);
      if (secs == 0) {
        // Set up new timer
        _timerSeconds = tea.brewTime;
        _sendNotification(
            _timerSeconds,
            AppString.notification_title.translate(),
            AppString.notification_text.translate(teaName: tea.name));
      } else {
        // Resume timer from stored prefs
        _timerSeconds = secs;
      }
      _timer = Timer.periodic(const Duration(seconds: 1), _decrementTimer);
      _timerEndTime = DateTime.now().add(Duration(seconds: _timerSeconds + 1));
      Prefs.setNextAlarm(_timerEndTime!);
    });
  }

  // Start timer from stored prefs
  void _checkNextTimer() {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);

    // Load saved brewing timer info from prefs
    int nextAlarm = Prefs.getNextAlarm();
    Tea? nextTea = provider.activeTea;
    if (nextAlarm > 0 && nextTea != null) {
      Duration diff = DateTime.fromMillisecondsSinceEpoch(nextAlarm)
          .difference(DateTime.now());
      if (diff.inSeconds > 0) {
        // Resume timer from stored prefs
        _setTimer(nextTea, diff.inSeconds);
        _doScroll = true;
      } else {
        provider.clearActiveTea();
      }
    } else {
      provider.clearActiveTea();
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
