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

import 'package:flutter/material.dart';

// Text entry dialog
class TeaNameDialog extends StatefulWidget {
  const TeaNameDialog({
    super.key,
    required this.initialValue,
    required this.validator,
    required this.buttonTextCancel,
    required this.buttonTextOK,
  });

  final String initialValue;
  final String? Function(String?) validator;
  final String buttonTextCancel;
  final String buttonTextOK;

  @override
  State<TeaNameDialog> createState() => _TeaNameDialogState();
}

class _TeaNameDialogState extends State<TeaNameDialog> {
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
    _newValue = widget.initialValue;
    _isValid = true;
    _controller = TextEditingController(text: _newValue);
  }

  // Build dialog
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog.adaptive(
          // Text entry
          content: Material(
            type: MaterialType.transparency,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: adaptiveTextFormField(
                textColor: Theme.of(context).textTheme.bodyLarge!.color!,
                cursorColor: _isValid ? null : Colors.red,
                controller: _controller,
                validator: widget.validator,
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
                onCleared: () => setState(() {
                  // Invalidate an empty value
                  _isValid = false;
                  _controller.clear();
                }),
              ),
            ),
          ),
          actions: <Widget>[
            // Cancel and close dialog
            adaptiveDialogAction(
              text: widget.buttonTextCancel,
              onPressed: () => Navigator.of(context).pop(),
            ),
            // Save and close dialog, if valid
            adaptiveDialogAction(
              isDefaultAction: true,
              onPressed:
                  _isValid ? () => Navigator.of(context).pop(_newValue) : null,
              text: widget.buttonTextOK,
            ),
          ],
        ),
      ),
    );
  }
}
