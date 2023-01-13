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
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/timer_page.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest_all.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
import 'package:tuple/tuple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();
  packageInfo = await PackageInfo.fromPlatform();

  // Get time zone
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  // Initialize notifications plugin
  await notify.initialize(const InitializationSettings(
    android: AndroidInitializationSettings(notifyIcon),
    iOS: DarwinInitializationSettings(
      // Wait to request permissions when user starts a timer
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    ),
  ));

  runApp(const CuppaApp());
}

// Create the app
class CuppaApp extends StatelessWidget {
  const CuppaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get platform
    appPlatform = Theme.of(context).platform;

    return ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: Selector<AppProvider, Tuple2<AppTheme, String>>(
            selector: (_, provider) =>
                Tuple2(provider.appTheme, provider.appLanguage),
            builder: (context, settings, child) {
              // Settings from provider
              ThemeMode appThemeMode = settings.item1.themeMode;
              bool appThemeBlack = settings.item1.blackTheme;
              String appLanguage = settings.item2;

              return MaterialApp(
                  builder: (context, child) {
                    // Set scale factor, up to a limit
                    appTextScale =
                        MediaQuery.of(context).textScaleFactor > maxTextScale
                            ? maxTextScale
                            : MediaQuery.of(context).textScaleFactor;
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaleFactor: appTextScale),
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
                  darkTheme: getPlatformAdaptiveDarkTheme(appPlatform,
                      blackTheme: appThemeBlack),
                  themeMode: appThemeMode,
                  // Initial route
                  home: const TimerWidget(),
                  // Localization
                  locale: appLanguage != '' ? Locale(appLanguage, '') : null,
                  supportedLocales:
                      supportedLanguages.keys.map<Locale>((String value) {
                    return Locale(value, '');
                  }).toList(),
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
                      // Set metric locale based on country code
                      if (locale.countryCode == 'US') {
                        isLocaleMetric = false;
                      }

                      // Set language or default to English
                      for (var supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode ==
                            locale.languageCode) {
                          return supportedLocale;
                        }
                      }
                    }
                    return const Locale(defaultLanguage, '');
                  });
            }));
  }
}
