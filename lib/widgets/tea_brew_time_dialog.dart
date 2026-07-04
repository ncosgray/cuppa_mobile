/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_brew_time_dialog.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa time entry dialog

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/common/separators.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';

import 'package:flutter/material.dart';

// Return type for brew time dialog: brew time plus infusion settings
typedef BrewTimeResult = ({
  int brewTime,
  int numInfusions,
  int infusionInterval,
  int currentInfusion,
});

// Display a tea brew time entry dialog box
class TeaBrewTimeDialog extends StatefulWidget {
  const TeaBrewTimeDialog({
    super.key,
    this.title,
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
    this.showInfusionSettings = true,
    this.initialNumInfusions = defaultNumInfusions,
    this.initialInfusionInterval = defaultInfusionInterval,
    this.initialCurrentInfusion = 1,
    this.allowInfusionReset = true,
  });

  final Widget? title;
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
  final bool showInfusionSettings;
  final int initialNumInfusions;
  final int initialInfusionInterval;
  final int initialCurrentInfusion;
  final bool allowInfusionReset;

  @override
  State<TeaBrewTimeDialog> createState() => _TeaBrewTimeDialogState();
}

class _TeaBrewTimeDialogState extends State<TeaBrewTimeDialog> {
  // State variables
  late int _currentBrewTime;
  late bool _multipleInfusions;
  late int _numInfusions;
  late int _currentInfusion;
  int _infusionInterval = 0;
  int _infusionIntervalSign = 1;
  int _intervalPickerKey = 0;

  // Initialize dialog state
  @override
  void initState() {
    super.initState();

    _currentBrewTime =
        widget.initialHours * 3600 +
        widget.initialMinutes * 60 +
        widget.initialSeconds;
    _multipleInfusions = widget.initialNumInfusions >= numInfusionsMin;
    _numInfusions = _multipleInfusions
        ? widget.initialNumInfusions
        : numInfusionsMin;
    _infusionInterval = widget.initialInfusionInterval.abs();
    _infusionIntervalSign = widget.initialInfusionInterval < 0 ? -1 : 1;
    _currentInfusion = widget.initialCurrentInfusion;
  }

  // Current infusion clamped to the selected infusion count
  int get _effectiveCurrentInfusion =>
      _multipleInfusions && _currentInfusion <= _numInfusions
      ? _currentInfusion
      : 1;

  // Build dialog
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: widget.title,
      content: SingleChildScrollView(
        child: Material(
          type: .transparency,
          child: Column(
            mainAxisAlignment: .center,
            mainAxisSize: .min,
            spacing: largeSpacing,
            children: [
              // Brew time picker
              AnimatedCrossFade(
                duration: longAnimationDuration,
                sizeCurve: Curves.easeInOut,
                crossFadeState: _multipleInfusions
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: _brewTimePicker(),
                secondChild: const SizedBox.shrink(),
              ),
              // Multiple infusions section
              if (widget.showInfusionSettings) ...[
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      AppString.tea_multiple_infusions.translate(),
                      style: textStyleSettingSecondary,
                    ),
                    adaptiveSwitch(
                      value: _multipleInfusions,
                      onChanged: (value) =>
                          setState(() => _multipleInfusions = value),
                    ),
                  ],
                ),
                // Infusions count and interval (if enabled)
                AnimatedCrossFade(
                  duration: longAnimationDuration,
                  sizeCurve: Curves.easeInOut,
                  crossFadeState: _multipleInfusions
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    spacing: largeSpacing,
                    children: [
                      listDivider,
                      // First infusion time picker
                      Text(
                        AppString.tea_infusion_first.translate(),
                        style: textStyleSettingSecondary,
                      ),
                      _brewTimePicker(dense: true),
                      listDivider,
                      // Number of infusions selector
                      Text(
                        AppString.tea_infusion_count.translate(),
                        style: textStyleSettingSecondary,
                      ),
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          adaptiveSmallButton(
                            icon: incrementDownIcon,
                            onPressed: _numInfusions > numInfusionsMin
                                ? () => setState(() => _numInfusions--)
                                : null,
                          ),
                          Text('$_numInfusions', style: textStyleSettingNumber),
                          adaptiveSmallButton(
                            icon: incrementUpIcon,
                            onPressed: _numInfusions < numInfusionsMax
                                ? () => setState(() => _numInfusions++)
                                : null,
                          ),
                        ],
                      ),
                      listDivider,
                      // Infusion interval label and sign toggle
                      Text(
                        AppString.tea_infusion_interval.translate(),
                        style: textStyleSettingSecondary,
                      ),
                      adaptiveSegmentedControl(
                        buttonTextTrue: '+',
                        buttonTextFalse: '−',
                        groupValue: _infusionIntervalSign > 0,
                        onValueChanged: (selected) {
                          if (selected != null) {
                            setState(
                              () => _infusionIntervalSign = selected ? 1 : -1,
                            );
                          }
                        },
                      ),
                      // Infusion interval time picker
                      BrewTimePicker(
                        key: ValueKey(_intervalPickerKey),
                        initialHours: 0,
                        hourOptions: const [0],
                        hourLabel: '',
                        initialMinutes: _infusionInterval ~/ 60,
                        minuteOptions: List.generate(
                          (_currentBrewTime - infusionIntervalMin).clamp(
                                    0,
                                    _currentBrewTime,
                                  ) ~/
                                  60 +
                              1,
                          (i) => i,
                        ),
                        minuteLabel: '',
                        initialSeconds: _infusionInterval % 60,
                        secondOptions: widget.secondOptions,
                        onChanged: (value) {
                          final effectiveMax =
                              (_currentBrewTime - infusionIntervalMin).clamp(
                                infusionIntervalMin,
                                _currentBrewTime,
                              );
                          final capped = value.clamp(
                            infusionIntervalMin,
                            effectiveMax,
                          );
                          setState(() {
                            if (value != capped) _intervalPickerKey++;
                            _infusionInterval = capped;
                          });
                        },
                        dense: true,
                      ),
                      listDivider,
                      // Display selected infusions
                      Text(
                        _infusionList(),
                        style: textStyleSettingNumber.copyWith(
                          fontWeight: .bold,
                        ),
                      ),
                      listDivider,
                      // Current infusion status and reset button
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Text(
                            AppString.tea_current_infusion.translate(),
                            style: textStyleSettingSecondary,
                          ),
                          Row(
                            children: [
                              Text(
                                '$_effectiveCurrentInfusion',
                                style: textStyleSettingNumber,
                              ),
                              adaptiveSmallButton(
                                icon: resetIcon,
                                onPressed:
                                    widget.allowInfusionReset &&
                                        _effectiveCurrentInfusion > 1
                                    ? () => setState(() => _currentInfusion = 1)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      ),
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
          onPressed: () => Navigator.pop<BrewTimeResult>(context, (
            brewTime: _currentBrewTime,
            numInfusions: _multipleInfusions ? _numInfusions : 1,
            infusionInterval: _infusionIntervalSign * _infusionInterval,
            currentInfusion: _effectiveCurrentInfusion,
          )),
        ),
      ],
    );
  }

  // Time picker for brew time or first infusion
  BrewTimePicker _brewTimePicker({bool dense = false}) => BrewTimePicker(
    key: ValueKey(_multipleInfusions),
    initialHours: _currentBrewTime ~/ 3600,
    hourOptions: widget.hourOptions,
    hourLabel: widget.hourLabel,
    initialMinutes: (_currentBrewTime % 3600) ~/ 60,
    minuteOptions: widget.minuteOptions,
    minuteLabel: widget.minuteLabel,
    initialSeconds: _currentBrewTime % 60,
    secondOptions: widget.secondOptions,
    onChanged: (value) {
      setState(() {
        _currentBrewTime = value;
        final maxInterval = (_currentBrewTime - infusionIntervalMin).clamp(
          infusionIntervalMin,
          _currentBrewTime,
        );
        if (_infusionInterval > maxInterval) {
          _infusionInterval = maxInterval;
          _intervalPickerKey++;
        }
      });
    },
    dense: dense,
  );

  // List of first few infusions generated from current settings selections
  String _infusionList() {
    final String infusion1 = formatTimer(_currentBrewTime);
    final String infusion2 = formatTimer(
      _currentBrewTime + (_infusionIntervalSign * _infusionInterval),
    );
    final String infusion3 = _numInfusions > 2
        ? ', ${formatTimer(_currentBrewTime + (2 * _infusionIntervalSign * _infusionInterval))}'
        : '';
    final String ellipsis = _numInfusions > 3 ? ', ...' : '';

    return '$infusion1, $infusion2$infusion3$ellipsis';
  }
}

// Reusable brew time scroll-wheel picker widget
class BrewTimePicker extends StatefulWidget {
  const BrewTimePicker({
    super.key,
    required this.initialHours,
    required this.hourOptions,
    required this.hourLabel,
    required this.initialMinutes,
    required this.minuteOptions,
    required this.minuteLabel,
    required this.initialSeconds,
    required this.secondOptions,
    required this.onChanged,
    required this.dense,
  });

  final int initialHours;
  final List<int> hourOptions;
  final String hourLabel;
  final int initialMinutes;
  final List<int> minuteOptions;
  final String minuteLabel;
  final int initialSeconds;
  final List<int> secondOptions;
  final ValueChanged<int> onChanged;
  final bool dense;

  @override
  State<BrewTimePicker> createState() => _BrewTimePickerState();
}

class _BrewTimePickerState extends State<BrewTimePicker> {
  // State variables
  int _hoursIndex = 0;
  int _minutesIndex = 0;
  int _secondsIndex = 0;
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _secondsController;
  late bool _hoursSelectionMode;

  // Whether hours are available in this picker
  bool get _allowHours => widget.hourOptions.length > 1;

  // Initialize picker state
  @override
  void initState() {
    super.initState();

    if (widget.hourOptions.contains(widget.initialHours)) {
      _hoursIndex = widget.hourOptions.indexOf(widget.initialHours);
    }
    _hoursController = FixedExtentScrollController(initialItem: _hoursIndex);
    if (widget.minuteOptions.contains(widget.initialMinutes)) {
      _minutesIndex = widget.minuteOptions.indexOf(widget.initialMinutes);
    }
    _minutesController = FixedExtentScrollController(
      initialItem: _minutesIndex,
    );
    if (widget.secondOptions.contains(widget.initialSeconds)) {
      _secondsIndex = widget.secondOptions.indexOf(widget.initialSeconds);
    }
    _secondsController = FixedExtentScrollController(
      initialItem: _secondsIndex,
    );
    _hoursSelectionMode = _allowHours && _hoursIndex > 0;
  }

  // Build picker
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.dense ? 80 : 120,
      child: Row(
        mainAxisAlignment: .spaceBetween,
        spacing: smallSpacing,
        children: [
          // Increment down
          adaptiveSmallButton(
            icon: incrementDownIcon,
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
                if (_allowHours) {
                  _hoursIndex--;
                  _minutesIndex = widget.minuteOptions.length - 1;
                } else {
                  _minutesIndex = 0;
                  _secondsIndex = 0;
                }
              }
              if (_allowHours && _hoursIndex <= 0) {
                _hoursIndex = 0;
                if (_hoursSelectionMode) {
                  // Change to minutes selection mode at 0 hours
                  _hoursSelectionMode = false;
                  _minutesIndex = widget.minuteOptions.length - 1;
                  _secondsIndex = widget.secondOptions.length - 1;
                }
              }
              _updatePicker(doScroll: true);
            },
          ),
          // Time pickers
          Row(
            children: [
              // Hours and minutes
              Visibility(
                visible: _hoursSelectionMode,
                maintainState: true,
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  spacing: largeSpacing,
                  children: [
                    _hoursPicker,
                    Text('', style: textStyleSettingTertiary),
                    _minutesPicker,
                  ],
                ),
              ),
              // Minutes and seconds
              Visibility(
                visible: !_hoursSelectionMode,
                maintainState: true,
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  textDirection: .ltr,
                  spacing: largeSpacing,
                  children: [
                    _minutesPicker,
                    Text(':', style: textStyleSettingTertiary),
                    _secondsPicker,
                  ],
                ),
              ),
            ],
          ),
          // Increment up
          adaptiveSmallButton(
            icon: incrementUpIcon,
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
                if (_allowHours) {
                  _minutesIndex = 0;
                  _hoursIndex++;
                  if (!_hoursSelectionMode) {
                    // Change to hours selection mode at max minutes
                    _hoursSelectionMode = true;
                  }
                } else {
                  // Clamp at maximum when hours not available
                  _minutesIndex = widget.minuteOptions.length - 1;
                  _secondsIndex = widget.secondOptions.length - 1;
                }
              }
              if (_allowHours && _hoursIndex >= widget.hourOptions.length) {
                _hoursIndex = widget.hourOptions.length - 1;
              }
              _updatePicker(doScroll: true);
            },
          ),
        ],
      ),
    );
  }

  // Hours picker
  Widget get _hoursPicker => Row(
    children: [
      _scrollWheel(
        controller: _hoursController,
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
            _updatePicker(doScroll: true);
          } else {
            _hoursIndex = newValue;
            _updatePicker();
          }
        },
      ),
      Text(widget.hourLabel, style: textStyleSettingTertiary),
    ],
  );

  // Minutes picker
  Widget get _minutesPicker => Row(
    children: [
      _scrollWheel(
        controller: _minutesController,
        timeValues: (_hoursSelectionMode || !_allowHours)
            ? widget.minuteOptions
            : widget.minuteOptions + [60],
        onChanged: (newValue) {
          if (newValue >= widget.minuteOptions.length) {
            // Change to hours selection mode at 60 minutes
            _hoursSelectionMode = true;
            _hoursIndex++;
            _minutesIndex = 0;
            _updatePicker(doScroll: true);
          } else {
            _minutesIndex = newValue;
            _updatePicker();
          }
        },
      ),
      Visibility(
        visible: _hoursSelectionMode,
        child: Text(widget.minuteLabel, style: textStyleSettingTertiary),
      ),
    ],
  );

  // Seconds picker
  Widget get _secondsPicker => _scrollWheel(
    controller: _secondsController,
    timeValues: widget.secondOptions,
    onChanged: (newValue) {
      _secondsIndex = newValue;
      _updatePicker();
    },
    padTime: true,
  );

  // Build a single scroll wheel column
  Widget _scrollWheel({
    required FixedExtentScrollController controller,
    required List<int> timeValues,
    required ValueChanged<int> onChanged,
    bool padTime = false,
  }) {
    double itemWidth = MediaQuery.of(context).textScaler.scale(28);

    return SizedBox(
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
        children: List<Widget>.generate(timeValues.length, (int index) {
          return Center(
            child: Text(
              padTime
                  ? timeValues[index].toString().padLeft(2, '0')
                  : timeValues[index].toString(),
              style: textStyleSettingNumber,
            ),
          );
        }),
      ),
    );
  }

  // Update picker position and notify parent
  void _updatePicker({bool doScroll = false}) {
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

    widget.onChanged(
      widget.hourOptions[_hoursIndex] * 3600 +
          widget.minuteOptions[_minutesIndex] * 60 +
          widget.secondOptions[_secondsIndex],
    );
  }
}
