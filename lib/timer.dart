/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    timer.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2021 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa timer widgets and logic
// - Build interface and interactivity
// - Start, confirm, cancel timers
// - Notification channels for platform code

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_actions/quick_actions.dart';
import 'main.dart';
import 'prefs.dart';
import 'platform_adaptive.dart';

class TimerWidget extends StatefulWidget {
  @override
  _TimerWidgetState createState() => new _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // Cup images
  static final String cupImageDefault = 'images/Cuppa_hires_default.png';
  static final String cupImageBegin = 'images/Cuppa_hires_light.png';
  static final String cupImageEnd = 'images/Cuppa_hires_dark.png';

  // Prefs keys
  static final String prefNextTeaName = 'Cuppa_next_tea_name';
  static final String prefNextAlarm = 'Cuppa_next_alarm';

  // State variables
  bool _timerActive = false;
  String _whichActive = '';
  String _cupImage = cupImageDefault;
  int _timerSeconds = 0;
  DateTime _timerEndTime;
  Timer _timer;

  // Notification channels
  static const platform =
      const MethodChannel('com.nathanatos.Cuppa/notification');
  Future<Null> _sendNotification(int secs, String title, String text) async {
    try {
      platform.invokeMethod('setupNotification', <String, dynamic>{
        'secs': secs,
        'title': title,
        'text': text,
      });
    } on PlatformException catch (e) {
      return;
    }
  }

  Future<Null> _cancelNotification() async {
    try {
      platform.invokeMethod('cancelNotification');
    } on PlatformException catch (e) {
      return;
    }
  }

  // Confirmation dialog
  static String confirmTitle = 'Warning!';
  static String confirmMessageLine1 = 'There is an active timer.';
  static String confirmMessageLine2 = 'Cancel and start a new timer?';
  static String confirmYes = 'Yes';
  static String confirmNo = 'No';
  Future<bool> _confirmTimer() {
    if (_timerActive) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return PlatformAdaptiveDialog(
              platform: CuppaApp.appPlatform,
              title: Text(confirmTitle),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(confirmMessageLine1),
                    Text(confirmMessageLine2),
                  ],
                ),
              ),
              buttonTextTrue: confirmYes,
              buttonTextFalse: confirmNo,
            );
          });
    } else {
      return Future.value(true);
    }
  }

  // Timer functions
  void _decrementTimer(Timer t) {
    setState(() {
      _timerSeconds = _timerEndTime.difference(new DateTime.now()).inSeconds;
      if (_timerSeconds <= 5) _cupImage = cupImageEnd;
      if (_timerSeconds <= 0) {
        _timerActive = false;
        _whichActive = '';
        _cupImage = cupImageDefault;
        _timerSeconds = 0;
        _timer.cancel();
        _clearPrefs();
      }
    });
  }

  void _setTimer(String teaName, [int secs = 0]) {
    setState(() {
      if (!_timerActive) _timerActive = true;
      _whichActive = teaName;
      if (secs == 0) {
        // Set up new timer
        _timerSeconds = Teas.teaTimerSeconds[teaName];
        _sendNotification(
            _timerSeconds, Teas.teaTimerTitle, Teas.teaTimerText[teaName]);
      } else {
        // Resume timer from stored prefs
        _timerSeconds = secs;
      }
      _cupImage = cupImageBegin;
      _timer = new Timer.periodic(new Duration(seconds: 1), _decrementTimer);
      _timerEndTime =
          new DateTime.now().add(new Duration(seconds: _timerSeconds + 1));
      _setPrefs(teaName, _timerEndTime);
    });
  }

  // Prefs functions
  void _setPrefs(String teaName, DateTime timerEndTime) async {
    // Store alarm info in prefs to persist when app is closed
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(prefNextTeaName, teaName);
    prefs.setString(prefNextAlarm, timerEndTime.toString());
  }

  void _checkPrefs() async {
    // Fetch next alarm info from prefs and resume if any
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String nextTeaName = prefs.getString(prefNextTeaName) ?? '';
    String nextAlarm = prefs.getString(prefNextAlarm) ?? '';
    if (DateTime.tryParse(nextAlarm) != null) {
      Duration diff = DateTime.parse(nextAlarm).difference(DateTime.now());
      if (diff.inSeconds > 0) {
        _setTimer(nextTeaName, diff.inSeconds);
      } else {
        _clearPrefs();
      }
    } else {
      _clearPrefs();
    }
  }

  void _clearPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(prefNextTeaName, '');
    prefs.setString(prefNextAlarm, '');
  }

  // Button handlers
  void _handleTapboxBlackChanged(bool newValue) async {
    if (_whichActive != Teas.BLACK) if (await _confirmTimer())
      _setTimer(Teas.BLACK);
  }

  void _handleTapboxGreenChanged(bool newValue) async {
    if (_whichActive != Teas.GREEN) if (await _confirmTimer())
      _setTimer(Teas.GREEN);
  }

  void _handleTapboxHerbalChanged(bool newValue) async {
    if (_whichActive != Teas.HERBAL) if (await _confirmTimer())
      _setTimer(Teas.HERBAL);
  }

  void _handleTapboxCancelPressed(bool newValue) {
    setState(() {
      _timerActive = false;
      _whichActive = '';
      _timerEndTime = new DateTime.now();
      _decrementTimer(_timer);
      _cancelNotification();
      _clearPrefs();
    });
  }

  @override
  void initState() {
    super.initState();

    // Check for an existing timer
    _checkPrefs();

    // Handle quick action selection
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) async {
      if (shortcutType != null) {
        switch (shortcutType) {
          case 'shortcutBlack':
            {
              if (await _confirmTimer()) _setTimer(Teas.BLACK);
            }
            break;
          case 'shortcutGreen':
            {
              if (await _confirmTimer()) _setTimer(Teas.GREEN);
            }
            break;
          case 'shortcutHerbal':
            {
              if (await _confirmTimer()) _setTimer(Teas.HERBAL);
            }
            break;
        }
      }
    });

    // Add quick action shortcuts
    quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(
        type: 'shortcutBlack',
        localizedTitle: Teas.teaFullName[Teas.BLACK],
        icon: 'shortcut_black',
      ),
      ShortcutItem(
        type: 'shortcutGreen',
        localizedTitle: Teas.teaFullName[Teas.GREEN],
        icon: 'shortcut_green',
      ),
      ShortcutItem(
        type: 'shortcutHerbal',
        localizedTitle: Teas.teaFullName[Teas.HERBAL],
        icon: 'shortcut_herbal',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Styles
    double scaleFactor = MediaQuery.of(context).size.height < 600.0 ? 0.7 : 1.0;
    final TextStyle timerStyle = Theme.of(context).textTheme.display3.copyWith(
        color: Colors.white,
        fontSize: 100.0 * scaleFactor,
        fontWeight: FontWeight.bold);

    return new Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          new SizedBox(
            child: new Container(
              padding: const EdgeInsets.fromLTRB(48.0, 24.0, 48.0, 24.0),
              child: new Container(
                decoration: new BoxDecoration(
                  color: Colors.green,
                  borderRadius:
                      const BorderRadius.all(const Radius.circular(12.0)),
                ),
                child: new Center(
                  child: new Text(
                    formatTimer(_timerSeconds),
                    style: timerStyle,
                  ),
                ),
              ),
            ),
          ),
          new Expanded(
            child: new Container(
              padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0.0),
              child: new Image.asset(
                _cupImage,
                height: 240.0 * scaleFactor,
                fit: BoxFit.fitWidth,
                gaplessPlayback: true,
              ),
            ),
          ),
          new SizedBox(
            child: new Container(
              margin: const EdgeInsets.all(24.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  new TeaButton(
                      name: Teas.teaButton[Teas.BLACK],
                      active: _whichActive == Teas.BLACK ? true : false,
                      fade: !_timerActive || _whichActive == Teas.BLACK
                          ? false
                          : true,
                      buttonColor: Theme.of(context).buttonColor,
                      onPressed: _handleTapboxBlackChanged),
                  new TeaButton(
                      name: Teas.teaButton[Teas.GREEN],
                      active: _whichActive == Teas.GREEN ? true : false,
                      fade: !_timerActive || _whichActive == Teas.GREEN
                          ? false
                          : true,
                      buttonColor: Colors.green,
                      onPressed: _handleTapboxGreenChanged),
                  new TeaButton(
                      name: Teas.teaButton[Teas.HERBAL],
                      active: _whichActive == Teas.HERBAL ? true : false,
                      fade: !_timerActive || _whichActive == Teas.HERBAL
                          ? false
                          : true,
                      buttonColor: Colors.orange,
                      onPressed: _handleTapboxHerbalChanged),
                ],
              ),
            ),
          ),
          new SizedBox(
            child: new Container(
              margin: const EdgeInsets.only(bottom: 24.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  new CancelButton(
                    active: _timerActive ? true : false,
                    onPressed: _handleTapboxCancelPressed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TeaButton extends StatelessWidget {
  TeaButton({
    @required this.name,
    @required this.active = false,
    @required this.fade = false,
    @required this.buttonColor,
    @required this.onPressed,
  }) {
    assert(name != null);
    assert(active != null);
    assert(fade != null);
    assert(buttonColor != null);
  }

  final String name;
  final bool active;
  final bool fade;
  final Color buttonColor;

  final ValueChanged<bool> onPressed;
  void _handleTap() {
    onPressed(!active);
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedOpacity(
      opacity: fade ? 0.4 : 1.0,
      duration: new Duration(milliseconds: 400),
      child: new GestureDetector(
        onTap: _handleTap,
        child: new Container(
          decoration: new BoxDecoration(
            color: active ? buttonColor : Colors.transparent,
            borderRadius: const BorderRadius.all(const Radius.circular(2.0)),
          ),
          child: new Container(
            margin: const EdgeInsets.all(8.0),
            child: new Column(
              children: [
                new Icon(
                  Icons.timer,
                  color: active ? Colors.white : buttonColor,
                  size: 64.0,
                ),
                new Text(
                  name,
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: active ? Colors.white : buttonColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  CancelButton({Key key, this.active: false, @required this.onPressed})
      : super(key: key);

  static String cancelButton = 'CANCEL';

  final bool active;
  final ValueChanged<bool> onPressed;

  void _handleTap() {
    onPressed(!active);
  }

  Widget build(BuildContext context) {
    return new IconButton(
        icon: new Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Icon(Icons.cancel,
                color: active ? Colors.blue : Theme.of(context).buttonColor),
            new Text(
              cancelButton,
              style: new TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.w400,
                color: active ? Colors.blue : Theme.of(context).buttonColor,
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.all(0.0),
        onPressed: active ? _handleTap : null);
  }
}

String formatTimer(s) {
  // Build the time format string
  int mins = (s / 60).floor();
  int secs = s - (mins * 60);
  String secsString = secs.toString();
  if (secs < 10) secsString = '0' + secsString;
  return mins.toString() + ':' + secsString;
}
