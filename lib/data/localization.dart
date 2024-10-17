/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    localization.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

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

const defaultLocale = Locale.fromSubtags(languageCode: 'en', countryCode: 'GB');

// Supported locales
const List<Locale> supportedLocales = [
  Locale.fromSubtags(languageCode: 'az'),
  Locale.fromSubtags(languageCode: 'br'),
  Locale.fromSubtags(languageCode: 'cs'),
  Locale.fromSubtags(languageCode: 'cv'),
  Locale.fromSubtags(languageCode: 'da'),
  Locale.fromSubtags(languageCode: 'de'),
  Locale.fromSubtags(languageCode: 'en', countryCode: 'GB'),
  Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
  Locale.fromSubtags(languageCode: 'eo'),
  Locale.fromSubtags(languageCode: 'es'),
  Locale.fromSubtags(languageCode: 'et'),
  Locale.fromSubtags(languageCode: 'eu'),
  Locale.fromSubtags(languageCode: 'fi'),
  Locale.fromSubtags(languageCode: 'fr'),
  Locale.fromSubtags(languageCode: 'ga'),
  Locale.fromSubtags(languageCode: 'he'),
  Locale.fromSubtags(languageCode: 'ht'),
  Locale.fromSubtags(languageCode: 'ia'),
  Locale.fromSubtags(languageCode: 'it'),
  Locale.fromSubtags(languageCode: 'ja'),
  Locale.fromSubtags(languageCode: 'lb'),
  Locale.fromSubtags(languageCode: 'nb'),
  Locale.fromSubtags(languageCode: 'nl'),
  Locale.fromSubtags(languageCode: 'pt'),
  Locale.fromSubtags(languageCode: 'ru'),
  Locale.fromSubtags(languageCode: 'sl'),
  Locale.fromSubtags(languageCode: 'tr'),
  Locale.fromSubtags(languageCode: 'uk'),
  Locale.fromSubtags(languageCode: 'ur'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  Locale.fromSubtags(languageCode: 'zh'),
];
final List<String> supportedLanguageCodes = supportedLocales
    .map<String>((Locale locale) => locale.languageCode)
    .toList();

// Languages not supported by GlobalMaterialLocalizations
final List<String> fallbackLanguageCodes = supportedLanguageCodes
    .where((item) => !kMaterialSupportedLanguages.contains(item))
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
  confirm_import('confirm_import'),
  confirm_message_line1('confirm_message_line1'),
  confirm_message_line2('confirm_message_line2'),
  confirm_title('confirm_title'),
  done_button('done_button'),
  error_name_long('error_name_long'),
  error_name_missing('error_name_missing'),
  export_failure('export_failure'),
  export_import('export_import'),
  export_label('export_label'),
  help_translate_info('help_translate_info'),
  help_translate('help_translate'),
  import_failure('import_failure'),
  import_sucess('import_sucess'),
  issues_info('issues_info'),
  issues('issues'),
  language_name('language_name'),
  new_tea_default_name('new_tea_default_name'),
  no_button('no_button'),
  notification_channel_name('notification_channel_name'),
  notification_channel_silent('notification_channel_silent'),
  notification_text('notification_text'),
  notification_title('notification_title'),
  ok_button('ok_button'),
  prefs_app_theme('prefs_app_theme'),
  prefs_cup_style('prefs_cup_style'),
  prefs_cup_style_chinese('prefs_cup_style_chinese'),
  prefs_cup_style_classic('prefs_cup_style_classic'),
  prefs_cup_style_floral('prefs_cup_style_floral'),
  prefs_cup_style_mug('prefs_cup_style_mug'),
  prefs_stacked_view('prefs_stacked_view'),
  prefs_header('prefs_header'),
  prefs_hide_increments('prefs_hide_increments'),
  prefs_hide_increments_info('prefs_hide_increments_info'),
  prefs_language('prefs_language'),
  prefs_notifications('prefs_notifications'),
  prefs_show_extra('prefs_show_extra'),
  prefs_show_extra_ratios('prefs_show_extra_ratios'),
  prefs_silent_default('prefs_silent_default'),
  prefs_silent_default_info('prefs_silent_default_info'),
  prefs_title('prefs_title'),
  prefs_use_brew_ratios('prefs_use_brew_ratios'),
  prefs_use_celsius('prefs_use_celsius'),
  privacy_policy('privacy_policy'),
  settings_title('settings_title'),
  sort_by_alpha('sort_by_alpha'),
  sort_by_brew_time('sort_by_brew_time'),
  sort_by_color('sort_by_color'),
  sort_by_favorite('sort_by_favorite'),
  sort_by_recent('sort_by_recent'),
  sort_by_usage('sort_by_usage'),
  sort_title('sort_title'),
  source_code_info('source_code_info'),
  source_code('source_code'),
  stats_begin('stats_begin'),
  stats_confirm_disable('stats_confirm_disable'),
  stats_confirm_enable('stats_confirm_enable'),
  stats_enable('stats_enable'),
  stats_favorite_am('stats_favorite_am'),
  stats_favorite_pm('stats_favorite_pm'),
  stats_header('stats_header'),
  stats_include_deleted('stats_include_deleted'),
  stats_starred('stats_starred'),
  stats_tea_amount('stats_tea_amount'),
  stats_timer_count('stats_timer_count'),
  stats_timer_time('stats_timer_time'),
  stats_title('stats_title'),
  support_the_project('support_the_project'),
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
  unit_days('unit_days'),
  unit_fahrenheit('unit_fahrenheit'),
  unit_grams('unit_grams'),
  unit_hours('unit_hours'),
  unit_kilograms('unit_kilograms'),
  unit_milliliters('unit_milliliters'),
  unit_minutes('unit_minutes'),
  unit_ounces('unit_ounces'),
  unit_seconds('unit_seconds'),
  unit_teaspoons('unit_teaspoons'),
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

// Given a locale, return its flat string name in the expected format
String localeString(Locale locale) {
  String name = locale.languageCode;
  if (locale.scriptCode != null) name += '_${locale.scriptCode!}';
  if (locale.countryCode != null) name += '_${locale.countryCode!}';
  return name;
}

// Given a flat string, parse into a locale
Locale parseLocaleString(String name) {
  List<String> nameParts = name.split('_');
  String? scriptCode;
  String? countryCode;
  if (nameParts.length > 1) {
    if (nameParts[1].length == 2 &&
        nameParts[1] == nameParts[1].toUpperCase()) {
      countryCode = nameParts[1];
    } else {
      scriptCode = nameParts[1];
    }
  }
  return Locale.fromSubtags(
    languageCode: nameParts[0],
    scriptCode: scriptCode,
    countryCode: countryCode,
  );
}

// Initialize app language options
Map<String, String> languageOptions = {
  followSystemLanguage: followSystemLanguage,
};

// Populate app language options
Future<void> loadLanguageOptions() async {
  Map<String, String> unsortedOptions = {};

  for (final locale in supportedLocales) {
    // Load strings map from JSON file in langs folder
    String jsonString = await rootBundle.loadString(
      'langs/${localeString(locale)}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Add localized name to map
    unsortedOptions.addAll({
      localeString(locale):
          jsonMap[AppString.language_name.name] ?? localeString(locale),
    });
  }

  // Set language options, sorted by language name
  languageOptions.addAll(
    Map.fromEntries(
      unsortedOptions.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value)),
    ),
  );
}

// Resolve app locale from the device locale
Locale localeResolutionCallback(
  Locale? deviceLocale,
  Iterable<Locale> appLocales,
) {
  if (deviceLocale != null) {
    // Set locale if supported
    if (appLocales.contains(deviceLocale)) {
      return deviceLocale;
    }
    if (deviceLocale.scriptCode != null) {
      for (final appLocale in appLocales) {
        if (appLocale.languageCode == deviceLocale.languageCode &&
            appLocale.scriptCode == deviceLocale.scriptCode) {
          return appLocale;
        }
      }
    }
    if (deviceLocale.countryCode != null) {
      for (final appLocale in appLocales) {
        if (appLocale.languageCode == deviceLocale.languageCode &&
            appLocale.countryCode == deviceLocale.countryCode) {
          return appLocale;
        }
      }
    }
    for (final appLocale in appLocales) {
      if (appLocale.languageCode == deviceLocale.languageCode) {
        return appLocale;
      }
    }
  }

  // Default if locale not supported
  return defaultLocale;
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
    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));

    // Populate default (English) strings map
    String jsonDefaultString = await rootBundle.loadString(
      'langs/${localeString(defaultLocale)}.json',
    );
    Map<String, dynamic> jsonDefaultMap = json.decode(jsonDefaultString);
    _defaultStrings =
        jsonDefaultMap.map((key, value) => MapEntry(key, value.toString()));

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
      fallbackLanguageCodes.contains(locale.languageCode);

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
      fallbackLanguageCodes.contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      const DefaultCupertinoLocalizations();

  @override
  bool shouldReload(old) => false;
}
