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

import 'package:cuppa_mobile/common/constants.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Supported locales and language names
final Map<Locale, String> supportedLocales = {
  const Locale.fromSubtags(languageCode: 'ht'): 'Ayisyen',
  const Locale.fromSubtags(languageCode: 'az'): 'Azərbaycanca',
  const Locale.fromSubtags(languageCode: 'br'): 'Brezhoneg',
  const Locale.fromSubtags(languageCode: 'cs'): 'Čeština',
  const Locale.fromSubtags(languageCode: 'da'): 'Dansk',
  const Locale.fromSubtags(languageCode: 'de'): 'Deutsch',
  const Locale.fromSubtags(languageCode: 'et'): 'Eesti',
  const Locale.fromSubtags(languageCode: 'en'): 'English',
  const Locale.fromSubtags(languageCode: 'es'): 'Español',
  const Locale.fromSubtags(languageCode: 'eo'): 'Esperanto',
  const Locale.fromSubtags(languageCode: 'eu'): 'Euskara',
  const Locale.fromSubtags(languageCode: 'fr'): 'Français',
  const Locale.fromSubtags(languageCode: 'ga'): 'Gaeilge',
  const Locale.fromSubtags(languageCode: 'it'): 'Italiano',
  const Locale.fromSubtags(languageCode: 'lb'): 'Lëtzebuergesch',
  const Locale.fromSubtags(languageCode: 'nl'): 'Nederlands',
  const Locale.fromSubtags(languageCode: 'nb'): 'Norsk Bokmål',
  const Locale.fromSubtags(languageCode: 'pt'): 'Português',
  const Locale.fromSubtags(languageCode: 'sl'): 'Slovenščina',
  const Locale.fromSubtags(languageCode: 'fi'): 'Suomi',
  const Locale.fromSubtags(languageCode: 'tr'): 'Türkçe',
  const Locale.fromSubtags(languageCode: 'ru'): 'Русский',
  const Locale.fromSubtags(languageCode: 'uk'): 'Українська',
  const Locale.fromSubtags(languageCode: 'he'): 'עברית',
  const Locale.fromSubtags(languageCode: 'ur'): 'اردو',
  const Locale.fromSubtags(languageCode: 'ja'): '日本語',
  const Locale.fromSubtags(languageCode: 'zh'): '简体中文',
  const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'): '繁體中文',
};
final List<String> supportedLanguageCodes = supportedLocales.keys
    .map<String>((Locale locale) => localeString(locale))
    .toList();

// Localizable app strings
// ignore_for_file: constant_identifier_names
enum AppString {
  about_app('about_app'),
  about_license('about_license'),
  about_title('about_title'),
  add_tea_button('add_tea_button'),
  cancel_button('cancel_button'),
  confirm_continue('confirm_continue'),
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
  prefs_hide_increments('prefs_hide_increments'),
  prefs_hide_increments_info('prefs_hide_increments_info'),
  prefs_language('prefs_language'),
  prefs_notifications('prefs_notifications'),
  prefs_show_extra('prefs_show_extra'),
  prefs_title('prefs_title'),
  prefs_use_celsius('prefs_use_celsius'),
  privacy_policy('privacy_policy'),
  settings_title('settings_title'),
  source_code_info('source_code_info'),
  source_code('source_code'),
  stats_begin('stats_begin'),
  stats_confirm_disable('stats_confirm_disable'),
  stats_confirm_enable('stats_confirm_enable'),
  stats_enable('stats_enable'),
  stats_favorite_am('stats_favorite_am'),
  stats_favorite_pm('stats_favorite_pm'),
  stats_header('stats_header'),
  stats_starred('stats_starred'),
  stats_timer_count('stats_timer_count'),
  stats_timer_time('stats_timer_time'),
  stats_title('stats_title'),
  tea_name_assam('tea_name_assam'),
  tea_name_black('tea_name_black'),
  tea_name_chamomile('tea_name_chamomile'),
  tea_name_cold_brew('tea_name_cold_brew'),
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
  tutorial('tutorial'),
  tutorial_info('tutorial_info'),
  tutorial_text1('tutorial_text1'),
  tutorial_text2('tutorial_text2'),
  tutorial_text3('tutorial_text3'),
  tutorial_text4('tutorial_text4'),
  tutorial_text5('tutorial_text5'),
  undo_button('undo_button'),
  undo_message('undo_message'),
  unit_celsius('unit_celsius'),
  unit_fahrenheit('unit_fahrenheit'),
  unit_hours('unit_hours'),
  unit_minutes('unit_minutes'),
  unit_seconds('unit_seconds'),
  version_history('version_history'),
  yes_button('yes_button');

  final String key;

  const AppString(this.key);

  // Lookup localized string and apply substitutions
  String translate({String teaName = ''}) {
    return AppLocalizations.translate(key)
        .replaceAll('{{tea_name}}', teaName)
        .replaceAll('{{app_name}}', appName)
        .replaceAll('{{favorites_max}}', favoritesMaxCount.toString())
        .replaceAll('{{teas_max}}', teasMaxCount.toString())
        .replaceAll('{{timers_max}}', timersMaxCount.toString())
        .replaceAll('{{star_symbol}}', starSymbol);
  }
}

// Languages not supported by GlobalMaterialLocalizations
final List<String> fallbackLanguages = supportedLanguageCodes
    .where((item) => !kMaterialSupportedLanguages.contains(item))
    .toList();

// Given a locale, return its flat string name in the expected format
String localeString(Locale locale) {
  String name = locale.languageCode;
  if (locale.scriptCode != null) name += '_${locale.scriptCode!}';
  return name;
}

// Given a flat string, parse into a locale
Locale parseLocaleString(String name) {
  List<String> nameParts = name.split('_');
  Locale locale = Locale.fromSubtags(
    languageCode: nameParts[0],
    scriptCode: nameParts.length > 1 ? nameParts[1] : null,
  );
  return locale;
}

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
        await rootBundle.loadString('langs/${localeString(locale)}.json');
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
      supportedLocales.containsKey(
        Locale.fromSubtags(
          languageCode: locale.languageCode,
          scriptCode: locale.scriptCode,
        ),
      ) ||
      supportedLanguageCodes.contains(locale.languageCode);

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
