/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    stats.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Tea timer usage statistics and database functionality
// - Query enums

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Stat entry definition
class Stat {
  Stat({
    Tea? tea,
    int? id,
    String? name,
    int? brewTime,
    int? brewTemp,
    double? brewAmount,
    bool? brewAmountMetric,
    Color? color,
    int? colorShadeRed,
    int? colorShadeGreen,
    int? colorShadeBlue,
    int? iconValue,
    bool? isFavorite,
    int? timerStartTime,
    int? count,
  }) {
    this.id = tea?.id ?? id ?? 0;
    this.name = tea?.name ?? name ?? unknownString;
    this.brewTime = tea?.brewTime ?? brewTime ?? defaultBrewTime;
    this.brewTemp = tea?.brewTemp ?? brewTemp ?? boilDegreesC;
    this.brewAmount = tea?.brewRatio.ratioNumerator ?? brewAmount ?? 0.0;
    this.brewAmountMetric =
        tea?.brewRatio.metricNumerator ??
        brewAmountMetric ??
        regionSettings.usesMetricSystem;
    this.colorShadeRed =
        convertRGBToInt(tea?.getColor().r) ?? colorShadeRed ?? 0;
    this.colorShadeGreen =
        convertRGBToInt(tea?.getColor().g) ?? colorShadeGreen ?? 0;
    this.colorShadeBlue =
        convertRGBToInt(tea?.getColor().b) ?? colorShadeBlue ?? 0;
    this.iconValue = tea?.icon.value ?? iconValue ?? defaultTeaIconValue;
    this.isFavorite = tea?.isFavorite ?? isFavorite ?? false;
    this.timerStartTime =
        timerStartTime ?? DateTime.now().millisecondsSinceEpoch;
    this.count = count ?? 0;
  }

  // Factories
  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      id: tryCast<int>(json[jsonKeyID]),
      name: tryCast<String>(json[jsonKeyName]) ?? unknownString,
      brewTime: tryCast<int>(json[jsonKeyBrewTime]) ?? defaultBrewTime,
      brewTemp: tryCast<int>(json[jsonKeyBrewTemp]) ?? boilDegreesC,
      brewAmount: tryCast<double>(json[jsonKeyBrewAmount]) ?? 0.0,
      brewAmountMetric:
          tryCast<bool>(json[jsonKeyBrewAmountMetric]) ??
          regionSettings.usesMetricSystem,
      colorShadeRed:
          tryCast<int>(json[jsonKeyColorShadeRed]) ?? defaultTeaColorValue,
      colorShadeGreen:
          tryCast<int>(json[jsonKeyColorShadeGreen]) ?? defaultTeaColorValue,
      colorShadeBlue:
          tryCast<int>(json[jsonKeyColorShadeBlue]) ?? defaultTeaColorValue,
      iconValue: tryCast<int>(json[jsonKeyIcon]) ?? defaultTeaIconValue,
      isFavorite: tryCast<bool>(json[jsonKeyIsFavorite]) ?? false,
      timerStartTime: tryCast<int>(json[jsonKeyTimerStartTime]) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    jsonKeyID: id,
    jsonKeyName: name,
    jsonKeyBrewTime: brewTime,
    jsonKeyBrewTemp: brewTemp,
    jsonKeyBrewAmount: brewAmount,
    jsonKeyBrewAmountMetric: brewAmountMetric,
    jsonKeyColorShadeRed: colorShadeRed,
    jsonKeyColorShadeGreen: colorShadeGreen,
    jsonKeyColorShadeBlue: colorShadeBlue,
    jsonKeyIcon: iconValue,
    jsonKeyIsFavorite: isFavorite,
    jsonKeyTimerStartTime: timerStartTime,
  };

  // Convert a stat to a map for inserting
  Map<String, dynamic> toMap() {
    return {
      statsColumnId: id,
      statsColumnName: name,
      statsColumnBrewTime: brewTime,
      statsColumnBrewTemp: brewTemp,
      statsColumnBrewAmount: (brewAmount * 10.0).toInt(),
      statsColumnBrewAmountMetric: brewAmountMetric ? 1 : 0,
      statsColumnColorShadeRed: colorShadeRed,
      statsColumnColorShadeGreen: colorShadeGreen,
      statsColumnColorShadeBlue: colorShadeBlue,
      statsColumnIconValue: iconValue,
      statsColumnIsFavorite: isFavorite ? 1 : 0,
      statsColumnTimerStartTime: timerStartTime,
    };
  }

  // Fields
  late int id;
  late String name;
  late int brewTime;
  late int brewTemp;
  late double brewAmount;
  late bool brewAmountMetric;
  late int colorShadeRed;
  late int colorShadeGreen;
  late int colorShadeBlue;
  late int iconValue;
  late bool isFavorite;
  late int timerStartTime;
  late int count;

  // Getters
  Color get color =>
      .fromRGBO(colorShadeRed, colorShadeGreen, colorShadeBlue, 1);
}

// Stats methods
abstract class Stats {
  // Data management queries
  static const createSQL =
      '''CREATE TABLE IF NOT EXISTS $statsTable (
      $statsColumnId INTEGER
      , $statsColumnName TEXT
      , $statsColumnBrewTime INTEGER
      , $statsColumnBrewTemp INTEGER
      , $statsColumnColorShadeRed INTEGER
      , $statsColumnColorShadeGreen INTEGER
      , $statsColumnColorShadeBlue INTEGER
      , $statsColumnIconValue INTEGER
      , $statsColumnIsFavorite INTEGER
      , $statsColumnTimerStartTime INTEGER
      , $statsColumnBrewAmount INTEGER
      , $statsColumnBrewAmountMetric INTEGER
    )''';
  static const upgradeV2Step1SQL = '''ALTER TABLE $statsTable
    ADD $statsColumnBrewAmount INTEGER''';
  static const upgradeV2Step2SQL = '''ALTER TABLE $statsTable
    ADD $statsColumnBrewAmountMetric INTEGER''';
  static const deleteAllSQL = 'DELETE FROM $statsTable';

  // Stats database getter
  static Database? _statsData;
  static Future<Database> get statsData async {
    if (_statsData?.isOpen != null) return _statsData!;

    _statsData = await openStats();
    return _statsData!;
  }

  // Open the usage stats database
  static Future<Database> openStats() async {
    return await openDatabase(
      join(await getDatabasesPath(), statsDatabase),
      version: 2,
      onCreate: (Database db, _) async => await db.execute(createSQL),
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute(upgradeV2Step1SQL);
          await db.execute(upgradeV2Step2SQL);
        }
      },
    );
  }

  // Clear usage data
  static Future<void> clearStats() async {
    final db = await statsData;

    // Delete contents of stats table
    await db.rawQuery(deleteAllSQL);
  }

  // Add a new stat to usage data
  static Future<void> insertStat(Stat stat) async {
    final db = await statsData;

    // Insert a row into the stats table
    await db.insert(statsTable, stat.toMap(), conflictAlgorithm: .replace);
  }

  // Retrieve tea stats from the database
  static Future<List<Stat>> getTeaStats([ListQuery? q]) async {
    final db = await statsData;

    // Query the stats table
    List<Map<String, dynamic>> results;
    if (q == null) {
      // Get all stats
      results = await db.query(statsTable);
    } else {
      // Get stats from query
      results = await db.rawQuery(q.sql);
    }

    // Convert the query results to a list
    return List.generate(results.length, (i) {
      return Stat(
        id: int.tryParse(results[i][statsColumnId].toString()),
        name: results[i][statsColumnName].toString(),
        brewTime: int.tryParse(results[i][statsColumnBrewTime].toString()),
        brewTemp: int.tryParse(results[i][statsColumnBrewTemp].toString()),
        brewAmount:
            (num.tryParse(results[i][statsColumnBrewAmount].toString()) ??
                0.0) /
            10.0,
        brewAmountMetric:
            int.tryParse(results[i][statsColumnBrewAmountMetric].toString()) ==
            1,
        colorShadeRed: int.tryParse(
          results[i][statsColumnColorShadeRed].toString(),
        ),
        colorShadeGreen: int.tryParse(
          results[i][statsColumnColorShadeGreen].toString(),
        ),
        colorShadeBlue: int.tryParse(
          results[i][statsColumnColorShadeBlue].toString(),
        ),
        iconValue: int.tryParse(results[i][statsColumnIconValue].toString()),
        isFavorite:
            int.tryParse(results[i][statsColumnIsFavorite].toString()) == 1,
        timerStartTime: int.tryParse(
          results[i][statsColumnTimerStartTime].toString(),
        ),
        count: int.tryParse(results[i][statsColumnCount].toString()),
      );
    });
  }

  // Retrieve a single numeric value from the stats database
  static Future<int> getMetric(MetricQuery q) async {
    int? metric;
    final db = await statsData;

    // Query the stats table
    var result = await db.rawQuery(q.sql);
    if (result.isNotEmpty) {
      metric = int.tryParse(result[0][statsColumnMetric].toString());
    }
    return metric ?? 0;
  }

  // Retrieve a single decimal value from the stats database
  static Future<double> getDecimal(DecimalQuery q) async {
    double? metric;
    final db = await statsData;

    // Query the stats table
    var result = await db.rawQuery(q.sql);
    if (result.isNotEmpty) {
      metric = double.tryParse(result[0][statsColumnMetric].toString());
    }
    return metric ?? 0.0;
  }

  // Retrieve a string value from the stats database
  static Future<String> getString(StringQuery q) async {
    String metric = '';
    final db = await statsData;

    // Query the stats table
    var result = await db.rawQuery(q.sql);
    if (result.isNotEmpty) {
      metric = result[0][statsColumnString].toString();
    }
    return metric;
  }
}

// Metric queries
enum MetricQuery {
  beginDateTime(_beginDateTimeSQL),
  totalCount(_totalCountSQL),
  totalTime(_totalTimeSQL),
  starredCount(_starredCountSQL);

  const MetricQuery(this.sql);

  final String sql;

  // Query SQL
  static const _beginDateTimeSQL =
      '''SELECT MIN($statsColumnTimerStartTime) AS metric
    FROM $statsTable''';
  static const _totalCountSQL = '''SELECT COUNT(*) AS metric
    FROM $statsTable''';
  static const _totalTimeSQL =
      '''SELECT SUM(IFNULL($statsColumnBrewTime, 0)) AS metric
    FROM $statsTable''';
  static const _starredCountSQL =
      '''SELECT COUNT(*) AS metric
    FROM $statsTable
    WHERE $statsColumnIsFavorite = 1''';
}

// Decimal queries
enum DecimalQuery {
  totalAmountG(_totalAmountGSQL),
  totalAmountTsp(_totalAmountTspSQL);

  const DecimalQuery(this.sql);

  final String sql;

  // Query SQL
  static const _totalAmountGSQL =
      '''SELECT SUM($statsColumnBrewAmount)/10.0 AS metric
    FROM $statsTable
    WHERE $statsColumnBrewAmountMetric = 1''';
  static const _totalAmountTspSQL =
      '''SELECT SUM($statsColumnBrewAmount)/10.0 AS metric
    FROM $statsTable
    WHERE $statsColumnBrewAmountMetric <> 1''';
}

// String queries
enum StringQuery {
  morningTea(_morningTeaSQL),
  afternoonTea(_afternoonTeaSQL);

  const StringQuery(this.sql);

  final String sql;

  // Query SQL
  static const _morningTeaSQL =
      '''SELECT (
      SELECT $statsColumnName
      FROM $statsTable
      WHERE $statsColumnId = stat.$statsColumnId
      ORDER BY $statsColumnTimerStartTime DESC
      LIMIT 1
    ) AS string
    FROM $statsTable stat
    WHERE STRFTIME('%H', stat.$statsColumnTimerStartTime / 1000, 'unixepoch', 'localtime') - 12 < 0
    GROUP BY stat.$statsColumnId
    ORDER BY COUNT(*) DESC
    LIMIT 1''';
  static const _afternoonTeaSQL =
      '''SELECT (
      SELECT $statsColumnName
      FROM $statsTable
      WHERE $statsColumnId = stat.$statsColumnId
      ORDER BY $statsColumnTimerStartTime DESC
      LIMIT 1
    ) AS string
    FROM $statsTable stat
    WHERE STRFTIME('%H', stat.$statsColumnTimerStartTime / 1000, 'unixepoch', 'localtime') - 12 >= 0
    GROUP BY stat.$statsColumnId
    ORDER BY COUNT(*) DESC
    LIMIT 1''';
}

// List queries
enum ListQuery {
  summaryStats(_summaryStatsSQL),
  mostUsed(_mostUsedSQL),
  recentlyUsed(_recentlyUsedSQL);

  const ListQuery(this.sql);

  final String sql;

  // Query SQL
  static const _summaryStatsSQL =
      '''SELECT $statsTable.$statsColumnId
    , tea.$statsColumnName
    , tea.$statsColumnColorShadeRed
    , tea.$statsColumnColorShadeGreen
    , tea.$statsColumnColorShadeBlue
    , tea.$statsColumnIconValue
    , tea.$statsColumnIsFavorite
    , COUNT(*) AS count
    FROM $statsTable
    INNER JOIN (
      SELECT DISTINCT $statsColumnId
      , $statsColumnName
      , $statsColumnColorShadeRed
      , $statsColumnColorShadeGreen
      , $statsColumnColorShadeBlue
      , $statsColumnIconValue
      , $statsColumnIsFavorite
      FROM $statsTable AS stat
      WHERE $statsColumnTimerStartTime = (
        SELECT MAX($statsColumnTimerStartTime)
        FROM $statsTable
        WHERE $statsColumnId = stat.$statsColumnId
      )
    ) AS tea
    ON tea.$statsColumnId = $statsTable.$statsColumnId
    GROUP BY $statsTable.$statsColumnId
    , tea.$statsColumnName
    , tea.$statsColumnColorShadeRed
    , tea.$statsColumnColorShadeGreen
    , tea.$statsColumnColorShadeBlue
    , tea.$statsColumnIconValue
    , tea.$statsColumnIsFavorite
    ORDER BY COUNT(*) DESC
    , tea.$statsColumnName ASC''';
  static const _mostUsedSQL =
      '''SELECT $statsTable.$statsColumnId
    , COUNT(*) AS count
    FROM $statsTable
    GROUP BY $statsTable.$statsColumnId
    ORDER BY COUNT(*) DESC''';
  static const _recentlyUsedSQL =
      '''SELECT $statsTable.$statsColumnId
    , MAX($statsTable.$statsColumnTimerStartTime) AS count
    FROM $statsTable
    GROUP BY $statsTable.$statsColumnId
    ORDER BY MAX($statsTable.$statsColumnTimerStartTime) DESC''';
}
