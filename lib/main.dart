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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization.dart';
import 'platform_adaptive.dart';
import 'prefs.dart';
import 'timer.dart';

// Globals
SharedPreferences sharedPrefs;
TargetPlatform appPlatform;
final String appName = 'Cuppa';
final String aboutCopyright = '\u00a9 Nathan Cosgray';
final String aboutURL = 'https://nathanatos.com';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();

  runApp(new CuppaApp());
}

// Create the app
class CuppaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    appPlatform = Theme.of(context).platform;
    Prefs.initTeas();

    return new MaterialApp(
        builder: (context, child) {
          // Set scale factor
          return MediaQuery(
            child: child,
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          );
        },
        title: appName,
        // Configure theme
        theme: getPlatformAdaptiveTheme(appPlatform),
        darkTheme: getPlatformAdaptiveDarkTheme(appPlatform),
        // Configure routes
        initialRoute: '/',
        routes: {
          '/': (context) => TimerWidget(),
          '/prefs': (context) => PrefsWidget(),
        },
        // Localization
        supportedLocales: [
          const Locale('en', ''),
          const Locale('da', ''),
          const Locale('de', ''),
          const Locale('es', ''),
          const Locale('et', ''),
          const Locale('eu', ''),
          const Locale('fi', ''),
          const Locale('fr', ''),
          const Locale('ga', ''),
          const Locale('ht', ''),
          const Locale('it', ''),
          const Locale('nb', ''),
          const Locale('nl', ''),
          const Locale('ru', ''),
          const Locale('sl', ''),
        ],
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Set language or default to English
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        });
  }
}

// Format brew temperature as number with units
String formatTemp(i) {
  // Infer C or F based on temp range
  if (i <= 100)
    return i.toString() + '\u00b0C';
  else
    return i.toString() + '\u00b0F';
}

// Format brew remaining time as m:ss
String formatTimer(s) {
  // Build the time format string
  int mins = (s / 60).floor();
  int secs = s - (mins * 60);
  String secsString = secs.toString();
  if (secs < 10) secsString = '0' + secsString;
  return mins.toString() + ':' + secsString;
}
