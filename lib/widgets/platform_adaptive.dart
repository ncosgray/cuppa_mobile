/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    platform_adaptive.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa platform adaptive elements
// - Light and dark themes for Android and iOS
// - Icons for Android and iOS
// - PlatformAdaptiveScaffold creates a page scaffold for context platform
// - PlatformAdaptiveScrollBehavior sets scroll behavior for context platform
// - PlatformAdaptiveDialog chooses showDialog type by context platform
// - PlatformAdaptiveTextFormDialog text entry dialog for context platform
// - PlatformAdaptiveTimePickerDialog time entry dialog for context platform
// - PlatformAdaptiveTempPickerDialog temp entry dialog for context platform

import 'package:cuppa_mobile/helpers.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// iOS themes
final ThemeData kIOSTheme = ThemeData(
  primaryColor: Colors.grey[100],
  textTheme: Typography.blackCupertino
      .copyWith(button: const TextStyle(color: Colors.black54)),
  brightness: Brightness.light,
);
final ThemeData kIOSDarkTheme = ThemeData(
  primaryColor: Colors.grey[900],
  textTheme: Typography.whiteCupertino
      .copyWith(button: const TextStyle(color: Colors.grey)),
  brightness: Brightness.dark,
);

// Android themes
final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.blue,
  textTheme: Typography.blackMountainView
      .copyWith(button: const TextStyle(color: Colors.black54)),
  brightness: Brightness.light,
);
final ThemeData kDarkTheme = ThemeData(
  primarySwatch: Colors.blue,
  textTheme: Typography.whiteMountainView
      .copyWith(button: const TextStyle(color: Colors.grey)),
  brightness: Brightness.dark,
);

// Get theme appropriate to platform
ThemeData getPlatformAdaptiveTheme(TargetPlatform platform) {
  return platform == TargetPlatform.iOS ? kIOSTheme : kDefaultTheme;
}

ThemeData getPlatformAdaptiveDarkTheme(TargetPlatform platform) {
  return platform == TargetPlatform.iOS ? kIOSDarkTheme : kDarkTheme;
}

// Platform specific icons
Icon getPlatformSettingsIcon(TargetPlatform platform) {
  return platform == TargetPlatform.iOS
      ? Icon(CupertinoIcons.settings_solid)
      : Icon(Icons.settings);
}

Icon getPlatformAboutIcon(TargetPlatform platform) {
  return platform == TargetPlatform.iOS
      ? Icon(CupertinoIcons.question)
      : Icon(Icons.help);
}

Icon getPlatformRadioOnIcon(TargetPlatform platform) {
  return platform == TargetPlatform.iOS
      ? Icon(CupertinoIcons.check_mark)
      : Icon(Icons.radio_button_on);
}

Icon getPlatformRadioOffIcon(TargetPlatform platform) {
  return platform == TargetPlatform.iOS
      ? Icon(null)
      : Icon(Icons.radio_button_off);
}

// Page scaffold with nav bar that is Material on Android and Cupertino on iOS
class PlatformAdaptiveScaffold extends StatelessWidget {
  PlatformAdaptiveScaffold({
    Key? key,
    required this.platform,
    required this.isPoppable,
    this.textScaleFactor = 1.0,
    required this.title,
    this.actionRoute,
    this.actionIcon,
    required this.body,
  }) : super(key: key);

  final TargetPlatform platform;
  final bool isPoppable;
  final double textScaleFactor;
  final String title;
  final String? actionRoute;
  final Icon? actionIcon;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    if (platform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: Theme.of(context).primaryColor,
            leading: isPoppable
                ? CupertinoNavigationBarBackButton(
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
            middle: Text(title,
                textScaleFactor: textScaleFactor,
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge!.color)),
            trailing: actionIcon != null && actionRoute != null
                ? CupertinoButton(
                    child: actionIcon!,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pushNamed(actionRoute!);
                    })
                : null,
          ),
          child: Card(elevation: 0.0, color: Colors.transparent, child: body));
    } else {
      return Scaffold(
          appBar: AppBar(
              title: Text(title),
              actions: actionIcon != null && actionRoute != null
                  ? <Widget>[
                      IconButton(
                        icon: actionIcon!,
                        onPressed: () {
                          Navigator.of(context).pushNamed(actionRoute!);
                        },
                      ),
                    ]
                  : null),
          body: body);
    }
  }
}

// Set scroll behavior appropriate to platform
class PlatformAdaptiveScrollBehavior extends ScrollBehavior {
  const PlatformAdaptiveScrollBehavior(
    this.platform,
  );

  final TargetPlatform platform;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return platform == TargetPlatform.iOS
        ? const BouncingScrollPhysics()
        : const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return platform == TargetPlatform.iOS
        ? child
        // Force stretch overscroll until Material 3 is fully implemented
        : StretchingOverscrollIndicator(
            axisDirection: details.direction,
            child: child,
          );
  }
}

// Alert dialog that is Material on Android and Cupertino on iOS
class PlatformAdaptiveDialog extends StatelessWidget {
  PlatformAdaptiveDialog({
    Key? key,
    required this.platform,
    required this.title,
    required this.content,
    required this.buttonTextFalse,
    this.buttonTextTrue,
  }) : super(key: key);

  final TargetPlatform platform;
  final Widget title;
  final Widget content;
  final String buttonTextFalse;
  final String? buttonTextTrue;

  @override
  Widget build(BuildContext context) {
    if (platform == TargetPlatform.iOS) {
      // Define Cupertino action button(s)
      List<Widget> actionList = [
        CupertinoDialogAction(
          child: Text(buttonTextFalse),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ];
      if (buttonTextTrue != null) {
        actionList.add(CupertinoDialogAction(
          child: Text(buttonTextTrue!),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ));
      }

      // Build the Cupertino dialog
      return CupertinoAlertDialog(
        title: title,
        content: content,
        actions: actionList,
      );
    } else {
      // Define Material action button(s)
      List<Widget> actionList = [
        TextButton(
          child: Text(buttonTextFalse),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        )
      ];
      if (buttonTextTrue != null) {
        actionList.add(TextButton(
          child: Text(buttonTextTrue!),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ));
      }

      // Build the Material dialog
      return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 0.0),
        title: title,
        content: content,
        actions: actionList,
      );
    }
  }
}

// Text entry dialog that is Material on Android and Cupertino on iOS
class PlatformAdaptiveTextFormDialog extends StatefulWidget {
  const PlatformAdaptiveTextFormDialog({
    Key? key,
    required this.platform,
    required this.initialValue,
    required this.validator,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  }) : super(key: key);

  final TargetPlatform platform;
  final String initialValue;
  final String? Function(String?) validator;
  final String buttonTextCancel;
  final String buttonTextOK;

  @override
  _PlatformAdaptiveTextFormDialogState createState() =>
      _PlatformAdaptiveTextFormDialogState(
          platform: platform,
          initialValue: initialValue,
          validator: validator,
          buttonTextCancel: buttonTextCancel,
          buttonTextOK: buttonTextOK);
}

class _PlatformAdaptiveTextFormDialogState
    extends State<PlatformAdaptiveTextFormDialog> {
  _PlatformAdaptiveTextFormDialogState({
    required this.platform,
    required this.initialValue,
    required this.validator,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  });

  final TargetPlatform platform;
  final String initialValue;
  final String? Function(String?) validator;
  final String buttonTextCancel;
  final String buttonTextOK;

  // State variables
  late GlobalKey<FormState> _formKey;
  late String _newValue;
  late bool _isValid;
  late TextEditingController _controller;

  // Initialize dialog state
  @override
  void initState() {
    super.initState();

    _formKey = GlobalKey();
    _newValue = initialValue;
    _isValid = true;
    _controller = TextEditingController(text: _newValue);
  }

  // Build dialog
  @override
  Widget build(BuildContext context) {
    if (platform == TargetPlatform.iOS) {
      return CupertinoAlertDialog(
        // Text entry
        content: Card(
            color: Colors.transparent,
            elevation: 0.0,
            child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Container(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                    child: _textField()))),
        actions: <Widget>[
          // Cancel and close dialog
          CupertinoDialogAction(
            child: Text(buttonTextCancel),
            onPressed: () {
              // Don't return anything
              Navigator.of(context).pop();
            },
          ),
          // Save and close dialog, if valid
          CupertinoDialogAction(
            child: Text(buttonTextOK),
            isDefaultAction: true,
            textStyle: _isValid ? null : TextStyle(color: Colors.grey),
            onPressed: _isValid
                ? () {
                    // Return new text value
                    Navigator.of(context).pop(_newValue);
                  }
                : null,
          ),
        ],
      );
    } else {
      return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 0.0),
        insetPadding: const EdgeInsets.all(4.0),
        // Text entry
        content: SingleChildScrollView(
            child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: _textField())),
        actions: <Widget>[
          // Cancel and close dialog
          TextButton(
            child: Text(buttonTextCancel),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () {
              // Don't return anything
              Navigator.of(context).pop();
            },
          ),
          // Save and close dialog, if valid
          TextButton(
            child: Text(buttonTextOK),
            style: ButtonStyle(
              foregroundColor: _isValid
                  ? MaterialStateProperty.all<Color>(Colors.blue)
                  : MaterialStateProperty.all<Color>(Colors.grey),
            ),
            onPressed: _isValid
                ? () {
                    // Return new text value
                    Navigator.of(context).pop(_newValue);
                  }
                : null,
          ),
        ],
      );
    }
  }

  // Build a text field for PlatformAdaptiveStringFormDialog
  Widget _textField() {
    // Text form field with clear button and validation
    return TextFormField(
      controller: _controller,
      autofocus: true,
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: true,
      textCapitalization: TextCapitalization.words,
      maxLines: 1,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        errorStyle: TextStyle(color: Colors.red),
        focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0)),
        counter: Offstage(),
        suffixIcon: _controller.text.length > 0
            // Clear field button
            ? IconButton(
                iconSize: 14.0,
                icon: Icon(Icons.cancel_outlined, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _isValid = false;
                    _controller.clear();
                  });
                },
              )
            : null,
      ),
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      // Checks for valid values
      validator: validator,
      onChanged: (String newValue) {
        // Validate text and set new value
        setState(() {
          _isValid = false;
          if (_formKey.currentState != null) if (_formKey.currentState!
              .validate()) {
            _isValid = true;
            _newValue = newValue;
          }
        });
      },
    );
  }
}

// Display a tea brew time entry dialog box
class PlatformAdaptiveTimePickerDialog extends StatefulWidget {
  const PlatformAdaptiveTimePickerDialog({
    Key? key,
    required this.platform,
    required this.initialMinutes,
    required this.minuteOptions,
    required this.initialSeconds,
    required this.secondOptions,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  }) : super(key: key);

  final TargetPlatform platform;
  final int initialMinutes;
  final List<int> minuteOptions;
  final int initialSeconds;
  final List<int> secondOptions;
  final String buttonTextCancel;
  final String buttonTextOK;

  @override
  State<PlatformAdaptiveTimePickerDialog> createState() =>
      _PlatformAdaptiveTimePickerDialogState(
          platform: platform,
          initialMinutes: initialMinutes,
          minuteOptions: minuteOptions,
          initialSeconds: initialSeconds,
          secondOptions: secondOptions,
          buttonTextCancel: buttonTextCancel,
          buttonTextOK: buttonTextOK);
}

class _PlatformAdaptiveTimePickerDialogState
    extends State<PlatformAdaptiveTimePickerDialog> {
  _PlatformAdaptiveTimePickerDialogState({
    required this.platform,
    required this.initialMinutes,
    required this.minuteOptions,
    required this.initialSeconds,
    required this.secondOptions,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  });

  final TargetPlatform platform;
  final int initialMinutes;
  final List<int> minuteOptions;
  final int initialSeconds;
  final List<int> secondOptions;
  final String buttonTextCancel;
  final String buttonTextOK;

  // State variables
  late int _newMinutes;
  late int _newSeconds;

  // Initialize dialog state
  @override
  void initState() {
    super.initState();

    _newMinutes = initialMinutes;
    _newSeconds = initialSeconds;
  }

  // Build dialog
  @override
  Widget build(BuildContext context) {
    if (platform == TargetPlatform.iOS) {
      return CupertinoAlertDialog(
        // Time entry
        content: _timePicker(),
        actions: <Widget>[
          // Cancel and close dialog
          CupertinoDialogAction(
            child: Text(buttonTextCancel),
            onPressed: () {
              // Cancel and close dialog
              Navigator.pop(context, null);
            },
          ),
          // Save and close dialog
          CupertinoDialogAction(
              child: Text(buttonTextOK),
              isDefaultAction: true,
              onPressed: () {
                // Return selected time
                Navigator.pop(context, (_newMinutes * 60 + _newSeconds));
              }),
        ],
      );
    } else {
      return AlertDialog(
        contentPadding: const EdgeInsets.only(top: 12.0),
        insetPadding: const EdgeInsets.all(4.0),
        // Time entry
        content: _timePicker(),
        actions: <Widget>[
          // Cancel and close dialog
          TextButton(
              child: Text(buttonTextCancel),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context, null);
              }),
          // Save and close dialog
          TextButton(
              child: Text(buttonTextOK),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                // Return selected time
                Navigator.pop(context, (_newMinutes * 60) + _newSeconds);
              }),
        ],
      );
    }
  }

  // Build a time picker
  Widget _timePicker() {
    return Container(
      height: 120.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Minutes picker
          _timePickerScrollWheel(
              initialValue: initialMinutes,
              timeValues: minuteOptions,
              onChanged: (newValue) {
                _newMinutes = minuteOptions[newValue];

                // Ensure we never have a 0:00 brew time
                if (_newMinutes == 0 && _newSeconds == 0) {
                  _newSeconds = 15;
                }
              }),
          SizedBox(width: 18.0),
          // Separator
          Text(
            ':',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          SizedBox(width: 18.0),
          // Seconds picker
          _timePickerScrollWheel(
              initialValue: initialSeconds,
              timeValues: secondOptions,
              onChanged: (newValue) {
                _newSeconds = secondOptions[newValue];

                // Ensure we never have a 0:00 brew time
                if (_newSeconds == 0 && _newMinutes == 0) {
                  _newSeconds = 15;
                }
              },
              padTime: true),
        ],
      ),
    );
  }

  // Build a time picker scroll wheel
  Widget _timePickerScrollWheel(
      {required int initialValue,
      required Null Function(dynamic value) onChanged,
      required List<int> timeValues,
      bool padTime = false}) {
    int initialItem = 0;
    if (timeValues.contains(initialValue)) {
      initialItem = timeValues.indexOf(initialValue);
    }

    return Container(
      width: 30.0,
      child: ListWheelScrollView(
        controller: FixedExtentScrollController(initialItem: initialItem),
        physics: FixedExtentScrollPhysics(),
        itemExtent: 22.0,
        squeeze: 1.1,
        diameterRatio: 1.1,
        useMagnifier: true,
        magnification: 1.1,
        perspective: 0.01,
        overAndUnderCenterOpacity: 0.2,
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
              style: TextStyle(
                fontSize: 18.0,
              ),
            ));
          },
        ),
        onSelectedItemChanged: onChanged,
      ),
    );
  }
}

// Display a tea brew temperature entry dialog box
class PlatformAdaptiveTempPickerDialog extends StatefulWidget {
  const PlatformAdaptiveTempPickerDialog({
    Key? key,
    required this.platform,
    required this.initialTemp,
    required this.tempFOptions,
    required this.tempCOptions,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  }) : super(key: key);

  final TargetPlatform platform;
  final int initialTemp;
  final List<int> tempFOptions;
  final List<int> tempCOptions;
  final String buttonTextCancel;
  final String buttonTextOK;

  @override
  State<PlatformAdaptiveTempPickerDialog> createState() =>
      _PlatformAdaptiveTempPickerDialogState(
          platform: platform,
          initialTemp: initialTemp,
          tempFOptions: tempFOptions,
          tempCOptions: tempCOptions,
          buttonTextCancel: buttonTextCancel,
          buttonTextOK: buttonTextOK);
}

class _PlatformAdaptiveTempPickerDialogState
    extends State<PlatformAdaptiveTempPickerDialog> {
  _PlatformAdaptiveTempPickerDialogState({
    required this.platform,
    required this.initialTemp,
    required this.tempFOptions,
    required this.tempCOptions,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  });

  final TargetPlatform platform;
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
    _unitsCelsius = initialTemp <= maxDegreesC ? true : false;
  }

  // Build dialog
  @override
  Widget build(BuildContext context) {
    if (platform == TargetPlatform.iOS) {
      return CupertinoAlertDialog(
        // Temperature entry
        content: _tempPicker(),
        actions: <Widget>[
          // Cancel and close dialog
          CupertinoDialogAction(
            child: Text(buttonTextCancel),
            onPressed: () {
              // Cancel and close dialog
              Navigator.pop(context, null);
            },
          ),
          // Save and close dialog
          CupertinoDialogAction(
              child: Text(buttonTextOK),
              isDefaultAction: true,
              onPressed: () {
                // Return selected time
                Navigator.pop(context, _newTemp);
              }),
        ],
      );
    } else {
      return AlertDialog(
        contentPadding: const EdgeInsets.only(top: 12.0),
        insetPadding: const EdgeInsets.all(4.0),
        // Temperature entry
        content: _tempPicker(),
        actions: <Widget>[
          // Cancel and close dialog
          TextButton(
              child: Text(buttonTextCancel),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context, null);
              }),
          // Save and close dialog
          TextButton(
              child: Text(buttonTextOK),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                // Return selected time
                Navigator.pop(context, _newTemp);
              }),
        ],
      );
    }
  }

  // Build a temperature picker
  Widget _tempPicker() {
    return Container(
      height: 130.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Unit selector
          _adaptiveUnitPicker(),
          SizedBox(height: 18.0),
          // Display selected temperature
          Text(
            formatTemp(_newTemp),
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          Container(
              padding: EdgeInsets.only(left: 18.0, right: 18.0),
              // Temperature picker
              child: _adaptiveTempSlider(
                  tempValueCount: tempCOptions.length - 1,
                  onChanged: (newValue) {
                    setState(() {
                      _newTempIndex = newValue.toInt();
                      _newTemp = _unitsCelsius
                          ? tempCOptions[_newTempIndex]
                          : tempFOptions[_newTempIndex];
                    });
                  })),
        ],
      ),
    );
  }

  // Build an adaptive temperature unit picker (sliding control or chips)
  Widget _adaptiveUnitPicker() {
    if (platform == TargetPlatform.iOS) {
      return CupertinoSlidingSegmentedControl<bool>(
          groupValue: _unitsCelsius,
          onValueChanged: (bool? selected) {
            if (selected != null)
              setState(() {
                _unitsCelsius = selected;
                if (_unitsCelsius) {
                  _newTemp = tempCOptions[_newTempIndex];
                } else {
                  _newTemp = tempFOptions[_newTempIndex];
                }
              });
          },
          children: <bool, Widget>{
            // Degrees C
            true: Text(
              degreesC,
            ),
            // Degrees F
            false: Text(
              degreesF,
            ),
          });
    } else {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Degrees C
        ChoiceChip(
            label: Text(degreesC),
            labelPadding: EdgeInsets.only(left: 18.0, right: 18.0),
            selected: _unitsCelsius,
            selectedColor: Colors.blue,
            elevation: 0,
            pressElevation: 0,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _unitsCelsius = true;
                  _newTemp = tempCOptions[_newTempIndex];
                }
              });
            }),
        SizedBox(width: 18.0),
        // Degrees F
        ChoiceChip(
            label: Text(degreesF),
            labelPadding: EdgeInsets.only(left: 18.0, right: 18.0),
            selected: !_unitsCelsius,
            selectedColor: Colors.blue,
            elevation: 0,
            pressElevation: 0,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _unitsCelsius = false;
                  _newTemp = tempFOptions[_newTempIndex];
                }
              });
            })
      ]);
    }
  }

  // Build an adaptive temperature slider
  Widget _adaptiveTempSlider(
      {required int tempValueCount,
      required Null Function(dynamic value) onChanged}) {
    if (platform == TargetPlatform.iOS) {
      return CupertinoSlider(
          value: _newTempIndex.toDouble(),
          min: 0.0,
          max: tempValueCount.toDouble(),
          divisions: tempValueCount,
          onChanged: onChanged);
    } else {
      return Slider(
          value: _newTempIndex.toDouble(),
          min: 0.0,
          max: tempValueCount.toDouble(),
          divisions: tempValueCount,
          onChanged: onChanged);
    }
  }
}
