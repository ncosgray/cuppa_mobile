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
// - Icons for Android and iOS
// - Buttons and controls for Android and iOS
// - Text form field for Android and iOS
// - PlatformAdaptiveNavBar creates page navigation for context platform
// - openPlatformAdaptiveSelectList modal/dialog selector for context platform

import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

Icon getPlatformStatsIcon() {
  return appPlatform == TargetPlatform.iOS
      ? const Icon(CupertinoIcons.chart_pie)
      : const Icon(Icons.pie_chart_outline);
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

// Nav bar action button with styling appropriate to platform
Widget adaptiveNavBarActionButton({
  required Widget icon,
  required Function()? onPressed,
}) {
  if (appPlatform == TargetPlatform.iOS) {
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
  required Function()? onPressed,
}) {
  if (appPlatform == TargetPlatform.iOS) {
    return CupertinoButton(
      minSize: 72.0,
      padding: noPadding,
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
        padding: smallDefaultPadding,
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
                enableSuggestions: false,
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
    this.secondaryActionRoute,
    this.secondaryActionIcon,
  });

  final bool isPoppable;
  final String title;
  final Widget? actionRoute;
  final Widget? actionIcon;
  final Widget? secondaryActionRoute;
  final Widget? secondaryActionIcon;

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // Android default

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
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => actionRoute!)),
        ),
      );
    }

    if (appPlatform == TargetPlatform.iOS) {
      return CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        backgroundColor: CupertinoDynamicColor.resolve(
          CupertinoTheme.of(context).barBackgroundColor,
          context,
        ),
        leading: isPoppable
            ? CupertinoNavigationBarBackButton(
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        middle: Text(
          title,
          style: TextStyle(
            color: CupertinoDynamicColor.resolve(
              CupertinoTheme.of(context).textTheme.navTitleTextStyle.color!,
              context,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        ),
      );
    } else {
      return AppBar(
        elevation: 4,
        title: Text(
          title,
          style: textStyleNavBar,
        ),
        actions: actions,
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
