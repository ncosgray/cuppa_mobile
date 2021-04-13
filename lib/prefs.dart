/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    prefs.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2021 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa preferences
// - Tea definitions
// - Handle shared prefs
// - Build prefs interface and interactivity

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Teas {
  // Tea names
  static const String BLACK = 'BLACK';
  static const String GREEN = 'GREEN';
  static const String HERBAL = 'HERBAL';

  // Default tea steep times
  static var teaTimerSecondsDefaults = {
    BLACK: 240,
    GREEN: 150,
    HERBAL: 300,
  };

  // Tea steep times
  static var teaTimerSeconds = {
    BLACK: teaTimerSecondsDefaults[BLACK],
    GREEN: teaTimerSecondsDefaults[GREEN],
    HERBAL: teaTimerSecondsDefaults[HERBAL],
  };

  // Button names
  static var teaButton = {
    BLACK: 'BLACK',
    GREEN: 'GREEN',
    HERBAL: 'HERBAL',
  };

  // Tea full names
  static var teaFullName = {
    BLACK: 'Black tea',
    GREEN: 'Green tea',
    HERBAL: 'Herbal tea',
  };

  // Brewing complete text
  static String teaTimerTitle = 'Brewing complete...';
  static var teaTimerText = {
    BLACK: 'Black tea is now ready!',
    GREEN: 'Green tea is now ready!',
    HERBAL: 'Herbal tea is now ready!',
  };
}

class Prefs {
  // Shared prefs tea steep times keys
  static var prefTeaSeconds = {
    Teas.BLACK: 'Cuppa_tea_secs_black',
    Teas.GREEN: 'Cuppa_tea_secs_green',
    Teas.HERBAL: 'Cuppa_tea_secs_herbal',
  };

  // Store tea steep time in Teas and in shared prefs
  static void setTeaSeconds(String teaName, int secs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Teas.teaTimerSeconds[teaName] = secs;
    prefs.setInt(prefTeaSeconds[teaName], secs);
  }

  // Fetch tea steep times from shared prefs
  static void getTeas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int _teaTimerSecondsBlack = prefs.getInt(prefTeaSeconds[Teas.BLACK]) ??
        Teas.teaTimerSecondsDefaults[Teas.BLACK];
    int _teaTimerSecondsGreen = prefs.getInt(prefTeaSeconds[Teas.GREEN]) ??
        Teas.teaTimerSecondsDefaults[Teas.GREEN];
    int _teaTimerSecondsHerbal = prefs.getInt(prefTeaSeconds[Teas.HERBAL]) ??
        Teas.teaTimerSecondsDefaults[Teas.HERBAL];
    Teas.teaTimerSeconds[Teas.BLACK] = _teaTimerSecondsBlack;
    Teas.teaTimerSeconds[Teas.GREEN] = _teaTimerSecondsGreen;
    Teas.teaTimerSeconds[Teas.HERBAL] = _teaTimerSecondsHerbal;
  }

  // Next alarm info
  static String nextTeaName = '';
  static String nextAlarm = '';

  // Shared prefs next alarm info keys
  static final String prefNextTeaName = 'Cuppa_next_tea_name';
  static final String prefNextAlarm = 'Cuppa_next_alarm';

  // Store next alarm info in shared prefs to persist when app is closed
  static void setNextAlarm(String teaName, DateTime timerEndTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(prefNextTeaName, teaName);
    prefs.setString(prefNextAlarm, timerEndTime.toString());
  }

  // Fetch next alarm info from shared prefs
  static void getNextAlarm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _nextTeaName = prefs.getString(prefNextTeaName) ?? '';
    String _nextAlarm = prefs.getString(prefNextAlarm) ?? '';
    nextTeaName = _nextTeaName;
    nextAlarm = _nextAlarm;
  }

  // Clear shared prefs next alarm info
  static void clearNextAlarm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(prefNextTeaName, '');
    prefs.setString(prefNextAlarm, '');
  }
}

class PrefsWidget extends StatefulWidget {
  @override
  _PrefsWidgetState createState() => new _PrefsWidgetState();
}

class _PrefsWidgetState extends State<PrefsWidget> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.fromLTRB(14.0, 28.0, 14.0, 28.0),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              new Container(
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new Icon(
                      Icons.timer,
                      color: Theme.of(context).buttonColor,
                      size: 42.0,
                    ),
                    new Text(
                      Teas.teaButton[Teas.BLACK],
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Theme.of(context).buttonColor,
                      ),
                    ),
                    new DropdownButton<int>(
                      value:
                          getMinsFromSeconds(Teas.teaTimerSeconds[Teas.BLACK]),
                      icon: null,
                      style: TextStyle(
                          fontSize: 28.0, color: Theme.of(context).buttonColor),
                      onChanged: (int newValue) {
                        setState(() {
                          Prefs.setTeaSeconds(
                              Teas.BLACK,
                              getSecondsFromMinsSecs(
                                  newValue,
                                  getSecsFromSeconds(
                                      Teas.teaTimerSeconds[Teas.BLACK])));
                        });
                      },
                      items: <int>[0, 1, 2, 3, 4, 5]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                    new Text(
                      ':',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Theme.of(context).buttonColor,
                      ),
                    ),
                    new DropdownButton<int>(
                      value:
                          getSecsFromSeconds(Teas.teaTimerSeconds[Teas.BLACK]),
                      icon: null,
                      style: TextStyle(
                          fontSize: 28.0, color: Theme.of(context).buttonColor),
                      onChanged: (int newValue) {
                        setState(() {
                          Prefs.setTeaSeconds(
                              Teas.BLACK,
                              getSecondsFromMinsSecs(
                                  getMinsFromSeconds(
                                      Teas.teaTimerSeconds[Teas.BLACK]),
                                  newValue));
                        });
                      },
                      items: <int>[0, 15, 30, 45]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString().padLeft(2, '0')),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              new Container(
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new Icon(
                      Icons.timer,
                      color: Colors.green,
                      size: 42.0,
                    ),
                    new Text(
                      Teas.teaButton[Teas.GREEN],
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Colors.green,
                      ),
                    ),
                    new DropdownButton<int>(
                      value:
                          getMinsFromSeconds(Teas.teaTimerSeconds[Teas.GREEN]),
                      icon: null,
                      style: TextStyle(
                          fontSize: 28.0, color: Theme.of(context).buttonColor),
                      onChanged: (int newValue) {
                        setState(() {
                          Prefs.setTeaSeconds(
                              Teas.GREEN,
                              getSecondsFromMinsSecs(
                                  newValue,
                                  getSecsFromSeconds(
                                      Teas.teaTimerSeconds[Teas.GREEN])));
                        });
                      },
                      items: <int>[0, 1, 2, 3, 4, 5]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                    new Text(
                      ':',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Theme.of(context).buttonColor,
                      ),
                    ),
                    new DropdownButton<int>(
                      value:
                          getSecsFromSeconds(Teas.teaTimerSeconds[Teas.GREEN]),
                      icon: null,
                      style: TextStyle(
                          fontSize: 28.0, color: Theme.of(context).buttonColor),
                      onChanged: (int newValue) {
                        setState(() {
                          Prefs.setTeaSeconds(
                              Teas.GREEN,
                              getSecondsFromMinsSecs(
                                  getMinsFromSeconds(
                                      Teas.teaTimerSeconds[Teas.GREEN]),
                                  newValue));
                        });
                      },
                      items: <int>[0, 15, 30, 45]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString().padLeft(2, '0')),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              new Container(
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new Icon(
                      Icons.timer,
                      color: Colors.orange,
                      size: 42.0,
                    ),
                    new Text(
                      Teas.teaButton[Teas.HERBAL],
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Colors.orange,
                      ),
                    ),
                    new DropdownButton<int>(
                      value:
                          getMinsFromSeconds(Teas.teaTimerSeconds[Teas.HERBAL]),
                      icon: null,
                      style: TextStyle(
                          fontSize: 28.0, color: Theme.of(context).buttonColor),
                      onChanged: (int newValue) {
                        setState(() {
                          Prefs.setTeaSeconds(
                              Teas.HERBAL,
                              getSecondsFromMinsSecs(
                                  newValue,
                                  getSecsFromSeconds(
                                      Teas.teaTimerSeconds[Teas.HERBAL])));
                        });
                      },
                      items: <int>[0, 1, 2, 3, 4, 5]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                    new Text(
                      ':',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Theme.of(context).buttonColor,
                      ),
                    ),
                    new DropdownButton<int>(
                      value:
                          getSecsFromSeconds(Teas.teaTimerSeconds[Teas.HERBAL]),
                      icon: null,
                      style: TextStyle(
                          fontSize: 28.0, color: Theme.of(context).buttonColor),
                      onChanged: (int newValue) {
                        setState(() {
                          Prefs.setTeaSeconds(
                              Teas.HERBAL,
                              getSecondsFromMinsSecs(
                                  getMinsFromSeconds(
                                      Teas.teaTimerSeconds[Teas.HERBAL]),
                                  newValue));
                        });
                      },
                      items: <int>[0, 15, 30, 45]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString().padLeft(2, '0')),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ]));
  }
}

int getMinsFromSeconds(s) {
  return (s / 60).floor();
}

int getSecsFromSeconds(s) {
  return s - (getMinsFromSeconds(s) * 60);
}

int getSecondsFromMinsSecs(int m, int s) {
  return (m * 60) + s;
}
