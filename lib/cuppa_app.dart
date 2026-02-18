/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    cuppa_app.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa app builder
// - Intialize globals, theme, localization

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/local_notifications.dart';
import 'package:cuppa_mobile/common/themes.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/pages/timer_page.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:region_settings/region_settings.dart';
import 'package:showcaseview/showcaseview.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest_all.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

// App initialization
Future<void> initializeApp({bool testing = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Settings initialization
  await Prefs.init();
  packageInfo = await PackageInfo.fromPlatform();
  regionSettings = await RegionSettings.getSettings();
  await loadLanguageOptions();

  // Get time zone
  tz.initializeTimeZones();
  final TimezoneInfo timeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZone.identifier));

  // Initialize notifications plugin
  skipNotify = testing;
  await initializeNotifications();

  // Register showcase for tutorial
  skipTutorial = testing;
  ShowcaseView.register();
}

// Create the app
class CuppaApp extends StatelessWidget {
  const CuppaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Selector<AppProvider, ({AppTheme appTheme, String appLanguage})>(
        selector: (_, provider) =>
            (appTheme: provider.appTheme, appLanguage: provider.appLanguage),
        builder: (context, settings, child) {
          // Settings from provider
          ThemeMode appThemeMode = settings.appTheme.themeMode;
          bool appThemeBlack = settings.appTheme.blackTheme;
          String appLanguage = settings.appLanguage;
          bool isSystemLanguage = appLanguage == followSystemLanguage;

          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              return MaterialApp(
                title: appName,
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                // Configure app theme including dynamic colors if supported
                theme: createLightTheme(dynamicColors: lightDynamic),
                highContrastTheme: createLightTheme(
                  dynamicColors: lightDynamic,
                  highContrast: true,
                ),
                darkTheme: createDarkTheme(
                  dynamicColors: darkDynamic,
                  blackTheme: appThemeBlack,
                ),
                highContrastDarkTheme: createDarkTheme(
                  dynamicColors: darkDynamic,
                  blackTheme: appThemeBlack,
                  highContrast: true,
                ),
                themeMode: appThemeMode,
                // Initial route
                home: const TimerWidget(),
                // Localization
                locale: isSystemLanguage
                    ? null
                    : parseLocaleString(appLanguage),
                supportedLocales: supportedLocales,
                localizationsDelegates: [
                  AppLocalizationsDelegate(isSystemLanguage: isSystemLanguage),
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  FallbackMaterialLocalizationsDelegate(),
                  FallbackCupertinoLocalizationsDelegate(),
                ],
                localeResolutionCallback: localeResolutionCallback,
              );
            },
          );
        },
      ),
    );
  }
}
