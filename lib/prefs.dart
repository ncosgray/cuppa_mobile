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
import 'main.dart';
import 'platform_adaptive.dart';

// Brewing complete text
String teaTimerTitle = 'Brewing complete...';
String teaTimerText = ' is now ready!';

// Tea definition
class Tea {
  // Fields
  String name;
  int brewTime;
  int color;

  // Tea name getters
  get buttonName {
    return name.toUpperCase();
  }

  get fullName {
    // Capitalized full name including "tea" for notifications
    String fullName = name[0].toUpperCase();
    if (fullName.length > 0)
      fullName = fullName + name.substring(1).toLowerCase();
    return fullName + ' tea';
  }

  // Color getter
  Color getThemeColor(context) {
    if (this.color == 0)
      // "Black" substitutes appropriate color for current theme
      return Theme.of(context).buttonColor;
    else
      return Prefs.teaColors[this.color];
  }

  // Shortcut icon name based on color
  get shortcutIcon {
    return Prefs.shortcutIcons[this.color];
  }

  // Brew time getters
  get brewTimeSeconds {
    return this.brewTime - (this.brewTimeMinutes * 60);
  }

  get brewTimeMinutes {
    return (this.brewTime / 60).floor();
  }

  // Brew time setters
  set brewTimeSeconds(int newSecs) {
    this.brewTime = (this.brewTimeMinutes * 60) + newSecs;
  }

  set brewTimeMinutes(int newMins) {
    this.brewTime = (newMins * 60) + this.brewTimeSeconds;
  }
}

abstract class Prefs {
  // Color map
  static final Map<int, Color> teaColors = {
    0: Colors.black,
    1: Colors.green,
    2: Colors.orange
  };

  // Shortcut icon map
  static final Map<int, String> shortcutIcons = {
    0: 'shortcut_black',
    1: 'shortcut_green',
    2: 'shortcut_herbal'
  };

  // Shared prefs keys for teas
  static final String _prefTea1Name = 'Cuppa_tea1_name';
  static final String _prefTea1BrewTime = 'Cuppa_tea1_brew_time';
  static final String _prefTea1Color = 'Cuppa_tea1_color';
  static final String _prefTea2Name = 'Cuppa_tea2_name';
  static final String _prefTea2BrewTime = 'Cuppa_tea2_brew_time';
  static final String _prefTea2Color = 'Cuppa_tea2_color';
  static final String _prefTea3Name = 'Cuppa_tea3_name';
  static final String _prefTea3BrewTime = 'Cuppa_tea3_brew_time';
  static final String _prefTea3Color = 'Cuppa_tea3_color';

  // Initialize teas with defaults
  static void initTeas() {
    tea1 = new Tea();
    tea1.name = 'Black';
    tea1.brewTime = 240;
    tea1.color = 0;
    tea2 = new Tea();
    tea2.name = 'Green';
    tea2.brewTime = 150;
    tea2.color = 1;
    tea3 = new Tea();
    tea3.name = 'Herbal';
    tea3.brewTime = 300;
    tea3.color = 2;
  }

  // Fetch all teas from shared prefs or use defaults
  static void getTeas() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _teaName;
    int _teaBrewTime;
    int _teaColor;

    _teaName = _prefs.getString(_prefTea1Name) ?? 'Black';
    _teaBrewTime = _prefs.getInt(_prefTea1BrewTime) ?? 240;
    _teaColor = _prefs.getInt(_prefTea1Color) ?? 0;
    tea1.name = _teaName;
    tea1.brewTime = _teaBrewTime;
    tea1.color = _teaColor;

    _teaName = _prefs.getString(_prefTea2Name) ?? 'Green';
    _teaBrewTime = _prefs.getInt(_prefTea2BrewTime) ?? 150;
    _teaColor = _prefs.getInt(_prefTea2Color) ?? 1;
    tea2.name = _teaName;
    tea2.brewTime = _teaBrewTime;
    tea2.color = _teaColor;

    _teaName = _prefs.getString(_prefTea3Name) ?? 'Herbal';
    _teaBrewTime = _prefs.getInt(_prefTea3BrewTime) ?? 300;
    _teaColor = _prefs.getInt(_prefTea3Color) ?? 2;
    tea3.name = _teaName;
    tea3.brewTime = _teaBrewTime;
    tea3.color = _teaColor;
  }

  // Store all teas in shared prefs
  static void setTeas() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString(_prefTea1Name, tea1.name);
    _prefs.setInt(_prefTea1BrewTime, tea1.brewTime);
    _prefs.setInt(_prefTea1Color, tea1.color);
    _prefs.setString(_prefTea2Name, tea2.name);
    _prefs.setInt(_prefTea2BrewTime, tea2.brewTime);
    _prefs.setInt(_prefTea2Color, tea2.color);
    _prefs.setString(_prefTea3Name, tea3.name);
    _prefs.setInt(_prefTea3BrewTime, tea3.brewTime);
    _prefs.setInt(_prefTea3Color, tea3.color);
  }

  // Next alarm info
  static String nextTeaName = '';
  static String nextAlarm = '';

  // Shared prefs next alarm info keys
  static final String _prefNextTeaName = 'Cuppa_next_tea_name';
  static final String _prefNextAlarm = 'Cuppa_next_alarm';

  // Fetch next alarm info from shared prefs
  static void getNextAlarm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _nextTeaName = prefs.getString(_prefNextTeaName) ?? '';
    String _nextAlarm = prefs.getString(_prefNextAlarm) ?? '';
    nextTeaName = _nextTeaName;
    nextAlarm = _nextAlarm;
  }

  // Store next alarm info in shared prefs to persist when app is closed
  static void setNextAlarm(String teaName, DateTime timerEndTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_prefNextTeaName, teaName);
    prefs.setString(_prefNextAlarm, timerEndTime.toString());
  }

  // Clear shared prefs next alarm info
  static void clearNextAlarm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_prefNextTeaName, '');
    prefs.setString(_prefNextAlarm, '');
  }
}

class PrefsWidget extends StatefulWidget {
  @override
  _PrefsWidgetState createState() => new _PrefsWidgetState();
}

class _PrefsWidgetState extends State<PrefsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new PlatformAdaptiveAppBar(
          title: new Text(CuppaApp.appTitle + ' Preferences'),
          platform: CuppaApp.appPlatform,
        ),
        body: new Container(
            margin: const EdgeInsets.fromLTRB(14.0, 28.0, 14.0, 28.0),
            child: new Column(children: [
              new PrefsTeaRow(tea: tea1),
              new PrefsTeaRow(tea: tea2),
              new PrefsTeaRow(tea: tea3),
            ])));
  }
}

class PrefsTeaRow extends StatefulWidget {
  PrefsTeaRow({
    this.tea,
  });

  final Tea tea;

  @override
  _PrefsTeaRowState createState() => _PrefsTeaRowState(tea: tea);
}

class _PrefsTeaRowState extends State<PrefsTeaRow> {
  _PrefsTeaRowState({
    this.tea,
  });

  final Tea tea;

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new Icon(
          Icons.timer,
          color: tea.getThemeColor(context),
          size: 42.0,
        ),
        new Flexible(
            child: Padding(
                padding: EdgeInsets.fromLTRB(7.0, 7.0, 7.0, 7.0),
                child: TextFormField(
                  initialValue: tea.buttonName,
                  autocorrect: false,
                  maxLength: 10,
                  maxLines: 1,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).buttonColor)),
                      counter: Offstage(),
                      contentPadding:
                          const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 0.0)),
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
                    color: tea.getThemeColor(context),
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      tea.name = newValue;
                      Prefs.setTeas();
                    });
                  },
                ))),
        new DropdownButton<int>(
          value: tea.brewTimeMinutes,
          icon: null,
          style:
              TextStyle(fontSize: 28.0, color: Theme.of(context).buttonColor),
          onChanged: (int newValue) {
            setState(() {
              tea.brewTimeMinutes = newValue;
              Prefs.setTeas();
            });
          },
          items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9]
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
          value: tea.brewTimeSeconds,
          icon: null,
          style:
              TextStyle(fontSize: 28.0, color: Theme.of(context).buttonColor),
          onChanged: (int newValue) {
            setState(() {
              tea.brewTimeSeconds = newValue;
              Prefs.setTeas();
            });
          },
          items: <int>[0, 15, 30, 45].map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(value.toString().padLeft(2, '0')),
            );
          }).toList(),
        ),
      ],
    ));
  }
}
