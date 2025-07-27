/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    prefs_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa Preferences page
// - Build prefs interface and interactivity

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/dialogs.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/list_tiles.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/common/separators.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/export.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/pages/about_page.dart';
import 'package:cuppa_mobile/pages/stats_page.dart';
import 'package:cuppa_mobile/widgets/page_header.dart';
import 'package:cuppa_mobile/widgets/tea_settings_list.dart';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transitioned_indexed_stack/transitioned_indexed_stack.dart';

// Cuppa Preferences page
class PrefsWidget extends StatefulWidget {
  const PrefsWidget({super.key, this.launchAddTea = false});

  final bool launchAddTea;

  @override
  State<PrefsWidget> createState() => _PrefsWidgetState();
}

class _PrefsWidgetState extends State<PrefsWidget> {
  // Navigation state
  int _navIndex = 0;
  bool _navInitial = true;
  bool _navSlideBack = false;

  // Build Prefs page
  @override
  Widget build(BuildContext context) {
    return Selector<AppProvider, bool>(
      selector: (_, provider) => provider.collectStats,
      builder: (context, collectStats, child) {
        // Determine layout based on device size
        bool layoutColumns = getDeviceSize(context).isLargeDevice;

        return Scaffold(
          appBar: PlatformAdaptiveNavBar(
            isPoppable: true,
            title: AppString.prefs_title.translate(),
            buttonTextDone: AppString.done_button.translate(),
            // Button to navigate to About page
            actionIcon: platformAboutIcon,
            actionRoute: const AboutWidget(),
            // Button to navigate to Stats page
            secondaryActionIcon: collectStats ? platformStatsIcon : null,
            secondaryActionRoute: collectStats ? const StatsWidget() : null,
          ),
          body: SafeArea(
            child: layoutColumns
                // Arrange Teas and Settings in two columns for large screens
                ? Row(
                    children: [
                      Expanded(
                        child: TeaSettingsList(
                          launchAddTea: widget.launchAddTea,
                        ),
                      ),
                      Expanded(child: _otherSettingsList),
                    ],
                  )
                // Use bottom nav bar with widget stack on small screens
                : SlideIndexedStack(
                    duration: shortAnimationDuration,
                    beginSlideOffset: _navInitial
                        // Do not transition on first build
                        ? Offset.zero
                        // Determine transition direction
                        : _navSlideBack
                        ? const Offset(-1, 0)
                        : const Offset(1, 0),
                    endSlideOffset: Offset.zero,
                    index: _navIndex,
                    children: [
                      TeaSettingsList(launchAddTea: widget.launchAddTea),
                      _otherSettingsList,
                    ],
                  ),
          ),
          bottomNavigationBar: layoutColumns
              ? null
              // Navigate between Teas and Settings
              : PlatformAdaptiveBottomNavBar(
                  currentIndex: _navIndex,
                  onTap: (index) => setState(() {
                    _navInitial = false;
                    _navSlideBack = index < _navIndex;
                    _navIndex = index;
                  }),
                  items: [
                    BottomNavigationBarItem(
                      icon: navBarTeasIcon,
                      label: AppString.teas_title.translate(),
                    ),
                    BottomNavigationBarItem(
                      icon: navBarSettingsIcon,
                      label: AppString.settings_title.translate(),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // List of other settings with pinned header
  Widget get _otherSettingsList => CustomScrollView(
    slivers: [
      pageHeader(context, title: AppString.settings_title.translate()),
      SliverToBoxAdapter(
        child: Padding(
          padding: columnPadding,
          child: Column(
            children: [
              // Setting: teacup style selection
              _cupStyleSetting,
              // Setting: app theme selection
              _appThemeSetting,
              // Setting: show extra info on buttons
              _selectExtraInfo,
              // Setting: stacked timer button view
              Selector<AppProvider, bool>(
                selector: (_, provider) =>
                    provider.teaCount > stackedViewTeaCount,
                builder: (context, showStackedView, child) {
                  return Visibility(
                    visible: showStackedView,
                    child: _stackedViewSetting,
                  );
                },
              ),
              // Setting: hide timer increment buttons
              _hideIncrementsSetting,
              listDivider,
              // Setting: use brew ratios
              _useBrewRatiosSetting,
              listDivider,
              // Setting: default to silent timer notifications
              _defaultSilentSetting,
              // Notification info
              _notificationLink,
              listDivider,
              // Setting: collect timer usage stats
              _collectStatsSetting,
              // Tools: export/import data
              _exportImportTools,
              listDivider,
              // Setting: app language selection
              _appLanguageSetting,
              // Setting: default to Celsius or Fahrenheit
              _useCelsiusSetting,
            ],
          ),
        ),
      ),
    ],
  );

  // Setting: collect timer usage stats
  Widget get _collectStatsSetting => settingSwitch(
    title: AppString.stats_enable.translate(),
    value: Provider.of<AppProvider>(context).collectStats,
    // Save collectStats setting to prefs
    onChanged: (bool newValue) async {
      AppProvider provider = Provider.of<AppProvider>(context, listen: false);

      // Show a prompt with more information
      if (await showConfirmDialog(
        context: context,
        body: Text(
          provider.collectStats
              ? AppString.stats_confirm_disable.translate()
              : AppString.stats_confirm_enable.translate(),
        ),
        bodyExtra: Text(AppString.confirm_continue.translate()),
        isDestructiveAction: provider.collectStats,
      )) {
        // Update setting
        provider.collectStats = newValue;

        // Clear usage data if collection gets disabled
        if (!provider.collectStats) {
          await Stats.clearStats();
        }
      }
    },
  );

  // Setting: use brew ratios
  Widget get _useBrewRatiosSetting => settingSwitch(
    title: AppString.prefs_use_brew_ratios.translate(),
    value: Provider.of<AppProvider>(context).useBrewRatios,
    // Save useBrewRatios setting to prefs
    onChanged: (bool newValue) {
      Provider.of<AppProvider>(context, listen: false).useBrewRatios = newValue;
    },
  );

  // Setting: show extra info on buttons
  Widget get _selectExtraInfo => Selector<AppProvider, bool>(
    selector: (_, provider) => provider.useBrewRatios,
    builder: (context, useBrewRatios, child) => settingChevron(
      title: useBrewRatios
          ? AppString.prefs_show_extra_ratios.translate()
          : AppString.prefs_show_extra.translate(),
      onTap: () => openPlatformAdaptiveSelectList(
        context: context,
        titleText: AppString.prefs_extra_select.translate(),
        buttonTextCancel: AppString.done_button.translate(),
        itemList: ExtraInfo.values
            .where((value) => value != ExtraInfo.brewRatio || useBrewRatios)
            .toList(),
        itemBuilder: _extraInfoItem,
        separatorBuilder: separatorDummy,
      ),
    ),
  );

  // Extra info option
  Widget _extraInfoItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    ExtraInfo value = ExtraInfo.values.elementAt(index);

    return Selector<AppProvider, bool>(
      selector: (_, provider) => provider.showExtraList.contains(value),
      builder: (context, isEnabled, child) => settingListCheckbox(
        context,
        // Extra info
        title: value.localizedName,
        value: isEnabled,
        // Save selection to prefs
        onChanged: (bool? newValue) {
          if (newValue == null) return;
          provider.toggleExtraInfo(value, newValue);
        },
      ),
    );
  }

  // Setting: hide timer increment buttons
  Widget get _hideIncrementsSetting => settingSwitch(
    title: AppString.prefs_hide_increments.translate(),
    subtitle: Provider.of<AppProvider>(context).hideIncrements
        ? AppString.prefs_hide_increments_info.translate()
        : null,
    value: Provider.of<AppProvider>(context).hideIncrements,
    // Save hideIncrements setting to prefs
    onChanged: (bool newValue) {
      Provider.of<AppProvider>(context, listen: false).hideIncrements =
          newValue;
    },
  );

  // Setting: default to silent timer notifications
  Widget get _defaultSilentSetting => Selector<AppProvider, bool>(
    selector: (_, provider) => provider.hideIncrements,
    builder: (context, hideIncrements, child) {
      return settingSwitch(
        title: AppString.prefs_silent_default.translate(),
        subtitle: hideIncrements
            ? AppString.prefs_silent_default_info.translate()
            : null,
        value: Provider.of<AppProvider>(context).silentDefault,
        // Save silentDefault setting to prefs
        onChanged: (bool newValue) {
          Provider.of<AppProvider>(context, listen: false).silentDefault =
              newValue;
        },
      );
    },
  );

  // Setting: stacked timer button view
  Widget get _stackedViewSetting => settingSwitch(
    title: AppString.prefs_stacked_view.translate(),
    value: Provider.of<AppProvider>(context).stackedView,
    // Save stackedView setting to prefs
    onChanged: (bool newValue) {
      Provider.of<AppProvider>(context, listen: false).stackedView = newValue;
    },
  );

  // Setting: default to Celsius or Fahrenheit
  Widget get _useCelsiusSetting => settingSwitch(
    title: AppString.prefs_use_celsius.translate(),
    value: Provider.of<AppProvider>(context).useCelsius,
    // Save useCelsius setting to prefs
    onChanged: (bool newValue) {
      Provider.of<AppProvider>(context, listen: false).useCelsius = newValue;
    },
  );

  // Setting: teacup style selection
  Widget get _cupStyleSetting => settingList(
    context,
    title: AppString.prefs_cup_style.translate(),
    selectedItem: Provider.of<AppProvider>(context).cupStyle.localizedName,
    selectedItemImage: Provider.of<AppProvider>(context).cupStyle.image,
    itemList: CupStyle.values,
    itemBuilder: _cupStyleItem,
  );

  // Teacup style option
  Widget _cupStyleItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    CupStyle value = CupStyle.values.elementAt(index);

    return settingListItem(
      context,
      // Cup style name
      title: value.localizedName,
      titleImage: value.image,
      value: value,
      groupValue: provider.cupStyle,
      // Save cupStyle to prefs
      onChanged: () {
        provider.cupStyle = value;
        Navigator.of(context).pop(true);
      },
    );
  }

  // Setting: app theme selection
  Widget get _appThemeSetting => settingList(
    context,
    title: AppString.prefs_app_theme.translate(),
    selectedItem: Provider.of<AppProvider>(context).appTheme.localizedName,
    itemList: AppTheme.values,
    itemBuilder: _appThemeItem,
  );

  // App theme option
  Widget _appThemeItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    AppTheme value = AppTheme.values.elementAt(index);

    return settingListItem(
      context,
      // Theme name
      title: value.localizedName,
      value: value,
      groupValue: provider.appTheme,
      // Save appTheme to prefs
      onChanged: () {
        provider.appTheme = value;
        Navigator.of(context).pop(true);
      },
    );
  }

  // Setting: app language selection
  Widget get _appLanguageSetting => settingList(
    context,
    title: AppString.prefs_language.translate(),
    selectedItem: languageLabel(Provider.of<AppProvider>(context).appLanguage),
    itemList: languageOptions.keys.toList(),
    itemBuilder: _appLanguageItem,
  );

  // App language option
  Widget _appLanguageItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    String value = languageOptions.keys.elementAt(index);

    return settingListItem(
      context,
      // Language name
      title: languageLabel(value),
      value: value,
      groupValue: provider.appLanguage,
      // Save appLanguage to prefs
      onChanged: () {
        provider.appLanguage = value;
        Navigator.of(context).pop(true);
      },
    );
  }

  // Tools: export/import data
  Widget get _exportImportTools => Align(
    alignment: Alignment.topLeft,
    child: Selector<AppProvider, bool>(
      selector: (_, provider) => provider.activeTeas.isNotEmpty,
      builder: (context, activeTeas, child) {
        return IgnorePointer(
          // Disable export/import while timer is active
          ignoring: activeTeas,
          child: Opacity(
            opacity: activeTeas ? fadeOpacity : noOpacity,
            child: ListTile(
              iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
              title: Text(
                AppString.export_import.translate(),
                style: textStyleTitle,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _exportButton,
                  const VerticalDivider(),
                  _importButton,
                ],
              ),
              contentPadding: listTilePadding,
              dense: true,
            ),
          ),
        );
      },
    ),
  );

  // Export button
  Widget get _exportButton => Builder(
    builder: (BuildContext context) {
      return IconButton(
        icon: platformExportIcon,
        onPressed: () {
          // Render location for share sheet on iPad
          RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          Rect sharePositionOrigin =
              (renderBox?.localToGlobal(Offset.zero) ?? Offset.zero) &
              (renderBox?.size ?? const Size(4, 4));

          // Attempt to save an export file and report if failed
          Export.create(
            Provider.of<AppProvider>(context, listen: false),
            share: true,
            sharePositionOrigin: sharePositionOrigin,
          ).then((exported) {
            if (!exported && context.mounted) {
              showInfoDialog(
                context: context,
                message: AppString.export_failure.translate(),
              );
            }
          });
        },
      );
    },
  );

  // Import button
  Widget get _importButton => IconButton(
    icon: platformImportIcon,
    onPressed: () async {
      // Show a prompt with more information
      if (await showConfirmDialog(
        context: context,
        body: Text(AppString.confirm_import.translate()),
        bodyExtra: Text(AppString.confirm_continue.translate()),
      )) {
        // Attempt to load an export file and report the result
        if (mounted) {
          await Export.load(
            Provider.of<AppProvider>(context, listen: false),
          ).then((imported) {
            if (mounted) {
              showInfoDialog(
                context: context,
                message: imported
                    ? AppString.import_sucess.translate()
                    : AppString.import_failure.translate(),
              );
            }
          });
        }
      }
    },
  );

  // Notification settings info text and link
  Widget get _notificationLink => InkWell(
    child: ListTile(
      minLeadingWidth: 30,
      leading: const SizedBox(height: double.infinity, child: infoIcon),
      horizontalTitleGap: 0,
      title: Text(
        AppString.prefs_notifications.translate(),
        style: textStyleSubtitle,
      ),
      trailing: const SizedBox(height: double.infinity, child: launchIcon),
      onTap: () =>
          AppSettings.openAppSettings(type: AppSettingsType.notification),
      contentPadding: listTilePadding,
      dense: true,
    ),
  );
}
