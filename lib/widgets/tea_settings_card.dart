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
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/brew_ratio.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/tea_brew_ratio_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_brew_temp_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_brew_time_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_color_dialog.dart';
import 'package:cuppa_mobile/widgets/tea_name_dialog.dart';

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
  State<TeaSettingsCard> createState() => _TeaSettingsCardState();
}

class _TeaSettingsCardState extends State<TeaSettingsCard>
    with SingleTickerProviderStateMixin {
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
    if (widget.tea.animate) {
      widget.tea.animate = false;
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
      margin: bodyPadding,
      child: ListTile(
        horizontalTitleGap: layoutPortrait ? 4.0 : 24.0,
        title: SizedBox(
          height: layoutPortrait ? 88.0 : 64.0,
          child: Flex(
            // Determine layout by device size
            direction: layoutPortrait ? Axis.vertical : Axis.horizontal,
            children: [
              Flexible(
                child: Container(
                  height: 54.0,
                  padding: noPadding,
                  child: Row(
                    children: [
                      // Favorite status
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _favoriteButton(),
                      ),
                      smallSpacerWidget,
                      // Tea name with edit icon
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _teaNameEditor(),
                        ),
                      ),
                      smallSpacerWidget,
                      // Tea color selection - alternate layout
                      Selector<AppProvider, bool>(
                        selector: (_, provider) => provider.useBrewRatios,
                        builder: (context, useBrewRatios, child) => Visibility(
                          visible: useBrewRatios,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _teaColorSelector(),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !layoutPortrait,
                        child: smallSpacerWidget,
                      ),
                    ],
                  ),
                ),
              ),
              // Tea settings selection
              Flexible(
                child: Container(
                  padding: noPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brew time
                      Expanded(
                        child: Align(
                          alignment: layoutPortrait
                              ? Alignment.centerLeft
                              : Alignment.center,
                          child: _teaBrewTimeSelector(),
                        ),
                      ),
                      smallSpacerWidget,
                      // Brew temperature
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _teaBrewTempSelector(),
                      ),
                      // Brew ratio
                      smallSpacerWidget,
                      Selector<AppProvider, bool>(
                        selector: (_, provider) => provider.useBrewRatios,
                        builder: (context, useBrewRatios, child) => Visibility(
                          visible: useBrewRatios,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _teaBrewRatioSelector(),
                          ),
                        ),
                      ),
                      smallSpacerWidget,
                      // Tea color selection - default layout
                      Selector<AppProvider, bool>(
                        selector: (_, provider) => provider.useBrewRatios,
                        builder: (context, useBrewRatios, child) => Visibility(
                          visible: !useBrewRatios,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _teaColorSelector(),
                          ),
                        ),
                      ),
                      smallSpacerWidget,
                      // Icon selection
                      Align(
                        alignment: Alignment.centerRight,
                        child: _teaIconSelector(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: const SizedBox(height: double.infinity, child: dragHandle),
      ),
    );
  }

  // Button to change favorite status
  Widget _favoriteButton() {
    return InkWell(
      customBorder: const CircleBorder(),
      // Toggle favorite status if enabled or max not reached
      onTap: widget.tea.isFavorite ||
              Provider.of<AppProvider>(context, listen: false)
                      .favoritesList
                      .length <
                  favoritesMaxCount
          ? () => Provider.of<AppProvider>(context, listen: false)
              .updateTea(widget.tea, isFavorite: !widget.tea.isFavorite)
          : null,
      child: Container(
        padding: smallDefaultPadding,
        child: widget.tea.isFavorite
            ? favoriteStarIcon
            : Provider.of<AppProvider>(context, listen: false)
                        .favoritesList
                        .length <
                    favoritesMaxCount
                ? nonFavoriteStarIcon
                : disabledStarIcon,
      ),
    );
  }

  // Tea name editor
  Widget _teaNameEditor() {
    return SizedBox(
      height: double.infinity,
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Text(
                widget.tea.name,
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyleSetting.copyWith(
                  color: widget.tea.getColor(),
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
        onTap: () =>
            _openTeaNameDialog(context, widget.tea.name).then((newValue) {
          if (newValue != null) {
            // Save name to prefs
            Provider.of<AppProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).updateTea(widget.tea, name: newValue);

            // Edit notification for active timer
            if (widget.tea.isActive &&
                widget.tea.brewTimeRemaining > 0 &&
                widget.tea.timerNotifyID != null) {
              sendNotification(
                widget.tea.brewTimeRemaining,
                AppString.notification_title.translate(),
                AppString.notification_text.translate(teaName: widget.tea.name),
                widget.tea.timerNotifyID!,
                silent: widget.tea.isSilent,
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
  Widget _teaColorSelector() {
    return SizedBox(
      height: double.infinity,
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: widget.tea.getColor(),
              ),
            ),
            dropdownArrow,
          ],
        ),
        // Open tea color dialog
        onTap: () =>
            _openColorDialog(context, widget.tea.color, widget.tea.colorShade)
                .then((newValues) {
          if (newValues != null) {
            // Save color data to prefs
            Provider.of<AppProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).updateTea(
              widget.tea,
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
          previewIcon: widget.tea.teaIcon,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              formatTimer(widget.tea.brewTime),
              style: textStyleSettingSeconday,
            ),
            dropdownArrow,
          ],
        ),
        // Open tea brew time dialog
        onTap: () => _openTeaBrewTimeDialog(
          context,
          widget.tea.brewTimeHours,
          widget.tea.brewTimeMinutes,
          widget.tea.brewTimeSeconds,
        ).then((newValue) {
          if (newValue != null) {
            // Save brew time to prefs
            Provider.of<AppProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).updateTea(widget.tea, brewTime: newValue);
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              formatTemp(
                widget.tea.brewTemp,
                useCelsius:
                    Provider.of<AppProvider>(context, listen: false).useCelsius,
              ),
              style: textStyleSettingSeconday,
            ),
            dropdownArrow,
          ],
        ),
        // Open tea brew temp dialog
        onTap: () => _openTeaBrewTempDialog(context, widget.tea.brewTemp)
            .then((newValue) {
          if (newValue != null) {
            // Save brew temp to prefs
            Provider.of<AppProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).updateTea(widget.tea, brewTemp: newValue);
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
  Widget _teaBrewRatioSelector() {
    return SizedBox(
      height: double.infinity,
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.tea.getBrewRatioDisplay(truncate: true),
              style: textStyleSettingSeconday,
            ),
            dropdownArrow,
          ],
        ),
        // Open tea brew ratio dialog
        onTap: () => _openTeaBrewRatioDialog(context, widget.tea.brewRatio)
            .then((newValue) {
          if (newValue != null) {
            // Save brew ratio to prefs
            Provider.of<AppProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).updateTea(
              widget.tea,
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
  Widget _teaIconSelector() {
    return SizedBox(
      height: double.infinity,
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              widget.tea.teaIcon,
              color: Theme.of(context).textTheme.bodySmall!.color!,
              size: 22.0,
            ),
            dropdownArrow,
          ],
        ),
        // Open tea icon dialog
        onTap: () => _openIconDialog(context, widget.tea),
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
        Provider.of<AppProvider>(
          navigatorKey.currentContext!,
          listen: false,
        ).updateTea(widget.tea, icon: value);
        Navigator.of(navigatorKey.currentContext!).pop(true);
      },
    );
  }
}
