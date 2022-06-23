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
// - Notification channels for platform code

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

  // Set up the brewing complete notification
  Future<Null> _sendNotification(int secs, String title, String text) async {
    try {
      notifyPlatform.invokeMethod(notifyMethodSetup, <String, dynamic>{
        notifyMethodSetupSecs: secs,
        notifyMethodSetupTitle: title,
        notifyMethodSetupText: text,
      });
    } on PlatformException {
      return;
    }
  }

  // Cancel the notification
  Future<Null> _cancelNotification() async {
    try {
      notifyPlatform.invokeMethod(notifyMethodCancel);
    } on PlatformException {
      return;
    }
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
        // Brewing complete
        _timerActive = false;
        _timerSeconds = 0;
        _timerEndTime = null;
        if (t != null) t.cancel();
        Prefs.clearNextAlarm();
        // Notify the rest of the app that the timer ended
        Provider.of<AppProvider>(context, listen: false).notify();
      }
    });
  }

  // Start a new brewing timer
  void _setTimer(Tea tea, [int secs = 0]) {
    setState(() {
      Prefs.clearNextAlarm();
      if (!_timerActive) _timerActive = true;
      tea.isActive = true;
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
      _timer = Timer.periodic(Duration(seconds: 1), _decrementTimer);
      _timerEndTime = DateTime.now().add(Duration(seconds: _timerSeconds + 1));
      Prefs.setNextAlarm(_timerEndTime!);
      // Notify the rest of the app that the timer started
      Provider.of<AppProvider>(context, listen: false).notify();
    });
  }

  // Start timer from stored prefs or shortcut
  void _checkNextTimer() {
    // Load saved brewing timer info from prefs
    int nextAlarm = Prefs.getNextAlarm();
    Tea? nextTea = Prefs.getActiveTea();
    if (nextAlarm > 0 && nextTea != null) {
      Duration diff = DateTime.fromMillisecondsSinceEpoch(nextAlarm)
          .difference(DateTime.now());
      if (diff.inSeconds > 0) {
        // Resume timer from stored prefs
        _setTimer(nextTea, diff.inSeconds);
        _doScroll = true;
      } else {
        Prefs.clearNextAlarm();
      }
    } else {
      Prefs.clearNextAlarm();
    }

    // Start a timer from shortcut selection
    quickActions.initialize((String shortcutType) async {
      int? teaIndex = int.tryParse(shortcutType.replaceAll(shortcutPrefix, ''));
      if (teaIndex != null) if (await _confirmTimer())
        _setTimer(Prefs.teaList[teaIndex]);
      _doScroll = true;
    });
  }

  // Autoscroll tea button list to specified tea
  void _scrollToTeaButton(Tea? tea) {
    if (tea != null && _doScroll && Prefs.teaList.length > teasMinCount) {
      BuildContext? target = GlobalObjectKey(tea.id).currentContext;
      if (target != null) Scrollable.ensureVisible(target);
    }
    _doScroll = false;
  }

  // Timer page state
  @override
  void initState() {
    super.initState();

    // Load tea settings
    Prefs.loadTeas();

    // Manage timers at app startup
    _checkNextTimer();
  }

  // Build Timer page
  @override
  Widget build(BuildContext context) {
    // Process tea list scroll request after build
    Future.delayed(
        Duration.zero, () => _scrollToTeaButton(Prefs.getActiveTea()));

    return PlatformAdaptiveScaffold(
        platform: appPlatform,
        isPoppable: false,
        title: appName,
        // Button to navigate to Preferences page
        actionIcon: getPlatformSettingsIcon(appPlatform),
        actionRoute: routePrefs,
        body: SafeArea(
            child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Countdown timer
              Container(
                  padding: const EdgeInsets.fromLTRB(48.0, 24.0, 48.0, 24.0),
                  width: 480.0,
                  height: 180.0,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.center,
                    child: Container(
                      width: (formatTimer(_timerSeconds)).length > 4
                          ? 480.0
                          : 420.0,
                      height: 180.0,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(12.0)),
                      ),
                      child: Center(
                        child: Text(
                          formatTimer(_timerSeconds),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 150.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )),
              // Teacup
              Expanded(
                child: Container(
                    constraints: BoxConstraints(maxWidth: deviceHeight * 0.6),
                    padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0.0),
                    alignment: Alignment.center,
                    child: Stack(children: [
                      // Teacup image
                      Image.asset(cupImageDefault,
                          fit: BoxFit.fitWidth, gaplessPlayback: true),
                      // While timing, gradually darken the tea in the cup
                      Opacity(
                          opacity: _timerActive && Prefs.getActiveTea() != null
                              ? (_timerSeconds / Prefs.getActiveTea()!.brewTime)
                              : 0.0,
                          child: Image.asset(cupImageTea,
                              fit: BoxFit.fitWidth, gaplessPlayback: true)),
                      // While timing, put a teabag in the cup
                      Visibility(
                          visible: _timerActive,
                          child: Image.asset(cupImageBag,
                              fit: BoxFit.fitWidth, gaplessPlayback: true)),
                    ])),
              ),
              // Tea brew start buttons
              SizedBox(
                  height: 170.0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 12.0),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        controller: _scrollController,
                        child: Row(
                            children: Prefs.teaList.map<TeaButton>((Tea tea) {
                          return TeaButton(
                              key: GlobalObjectKey(tea.id),
                              tea: tea,
                              active: tea.isActive,
                              fade:
                                  !_timerActive || tea.isActive ? false : true,
                              onPressed: (bool newValue) async {
                                if (!tea.isActive) if (await _confirmTimer())
                                  _setTimer(tea);
                              });
                        }).toList())),
                  )),
              // Cancel brewing button
              SizedBox(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
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
        )));
  }
}

// Widget defining a tea brew start button
class TeaButton extends StatelessWidget {
  TeaButton({
    Key? key,
    required this.tea,
    this.active = false,
    this.fade = false,
    required this.onPressed,
  }) : super(key: key);

  final Tea tea;
  final bool active;
  final bool fade;

  final ValueChanged<bool> onPressed;
  void _handleTap() {
    onPressed(!active);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 0.0),
        child: AnimatedOpacity(
          opacity: fade ? 0.4 : 1.0,
          duration: Duration(milliseconds: 400),
          child: Card(
              child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              decoration: BoxDecoration(
                color: active ? tea.getThemeColor(context) : Colors.transparent,
                borderRadius:
                    const BorderRadius.all(const Radius.circular(2.0)),
              ),
              child: Container(
                constraints:
                    BoxConstraints(minWidth: 80.0, maxWidth: double.infinity),
                margin: const EdgeInsets.all(8.0),
                // Timer icon with tea name
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: active ? Colors.white : tea.getThemeColor(context),
                      size: 64.0,
                    ),
                    Text(
                      tea.buttonName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color:
                            active ? Colors.white : tea.getThemeColor(context),
                      ),
                    ),
                    // Optional extra info: brew time and temp display
                    Visibility(
                        visible: Prefs.showExtra,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Brew time
                              Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      4.0, 2.0, 4.0, 0.0),
                                  child: Text(
                                    formatTimer(tea.brewTime),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                      color: active
                                          ? Colors.white
                                          : tea.getThemeColor(context),
                                    ),
                                  )),
                              // Brew temperature
                              Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      4.0, 2.0, 4.0, 0.0),
                                  child: Text(
                                    tea.tempDisplay,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                      color: active
                                          ? Colors.white
                                          : tea.getThemeColor(context),
                                    ),
                                  ))
                            ])),
                  ],
                ),
              ),
            ),
          )),
        ));
  }
}

// Widget defining a cancel brewing button
class CancelButton extends StatelessWidget {
  CancelButton({Key? key, this.active: false, required this.onPressed})
      : super(key: key);

  final bool active;
  final ValueChanged<bool> onPressed;

  void _handleTap() {
    onPressed(!active);
  }

  Widget build(BuildContext context) {
    // Button with "X" icon
    return TextButton.icon(
      label: Text(
        AppString.cancel_button.translate().toUpperCase(),
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: active
              ? Colors.red[400]
              : Theme.of(context).textTheme.button!.color!,
        ),
      ),
      icon: Icon(Icons.cancel,
          color: active
              ? Colors.red[400]
              : Theme.of(context).textTheme.button!.color!,
          size: 16.0),
      onPressed: active ? _handleTap : null,
    );
  }
}
