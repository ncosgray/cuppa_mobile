/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    stats_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

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
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/mini_tea_button.dart';

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Timer Stats page
class StatsWidget extends StatefulWidget {
  const StatsWidget({super.key});

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  // Timer data
  int _beginDateTime = 0;
  int _totalCount = 0;
  int _starredCount = 0;
  int _totalTime = 0;
  double _totalAmountG = 0;
  double _totalAmountTsp = 0;
  String _morningTea = '';
  String _afternoonTea = '';
  List<Stat> _summaryStats = [];

  // Chart interaction
  bool _includeDeleted = false;
  int _selectedSection = -1;
  bool _altMetrics = false;

  // Build Stats page
  @override
  Widget build(BuildContext context) {
    // Determine layout and widget sizes based on device size
    bool layoutPortrait =
        getDeviceSize(context).isPortrait &&
        !getDeviceSize(context).isLargeDevice;
    double summaryWidth =
        (getDeviceSize(context).width / (layoutPortrait ? 1.0 : 2.0));
    double chartSize = layoutPortrait
        ? getDeviceSize(context).width * 0.6
        : min(
            getDeviceSize(context).width * 0.4,
            getDeviceSize(context).height * 0.4,
          );

    return adaptiveScaffold(
      appBar: PlatformAdaptiveNavBar(
        isPoppable: true,
        title: AppString.stats_title.translate(),
        buttonTextDone: AppString.done_button.translate(),
        previousPageTitle: AppString.prefs_title.translate(),
      ),
      body: FutureBuilder<bool>(
        future: _fetchTimerStats(),
        builder: (_, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return CustomScrollView(
              slivers: _filteredSummaryStats.isEmpty
                  // No data to show
                  ? [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: bodyPadding,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppString.stats_no_data_1.translate(),
                                style: textStyleHeader,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                AppString.stats_no_data_2.translate(),
                                style: textStyleSubtitle,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                  // Usage report
                  : [
                      // Summary section
                      SliverToBoxAdapter(
                        child: SafeArea(
                          top: false,
                          bottom: false,
                          child: Padding(
                            padding: EdgeInsetsGeometry.only(top: largeSpacing),
                            child: Flex(
                              // Determine layout by device size
                              direction: layoutPortrait
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Summary stats
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: summaryWidth,
                                    ),
                                    child: AnimatedSize(
                                      duration: longAnimationDuration,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          ..._filteredSummaryStats.map<Widget>(
                                            (Stat stat) => _statWidget(
                                              stat: stat,
                                              statIndex: _summaryStats.indexOf(
                                                stat,
                                              ),
                                              maxWidth: summaryWidth,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    // Summary pie chart
                                    Visibility(
                                      visible: _filteredSummaryStats.isNotEmpty,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: _chart(chartSize: chartSize),
                                        ),
                                      ),
                                    ),
                                    // Chart option: Include deleted teas
                                    Visibility(
                                      visible:
                                          _includeDeleted ||
                                          _totalCount != _filteredTotalCount,
                                      child: Padding(
                                        padding: smallDefaultPadding,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: chartSize,
                                              ),
                                              child: Text(
                                                AppString.stats_include_deleted
                                                    .translate(),
                                                textAlign: TextAlign.end,
                                                style: textStyleSettingTertiary,
                                              ),
                                            ),
                                            Checkbox.adaptive(
                                              value: _includeDeleted,
                                              onChanged: (newValue) => setState(
                                                () => _includeDeleted =
                                                    newValue ?? false,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Metrics section
                      SliverFillRemaining(
                        hasScrollBody: false,
                        fillOverscroll: true,
                        child: SafeArea(
                          top: false,
                          child: Container(
                            margin: bottomSliverPadding,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              // General metrics
                              child: IntrinsicHeight(
                                child: Card(
                                  elevation: 1,
                                  child: Container(
                                    margin: largeDefaultPadding,
                                    child: _metricsList(),
                                  ),
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
                children: [CircularProgressIndicator()],
              ),
            );
          }
        },
      ),
    );
  }

  // Fetch stats from database
  Future<bool> _fetchTimerStats() async {
    _beginDateTime = await Stats.getMetric(MetricQuery.beginDateTime);
    _totalCount = await Stats.getMetric(MetricQuery.totalCount);
    _starredCount = await Stats.getMetric(MetricQuery.starredCount);
    _totalTime = await Stats.getMetric(MetricQuery.totalTime);
    _morningTea = await Stats.getString(StringQuery.morningTea);
    _afternoonTea = await Stats.getString(StringQuery.afternoonTea);
    _summaryStats = await Stats.getTeaStats(ListQuery.summaryStats);
    _totalAmountG = await Stats.getDecimal(DecimalQuery.totalAmountG);
    _totalAmountTsp = await Stats.getDecimal(DecimalQuery.totalAmountTsp);

    return true;
  }

  // Concatenate total amounts for each unit
  String get _totalAmount {
    String totalAmount = '';
    totalAmount = _totalAmountG > 0.0
        ? formatNumeratorAmount(
            _totalAmountG,
            useMetric: true,
            inLargeUnits: !_altMetrics,
          )
        : '';
    if (_totalAmountG > 0.0 && _totalAmountTsp > 0.0) {
      totalAmount += ' + ';
    }
    totalAmount += _totalAmountTsp > 0.0
        ? formatNumeratorAmount(
            _totalAmountTsp,
            useMetric: false,
            inLargeUnits: !_altMetrics,
          )
        : '';

    return totalAmount;
  }

  // Apply deleted teas filter to stats
  Iterable<Stat> get _filteredSummaryStats {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);

    return _summaryStats.where(
      (stat) =>
          _includeDeleted || provider.teaList.any((tea) => tea.id == stat.id),
    );
  }

  int get _filteredTotalCount {
    return _filteredSummaryStats.fold<int>(
      0,
      (total, stat) => total + stat.count,
    );
  }

  // Toggle alternative metrics display
  void _toggleAltMetrics() {
    setState(() => _altMetrics = !_altMetrics);
  }

  // Generate a stat widget
  Widget _statWidget({
    required Stat stat,
    required int statIndex,
    required double maxWidth,
  }) {
    String percent = _filteredTotalCount > 0
        ? '(${AppLocalizations.numberString(stat.count / _filteredTotalCount, asPercentage: true)})'
        : '';
    bool fade = _selectedSection > -1 && statIndex != _selectedSection;

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
                      constraints: BoxConstraints(maxWidth: maxWidth / 1.8),
                      child: Text(
                        stat.name + (stat.isFavorite ? ' $starSymbol' : ''),
                        style: textStyleStat.copyWith(color: stat.color),
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
                            Text(percent, style: textStyleStatLabel),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Chart interactivity
          onTapDown: (_) => setState(() => _selectedSection = statIndex),
          onTapUp: (_) => setState(() => _selectedSection = -1),
          onTapCancel: () => setState(() => _selectedSection = -1),
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
          sectionsSpace: 1,
          startDegreeOffset: 270,
          centerSpaceRadius: 0,
          // Chart sections
          sections: [
            ..._filteredSummaryStats.map<PieChartSectionData>(
              (Stat stat) => _chartSection(
                stat: stat,
                radius: chartSize / 2.0,
                selected: _summaryStats.indexOf(stat) == _selectedSection,
              ),
            ),
          ],
          // Chart interactivity
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  _selectedSection = -1;
                  return;
                }
                _selectedSection =
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
    double percent = _filteredTotalCount > 0
        ? stat.count / _filteredTotalCount
        : 0.0;

    return PieChartSectionData(
      value: stat.count.toDouble(),
      color: stat.color,
      radius: selected ? radius * 1.05 : radius,
      showTitle: percent > 0.05,
      title: AppLocalizations.numberString(percent, asPercentage: true),
      titleStyle: textStyleSubtitle.copyWith(
        color: chartTextColor,
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
          visible: _beginDateTime > 0,
          child: _metricWidget(
            metricName: AppString.stats_begin.translate(),
            metric: AppLocalizations.dateString(_beginDateTime),
          ),
        ),
        _metricWidget(
          metricName: AppString.stats_timer_count.translate(),
          metric: _totalCount.toString(),
        ),
        Visibility(
          visible: _totalCount > 0,
          child: _metricWidget(
            metricName: AppString.stats_starred.translate(),
            metric: AppLocalizations.numberString(
              _starredCount / _totalCount,
              asPercentage: true,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleAltMetrics,
          child: _metricWidget(
            metricName: AppString.stats_timer_time.translate(),
            metric: formatTimer(_totalTime, inDays: !_altMetrics),
          ),
        ),
        Visibility(
          visible:
              Provider.of<AppProvider>(context, listen: false).useBrewRatios &&
              _totalAmount.isNotEmpty,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleAltMetrics,
            child: _metricWidget(
              metricName: AppString.stats_tea_amount.translate(),
              metric: _totalAmount,
            ),
          ),
        ),
        Visibility(
          visible: _morningTea.isNotEmpty,
          child: _metricWidget(
            metricName: AppString.stats_favorite_am.translate(),
            metric: _morningTea,
          ),
        ),
        Visibility(
          visible: _afternoonTea.isNotEmpty,
          child: _metricWidget(
            metricName: AppString.stats_favorite_pm.translate(),
            metric: _afternoonTea,
          ),
        ),
      ],
    );
  }

  // Generate a metric list item widget
  Widget _metricWidget({required String metricName, required String metric}) {
    double maxWidth = (getDeviceSize(context).width / 2.0) - 24.0;

    return Padding(
      padding: smallDefaultPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Metric name
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(metricName, style: textStyleStatLabel),
          ),
          // Formatted metric value
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(metric, style: textStyleStat),
          ),
        ],
      ),
    );
  }
}
