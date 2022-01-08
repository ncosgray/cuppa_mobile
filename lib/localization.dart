/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    localization.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

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

// Supported language codes and names
final Map<String, String> supportedLanguages = {
  'en': 'English',
  'cs': 'Čeština',
  'da': 'Dansk',
  'de': 'Deutsch',
  //'eo': 'Esperanto', // Not supported by GlobalMaterialLocalizations
  'es': 'Español',
  'et': 'Eesti',
  'eu': 'Euskara',
  'fi': 'Suomi',
  'fr': 'Français',
  //'ga': 'Gaeilge', // Not supported by GlobalMaterialLocalizations
  //'ht': 'Ayisyen', // Not supported by GlobalMaterialLocalizations
  'it': 'Italiano',
  'nb': 'Norsk Bokmål',
  'nl': 'Nederlands',
  'ru': 'Русский',
  'sl': 'Slovenščina',
};

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  // Localizations instance
  static AppLocalizations get instance => AppLocalizationsDelegate.instance!;

  // Populate strings map from JSON files in langs folder
  Map<String, String> _localizedStrings = new Map();
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
    return AppLocalizations.instance._localizedStrings[key] ?? '';
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  static AppLocalizations? instance;

  // Determine if a language is supported
  @override
  bool isSupported(Locale locale) =>
      supportedLanguages.keys.contains(locale.languageCode);

  // Load localizations
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
