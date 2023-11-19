/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    stats.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Tea timer usage statistics and database functionality
// - Query enums

import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Stat entry definition
class Stat {
  // Fields
  late int id;
  late String name;
  late int brewTime;
  late int brewTemp;
  late int colorShadeRed;
  late int colorShadeGreen;
  late int colorShadeBlue;
  late int iconValue;
  late bool isFavorite;
  late int timerStartTime;
  late int count;

  // Constructor
  Stat({
    Tea? tea,
    int? id,
    String? name,
    int? brewTime,
    int? brewTemp,
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
    this.name = tea?.name ?? name ?? '';
    this.brewTime = tea?.brewTime ?? brewTime ?? 0;
    this.brewTemp = tea?.brewTemp ?? brewTemp ?? 0;
    this.colorShadeRed = tea?.getColor().red ?? colorShadeRed ?? 0;
    this.colorShadeGreen = tea?.getColor().green ?? colorShadeGreen ?? 0;
    this.colorShadeBlue = tea?.getColor().blue ?? colorShadeBlue ?? 0;
    this.iconValue = tea?.icon.value ?? iconValue ?? 0;
    this.isFavorite = tea?.isFavorite ?? isFavorite ?? false;
    this.timerStartTime =
        timerStartTime ?? DateTime.now().millisecondsSinceEpoch;
    this.count = count ?? 0;
  }

  // Getters
  Color get color {
    return Color.fromRGBO(
      colorShadeRed,
      colorShadeGreen,
      colorShadeBlue,
      1.0,
    );
  }

  // Convert a stat to a map for inserting
  Map<String, dynamic> toMap() {
    return {
      statsColumnId: this.id,
      statsColumnName: this.name,
      statsColumnBrewTime: this.brewTime,
      statsColumnBrewTemp: this.brewTemp,
      statsColumnColorShadeRed: this.colorShadeRed,
      statsColumnColorShadeGreen: this.colorShadeGreen,
      statsColumnColorShadeBlue: this.colorShadeBlue,
      statsColumnIconValue: this.iconValue,
      statsColumnIsFavorite: this.isFavorite ? 1 : 0,
      statsColumnTimerStartTime: this.timerStartTime,
    };
  }
}

// Stats methods
abstract class Stats {
  // Data management queries
  static const createSQL = '''CREATE TABLE $statsTable (
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
    )''';
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
      version: 1,
      onCreate: (Database db, _) async {
        await db.execute(createSQL);
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
  static Future<void> insertStat(Tea tea) async {
    final db = await statsData;

    // Insert a row into the stats table
    await db.insert(
      statsTable,
      Stat(tea: tea).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
        colorShadeRed:
            int.tryParse(results[i][statsColumnColorShadeRed].toString()),
        colorShadeGreen:
            int.tryParse(results[i][statsColumnColorShadeGreen].toString()),
        colorShadeBlue:
            int.tryParse(results[i][statsColumnColorShadeBlue].toString()),
        iconValue: int.tryParse(results[i][statsColumnIconValue].toString()),
        isFavorite:
            int.tryParse(results[i][statsColumnIsFavorite].toString()) == 1,
        timerStartTime:
            int.tryParse(results[i][statsColumnTimerStartTime].toString()),
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
  beginDateTime(0),
  totalCount(1),
  totalTime(2),
  starredCount(3);

  final int value;

  const MetricQuery(this.value);

  // Stats queries
  final beginDateTimeSQL = '''SELECT MIN($statsColumnTimerStartTime) AS metric
    FROM $statsTable''';
  final totalCountSQL = '''SELECT COUNT(*) AS metric
    FROM $statsTable''';
  final totalTimeSQL = '''SELECT SUM(IFNULL($statsColumnBrewTime, 0)) AS metric
    FROM $statsTable''';
  final starredCountSQL = '''SELECT COUNT(*) AS metric
    FROM $statsTable
    WHERE $statsColumnIsFavorite = 1''';

  // Query SQL
  get sql {
    switch (value) {
      case 1:
        return totalCountSQL;
      case 2:
        return totalTimeSQL;
      case 3:
        return starredCountSQL;
      default:
        return beginDateTimeSQL;
    }
  }
}

// String queries
enum StringQuery {
  morningTea(0),
  afternoonTea(1);

  final int value;

  const StringQuery(this.value);

  // Stats queries
  final morningTeaSQL = '''SELECT (
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
  final afternoonTeaSQL = '''SELECT (
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

  // Query SQL
  get sql {
    switch (value) {
      case 1:
        return afternoonTeaSQL;
      default:
        return morningTeaSQL;
    }
  }
}

// List queries
enum ListQuery {
  summaryStats(0);

  final int value;

  const ListQuery(this.value);

  // Stats queries
  final summaryStatsSQL = '''SELECT $statsTable.$statsColumnId
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
    ORDER BY COUNT(*) DESC''';

  // Query SQL
  get sql {
    switch (value) {
      default:
        return summaryStatsSQL;
    }
  }
}
