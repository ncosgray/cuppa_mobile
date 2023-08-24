/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    platform_adaptive.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa platform adaptive elements
// - Light and dark themes for Android and iOS
// - Icons for Android and iOS
// - Buttons for Android and iOS
// - PlatformAdaptiveNavBar creates page navigation for context platform
// - PlatformAdaptiveTempPickerDialog temp entry dialog for context platform
// - PlatformAdaptiveListTile list tile for context platform
// - openPlatformAdaptiveSelectList modal/dialog selector for context platform

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// iOS themes
final ThemeData kIOSTheme = ThemeData(
  primaryColor: Colors.grey.shade100,
  textTheme: Typography.blackCupertino,
  iconTheme: const IconThemeData(
    color: Colors.grey,
  ),
  brightness: Brightness.light,
);
final ThemeData kIOSDarkTheme = ThemeData(
  primaryColor: Colors.grey.shade900,
  textTheme: Typography.whiteCupertino,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  brightness: Brightness.dark,
);
final ThemeData kIOSBlackTheme = ThemeData(
  primaryColor: Colors.grey.shade900,
  scaffoldBackgroundColor: Colors.black,
  cardColor: Colors.grey.shade900,
  textTheme: Typography.whiteCupertino,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  brightness: Brightness.dark,
);

// Android themes
final ThemeData kDefaultTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.blue,
  textTheme: Typography.blackMountainView,
  iconTheme: const IconThemeData(
    color: Colors.grey,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.grey,
  ),
  brightness: Brightness.light,
);
final ThemeData kDarkTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.blue,
  scaffoldBackgroundColor: const Color(0xff323232),
  cardTheme: CardTheme(
    color: Colors.grey.shade800,
  ),
  textTheme: Typography.whiteMountainView,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.white,
  ),
  brightness: Brightness.dark,
);
final ThemeData kBlackTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.blue,
  scaffoldBackgroundColor: Colors.black,
  textTheme: Typography.whiteMountainView,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.white,
  ),
  brightness: Brightness.dark,
);

// Get theme appropriate to platform
ThemeData getPlatformAdaptiveTheme({ColorScheme? dynamicColors}) {
  ThemeData theme =
      appPlatform == TargetPlatform.iOS ? kIOSTheme : kDefaultTheme;
  if (dynamicColors != null) {
    // Use dynamic colors if provided
    theme = theme.copyWith(colorScheme: dynamicColors.harmonized());
  }
  return theme;
}

ThemeData getPlatformAdaptiveDarkTheme({
  ColorScheme? dynamicColors,
  bool blackTheme = true,
}) {
  ThemeData theme = appPlatform == TargetPlatform.iOS
      ? (blackTheme ? kIOSBlackTheme : kIOSDarkTheme)
      : (blackTheme ? kBlackTheme : kDarkTheme);
  if (dynamicColors != null) {
    // Use dynamic colors if provided
    theme = theme.copyWith(colorScheme: dynamicColors.harmonized());
  }
  return theme;
}

// Platform specific icons
Icon getPlatformSettingsIcon() {
  return appPlatform == TargetPlatform.iOS
      ? const Icon(CupertinoIcons.settings_solid)
      : const Icon(Icons.settings);
}

Icon getPlatformAboutIcon() {
  return appPlatform == TargetPlatform.iOS
      ? const Icon(CupertinoIcons.question)
      : const Icon(Icons.help);
}

Icon getPlatformRemoveIcon(Color color) {
  return appPlatform == TargetPlatform.iOS
      ? Icon(CupertinoIcons.trash_fill, color: color)
      : Icon(Icons.delete_outline, color: color);
}

Icon getPlatformRemoveAllIcon(Color color) {
  return appPlatform == TargetPlatform.iOS
      ? Icon(CupertinoIcons.square_stack_3d_up_slash_fill, color: color)
      : Icon(Icons.delete_sweep_outlined, color: color);
}

// Dialog action button appropriate to platform
Widget adaptiveDialogAction({
  bool isDefaultAction = false,
  required String text,
  required Function()? onPressed,
}) {
  if (appPlatform == TargetPlatform.iOS) {
    return CupertinoDialogAction(
      isDefaultAction: isDefaultAction,
      onPressed: onPressed,
      child: Text(text),
    );
  } else {
    return FilledButton.tonal(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

// Small button with styling appropriate to platform
Widget adaptiveSmallButton({
  required IconData icon,
  required Function()? onPressed,
}) {
  if (appPlatform == TargetPlatform.iOS) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(icon),
    );
  } else {
    return OutlinedButton(
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}

// Navigation bar that is Material on Android and Cupertino on iOS
class PlatformAdaptiveNavBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PlatformAdaptiveNavBar({
    Key? key,
    required this.isPoppable,
    this.textScaleFactor = 1.0,
    required this.title,
    this.actionRoute,
    this.actionIcon,
  }) : super(key: key);

  final bool isPoppable;
  final double textScaleFactor;
  final String title;
  final Widget? actionRoute;
  final Widget? actionIcon;

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // Android default

  @override
  Widget build(BuildContext context) {
    if (appPlatform == TargetPlatform.iOS) {
      return CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        backgroundColor: Theme.of(context).primaryColor,
        leading: isPoppable
            ? CupertinoNavigationBarBackButton(
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        middle: Text(
          title,
          textScaleFactor: textScaleFactor,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
        ),
        trailing: actionIcon != null && actionRoute != null
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => actionRoute!)),
                child: actionIcon!,
              )
            : null,
      );
    } else {
      return AppBar(
        elevation: 4,
        title: Text(title),
        actions: actionIcon != null && actionRoute != null
            ? <Widget>[
                IconButton(
                  icon: actionIcon!,
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => actionRoute!)),
                ),
              ]
            : null,
      );
    }
  }
}

// Display a tea brew temperature entry dialog box
class PlatformAdaptiveTempPickerDialog extends StatefulWidget {
  const PlatformAdaptiveTempPickerDialog({
    Key? key,
    required this.initialTemp,
    required this.tempFOptions,
    required this.tempCOptions,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  }) : super(key: key);

  final int initialTemp;
  final List<int> tempFOptions;
  final List<int> tempCOptions;
  final String buttonTextCancel;
  final String buttonTextOK;

  @override
  State<PlatformAdaptiveTempPickerDialog> createState() =>
      _PlatformAdaptiveTempPickerDialogState(
        initialTemp: initialTemp,
        tempFOptions: tempFOptions,
        tempCOptions: tempCOptions,
        buttonTextCancel: buttonTextCancel,
        buttonTextOK: buttonTextOK,
      );
}

class _PlatformAdaptiveTempPickerDialogState
    extends State<PlatformAdaptiveTempPickerDialog> {
  _PlatformAdaptiveTempPickerDialogState({
    required this.initialTemp,
    required this.tempFOptions,
    required this.tempCOptions,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  });

  final int initialTemp;
  final List<int> tempFOptions;
  final List<int> tempCOptions;
  final String buttonTextCancel;
  final String buttonTextOK;

  // State variables
  late int _newTemp;
  int _newTempIndex = 0;
  late bool _unitsCelsius;

  // Initialize dialog state
  @override
  void initState() {
    super.initState();

    // Set starting values
    _newTemp = initialTemp;
    if (tempCOptions.contains(_newTemp)) {
      _newTempIndex = tempCOptions.indexOf(_newTemp);
    }
    if (tempFOptions.contains(_newTemp)) {
      _newTempIndex = tempFOptions.indexOf(_newTemp);
    }
    _unitsCelsius = isTempCelsius(initialTemp);
  }

  // Build dialog
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      // Temperature entry
      content: _tempPicker(),
      actions: <Widget>[
        // Cancel and close dialog
        adaptiveDialogAction(
          text: buttonTextCancel,
          onPressed: () => Navigator.pop(context, null),
        ),
        // Save and close dialog
        adaptiveDialogAction(
          text: buttonTextOK,
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, _newTemp),
        ),
      ],
    );
  }

  // Build a temperature picker
  Widget _tempPicker() {
    const Widget tempPickerSpacer = SizedBox(height: 14.0);

    return SizedBox(
      height: 175.0,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Unit selector
            _adaptiveUnitPicker(),
            tempPickerSpacer,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Increment down
                adaptiveSmallButton(
                  icon: Icons.keyboard_arrow_down,
                  onPressed: _newTempIndex > 0
                      ? () {
                          _newTempIndex--;
                          _updateTempSlider();
                        }
                      : null,
                ),
                // Display selected temperature
                Text(
                  formatTemp(_newTemp),
                  style: textStyleSettingSeconday,
                ),
                // Increment up
                adaptiveSmallButton(
                  icon: Icons.keyboard_arrow_up,
                  onPressed: _newTempIndex < tempCOptions.length - 1
                      ? () {
                          _newTempIndex++;
                          _updateTempSlider();
                        }
                      : null,
                ),
              ],
            ),
            tempPickerSpacer,
            // Temperature picker
            Slider.adaptive(
              value: _newTempIndex.toDouble(),
              min: 0.0,
              max: (tempCOptions.length - 1).toDouble(),
              divisions: tempCOptions.length - 1,
              onChanged: (newValue) {
                _newTempIndex = newValue.toInt();
                _updateTempSlider();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Build an adaptive temperature unit picker (sliding control or segments)
  Widget _adaptiveUnitPicker() {
    if (appPlatform == TargetPlatform.iOS) {
      return CupertinoSlidingSegmentedControl<bool>(
        groupValue: _unitsCelsius,
        onValueChanged: (bool? selected) {
          if (selected != null) {
            setState(() {
              _unitsCelsius = selected;
              if (_unitsCelsius) {
                _newTemp = tempCOptions[_newTempIndex];
              } else {
                _newTemp = tempFOptions[_newTempIndex];
              }
            });
          }
        },
        children: <bool, Widget>{
          // Degrees C
          true: Text(degreesC),
          // Degrees F
          false: Text(degreesF),
        },
      );
    } else {
      return SegmentedButton<bool>(
        selected: <bool>{_unitsCelsius},
        onSelectionChanged: (Set<bool> selected) {
          setState(() {
            _unitsCelsius = selected.first;
            if (_unitsCelsius) {
              _newTemp = tempCOptions[_newTempIndex];
            } else {
              _newTemp = tempFOptions[_newTempIndex];
            }
          });
        },
        segments: <ButtonSegment<bool>>[
          // Degrees C
          ButtonSegment<bool>(
            value: true,
            label: Text(degreesC),
          ),
          // Degrees F
          ButtonSegment<bool>(
            value: false,
            label: Text(degreesF),
          ),
        ],
      );
    }
  }

  // Update temperature slider position
  void _updateTempSlider() {
    setState(() {
      _newTemp = _unitsCelsius
          ? tempCOptions[_newTempIndex]
          : tempFOptions[_newTempIndex];
    });
  }
}

// List tile with styling appropriate to platform
class PlatformAdaptiveListTile extends StatelessWidget {
  const PlatformAdaptiveListTile({
    Key? key,
    required this.itemIcon,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  final Widget itemIcon;
  final Widget item;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (appPlatform == TargetPlatform.iOS) {
      return CupertinoListTile(
        backgroundColorActivated: Colors.transparent,
        leading: itemIcon,
        title: item,
        onTap: onTap,
      );
    } else {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: itemIcon,
        title: item,
        onTap: onTap,
      );
    }
  }
}

// Display a selector list that is Material on Android and Cupertino on iOS
Future<bool?> openPlatformAdaptiveSelectList({
  required BuildContext context,
  required String titleText,
  required String buttonTextCancel,
  required List<dynamic> itemList,
  required Widget Function(BuildContext, int) itemBuilder,
  required Widget Function(BuildContext, int) separatorBuilder,
}) async {
  if (appPlatform == TargetPlatform.iOS) {
    // iOS style modal list
    return showCupertinoModalPopup<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: CupertinoActionSheet(
            title: Text(titleText),
            // Item options
            actions: itemList
                .asMap()
                .entries
                .map(
                  (item) => CupertinoActionSheetAction(
                    child: itemBuilder(context, item.key),
                    onPressed: () {}, // Tap handled by itemBuilder
                  ),
                )
                .toList(),
            // Cancel button
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(buttonTextCancel),
            ),
          ),
        );
      },
    );
  } else {
    // Scrolling dialog list
    return showAdaptiveDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Text(titleText),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Scrollbar(
              // Item options
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: itemList.length,
                itemBuilder: itemBuilder,
                separatorBuilder: separatorBuilder,
              ),
            ),
          ),
          actions: [
            // Cancel button
            adaptiveDialogAction(
              text: buttonTextCancel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        );
      },
    );
  }
}
