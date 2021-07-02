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

// Cuppa localizations
// - Populate strings from language files
// - Get translated strings

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  // Localizations instance
  static AppLocalizations get instance => AppLocalizationsDelegate.instance;

  // Populate strings map from JSON files in langs folder
  Map<String, String> _localizedStrings;
  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString('langs/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // Get translated string
  static String translate(String key) {
    return AppLocalizations.instance._localizedStrings[key];
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  static AppLocalizations instance;

  @override
  bool isSupported(Locale locale) => [
        'en',
        'de',
        'fi',
        'fr',
        'ht',
        'it',
        'nb',
        'sl'
      ].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    instance = localizations;
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
