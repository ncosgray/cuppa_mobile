/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_color_dialog.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea color selection dialog

import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/widgets/common.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';

import 'dart:math';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

// Text entry dialog
class TeaColorDialog extends StatefulWidget {
  const TeaColorDialog({
    Key? key,
    required this.initialTeaColor,
    required this.initialColorShade,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  }) : super(key: key);

  final TeaColor initialTeaColor;
  final Color? initialColorShade;
  final String buttonTextCancel;
  final String buttonTextOK;

  @override
  _TeaColorDialogState createState() => _TeaColorDialogState(
        initialTeaColor: initialTeaColor,
        initialColorShade: initialColorShade,
        buttonTextCancel: buttonTextCancel,
        buttonTextOK: buttonTextOK,
      );
}

class _TeaColorDialogState extends State<TeaColorDialog> {
  _TeaColorDialogState({
    required this.initialTeaColor,
    required this.initialColorShade,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  });

  final TeaColor initialTeaColor;
  final Color? initialColorShade;
  final String buttonTextCancel;
  final String buttonTextOK;

  // State variables
  late TeaColor _newTeaColor;
  late Color? _newColorShade;

  // Initialize dialog state
  @override
  void initState() {
    super.initState();

    _newTeaColor = initialTeaColor;
    _newColorShade = initialColorShade;
  }

  // Build dialog
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Container(),
      content: SizedBox(
        width: TeaColor.values.length * 26,
        height: min(
          getDeviceSize(context).height * 0.5,
          TeaColor.values.length * 26,
        ),
        child: SingleChildScrollView(
          child: ColorPicker(
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
              for (TeaColor color in TeaColor.values)
                ColorTools.createPrimarySwatch(
                  color.getColor(),
                ): color.name,
            },
            enableShadesSelection: true,
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
        ),
      ),
      actions: [
        adaptiveDialogAction(
          text: buttonTextCancel,
          onPressed: () => Navigator.of(context).pop(null),
        ),
        adaptiveDialogAction(
          isDefaultAction: true,
          text: buttonTextOK,
          onPressed: () => Navigator.of(context).pop(
            (teaColor: _newTeaColor, colorShade: _newColorShade),
          ),
        ),
      ],
    );
  }
}
