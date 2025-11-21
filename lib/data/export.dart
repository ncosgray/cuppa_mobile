/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    export.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Export and import tea list, settings, and usage stats

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Export/import functionality
abstract class Export {
  // Create and optionally share a JSON file containing all app data
  static Future<bool> create(
    AppProvider provider, {
    bool share = false,
    Rect? sharePositionOrigin,
  }) async {
    try {
      // Create the export dataset
      String exportData = ExportFile(
        settings: ExportSettings(
          nextTeaID: Prefs.nextTeaID,
          showExtraList: provider.showExtraList
              .map((infoType) => infoType.value)
              .toList(),
          hideIncrements: provider.hideIncrements,
          silentDefault: provider.silentDefault,
          useCelsius: provider.useCelsius,
          useBrewRatios: provider.useBrewRatios,
          cupStyleValue: provider.cupStyle.value,
          buttonSizeValue: provider.buttonSize.value,
          appThemeValue: provider.appTheme.value,
          appLanguage: provider.appLanguage,
          collectStats: provider.collectStats,
          stackedView: provider.stackedView,
        ),
        teaList: provider.teaList,
        stats: await Stats.getTeaStats(),
      ).toJson();

      // Save to a temp file
      final Directory dir = await getApplicationDocumentsDirectory();
      final File file = .new(
        '${dir.path}/$exportFileName.$exportFileExtension',
      );
      File exportFile = await file.writeAsString(exportData);

      // Share via OS
      if (share) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(exportFile.path)],
            subject: AppString.export_label.translate(),
            sharePositionOrigin: sharePositionOrigin,
          ),
        );
      }
    } catch (e) {
      // Something went wrong
      return Future.value(false);
    }

    return Future.value(true);
  }

  // Load an export file
  static Future<bool> load(AppProvider provider) async {
    bool imported = false;

    // Prompt for export file source
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [exportFileExtension],
    );
    if (result != null && result.files.single.path != null) {
      try {
        // Read file contents
        final File file = .new(result.files.single.path!);
        ExportFile exportData = ExportFile.fromJson(
          jsonDecode(file.readAsStringSync()),
        );

        // Apply imported settings, replacing existing
        if (exportData.settings != null) {
          if (exportData.settings!.nextTeaID != null) {
            Prefs.nextTeaID = exportData.settings!.nextTeaID!;
          }

          if (exportData.settings!.showExtraList != null) {
            provider.showExtraList = exportData.settings!.showExtraList!
                .map(
                  (element) => ExtraInfo.values.cast<ExtraInfo?>().firstWhere(
                    (infoType) => infoType?.value == element,
                    orElse: () => null,
                  ),
                )
                .where((infoType) => infoType != null)
                .cast<ExtraInfo>()
                .toList();
          }

          if (exportData.settings!.showExtraList == null &&
              exportData.settings!.showExtra != null) {
            // Migrate from legacy setting
            provider.showExtraList = exportData.settings!.showExtra!
                ? ExtraInfo.values
                : defaultShowExtraList;
          }

          if (exportData.settings!.hideIncrements != null) {
            provider.hideIncrements = exportData.settings!.hideIncrements!;
          }

          if (exportData.settings!.silentDefault != null) {
            provider.silentDefault = exportData.settings!.silentDefault!;
          }

          if (exportData.settings!.useCelsius != null) {
            provider.useCelsius = exportData.settings!.useCelsius!;
          }

          if (exportData.settings!.useBrewRatios != null) {
            provider.useBrewRatios = exportData.settings!.useBrewRatios!;
          }

          // Look up cupStyle from value
          int? cupStyleValue = exportData.settings!.cupStyleValue;
          if (cupStyleValue != null && CupStyle.isValid(cupStyleValue)) {
            provider.cupStyle = CupStyle.fromValue(cupStyleValue)!;
          }

          // Look up buttonSize from value
          int? buttonSizeValue = exportData.settings!.buttonSizeValue;
          if (buttonSizeValue != null && ButtonSize.isValid(buttonSizeValue)) {
            provider.buttonSize = ButtonSize.fromValue(buttonSizeValue)!;
          }

          // Look up appTheme from value
          int? appThemeValue = exportData.settings!.appThemeValue;
          if (appThemeValue != null && AppTheme.isValid(appThemeValue)) {
            provider.appTheme = AppTheme.fromValue(appThemeValue)!;
          }

          if (exportData.settings!.appLanguage != null) {
            provider.appLanguage = exportData.settings!.appLanguage!;
          }

          if (exportData.settings!.collectStats != null) {
            provider.collectStats = exportData.settings!.collectStats!;
          }

          if (exportData.settings!.stackedView != null) {
            provider.stackedView = exportData.settings!.stackedView!;
          }

          imported = true;
        }

        // Load imported teas, replacing existing
        if (exportData.teaList != null) {
          provider.teaList = exportData.teaList!;
          imported = true;
        }

        // Load imported stats, replacing existing
        if (exportData.stats != null) {
          await Stats.clearStats();
          for (final stat in exportData.stats!) {
            await Stats.insertStat(stat);
          }
          imported = true;
        }
      } catch (e) {
        // Something went wrong
        imported = false;
      }
    }

    return Future.value(imported);
  }
}

// Export file definition
class ExportFile {
  ExportFile({
    required this.settings,
    required this.teaList,
    required this.stats,
  });

  // Factories
  factory ExportFile.fromJson(Map<String, dynamic> json) {
    try {
      return ExportFile(
        settings: ExportSettings.fromJson(json[jsonKeySettings]),
        teaList: (json[jsonKeyTeas].map<Tea>(
          (tea) => Tea.fromJson(tea),
        )).toList(),
        stats: (json[jsonKeyStats].map<Stat>(
          (stat) => Stat.fromJson(stat),
        )).toList(),
      );
    } catch (e) {
      return ExportFile(settings: null, teaList: null, stats: null);
    }
  }

  String toJson() {
    return jsonEncode({
      jsonKeySettings: settings,
      jsonKeyTeas: teaList,
      jsonKeyStats: stats,
    });
  }

  // Fields
  ExportSettings? settings;
  List<Tea>? teaList;
  List<Stat>? stats;
}

// Settings export/import class
class ExportSettings {
  ExportSettings({
    this.nextTeaID,
    this.showExtra,
    this.showExtraList,
    this.hideIncrements,
    this.silentDefault,
    this.useCelsius,
    this.useBrewRatios,
    this.cupStyleValue,
    this.buttonSizeValue,
    this.appThemeValue,
    this.appLanguage,
    this.collectStats,
    this.stackedView,
  });

  // Factories
  factory ExportSettings.fromJson(Map<String, dynamic> json) {
    return ExportSettings(
      nextTeaID: tryCast<int>(json[jsonKeyNextTeaID]),
      showExtra: tryCast<bool>(json[jsonKeyShowExtra]),
      showExtraList: (json[jsonKeyShowExtraList] as List?)?.cast<int>(),
      hideIncrements: tryCast<bool>(json[jsonKeyHideIncrements]),
      silentDefault: tryCast<bool>(json[jsonKeySilentDefault]),
      useCelsius: tryCast<bool>(json[jsonKeyUseCelsius]),
      useBrewRatios: tryCast<bool>(json[jsonKeyUseBrewRatios]),
      cupStyleValue: tryCast<int>(json[jsonKeyCupStyle]),
      buttonSizeValue: tryCast<int>(json[jsonKeyButtonSize]),
      appThemeValue: tryCast<int>(json[jsonKeyAppTheme]),
      appLanguage: tryCast<String>(json[jsonKeyAppLanguage]),
      collectStats: tryCast<bool>(json[jsonKeyCollectStats]),
      stackedView: tryCast<bool>(json[jsonKeyStackedView]),
    );
  }

  Map<String, dynamic> toJson() => {
    jsonKeyNextTeaID: nextTeaID,
    jsonKeyShowExtraList: showExtraList, // Do not export legacy showExtra
    jsonKeyHideIncrements: hideIncrements,
    jsonKeySilentDefault: silentDefault,
    jsonKeyUseCelsius: useCelsius,
    jsonKeyUseBrewRatios: useBrewRatios,
    jsonKeyCupStyle: cupStyleValue,
    jsonKeyButtonSize: buttonSizeValue,
    jsonKeyAppTheme: appThemeValue,
    jsonKeyAppLanguage: appLanguage,
    jsonKeyCollectStats: collectStats,
    jsonKeyStackedView: stackedView,
  };

  // Fields
  int? nextTeaID;
  bool? showExtra;
  List<int>? showExtraList;
  bool? hideIncrements;
  bool? silentDefault;
  bool? useCelsius;
  bool? useBrewRatios;
  int? cupStyleValue;
  int? buttonSizeValue;
  int? appThemeValue;
  String? appLanguage;
  bool? collectStats;
  bool? stackedView;
}
