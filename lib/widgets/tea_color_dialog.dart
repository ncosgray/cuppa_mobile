/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_color_dialog.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea color selection dialog

import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/common/separators.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/mini_tea_button.dart';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

// Text entry dialog
class TeaColorDialog extends StatefulWidget {
  const TeaColorDialog({
    super.key,
    required this.initialTeaColor,
    required this.initialColorShade,
    required this.previewIcon,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  });

  final TeaColor initialTeaColor;
  final Color? initialColorShade;
  final IconData previewIcon;
  final String buttonTextCancel;
  final String buttonTextOK;

  @override
  State<TeaColorDialog> createState() => _TeaColorDialogState();
}

class _TeaColorDialogState extends State<TeaColorDialog> {
  // State variables
  late TeaColor _newTeaColor;
  late Color? _newColorShade;

  // Initialize dialog state
  @override
  void initState() {
    super.initState();

    // Set starting values
    _newTeaColor = widget.initialTeaColor;
    _newColorShade =
        widget.initialColorShade ?? widget.initialTeaColor.getColor();
  }

  // Build dialog
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Container(),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini tea button previews
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                miniTeaButton(
                  icon: widget.previewIcon,
                  color: _newColorShade,
                ),
                miniTeaButton(
                  icon: widget.previewIcon,
                  color: _newColorShade,
                  isActive: true,
                ),
                miniTeaButton(
                  icon: widget.previewIcon,
                  color: _newColorShade,
                  darkTheme: true,
                ),
              ],
            ),
            // Tea color picker
            ColorPicker(
              color: _newColorShade ?? _newTeaColor.getColor(),
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.both: false,
                ColorPickerType.primary: false,
                ColorPickerType.accent: false,
                ColorPickerType.bw: false,
                ColorPickerType.custom: true,
                ColorPickerType.wheel: false,
              },
              customColorSwatchesAndNames: <ColorSwatch<Object>, String>{
                for (final color in TeaColor.values)
                  ColorTools.createPrimarySwatch(
                    color.getColor(),
                  ): color.name,
              },
              enableShadesSelection: true,
              heading: listDivider,
              subheading: listDivider,
              onColorChanged: (Color newColor) {
                setState(() {
                  // Set primary TeaColor
                  _newTeaColor = TeaColor.values.firstWhere(
                    (color) => color.getColor() == newColor,
                    orElse: () => _newTeaColor,
                  );

                  // Set color shade
                  _newColorShade = newColor;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        adaptiveDialogAction(
          text: widget.buttonTextCancel,
          onPressed: () => Navigator.of(context).pop(null),
        ),
        adaptiveDialogAction(
          isDefaultAction: true,
          text: widget.buttonTextOK,
          onPressed: () => Navigator.of(context).pop(
            (teaColor: _newTeaColor, colorShade: _newColorShade),
          ),
        ),
      ],
    );
  }
}
