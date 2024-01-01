/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    export.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Export and import tea list, settings, and usage stats

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:file_picker/file_picker.dart';

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Export/import functionality
abstract class Export {
  // Create and optionally share a JSON file containing all app data
  static void create(AppProvider provider, {bool share = false}) async {
    // Create the export dataset
    String exportData = ExportFile(
      settings: Settings(
        showExtra: provider.showExtra,
        hideIncrements: provider.hideIncrements,
        useCelsius: provider.useCelsius,
        appThemeValue: provider.appTheme.value,
        appLanguage: provider.appLanguage,
        collectStats: provider.collectStats,
      ),
      teaList: provider.teaList,
      stats: await Stats.getTeaStats(),
    ).toJson();

    // Save to a temp file
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$exportFileName');
    File exportFile = await file.writeAsString(exportData);

    // Share via OS
    if (share) {
      await Share.shareXFiles(
        [XFile(exportFile.path)],
        subject: AppString.export_label.translate(),
      );
    }
  }

  // Load an export file
  static Future<bool> load(AppProvider provider) async {
    bool imported = false;

    // Prompt for export file source
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      // Read file contents
      final File file = File(result.files.single.path!);
      ExportFile exportData =
          ExportFile.fromJson(jsonDecode(file.readAsStringSync()));

      // Apply imported settings, replacing existing
      if (exportData.settings != null) {
        if (exportData.settings!.showExtra != null) {
          provider.showExtra = exportData.settings!.showExtra!;
        }

        if (exportData.settings!.hideIncrements != null) {
          provider.hideIncrements = exportData.settings!.hideIncrements!;
        }

        if (exportData.settings!.useCelsius != null) {
          provider.useCelsius = exportData.settings!.useCelsius!;
        }

        // Look up appTheme from value
        if (exportData.settings!.appThemeValue != null &&
            exportData.settings!.appThemeValue! < AppTheme.values.length) {
          provider.appTheme =
              AppTheme.values[exportData.settings!.appThemeValue!];
        }

        if (exportData.settings!.appLanguage != null) {
          provider.appLanguage = exportData.settings!.appLanguage!;
        }

        if (exportData.settings!.collectStats != null) {
          provider.collectStats = exportData.settings!.collectStats!;
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
        Stats.clearStats();
        for (Stat stat in exportData.stats!) {
          Stats.insertStat(stat);
        }
        imported = true;
      }
    }

    return Future.value(imported);
  }
}

// Export file definition
class ExportFile {
  Settings? settings;
  List<Tea>? teaList;
  List<Stat>? stats;

  // Constructor
  ExportFile({
    required this.settings,
    required this.teaList,
    required this.stats,
  });

  // Factories
  factory ExportFile.fromJson(Map<String, dynamic> json) {
    return ExportFile(
      settings: Settings.fromJson(json[jsonKeySettings]),
      teaList:
          (json[jsonKeyTeas].map<Tea>((tea) => Tea.fromJson(tea))).toList(),
      stats: (json[jsonKeyStats].map<Stat>((stat) => Stat.fromJson(stat)))
          .toList(),
    );
  }

  String toJson() {
    return jsonEncode({
      jsonKeySettings: settings,
      jsonKeyTeas: teaList,
      jsonKeyStats: stats,
    });
  }
}

// Settings export/import class
class Settings {
  bool? showExtra;
  bool? hideIncrements;
  bool? useCelsius;
  int? appThemeValue;
  String? appLanguage;
  bool? collectStats;

  // Constructor
  Settings({
    this.showExtra,
    this.hideIncrements,
    this.useCelsius,
    this.appThemeValue,
    this.appLanguage,
    this.collectStats,
  });

  // Factories
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      showExtra: json[jsonKeyShowExtra],
      hideIncrements: json[jsonKeyHideIncrements],
      useCelsius: json[jsonKeyUseCelsius],
      appThemeValue: json[jsonKeyAppTheme],
      appLanguage: json[jsonKeyAppLanguage],
      collectStats: json[jsonKeyCollectStats],
    );
  }

  Map<String, dynamic> toJson() => {
        jsonKeyShowExtra: showExtra,
        jsonKeyHideIncrements: hideIncrements,
        jsonKeyUseCelsius: useCelsius,
        jsonKeyAppTheme: appThemeValue,
        jsonKeyAppLanguage: appLanguage,
        jsonKeyCollectStats: collectStats,
      };
}
