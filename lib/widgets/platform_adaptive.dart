/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    platform_adaptive.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

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
// - PlatformAdaptiveSelectListItem selector item for context platform
// - openPlatformAdaptiveSelectList modal/dialog selector for context platform

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// iOS themes
final ThemeData kIOSTheme = ThemeData(
  primaryColor: Colors.grey.shade100,
  textTheme: Typography.blackCupertino,
  iconTheme: const IconThemeData(
    color: Colors.grey,
  ),
  brightness: Brightness.light,
);
final ThemeData kIOSDarkTheme = ThemeData(
  primaryColor: Colors.grey.shade900,
  textTheme: Typography.whiteCupertino,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  brightness: Brightness.dark,
);
final ThemeData kIOSBlackTheme = ThemeData(
  primaryColor: Colors.grey.shade900,
  scaffoldBackgroundColor: Colors.black,
  cardColor: Colors.grey.shade900,
  textTheme: Typography.whiteCupertino,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  brightness: Brightness.dark,
);

// Android themes
final ThemeData kDefaultTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.blue,
  textTheme: Typography.blackMountainView,
  iconTheme: const IconThemeData(
    color: Colors.grey,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.grey,
  ),
  brightness: Brightness.light,
);
final ThemeData kDarkTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.blue,
  scaffoldBackgroundColor: const Color(0xff323232),
  cardTheme: CardTheme(
    color: Colors.grey.shade800,
  ),
  textTheme: Typography.whiteMountainView,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.white,
  ),
  brightness: Brightness.dark,
);
final ThemeData kBlackTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.blue,
  scaffoldBackgroundColor: Colors.black,
  textTheme: Typography.whiteMountainView,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.white,
  ),
  brightness: Brightness.dark,
);

// Get theme appropriate to platform
ThemeData getPlatformAdaptiveTheme(TargetPlatform platform,
    {ColorScheme? dynamicColors}) {
  ThemeData theme = platform == TargetPlatform.iOS ? kIOSTheme : kDefaultTheme;
  if (dynamicColors != null) {
    // Use dynamic colors if provided
    theme = theme.copyWith(colorScheme: dynamicColors.harmonized());
  }
  return theme;
}

ThemeData getPlatformAdaptiveDarkTheme(TargetPlatform platform,
    {ColorScheme? dynamicColors, bool blackTheme = true}) {
  ThemeData theme = platform == TargetPlatform.iOS
      ? (blackTheme ? kIOSBlackTheme : kIOSDarkTheme)
      : (blackTheme ? kBlackTheme : kDarkTheme);
  if (dynamicColors != null) {
    // Use dynamic colors if provided
    theme = theme.copyWith(colorScheme: dynamicColors.harmonized());
  }
  return theme;
}

// Platform specific icons
Icon getPlatformSettingsIcon(TargetPlatform platform) {
  return platform == TargetPlatform.iOS
      ? const Icon(CupertinoIcons.settings_solid)
      : const Icon(Icons.settings);
}

Icon getPlatformAboutIcon(TargetPlatform platform) {
  return platform == TargetPlatform.iOS
      ? const Icon(CupertinoIcons.question)
      : const Icon(Icons.help);
}

Icon getPlatformRadioOnIcon(TargetPlatform platform) {
  return platform == TargetPlatform.iOS
      ? const Icon(CupertinoIcons.check_mark)
      : const Icon(Icons.radio_button_on);
}

Icon getPlatformRadioOffIcon(TargetPlatform platform) {
  return platform == TargetPlatform.iOS
      ? const Icon(null)
      : const Icon(Icons.radio_button_off);
}

Icon getPlatformRemoveIcon(TargetPlatform platform, Color color) {
  return platform == TargetPlatform.iOS
      ? Icon(CupertinoIcons.trash_fill, color: color)
      : Icon(Icons.delete_outline, color: color);
}

Icon getPlatformRemoveAllIcon(TargetPlatform platform, Color color) {
  return platform == TargetPlatform.iOS
      ? Icon(CupertinoIcons.square_stack_3d_up_slash_fill, color: color)
      : Icon(Icons.delete_sweep_outlined, color: color);
}

// Page scaffold with nav bar that is Material on Android and Cupertino on iOS
class PlatformAdaptiveScaffold extends StatelessWidget {
  const PlatformAdaptiveScaffold({
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
  final Widget? actionRoute;
  final Widget? actionIcon;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    if (platform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            transitionBetweenRoutes: false,
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
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => actionRoute!));
                    },
                    child: actionIcon!)
                : null,
          ),
          child: Material(type: MaterialType.transparency, child: body));
    } else {
      return Scaffold(
          appBar: AppBar(
              elevation: 4,
              title: Text(title),
              actions: actionIcon != null && actionRoute != null
                  ? <Widget>[
                      IconButton(
                        icon: actionIcon!,
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => actionRoute!));
                        },
                      ),
                    ]
                  : null),
          body: body);
    }
  }
}

// Material alert dialog with padding
AlertDialog materialAlertDialog({title, content, actions}) {
  return AlertDialog(
    contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0),
    actionsPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 18.0),
    title: title,
    content: content,
    actions: actions,
  );
}

// Alert dialog that is Material on Android and Cupertino on iOS
class PlatformAdaptiveDialog extends StatelessWidget {
  const PlatformAdaptiveDialog({
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
        FilledButton.tonal(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(buttonTextFalse),
        )
      ];
      if (buttonTextTrue != null) {
        actionList.add(FilledButton.tonal(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(buttonTextTrue!),
        ));
      }

      // Build the Material dialog
      return materialAlertDialog(
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
        content: Material(
            type: MaterialType.transparency,
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
            isDefaultAction: true,
            textStyle: _isValid ? null : const TextStyle(color: Colors.grey),
            onPressed: _isValid
                ? () {
                    // Return new text value
                    Navigator.of(context).pop(_newValue);
                  }
                : null,
            child: Text(buttonTextOK),
          ),
        ],
      );
    } else {
      return materialAlertDialog(
        // Text entry
        content: SingleChildScrollView(
            child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: _textField())),
        actions: <Widget>[
          // Cancel and close dialog
          FilledButton.tonal(
            onPressed: () {
              // Don't return anything
              Navigator.of(context).pop();
            },
            child: Text(buttonTextCancel),
          ),
          // Save and close dialog, if valid
          FilledButton.tonal(
            onPressed: _isValid
                ? () {
                    // Return new text value
                    Navigator.of(context).pop(_newValue);
                  }
                : null,
            child: Text(buttonTextOK),
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
        counter: const Offstage(),
        suffixIcon: _controller.text.isNotEmpty
            // Clear field button
            ? IconButton(
                iconSize: 14.0,
                icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _isValid = false;
                    _controller.clear();
                  });
                },
              )
            : null,
      ),
      style: textStyleSetting,
      // Checks for valid values
      validator: validator,
      onChanged: (String newValue) {
        // Validate text and set new value
        setState(() {
          _isValid = false;
          if (_formKey.currentState != null) {
            if (_formKey.currentState!.validate()) {
              _isValid = true;
              _newValue = newValue;
            }
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
  int _minutesIndex = 0;
  int _secondsIndex = 0;
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _secondsController;

  // Initialize dialog state
  @override
  void initState() {
    super.initState();

    // Set starting values
    if (minuteOptions.contains(initialMinutes)) {
      _minutesIndex = minuteOptions.indexOf(initialMinutes);
    }
    _minutesController =
        FixedExtentScrollController(initialItem: _minutesIndex);
    if (secondOptions.contains(initialSeconds)) {
      _secondsIndex = secondOptions.indexOf(initialSeconds);
    }
    _secondsController =
        FixedExtentScrollController(initialItem: _secondsIndex);
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
              isDefaultAction: true,
              onPressed: () {
                // Return selected time
                Navigator.pop(
                    context,
                    minuteOptions[_minutesIndex] * 60 +
                        secondOptions[_secondsIndex]);
              },
              child: Text(buttonTextOK)),
        ],
      );
    } else {
      return materialAlertDialog(
        // Time entry
        content: _timePicker(),
        actions: <Widget>[
          // Cancel and close dialog
          FilledButton.tonal(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text(buttonTextCancel)),
          // Save and close dialog
          FilledButton.tonal(
              onPressed: () {
                // Return selected time
                Navigator.pop(
                    context,
                    minuteOptions[_minutesIndex] * 60 +
                        secondOptions[_secondsIndex]);
              },
              child: Text(buttonTextOK)),
        ],
      );
    }
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
          _adaptiveIncrementButton(
            icon: Icons.keyboard_arrow_down,
            onPressed: () {
              if (--_secondsIndex < 0) {
                _minutesIndex--;
                _secondsIndex = secondOptions.length - 1;
              }
              _updateTimePicker(doScroll: true);
            },
          ),
          timePickerSpacer,
          // Minutes picker
          _timePickerScrollWheel(
            controller: _minutesController,
            initialValue: initialMinutes,
            timeValues: minuteOptions,
            onChanged: (newValue) {
              _minutesIndex = newValue;
              _updateTimePicker();
            },
          ),
          timePickerSpacer,
          // Separator
          const Text(
            ':',
            style: textStyleSettingSeconday,
          ),
          timePickerSpacer,
          // Seconds picker
          _timePickerScrollWheel(
            controller: _secondsController,
            initialValue: initialSeconds,
            timeValues: secondOptions,
            onChanged: (newValue) {
              _secondsIndex = newValue;
              _updateTimePicker();
            },
            padTime: true,
          ),
          timePickerSpacer,
          // Increment up
          _adaptiveIncrementButton(
            icon: Icons.keyboard_arrow_up,
            onPressed: () {
              if (!(_minutesIndex == minuteOptions.length - 1 &&
                  _secondsIndex == secondOptions.length - 1)) {
                if (++_secondsIndex >= secondOptions.length) {
                  _minutesIndex++;
                  _secondsIndex = 0;
                }
                _updateTimePicker(doScroll: true);
              }
            },
          ),
        ],
      ),
    );
  }

  // Timer increment button with styling appropriate to platform
  Widget _adaptiveIncrementButton(
      {required IconData icon, required Function()? onPressed}) {
    if (platform == TargetPlatform.iOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Icon(icon),
      );
    } else {
      return OutlinedButton(
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        onPressed: onPressed,
        child: Icon(icon),
      );
    }
  }

  // Build a time picker scroll wheel
  Widget _timePickerScrollWheel(
      {required FixedExtentScrollController controller,
      required int initialValue,
      required Null Function(dynamic value) onChanged,
      required List<int> timeValues,
      bool padTime = false}) {
    return Row(children: [
      SizedBox(
        width: 36.0,
        child: ListWheelScrollView(
          controller: controller,
          physics: const FixedExtentScrollPhysics(),
          itemExtent: 28.0,
          squeeze: 1.1,
          diameterRatio: 1.1,
          useMagnifier: true,
          magnification: 1.1,
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
              ));
            },
          ),
        ),
      )
    ]);
  }

  // Update time picker scroll wheel position
  void _updateTimePicker({bool doScroll = false}) {
    // Ensure we never have a 0:00 brew time
    if (minuteOptions[_minutesIndex] == 0 &&
        secondOptions[_secondsIndex] == 0) {
      _secondsIndex++;
      doScroll = true;
    }

    // Scroll wheels to new values
    if (doScroll) {
      _minutesController.animateToItem(
        _minutesIndex,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
      _secondsController.animateToItem(
        _secondsIndex,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    }
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
              isDefaultAction: true,
              onPressed: () {
                // Return selected time
                Navigator.pop(context, _newTemp);
              },
              child: Text(buttonTextOK)),
        ],
      );
    } else {
      return materialAlertDialog(
        // Temperature entry
        content: _tempPicker(),
        actions: <Widget>[
          // Cancel and close dialog
          FilledButton.tonal(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text(buttonTextCancel)),
          // Save and close dialog
          FilledButton.tonal(
              onPressed: () {
                // Return selected time
                Navigator.pop(context, _newTemp);
              },
              child: Text(buttonTextOK)),
        ],
      );
    }
  }

  // Build a temperature picker
  Widget _tempPicker() {
    return SizedBox(
      height: 145.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Unit selector
          _adaptiveUnitPicker(),
          const SizedBox(height: 18.0),
          // Display selected temperature
          Text(
            formatTemp(_newTemp),
            style: textStyleSettingSeconday,
          ),
          Container(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0),
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

  // Build an adaptive temperature unit picker (sliding control or segments)
  Widget _adaptiveUnitPicker() {
    if (platform == TargetPlatform.iOS) {
      return CupertinoSlidingSegmentedControl<bool>(
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
          children: const <bool, Widget>{
            // Degrees C
            true: Text(degreesC),
            // Degrees F
            false: Text(degreesF),
          });
    } else {
      return SegmentedButton<bool>(
          selected: <bool>{_unitsCelsius},
          onSelectionChanged: (Set<bool> selected) {
            setState(() {
              _unitsCelsius = selected.first;
              if (_unitsCelsius) {
                _newTemp = tempCOptions[_newTempIndex];
              } else {
                _newTemp = tempFOptions[_newTempIndex];
              }
            });
          },
          segments: const <ButtonSegment<bool>>[
            // Degrees C
            ButtonSegment<bool>(
              value: true,
              label: Text(degreesC),
            ),
            // Degrees F
            ButtonSegment<bool>(
              value: false,
              label: Text(degreesF),
            ),
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

// Selector list item that adds inkwell effect on Android
class PlatformAdaptiveSelectListItem extends StatelessWidget {
  const PlatformAdaptiveSelectListItem({
    Key? key,
    required this.platform,
    required this.itemHeight,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  final TargetPlatform platform;
  final double itemHeight;
  final Widget item;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (platform == TargetPlatform.iOS) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: item,
      );
    } else {
      return InkWell(
        onTap: onTap,
        child: SizedBox(
          height: itemHeight,
          child: Container(
            padding: const EdgeInsets.only(right: 6.0),
            child: item,
          ),
        ),
      );
    }
  }
}

// Display a selector list that is Material on Android and Cupertino on iOS
Future<bool?> openPlatformAdaptiveSelectList(
    {required BuildContext context,
    required TargetPlatform platform,
    required String titleText,
    required String buttonTextCancel,
    required List<dynamic> itemList,
    required Widget Function(BuildContext, int) itemBuilder,
    required Widget Function(BuildContext, int) separatorBuilder}) async {
  if (platform == TargetPlatform.iOS) {
    // iOS style modal list
    return showCupertinoModalPopup<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
              title: Text(titleText),
              // Item options
              actions: itemList
                  .asMap()
                  .entries
                  .map((item) => CupertinoActionSheetAction(
                        child: itemBuilder(context, item.key),
                        onPressed: () {}, // Tap handled by itemBuilder
                      ))
                  .toList(),
              // Cancel button
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(buttonTextCancel),
              ));
        });
  } else {
    // Scrolling dialog list
    return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return materialAlertDialog(
              title: Text(titleText),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Scrollbar(
                    // Item options
                    child: ListView.separated(
                      padding: const EdgeInsets.all(0.0),
                      shrinkWrap: true,
                      itemCount: itemList.length,
                      itemBuilder: itemBuilder,
                      separatorBuilder: separatorBuilder,
                    ),
                  )),
              actions: [
                // Cancel button
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(buttonTextCancel),
                )
              ]);
        });
  }
}
