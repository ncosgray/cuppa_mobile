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

import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';

import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// Platform specific icons
Icon get platformSettingsIcon => Platform.isIOS
    ? const Icon(CupertinoIcons.settings_solid)
    : const Icon(Icons.settings);

Icon get platformAboutIcon => Platform.isIOS
    ? const Icon(CupertinoIcons.question)
    : const Icon(Icons.help);

Icon get platformStatsIcon => Platform.isIOS
    ? const Icon(CupertinoIcons.chart_pie)
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
  ObstructingPreferredSizeWidget? appBar,
  Widget? bottomNavigationBar,
  Color? backgroundColor,
  bool resizeToAvoidBottomInset = true,
}) {
  if (Platform.isIOS) {
    final bool showTopFade = appBar != null;

    if (bottomNavigationBar != null) {
      // With bottom nav bar: Material Scaffold so GlassBottomBar integrates
      // correctly. AnnotatedRegion provides status bar style since Material
      // Scaffold doesn't manage it automatically without a Material AppBar.
      return Builder(
        builder: (context) {
          final ThemeData theme = Theme.of(context);
          final bool isDark = theme.brightness == Brightness.dark;
          final Color bgColor =
              backgroundColor ?? theme.scaffoldBackgroundColor;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: Scaffold(
              appBar: appBar,
              backgroundColor: backgroundColor,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
              extendBodyBehindAppBar: true,
              extendBody: true,
              body: Material(
                type: .transparency,
                child: Stack(
                  children: [
                    body,
                    if (showTopFade)
                      _liquidGlassFadeOverlay(color: bgColor, top: true),
                    _liquidGlassFadeOverlay(color: bgColor, top: false),
                  ],
                ),
              ),
              bottomNavigationBar: bottomNavigationBar,
            ),
          );
        },
      );
    } else {
      // Without bottom nav: CupertinoPageScaffold for correct layout.
      // AnnotatedRegion provides a baseline status bar style for pages that
      // have no SliverAppBar (e.g. the timer page). Pages with adaptivePageHeader
      // also set systemOverlayStyle directly on their SliverAppBar so the
      // correct style is applied even as it scrolls through the status bar area.
      return Builder(
        builder: (context) {
          final ThemeData theme = Theme.of(context);
          final bool isDark = theme.brightness == Brightness.dark;
          final Color bgColor =
              backgroundColor ?? theme.scaffoldBackgroundColor;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: CupertinoPageScaffold(
              navigationBar: appBar,
              backgroundColor: bgColor,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
              child: Material(
                type: .transparency,
                child: Stack(
                  children: [
                    body,
                    if (showTopFade)
                      _liquidGlassFadeOverlay(color: bgColor, top: true),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  } else {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
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
    final Color primaryColor = CupertinoTheme.of(context).primaryColor;

    return GlassIconButton(
      icon: IconTheme(
        data: IconThemeData(color: primaryColor),
        child: icon,
      ),
      onPressed: onPressed,
      size: 44,
      useOwnLayer: true,
      quality: .standard,
      settings: _liquidGlassSettings,
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

// Switch with styling appropriate to platform
Widget adaptiveSwitch({
  required bool value,
  required Function(bool) onChanged,
}) {
  if (Platform.isIOS) {
    return Builder(
      builder: (context) => GlassSwitch(
        value: value,
        onChanged: onChanged,
        inactiveColor: CupertinoColors.systemFill.resolveFrom(context),
        quality: .minimal,
      ),
    );
  } else {
    return Switch.adaptive(value: value, onChanged: onChanged);
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
    return Builder(
      builder: (context) {
        final Color primaryColor = CupertinoTheme.of(context).primaryColor;
        return GlassSegmentedControl(
          segments: [buttonTextTrue, buttonTextFalse],
          selectedIndex: groupValue ? 0 : 1,
          onSegmentSelected: (i) => onValueChanged(i == 0),
          backgroundColor: CupertinoColors.systemFill
              .resolveFrom(context)
              .withValues(alpha: 0.05),
          indicatorColor: primaryColor.withValues(alpha: 0.1),
          selectedTextStyle: textStyleSettingTertiary.copyWith(
            color: primaryColor,
          ),
          unselectedTextStyle: textStyleSettingTertiary.copyWith(
            color: CupertinoColors.label.resolveFrom(context),
          ),
        );
      },
    );
  } else {
    return SegmentedButton<bool>(
      selected: <bool>{groupValue},
      onSelectionChanged: (selected) => onValueChanged(selected.first),
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
    elevation: pinned ? 1 : 0,
    pinned: Platform.isIOS ? false : pinned,
    floating: Platform.isIOS ? false : !pinned,
    snap: Platform.isIOS ? false : !pinned,
    backgroundColor: Platform.isIOS
        ? Colors.transparent
        : Theme.of(context).scaffoldBackgroundColor,
    surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
    shadowColor: Platform.isIOS ? Colors.transparent : shadowColor,
    // Override so SystemUiOverlayStyle is always correct regardless of where
    // the SliverAppBar sits relative to the status bar during scrolling
    systemOverlayStyle: Platform.isIOS
        ? (Theme.of(context).brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
        : null,
    // Frosted glass background on pinned iOS headers
    flexibleSpace: Platform.isIOS && pinned
        ? Builder(
            builder: (ctx) => ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Theme.of(
                    ctx,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.75),
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
  bool shouldFullyObstruct(BuildContext context) => !Platform.isIOS;

  @override
  Size get preferredSize =>
      .fromHeight(Platform.isIOS ? 44 + smallSpacing : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // Build action list
    final List<Widget> actions = [
      if (secondaryActionIcon != null && secondaryActionRoute != null)
        adaptiveNavBarActionButton(
          context,
          icon: secondaryActionIcon!,
          onPressed: adaptiveOnPressed(context, route: secondaryActionRoute!),
        ),
      if (actionIcon != null && actionRoute != null)
        adaptiveNavBarActionButton(
          context,
          icon: actionIcon!,
          onPressed: adaptiveOnPressed(context, route: actionRoute!),
        ),
    ];

    if (Platform.isIOS) {
      return GlassAppBar(
        padding: EdgeInsets.only(
          top: smallSpacing,
          left: largeSpacing,
          right: largeSpacing,
        ),
        // Back/done navigation button
        leading: isPoppable
            ? GlassIconButton(
                icon: Icon(
                  previousPageTitle != null
                      ? CupertinoIcons.chevron_back
                      : CupertinoIcons.xmark,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
                useOwnLayer: true,
                quality: .standard,
                settings: _liquidGlassSettings,
              )
            : null,
        actions: actions.isNotEmpty ? actions : null,
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

// Slide-up tween for the transitionUp route animation
final _slideUpTween = Tween<Offset>(
  begin: const Offset(0, 1),
  end: Offset.zero,
).chain(CurveTween(curve: Curves.easeInOutCubic));

// Navigation action handler that adapts to platform
Function()? adaptiveOnPressed(
  BuildContext context, {
  required Widget route,
  bool transitionUp = false,
}) {
  return () {
    if (Platform.isIOS) {
      Navigator.of(context).push(
        transitionUp
            ? PageRouteBuilder<void>(
                pageBuilder: (_, _, _) => route,
                transitionDuration: transitionAnimationDuration,
                reverseTransitionDuration: transitionAnimationDuration,
                transitionsBuilder: (_, animation, _, child) {
                  return SlideTransition(
                    position: animation.drive(_slideUpTween),
                    child: child,
                  );
                },
              )
            : CupertinoPageRoute<void>(builder: (_) => route),
      );
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => route));
    }
  };
}

// Bottom nav bar that is Material on Android and Liquid Glass on iOS
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
      final Color labelColor = CupertinoColors.label.resolveFrom(context);
      final Color primaryColor = CupertinoTheme.of(context).primaryColor;
      const double tabWidth = 120;
      const double hPadding = 20;
      const double barBorderRadius = 32;
      final double barWidth = items.length * tabWidth + 2 * hPadding;

      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            SizedBox(
              width: barWidth,
              child: GlassBottomBar(
                selectedIndex: currentIndex,
                onTabSelected: onTap ?? (_) {},
                tabs: items
                    .map(
                      (item) => GlassBottomBarTab(
                        icon: _glassBottomBarTabIcon(
                          icon: item.icon,
                          label: item.label,
                          color: labelColor,
                        ),
                        activeIcon: _glassBottomBarTabIcon(
                          icon: item.icon,
                          label: item.label,
                          color: primaryColor,
                        ),
                      ),
                    )
                    .toList(),
                barHeight: 58,
                verticalPadding: 0,
                iconSize: 22,
                horizontalPadding: 0,
                barBorderRadius: barBorderRadius,
                selectedIconColor: primaryColor,
                unselectedIconColor: labelColor,
                indicatorColor: primaryColor.withValues(alpha: 0.1),
                glowDuration: shortAnimationDuration,
                settings: _liquidGlassSettings,
              ),
            ),
          ],
        ),
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

// Liquid Glass customizations
final _liquidGlassSettings = LiquidGlassSettings(
  shadow: [BoxShadow(color: shadowColor, blurRadius: 12)],
);

// Gradient overlay that fades from the scaffold background color to transparent
Widget _liquidGlassFadeOverlay({required Color color, required bool top}) =>
    Positioned(
      left: 0,
      right: 0,
      top: top ? 0 : null,
      bottom: top ? null : 0,
      child: IgnorePointer(
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: top ? .topCenter : .bottomCenter,
              end: top ? .bottomCenter : .topCenter,
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );

// Icon with optional text label for Liquid Glass tab bar
Widget _glassBottomBarTabIcon({
  required Widget icon,
  required String? label,
  required Color color,
}) => Column(
  mainAxisAlignment: .spaceAround,
  mainAxisSize: .min,
  children: [
    icon,
    Text(label ?? '', style: TextStyle(color: color, fontSize: 11)),
  ],
);

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
