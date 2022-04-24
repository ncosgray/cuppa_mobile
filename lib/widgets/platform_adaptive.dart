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
// - PlatformAdaptiveAppBar from https://github.com/efortuna/memechat
// - PlatformAdaptiveDialog chooses showDialog type by context platform
// - PlatformAdaptiveTextFormDialog text entry dialog for context platform

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

// App bar that uses iOS styling on iOS
class PlatformAdaptiveAppBar extends AppBar {
  PlatformAdaptiveAppBar({
    Key? key,
    required TargetPlatform platform,
    List<Widget>? actions,
    required Widget title,
    Widget? body,
  }) : super(
          key: key,
          elevation: platform == TargetPlatform.iOS ? 0.0 : 4.0,
          title: title,
          actions: actions,
        );
}

// Alert dialog that is Material on Android and Cupertino on iOS
class PlatformAdaptiveDialog extends StatelessWidget {
  PlatformAdaptiveDialog({
    Key? key,
    required this.platform,
    required this.title,
    required this.content,
    required this.buttonTextTrue,
    required this.buttonTextFalse,
  }) : super(
          key: key,
        );

  final TargetPlatform platform;
  final Widget title;
  final Widget content;
  final String buttonTextTrue;
  final String buttonTextFalse;

  @override
  Widget build(BuildContext context) {
    if (platform == TargetPlatform.iOS) {
      return CupertinoAlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(buttonTextTrue),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: Text(buttonTextFalse),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    } else {
      return AlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          TextButton(
            child: Text(buttonTextTrue),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: Text(buttonTextFalse),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
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
        // Text entry
        content: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: _textField()),
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
      enableInteractiveSelection: false,
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
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
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
