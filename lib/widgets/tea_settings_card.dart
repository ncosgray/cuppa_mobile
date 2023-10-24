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
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/common.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/tea_brew_temp_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_brew_time_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_color_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_name_dialog.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widget defining a tea settings card
class TeaSettingsCard extends StatefulWidget {
  const TeaSettingsCard({
    super.key,
    required this.tea,
  });

  final Tea tea;

  @override
  _TeaSettingsCardState createState() => _TeaSettingsCardState(tea: tea);
}

class _TeaSettingsCardState extends State<TeaSettingsCard>
    with SingleTickerProviderStateMixin {
  _TeaSettingsCardState({
    required this.tea,
  });

  final Tea tea;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  initState() {
    super.initState();

    // Settings card pop-in
    _animationController = AnimationController(
      duration: shortAnimationDuration,
      vsync: this,
    );
    _animation = Tween(
      begin: 0.5,
      end: 1.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Animate adding a new tea or skip animation for existing teas
    if (tea.animate) {
      tea.animate = false;
      _animationController.forward();
      return ScaleTransition(
        scale: _animation,
        child: _settingsCard(context),
      );
    } else {
      return _settingsCard(context);
    }
  }

  // Build a tea settings card
  Widget _settingsCard(BuildContext context) {
    // Determine layout based on device size
    bool layoutPortrait = getDeviceSize(context).isPortrait ||
        getDeviceSize(context).isLargeDevice;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: IgnorePointer(
        // Disable editing actively brewing tea
        ignoring: tea.isActive,
        child: ListTile(
          horizontalTitleGap: layoutPortrait ? 4.0 : 24.0,
          title: Opacity(
            opacity: tea.isActive ? 0.4 : 1.0,
            child: SizedBox(
              height: layoutPortrait ? 88.0 : 64.0,
              child: Flex(
                // Determine layout by device size
                direction: layoutPortrait ? Axis.vertical : Axis.horizontal,
                children: [
                  Flexible(
                    child: Container(
                      height: 54.0,
                      padding: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                      child: Row(
                        children: [
                          // Favorite status
                          _favoriteButton(),
                          // Tea name with edit icon
                          _teaNameEditor(),
                        ],
                      ),
                    ),
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
                            flex: 11,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _teaBrewTimeSelector(),
                            ),
                          ),
                          // Brew temperature
                          Flexible(
                            flex: 8,
                            child: Align(
                              alignment: Alignment.center,
                              child: _teaBrewTempSelector(),
                            ),
                          ),
                          // Settings separator
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 12.0,
                              maxWidth: double.infinity,
                            ),
                            child: Container(),
                          ),
                          // Tea color selection
                          Flexible(
                            flex: 6,
                            child: Align(
                              alignment: Alignment.center,
                              child: _teaColorSelector(),
                            ),
                          ),
                          // Icon selection
                          Flexible(
                            flex: 6,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _teaIconSelector(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          trailing: const SizedBox(height: double.infinity, child: dragHandle),
        ),
      ),
    );
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
          ? () => Provider.of<AppProvider>(context, listen: false)
              .updateTea(tea, isFavorite: !tea.isFavorite)
          : null,
    );
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
              child: Text(
                tea.name,
                textAlign: TextAlign.left,
                maxLines: 1,
                style: textStyleSetting.copyWith(
                  color: tea.getColor(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 6.0),
              child: Icon(
                Icons.edit,
                color: Theme.of(context).iconTheme.color,
                size: 20.0,
              ),
            ),
          ],
        ),
        // Open tea name dialog
        onTap: () => _openTeaNameDialog(context, tea.name).then((newValue) {
          if (newValue != null) {
            // Save name to prefs
            Provider.of<AppProvider>(context, listen: false)
                .updateTea(tea, name: newValue);
          }
        }),
      ),
    );
  }

  // Display a tea name entry dialog box
  Future<String?> _openTeaNameDialog(
    BuildContext context,
    String currentTeaName,
  ) async {
    return showAdaptiveDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TeaNameDialog(
          initialValue: currentTeaName,
          validator: (String? newValue) {
            // Checks for valid tea names
            if (newValue == null || newValue.isEmpty) {
              return AppString.error_name_missing.translate();
            } else if (newValue.characters.length > teaNameMaxLength) {
              return AppString.error_name_long.translate();
            }
            return null;
          },
          buttonTextCancel: AppString.cancel_button.translate(),
          buttonTextOK: AppString.ok_button.translate(),
        );
      },
    );
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
          ),
        ),
        // Open tea brew time dialog
        onTap: () => _openTeaBrewTimeDialog(
          context,
          tea.brewTimeHours,
          tea.brewTimeMinutes,
          tea.brewTimeSeconds,
        ).then((newValue) {
          if (newValue != null) {
            // Save brew time to prefs
            Provider.of<AppProvider>(context, listen: false)
                .updateTea(tea, brewTime: newValue);
          }
        }),
      ),
    );
  }

  // Display a tea brew time entry dialog box
  Future<int?> _openTeaBrewTimeDialog(
    BuildContext context,
    int currentHours,
    int currentMinutes,
    int currentSeconds,
  ) async {
    return showAdaptiveDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TeaBrewTimeDialog(
          initialHours: currentHours,
          hourOptions: brewTimeHourOptions,
          hourLabel: AppString.unit_hours.translate(),
          initialMinutes: currentMinutes,
          minuteOptions: brewTimeMinuteOptions,
          minuteLabel: AppString.unit_minutes.translate(),
          initialSeconds: currentSeconds,
          secondOptions: brewTimeSecondOptions,
          buttonTextCancel: AppString.cancel_button.translate(),
          buttonTextOK: AppString.ok_button.translate(),
        );
      },
    );
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
                formatTemp(
                  tea.brewTemp,
                  useCelsius: Provider.of<AppProvider>(context, listen: false)
                      .useCelsius,
                ),
                style: textStyleSettingSeconday,
              ),
              dropdownArrow,
            ],
          ),
        ),
        // Open tea brew temp dialog
        onTap: () =>
            _openTeaBrewTempDialog(context, tea.brewTemp).then((newValue) {
          if (newValue != null) {
            // Save brew temp to prefs
            Provider.of<AppProvider>(context, listen: false)
                .updateTea(tea, brewTemp: newValue);
          }
        }),
      ),
    );
  }

  // Display a tea brew temperature entry dialog box
  Future<int?> _openTeaBrewTempDialog(
    BuildContext context,
    int currentTemp,
  ) async {
    return showAdaptiveDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TeaBrewTempDialog(
          initialTemp: currentTemp,
          tempFOptions: brewTempFOptions,
          tempCOptions: brewTempCOptions,
          buttonTextCancel: AppString.cancel_button.translate(),
          buttonTextOK: AppString.ok_button.translate(),
        );
      },
    );
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: tea.getColor(),
                ),
              ),
              dropdownArrow,
            ],
          ),
        ),
        // Open tea color dialog
        onTap: () => _openColorDialog(context, tea.color, tea.colorShade)
            .then((newValues) {
          if (newValues != null) {
            // Save color data to prefs
            Provider.of<AppProvider>(context, listen: false).updateTea(
              tea,
              color: newValues.teaColor,
              colorShade: newValues.colorShade,
            );
          }
        }),
      ),
    );
  }

  // Display a tea color selection dialog box
  Future<({TeaColor teaColor, Color? colorShade})?> _openColorDialog(
    BuildContext context,
    TeaColor currentTeaColor,
    Color? currentColorShade,
  ) async {
    return showAdaptiveDialog<({TeaColor teaColor, Color? colorShade})>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TeaColorDialog(
          initialTeaColor: currentTeaColor,
          initialColorShade: currentColorShade,
          previewIcon: tea.teaIcon,
          buttonTextCancel: AppString.cancel_button.translate(),
          buttonTextOK: AppString.ok_button.translate(),
        );
      },
    );
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
                  color: tea.getColor(),
                ),
              ),
              dropdownArrow,
            ],
          ),
        ),
        // Open tea icon dialog
        onTap: () => _openIconDialog(context, tea),
      ),
    );
  }

  // Display a tea icon selection dialog box
  Future<bool?> _openIconDialog(BuildContext context, Tea tea) async {
    return showAdaptiveDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Container(),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // Tea icon buttons
                  children: List.generate(
                    TeaIcon.values.length,
                    (index) => _iconButton(index),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            adaptiveDialogAction(
              text: AppString.cancel_button.translate(),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        );
      },
    );
  }

  // Tea icon button
  Widget _iconButton(int index) {
    TeaIcon value = TeaIcon.values[index];
    return adaptiveLargeButton(
      icon: value.getIcon(),
      // Set selected icon
      onPressed: () {
        Provider.of<AppProvider>(context, listen: false)
            .updateTea(tea, icon: value);
        Navigator.of(context).pop(true);
      },
    );
  }
}
