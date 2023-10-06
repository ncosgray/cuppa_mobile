/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_brew_temp_dialog.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea temperature picker dialog

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'package:flutter/material.dart';

// Display a tea brew temperature entry dialog box
class TeaBrewTempDialog extends StatefulWidget {
  const TeaBrewTempDialog({
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
  State<TeaBrewTempDialog> createState() => _TeaBrewTempDialogState(
        initialTemp: initialTemp,
        tempFOptions: tempFOptions,
        tempCOptions: tempCOptions,
        buttonTextCancel: buttonTextCancel,
        buttonTextOK: buttonTextOK,
      );
}

class _TeaBrewTempDialogState extends State<TeaBrewTempDialog> {
  _TeaBrewTempDialogState({
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
      content: SingleChildScrollView(
        child: _tempPicker(),
      ),
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

    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Unit selector
          adaptiveSegmentedControl(
            // Degrees C
            buttonTextTrue: degreesC,
            // Degrees F
            buttonTextFalse: degreesF,
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
          ),
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
    );
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
