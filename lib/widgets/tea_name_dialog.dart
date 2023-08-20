/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_name_dialog.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea name entry dialog

import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'package:flutter/material.dart';

// Text entry dialog
class TeaNameDialog extends StatefulWidget {
  const TeaNameDialog({
    Key? key,
    required this.initialValue,
    required this.validator,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  }) : super(key: key);

  final String initialValue;
  final String? Function(String?) validator;
  final String buttonTextCancel;
  final String buttonTextOK;

  @override
  _TeaNameDialogState createState() => _TeaNameDialogState(
        initialValue: initialValue,
        validator: validator,
        buttonTextCancel: buttonTextCancel,
        buttonTextOK: buttonTextOK,
      );
}

class _TeaNameDialogState extends State<TeaNameDialog> {
  _TeaNameDialogState({
    required this.initialValue,
    required this.validator,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  });

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
    return AlertDialog.adaptive(
      // Text entry
      content: SingleChildScrollView(
        child: Material(
          type: MaterialType.transparency,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: _textField(),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        // Cancel and close dialog
        adaptiveDialogAction(
          text: buttonTextCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Save and close dialog, if valid
        adaptiveDialogAction(
          isDefaultAction: true,
          onPressed:
              _isValid ? () => Navigator.of(context).pop(_newValue) : null,
          text: buttonTextOK,
        ),
      ],
    );
  }

  // Build a text field for TextFormDialog
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
                onPressed: () => setState(() {
                  _isValid = false;
                  _controller.clear();
                }),
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
