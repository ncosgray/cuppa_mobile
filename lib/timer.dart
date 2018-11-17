// Cuppa timer.dart
// Author: Nathan Cosgray | https://www.nathanatos.com

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Cuppa: timer classes

class TimerWidget extends StatefulWidget {
  @override
  _TimerWidgetState createState() => new _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // Tea names
  static String BLACK = 'BLACK';
  static String GREEN = 'GREEN';
  static String HERBAL = 'HERBAL';

  // Tea steep times
  var teaTimerSeconds = {
    BLACK: 240,
    GREEN: 150,
    HERBAL: 300,
  };

  // Cup images
  static String cupImageDefault = 'images/Cuppa_hires_default.png';
  static String cupImageBegin = 'images/Cuppa_hires_light.png';
  static String cupImageEnd = 'images/Cuppa_hires_dark.png';

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
  Future<Null> _sendNotification(int secs) async {
    try {
      platform.invokeMethod('setupNotification', secs);
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
      }
    });
  }

  void _setTimer(String teaName) {
    setState(() {
      if (!_timerActive) {
        _timerActive = true;
        _whichActive = teaName;
        _timerSeconds = teaTimerSeconds[teaName];
        _cupImage = cupImageBegin;
        _timerEndTime =
            new DateTime.now().add(new Duration(seconds: _timerSeconds + 1));
        _timer = new Timer.periodic(new Duration(seconds: 1), _decrementTimer);
        _sendNotification(_timerSeconds);
      }
    });
  }

  // Button handlers
  void _handleTapboxBlackChanged(bool newValue) {
    _setTimer(BLACK);
  }

  void _handleTapboxGreenChanged(bool newValue) {
    _setTimer(GREEN);
  }

  void _handleTapboxHerbalChanged(bool newValue) {
    _setTimer(HERBAL);
  }

  void _handleTapboxCancelPressed(bool newValue) {
    setState(() {
      _timerActive = false;
      _whichActive = '';
      _timerEndTime = new DateTime.now();
      _decrementTimer(_timer);
      _cancelNotification();
    });
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
                      name: BLACK,
                      active: _whichActive == BLACK ? true : false,
                      fade:
                          !_timerActive || _whichActive == BLACK ? false : true,
                      buttonColor: Colors.black54,
                      onPressed: _handleTapboxBlackChanged),
                  new TeaButton(
                      name: GREEN,
                      active: _whichActive == GREEN ? true : false,
                      fade:
                          !_timerActive || _whichActive == GREEN ? false : true,
                      buttonColor: Colors.green,
                      onPressed: _handleTapboxGreenChanged),
                  new TeaButton(
                      name: HERBAL,
                      active: _whichActive == HERBAL ? true : false,
                      fade: !_timerActive || _whichActive == HERBAL
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

  static String CANCEL = 'CANCEL';

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
                color: active ? Colors.blue : Colors.black12),
            new Text(
              CANCEL,
              style: new TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.w400,
                color: active ? Colors.blue : Colors.black12,
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
