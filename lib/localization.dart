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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Supported language codes and names
final Map<String, String> supportedLanguages = {
  'en': 'English',
  'br': 'Brezhoneg',
  'cs': 'Čeština',
  'da': 'Dansk',
  'de': 'Deutsch',
  'eo': 'Esperanto',
  'es': 'Español',
  'et': 'Eesti',
  'eu': 'Euskara',
  'fi': 'Suomi',
  'fr': 'Français',
  'ga': 'Gaeilge',
  'he': 'עברית',
  'ht': 'Ayisyen',
  'it': 'Italiano',
  'nb': 'Norsk Bokmål',
  'nl': 'Nederlands',
  'ru': 'Русский',
  'sl': 'Slovenščina',
  'uk': 'Українська',
};

// Languages not supported by GlobalMaterialLocalizations
final List<String> fallbackLanguages = supportedLanguages.keys
    .where((item) => !kMaterialSupportedLanguages.contains(item))
    .toList();

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
  bool shouldReload(_) => false;
}

class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  // Force defaults for locales not supported by GlobalMaterialLocalizations
  @override
  bool isSupported(Locale locale) =>
      fallbackLanguages.contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      DefaultMaterialLocalizations();

  @override
  bool shouldReload(_) => false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  // Force defaults for locales not supported by CupertinoLocalizations
  @override
  bool isSupported(Locale locale) =>
      fallbackLanguages.contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      DefaultCupertinoLocalizations();

  @override
  bool shouldReload(_) => false;
}
