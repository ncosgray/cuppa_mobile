/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    toast.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa toast message

import 'dart:io' show Platform;

import 'package:material_ui/material_ui.dart';

enum ToastPosition { top, bottom }

ToastPosition get defaultToastPosition => Platform.isIOS ? .top : .bottom;

class Toast extends StatelessWidget {
  const Toast({
    super.key,
    required this.message,
    this.actionIcon,
    this.actionLabel,
    required this.onActionPressed,
    this.backgroundColor,
    this.textColor,
    this.actionColor,
    this.position,
  });
  final String message;
  final IconData? actionIcon;
  final String? actionLabel;
  final VoidCallback onActionPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? actionColor;
  final ToastPosition? position;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snackBarTheme = theme.snackBarTheme;

    final effectiveBackgroundColor =
        backgroundColor ??
        snackBarTheme.backgroundColor ??
        theme.colorScheme.inverseSurface;

    final effectiveTextColor =
        textColor ??
        snackBarTheme.contentTextStyle?.color ??
        theme.colorScheme.onInverseSurface;

    final effectiveActionColor =
        actionColor ??
        snackBarTheme.actionTextColor ??
        theme.colorScheme.inversePrimary;

    return Material(
      color: effectiveBackgroundColor,
      borderRadius: .circular(4),
      elevation: snackBarTheme.elevation ?? 6,
      child: Container(
        padding: const .symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: effectiveTextColor, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            _buildAction(effectiveActionColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(Color actionColor) {
    if (actionLabel != null) {
      // Show label with optional icon
      return TextButton.icon(
        label: Text(actionLabel!, style: TextStyle(fontWeight: .bold)),
        icon: Icon(actionIcon, size: 18),
        style: TextButton.styleFrom(
          foregroundColor: actionColor,
          padding: const .symmetric(horizontal: 8),
          minimumSize: .zero,
          tapTargetSize: .shrinkWrap,
        ),
        onPressed: onActionPressed,
      );
    } else if (actionIcon != null) {
      // Show only icon
      return IconButton(
        icon: Icon(actionIcon),
        color: actionColor,
        iconSize: 20,
        padding: .zero,
        constraints: const BoxConstraints(),
        onPressed: onActionPressed,
      );
    }

    // Fallback to empty container if neither provided
    return const SizedBox.shrink();
  }

  // Helper method to show a toast for a limited duration
  static void show(
    BuildContext context, {
    required String message,
    IconData? actionIcon,
    String? actionLabel,
    required VoidCallback onActionPressed,
    Color? backgroundColor,
    Color? textColor,
    Color? actionColor,
    ToastPosition? position,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final effectivePosition = position ?? defaultToastPosition;
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: effectivePosition == ToastPosition.top ? 0 : null,
        bottom: effectivePosition == ToastPosition.bottom ? 20 : null,
        left: 8,
        right: 8,
        child: SafeArea(
          child: Toast(
            message: message,
            actionIcon: actionIcon,
            actionLabel: actionLabel,
            onActionPressed: () {
              onActionPressed();
              overlayEntry.remove();
            },
            backgroundColor: backgroundColor,
            textColor: textColor,
            actionColor: actionColor,
            position: effectivePosition,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
