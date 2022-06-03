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

import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/widgets/about_page.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/prefs_page.dart';
import 'package:cuppa_mobile/widgets/timer_page.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Load app theme settings
    Prefs.loadTheme();

    return ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: Consumer<AppProvider>(
            builder: (context, provider, child) => MaterialApp(
                builder: (context, child) {
                  // Get device dimensions
                  deviceWidth = MediaQuery.of(context).size.width;
                  deviceHeight = MediaQuery.of(context).size.height;

                  return MediaQuery(
                    // Set scale factor
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    // Set default scroll behavior
                    child: ScrollConfiguration(
                        behavior: PlatformAdaptiveScrollBehavior(appPlatform),
                        child: child!),
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
