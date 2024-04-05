/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    main.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa: a simple tea timer app for Android and iOS

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
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest_all.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();
  packageInfo = await PackageInfo.fromPlatform();

  // Set metric locale based on country code
  if ((WidgetsBinding.instance.platformDispatcher.locale.countryCode ?? '') ==
      'US') {
    isLocaleMetric = false;
  }

  // Get time zone
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  // Initialize notifications plugin
  await initializeNotifications();

  runApp(const CuppaApp());
}

// Create the app
class CuppaApp extends StatelessWidget {
  const CuppaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get platform
    appPlatform = Theme.of(context).platform;

    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Selector<AppProvider, ({AppTheme appTheme, String appLanguage})>(
        selector: (_, provider) => (
          appTheme: provider.appTheme,
          appLanguage: provider.appLanguage,
        ),
        builder: (context, settings, child) {
          // Settings from provider
          ThemeMode appThemeMode = settings.appTheme.themeMode;
          bool appThemeBlack = settings.appTheme.blackTheme;
          String appLanguage = settings.appLanguage;

          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              return MaterialApp(
                builder: (context, child) {
                  return ShowCaseWidget(
                    autoPlay: false,
                    builder: Builder(
                      builder: (context) => child!,
                    ),
                  );
                },
                title: appName,
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                // Configure app theme including dynamic colors if supported
                theme: createLightTheme(
                  dynamicColors: lightDynamic,
                ),
                darkTheme: createDarkTheme(
                  dynamicColors: darkDynamic,
                  blackTheme: appThemeBlack,
                ),
                themeMode: appThemeMode,
                // Initial route
                home: const TimerWidget(),
                // Localization
                locale: appLanguage != followSystemLanguage
                    ? parseLocaleString(appLanguage)
                    : null,
                supportedLocales: supportedLocales.keys,
                localizationsDelegates: const [
                  AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  FallbackMaterialLocalizationsDelegate(),
                  FallbackCupertinoLocalizationsDelegate(),
                ],
                localeResolutionCallback: (locale, supportedLocales) {
                  if (locale != null) {
                    // Set locale if supported
                    for (Locale supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode == locale.languageCode &&
                          supportedLocale.scriptCode == locale.scriptCode) {
                        return supportedLocale;
                      }
                    }
                    for (Locale supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode == locale.languageCode) {
                        return supportedLocale;
                      }
                    }
                  }

                  // Default if locale not supported
                  return const Locale.fromSubtags(
                    languageCode: defaultLanguage,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
