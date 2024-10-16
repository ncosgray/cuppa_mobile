/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    prefs_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

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
  const PrefsWidget({
    super.key,
    this.launchAddTea = false,
  });

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
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);

    // Determine layout based on device size
    bool layoutColumns = getDeviceSize(context).isLargeDevice;

    return Scaffold(
      appBar: PlatformAdaptiveNavBar(
        isPoppable: true,
        title: AppString.prefs_title.translate(),
        buttonTextDone: AppString.done_button.translate(),
        // Button to navigate to About page
        actionIcon: getPlatformAboutIcon(),
        actionRoute: const AboutWidget(),
        // Button to navigate to Stats page
        secondaryActionIcon:
            provider.collectStats ? getPlatformStatsIcon() : null,
        secondaryActionRoute:
            provider.collectStats ? const StatsWidget() : null,
      ),
      body: SafeArea(
        child: layoutColumns
            // Arrange Teas and Settings in two columns for large screens
            ? Row(
                children: [
                  Expanded(
                    child: TeaSettingsList(launchAddTea: widget.launchAddTea),
                  ),
                  Expanded(
                    child: _otherSettingsList(context),
                  ),
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
                        ? const Offset(-1.0, 0.0)
                        : const Offset(1.0, 0.0),
                endSlideOffset: Offset.zero,
                index: _navIndex,
                children: [
                  TeaSettingsList(launchAddTea: widget.launchAddTea),
                  _otherSettingsList(context),
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
  }

  // List of other settings with pinned header
  Widget _otherSettingsList(BuildContext context) {
    return CustomScrollView(
      slivers: [
        pageHeader(
          context,
          title: AppString.settings_title.translate(),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              // Setting: teacup style selection
              _cupStyleSetting(context),
              // Setting: app theme selection
              _appThemeSetting(context),
              // Setting: show extra info on buttons
              _showExtraSetting(context),
              // Setting: stacked timer button view
              Selector<AppProvider, bool>(
                selector: (_, provider) =>
                    provider.teaCount > stackedViewTeaCount,
                builder: (context, showStackedView, child) {
                  return Visibility(
                    visible: showStackedView,
                    child: _stackedViewSetting(context),
                  );
                },
              ),
              // Setting: hide timer increment buttons
              _hideIncrementsSetting(context),
              listDivider,
              // Setting: use brew ratios
              _useBrewRatiosSetting(context),
              listDivider,
              // Setting: default to silent timer notifications
              _defaultSilentSetting(context),
              // Notification info
              _notificationLink(),
              listDivider,
              // Setting: collect timer usage stats
              _collectStatsSetting(context),
              // Tools: export/import data
              _exportImportTools(context),
              listDivider,
              // Setting: app language selection
              _appLanguageSetting(context),
              // Setting: default to Celsius or Fahrenheit
              _useCelsiusSetting(context),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: smallSpacerWidget),
      ],
    );
  }

  // Setting: collect timer usage stats
  Widget _collectStatsSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return settingSwitch(
      context,
      title: AppString.stats_enable.translate(),
      value: provider.collectStats,
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
            Stats.clearStats();
          }
        }
      },
    );
  }

  // Setting: use brew ratios
  Widget _useBrewRatiosSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return settingSwitch(
      context,
      title: AppString.prefs_use_brew_ratios.translate(),
      value: provider.useBrewRatios,
      // Save useBrewRatios setting to prefs
      onChanged: (bool newValue) {
        provider.useBrewRatios = newValue;
      },
    );
  }

  // Setting: show extra info on buttons
  Widget _showExtraSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return settingSwitch(
      context,
      title: provider.useBrewRatios
          ? AppString.prefs_show_extra_ratios.translate()
          : AppString.prefs_show_extra.translate(),
      value: provider.showExtra,
      // Save showExtra setting to prefs
      onChanged: (bool newValue) {
        provider.showExtra = newValue;
      },
    );
  }

  // Setting: hide timer increment buttons
  Widget _hideIncrementsSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return settingSwitch(
      context,
      title: AppString.prefs_hide_increments.translate(),
      subtitle: provider.hideIncrements
          ? AppString.prefs_hide_increments_info.translate()
          : null,
      value: provider.hideIncrements,
      // Save hideIncrements setting to prefs
      onChanged: (bool newValue) {
        provider.hideIncrements = newValue;
      },
    );
  }

  // Setting: default to silent timer notifications
  Widget _defaultSilentSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return settingSwitch(
      context,
      title: AppString.prefs_silent_default.translate(),
      subtitle: provider.hideIncrements
          ? AppString.prefs_silent_default_info.translate()
          : null,
      value: provider.silentDefault,
      // Save silentDefault setting to prefs
      onChanged: (bool newValue) {
        provider.silentDefault = newValue;
      },
    );
  }

  // Setting: stacked timer button view
  Widget _stackedViewSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return settingSwitch(
      context,
      title: AppString.prefs_stacked_view.translate(),
      value: provider.stackedView,
      // Save stackedView setting to prefs
      onChanged: (bool newValue) {
        provider.stackedView = newValue;
      },
    );
  }

  // Setting: default to Celsius or Fahrenheit
  Widget _useCelsiusSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return settingSwitch(
      context,
      title: AppString.prefs_use_celsius.translate(),
      value: provider.useCelsius,
      // Save useCelsius setting to prefs
      onChanged: (bool newValue) {
        provider.useCelsius = newValue;
      },
    );
  }

  // Setting: teacup style selection
  Widget _cupStyleSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return settingList(
      context,
      title: AppString.prefs_cup_style.translate(),
      selectedItem: provider.cupStyle.localizedName,
      selectedItemImage: provider.cupStyle.image,
      itemList: CupStyle.values,
      itemBuilder: _cupStyleItem,
    );
  }

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
  Widget _appThemeSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return settingList(
      context,
      title: AppString.prefs_app_theme.translate(),
      selectedItem: provider.appTheme.localizedName,
      itemList: AppTheme.values,
      itemBuilder: _appThemeItem,
    );
  }

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
  Widget _appLanguageSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return settingList(
      context,
      title: AppString.prefs_language.translate(),
      selectedItem: provider.appLanguage == followSystemLanguage
          ? AppString.theme_system.translate()
          : languageOptions[provider.appLanguage] ?? provider.appLanguage,
      itemList: languageOptions.keys.toList(),
      itemBuilder: _appLanguageItem,
    );
  }

  // App language option
  Widget _appLanguageItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    String value = languageOptions.keys.elementAt(index);

    return settingListItem(
      context,
      // Language name
      title: value == followSystemLanguage
          ? AppString.theme_system.translate()
          : languageOptions[value] ?? value,
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
  Widget _exportImportTools(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return Align(
      alignment: Alignment.topLeft,
      child: IgnorePointer(
        // Disable export/import while timer is active
        ignoring: provider.activeTeas.isNotEmpty,
        child: Opacity(
          opacity: provider.activeTeas.isNotEmpty ? fadeOpacity : noOpacity,
          child: ListTile(
            iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
            title: Text(
              AppString.export_import.translate(),
              style: textStyleTitle,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _exportButton(context),
                const VerticalDivider(),
                _importButton(context),
              ],
            ),
            contentPadding: listTilePadding,
            dense: true,
          ),
        ),
      ),
    );
  }

  // Export button
  Widget _exportButton(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: exportIcon,
          onPressed: () {
            // Render location for share sheet on iPad
            RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            Rect sharePositionOrigin =
                (renderBox?.localToGlobal(Offset.zero) ?? Offset.zero) &
                    (renderBox?.size ?? const Size(4.0, 4.0));

            // Attempt to save an export file and report if failed
            Export.create(
              provider,
              share: true,
              sharePositionOrigin: sharePositionOrigin,
            ).then(
              (exported) {
                if (!exported && context.mounted) {
                  showInfoDialog(
                    context: context,
                    message: AppString.export_failure.translate(),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // Import button
  Widget _importButton(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return IconButton(
      icon: importIcon,
      onPressed: () async {
        // Show a prompt with more information
        if (await showConfirmDialog(
          context: context,
          body: Text(AppString.confirm_import.translate()),
          bodyExtra: Text(AppString.confirm_continue.translate()),
        )) {
          // Attempt to load an export file and report the result
          Export.load(provider).then(
            (imported) {
              if (context.mounted) {
                showInfoDialog(
                  context: context,
                  message: imported
                      ? AppString.import_sucess.translate()
                      : AppString.import_failure.translate(),
                );
              }
            },
          );
        }
      },
    );
  }

  // Notification settings info text and link
  Widget _notificationLink() {
    return InkWell(
      child: ListTile(
        minLeadingWidth: 30.0,
        leading: const SizedBox(
          height: double.infinity,
          child: infoIcon,
        ),
        horizontalTitleGap: 0.0,
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
}
