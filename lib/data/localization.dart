/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    localization.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa localizations
// - Populate strings from language files
// - Get translated strings
// - String keys

import 'package:cuppa_mobile/data/constants.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Supported language codes and names
final Map<String, String> supportedLanguages = {
  'en': 'English',
  'az': 'Azərbaycanca',
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
  'pt': 'Português',
  'ru': 'Русский',
  'sl': 'Slovenščina',
  'tr': 'Türkçe',
  'uk': 'Українська',
};
const String defaultLanguage = 'en';

// Localizable app strings
enum AppString {
  about_app('about_app'),
  about_license('about_license'),
  about_title('about_title'),
  add_tea_button('add_tea_button'),
  cancel_button('cancel_button'),
  confirm_delete('confirm_delete'),
  confirm_message_line1('confirm_message_line1'),
  confirm_message_line2('confirm_message_line2'),
  confirm_title('confirm_title'),
  error_name_long('error_name_long'),
  error_name_missing('error_name_missing'),
  help_translate_info('help_translate_info'),
  help_translate('help_translate'),
  issues_info('issues_info'),
  issues('issues'),
  language_name('language_name'),
  new_tea_default_name('new_tea_default_name'),
  no_button('no_button'),
  notification_channel_name('notification_channel_name'),
  notification_text('notification_text'),
  notification_title('notification_title'),
  ok_button('ok_button'),
  prefs_app_theme('prefs_app_theme'),
  prefs_header('prefs_header'),
  prefs_language('prefs_language'),
  prefs_notifications('prefs_notifications'),
  prefs_show_extra('prefs_show_extra'),
  prefs_title('prefs_title'),
  prefs_use_celsius('prefs_use_celsius'),
  privacy_policy('privacy_policy'),
  source_code_info('source_code_info'),
  source_code('source_code'),
  tea_name_assam('tea_name_assam'),
  tea_name_black('tea_name_black'),
  tea_name_chamomile('tea_name_chamomile'),
  tea_name_darjeeling('tea_name_darjeeling'),
  tea_name_green('tea_name_green'),
  tea_name_herbal('tea_name_herbal'),
  tea_name_mint('tea_name_mint'),
  tea_name_oolong('tea_name_oolong'),
  tea_name_puer('tea_name_puer'),
  tea_name_rooibos('tea_name_rooibos'),
  tea_name_white('tea_name_white'),
  teas_title('teas_title'),
  theme_black('theme_black'),
  theme_dark('theme_dark'),
  theme_light('theme_light'),
  theme_system('theme_system'),
  theme_system_black('theme_system_black'),
  version_history('version_history'),
  yes_button('yes_button');

  final String key;

  const AppString(this.key);

  // Lookup localized string and apply substitutions
  String translate({String teaName = ''}) {
    return AppLocalizations.translate(key)
        .replaceAll('{{tea_name}}', teaName)
        .replaceAll('{{app_name}}', appName)
        .replaceAll('{{favorites_max}}', favoritesMaxCount.toString());
  }
}

// Languages not supported by GlobalMaterialLocalizations
final List<String> fallbackLanguages = supportedLanguages.keys
    .where((item) => !kMaterialSupportedLanguages.contains(item))
    .toList();

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  // Localizations instance
  static AppLocalizations get instance => AppLocalizationsDelegate.instance!;

  // Populate strings
  Map<String, String> _localizedStrings = {};
  Map<String, String> _defaultStrings = {};
  Future<bool> load() async {
    // Populate strings map from JSON file in langs folder
    String jsonString =
        await rootBundle.loadString('langs/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    // Populate default (English) strings map
    String jsonDefaultString =
        await rootBundle.loadString('langs/$defaultLanguage.json');
    Map<String, dynamic> jsonDefaultMap = json.decode(jsonDefaultString);

    _defaultStrings = jsonDefaultMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // Get translated string (or use default string if unavailable)
  static String translate(String key) {
    return AppLocalizations.instance._localizedStrings[key] ??
        AppLocalizations.instance._defaultStrings[key]!;
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
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    instance = localizations;
    return localizations;
  }

  @override
  bool shouldReload(old) => false;
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
      const DefaultMaterialLocalizations();

  @override
  bool shouldReload(old) => false;
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
      const DefaultCupertinoLocalizations();

  @override
  bool shouldReload(old) => false;
}
