/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    main.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2021 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa: a simple tea timer app for Android and iOS

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'platform_adaptive.dart';
import 'timer.dart';
import 'prefs.dart';

SharedPreferences sharedPrefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();

  runApp(new CuppaApp());
}

class CuppaApp extends StatelessWidget {
  static final String appTitle = 'Cuppa';
  static TargetPlatform appPlatform;

  @override
  Widget build(BuildContext context) {
    appPlatform = Theme.of(context).platform;

    Prefs.initTeas();

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
      initialRoute: '/',
      routes: {
        '/': (context) => TimerWidget(),
        '/prefs': (context) => PrefsWidget(),
      },
    );
  }
}
