/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_settings_list.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea settings list
// - Tea settings cards
// - Sort, add, and remove all buttons

import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/dialogs.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/common/separators.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/presets.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/page_header.dart';
import 'package:cuppa_mobile/widgets/tea_settings_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

// MultiSliver containing a tea settings list
class TeaSettingsList extends StatefulWidget {
  const TeaSettingsList({super.key, this.launchAddTea = false});

  final bool launchAddTea;

  @override
  State<TeaSettingsList> createState() => _TeaSettingsListState();
}

class _TeaSettingsListState extends State<TeaSettingsList> {
  // State variables
  final ScrollController _scrollController = ScrollController();
  bool _scrollToEnd = false;
  bool _animateTeaList = false;
  late bool _launchAddTea;

  // Initialize widget state
  @override
  void initState() {
    super.initState();

    _launchAddTea = widget.launchAddTea;
  }

  // Build tea settings list
  @override
  Widget build(BuildContext context) {
    int teaCount = Provider.of<AppProvider>(context, listen: false).teaCount;

    Future.delayed(Duration.zero, () {
      // Process request to show Add Tea dialog
      if (_launchAddTea && teaCount < teasMaxCount) {
        _openAddTeaDialog();
      }
      _launchAddTea = false;

      // Process request to scroll to end of tea list
      if (_scrollToEnd && _scrollController.hasClients) {
        Future.delayed(longAnimationDuration).then((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: shortAnimationDuration,
            curve: Curves.fastOutSlowIn,
          );
        });
      }
      _scrollToEnd = false;
    });

    return Selector<AppProvider, ({bool activeTeas})>(
      selector: (_, provider) => (activeTeas: provider.activeTeas.isNotEmpty),
      builder: (context, teaData, child) => CustomScrollView(
        controller: _scrollController,
        cacheExtent: teasMaxCount * 48,
        slivers: [
          // Teas section header
          pageHeader(
            context,
            title: AppString.teas_title.translate(),
            // Add Tea and Sort Teas action buttons
            actions: [
              teaCount < teasMaxCount ? _addTeaAction : const SizedBox.shrink(),
              teaCount > 0 ? _sortTeasAction : const SizedBox.shrink(),
            ],
          ),
          // Tea settings info text
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: bodyPadding,
                child: Text(
                  AppString.prefs_header.translate(),
                  style: textStyleSubtitle,
                ),
              ),
            ),
          ),
          // Tea settings cards
          SliverAnimatedPaintExtent(
            duration: longAnimationDuration,
            child: _teaSettingsList(),
          ),
          // Add Tea and Remove All buttons
          SliverToBoxAdapter(
            child: Container(
              margin: bottomSliverPadding,
              child: Row(
                spacing: smallSpacing,
                children: [
                  Expanded(child: _addTeaButton),
                  (teaCount > 0 && !teaData.activeTeas)
                      ? _removeAllButton
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add Tea action
  Widget get _addTeaAction =>
      IconButton(icon: Icon(Icons.add), onPressed: () => _openAddTeaDialog());

  // Sort Teas action
  Widget get _sortTeasAction => Selector<AppProvider, bool>(
    selector: (_, provider) => provider.collectStats,
    builder: (context, collectStats, child) => IconButton(
      icon: platformSortIcon,
      onPressed: () => openPlatformAdaptiveSelectList(
        context: context,
        titleText: AppString.sort_title.translate(),
        buttonTextCancel: AppString.cancel_button.translate(),
        // Don't offer to sort with stats data unless stats are available
        itemList: SortBy.values
            .where((item) => collectStats || !item.statsRequired)
            .toList(),
        itemBuilder: _sortByOption,
        separatorBuilder: separatorDummy,
      ),
    ),
  );

  // Sort by option
  Widget _sortByOption(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    SortBy value = SortBy.values.elementAt(index);

    return adaptiveSelectListAction(
      action: ListTile(
        dense: true,
        // Sorting type
        title: Text(value.localizedName, style: textStyleTitle),
      ),
      onTap: () {
        // Apply new sorting and animate the tea settings list
        _animateTeaList = true;
        provider.sortTeas(sortBy: value);
        Navigator.of(context).pop(true);
      },
    );
  }

  // Reorderable list of tea settings cards
  Widget _teaSettingsList() {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);

    // Reset animate flag after a delay
    if (_animateTeaList) {
      Future.delayed(longAnimationDuration, () {
        setState(() => _animateTeaList = false);
      });
    }

    return SliverReorderableList(
      itemBuilder: _animateTeaList ? separatorDummy : _teaSettingsListItem,
      itemCount: _animateTeaList ? 0 : provider.teaCount,
      prototypeItem: _animateTeaList ? null : TeaSettingsCard(tea: dummyTea),
      proxyDecorator: _draggableFeedback,
      onReorderStart: (_) => HapticFeedback.heavyImpact(),
      onReorder: (int oldIndex, int newIndex) {
        // Reorder the tea list
        provider.reorderTeas(oldIndex, newIndex);
      },
    );
  }

  // Custom draggable feedback for reorderable list
  Widget _draggableFeedback(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: <BoxShadow>[BoxShadow(color: shadowColor, blurRadius: 14)],
      ),
      child: child,
    );
  }

  // Tea settings list item
  Widget _teaSettingsListItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    Tea tea = provider.teaList[index];

    return ReorderableDelayedDragStartListener(
      key: Key('reorder${tea.name}${tea.id}'),
      index: index,
      child: tea.isActive
          ?
            // Don't allow deleting if timer is active
            TeaSettingsCard(tea: tea)
          :
            // Deleteable
            Dismissible(
              key: Key('dismiss${tea.name}${tea.id}'),
              onDismissed: (direction) {
                // Provide an undo option
                int? teaIndex = provider.teaList.indexWhere(
                  (item) => item.id == tea.id,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 1500),
                    content: Text(
                      AppString.undo_message.translate(teaName: tea.name),
                    ),
                    action: SnackBarAction(
                      label: AppString.undo_button.translate(),
                      // Re-add deleted tea in its former position
                      onPressed: () => provider.addTea(tea, atIndex: teaIndex),
                    ),
                  ),
                );

                // Delete this from the tea list
                provider.deleteTea(tea);
              },
              // Dismissible delete warning background
              background: _dismissibleBackground(context, Alignment.centerLeft),
              secondaryBackground: _dismissibleBackground(
                context,
                Alignment.centerRight,
              ),
              resizeDuration: longAnimationDuration,
              child: TeaSettingsCard(tea: tea),
            ),
    );
  }

  // Dismissible delete warning background
  Widget _dismissibleBackground(BuildContext context, Alignment alignment) {
    return Container(
      color: Theme.of(context).colorScheme.error,
      margin: bodyPadding,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Align(
          alignment: alignment,
          child: getPlatformRemoveIcon(Theme.of(context).colorScheme.onError),
        ),
      ),
    );
  }

  // Add tea button
  Widget get _addTeaButton => Selector<AppProvider, bool>(
    selector: (_, provider) => provider.teaCount < teasMaxCount,
    builder: (context, maxNotReached, child) => SizedBox(
      height: 48,
      child: Card(
        margin: noPadding,
        shadowColor: Colors.transparent,
        surfaceTintColor: Theme.of(context).colorScheme.primary,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          child: TextButton.icon(
            label: Text(
              AppString.add_tea_button.translate(),
              style: textStyleButtonSecondary,
            ),
            icon: addIcon,
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
            // Disable adding teas if there are maximum teas
            onPressed: maxNotReached ? () => _openAddTeaDialog() : null,
          ),
        ),
      ),
    ),
  );

  // Open Add Tea dialog
  void _openAddTeaDialog() {
    openPlatformAdaptiveSelectList(
      context: context,
      titleText: AppString.add_tea_button.translate(),
      buttonTextCancel: AppString.cancel_button.translate(),
      itemList: Presets.presetList,
      itemBuilder: _teaPresetItem,
      separatorBuilder: separatorBuilder,
    );
  }

  // Tea preset option
  Widget _teaPresetItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    Preset preset = Presets.presetList[index];
    Color presetColor = preset.getColor();

    return adaptiveSelectListAction(
      action: ListTile(
        contentPadding: noPadding,
        // Preset tea icon
        leading: SizedBox.square(
          dimension: 48,
          child: preset.isCustom
              ? customPresetIcon(color: presetColor)
              : Icon(preset.getIcon(), color: presetColor, size: 24),
        ),
        // Preset tea brew time, temperature, and ratio
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              preset.localizedName,
              style: textStyleSetting.copyWith(color: presetColor),
            ),
            Container(
              child: preset.isCustom
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: largeSpacing,
                      children: [
                        Text(
                          formatTimer(preset.brewTime),
                          style: textStyleSettingNumber.copyWith(
                            color: presetColor,
                          ),
                        ),
                        Visibility(
                          visible: preset.brewTempDegreesC > roomTemp,
                          child: Text(
                            preset.tempDisplay(provider.useCelsius),
                            style: textStyleSettingNumber.copyWith(
                              color: presetColor,
                            ),
                          ),
                        ),
                        Text(
                          preset.ratioDisplay(provider.useCelsius),
                          style: textStyleSettingNumber.copyWith(
                            color: presetColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      // Add selected tea
      onTap: () {
        provider.addTea(preset.createTea(useCelsius: provider.useCelsius));
        _scrollToEnd = true;
        Navigator.of(context).pop(true);
      },
    );
  }

  // Remove all teas button
  Widget get _removeAllButton => SizedBox(
    width: 48,
    height: 48,
    child: Card(
      margin: noPadding,
      shadowColor: Colors.transparent,
      surfaceTintColor: Theme.of(context).colorScheme.error,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        child: getPlatformRemoveAllIcon(Theme.of(context).colorScheme.error),
        onTap: () async {
          AppProvider provider = Provider.of<AppProvider>(
            context,
            listen: false,
          );
          if (await showConfirmDialog(
            context: context,
            body: Text(AppString.confirm_delete.translate()),
          )) {
            // Clear tea list
            provider.clearTeaList();
          }
        },
      ),
    ),
  );
}
