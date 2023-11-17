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
// - Buttons and controls for Android and iOS
// - Text form field for Android and iOS
// - PlatformAdaptiveNavBar creates page navigation for context platform
// - PlatformAdaptiveListTile list tile for context platform
// - openPlatformAdaptiveSelectList modal/dialog selector for context platform

import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/widgets/common.dart';

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
      style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}

// Large button with styling appropriate to platform
Widget adaptiveLargeButton({
  required IconData icon,
  required Function()? onPressed,
}) {
  if (appPlatform == TargetPlatform.iOS) {
    return CupertinoButton(
      minSize: 72.0,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(icon, size: 36.0),
    );
  } else {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.comfortable,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        minimumSize: const Size(60.0, 60.0),
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 36.0),
    );
  }
}

// Build a platform adaptive text form field with clear button and validation
Widget adaptiveTextFormField({
  required Color textColor,
  required Color? cursorColor,
  required TextEditingController controller,
  required String? Function(String?)? validator,
  required Function()? onCleared,
  required Function(String)? onChanged,
}) {
  if (appPlatform == TargetPlatform.iOS) {
    return CupertinoFormSection.insetGrouped(
      margin: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      children: [
        Row(
          children: [
            SizedBox(
              width: 186.0,
              child: CupertinoTextFormFieldRow(
                controller: controller,
                autofocus: true,
                autocorrect: false,
                enableSuggestions: false,
                enableInteractiveSelection: true,
                textCapitalization: TextCapitalization.words,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                padding: const EdgeInsets.all(8.0),
                style: TextStyle(color: textColor),
                cursorColor: cursorColor,
                validator: validator,
                onChanged: onChanged,
              ),
            ),
            Visibility(
              visible: controller.text.isNotEmpty,
              // Clear field button
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onCleared,
                child: clearIcon,
              ),
              //),
            ),
          ],
        ),
      ],
    );
  } else {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        autofocus: true,
        autocorrect: false,
        enableSuggestions: false,
        enableInteractiveSelection: true,
        textCapitalization: TextCapitalization.words,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          counter: const Offstage(),
          suffixIcon: controller.text.isNotEmpty
              // Clear field button
              ? IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onCleared,
                  icon: clearIcon,
                )
              : null,
        ),
        style: TextStyle(color: textColor),
        cursorColor: cursorColor,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}

// Segmented control with styling appropriate to platform
Widget adaptiveSegmentedControl({
  required String buttonTextTrue,
  required String buttonTextFalse,
  required bool groupValue,
  required Function(bool?) onValueChanged,
}) {
  if (appPlatform == TargetPlatform.iOS) {
    return CupertinoSlidingSegmentedControl<bool>(
      groupValue: groupValue,
      onValueChanged: onValueChanged,
      children: <bool, Widget>{
        true: Text(buttonTextTrue),
        false: Text(buttonTextFalse),
      },
    );
  } else {
    // Refactor onChanged function to use a set of values
    onValueSetChanged(Set<bool>? selected) {
      return onValueChanged(selected?.first);
    }

    return SegmentedButton<bool>(
      selected: <bool>{groupValue},
      onSelectionChanged: onValueSetChanged,
      segments: <ButtonSegment<bool>>[
        ButtonSegment<bool>(
          value: true,
          label: Text(buttonTextTrue),
        ),
        ButtonSegment<bool>(
          value: false,
          label: Text(buttonTextFalse),
        ),
      ],
    );
  }
}

// Navigation bar that is Material on Android and Cupertino on iOS
class PlatformAdaptiveNavBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PlatformAdaptiveNavBar({
    super.key,
    required this.isPoppable,
    required this.title,
    this.actionRoute,
    this.actionIcon,
  });

  final bool isPoppable;
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

// List tile with styling appropriate to platform
class PlatformAdaptiveListTile extends StatelessWidget {
  const PlatformAdaptiveListTile({
    super.key,
    required this.itemIcon,
    required this.item,
    required this.onTap,
  });

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
            width: double.maxFinite,
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
