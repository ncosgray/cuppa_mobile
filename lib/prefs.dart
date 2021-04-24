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
import 'main.dart';
import 'platform_adaptive.dart';

// Teas
Tea tea1;
Tea tea2;
Tea tea3;

// Strings
final String appTitle = 'Cuppa';
final String cancelButton = 'CANCEL';
final String teaTimerTitle = 'Brewing complete...';
final String teaTimerText = ' is now ready!';
final String confirmTitle = 'Warning!';
final String confirmMessageLine1 = 'There is an active timer.';
final String confirmMessageLine2 = 'Cancel and start a new timer?';
final String confirmYes = 'Yes';
final String confirmNo = 'No';
final String prefsTitle = 'Cuppa Preferences';
final String prefsHeader = 'Set tea names, brew times, and colors.';
final String prefsNameMissing = 'Please enter a tea name';
final String prefsNameLong = 'Tea name is too long';

// Limits
final int teaNameMaxLength = 12;

// Tea definition
class Tea {
  // Fields
  String name;
  int brewTime;
  int color;

  // Tea name getters
  get buttonName {
    return this.name.toUpperCase();
  }

  get fullName {
    // Name including "tea" for notifications and shortcuts
    return this.name + ' tea';
  }

  // Color getter
  Color getThemeColor(context) {
    return Prefs.themeColor(this.color, context);
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
  // Initialize teas
  static void initTeas() {
    tea1 = new Tea();
    tea2 = new Tea();
    tea3 = new Tea();
  }

  // Color map
  static final Map<int, Color> teaColors = {
    0: Colors.black,
    1: Colors.red[600],
    2: Colors.orange,
    3: Colors.green,
    4: Colors.blue,
    5: Colors.purple[300],
  };

  // Themed color map lookup
  static Color themeColor(int color, context) {
    if (color == 0)
      // "Black" substitutes appropriate color for current theme
      return Theme.of(context).buttonColor;
    else
      return Prefs.teaColors[color];
  }

  // Shortcut icon map
  static final Map<int, String> shortcutIcons = {
    0: 'shortcut_black',
    1: 'shortcut_red',
    2: 'shortcut_herbal',
    3: 'shortcut_green',
    4: 'shortcut_blue',
    5: 'shortcut_purple'
  };

  // Shared prefs keys for teas
  static const _prefTea1Name = 'Cuppa_tea1_name';
  static const _prefTea1BrewTime = 'Cuppa_tea1_brew_time';
  static const _prefTea1Color = 'Cuppa_tea1_color';
  static const _prefTea2Name = 'Cuppa_tea2_name';
  static const _prefTea2BrewTime = 'Cuppa_tea2_brew_time';
  static const _prefTea2Color = 'Cuppa_tea2_color';
  static const _prefTea3Name = 'Cuppa_tea3_name';
  static const _prefTea3BrewTime = 'Cuppa_tea3_brew_time';
  static const _prefTea3Color = 'Cuppa_tea3_color';

  // Fetch all teas from shared prefs or use defaults
  static void getTeas() {
    tea1.name = sharedPrefs.getString(_prefTea1Name) ?? 'Black';
    tea1.brewTime = sharedPrefs.getInt(_prefTea1BrewTime) ?? 240;
    tea1.color = sharedPrefs.getInt(_prefTea1Color) ?? 0;

    tea2.name = sharedPrefs.getString(_prefTea2Name) ?? 'Green';
    tea2.brewTime = sharedPrefs.getInt(_prefTea2BrewTime) ?? 150;
    tea2.color = sharedPrefs.getInt(_prefTea2Color) ?? 3;

    tea3.name = sharedPrefs.getString(_prefTea3Name) ?? 'Herbal';
    tea3.brewTime = sharedPrefs.getInt(_prefTea3BrewTime) ?? 300;
    tea3.color = sharedPrefs.getInt(_prefTea3Color) ?? 2;
  }

  // Store all teas in shared prefs
  static void setTeas() {
    sharedPrefs.setString(_prefTea1Name, tea1.name);
    sharedPrefs.setInt(_prefTea1BrewTime, tea1.brewTime);
    sharedPrefs.setInt(_prefTea1Color, tea1.color);
    sharedPrefs.setString(_prefTea2Name, tea2.name);
    sharedPrefs.setInt(_prefTea2BrewTime, tea2.brewTime);
    sharedPrefs.setInt(_prefTea2Color, tea2.color);
    sharedPrefs.setString(_prefTea3Name, tea3.name);
    sharedPrefs.setInt(_prefTea3BrewTime, tea3.brewTime);
    sharedPrefs.setInt(_prefTea3Color, tea3.color);
  }

  // Next alarm info
  static String nextTeaName = '';
  static String nextAlarm = '';

  // Shared prefs next alarm info keys
  static const _prefNextTeaName = 'Cuppa_next_tea_name';
  static const _prefNextAlarm = 'Cuppa_next_alarm';

  // Fetch next alarm info from shared prefs
  static void getNextAlarm() {
    nextTeaName = sharedPrefs.getString(_prefNextTeaName) ?? '';
    nextAlarm = sharedPrefs.getString(_prefNextAlarm) ?? '';
  }

  // Store next alarm info in shared prefs to persist when app is closed
  static void setNextAlarm(String teaName, DateTime timerEndTime) {
    sharedPrefs.setString(_prefNextTeaName, teaName);
    sharedPrefs.setString(_prefNextAlarm, timerEndTime.toString());
  }

  // Clear shared prefs next alarm info
  static void clearNextAlarm() {
    sharedPrefs.setString(_prefNextTeaName, '');
    sharedPrefs.setString(_prefNextAlarm, '');
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
          title: new Text(prefsTitle),
          platform: appPlatform,
        ),
        body: new ListView(
          padding: const EdgeInsets.fromLTRB(14.0, 21.0, 14.0, 0.0),
          children: [
            new Align(
                alignment: Alignment.topLeft,
                child: new Container(
                    margin: const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 14.0),
                    child: new Text(prefsHeader,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).buttonColor,
                        )))),
            new PrefsTeaRow(tea: tea1),
            new PrefsTeaRow(tea: tea2),
            new PrefsTeaRow(tea: tea3),
          ],
        ));
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
  GlobalKey<FormState> _formKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return new Card(
        child: new Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: new ListTile(
                leading: new PopupMenuButton(
                  onSelected: (int newValue) {
                    setState(() {
                      tea.color = newValue;
                      Prefs.setTeas();
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return Prefs.teaColors.keys.map((int value) {
                      return PopupMenuItem(
                        value: value,
                        child: Icon(
                          Icons.timer,
                          color: Prefs.themeColor(value, context),
                          size: 35.0,
                        ),
                      );
                    }).toList();
                  },
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.timer,
                        color: tea.getThemeColor(context),
                        size: 70.0,
                      ),
                      Icon(Icons.arrow_drop_down,
                          color: Theme.of(context).buttonColor),
                    ],
                  ),
                ),
                title: new Column(
                  children: [
                    new Container(
                        height: 54.0,
                        padding: EdgeInsets.zero,
                        child: new TextFormField(
                          initialValue: tea.name,
                          autocorrect: false,
                          maxLength: teaNameMaxLength + 1,
                          maxLines: 1,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).buttonColor)),
                              counter: Offstage(),
                              contentPadding: const EdgeInsets.fromLTRB(
                                  7.0, 0.0, 7.0, 0.0)),
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28.0,
                            color: tea.getThemeColor(context),
                          ),
                          validator: (String newValue) {
                            if (newValue == null || newValue.isEmpty) {
                              return prefsNameMissing;
                            } else if (newValue.length > teaNameMaxLength) {
                              return prefsNameLong;
                            }
                            return null;
                          },
                          onChanged: (String newValue) {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                tea.name = newValue;
                                Prefs.setTeas();
                              });
                            }
                          },
                        )),
                    new Container(
                        height: 40.0,
                        padding: EdgeInsets.fromLTRB(7.0, 0.0, 0.0, 7.0),
                        child: Row(children: [
                          new DropdownButton<int>(
                            value: tea.brewTimeMinutes,
                            icon: null,
                            style: TextStyle(
                                fontSize: 28.0,
                                color: Theme.of(context).buttonColor),
                            underline: SizedBox(),
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
                            ': ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28.0,
                              color: Theme.of(context).buttonColor,
                            ),
                          ),
                          new DropdownButton<int>(
                            value: tea.brewTimeSeconds,
                            icon: null,
                            style: TextStyle(
                                fontSize: 28.0,
                                color: Theme.of(context).buttonColor),
                            underline: SizedBox(),
                            onChanged: (int newValue) {
                              setState(() {
                                tea.brewTimeSeconds = newValue;
                                Prefs.setTeas();
                              });
                            },
                            items: <int>[0, 15, 30, 45]
                                .map<DropdownMenuItem<int>>((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString().padLeft(2, '0')),
                              );
                            }).toList(),
                          )
                        ])),
                  ],
                ))));
  }
}
