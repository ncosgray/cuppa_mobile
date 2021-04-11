/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    main.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2020 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa: a simple tea timer app for Android and iOS

import 'package:flutter/material.dart';
import 'platform_adaptive.dart';
import 'timer.dart';

void main() {
  runApp(new CuppaApp());
}

class CuppaApp extends StatelessWidget {
  static final String appTitle = 'Cuppa';
  static TargetPlatform appPlatform;

  @override
  Widget build(BuildContext context) {
    appPlatform = Theme.of(context).platform;

    return new MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          child: child,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      title: appTitle,
      theme: getPlatformAdaptiveTheme(appPlatform),
      darkTheme: getPlatformAdaptiveDarkTheme(appPlatform),
      home: TimerRoute(),
    );
  }
}

class TimerRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new PlatformAdaptiveAppBar(
          title: new Text(CuppaApp.appTitle),
          platform: CuppaApp.appPlatform,
        ),
        body: new TimerWidget());
  }
}
