/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    platform_adaptive.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2020 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa platform adaptive elements
// - Light and dark themes for Android and iOS
// - PlatformAdaptiveAppBar from https://github.com/efortuna/memechat
// - PlatformAdaptiveDialog chooses showDialog type by context platform

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// iOS themes
final ThemeData kIOSTheme = new ThemeData(
  primaryColor: Colors.grey[100],
  buttonColor: Colors.black54,
  brightness: Brightness.light,
);
final ThemeData kIOSDarkTheme = new ThemeData(
  primaryColor: Colors.grey[900],
  buttonColor: Colors.grey,
  brightness: Brightness.dark,
);

// Android themes
final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.blueAccent[400],
  buttonColor: Colors.black54,
  brightness: Brightness.light,
);
final ThemeData kDarkTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.blueAccent[400],
  buttonColor: Colors.grey,
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
    Key key,
    TargetPlatform platform,
    List<Widget> actions,
    Widget title,
    Widget body,
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
    Key key,
    this.title,
    this.content,
    this.buttonTextTrue,
    this.buttonTextFalse,
  }) : super(
          key: key,
        );

  final Widget title;
  final Widget content;
  final String buttonTextTrue;
  final String buttonTextFalse;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return new CupertinoAlertDialog(
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
      return new AlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          FlatButton(
            child: Text(buttonTextTrue),
            textColor: Colors.blue,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          FlatButton(
            child: Text(buttonTextFalse),
            textColor: Colors.blue,
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    }
  }
}
