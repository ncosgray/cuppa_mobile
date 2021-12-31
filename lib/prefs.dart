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
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reorderables/reorderables.dart';
import 'dart:convert';
import 'main.dart';
import 'localization.dart';
import 'platform_adaptive.dart';

// Teas
List<Tea> teaList;

// Settings
bool showExtra;
bool useCelsius;
int appTheme;

// Limits
final int teaNameMaxLength = 16;
final int teasMinCount = 3;
final int teasMaxCount = 15;

// Tea definition
class Tea {
  // ID
  UniqueKey id;

  // Fields
  String name;
  int brewTime;
  int brewTemp;
  int color;
  bool isFavorite;

  // Constructor
  Tea({String name, int brewTime, int brewTemp, int color, bool isFavorite}) {
    id = UniqueKey();
    this.name = name;
    this.brewTime = brewTime;
    this.brewTemp = brewTemp;
    this.color = color;
    this.isFavorite = isFavorite;
  }

  // Tea display getters
  get buttonName {
    return this.name.toUpperCase();
  }

  get tempDisplay {
    return formatTemp(this.brewTemp);
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

  // Factories
  factory Tea.fromJson(Map<String, dynamic> json) {
    return new Tea(
        name: json['name'] ?? '',
        brewTime: json['brewTime'] ?? 0,
        brewTemp: json['brewTemp'] ?? 0,
        color: json['color'] ?? 0,
        isFavorite: json['isFavorite'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'brewTime': this.brewTime,
      'brewTemp': this.brewTemp,
      'color': this.color,
      'isFavorite': this.isFavorite,
    };
  }

  // Overrides for comparisons
  @override
  bool operator ==(otherTea) {
    return (otherTea is Tea) &&
        otherTea.name == this.name &&
        otherTea.brewTime == this.brewTime &&
        otherTea.brewTemp == this.brewTemp &&
        otherTea.color == this.color &&
        otherTea.isFavorite == this.isFavorite;
  }

  @override
  int get hashCode =>
      this.name.hashCode ^
      this.brewTime.hashCode ^
      this.brewTemp.hashCode ^
      this.color.hashCode ^
      this.isFavorite.hashCode;
}

// Shared prefs functionality
abstract class Prefs {
  // Initialize teas
  static void initTeas() {
    teaList = [new Tea(), new Tea(), new Tea()];

    // Load app theme
    appTheme = sharedPrefs.getInt(_prefAppTheme) ?? 0;
  }

  // Color map
  static final Map<int, Color> teaColors = {
    0: Colors.black,
    1: Colors.red[600],
    2: Colors.orange,
    3: Colors.green,
    4: Colors.blue,
    5: Colors.purple[400],
    6: Colors.brown[400],
    7: Colors.pink[200],
    8: Colors.amber,
    9: Colors.teal,
    10: Colors.cyan[400],
    11: Colors.deepPurple[200],
  };

  // Themed color map lookup
  static Color themeColor(int color, context) {
    if (color == 0)
      // "Black" substitutes appropriate color for current theme
      return Theme.of(context).textTheme.button.color;
    else
      return Prefs.teaColors[color];
  }

  // App theme map
  static final Map<int, ThemeMode> appThemes = {
    0: ThemeMode.system,
    1: ThemeMode.light,
    2: ThemeMode.dark
  };

  // App theme name map
  static final Map<int, String> appThemeNames = {
    0: AppLocalizations.translate('theme_system'),
    1: AppLocalizations.translate('theme_light'),
    2: AppLocalizations.translate('theme_dark')
  };

  // Quick action shortcut icon map
  static final Map<int, String> shortcutIcons = {
    0: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_black',
    1: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_red',
    2: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_orange',
    3: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_green',
    4: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_blue',
    5: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_purple',
    6: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_brown',
    7: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_pink',
    8: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_amber',
    9: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_teal',
    10: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_cyan',
    11: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_lavender',
  };

  // Shared prefs keys for teas and other settings
  static const _prefTea1Name = 'Cuppa_tea1_name';
  static const _prefTea1BrewTime = 'Cuppa_tea1_brew_time';
  static const _prefTea1BrewTemp = 'Cuppa_tea1_brew_temp';
  static const _prefTea1Color = 'Cuppa_tea1_color';
  static const _prefTea1IsFavorite = 'Cuppa_tea1_is_favorite';
  static const _prefTea2Name = 'Cuppa_tea2_name';
  static const _prefTea2BrewTime = 'Cuppa_tea2_brew_time';
  static const _prefTea2BrewTemp = 'Cuppa_tea2_brew_temp';
  static const _prefTea2Color = 'Cuppa_tea2_color';
  static const _prefTea2IsFavorite = 'Cuppa_tea2_is_favorite';
  static const _prefTea3Name = 'Cuppa_tea3_name';
  static const _prefTea3BrewTime = 'Cuppa_tea3_brew_time';
  static const _prefTea3BrewTemp = 'Cuppa_tea3_brew_temp';
  static const _prefTea3Color = 'Cuppa_tea3_color';
  static const _prefTea3IsFavorite = 'Cuppa_tea3_is_favorite';
  static const _prefMoreTeas = 'Cuppa_tea_list';
  static const _prefShowExtra = 'Cuppa_show_extra';
  static const _prefUseCelsius = 'Cuppa_use_celsius';
  static const _prefAppTheme = 'Cuppa_app_theme';

  // Fetch all teas from shared prefs or use defaults
  static void getTeas() {
    Prefs.initTeas();

    // Default: Black tea
    teaList[0].name = sharedPrefs.getString(_prefTea1Name) ??
        AppLocalizations.translate('tea_name_black');
    teaList[0].brewTime = sharedPrefs.getInt(_prefTea1BrewTime) ?? 240;
    teaList[0].brewTemp =
        sharedPrefs.getInt(_prefTea1BrewTemp) ?? (isLocaleMetric ? 100 : 212);
    teaList[0].color = sharedPrefs.getInt(_prefTea1Color) ?? 0;
    teaList[0].isFavorite = sharedPrefs.getBool(_prefTea1IsFavorite) ?? true;

    // Default: Green tea
    teaList[1].name = sharedPrefs.getString(_prefTea2Name) ??
        AppLocalizations.translate('tea_name_green');
    teaList[1].brewTime = sharedPrefs.getInt(_prefTea2BrewTime) ?? 150;
    // Select default temp of 212 if name changed from Green tea
    teaList[1].brewTemp = sharedPrefs.getInt(_prefTea2BrewTemp) ??
        (teaList[1].name != AppLocalizations.translate('tea_name_green')
            ? (isLocaleMetric ? 100 : 212)
            : (isLocaleMetric ? 80 : 180));
    teaList[1].color = sharedPrefs.getInt(_prefTea2Color) ?? 3;
    teaList[1].isFavorite = sharedPrefs.getBool(_prefTea2IsFavorite) ?? true;

    // Default: Herbal tea
    teaList[2].name = sharedPrefs.getString(_prefTea3Name) ??
        AppLocalizations.translate('tea_name_herbal');
    teaList[2].brewTime = sharedPrefs.getInt(_prefTea3BrewTime) ?? 300;
    teaList[2].brewTemp =
        sharedPrefs.getInt(_prefTea3BrewTemp) ?? (isLocaleMetric ? 100 : 212);
    teaList[2].color = sharedPrefs.getInt(_prefTea3Color) ?? 2;
    teaList[2].isFavorite = sharedPrefs.getBool(_prefTea3IsFavorite) ?? true;

    // More teas list
    List<String> moreTeasJson =
        sharedPrefs.getStringList(_prefMoreTeas) ?? null;
    if (moreTeasJson != null)
      teaList += (moreTeasJson.map<Tea>((tea) => Tea.fromJson(jsonDecode(tea))))
          .toList();

    // Other settings
    showExtra = sharedPrefs.getBool(_prefShowExtra) ?? false;
    useCelsius = sharedPrefs.getBool(_prefUseCelsius) ?? isLocaleMetric;

    // Manage quick actions
    setQuickActions();
  }

  // Store all teas in shared prefs
  static void setTeas() {
    sharedPrefs.setString(_prefTea1Name, teaList[0].name);
    sharedPrefs.setInt(_prefTea1BrewTime, teaList[0].brewTime);
    sharedPrefs.setInt(_prefTea1BrewTemp, teaList[0].brewTemp);
    sharedPrefs.setInt(_prefTea1Color, teaList[0].color);
    sharedPrefs.setBool(_prefTea1IsFavorite, teaList[0].isFavorite);

    sharedPrefs.setString(_prefTea2Name, teaList[1].name);
    sharedPrefs.setInt(_prefTea2BrewTime, teaList[1].brewTime);
    sharedPrefs.setInt(_prefTea2BrewTemp, teaList[1].brewTemp);
    sharedPrefs.setInt(_prefTea2Color, teaList[1].color);
    sharedPrefs.setBool(_prefTea2IsFavorite, teaList[1].isFavorite);

    sharedPrefs.setString(_prefTea3Name, teaList[2].name);
    sharedPrefs.setInt(_prefTea3BrewTime, teaList[2].brewTime);
    sharedPrefs.setInt(_prefTea3BrewTemp, teaList[2].brewTemp);
    sharedPrefs.setInt(_prefTea3Color, teaList[2].color);
    sharedPrefs.setBool(_prefTea3IsFavorite, teaList[2].isFavorite);

    List<String> moreTeasEncoded =
        (teaList.sublist(3)).map((tea) => jsonEncode(tea.toJson())).toList();
    sharedPrefs.setStringList(_prefMoreTeas, moreTeasEncoded);

    sharedPrefs.setInt(_prefAppTheme, appTheme);

    sharedPrefs.setBool(_prefShowExtra, showExtra);
    sharedPrefs.setBool(_prefUseCelsius, useCelsius);

    // Manage quick actions
    setQuickActions();
  }

  // Next alarm info
  static String nextTeaName = '';
  static int nextAlarm = 0;

  // Shared prefs next alarm info keys
  static const _prefNextTeaName = 'Cuppa_next_tea_name';
  static const _prefNextAlarm = 'Cuppa_next_alarm_time';

  // Fetch next alarm info from shared prefs
  static void getNextAlarm() {
    nextTeaName = sharedPrefs.getString(_prefNextTeaName) ?? '';
    nextAlarm = sharedPrefs.getInt(_prefNextAlarm) ?? 0;
  }

  // Store next alarm info in shared prefs to persist when app is closed
  static void setNextAlarm(String teaName, DateTime timerEndTime) {
    sharedPrefs.setString(_prefNextTeaName, teaName);
    sharedPrefs.setInt(_prefNextAlarm, timerEndTime.millisecondsSinceEpoch);
  }

  // Clear shared prefs next alarm info
  static void clearNextAlarm() {
    sharedPrefs.setString(_prefNextTeaName, '');
    sharedPrefs.setInt(_prefNextAlarm, 0);
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
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus.unfocus(),
        child: Scaffold(
            appBar: new PlatformAdaptiveAppBar(
              title: new Text(AppLocalizations.translate('prefs_title')
                  .replaceAll('{{app_name}}', appName)),
              platform: appPlatform,
            ),
            body: new SafeArea(
                child: new Container(
              padding: const EdgeInsets.fromLTRB(14.0, 21.0, 14.0, 0.0),
              child: new CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  new SliverToBoxAdapter(
                      child: new Column(children: [
                    // Section: Teas
                    new Align(
                        alignment: Alignment.topLeft,
                        child: new Container(
                            margin:
                                const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 14.0),
                            child: new Text(
                                AppLocalizations.translate('teas_title'),
                                style: TextStyle(
                                  fontSize: 18.0,
                                )))),
                    // Prefs header info text
                    new Align(
                        alignment: Alignment.topLeft,
                        child: new Container(
                            margin:
                                const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 14.0),
                            child: new Text(
                                AppLocalizations.translate('prefs_header')
                                    .replaceAll('{{favorites_max}}',
                                        favoritesMaxCount.toString()),
                                style: TextStyle(
                                  fontSize: 14.0,
                                ))))
                  ])),
                  // Tea settings cards
                  new ReorderableSliverList(
                      buildDraggableFeedback: _draggableFeedback,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          // Reorder the tea list
                          Tea oldTea = teaList.removeAt(oldIndex);
                          teaList.insert(newIndex, oldTea);
                          Prefs.setTeas();
                        });
                      },
                      delegate: new ReorderableSliverChildListDelegate(
                          teaList.map<Widget>((tea) {
                        if (teaList.length <= teasMinCount)
                          // Don't allow deleting if there are only 3 teas
                          return new Container(
                              key: Key(tea.id.toString()),
                              child: new PrefsTeaRow(
                                tea: tea,
                              ));
                        else
                          // Deleteable
                          return new Dismissible(
                            key: Key(tea.id.toString()),
                            child: new PrefsTeaRow(
                              tea: tea,
                            ),
                            onDismissed: (direction) {
                              setState(() {
                                // Delete this from the tea list
                                teaList.remove(tea);
                                Prefs.setTeas();
                              });
                            },
                            // Dismissible delete warning background
                            background: Container(
                                padding: const EdgeInsets.all(5.0),
                                child: new Container(
                                    color: Colors.red,
                                    child: new Padding(
                                        padding: const EdgeInsets.all(14.0),
                                        child: new Align(
                                            alignment: Alignment.centerLeft,
                                            child: new Icon(
                                                Icons.delete_outline,
                                                color: Colors.white,
                                                size: 28.0))))),
                            secondaryBackground: Container(
                                padding: const EdgeInsets.all(5.0),
                                child: new Container(
                                    color: Colors.red,
                                    child: new Padding(
                                        padding: const EdgeInsets.all(14.0),
                                        child: new Align(
                                            alignment: Alignment.centerRight,
                                            child: new Icon(
                                                Icons.delete_outline,
                                                color: Colors.white,
                                                size: 28.0))))),
                          );
                      }).toList())),
                  new SliverToBoxAdapter(
                    child: new Column(children: [
                      // Add tea button
                      new Card(
                          child: new ListTile(
                              title: new TextButton.icon(
                        label: new Text(
                            AppLocalizations.translate('add_tea_button')
                                .toUpperCase(),
                            style: TextStyle(
                                fontSize: 14.0,
                                color: teaList.length < teasMaxCount
                                    ? Colors.blue
                                    : Colors.grey)),
                        icon: Icon(Icons.add_circle,
                            color: teaList.length < teasMaxCount
                                ? Colors.blue
                                : Colors.grey,
                            size: 20.0),
                        onPressed: teaList.length < teasMaxCount
                            ? () {
                                setState(() {
                                  // Add a blank tea
                                  teaList.add(new Tea(
                                      name: _getNextDefaultTeaName(),
                                      brewTime: 240,
                                      brewTemp: useCelsius ? 100 : 212,
                                      color: 0,
                                      isFavorite: false));
                                  Prefs.setTeas();
                                });
                              }
                            : null,
                      ))),
                      // Setting: show extra info on buttons
                      new Align(
                          alignment: Alignment.topLeft,
                          child: new SwitchListTile.adaptive(
                            title: new Text(
                                AppLocalizations.translate('prefs_show_extra'),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,
                                )),
                            value: showExtra,
                            // Save showExtra setting to prefs
                            onChanged: (bool newValue) {
                              setState(() {
                                showExtra = newValue;
                                Prefs.setTeas();
                              });
                            },
                            contentPadding:
                                const EdgeInsets.fromLTRB(7.0, 14.0, 7.0, 0.0),
                            dense: true,
                          )),
                      const Divider(
                        thickness: 1.0,
                        indent: 7.0,
                        endIndent: 7.0,
                      ),
                      // Setting: default to Celsius or Fahrenheit
                      new Align(
                          alignment: Alignment.topLeft,
                          child: new SwitchListTile.adaptive(
                            title: new Text(
                                AppLocalizations.translate('prefs_use_celsius'),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,
                                )),
                            value: useCelsius,
                            // Save useCelsius setting to prefs
                            onChanged: (bool newValue) {
                              setState(() {
                                useCelsius = newValue;
                                Prefs.setTeas();
                              });
                            },
                            contentPadding:
                                const EdgeInsets.fromLTRB(7.0, 7.0, 7.0, 0.0),
                            dense: true,
                          )),
                      const Divider(
                        thickness: 1.0,
                        indent: 7.0,
                        endIndent: 7.0,
                      ),
                      // Setting: app theme selection
                      new Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) => Align(
                              alignment: Alignment.topLeft,
                              child: new ListTile(
                                title: new Text(
                                    AppLocalizations.translate(
                                        'prefs_app_theme'),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color,
                                    )),
                                trailing:
                                    // App theme dropdown
                                    new DropdownButton<int>(
                                  value: appTheme,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    size: 20.0,
                                    color: Colors.grey,
                                  ),
                                  underline: SizedBox(),
                                  items: Prefs.appThemeNames.keys
                                      .map<DropdownMenuItem<int>>((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(Prefs.appThemeNames[value],
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: value == appTheme
                                                  ? FontWeight.w400
                                                  : FontWeight.w300)),
                                    );
                                  }).toList(),
                                  // Save appTheme to prefs
                                  onChanged: (int newValue) {
                                    setState(() {
                                      appTheme = newValue;
                                      Prefs.setTeas();

                                      // Notify consumers when theme changes
                                      themeProvider.changeTheme();
                                    });
                                  },
                                  alignment: Alignment.centerRight,
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(
                                    7.0, 7.0, 7.0, 0.0),
                                dense: true,
                              ))),
                      const Divider(
                        thickness: 1.0,
                        indent: 7.0,
                        endIndent: 7.0,
                      ),
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
                                    child: Icon(
                                      Icons.info,
                                      size: 20.0,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color,
                                    )),
                                new Expanded(
                                    child: new Text(
                                        AppLocalizations.translate(
                                                'prefs_notifications')
                                            .replaceAll(
                                                '{{app_name}}', appName),
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .color,
                                        )))
                              ]))),
                    ]),
                  ),
                  new SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: new Align(
                      alignment: Alignment.bottomLeft,
                      child: new Container(
                        margin: const EdgeInsets.fromLTRB(7.0, 21.0, 7.0, 21.0),
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
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .color,
                                      )),
                                  new Row(children: [
                                    new Text(aboutCopyright,
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .color,
                                        )),
                                    new VerticalDivider(),
                                    new Text(aboutURL,
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline))
                                  ])
                                ]),
                            onTap: () => launch(aboutURL)),
                      ),
                    ),
                  )
                ],
              ),
            ))));
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
                        size: 42.0,
                      ),
                    );
                  }).toList();
                },
                // Color dropdown
                child: new SizedBox(
                    height: double.infinity,
                    child: new Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.timer,
                          color: tea.getThemeColor(context),
                          size: 42.0,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 24.0,
                          color: Colors.grey,
                        ),
                      ],
                    )),
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
                  new Container(
                      height: 54.0,
                      padding: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                      child: new Row(children: [
                        // Favorite status
                        new IconButton(
                            alignment: Alignment.topLeft,
                            constraints:
                                BoxConstraints(minWidth: 30.0, minHeight: 30.0),
                            iconSize: 20.0,
                            icon: tea.isFavorite
                                ? Icon(Icons.star, color: Colors.amber)
                                : Icon(Icons.star_border_outlined,
                                    color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                // Toggle favorite status off
                                if (tea.isFavorite) {
                                  tea.isFavorite = false;
                                  Prefs.setTeas();
                                }
                                // Toggle favorite status on if max not reached
                                else if (teaList
                                        .where((tea) => tea.isFavorite == true)
                                        .length <
                                    favoritesMaxCount) {
                                  tea.isFavorite = true;
                                  Prefs.setTeas();
                                }
                              });
                            }),
                        // Tea name entry
                        new Expanded(
                            child: new TextFormField(
                          initialValue: tea.name,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.words,
                          maxLength: teaNameMaxLength + 1,
                          maxLines: 1,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder:
                                OutlineInputBorder(borderSide: BorderSide()),
                            errorStyle: TextStyle(color: Colors.red),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                            counter: Offstage(),
                            contentPadding:
                                const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 0.0),
                          ),
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
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
                      ])),
                  // Tea brew time selection
                  new Container(
                      height: 30.0,
                      padding: EdgeInsets.fromLTRB(7.0, 0.0, 0.0, 7.0),
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Brew time minutes dropdown
                            new DropdownButton<int>(
                              value: tea.brewTimeMinutes,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 24.0,
                                color: Colors.grey,
                              ),
                              style: TextStyle(
                                fontSize: 18.0,
                                color:
                                    Theme.of(context).textTheme.bodyText1.color,
                              ),
                              underline: SizedBox(),
                              alignment: AlignmentDirectional.center,
                              items: <int>[
                                0,
                                1,
                                2,
                                3,
                                4,
                                5,
                                6,
                                7,
                                8,
                                9,
                                10,
                                11,
                                12,
                                13,
                                14,
                                15,
                                16,
                                17,
                                18,
                                19
                              ].map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString(),
                                      style: TextStyle(
                                          fontWeight:
                                              value == tea.brewTimeMinutes
                                                  ? FontWeight.w400
                                                  : FontWeight.w300)),
                                );
                              }).toList(),
                              // Save brew time to prefs
                              onChanged: (int newValue) {
                                setState(() {
                                  // Ensure we never have a 0:00 brew time
                                  if (newValue == 0 &&
                                      tea.brewTimeSeconds == 0) {
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
                                fontSize: 18.0,
                                color:
                                    Theme.of(context).textTheme.bodyText1.color,
                              ),
                            ),
                            // Brew time seconds dropdown
                            new DropdownButton<int>(
                              value: tea.brewTimeSeconds,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 24.0,
                                color: Colors.grey,
                              ),
                              style: TextStyle(
                                fontSize: 18.0,
                                color:
                                    Theme.of(context).textTheme.bodyText1.color,
                              ),
                              underline: SizedBox(),
                              // Ensure we never have a 0:00 brew time
                              items: (tea.brewTimeMinutes == 0
                                      ? <int>[15, 30, 45]
                                      : <int>[0, 15, 30, 45])
                                  .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                          fontWeight:
                                              value == tea.brewTimeSeconds
                                                  ? FontWeight.w400
                                                  : FontWeight.w300)),
                                );
                              }).toList(),
                              // Save brew time to prefs
                              onChanged: (int newValue) {
                                setState(() {
                                  // Ensure we never have a 0:00 brew time
                                  if (newValue == 0 &&
                                      tea.brewTimeMinutes == 0) {
                                    newValue = 15;
                                  }
                                  tea.brewTimeSeconds = newValue;
                                  Prefs.setTeas();
                                });
                              },
                            ),
                            new Flexible(
                                child: new ConstrainedBox(
                                    constraints: new BoxConstraints(
                                        minWidth: 1.0, maxWidth: 30.0),
                                    child: new Container())),
                            // Brew temperature dropdown
                            new DropdownButton<int>(
                              value: tea.brewTemp,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 24.0,
                                color: Colors.grey,
                              ),
                              style: TextStyle(
                                fontSize: 18.0,
                                color:
                                    Theme.of(context).textTheme.bodyText1.color,
                              ),
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
                                  child: Text(formatTemp(value),
                                      style: TextStyle(
                                          fontWeight: value == tea.brewTemp
                                              ? FontWeight.w400
                                              : FontWeight.w300)),
                                );
                              }).toList(),
                              // Save brew temp to prefs
                              onChanged: (int newValue) {
                                setState(() {
                                  tea.brewTemp = newValue;
                                  Prefs.setTeas();
                                });
                              },
                            ),
                          ])),
                ],
              ),
              trailing: new Container(
                  height: double.infinity,
                  child: new Icon(
                    Icons.drag_handle,
                    size: 20.0,
                    color: Colors.grey,
                  )),
            )));
  }
}

// Create a unique default tea name
String _getNextDefaultTeaName() {
  // Build the name string
  String nextName;
  int nextNumber = 1;
  do {
    nextName = AppLocalizations.translate('new_tea_default_name') +
        ' ' +
        nextNumber.toString();
    nextNumber++;
  } while (teaList.indexWhere((tea) => tea.name == nextName) >= 0);
  return nextName;
}

// Custom draggable feedback for reorderable list
Widget _draggableFeedback(
    BuildContext context, BoxConstraints constraints, Widget child) {
  return Transform(
    transform: Matrix4.rotationZ(0),
    alignment: FractionalOffset.topLeft,
    child: Container(
      child: ConstrainedBox(constraints: constraints, child: child),
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.black26, blurRadius: 7.0, offset: Offset(0.0, 0.75))
      ]),
    ),
  );
}
