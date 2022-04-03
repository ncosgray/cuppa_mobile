/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    main.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa: a simple tea timer app for Android and iOS

import 'package:Cuppa/data/constants.dart';
import 'package:Cuppa/data/localization.dart';
import 'package:Cuppa/data/prefs.dart';
import 'package:Cuppa/widgets/about_page.dart';
import 'package:Cuppa/widgets/platform_adaptive.dart';
import 'package:Cuppa/widgets/prefs_page.dart';
import 'package:Cuppa/widgets/timer_page.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Globals
bool timerActive = false;
late SharedPreferences sharedPrefs;
late TargetPlatform appPlatform;
late double deviceWidth;
late double deviceHeight;
bool isLocaleMetric = true;

// Package info
PackageInfo packageInfo = PackageInfo(
  appName: 'Unknown',
  packageName: 'Unknown',
  version: 'Unknown',
  buildNumber: 'Unknown',
);

// Quick actions
final QuickActions quickActions = const QuickActions();

// Notification channel
final MethodChannel notifyPlatform = const MethodChannel(notifyChannel);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();
  packageInfo = await PackageInfo.fromPlatform();

  runApp(CuppaApp());
}

// Create the app
class CuppaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    appPlatform = Theme.of(context).platform;

    // Load user settings
    Prefs.load();

    return ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: Consumer<AppProvider>(
            builder: (context, provider, child) => MaterialApp(
                builder: (context, child) {
                  // Get device dimensions
                  deviceWidth = MediaQuery.of(context).size.width;
                  deviceHeight = MediaQuery.of(context).size.height;

                  // Set scale factor
                  return MediaQuery(
                    child: child!,
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  );
                },
                title: appName,
                debugShowCheckedModeBanner: false,
                // Configure app theme
                theme: getPlatformAdaptiveTheme(appPlatform),
                darkTheme: getPlatformAdaptiveDarkTheme(appPlatform),
                themeMode: Prefs.appThemes[Prefs.appTheme],
                // Configure routes
                initialRoute: routeTimer,
                routes: {
                  routeTimer: (context) => TimerWidget(),
                  routePrefs: (context) => PrefsWidget(),
                  routeAbout: (context) => AboutWidget(),
                },
                // Localization
                locale: Prefs.appLanguage != ''
                    ? Locale(Prefs.appLanguage, '')
                    : null,
                supportedLocales:
                    supportedLanguages.keys.map<Locale>((String value) {
                  return Locale(value, '');
                }).toList(),
                localizationsDelegates: [
                  const AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  const FallbackMaterialLocalizationsDelegate(),
                  const FallbackCupertinoLocalizationsDelegate(),
                ],
                localeResolutionCallback: (locale, supportedLocales) {
                  if (locale != null) {
                    // Set metric locale based on country code
                    if (locale.countryCode == 'US') isLocaleMetric = false;

                    // Set language or default to English
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode == locale.languageCode) {
                        return supportedLocale;
                      }
                    }
                  }
                  return Locale('en', '');
                })));
  }
}

// Provider for settings changes
class AppProvider extends ChangeNotifier {
  void update() {
    // Save user settings
    Prefs.save();

    // Ensure UI elements get updated
    notifyListeners();
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
