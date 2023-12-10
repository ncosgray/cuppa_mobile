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
// - Stats display widgets

import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/mini_tea_button.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
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

  // Chart interaction
  int selectedSection = -1;

  // Build Stats page
  @override
  Widget build(BuildContext context) {
    // Determine layout and widget sizes based on device size
    bool layoutPortrait = getDeviceSize(context).isPortrait &&
        !getDeviceSize(context).isLargeDevice;
    double summaryWidth =
        (getDeviceSize(context).width / (layoutPortrait ? 1.0 : 2.0));
    double chartSize = layoutPortrait
        ? getDeviceSize(context).width * 0.6
        : min(
            getDeviceSize(context).width * 0.4,
            getDeviceSize(context).height * 0.4,
          );

    return Scaffold(
      appBar: PlatformAdaptiveNavBar(
        isPoppable: true,
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
                  // Report header
                  SliverAppBar(
                    elevation: 1,
                    pinned: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
                    shadowColor: Theme.of(context).shadowColor,
                    automaticallyImplyLeading: false,
                    titleSpacing: 0.0,
                    title: Container(
                      margin: headerPadding,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppString.stats_header.translate(),
                        style: textStyleHeader.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                    ),
                  ),
                  // Summary section
                  SliverToBoxAdapter(
                    child: Flex(
                      // Determine layout by device size
                      direction:
                          layoutPortrait ? Axis.vertical : Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary stats
                        Align(
                          alignment: Alignment.topLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: summaryWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                for (int i = 0; i < summaryStats.length; i++)
                                  _statWidget(
                                    stat: summaryStats[i],
                                    statIndex: i,
                                    maxWidth: summaryWidth,
                                    totalCount: totalCount,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Summary pie chart
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: _chart(chartSize: chartSize),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Metrics section
                  SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: Container(
                      margin: bodyPadding,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        // General metrics
                        child: IntrinsicHeight(
                          child: Card(
                            elevation: 1.0,
                            child: Container(
                              margin: largeDefaultPadding,
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

  // Generate a stat widget
  Widget _statWidget({
    required Stat stat,
    required int statIndex,
    required double maxWidth,
    int totalCount = 0,
    bool details = false,
  }) {
    String percent =
        totalCount > 0 ? '(${formatPercent(stat.count / totalCount)})' : '';
    bool fade = selectedSection > -1 && statIndex != selectedSection;

    return AnimatedOpacity(
      opacity: fade ? fadeOpacity : noOpacity,
      duration: shortAnimationDuration,
      child: Padding(
        padding: bodyPadding,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Tea icon button
                  Padding(
                    padding: rowPadding,
                    child: miniTeaButton(
                      color: stat.color,
                      icon: TeaIcon.values[stat.iconValue].getIcon(),
                    ),
                  ),
                  // Tea name
                  Padding(
                    padding: rowPadding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Text(
                        stat.name + (stat.isFavorite ? ' $starSymbol' : ''),
                        style: textStyleStat.copyWith(
                          color: stat.color,
                        ),
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
                          '${formatTimer(stat.brewTime)} @ ${formatTemp(stat.brewTemp)}',
                        ),
                      ),
                      // Tea timer usage
                      Visibility(
                        visible: stat.count > 0,
                        child: Row(
                          children: [
                            Padding(
                              padding: rowPadding,
                              child: Text(
                                '${stat.count}',
                                style: textStyleStat,
                              ),
                            ),
                            Text(
                              percent,
                              style: textStyleStatLabel,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Details: Timer start date and time
                  Visibility(
                    visible: details,
                    child:
                        Text(formatDate(stat.timerStartTime, dateTime: true)),
                  ),
                ],
              ),
            ],
          ),
          // Chart interactivity
          onTapDown: (_) => setState(() => selectedSection = statIndex),
          onTapUp: (_) => setState(() => selectedSection = -1),
          onTapCancel: () => setState(() => selectedSection = -1),
        ),
      ),
    );
  }

  // Build a pie chart
  Widget _chart({required double chartSize}) {
    return SizedBox(
      width: chartSize,
      height: chartSize,
      child: PieChart(
        PieChartData(
          sectionsSpace: 1.0,
          startDegreeOffset: 270.0,
          centerSpaceRadius: 0.0,
          // Chart sections
          sections: [
            for (int i = 0; i < summaryStats.length; i++)
              _chartSection(
                stat: summaryStats[i],
                radius: chartSize / 2.0,
                selected: i == selectedSection,
              ),
          ],
          // Chart interactivity
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  selectedSection = -1;
                  return;
                }
                selectedSection =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
        ),
      ),
    );
  }

  // Pie chart stat section
  PieChartSectionData _chartSection({
    required Stat stat,
    required double radius,
    bool selected = false,
  }) {
    return PieChartSectionData(
      value: stat.count.toDouble(),
      color: stat.color,
      radius: selected ? radius * 1.05 : radius,
      title: totalCount > 0 ? formatPercent(stat.count / totalCount) : null,
      titleStyle: textStyleSubtitle.copyWith(
        color: activeColor,
        fontWeight: selected ? FontWeight.bold : null,
      ),
      titlePositionPercentageOffset: 0.7,
    );
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
  Widget _metricWidget({
    required String metricName,
    required String metric,
  }) {
    double maxWidth = (getDeviceSize(context).width / 2.0) - 12.0;

    return Padding(
      padding: smallDefaultPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Metric name
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              metricName,
              style: textStyleStatLabel,
            ),
          ),
          // Formatted metric value
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              metric,
              style: textStyleStat,
            ),
          ),
        ],
      ),
    );
  }
}
