/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    platform_adaptive.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa platform adaptive elements
// - Icons for Android and iOS
// - Buttons and controls for Android and iOS
// - Text form field for Android and iOS
// - Create NavBar and BottomNavBar page navigation for context platform
// - openPlatformAdaptiveSelectList modal/dialog selector for context platform

import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';

import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Platform specific icons
Icon get platformSettingsIcon => Platform.isIOS
    ? const Icon(CupertinoIcons.settings_solid, size: 24)
    : const Icon(Icons.settings);

Icon get platformAboutIcon => Platform.isIOS
    ? const Icon(CupertinoIcons.question, size: 24)
    : const Icon(Icons.help);

Icon get platformStatsIcon => Platform.isIOS
    ? const Icon(CupertinoIcons.chart_pie, size: 24)
    : const Icon(Icons.pie_chart_outline);

Icon get platformSortIcon => Platform.isIOS
    ? const Icon(CupertinoIcons.sort_down)
    : const Icon(Icons.swap_vert);

Icon get platformExportIcon => Platform.isIOS
    ? const Icon(CupertinoIcons.floppy_disk)
    : const Icon(Icons.save);

Icon get platformImportIcon => Platform.isIOS
    ? const Icon(CupertinoIcons.arrow_up_doc)
    : const Icon(Icons.upload_file);

Icon get platformChevronIcon => Platform.isIOS
    ? Icon(CupertinoIcons.chevron_right)
    : Icon(Icons.chevron_right);

Icon getPlatformEditIcon({double? size}) {
  return Platform.isIOS
      ? Icon(CupertinoIcons.pencil_ellipsis_rectangle, size: size)
      : Icon(Icons.edit, size: size);
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

// Active color for checkboxes and other widgets
Color? getAdaptiveActiveColor(BuildContext context) {
  return Platform.isIOS
      ? CupertinoColors.systemBlue.resolveFrom(context)
      : null;
}

// Platform adaptive page scaffold
Widget adaptiveScaffold({
  required Widget body,
  PreferredSizeWidget? appBar,
  Widget? bottomNavigationBar,
  Color? backgroundColor,
}) {
  if (Platform.isIOS) {
    if (bottomNavigationBar != null &&
        bottomNavigationBar is PlatformAdaptiveBottomNavBar) {
      // For iOS with bottom navigation, use CupertinoTabScaffold
      return CupertinoTabScaffold(
        backgroundColor: backgroundColor,
        tabBar: (bottomNavigationBar).iosTabBar,
        tabBuilder: (BuildContext context, int index) {
          return CupertinoPageScaffold(
            navigationBar: appBar as PlatformAdaptiveNavBar,
            backgroundColor: backgroundColor,
            child: Material(type: .transparency, child: body),
          );
        },
      );
    } else {
      // Regular iOS page without bottom navigation
      return CupertinoPageScaffold(
        navigationBar: appBar != null ? appBar as PlatformAdaptiveNavBar : null,
        backgroundColor: backgroundColor,
        child: Material(type: .transparency, child: body),
      );
    }
  } else {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
    );
  }
}

// Nav bar action button with styling appropriate to platform
Widget adaptiveNavBarActionButton(
  BuildContext context, {
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
      color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
      onPressed: onPressed,
    );
  }
}

// Select list action appropriate to platform
Widget adaptiveSelectListAction({
  required Widget action,
  required Function() onTap,
}) {
  if (Platform.isIOS) {
    return CupertinoActionSheetAction(onPressed: onTap, child: action);
  } else {
    return GestureDetector(onTap: onTap, child: action);
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
        ? TextButton(onPressed: onPressed, child: Text(text))
        : FilledButton.tonal(onPressed: onPressed, child: Text(text));
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
      style: OutlinedButton.styleFrom(visualDensity: .compact),
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
      minimumSize: Size(72, 72),
      padding: noPadding,
      onPressed: onPressed,
      child: Icon(icon, size: 36, color: iconColor),
    );
  } else {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        visualDensity: .comfortable,
        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
        minimumSize: const Size(60, 60),
        padding: smallDefaultPadding,
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 36, color: iconColor),
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
              width: 186,
              child: CupertinoTextFormFieldRow(
                controller: controller,
                autofocus: true,
                autocorrect: false,
                enableSuggestions: true,
                enableInteractiveSelection: true,
                textCapitalization: .words,
                maxLines: 1,
                textAlignVertical: .center,
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
        textCapitalization: .words,
        maxLines: 1,
        textAlignVertical: .center,
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
        ButtonSegment<bool>(value: true, label: Text(buttonTextTrue)),
        ButtonSegment<bool>(value: false, label: Text(buttonTextFalse)),
      ],
    );
  }
}

// Sliver app bar page header with effects appropriate to platform
Widget adaptivePageHeader(
  BuildContext context, {
  bool pinned = false,
  Widget? leading,
  required String title,
  List<Widget>? actions,
}) {
  return SliverAppBar(
    elevation: Platform.isIOS ? 0 : (pinned ? 1 : 0),
    pinned: pinned,
    floating: !pinned,
    snap: !pinned,
    backgroundColor: Platform.isIOS
        ? Colors.transparent
        : Theme.of(context).scaffoldBackgroundColor,
    surfaceTintColor: Platform.isIOS
        ? null
        : Theme.of(context).scaffoldBackgroundColor,
    shadowColor: Platform.isIOS
        ? Colors.transparent
        : Theme.of(context).shadowColor,
    flexibleSpace: Platform.isIOS
        ? FlexibleSpaceBar(
            background: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          )
        : null,
    automaticallyImplyLeading: false,
    leading: leading,
    titleSpacing: 0,
    title: Container(
      margin: headerPadding,
      alignment: .centerLeft,
      child: FittedBox(
        child: Text(
          title,
          style: textStyleHeader.copyWith(
            color: Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
      ),
    ),
    actions: actions,
  );
}

// Navigation bar that is Material on Android and Cupertino on iOS
class PlatformAdaptiveNavBar extends StatelessWidget
    implements PreferredSizeWidget, ObstructingPreferredSizeWidget {
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
  bool shouldFullyObstruct(BuildContext context) => true;

  @override
  Size get preferredSize => .fromHeight(Platform.isIOS ? 44 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // Build action list
    List<Widget> actions = [];
    if (secondaryActionIcon != null && secondaryActionRoute != null) {
      actions.add(
        adaptiveNavBarActionButton(
          context,
          icon: secondaryActionIcon!,
          onPressed: adaptiveOnPressed(context, route: secondaryActionRoute!),
        ),
      );
    }
    if (actionIcon != null && actionRoute != null) {
      actions.add(
        adaptiveNavBarActionButton(
          context,
          icon: actionIcon!,
          onPressed: adaptiveOnPressed(context, route: actionRoute!),
        ),
      );
    }

    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        automaticallyImplyLeading: false,
        automaticallyImplyMiddle: false,
        automaticBackgroundVisibility: false,
        enableBackgroundFilterBlur: false,
        padding: previousPageTitle != null
            ? const EdgeInsetsDirectional.only(start: 4, end: 12)
            : const EdgeInsetsDirectional.symmetric(horizontal: 12),
        border: isPoppable
            ? const Border(
                bottom: BorderSide(color: Color(0x4D000000), width: 0.5),
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
                  mainAxisSize: .min,
                  children: [
                    const Icon(CupertinoIcons.chevron_back, size: 28),
                    Text(previousPageTitle!),
                  ],
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : isPoppable
            ? CupertinoButton(
                padding: noPadding,
                child: Text(
                  buttonTextDone,
                  style: TextStyle(fontWeight: .w600),
                ),
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
        trailing: Row(mainAxisSize: .min, children: actions),
      );
    } else {
      return AppBar(
        elevation: !isPoppable ? 4.0 : null,
        title: Text(title, style: textStyleNavBar),
        actions: actions,
      );
    }
  }
}

// Navigation action handler that adapts to platform
Function()? adaptiveOnPressed(BuildContext context, {required Widget route}) {
  return () {
    if (Platform.isIOS) {
      Navigator.of(
        context,
      ).push(CupertinoSheetRoute<void>(builder: (_) => route));
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => route));
    }
  };
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

  CupertinoTabBar get iosTabBar =>
      CupertinoTabBar(currentIndex: currentIndex, onTap: onTap, items: items);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return iosTabBar;
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
          type: .transparency,
          child: CupertinoActionSheet(
            title: Text(titleText),
            // Item options
            actions: itemList
                .asMap()
                .entries
                .map((item) => itemBuilder(context, item.key))
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
