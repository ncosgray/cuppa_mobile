/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    prefs_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa Preferences page
// - Build prefs interface and interactivity

import 'package:Cuppa/main.dart';
import 'package:Cuppa/data/constants.dart';
import 'package:Cuppa/data/localization.dart';
import 'package:Cuppa/data/prefs.dart';
import 'package:Cuppa/data/tea.dart';
import 'package:Cuppa/widgets/about_page.dart';
import 'package:Cuppa/widgets/platform_adaptive.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

// Cuppa Preferences page
class PrefsWidget extends StatefulWidget {
  const PrefsWidget({Key? key}) : super(key: key);

  @override
  _PrefsWidgetState createState() => _PrefsWidgetState();
}

class _PrefsWidgetState extends State<PrefsWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {
              if (FocusManager.instance.primaryFocus != null)
                FocusManager.instance.primaryFocus!.unfocus()
            },
        child: Scaffold(
            appBar: PlatformAdaptiveAppBar(
                title: Text(AppLocalizations.translate('prefs_title')
                    .replaceAll('{{app_name}}', appName)),
                platform: appPlatform,
                // Button to navigate to About page
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.help),
                    onPressed: () {
                      Navigator.of(context).pushNamed(routeAbout);
                    },
                  ),
                ]),
            body: SafeArea(
                child: Container(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    elevation: 0,
                    backgroundColor: Theme.of(context).canvasColor,
                    automaticallyImplyLeading: false,
                    leading: Container(
                        margin: const EdgeInsets.fromLTRB(6.0, 18.0, 6.0, 12.0),
                        child:
                            // Section: Teas
                            Text(AppLocalizations.translate('teas_title'),
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .color!,
                                ))),
                  ),
                  SliverToBoxAdapter(
                      child:
                          // Prefs header info text
                          Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                  margin: const EdgeInsets.fromLTRB(
                                      6.0, 0.0, 6.0, 12.0),
                                  child: Text(
                                      AppLocalizations.translate('prefs_header')
                                          .replaceAll('{{favorites_max}}',
                                              favoritesMaxCount.toString()),
                                      style: TextStyle(
                                        fontSize: 14.0,
                                      ))))),
                  // Tea settings cards
                  Consumer<AppProvider>(
                      builder: (context, provider, child) =>
                          ReorderableSliverList(
                              buildDraggableFeedback: _draggableFeedback,
                              onReorder: (int oldIndex, int newIndex) {
                                // Reorder the tea list
                                Tea oldTea = teaList.removeAt(oldIndex);
                                teaList.insert(newIndex, oldTea);
                                provider.update();
                              },
                              delegate: ReorderableSliverChildListDelegate(
                                  teaList.map<Widget>((tea) {
                                if ((teaList.length <= teasMinCount) ||
                                    (timerActive && tea.isActive))
                                  // Don't allow deleting if there are minimum teas or timer is active
                                  return IgnorePointer(
                                      // Disable editing actively brewing tea
                                      ignoring: timerActive && tea.isActive,
                                      child: Opacity(
                                          opacity: timerActive ? 0.4 : 1.0,
                                          child: Container(
                                              key: Key(tea.id.toString()),
                                              child: PrefsTeaRow(
                                                tea: tea,
                                              ))));
                                else
                                  // Deleteable
                                  return Dismissible(
                                    key: Key(tea.id.toString()),
                                    child: PrefsTeaRow(
                                      tea: tea,
                                    ),
                                    onDismissed: (direction) {
                                      // Delete this from the tea list
                                      teaList.remove(tea);
                                      provider.update();
                                    },
                                    // Dismissible delete warning background
                                    background: _dismissibleBackground(
                                        Alignment.centerLeft),
                                    secondaryBackground: _dismissibleBackground(
                                        Alignment.centerRight),
                                  );
                              }).toList()))),
                  SliverToBoxAdapter(
                    child: Column(children: [
                      // Add tea button
                      Consumer<AppProvider>(
                          builder: (context, provider, child) => Card(
                                  child: ListTile(
                                      title: TextButton.icon(
                                label: Text(
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
                                onPressed:
                                    // Disable adding teas if there are maximum teas
                                    teaList.length < teasMaxCount
                                        ? () {
                                            // Add a blank tea
                                            teaList.add(Tea(
                                                name: _getNextDefaultTeaName(),
                                                brewTime: 240,
                                                brewTemp:
                                                    useCelsius ? 100 : 212,
                                                color: 0,
                                                isFavorite: false,
                                                isActive: false));
                                            provider.update();
                                          }
                                        : null,
                              )))),
                      // Setting: show extra info on buttons
                      Align(
                          alignment: Alignment.topLeft,
                          child: Consumer<AppProvider>(
                              builder: (context, provider, child) =>
                                  SwitchListTile.adaptive(
                                    title: Text(
                                        AppLocalizations.translate(
                                            'prefs_show_extra'),
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        )),
                                    value: showExtra,
                                    // Save showExtra setting to prefs
                                    onChanged: (bool newValue) {
                                      showExtra = newValue;
                                      provider.update();
                                    },
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        6.0, 12.0, 6.0, 6.0),
                                    dense: true,
                                  ))),
                      _divider(),
                      // Setting: default to Celsius or Fahrenheit
                      Align(
                          alignment: Alignment.topLeft,
                          child: Consumer<AppProvider>(
                              builder: (context, provider, child) =>
                                  SwitchListTile.adaptive(
                                    title: Text(
                                        AppLocalizations.translate(
                                            'prefs_use_celsius'),
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        )),
                                    value: useCelsius,
                                    // Save useCelsius setting to prefs
                                    onChanged: (bool newValue) {
                                      useCelsius = newValue;
                                      provider.update();
                                    },
                                    contentPadding: const EdgeInsets.all(6.0),
                                    dense: true,
                                  ))),
                      _divider(),
                      // Setting: app theme selection
                      Align(
                          alignment: Alignment.topLeft,
                          child: Consumer<AppProvider>(
                              builder: (context, provider, child) => ListTile(
                                    title: Text(
                                        AppLocalizations.translate(
                                            'prefs_app_theme'),
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        )),
                                    trailing:
                                        // App theme dropdown
                                        DropdownButton<int>(
                                      value: appTheme,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        size: 20.0,
                                        color: Colors.grey,
                                      ),
                                      underline: SizedBox(),
                                      items: Prefs.appThemeNames.keys
                                          .map<DropdownMenuItem<int>>(
                                              (int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(
                                              AppLocalizations.translate(
                                                  Prefs.appThemeNames[value]!),
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: value == appTheme
                                                      ? FontWeight.w400
                                                      : FontWeight.w300)),
                                        );
                                      }).toList(),
                                      // Save appTheme to prefs
                                      onChanged: (int? newValue) {
                                        if (newValue != null)
                                          appTheme = newValue;
                                        provider.update();
                                      },
                                      alignment: Alignment.centerRight,
                                    ),
                                    contentPadding: const EdgeInsets.all(6.0),
                                    dense: true,
                                  ))),
                      _divider(),
                      // Setting: app language selection
                      Align(
                          alignment: Alignment.topLeft,
                          child: Consumer<AppProvider>(
                              builder: (context, provider, child) => ListTile(
                                    title: Text(
                                        AppLocalizations.translate(
                                            'prefs_language'),
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        )),
                                    trailing:
                                        // App language dropdown
                                        DropdownButton<String>(
                                      value: appLanguage,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        size: 20.0,
                                        color: Colors.grey,
                                      ),
                                      underline: SizedBox(),
                                      items: ([''] +
                                              supportedLanguages.keys.toList())
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                              value == ''
                                                  ? AppLocalizations.translate(
                                                      'theme_system')
                                                  : supportedLanguages[value]! +
                                                      ' (' +
                                                      value +
                                                      ')',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight:
                                                      value == appLanguage
                                                          ? FontWeight.w400
                                                          : FontWeight.w300)),
                                        );
                                      }).toList(),
                                      // Save appLanguage to prefs
                                      onChanged: (String? newValue) {
                                        if (newValue != null)
                                          appLanguage = newValue;
                                        provider.update();
                                      },
                                      alignment: Alignment.centerRight,
                                    ),
                                    contentPadding: const EdgeInsets.all(6.0),
                                    dense: true,
                                  ))),
                      _divider(),
                      // Notification settings info text
                      Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(
                                  6.0, 12.0, 6.0, 0.0),
                              child: Row(children: [
                                Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        0.0, 0.0, 6.0, 0.0),
                                    child: Icon(
                                      Icons.info,
                                      size: 20.0,
                                    )),
                                Expanded(
                                    child: Text(
                                        AppLocalizations.translate(
                                                'prefs_notifications')
                                            .replaceAll(
                                                '{{app_name}}', appName),
                                        style: TextStyle(
                                          fontSize: 14.0,
                                        )))
                              ]))),
                    ]),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(6.0, 36.0, 6.0, 18.0),
                        // About text linking to app website
                        child: aboutText(),
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
  const PrefsTeaRow({
    Key? key,
    required this.tea,
  }) : super(key: key);

  final Tea tea;

  @override
  _PrefsTeaRowState createState() => _PrefsTeaRowState(tea: tea);
}

class _PrefsTeaRowState extends State<PrefsTeaRow> {
  _PrefsTeaRowState({
    required this.tea,
  });

  final Tea tea;
  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListTile(
              horizontalTitleGap: 4.0,
              // Tea color selection
              leading: Consumer<AppProvider>(
                  builder: (context, provider, child) => PopupMenuButton(
                        // Color icon
                        itemBuilder: (BuildContext context) {
                          return Prefs.teaColors.keys.map((int value) {
                            return PopupMenuItem(
                              value: value,
                              child: Icon(
                                Icons.timer_outlined,
                                color: Prefs.themeColor(value, context),
                                size: 42.0,
                              ),
                            );
                          }).toList();
                        },
                        // Color dropdown
                        child: SizedBox(
                            height: double.infinity,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.timer_outlined,
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
                          tea.color = newValue;
                          provider.update();
                        },
                      )),
              title: Column(
                children: [
                  Container(
                      height: 54.0,
                      padding: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                      child: Row(children: [
                        // Favorite status
                        Consumer<AppProvider>(
                            builder: (context, provider, child) => IconButton(
                                alignment: Alignment.topLeft,
                                constraints: BoxConstraints(
                                    minWidth: 30.0, minHeight: 30.0),
                                iconSize: 20.0,
                                icon: tea.isFavorite
                                    ? Icon(Icons.star, color: Colors.amber)
                                    : Icon(Icons.star_border_outlined,
                                        color: Colors.grey),
                                onPressed: () {
                                  // Toggle favorite status off
                                  if (tea.isFavorite) {
                                    tea.isFavorite = false;
                                    provider.update();
                                  }
                                  // Toggle favorite status on if max not reached
                                  else if (teaList
                                          .where(
                                              (tea) => tea.isFavorite == true)
                                          .length <
                                      favoritesMaxCount) {
                                    tea.isFavorite = true;
                                    provider.update();
                                  }
                                })),
                        // Tea name entry
                        Expanded(
                            child: Consumer<AppProvider>(
                                builder: (context, provider, child) =>
                                    TextFormField(
                                      initialValue: tea.name,
                                      autocorrect: false,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      maxLength: teaNameMaxLength + 1,
                                      maxLines: 1,
                                      textAlignVertical: TextAlignVertical.top,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide()),
                                        errorStyle:
                                            TextStyle(color: Colors.red),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                        counter: Offstage(),
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                6.0, 0.0, 6.0, 0.0),
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: tea.getThemeColor(context),
                                      ),
                                      // Checks for tea names that are blank or too long
                                      validator: (String? newValue) {
                                        if (newValue == null ||
                                            newValue.isEmpty) {
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
                                        if (_formKey.currentState != null) if (_formKey
                                            .currentState!
                                            .validate()) {
                                          tea.name = newValue;
                                          provider.update();
                                        }
                                      },
                                    ))),
                      ])),
                  // Tea brew time selection
                  Container(
                      height: 30.0,
                      padding: EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 6.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Brew time minutes dropdown
                            Consumer<AppProvider>(
                                builder: (context, provider, child) =>
                                    DropdownButton<int>(
                                      value: tea.brewTimeMinutes,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        size: 24.0,
                                        color: Colors.grey,
                                      ),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color!,
                                      ),
                                      underline: SizedBox(),
                                      alignment: AlignmentDirectional.center,
                                      items: <int>[
                                        for (var i = 0; i <= 19; i++) i
                                      ].map<DropdownMenuItem<int>>((int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(value.toString(),
                                              style: TextStyle(
                                                  fontWeight: value ==
                                                          tea.brewTimeMinutes
                                                      ? FontWeight.w400
                                                      : FontWeight.w300)),
                                        );
                                      }).toList(),
                                      // Save brew time to prefs
                                      onChanged: (int? newValue) {
                                        if (newValue != null)
                                        // Ensure we never have a 0:00 brew time
                                        if (newValue == 0 &&
                                            tea.brewTimeSeconds == 0) {
                                          tea.brewTimeSeconds = 15;
                                        }
                                        tea.brewTimeMinutes = newValue!;
                                        provider.update();
                                      },
                                    )),
                            // Brew time separator
                            Text(
                              ': ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            // Brew time seconds dropdown
                            Consumer<AppProvider>(
                                builder: (context, provider, child) =>
                                    DropdownButton<int>(
                                      value: tea.brewTimeSeconds,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        size: 24.0,
                                        color: Colors.grey,
                                      ),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color!,
                                      ),
                                      underline: SizedBox(),
                                      // Ensure we never have a 0:00 brew time
                                      items: (tea.brewTimeMinutes == 0
                                              ? <int>[15, 30, 45]
                                              : <int>[0, 15, 30, 45])
                                          .map<DropdownMenuItem<int>>(
                                              (int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(
                                              value.toString().padLeft(2, '0'),
                                              style: TextStyle(
                                                  fontWeight: value ==
                                                          tea.brewTimeSeconds
                                                      ? FontWeight.w400
                                                      : FontWeight.w300)),
                                        );
                                      }).toList(),
                                      // Save brew time to prefs
                                      onChanged: (int? newValue) {
                                        if (newValue != null)
                                        // Ensure we never have a 0:00 brew time
                                        if (newValue == 0 &&
                                            tea.brewTimeMinutes == 0) {
                                          newValue = 15;
                                        }
                                        tea.brewTimeSeconds = newValue!;
                                        provider.update();
                                      },
                                    )),
                            Flexible(
                                child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: 1.0, maxWidth: 30.0),
                                    child: Container())),
                            // Brew temperature dropdown
                            Consumer<AppProvider>(
                                builder: (context, provider, child) =>
                                    DropdownButton<int>(
                                      value: tea.brewTemp,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        size: 24.0,
                                        color: Colors.grey,
                                      ),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color!,
                                      ),
                                      underline: SizedBox(),
                                      items: Prefs.brewTemps
                                          .map<DropdownMenuItem<int>>(
                                              (int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(formatTemp(value),
                                              style: TextStyle(
                                                  fontWeight:
                                                      value == tea.brewTemp
                                                          ? FontWeight.w400
                                                          : FontWeight.w300)),
                                        );
                                      }).toList(),
                                      // Save brew temp to prefs
                                      onChanged: (int? newValue) {
                                        if (newValue != null)
                                          tea.brewTemp = newValue;
                                        provider.update();
                                      },
                                    )),
                          ])),
                ],
              ),
              trailing: Container(
                  height: double.infinity,
                  child: Icon(
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

// Prefs settings list divider
Widget _divider() {
  return const Divider(
    thickness: 1.0,
    indent: 6.0,
    endIndent: 6.0,
  );
}

// Dismissible delete warning background
Widget _dismissibleBackground(Alignment alignment) {
  return Container(
      padding: const EdgeInsets.all(5.0),
      child: Container(
          color: Colors.red,
          child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                  alignment: alignment,
                  child: Icon(Icons.delete_outline,
                      color: Colors.white, size: 28.0)))));
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
