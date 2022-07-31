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

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/presets.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/about_page.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

// Cuppa Preferences page
class PrefsWidget extends StatelessWidget {
  const PrefsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveScaffold(
        platform: appPlatform,
        isPoppable: true,
        textScaleFactor: appTextScale,
        title: AppString.prefs_title.translate(),
        // Button to navigate to About page
        actionIcon: getPlatformAboutIcon(appPlatform),
        actionRoute: routeAbout,
        body: SafeArea(
            child: Container(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0,
                backgroundColor: Theme.of(context).canvasColor,
                automaticallyImplyLeading: false,
                leading: Container(
                    margin: const EdgeInsets.fromLTRB(6.0, 18.0, 6.0, 12.0),
                    child:
                        // Section: Teas
                        Text(AppString.teas_title.translate(),
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
                              child: Text(AppString.prefs_header.translate(),
                                  style: TextStyle(
                                    fontSize: 14.0,
                                  ))))),
              // Tea settings cards
              Consumer<AppProvider>(
                  builder: (context, provider, child) => ReorderableSliverList(
                      buildDraggableFeedback: _draggableFeedback,
                      onReorder: (int oldIndex, int newIndex) {
                        // Reorder the tea list
                        provider.reorderTeas(oldIndex, newIndex);
                      },
                      delegate: ReorderableSliverChildListDelegate(
                          provider.teaList.map<Widget>((tea) {
                        if ((provider.teaCount <= teasMinCount) || tea.isActive)
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
                              provider.deleteTea(tea);
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
                  Selector<AppProvider, int>(
                      selector: (_, provider) => provider.teaCount,
                      builder: (context, count, child) => Card(
                          child: ListTile(
                              title: TextButton.icon(
                                  label: Text(
                                      AppString.add_tea_button
                                          .translate()
                                          .toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: count < teasMaxCount
                                              ? Colors.blue
                                              : Colors.grey)),
                                  icon: Icon(Icons.add_circle,
                                      color: count < teasMaxCount
                                          ? Colors.blue
                                          : Colors.grey,
                                      size: 20.0),
                                  onPressed:
                                      // Disable adding teas if there are maximum teas
                                      count < teasMaxCount
                                          ? () {
                                              // Open add tea dialog
                                              _displayAddTeaDialog(context);
                                            }
                                          : null)))),
                  // Setting: show extra info on buttons
                  Align(
                      alignment: Alignment.topLeft,
                      child: SwitchListTile.adaptive(
                        title: Text(AppString.prefs_show_extra.translate(),
                            style: TextStyle(
                              fontSize: 16.0,
                            )),
                        value: Provider.of<AppProvider>(context).showExtra,
                        // Save showExtra setting to prefs
                        onChanged: (bool newValue) {
                          Provider.of<AppProvider>(context, listen: false)
                              .showExtra = newValue;
                        },
                        contentPadding:
                            const EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 6.0),
                        dense: true,
                      )),
                  _divider(),
                  // Setting: default to Celsius or Fahrenheit
                  Align(
                      alignment: Alignment.topLeft,
                      child: SwitchListTile.adaptive(
                        title: Text(AppString.prefs_use_celsius.translate(),
                            style: TextStyle(
                              fontSize: 16.0,
                            )),
                        value: Provider.of<AppProvider>(context).useCelsius,
                        // Save useCelsius setting to prefs
                        onChanged: (bool newValue) {
                          Provider.of<AppProvider>(context, listen: false)
                              .useCelsius = newValue;
                        },
                        contentPadding: const EdgeInsets.all(6.0),
                        dense: true,
                      )),
                  _divider(),
                  // Setting: app theme selection
                  Align(
                      alignment: Alignment.topLeft,
                      child: ListTile(
                        title: Text(AppString.prefs_app_theme.translate(),
                            style: TextStyle(
                              fontSize: 16.0,
                            )),
                        trailing: Text(
                            Provider.of<AppProvider>(context)
                                .appTheme
                                .localizedName,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.caption!.color!,
                              fontSize: 16.0,
                            )),
                        onTap: () {
                          // Open app theme dialog
                          _displayAppThemeDialog(context);
                        },
                        contentPadding: const EdgeInsets.all(6.0),
                        dense: true,
                      )),
                  _divider(),
                  // Setting: app language selection
                  Align(
                      alignment: Alignment.topLeft,
                      child: ListTile(
                        title: Text(AppString.prefs_language.translate(),
                            style: TextStyle(
                              fontSize: 16.0,
                            )),
                        trailing: Text(
                            Provider.of<AppProvider>(context).appLanguage == ''
                                ? AppString.theme_system.translate()
                                : supportedLanguages[
                                        Provider.of<AppProvider>(context)
                                            .appLanguage]! +
                                    ' (' +
                                    Provider.of<AppProvider>(context)
                                        .appLanguage +
                                    ')',
                            style: TextStyle(
                              fontSize: 16.0,
                              color:
                                  Theme.of(context).textTheme.caption!.color!,
                            )),
                        onTap: () {
                          // Open app language dialog
                          _displayAppLanguageDialog(context);
                        },
                        contentPadding: const EdgeInsets.all(6.0),
                        dense: true,
                      )),
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
                                    AppString.prefs_notifications.translate(),
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
    bool isLargeDevice = MediaQuery.of(context).size.width >= largeDeviceSize;

    return Card(
        child: ListTile(
      horizontalTitleGap: isLargeDevice ? 24.0 : 4.0,
      // Tea color selection
      leading: InkWell(
          // Color icon
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
          onTap: () {
            // Open tea color dialog
            _displayColorDialog(tea, context);
          }),
      title: Container(
          height: isLargeDevice ? 64.0 : 84.0,
          child: Flex(
            // Determine layout by device size
            direction: isLargeDevice ? Axis.horizontal : Axis.vertical,
            children: [
              Flexible(
                flex: 3,
                child: Container(
                    height: 54.0,
                    padding: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                    child: Row(children: [
                      // Favorite status
                      IconButton(
                          alignment: Alignment.topLeft,
                          constraints:
                              BoxConstraints(minWidth: 30.0, minHeight: 30.0),
                          iconSize: 20.0,
                          icon: tea.isFavorite
                              ? Icon(Icons.star, color: Colors.amber)
                              : Provider.of<AppProvider>(context, listen: false)
                                          .favoritesList
                                          .length <
                                      favoritesMaxCount
                                  ? Icon(Icons.star, color: Colors.grey)
                                  : Icon(Icons.star_border_outlined,
                                      color: Colors.grey),
                          // Toggle favorite status if enabled or max not reached
                          onPressed: tea.isFavorite ||
                                  Provider.of<AppProvider>(context,
                                              listen: false)
                                          .favoritesList
                                          .length <
                                      favoritesMaxCount
                              ? () {
                                  // Toggle favorite status
                                  Provider.of<AppProvider>(context,
                                          listen: false)
                                      .updateTea(tea,
                                          isFavorite: !tea.isFavorite);
                                }
                              : null),
                      // Tea name with edit icon
                      Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
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
                                    Provider.of<AppProvider>(context,
                                            listen: false)
                                        .updateTea(tea, name: newValue);
                                  }
                                });
                              })),
                    ])),
              ),
              // Tea brew time selection
              Flexible(
                flex: 2,
                child: Container(
                    padding: const EdgeInsets.fromLTRB(6.0, 2.0, 0.0, 6.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Brew time minutes dropdown
                          DropdownButton<int>(
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
                              if (newValue != null) {
                                AppProvider provider = Provider.of<AppProvider>(
                                    context,
                                    listen: false);

                                // Ensure we never have a 0:00 brew time
                                if (newValue == 0 && tea.brewTimeSeconds == 0) {
                                  provider.updateTea(tea, brewTimeSeconds: 15);
                                }
                                provider.updateTea(tea,
                                    brewTimeMinutes: newValue);
                              }
                            },
                          ),
                          // Brew time separator
                          Text(
                            ': ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          // Brew time seconds dropdown
                          DropdownButton<int>(
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
                              if (newValue != null) {
                                // Ensure we never have a 0:00 brew time
                                if (newValue == 0 && tea.brewTimeMinutes == 0) {
                                  newValue = 15;
                                }
                                Provider.of<AppProvider>(context, listen: false)
                                    .updateTea(tea, brewTimeSeconds: newValue);
                              }
                            },
                          ),
                          Flexible(
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minWidth: 1.0, maxWidth: 30.0),
                                  child: Container())),
                          // Brew temperature dropdown
                          DropdownButton<int>(
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
                            items: brewTemps
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
                              if (newValue != null)
                                Provider.of<AppProvider>(context, listen: false)
                                    .updateTea(tea, brewTemp: newValue);
                            },
                          ),
                        ])),
              ),
            ],
          )),
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
                return AppString.error_name_missing.translate();
              } else if (newValue.characters.length > teaNameMaxLength) {
                return AppString.error_name_long.translate();
              }
              return null;
            },
            buttonTextCancel: AppString.cancel_button.translate(),
            buttonTextOK: AppString.ok_button.translate());
      });
}

// Display a tea color selection dialog box
Future<bool?> _displayColorDialog(Tea tea, BuildContext context) async {
  return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PlatformAdaptiveDialog(
            platform: appPlatform,
            title: Container(),
            content: SizedBox(
              width: double.maxFinite,
              height: TeaColor.values.length * 22,
              child: Card(
                  margin: EdgeInsets.all(0.0),
                  color: Colors.transparent,
                  elevation: 0,
                  child: GridView.builder(
                    padding: EdgeInsets.all(0.0),
                    shrinkWrap: true,
                    itemCount: TeaColor.values.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 120.0,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0),
                    // Tea color button
                    itemBuilder: (BuildContext context, int index) {
                      TeaColor value = TeaColor.values[index];
                      return ListTile(
                          dense: true,
                          title: Container(
                              constraints: BoxConstraints.expand(),
                              color: value.getThemeColor(context),
                              child: value == tea.color
                                  ? Container(
                                      // Timer icon indicates current color
                                      child: Icon(
                                      Icons.timer_outlined,
                                      color: Colors.white,
                                    ))
                                  : Container()),
                          onTap: () {
                            // Set selected color
                            Provider.of<AppProvider>(context, listen: false)
                                .updateTea(tea, color: value);
                            Navigator.of(context).pop(true);
                          });
                    },
                  )),
            ),
            buttonTextFalse: AppString.cancel_button.translate());
      });
}

// Display an add tea selection dialog box
Future<bool?> _displayAddTeaDialog(BuildContext context) async {
  double deviceHeight = MediaQuery.of(context).size.height;

  return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PlatformAdaptiveDialog(
            platform: appPlatform,
            title: Text(AppString.add_tea_button.translate()),
            content: SizedBox(
                width: double.maxFinite,
                height: deviceHeight * 0.6,
                child: Card(
                    margin: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
                    color: Colors.transparent,
                    elevation: 0,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
                        shrinkWrap: true,
                        itemCount: Presets.presetList.length,
                        // Tea name button
                        itemBuilder: (BuildContext context, int index) {
                          AppProvider provider =
                              Provider.of<AppProvider>(context, listen: false);
                          Preset preset = Presets.presetList[index];

                          return ListTile(
                              dense: true,
                              // Present tea icon
                              leading: Container(
                                  height: double.infinity,
                                  child: Icon(
                                    preset.isCustom
                                        ? Icons.add_circle
                                        : Icons.timer_outlined,
                                    color: preset.getThemeColor(context),
                                    size: 20.0,
                                  )),
                              // Localized preset tea name
                              title: Text(
                                preset.localizedName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: preset.getThemeColor(context)),
                              ),
                              // Preset tea brew time and temperature
                              subtitle: preset.isCustom
                                  ? null
                                  : Container(
                                      padding:
                                          const EdgeInsets.only(right: 24.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              formatTimer(preset.brewTime),
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: preset
                                                      .getThemeColor(context)),
                                            ),
                                            Text(
                                              preset.tempDisplay(
                                                  provider.useCelsius),
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: preset
                                                      .getThemeColor(context)),
                                            )
                                          ])),
                              onTap: () {
                                // Add selected tea
                                provider.addTea(preset.createTea(
                                    useCelsius: provider.useCelsius));
                                Navigator.of(context).pop(true);
                              });
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                      ),
                    ))),
            buttonTextFalse: AppString.cancel_button.translate());
      });
}

// Display an app theme selection dialog box
Future<bool?> _displayAppThemeDialog(BuildContext context) async {
  return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PlatformAdaptiveDialog(
            platform: appPlatform,
            title: Text(AppString.prefs_app_theme.translate()),
            content: Card(
                margin: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
                color: Colors.transparent,
                elevation: 0,
                child: SizedBox(
                  width: double.maxFinite,
                  height: AppTheme.values.length * 56,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
                    shrinkWrap: true,
                    itemCount: AppTheme.values.length,
                    // App theme button
                    itemBuilder: (BuildContext context, int index) {
                      AppProvider provider =
                          Provider.of<AppProvider>(context, listen: false);
                      AppTheme value = AppTheme.values.elementAt(index);

                      return ListTile(
                          dense: true,
                          title: Row(children: [
                            Container(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Icon(
                                  value == provider.appTheme
                                      ? Icons.radio_button_on
                                      : Icons.radio_button_off,
                                  size: 20.0,
                                )),
                            Expanded(
                                child: Text(
                              value.localizedName,
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            )),
                          ]),
                          onTap: () {
                            // Save appTheme to prefs
                            provider.appTheme = value;
                            Navigator.of(context).pop(true);
                          });
                    },
                  ),
                )),
            buttonTextFalse: AppString.cancel_button.translate());
      });
}

// Display an app language selection dialog box
Future<bool?> _displayAppLanguageDialog(BuildContext context) async {
  double deviceHeight = MediaQuery.of(context).size.height;
  final List<String> languageOptions = [''] + supportedLanguages.keys.toList();

  return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PlatformAdaptiveDialog(
            platform: appPlatform,
            title: Text(AppString.prefs_language.translate()),
            content: Card(
                margin: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
                color: Colors.transparent,
                elevation: 0,
                child: SizedBox(
                  width: double.maxFinite,
                  height: deviceHeight * 0.6,
                  child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
                        shrinkWrap: true,
                        itemCount: languageOptions.length,
                        // App language button
                        itemBuilder: (BuildContext context, int index) {
                          AppProvider provider =
                              Provider.of<AppProvider>(context, listen: false);
                          String value = languageOptions[index];

                          return ListTile(
                              dense: true,
                              title: Row(children: [
                                Container(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: Icon(
                                      value == provider.appLanguage
                                          ? Icons.radio_button_on
                                          : Icons.radio_button_off,
                                      size: 20.0,
                                    )),
                                Expanded(
                                    child: Text(
                                  value == ''
                                      ? AppString.theme_system.translate()
                                      : supportedLanguages[value]! +
                                          ' (' +
                                          value +
                                          ')',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                )),
                              ]),
                              onTap: () {
                                // Save appLanguage to prefs
                                provider.appLanguage = value;
                                Navigator.of(context).pop(true);
                              });
                        },
                      )),
                )),
            buttonTextFalse: AppString.cancel_button.translate());
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
