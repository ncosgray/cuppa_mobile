/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_brew_time_dialog.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa time entry dialog

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';

import 'package:flutter/material.dart';

// Display a tea brew time entry dialog box
class TeaBrewTimeDialog extends StatefulWidget {
  const TeaBrewTimeDialog({
    super.key,
    required this.initialHours,
    required this.hourOptions,
    required this.hourLabel,
    required this.initialMinutes,
    required this.minuteOptions,
    required this.minuteLabel,
    required this.initialSeconds,
    required this.secondOptions,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  });

  final int initialHours;
  final List<int> hourOptions;
  final String hourLabel;
  final int initialMinutes;
  final List<int> minuteOptions;
  final String minuteLabel;
  final int initialSeconds;
  final List<int> secondOptions;
  final String buttonTextCancel;
  final String buttonTextOK;

  @override
  State<TeaBrewTimeDialog> createState() => _TeaBrewTimeDialogState();
}

class _TeaBrewTimeDialogState extends State<TeaBrewTimeDialog> {
  // State variables
  int _hoursIndex = 0;
  int _minutesIndex = 0;
  int _secondsIndex = 0;
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _secondsController;
  late bool _hoursSelectionMode;

  // Initialize dialog state
  @override
  void initState() {
    super.initState();

    // Set starting values
    if (widget.hourOptions.contains(widget.initialHours)) {
      _hoursIndex = widget.hourOptions.indexOf(widget.initialHours);
    }
    _hoursController = FixedExtentScrollController(initialItem: _hoursIndex);
    if (widget.minuteOptions.contains(widget.initialMinutes)) {
      _minutesIndex = widget.minuteOptions.indexOf(widget.initialMinutes);
    }
    _minutesController =
        FixedExtentScrollController(initialItem: _minutesIndex);
    if (widget.secondOptions.contains(widget.initialSeconds)) {
      _secondsIndex = widget.secondOptions.indexOf(widget.initialSeconds);
    }
    _secondsController =
        FixedExtentScrollController(initialItem: _secondsIndex);
    _hoursSelectionMode = _hoursIndex > 0;
  }

  // Build dialog
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      // Time entry
      content: _timePicker(),
      actions: <Widget>[
        // Cancel and close dialog
        adaptiveDialogAction(
          text: widget.buttonTextCancel,
          onPressed: () => Navigator.pop(context, null),
        ),
        // Save and close dialog
        adaptiveDialogAction(
          isDefaultAction: true,
          text: widget.buttonTextOK,
          onPressed: () => Navigator.pop(
            context,
            widget.hourOptions[_hoursIndex] * 3600 +
                widget.minuteOptions[_minutesIndex] * 60 +
                widget.secondOptions[_secondsIndex],
          ),
        ),
      ],
    );
  }

  // Build a time picker
  Widget _timePicker() {
    const Widget timePickerSpacer = SizedBox(width: 14.0);

    return SizedBox(
      height: 120.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Increment down
          adaptiveSmallButton(
            icon: Icons.keyboard_arrow_down,
            onPressed: () {
              if (_hoursSelectionMode) {
                _minutesIndex--;
              } else {
                _secondsIndex--;
              }
              if (_secondsIndex < 0) {
                _minutesIndex--;
                _secondsIndex = widget.secondOptions.length - 1;
              }
              if (_minutesIndex < 0) {
                _hoursIndex--;
                _minutesIndex = widget.minuteOptions.length - 1;
              }
              if (_hoursIndex <= 0) {
                _hoursIndex = 0;
                if (_hoursSelectionMode) {
                  // Change to minutes selection mode at 0 hours
                  _hoursSelectionMode = false;
                  _minutesIndex = widget.minuteOptions.length - 1;
                  _secondsIndex = widget.secondOptions.length - 1;
                }
              }
              _updateTimePicker(doScroll: true);
            },
          ),
          timePickerSpacer,
          // Hours picker
          Visibility(
            visible: _hoursSelectionMode,
            maintainState: true,
            child: _timePickerScrollWheel(
              controller: _hoursController,
              initialValue: widget.initialHours,
              timeValues: widget.hourOptions,
              onChanged: (newValue) {
                if (newValue <= 0) {
                  _hoursIndex = 0;
                  if (_hoursSelectionMode) {
                    // Change to minutes selection mode at 0 hours
                    _hoursSelectionMode = false;
                    _minutesIndex = widget.minuteOptions.length - 1;
                    _secondsIndex = widget.secondOptions.length - 1;
                  }
                  _updateTimePicker(doScroll: true);
                } else {
                  _hoursIndex = newValue;
                  _updateTimePicker();
                }
              },
            ),
          ),
          // Unit
          Visibility(
            visible: _hoursSelectionMode,
            child: Text(
              widget.hourLabel,
              style: textStyleSettingTertiary,
            ),
          ),
          Visibility(visible: _hoursSelectionMode, child: timePickerSpacer),
          // Minutes picker
          _timePickerScrollWheel(
            controller: _minutesController,
            initialValue: widget.initialMinutes,
            timeValues: _hoursSelectionMode
                ? widget.minuteOptions
                : widget.minuteOptions + [60],
            onChanged: (newValue) {
              if (newValue >= widget.minuteOptions.length) {
                // Change to hours selection mode at 60 minutes
                _hoursSelectionMode = true;
                _hoursIndex++;
                _minutesIndex = 0;
                _updateTimePicker(doScroll: true);
              } else {
                _minutesIndex = newValue;
                _updateTimePicker();
              }
            },
          ),
          Visibility(visible: !_hoursSelectionMode, child: timePickerSpacer),
          // Unit
          Text(
            _hoursSelectionMode ? widget.minuteLabel : ':',
            style: textStyleSettingTertiary,
          ),
          Visibility(visible: !_hoursSelectionMode, child: timePickerSpacer),
          // Seconds picker
          Visibility(
            visible: !_hoursSelectionMode,
            maintainState: true,
            child: _timePickerScrollWheel(
              controller: _secondsController,
              initialValue: widget.initialSeconds,
              timeValues: widget.secondOptions,
              onChanged: (newValue) {
                _secondsIndex = newValue;
                _updateTimePicker();
              },
              padTime: true,
            ),
          ),
          timePickerSpacer,
          // Increment up
          adaptiveSmallButton(
            icon: Icons.keyboard_arrow_up,
            onPressed: () {
              if (_hoursSelectionMode) {
                _minutesIndex++;
              } else {
                _secondsIndex++;
              }
              if (_secondsIndex >= widget.secondOptions.length) {
                _minutesIndex++;
                _secondsIndex = 0;
              }
              if (_minutesIndex >= widget.minuteOptions.length) {
                _minutesIndex = 0;
                _hoursIndex++;
                if (!_hoursSelectionMode) {
                  // Change to hours selection mode at 60 minutes
                  _hoursSelectionMode = true;
                }
              }
              if (_hoursIndex >= widget.hourOptions.length) {
                _hoursIndex = widget.hourOptions.length - 1;
              }
              _updateTimePicker(doScroll: true);
            },
          ),
        ],
      ),
    );
  }

  // Build a time picker scroll wheel
  Widget _timePickerScrollWheel({
    required FixedExtentScrollController controller,
    required int initialValue,
    required Null Function(dynamic value) onChanged,
    required List<int> timeValues,
    bool padTime = false,
  }) {
    double itemWidth = MediaQuery.of(context).textScaler.scale(28.0);

    return Row(
      children: [
        SizedBox(
          width: itemWidth,
          child: ListWheelScrollView(
            controller: controller,
            physics: const FixedExtentScrollPhysics(),
            itemExtent: itemWidth,
            squeeze: 1.1,
            diameterRatio: 1.1,
            perspective: 0.01,
            overAndUnderCenterOpacity: 0.2,
            onSelectedItemChanged: onChanged,
            // Time values menu
            children: List<Widget>.generate(
              timeValues.length,
              (int index) {
                return Center(
                  child: Text(
                    // Format time with or without zero padding
                    padTime
                        ? timeValues[index].toString().padLeft(2, '0')
                        : timeValues[index].toString(),
                    style: textStyleSettingSeconday,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Update time picker scroll wheel position
  void _updateTimePicker({bool doScroll = false}) {
    // Ensure we never have a 0:00:00 brew time
    if (widget.hourOptions[_hoursIndex] == 0 &&
        widget.minuteOptions[_minutesIndex] == 0 &&
        widget.secondOptions[_secondsIndex] == 0) {
      if (widget.hourOptions[_hoursIndex] > 0) {
        _minutesIndex++;
      } else {
        _secondsIndex++;
      }
      doScroll = true;
    }

    // Scroll wheels to new values
    setState(() {
      if (doScroll) {
        _hoursController.animateToItem(
          _hoursIndex,
          duration: shortAnimationDuration,
          curve: Curves.linear,
        );
        _minutesController.animateToItem(
          _minutesIndex,
          duration: shortAnimationDuration,
          curve: Curves.linear,
        );
        _secondsController.animateToItem(
          _secondsIndex,
          duration: shortAnimationDuration,
          curve: Curves.linear,
        );
      }
    });
  }
}
