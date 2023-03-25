/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_settings_card.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea settings card
// - Build interface for tea customization

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/common.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widget defining a tea settings card
class TeaSettingsCard extends StatefulWidget {
  const TeaSettingsCard({
    Key? key,
    required this.tea,
  }) : super(key: key);

  final Tea tea;

  @override
  _TeaSettingsCardState createState() => _TeaSettingsCardState(tea: tea);
}

class _TeaSettingsCardState extends State<TeaSettingsCard> {
  _TeaSettingsCardState({
    required this.tea,
  });

  final Tea tea;

  // Build a tea settings card
  @override
  Widget build(BuildContext context) {
    bool isLargeDevice = MediaQuery.of(context).size.width >= largeDeviceSize;

    return Card(
        child: ListTile(
      horizontalTitleGap: isLargeDevice ? 24.0 : 4.0,
      title: Opacity(
          opacity: tea.isActive ? 0.4 : 1.0,
          child: SizedBox(
              height: isLargeDevice ? 64.0 : 88.0,
              child: Flex(
                // Determine layout by device size
                direction: isLargeDevice ? Axis.horizontal : Axis.vertical,
                children: [
                  Flexible(
                    child: Container(
                        height: 54.0,
                        padding: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                        child: Row(children: [
                          // Favorite status
                          _favoriteButton(),
                          // Tea name with edit icon
                          _teaNameEditor(),
                        ])),
                  ),
                  // Tea settings selection
                  Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Brew time
                              Flexible(
                                  flex: 10,
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: _teaBrewTimeSelector())),
                              // Brew temperature
                              Flexible(
                                  flex: 10,
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: _teaBrewTempSelector())),
                              // Settings separator
                              ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      minWidth: 16.0,
                                      maxWidth: double.infinity),
                                  child: Container()),
                              // Tea color selection
                              Flexible(
                                  flex: 7,
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: _teaColorSelector())),
                              // Icon selection
                              Flexible(
                                  flex: 7,
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: _teaIconSelector())),
                            ])),
                  ),
                ],
              ))),
      trailing: const SizedBox(height: double.infinity, child: dragHandle),
    ));
  }

  // Button to change favorite status
  Widget _favoriteButton() {
    return IconButton(
        iconSize: 24.0,
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        constraints: const BoxConstraints(minWidth: 32.0, minHeight: 32.0),
        splashRadius: 32.0,
        icon: tea.isFavorite
            ? const Icon(Icons.star, color: Colors.amber)
            : Provider.of<AppProvider>(context, listen: false)
                        .favoritesList
                        .length <
                    favoritesMaxCount
                ? const Icon(Icons.star)
                : const Icon(Icons.star_border_outlined),
        // Toggle favorite status if enabled or max not reached
        onPressed: tea.isFavorite ||
                Provider.of<AppProvider>(context, listen: false)
                        .favoritesList
                        .length <
                    favoritesMaxCount
            ? () {
                // Toggle favorite status
                Provider.of<AppProvider>(context, listen: false)
                    .updateTea(tea, isFavorite: !tea.isFavorite);
              }
            : null);
  }

  // Tea name editor
  Widget _teaNameEditor() {
    return SizedBox(
        height: double.infinity,
        child: InkWell(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(tea.name,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        style: textStyleSetting.copyWith(
                          color: tea.getThemeColor(context),
                        ))),
                Container(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).iconTheme.color,
                      size: 20.0,
                    )),
              ],
            ),
            onTap: () {
              // Open tea name dialog
              _openTeaNameDialog(context, tea.name).then((newValue) {
                if (newValue != null) {
                  // Save name to prefs
                  Provider.of<AppProvider>(context, listen: false)
                      .updateTea(tea, name: newValue);
                }
              });
            }));
  }

  // Display a tea name entry dialog box
  Future<String?> _openTeaNameDialog(
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

  // Tea brew time selection
  Widget _teaBrewTimeSelector() {
    return SizedBox(
        height: double.infinity,
        child: InkWell(
            child: Container(
                padding: const EdgeInsets.only(left: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      formatTimer(tea.brewTime),
                      style: textStyleSettingSeconday,
                    ),
                    dropdownArrow,
                  ],
                )),
            onTap: () {
              // Open tea brew time dialog
              _openTeaBrewTimeDialog(
                      context, tea.brewTimeMinutes, tea.brewTimeSeconds)
                  .then((newValue) {
                if (newValue != null) {
                  // Save brew time to prefs
                  Provider.of<AppProvider>(context, listen: false)
                      .updateTea(tea, brewTime: newValue);
                }
              });
            }));
  }

  // Display a tea brew time entry dialog box
  Future<int?> _openTeaBrewTimeDialog(
      BuildContext context, int currentMinutes, int currentSeconds) async {
    return showDialog<int>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return PlatformAdaptiveTimePickerDialog(
              platform: appPlatform,
              initialMinutes: currentMinutes,
              minuteOptions: brewTimeMinuteOptions,
              initialSeconds: currentSeconds,
              secondOptions: brewTimeSecondOptions,
              buttonTextCancel: AppString.cancel_button.translate(),
              buttonTextOK: AppString.ok_button.translate());
        });
  }

  // Tea brew temp selection
  Widget _teaBrewTempSelector() {
    return SizedBox(
        height: double.infinity,
        child: InkWell(
            child: Container(
                padding: const EdgeInsets.only(left: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      formatTemp(tea.brewTemp),
                      style: textStyleSettingSeconday,
                    ),
                    dropdownArrow,
                  ],
                )),
            onTap: () {
              // Open tea brew temp dialog
              _openTeaBrewTempDialog(context, tea.brewTemp).then((newValue) {
                if (newValue != null) {
                  // Save brew temp to prefs
                  Provider.of<AppProvider>(context, listen: false)
                      .updateTea(tea, brewTemp: newValue);
                }
              });
            }));
  }

  // Display a tea brew temperature entry dialog box
  Future<int?> _openTeaBrewTempDialog(
      BuildContext context, int currentTemp) async {
    return showDialog<int>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return PlatformAdaptiveTempPickerDialog(
              platform: appPlatform,
              initialTemp: currentTemp,
              tempFOptions: brewTempFOptions,
              tempCOptions: brewTempCOptions,
              buttonTextCancel: AppString.cancel_button.translate(),
              buttonTextOK: AppString.ok_button.translate());
        });
  }

  // Tea color selection
  Widget _teaColorSelector() {
    return SizedBox(
        height: double.infinity,
        child: InkWell(
            child: Container(
                padding: const EdgeInsets.only(left: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 18.0,
                      height: 18.0,
                      color: tea.getThemeColor(context),
                    ),
                    dropdownArrow,
                  ],
                )),
            onTap: () {
              // Open tea color dialog
              _openColorDialog(tea, context);
            }));
  }

  // Display a tea color selection dialog box
  Future<bool?> _openColorDialog(Tea tea, BuildContext context) async {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return PlatformAdaptiveDialog(
              platform: appPlatform,
              title: Container(),
              content: SizedBox(
                width: TeaColor.values.length * 16,
                height: min(MediaQuery.of(context).size.height * 0.4,
                    TeaColor.values.length * 24),
                child: Material(
                    type: MaterialType.transparency,
                    child: Scrollbar(
                        child: GridView.count(
                      childAspectRatio: 1.1,
                      crossAxisCount: TeaColor.values.length ~/ 4,
                      mainAxisSpacing: 12.0,
                      crossAxisSpacing: 12.0,
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 12.0),
                      shrinkWrap: true,
                      // Tea color buttons
                      children: List.generate(TeaColor.values.length,
                          (index) => _colorButton(context, index)),
                    ))),
              ),
              buttonTextFalse: AppString.cancel_button.translate());
        });
  }

  // Tea color button
  Widget _colorButton(BuildContext context, int index) {
    TeaColor value = TeaColor.values[index];
    return InkWell(
        child: Container(
            constraints: const BoxConstraints.expand(),
            color: value.getThemeColor(context),
            child: value == tea.color
                ?
                // Timer icon indicates current color
                Icon(
                    tea.teaIcon,
                    size: 24.0,
                    color: Colors.white,
                  )
                : Container()),
        onTap: () {
          // Set selected color
          Provider.of<AppProvider>(context, listen: false)
              .updateTea(tea, color: value);
          Navigator.of(context).pop(true);
        });
  }

  // Tea icon selection
  Widget _teaIconSelector() {
    return SizedBox(
        height: double.infinity,
        child: InkWell(
            child: Container(
                padding: const EdgeInsets.only(left: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        width: 18.0,
                        child: Icon(
                          tea.teaIcon,
                          color: tea.getThemeColor(context),
                        )),
                    dropdownArrow,
                  ],
                )),
            onTap: () {
              // Open tea icon dialog
              _openIconDialog(tea, context);
            }));
  }

  // Display a tea icon selection dialog box
  Future<bool?> _openIconDialog(Tea tea, BuildContext context) async {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return PlatformAdaptiveDialog(
              platform: appPlatform,
              title: Container(),
              content: SizedBox(
                width: TeaIcon.values.length * 12,
                height: TeaIcon.values.length * 12,
                child: Material(
                    type: MaterialType.transparency,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // Tea icon buttons
                      children: List.generate(
                          TeaIcon.values.length, (index) => _iconButton(index)),
                    )),
              ),
              buttonTextFalse: AppString.cancel_button.translate());
        });
  }

  // Tea icon button
  Widget _iconButton(int index) {
    TeaIcon value = TeaIcon.values[index];
    return InkWell(
        child: Icon(
          value.getIcon(),
          size: 36.0,
          color: value == tea.icon ? tea.getThemeColor(context) : null,
        ),
        onTap: () {
          // Set selected icon
          Provider.of<AppProvider>(context, listen: false)
              .updateTea(tea, icon: value);
          Navigator.of(context).pop(true);
        });
  }
}
