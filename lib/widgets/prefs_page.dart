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

import 'package:cuppa_mobile/main.dart';
import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/about_page.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';

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
    return Scaffold(
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
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color!,
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
                  builder: (context, provider, child) => ReorderableSliverList(
                      buildDraggableFeedback: _draggableFeedback,
                      onReorder: (int oldIndex, int newIndex) {
                        // Reorder the tea list
                        Tea oldTea = Prefs.teaList.removeAt(oldIndex);
                        Prefs.teaList.insert(newIndex, oldTea);
                        provider.update();
                      },
                      delegate: ReorderableSliverChildListDelegate(
                          Prefs.teaList.map<Widget>((tea) {
                        if ((Prefs.teaList.length <= teasMinCount) ||
                            tea.isActive)
                          // Don't allow deleting if there are minimum teas or timer is active
                          return IgnorePointer(
                              // Disable editing actively brewing tea
                              ignoring: tea.isActive,
                              child: Opacity(
                                  opacity: tea.isActive ? 0.4 : 1.0,
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
                              Prefs.teaList.remove(tea);
                              provider.update();
                            },
                            // Dismissible delete warning background
                            background:
                                _dismissibleBackground(Alignment.centerLeft),
                            secondaryBackground:
                                _dismissibleBackground(Alignment.centerRight),
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
                                    color: Prefs.teaList.length < teasMaxCount
                                        ? Colors.blue
                                        : Colors.grey)),
                            icon: Icon(Icons.add_circle,
                                color: Prefs.teaList.length < teasMaxCount
                                    ? Colors.blue
                                    : Colors.grey,
                                size: 20.0),
                            onPressed:
                                // Disable adding teas if there are maximum teas
                                Prefs.teaList.length < teasMaxCount
                                    ? () {
                                        // Add a blank tea
                                        Prefs.teaList.add(Tea(
                                            name: getNextDefaultTeaName(),
                                            brewTime: 240,
                                            brewTemp:
                                                Prefs.useCelsius ? 100 : 212,
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
                                value: Prefs.showExtra,
                                // Save showExtra setting to prefs
                                onChanged: (bool newValue) {
                                  Prefs.showExtra = newValue;
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
                                value: Prefs.useCelsius,
                                // Save useCelsius setting to prefs
                                onChanged: (bool newValue) {
                                  Prefs.useCelsius = newValue;
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
                                  value: Prefs.appTheme,
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
                                      child: Text(
                                          AppLocalizations.translate(
                                              Prefs.appThemeNames[value]!),
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight:
                                                  value == Prefs.appTheme
                                                      ? FontWeight.w400
                                                      : FontWeight.w300)),
                                    );
                                  }).toList(),
                                  // Save appTheme to prefs
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      Prefs.appTheme = newValue;
                                      provider.update();
                                    }
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
                                  value: Prefs.appLanguage,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    size: 20.0,
                                    color: Colors.grey,
                                  ),
                                  underline: SizedBox(),
                                  items:
                                      ([''] + supportedLanguages.keys.toList())
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
                                                  value == Prefs.appLanguage
                                                      ? FontWeight.w400
                                                      : FontWeight.w300)),
                                    );
                                  }).toList(),
                                  // Save appLanguage to prefs
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      Prefs.appLanguage = newValue;
                                      provider.update();
                                    }
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
                          margin:
                              const EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 0.0),
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
                                        .replaceAll('{{app_name}}', appName),
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
        )));
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

  @override
  Widget build(BuildContext context) {
    return Card(
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
                        constraints:
                            BoxConstraints(minWidth: 30.0, minHeight: 30.0),
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
                          else if (Prefs.teaList
                                  .where((tea) => tea.isFavorite == true)
                                  .length <
                              favoritesMaxCount) {
                            tea.isFavorite = true;
                            provider.update();
                          }
                        })),
                // Tea name with edit icon
                Align(
                    alignment: Alignment.centerLeft,
                    child: Consumer<AppProvider>(
                        builder: (context, provider, child) => TextButton.icon(
                            icon: Text(tea.name,
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: tea.getThemeColor(context),
                                )),
                            label: Icon(
                              Icons.edit,
                              color: Colors.grey,
                              size: 20.0,
                            ),
                            onPressed: () {
                              // Open tea name dialog
                              _displayTeaNameDialog(context, tea.name)
                                  .then((newValue) {
                                if (newValue != null) {
                                  // Save name to prefs
                                  tea.name = newValue;
                                  provider.update();
                                }
                              });
                            }))),
              ])),
          // Tea brew time selection
          Container(
              height: 30.0,
              padding: EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 6.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                // Brew time minutes dropdown
                Consumer<AppProvider>(
                    builder: (context, provider, child) => DropdownButton<int>(
                          value: tea.brewTimeMinutes,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 24.0,
                            color: Colors.grey,
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color:
                                Theme.of(context).textTheme.bodyText1!.color!,
                          ),
                          underline: SizedBox(),
                          alignment: AlignmentDirectional.center,
                          items: <int>[for (var i = 0; i <= 19; i++) i]
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString(),
                                  style: TextStyle(
                                      fontWeight: value == tea.brewTimeMinutes
                                          ? FontWeight.w400
                                          : FontWeight.w300)),
                            );
                          }).toList(),
                          // Save brew time to prefs
                          onChanged: (int? newValue) {
                            if (newValue != null)
                            // Ensure we never have a 0:00 brew time
                            if (newValue == 0 && tea.brewTimeSeconds == 0) {
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
                    builder: (context, provider, child) => DropdownButton<int>(
                          value: tea.brewTimeSeconds,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 24.0,
                            color: Colors.grey,
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color:
                                Theme.of(context).textTheme.bodyText1!.color!,
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
                                      fontWeight: value == tea.brewTimeSeconds
                                          ? FontWeight.w400
                                          : FontWeight.w300)),
                            );
                          }).toList(),
                          // Save brew time to prefs
                          onChanged: (int? newValue) {
                            if (newValue != null)
                            // Ensure we never have a 0:00 brew time
                            if (newValue == 0 && tea.brewTimeMinutes == 0) {
                              newValue = 15;
                            }
                            tea.brewTimeSeconds = newValue!;
                            provider.update();
                          },
                        )),
                Flexible(
                    child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: 1.0, maxWidth: 30.0),
                        child: Container())),
                // Brew temperature dropdown
                Consumer<AppProvider>(
                    builder: (context, provider, child) => DropdownButton<int>(
                          value: tea.brewTemp,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 24.0,
                            color: Colors.grey,
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color:
                                Theme.of(context).textTheme.bodyText1!.color!,
                          ),
                          underline: SizedBox(),
                          items: Prefs.brewTemps
                              .map<DropdownMenuItem<int>>((int value) {
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
                          onChanged: (int? newValue) {
                            if (newValue != null) tea.brewTemp = newValue;
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
    ));
  }
}

// Display a tea name entry dialog box
Future<String?> _displayTeaNameDialog(
    BuildContext context, String currentTeaName) async {
  return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PlatformAdaptiveTextFormDialog(
            platform: appPlatform,
            initialValue: currentTeaName,
            validator: (String? newValue) {
              if (newValue == null || newValue.isEmpty) {
                return AppLocalizations.translate('error_name_missing');
              } else if (newValue.characters.length > teaNameMaxLength) {
                return AppLocalizations.translate('error_name_long');
              }
              return null;
            },
            buttonTextCancel: AppLocalizations.translate('cancel_button'),
            buttonTextOK: AppLocalizations.translate('ok_button'));
      });
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
