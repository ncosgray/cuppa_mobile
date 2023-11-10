/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    stats_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa stats page
// - Tea timer usage report

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'package:flutter/material.dart';

// Timer Stats page
class StatsWidget extends StatefulWidget {
  const StatsWidget({super.key});

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  // Timer data
  int beginDateTime = 0;
  int totalCount = 0;
  int starredCount = 0;
  int totalTime = 0;
  String morningTea = '';
  String afternoonTea = '';
  List<Stat> summaryStats = [];

  // Build Stats page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlatformAdaptiveNavBar(
        isPoppable: true,
        textScaleFactor: appTextScale,
        title: AppString.stats_title.translate(),
      ),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: _fetchTimerStats(),
          builder: (_, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              // Usage report
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    elevation: 1,
                    pinned: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
                    shadowColor: Theme.of(context).shadowColor,
                    automaticallyImplyLeading: false,
                    titleSpacing: 0.0,
                    title: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppString.stats_header.translate(),
                        style: textStyleHeader.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                      child: Column(
                        children: <Widget>[
                          // Summary stats
                          for (Stat stat in summaryStats)
                            stat.toWidget(totalCount: totalCount),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        // General metrics
                        child: IntrinsicHeight(
                          child: Card(
                            elevation: 1.0,
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              child: _metricsList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Progress indicator while fetching stats
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Fetch stats from database
  Future<bool> _fetchTimerStats() async {
    beginDateTime = await Stats.getMetric(MetricQuery.beginDateTime);
    totalCount = await Stats.getMetric(MetricQuery.totalCount);
    starredCount = await Stats.getMetric(MetricQuery.starredCount);
    totalTime = await Stats.getMetric(MetricQuery.totalTime);
    morningTea = await Stats.getString(StringQuery.morningTea);
    afternoonTea = await Stats.getString(StringQuery.afternoonTea);
    summaryStats = await Stats.getTeaStats(ListQuery.summaryStats);

    return true;
  }

  // Metrics list
  Widget _metricsList() {
    return Column(
      children: [
        Visibility(
          visible: beginDateTime > 0,
          child: _metricWidget(
            metricName: AppString.stats_begin.translate(),
            metric: formatDate(beginDateTime),
          ),
        ),
        _metricWidget(
          metricName: AppString.stats_timer_count.translate(),
          metric: totalCount.toString(),
        ),
        Visibility(
          visible: totalCount > 0,
          child: _metricWidget(
            metricName: AppString.stats_starred.translate(),
            metric: formatPercent(starredCount / totalCount),
          ),
        ),
        _metricWidget(
          metricName: AppString.stats_timer_time.translate(),
          metric: formatTimer(totalTime),
        ),
        Visibility(
          visible: morningTea.isNotEmpty,
          child: _metricWidget(
            metricName: AppString.stats_favorite_am.translate(),
            metric: morningTea,
          ),
        ),
        Visibility(
          visible: afternoonTea.isNotEmpty,
          child: _metricWidget(
            metricName: AppString.stats_favorite_pm.translate(),
            metric: afternoonTea,
          ),
        ),
      ],
    );
  }

  // Generate a metric list item widget
  static Widget _metricWidget({
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
              style: textStyleStatLabel,
            ),
          ),
          // Formatted metric value
          Text(
            metric,
            style: textStyleStat,
          ),
        ],
      ),
    );
  }
}
