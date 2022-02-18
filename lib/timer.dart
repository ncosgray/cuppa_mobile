/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    timer.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa timer widgets and logic
// - Build interface and interactivity
// - Start, confirm, cancel timers
// - Notification channels for platform code

import 'localization.dart';
import 'main.dart';
import 'platform_adaptive.dart';
import 'prefs.dart';

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Cuppa Timer page
class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // Cup images
  static final String cupImageDefault = 'images/Cuppa_hires_default.png';
  static final String cupImageBag = 'images/Cuppa_hires_bag.png';
  static final String cupImageTea = 'images/Cuppa_hires_tea.png';

  // State variables
  bool _timerActive = false;
  Tea? _whichActive;
  int _timerSeconds = 0;
  DateTime? _timerEndTime;
  Timer? _timer;

  // Notification channel
  static const platform =
      const MethodChannel('com.nathanatos.Cuppa/notification');

  // Set up the brewing complete notification
  Future<Null> _sendNotification(int secs, String title, String text) async {
    try {
      platform.invokeMethod('setupNotification', <String, dynamic>{
        'secs': secs,
        'title': title,
        'text': text,
      });
    } on PlatformException {
      return;
    }
  }

  // Cancel the notification
  Future<Null> _cancelNotification() async {
    try {
      platform.invokeMethod('cancelNotification');
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
              title: Text(AppLocalizations.translate('confirm_title')),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(AppLocalizations.translate('confirm_message_line1')),
                    Text(AppLocalizations.translate('confirm_message_line2')),
                  ],
                ),
              ),
              buttonTextTrue: AppLocalizations.translate('yes_button'),
              buttonTextFalse: AppLocalizations.translate('no_button'),
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
        _whichActive = null;
        _timerSeconds = 0;
        _timerEndTime = null;
        if (t != null) t.cancel();
        Prefs.clearNextAlarm();
      }
    });
  }

  // Start a new brewing timer
  void _setTimer(Tea tea, [int secs = 0]) {
    setState(() {
      if (!_timerActive) _timerActive = true;
      _whichActive = tea;
      if (secs == 0) {
        // Set up new timer
        _timerSeconds = tea.brewTime;
        _sendNotification(
            _timerSeconds,
            AppLocalizations.translate('notification_title'),
            AppLocalizations.translate('notification_text')
                .replaceAll('{{tea_name}}', tea.name));
      } else {
        // Resume timer from stored prefs
        _timerSeconds = secs;
      }
      _timer = Timer.periodic(Duration(seconds: 1), _decrementTimer);
      _timerEndTime = DateTime.now().add(Duration(seconds: _timerSeconds + 1));
      Prefs.setNextAlarm(tea.name, _timerEndTime!);
    });
  }

  // Load next brewing timer info from shared prefs
  void _checkNextAlarm() {
    Prefs.getTeas();
    Prefs.getNextAlarm();
    if (Prefs.nextAlarm > 0) {
      Duration diff = DateTime.fromMillisecondsSinceEpoch(Prefs.nextAlarm)
          .difference(DateTime.now());
      if (diff.inSeconds > 0) {
        // Resume timer from stored prefs
        Tea? nextTea =
            teaList.firstWhereOrNull((tea) => tea.name == Prefs.nextTeaName);
        if (nextTea != null) _setTimer(nextTea, diff.inSeconds);
      } else {
        Prefs.clearNextAlarm();
      }
    } else {
      Prefs.clearNextAlarm();
    }
  }

  // Refresh tea settings and set up quick actions
  void _refreshTeas() {
    setState(() {
      // Load user tea steep times
      Prefs.getTeas();
    });
  }

  // Timer page state
  @override
  void initState() {
    super.initState();

    // Check for an existing timer and resume if needed
    _checkNextAlarm();

    // Handle quick action selection
    quickActions.initialize((String shortcutType) async {
      int? teaIndex = int.tryParse(shortcutType.replaceAll(shortcutPrefix, ''));
      if (teaIndex != null) if (await _confirmTimer())
        _setTimer(teaList[teaIndex]);
    });
  }

  // Build Timer page
  @override
  Widget build(BuildContext context) {
    // Refresh tea settings and shortcuts on build
    _refreshTeas();

    return Scaffold(
        appBar:
            PlatformAdaptiveAppBar(title: Text(appName), platform: appPlatform,
                // Button to navigate to Preferences page
                actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed("/prefs")
                      .then((value) => setState(() {}));
                },
              ),
            ]),
        body: Container(
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
                          opacity: _timerActive && _whichActive != null
                              ? (_timerSeconds / _whichActive!.brewTime)
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
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        children: teaList.map<Widget>((tea) {
                          // Build the list of teas
                          return Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 0.0),
                              child: TeaButton(
                                  tea: tea,
                                  active: _whichActive == tea ? true : false,
                                  fade: !_timerActive || _whichActive == tea
                                      ? false
                                      : true,
                                  onPressed: (bool newValue) async {
                                    if (_whichActive !=
                                        tea) if (await _confirmTimer())
                                      _setTimer(tea);
                                  }));
                        }).toList()),
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
                          setState(() {
                            // Stop timing and reset
                            _timerActive = false;
                            _whichActive = null;
                            _timerEndTime = DateTime.now();
                            _decrementTimer(_timer);
                            _cancelNotification();
                            Prefs.clearNextAlarm();
                          });
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
    return AnimatedOpacity(
      opacity: fade ? 0.4 : 1.0,
      duration: Duration(milliseconds: 400),
      child: Card(
          child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            color: active ? tea.getThemeColor(context) : Colors.transparent,
            borderRadius: const BorderRadius.all(const Radius.circular(2.0)),
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
                  Icons.timer,
                  color: active ? Colors.white : tea.getThemeColor(context),
                  size: 64.0,
                ),
                Text(
                  tea.buttonName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: active ? Colors.white : tea.getThemeColor(context),
                  ),
                ),
                // Optional extra info: brew time and temp display
                Visibility(
                    visible: showExtra,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Brew time
                          Container(
                              padding:
                                  const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 0.0),
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
                              padding:
                                  const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 0.0),
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
    );
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
        AppLocalizations.translate('cancel_button').toUpperCase(),
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: active ? Colors.red[400] : Colors.grey,
        ),
      ),
      icon: Icon(Icons.cancel,
          color: active ? Colors.red[400] : Colors.grey, size: 16.0),
      onPressed: active ? _handleTap : null,
    );
  }
}
