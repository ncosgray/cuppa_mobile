/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_brew_ratio_dialog.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea ratio picker dialog

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/brew_ratio.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';

import 'package:flutter/material.dart';

// Display a tea brew ratio entry dialog box
class TeaBrewRatioDialog extends StatefulWidget {
  const TeaBrewRatioDialog({
    super.key,
    required this.initialRatio,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  });

  final BrewRatio initialRatio;
  final String buttonTextCancel;
  final String buttonTextOK;

  @override
  State<TeaBrewRatioDialog> createState() => _TeaBrewRatioDialogState();
}

class _TeaBrewRatioDialogState extends State<TeaBrewRatioDialog> {
  // State variables
  late BrewRatio _newRatio;
  int _newDenominatorIndex = 0;

  // Initialize dialog state
  @override
  void initState() {
    super.initState();

    // Set starting values
    _newRatio = BrewRatio(
      ratioNumerator: widget.initialRatio.ratioNumerator,
      ratioDenominator: widget.initialRatio.ratioDenominator,
      metricNumerator: widget.initialRatio.metricNumerator,
      metricDenominator: widget.initialRatio.metricDenominator,
    );
    if (brewRatioMlOptions.contains(_newRatio.ratioDenominator)) {
      _newDenominatorIndex = brewRatioMlOptions.indexOf(
        _newRatio.ratioDenominator,
      );
    }
    if (brewRatioOzOptions.contains(_newRatio.ratioDenominator)) {
      _newDenominatorIndex = brewRatioOzOptions.indexOf(
        _newRatio.ratioDenominator,
      );
    }
  }

  // Build dialog
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      // Ratio entry
      content: SingleChildScrollView(child: _ratioPicker()),
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
          onPressed: () => Navigator.pop(context, _newRatio),
        ),
      ],
    );
  }

  // Build a brewing ratio picker
  Widget _ratioPicker() {
    return Material(
      type: .transparency,
      child: Column(
        mainAxisAlignment: .center,
        mainAxisSize: .min,
        spacing: largeSpacing,
        children: [
          // Numerator unit selector
          adaptiveSegmentedControl(
            // Grams
            buttonTextTrue: AppString.unit_grams.translate(),
            // Teaspoons
            buttonTextFalse: AppString.unit_teaspoons.translate(),
            groupValue: _newRatio.metricNumerator,
            onValueChanged: (bool? selected) {
              if (selected != null) {
                setState(() => _newRatio.metricNumerator = selected);
              }
            },
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            spacing: largeSpacing,
            children: [
              // Increment numerator down
              adaptiveSmallButton(
                icon: incrementDownIcon,
                onPressed: _newRatio.ratioNumerator > brewRatioNumeratorMin
                    ? () => setState(
                        () =>
                            _newRatio.ratioNumerator -= brewRatioNumeratorStep,
                      )
                    : null,
              ),
              // Display selected numerator
              Text(_newRatio.numeratorString, style: textStyleSettingNumber),
              // Increment numerator up
              adaptiveSmallButton(
                icon: incrementUpIcon,
                onPressed: _newRatio.ratioNumerator < brewRatioNumeratorMax
                    ? () => setState(
                        () =>
                            _newRatio.ratioNumerator += brewRatioNumeratorStep,
                      )
                    : null,
              ),
            ],
          ),
          // Numerator slider
          Slider.adaptive(
            value: _newRatio.ratioNumerator,
            min: brewRatioNumeratorMin,
            max: brewRatioNumeratorMax,
            divisions:
                ((brewRatioNumeratorMax - brewRatioNumeratorMin) /
                        brewRatioNumeratorStep)
                    .round(),
            onChanged: (newValue) {
              setState(() => _newRatio.ratioNumerator = newValue);
            },
          ),
          // Denominator unit selector
          adaptiveSegmentedControl(
            // Milliliters
            buttonTextTrue: AppString.unit_milliliters.translate(),
            // Ounces
            buttonTextFalse: AppString.unit_ounces.translate(),
            groupValue: _newRatio.metricDenominator,
            onValueChanged: (bool? selected) {
              if (selected != null) {
                setState(() {
                  _newRatio.metricDenominator = selected;
                  if (_newRatio.metricDenominator) {
                    _newRatio.ratioDenominator =
                        brewRatioMlOptions[_newDenominatorIndex];
                  } else {
                    _newRatio.ratioDenominator =
                        brewRatioOzOptions[_newDenominatorIndex];
                  }
                });
              }
            },
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            spacing: largeSpacing,
            children: [
              // Increment denominator down
              adaptiveSmallButton(
                icon: incrementDownIcon,
                onPressed: _newDenominatorIndex > 0
                    ? () {
                        _newDenominatorIndex--;
                        _updateDenominatorSlider();
                      }
                    : null,
              ),
              // Display selected denominator
              Text(_newRatio.denominatorString, style: textStyleSettingNumber),
              // Increment denominator up
              adaptiveSmallButton(
                icon: incrementUpIcon,
                onPressed: _newDenominatorIndex < brewRatioMlOptions.length - 1
                    ? () {
                        _newDenominatorIndex++;
                        _updateDenominatorSlider();
                      }
                    : null,
              ),
            ],
          ),
          // Denominator slider
          Slider.adaptive(
            value: _newDenominatorIndex.toDouble(),
            min: 0,
            max: (brewRatioMlOptions.length - 1).toDouble(),
            divisions: brewRatioMlOptions.length - 1,
            onChanged: (newValue) {
              _newDenominatorIndex = newValue.toInt();
              _updateDenominatorSlider();
            },
          ),
          // Display full selected ratio
          AnimatedOpacity(
            opacity: _newRatio.ratioString.isEmpty ? fullOpacity : noOpacity,
            duration: shortAnimationDuration,
            child: Text(
              _newRatio.ratioString,
              style: textStyleSettingNumber.copyWith(fontWeight: .bold),
            ),
          ),
        ],
      ),
    );
  }

  // Update denominator slider position
  void _updateDenominatorSlider() {
    setState(() {
      _newRatio.ratioDenominator = _newRatio.metricDenominator
          ? brewRatioMlOptions[_newDenominatorIndex]
          : brewRatioOzOptions[_newDenominatorIndex];
    });
  }
}
