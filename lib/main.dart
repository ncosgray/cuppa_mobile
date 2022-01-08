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

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization.dart';
import 'platform_adaptive.dart';
import 'prefs.dart';
import 'timer.dart';

// Globals
late SharedPreferences sharedPrefs;
late TargetPlatform appPlatform;
late double deviceWidth;
late double deviceHeight;
bool isLocaleMetric = true;
final String appName = 'Cuppa';
final String aboutCopyright = '\u00a9 Nathan Cosgray';
final String aboutURL = 'https://nathanatos.com';

// Quick actions
QuickActions quickActions = const QuickActions();
final int favoritesMaxCount = 4; // iOS limitation
final String shortcutPrefix = 'shortcutTea';

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

    return ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: Consumer<AppProvider>(
            builder: (context, themeProvider, child) => MaterialApp(
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
                themeMode: Prefs.appThemes[appTheme],
                // Configure routes
                initialRoute: '/',
                routes: {
                  '/': (context) => TimerWidget(),
                  '/prefs': (context) => PrefsWidget(),
                },
                // Localization
                locale: appLanguage != '' ? Locale(appLanguage, '') : null,
                supportedLocales:
                    supportedLanguages.keys.map<Locale>((String value) {
                  return Locale(value, '');
                }).toList(),
                localizationsDelegates: [
                  const AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
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

// Provider for theme and language changes
class AppProvider extends ChangeNotifier {
  void update() {
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

// Add quick action shortcuts
void setQuickActions() {
  quickActions.setShortcutItems(teaList
      .where((tea) => tea.isFavorite == true)
      .take(favoritesMaxCount)
      .map<ShortcutItem>((tea) {
    // Create a shortcut item for this favorite tea
    return ShortcutItem(
      type: shortcutPrefix + teaList.indexOf(tea).toString(),
      localizedTitle: tea.name,
      icon: tea.shortcutIcon,
    );
  }).toList());
}
