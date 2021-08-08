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
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'localization.dart';
import 'platform_adaptive.dart';

// Teas
Tea tea1;
Tea tea2;
Tea tea3;

// Settings
bool showExtra;

// Limits
final int teaNameMaxLength = 12;

// Tea definition
class Tea {
  // Fields
  String name;
  int brewTime;
  int brewTemp;
  int color;

  // Tea display getters
  get buttonName {
    return this.name.toUpperCase();
  }

  get tempDisplay {
    return _formatTemp(this.brewTemp);
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

// Shared prefs functionality
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
    2: 'shortcut_orange',
    3: 'shortcut_green',
    4: 'shortcut_blue',
    5: 'shortcut_purple'
  };

  // Shared prefs keys for teas and other settings
  static const _prefTea1Name = 'Cuppa_tea1_name';
  static const _prefTea1BrewTime = 'Cuppa_tea1_brew_time';
  static const _prefTea1BrewTemp = 'Cuppa_tea1_brew_temp';
  static const _prefTea1Color = 'Cuppa_tea1_color';
  static const _prefTea2Name = 'Cuppa_tea2_name';
  static const _prefTea2BrewTime = 'Cuppa_tea2_brew_time';
  static const _prefTea2BrewTemp = 'Cuppa_tea2_brew_temp';
  static const _prefTea2Color = 'Cuppa_tea2_color';
  static const _prefTea3Name = 'Cuppa_tea3_name';
  static const _prefTea3BrewTime = 'Cuppa_tea3_brew_time';
  static const _prefTea3BrewTemp = 'Cuppa_tea3_brew_temp';
  static const _prefTea3Color = 'Cuppa_tea3_color';
  static const _prefShowExtra = 'Cuppa_show_extra';

  // Fetch all teas from shared prefs or use defaults
  static void getTeas() {
    // Default: Black tea
    tea1.name = sharedPrefs.getString(_prefTea1Name) ??
        AppLocalizations.translate('tea_name_black');
    tea1.brewTime = sharedPrefs.getInt(_prefTea1BrewTime) ?? 240;
    tea1.brewTemp = sharedPrefs.getInt(_prefTea1BrewTemp) ?? 212;
    tea1.color = sharedPrefs.getInt(_prefTea1Color) ?? 0;

    // Default: Green tea
    tea2.name = sharedPrefs.getString(_prefTea2Name) ??
        AppLocalizations.translate('tea_name_green');
    tea2.brewTime = sharedPrefs.getInt(_prefTea2BrewTime) ?? 150;
    // Select default temp of 212 if name changed from Green tea
    tea2.brewTemp = sharedPrefs.getInt(_prefTea2BrewTemp) ??
        (tea2.name != AppLocalizations.translate('tea_name_green') ? 212 : 180);
    tea2.color = sharedPrefs.getInt(_prefTea2Color) ?? 3;

    // Default: Herbal tea
    tea3.name = sharedPrefs.getString(_prefTea3Name) ??
        AppLocalizations.translate('tea_name_herbal');
    tea3.brewTime = sharedPrefs.getInt(_prefTea3BrewTime) ?? 300;
    tea3.brewTemp = sharedPrefs.getInt(_prefTea3BrewTemp) ?? 212;
    tea3.color = sharedPrefs.getInt(_prefTea3Color) ?? 2;

    // Other settings
    showExtra = sharedPrefs.getBool(_prefShowExtra) ?? false;
  }

  // Store all teas in shared prefs
  static void setTeas() {
    sharedPrefs.setString(_prefTea1Name, tea1.name);
    sharedPrefs.setInt(_prefTea1BrewTime, tea1.brewTime);
    sharedPrefs.setInt(_prefTea1BrewTemp, tea1.brewTemp);
    sharedPrefs.setInt(_prefTea1Color, tea1.color);

    sharedPrefs.setString(_prefTea2Name, tea2.name);
    sharedPrefs.setInt(_prefTea2BrewTime, tea2.brewTime);
    sharedPrefs.setInt(_prefTea2BrewTemp, tea2.brewTemp);
    sharedPrefs.setInt(_prefTea2Color, tea2.color);

    sharedPrefs.setString(_prefTea3Name, tea3.name);
    sharedPrefs.setInt(_prefTea3BrewTime, tea3.brewTime);
    sharedPrefs.setInt(_prefTea3BrewTemp, tea3.brewTemp);
    sharedPrefs.setInt(_prefTea3Color, tea3.color);

    sharedPrefs.setBool(_prefShowExtra, showExtra);
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

// Cuppa Preferences page
class PrefsWidget extends StatefulWidget {
  @override
  _PrefsWidgetState createState() => new _PrefsWidgetState();
}

class _PrefsWidgetState extends State<PrefsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new PlatformAdaptiveAppBar(
          title: new Text(AppLocalizations.translate('prefs_title')
              .replaceAll('{{app_name}}', appName)),
          platform: appPlatform,
        ),
        body: new SafeArea(
          child: new CustomScrollView(
            slivers: [
              new SliverToBoxAdapter(
                child: new Container(
                    padding: const EdgeInsets.fromLTRB(14.0, 21.0, 14.0, 0.0),
                    child: new Column(children: [
                      // Prefs header info text
                      new Align(
                          alignment: Alignment.topLeft,
                          child: new Container(
                              margin: const EdgeInsets.fromLTRB(
                                  7.0, 0.0, 7.0, 14.0),
                              child: new Text(
                                  AppLocalizations.translate('prefs_header'),
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Theme.of(context).buttonColor,
                                  )))),
                      // Tea settings cards
                      new PrefsTeaRow(tea: tea1),
                      new PrefsTeaRow(tea: tea2),
                      new PrefsTeaRow(tea: tea3),
                      // Setting: show extra info on buttons
                      new Align(
                          alignment: Alignment.topLeft,
                          child: new SwitchListTile.adaptive(
                            title: new Text(
                                AppLocalizations.translate('prefs_show_extra'),
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Theme.of(context).buttonColor)),
                            value: showExtra,
                            // Save showExtra setting to prefs
                            onChanged: (bool newValue) {
                              setState(() {
                                showExtra = newValue;
                                Prefs.setTeas();
                              });
                            },
                            contentPadding:
                                const EdgeInsets.fromLTRB(7.0, 7.0, 7.0, 0.0),
                            dense: true,
                          )),
                      // Notification settings info text
                      new Align(
                          alignment: Alignment.topLeft,
                          child: new Container(
                              margin: const EdgeInsets.fromLTRB(
                                  7.0, 14.0, 7.0, 0.0),
                              child: new Row(children: [
                                new Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        0.0, 0.0, 7.0, 0.0),
                                    child: Icon(Icons.info,
                                        size: 20.0,
                                        color: Theme.of(context).buttonColor)),
                                new Expanded(
                                    child: new Text(
                                        AppLocalizations.translate(
                                                'prefs_notifications')
                                            .replaceAll(
                                                '{{app_name}}', appName),
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context).buttonColor,
                                        )))
                              ]))),
                    ])),
              ),
              new SliverFillRemaining(
                hasScrollBody: false,
                fillOverscroll: true,
                child: new Align(
                  alignment: Alignment.bottomLeft,
                  child: new Container(
                    margin: const EdgeInsets.all(21.0),
                    // About text linking to app website
                    child: new InkWell(
                        child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              new Text(
                                  AppLocalizations.translate('about_app')
                                      .replaceAll('{{app_name}}', appName),
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Theme.of(context).buttonColor,
                                  )),
                              new Row(children: [
                                new Text(aboutCopyright,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Theme.of(context).buttonColor,
                                    )),
                                new VerticalDivider(),
                                new Text(aboutURL,
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline))
                              ])
                            ]),
                        onTap: () => launch(aboutURL)),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

// Widget defining a tea settings card
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
                // Tea color selection
                leading: new PopupMenuButton(
                  // Color icon
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
                  // Color dropdown
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.timer,
                        color: tea.getThemeColor(context),
                        size: 60.0,
                      ),
                      Icon(Icons.arrow_drop_down,
                          size: 24.0, color: Theme.of(context).buttonColor),
                    ],
                  ),
                  // Save selected color to prefs
                  onSelected: (int newValue) {
                    setState(() {
                      tea.color = newValue;
                      Prefs.setTeas();
                    });
                  },
                ),
                title: new Column(
                  children: [
                    // Tea name entry
                    new Container(
                        height: 54.0,
                        padding: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                        child: new TextFormField(
                          initialValue: tea.name,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.words,
                          maxLength: teaNameMaxLength + 1,
                          maxLines: 1,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).buttonColor)),
                            errorStyle: TextStyle(color: Colors.red),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                            counter: Offstage(),
                            contentPadding:
                                const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 0.0),
                          ),
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: tea.getThemeColor(context),
                          ),
                          // Checks for tea names that are blank or too long
                          validator: (String newValue) {
                            if (newValue == null || newValue.isEmpty) {
                              return AppLocalizations.translate(
                                  'error_name_missing');
                            } else if (newValue.characters.length >
                                teaNameMaxLength) {
                              return AppLocalizations.translate(
                                  'error_name_long');
                            }
                            return null;
                          },
                          // Save name to prefs
                          onChanged: (String newValue) {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                tea.name = newValue;
                                Prefs.setTeas();
                              });
                            }
                          },
                        )),
                    // Tea brew time selection
                    new Container(
                        height: 30.0,
                        padding: EdgeInsets.fromLTRB(7.0, 0.0, 0.0, 7.0),
                        child: Row(children: [
                          // Brew time minutes dropdown
                          new DropdownButton<int>(
                            value: tea.brewTimeMinutes,
                            icon: Icon(Icons.arrow_drop_down,
                                size: 24.0,
                                color: Theme.of(context).buttonColor),
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).buttonColor),
                            underline: SizedBox(),
                            items: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                                .map<DropdownMenuItem<int>>((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            // Save brew time to prefs
                            onChanged: (int newValue) {
                              setState(() {
                                // Ensure we never have a 0:00 brew time
                                if (newValue == 0 && tea.brewTimeSeconds == 0) {
                                  tea.brewTimeSeconds = 15;
                                }
                                tea.brewTimeMinutes = newValue;
                                Prefs.setTeas();
                              });
                            },
                          ),
                          // Brew time separator
                          new Text(
                            ': ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Theme.of(context).buttonColor,
                            ),
                          ),
                          // Brew time seconds dropdown
                          new DropdownButton<int>(
                            value: tea.brewTimeSeconds,
                            icon: Icon(Icons.arrow_drop_down,
                                size: 24.0,
                                color: Theme.of(context).buttonColor),
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).buttonColor),
                            underline: SizedBox(),
                            // Ensure we never have a 0:00 brew time
                            items: (tea.brewTimeMinutes == 0
                                    ? <int>[15, 30, 45]
                                    : <int>[0, 15, 30, 45])
                                .map<DropdownMenuItem<int>>((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString().padLeft(2, '0')),
                              );
                            }).toList(),
                            // Save brew time to prefs
                            onChanged: (int newValue) {
                              setState(() {
                                // Ensure we never have a 0:00 brew time
                                if (newValue == 0 && tea.brewTimeMinutes == 0) {
                                  newValue = 15;
                                }
                                tea.brewTimeSeconds = newValue;
                                Prefs.setTeas();
                              });
                            },
                          ),
                          new Spacer(),
                          // Brew temperature dropdown
                          new DropdownButton<int>(
                            value: tea.brewTemp,
                            icon: Icon(Icons.arrow_drop_down,
                                size: 24.0,
                                color: Theme.of(context).buttonColor),
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).buttonColor),
                            underline: SizedBox(),
                            items: (<int>[
                              60,
                              65,
                              70,
                              75,
                              80,
                              85,
                              90,
                              95,
                              100,
                              140,
                              150,
                              160,
                              170,
                              180,
                              190,
                              200,
                              212
                            ]).map<DropdownMenuItem<int>>((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(_formatTemp(value)),
                              );
                            }).toList(),
                            // Save brew temp to prefs
                            onChanged: (int newValue) {
                              setState(() {
                                tea.brewTemp = newValue;
                                Prefs.setTeas();
                              });
                            },
                          )
                        ])),
                  ],
                ))));
  }
}

// Format brew temperature as number with units
String _formatTemp(i) {
  // Infer C or F based on temp range
  if (i <= 100)
    return i.toString() + '\u00b0C';
  else
    return i.toString() + '\u00b0F';
}
