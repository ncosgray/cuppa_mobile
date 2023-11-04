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
// - Stats display widgets

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/common.dart';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Stats methods
abstract class Stats {
  static Database? _statsData;

  // Stats database getter
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
        await db.execute(statsCreateSQL);
      },
    );
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
  static Future<List<Stat>> getTeaStats({String? sql}) async {
    final db = await statsData;

    // Query the stats table
    List<Map<String, dynamic>> results;
    if (sql == null) {
      // Get all stats
      results = await db.query(statsTable);
    } else {
      // Get stats from query
      results = await db.rawQuery(sql);
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
            (int.tryParse(results[i][statsColumnIsFavorite].toString())) == 1
                ? true
                : false,
        timerStartTime:
            int.tryParse(results[i][statsColumnTimerStartTime].toString()),
        count: int.tryParse(results[i][statsColumnCount].toString()),
      );
    });
  }

  // Retrieve a single numeric value from the stats database
  static Future<int> getMetric({required String sql}) async {
    int? metric;
    final db = await statsData;

    // Query the stats table
    var result = await db.rawQuery(sql);
    if (result.isNotEmpty) {
      metric = int.tryParse(result[0][statsColumnMetric].toString());
    }
    return metric ?? 0;
  }

  // Retrieve a string value from the stats database
  static Future<String> getString({required String sql}) async {
    String metric = '';
    final db = await statsData;

    // Query the stats table
    var result = await db.rawQuery(sql);
    if (result.isNotEmpty) {
      metric = result[0][statsColumnString].toString();
    }
    return metric;
  }

  // Generate a metric widget
  static Widget metricWidget({
    required String metricName,
    required String metric,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Metric name
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Text(
              metricName,
            ),
          ),
          // Formatted metric value
          Text(
            metric,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

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
  late int isFavorite;
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
    this.isFavorite = (tea?.isFavorite ?? isFavorite ?? false) ? 1 : 0;
    this.timerStartTime =
        timerStartTime ?? DateTime.now().millisecondsSinceEpoch;
    this.count = count ?? 0;
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
      statsColumnIsFavorite: this.isFavorite,
      statsColumnTimerStartTime: this.timerStartTime,
    };
  }

  // Generate a stat widget
  Widget toWidget({
    bool details = false,
    int totalCount = 0,
  }) {
    Color color = Color.fromRGBO(
      colorShadeRed,
      colorShadeGreen,
      colorShadeBlue,
      1.0,
    );
    String percent =
        totalCount > 0 ? '(${formatPercent(count / totalCount)})' : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Tea icon button
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: miniTeaButton(
                  color: color,
                  icon: TeaIcon.values[iconValue].getIcon(),
                ),
              ),
              // Tea name
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Text(
                  this.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Details: Brew time and temperature
                  Visibility(
                    visible: details,
                    child: Text(
                      '${formatTimer(brewTime)} @ ${formatTemp(brewTemp)}',
                    ),
                  ),
                  // Tea timer usage
                  Visibility(
                    visible: count > 0,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          percent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Details: Timer start date and time
              Visibility(
                visible: details,
                child: Text(formatDate(timerStartTime, dateTime: true)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
