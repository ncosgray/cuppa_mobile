/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_settings_card.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea settings card
// - Build interface for tea customization

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/local_notifications.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/brew_ratio.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/tea_brew_ratio_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_brew_temp_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_brew_time_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_color_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_name_dialog.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widget defining a tea settings card
class TeaSettingsCard extends StatelessWidget {
  const TeaSettingsCard({
    super.key,
    required this.tea,
  });

  final Tea tea;

  // Build a tea settings card
  @override
  Widget build(BuildContext context) {
    // Determine layout based on device size
    bool layoutPortrait = getDeviceSize(context).isPortrait ||
        getDeviceSize(context).isLargeDevice;

    return Card(
      margin: bodyPadding,
      child: SizedBox(
        height: layoutPortrait ? 96.0 : 64.0,
        child: Container(
          padding: listTilePadding,
          child: Row(
            children: [
              Expanded(
                child: Flex(
                  // Determine layout by device size
                  direction: layoutPortrait ? Axis.vertical : Axis.horizontal,
                  children: [
                    Expanded(
                      child: Container(
                        height: 54,
                        padding: noPadding,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: smallSpacing,
                          children: [
                            // Favorite status
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _favoriteButton(context),
                            ),
                            // Tea name with edit icon
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _teaNameEditor(context),
                              ),
                            ),
                            Row(
                              children: [
                                // Tea color selection - alternate layout
                                Selector<AppProvider, bool>(
                                  selector: (_, provider) =>
                                      provider.useBrewRatios,
                                  builder: (context, useBrewRatios, child) =>
                                      Visibility(
                                    visible: useBrewRatios,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: _teaColorSelector(context),
                                    ),
                                  ),
                                ),
                                // Extra space for horizontal layout
                                SizedBox(
                                  width: layoutPortrait ? 0.0 : 24.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Tea settings selection
                    Expanded(
                      child: Container(
                        padding: noPadding,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: largeSpacing,
                          children: [
                            // Brew time
                            Align(
                              alignment: layoutPortrait
                                  ? Alignment.centerLeft
                                  : Alignment.center,
                              child: _teaBrewTimeSelector(context),
                            ),
                            // Brew temperature
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _teaBrewTempSelector(context),
                            ),
                            Row(
                              children: [
                                // Brew ratio
                                Selector<AppProvider, bool>(
                                  selector: (_, provider) =>
                                      provider.useBrewRatios,
                                  builder: (context, useBrewRatios, child) =>
                                      Visibility(
                                    visible: useBrewRatios,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: _teaBrewRatioSelector(context),
                                    ),
                                  ),
                                ),
                                // Tea color selection - default layout
                                Selector<AppProvider, bool>(
                                  selector: (_, provider) =>
                                      provider.useBrewRatios,
                                  builder: (context, useBrewRatios, child) =>
                                      Visibility(
                                    visible: !useBrewRatios,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: _teaColorSelector(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Icon selection
                            Align(
                              alignment: Alignment.centerRight,
                              child: _teaIconSelector(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Extra space for horizontal layout
              SizedBox(
                width: layoutPortrait ? 0.0 : 24.0,
              ),
              // Indicate reorderability
              dragHandle,
            ],
          ),
        ),
      ),
    );
  }

  // Button to change favorite status
  Widget _favoriteButton(BuildContext context) {
    return Selector<AppProvider, bool>(
      selector: (_, provider) =>
          provider.favoritesList.length < favoritesMaxCount,
      builder: (context, maxNotReached, child) => InkWell(
        customBorder: const CircleBorder(),
        // Toggle favorite status if enabled or max not reached
        onTap: tea.isFavorite || maxNotReached
            ? () => Provider.of<AppProvider>(context, listen: false)
                .updateTea(tea, isFavorite: !tea.isFavorite)
            : null,
        child: Container(
          padding: smallDefaultPadding,
          child: tea.isFavorite
              ? favoriteStarIcon
              : maxNotReached
                  ? nonFavoriteStarIcon
                  : disabledStarIcon,
        ),
      ),
    );
  }

  // Tea name editor
  Widget _teaNameEditor(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Text(
                tea.name,
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyleSetting.copyWith(
                  color: tea.getColor(),
                ),
              ),
            ),
            Container(
              padding: smallDefaultPadding,
              child: editIcon,
            ),
          ],
        ),
        // Open tea name dialog
        onTap: () => _openTeaNameDialog(context, tea.name).then((newValue) {
          if (newValue != null) {
            // Save name to prefs
            Provider.of<AppProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).updateTea(tea, name: newValue);

            // Edit notification for active timer
            if (tea.isActive &&
                tea.brewTimeRemaining > 0 &&
                tea.timerNotifyID != null) {
              sendNotification(
                tea.brewTimeRemaining,
                AppString.notification_title.translate(),
                AppString.notification_text.translate(teaName: tea.name),
                tea.timerNotifyID!,
                silent: tea.isSilent,
              );
            }
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

  // Tea color selection
  Widget _teaColorSelector(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: tea.getColor(),
              ),
            ),
            dropdownArrow,
          ],
        ),
        // Open tea color dialog
        onTap: () => _openColorDialog(context, tea.color, tea.colorShade)
            .then((newValues) {
          if (newValues != null) {
            // Save color data to prefs
            Provider.of<AppProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).updateTea(
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

  // Tea brew time selection
  Widget _teaBrewTimeSelector(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              formatTimer(tea.brewTime),
              style: textStyleSettingNumber,
            ),
            dropdownArrow,
          ],
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
            Provider.of<AppProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).updateTea(tea, brewTime: newValue);
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
  Widget _teaBrewTempSelector(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              formatTemp(
                tea.brewTemp,
                useCelsius:
                    Provider.of<AppProvider>(context, listen: false).useCelsius,
              ),
              style: textStyleSettingNumber,
            ),
            dropdownArrow,
          ],
        ),
        // Open tea brew temp dialog
        onTap: () =>
            _openTeaBrewTempDialog(context, tea.brewTemp).then((newValue) {
          if (newValue != null) {
            // Save brew temp to prefs
            Provider.of<AppProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).updateTea(tea, brewTemp: newValue);
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
          useCelsius:
              Provider.of<AppProvider>(context, listen: false).useCelsius,
          tempCOptions: brewTempCOptions,
          tempFOptions: brewTempFOptions,
          tempCIncrements: brewTempCIncrements,
          tempFIncrements: brewTempFIncrements,
          buttonTextCancel: AppString.cancel_button.translate(),
          buttonTextOK: AppString.ok_button.translate(),
        );
      },
    );
  }

  // Tea brew ratio selection
  Widget _teaBrewRatioSelector(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              tea.brewRatio.numeratorString,
              style: textStyleSettingNumber,
            ),
            dropdownArrow,
          ],
        ),
        // Open tea brew ratio dialog
        onTap: () =>
            _openTeaBrewRatioDialog(context, tea.brewRatio).then((newValue) {
          if (newValue != null) {
            // Save brew ratio to prefs
            Provider.of<AppProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).updateTea(
              tea,
              brewRatio: newValue,
            );
          }
        }),
      ),
    );
  }

  // Display a tea brew ratio entry dialog box
  Future<BrewRatio?> _openTeaBrewRatioDialog(
    BuildContext context,
    BrewRatio currentRatio,
  ) async {
    return showAdaptiveDialog<BrewRatio?>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TeaBrewRatioDialog(
          initialRatio: currentRatio,
          buttonTextCancel: AppString.cancel_button.translate(),
          buttonTextOK: AppString.ok_button.translate(),
        );
      },
    );
  }

  // Tea icon selection
  Widget _teaIconSelector(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              tea.teaIcon,
              color: Theme.of(context).textTheme.bodySmall!.color!,
              size: 22,
            ),
            dropdownArrow,
          ],
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
                    (index) => _iconButton(context, index),
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
  Widget _iconButton(BuildContext context, int index) {
    TeaIcon value = TeaIcon.values[index];
    return adaptiveLargeButton(
      icon: value.getIcon(),
      iconColor: Theme.of(context).textTheme.bodySmall!.color!,
      // Set selected icon
      onPressed: () {
        Provider.of<AppProvider>(
          navigatorKey.currentContext!,
          listen: false,
        ).updateTea(tea, icon: value);
        Navigator.of(navigatorKey.currentContext!).pop(true);
      },
    );
  }
}
