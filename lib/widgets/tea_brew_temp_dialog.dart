/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_brew_temp_dialog.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea temperature picker dialog

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';

import 'package:flutter/material.dart';

// Display a tea brew temperature entry dialog box
class TeaBrewTempDialog extends StatefulWidget {
  const TeaBrewTempDialog({
    super.key,
    required this.initialTemp,
    required this.useCelsius,
    required this.tempFOptions,
    required this.tempCOptions,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  });

  final int initialTemp;
  final bool useCelsius;
  final List<int> tempFOptions;
  final List<int> tempCOptions;
  final String buttonTextCancel;
  final String buttonTextOK;

  @override
  State<TeaBrewTempDialog> createState() => _TeaBrewTempDialogState();
}

class _TeaBrewTempDialogState extends State<TeaBrewTempDialog> {
  // State variables
  late int _newTemp;
  late bool _unitsCelsius;
  int _newTempIndex = 0;

  // Initialize dialog state
  @override
  void initState() {
    super.initState();

    // Set starting values
    _newTemp = isRoomTemp(widget.initialTemp, useCelsius: widget.useCelsius)
        ? roomTemp
        : widget.initialTemp;
    _unitsCelsius = isCelsiusTemp(_newTemp, useCelsius: widget.useCelsius);
    if (widget.tempCOptions.contains(_newTemp)) {
      _newTempIndex = widget.tempCOptions.indexOf(_newTemp);
    }
    if (widget.tempFOptions.contains(_newTemp)) {
      _newTempIndex = widget.tempFOptions.indexOf(_newTemp);
    }
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
          text: widget.buttonTextCancel,
          onPressed: () => Navigator.pop(context, null),
        ),
        // Save and close dialog
        adaptiveDialogAction(
          text: widget.buttonTextOK,
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, _newTemp),
        ),
      ],
    );
  }

  // Build a temperature picker
  Widget _tempPicker() {
    int maxTempIndex = widget.tempCOptions.length - 1;

    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Unit selector
          AnimatedOpacity(
            opacity: isRoomTemp(_newTemp, useCelsius: _unitsCelsius)
                ? fullOpacity
                : noOpacity,
            duration: shortAnimationDuration,
            child: IgnorePointer(
              ignoring: _newTemp == roomTemp,
              child: adaptiveSegmentedControl(
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
                        _newTemp = widget.tempCOptions[_newTempIndex];
                      } else {
                        _newTemp = widget.tempFOptions[_newTempIndex];
                      }
                    });
                  }
                },
              ),
            ),
          ),
          spacerWidget,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Increment down
              adaptiveSmallButton(
                icon: incrementDownIcon,
                onPressed: _newTempIndex > 0
                    ? () {
                        // Approach room temp slowly
                        if (_newTempIndex == 1) {
                          _newTempIndex = 0;
                        } else if (_newTempIndex <= brewTempIncrement) {
                          _newTempIndex = 1;
                        } else {
                          _newTempIndex -= brewTempIncrement;
                        }
                        _updateTempSlider();
                      }
                    : null,
              ),
              // Display selected temperature
              Text(
                formatTemp(_newTemp, useCelsius: _unitsCelsius),
                style: textStyleSettingSeconday,
              ),
              // Increment up
              adaptiveSmallButton(
                icon: incrementUpIcon,
                onPressed: _newTempIndex < maxTempIndex
                    ? () {
                        _newTempIndex +=
                            (_newTempIndex == 0 ? 1 : brewTempIncrement);
                        if (_newTempIndex > maxTempIndex) {
                          _newTempIndex = maxTempIndex;
                        }
                        _updateTempSlider();
                      }
                    : null,
              ),
            ],
          ),
          spacerWidget,
          // Temperature picker
          Slider.adaptive(
            value: _newTempIndex.toDouble(),
            min: 0.0,
            max: maxTempIndex.toDouble(),
            divisions: maxTempIndex,
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
          ? widget.tempCOptions[_newTempIndex]
          : widget.tempFOptions[_newTempIndex];
    });
  }
}
