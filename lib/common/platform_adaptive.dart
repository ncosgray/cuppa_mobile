/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    platform_adaptive.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa platform adaptive elements
// - Icons for Android and iOS
// - Buttons and controls for Android and iOS
// - Text form field for Android and iOS
// - Create NavBar and BottomNavBar page navigation for context platform
// - openPlatformAdaptiveSelectList modal/dialog selector for context platform

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Platform specific icons
Icon getPlatformSettingsIcon() {
  return Platform.isIOS
      ? const Icon(CupertinoIcons.settings_solid)
      : const Icon(Icons.settings);
}

Icon getPlatformAboutIcon() {
  return Platform.isIOS
      ? const Icon(CupertinoIcons.question)
      : const Icon(Icons.help);
}

Icon getPlatformStatsIcon() {
  return Platform.isIOS
      ? const Icon(CupertinoIcons.chart_pie)
      : const Icon(Icons.pie_chart_outline);
}

Icon getPlatformRemoveIcon([Color? color]) {
  return Platform.isIOS
      ? Icon(CupertinoIcons.trash_fill, color: color)
      : Icon(Icons.delete_outline, color: color);
}

Icon getPlatformRemoveAllIcon([Color? color]) {
  return Platform.isIOS
      ? Icon(CupertinoIcons.square_stack_3d_up_slash_fill, color: color)
      : Icon(Icons.delete_sweep_outlined, color: color);
}

Icon getPlatformSortIcon() {
  return Platform.isIOS
      ? const Icon(CupertinoIcons.sort_down)
      : const Icon(Icons.swap_vert);
}

// Nav bar action button with styling appropriate to platform
Widget adaptiveNavBarActionButton({
  required Widget icon,
  required Function()? onPressed,
}) {
  if (Platform.isIOS) {
    return CupertinoButton(
      padding: noPadding,
      onPressed: onPressed,
      child: icon,
    );
  } else {
    return IconButton(
      icon: icon,
      onPressed: onPressed,
    );
  }
}

// Dialog action button appropriate to platform
Widget adaptiveDialogAction({
  bool isDefaultAction = false,
  bool isDestructiveAction = false,
  required String text,
  required Function()? onPressed,
}) {
  if (Platform.isIOS) {
    return CupertinoDialogAction(
      isDefaultAction: isDefaultAction,
      isDestructiveAction: isDestructiveAction,
      onPressed: onPressed,
      child: Text(text),
    );
  } else {
    return isDestructiveAction
        ? TextButton(
            onPressed: onPressed,
            child: Text(text),
          )
        : FilledButton.tonal(
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
  if (Platform.isIOS) {
    return CupertinoButton(
      padding: noPadding,
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
  Color? iconColor,
  required Function()? onPressed,
}) {
  if (Platform.isIOS) {
    return CupertinoButton(
      minSize: 72.0,
      padding: noPadding,
      onPressed: onPressed,
      child: Icon(icon, size: 36.0, color: iconColor),
    );
  } else {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.comfortable,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        minimumSize: const Size(60.0, 60.0),
        padding: smallDefaultPadding,
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 36.0, color: iconColor),
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
  if (Platform.isIOS) {
    return CupertinoFormSection.insetGrouped(
      margin: noPadding,
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
                enableSuggestions: true,
                enableInteractiveSelection: true,
                textCapitalization: TextCapitalization.words,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                padding: largeDefaultPadding,
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
                padding: noPadding,
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
      padding: largeDefaultPadding,
      child: TextFormField(
        controller: controller,
        autofocus: true,
        autocorrect: false,
        enableSuggestions: true,
        enableInteractiveSelection: true,
        textCapitalization: TextCapitalization.words,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          counter: const Offstage(),
          suffixIcon: controller.text.isNotEmpty
              // Clear field button
              ? IconButton(
                  padding: noPadding,
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
  if (Platform.isIOS) {
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
    required this.buttonTextDone,
    this.previousPageTitle,
    this.actionRoute,
    this.actionIcon,
    this.secondaryActionRoute,
    this.secondaryActionIcon,
  });

  final bool isPoppable;
  final String title;
  final String buttonTextDone;
  final String? previousPageTitle;
  final Widget? actionRoute;
  final Widget? actionIcon;
  final Widget? secondaryActionRoute;
  final Widget? secondaryActionIcon;

  @override
  Size get preferredSize => const Size.fromHeight(navBarHeight);

  @override
  Widget build(BuildContext context) {
    // Build action list
    List<Widget> actions = [];
    if (secondaryActionIcon != null && secondaryActionRoute != null) {
      actions.add(
        adaptiveNavBarActionButton(
          icon: secondaryActionIcon!,
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => secondaryActionRoute!)),
        ),
      );
    }
    if (actionIcon != null && actionRoute != null) {
      actions.add(
        adaptiveNavBarActionButton(
          icon: actionIcon!,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: !isPoppable,
              builder: (_) => actionRoute!,
            ),
          ),
        ),
      );
    }

    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        automaticallyImplyLeading: false,
        automaticallyImplyMiddle: false,
        padding: previousPageTitle != null
            ? const EdgeInsetsDirectional.only(start: 4.0, end: 12.0)
            : const EdgeInsetsDirectional.symmetric(horizontal: 12.0),
        border: isPoppable
            ? const Border(
                bottom: BorderSide(color: Color(0x4D000000), width: 0.0),
              ) // _kDefaultNavBarBorder
            : null,
        backgroundColor: isPoppable
            ? CupertinoDynamicColor.resolve(
                CupertinoTheme.of(context).barBackgroundColor,
                context,
              )
            : Theme.of(context).scaffoldBackgroundColor,
        // Back navigation
        leading: previousPageTitle != null
            ? CupertinoButton(
                padding: noPadding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.chevron_back,
                      size: 28.0,
                    ),
                    Text(previousPageTitle!),
                  ],
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : isPoppable
                ? CupertinoButton(
                    padding: noPadding,
                    child: Text(buttonTextDone),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
        // Page title
        middle: Padding(
          padding: titlePadding,
          child: Text(
            title,
            style: TextStyle(
              color: CupertinoDynamicColor.resolve(
                CupertinoTheme.of(context).textTheme.navTitleTextStyle.color!,
                context,
              ),
            ),
          ),
        ),
        // Action buttons
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        ),
      );
    } else {
      return AppBar(
        elevation: !isPoppable ? 4.0 : null,
        title: Text(
          title,
          style: textStyleNavBar,
        ),
        actions: actions,
      );
    }
  }
}

// Bottom nav bar that is Material on Android and Cupertino on iOS
class PlatformAdaptiveBottomNavBar extends StatelessWidget {
  const PlatformAdaptiveBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final Function(int)? onTap;
  final List<BottomNavigationBarItem> items;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTabBar(
        height: navBarHeight,
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
      );
    } else {
      return BottomNavigationBar(
        useLegacyColorScheme: false,
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
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
  if (Platform.isIOS) {
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
                padding: noPadding,
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
