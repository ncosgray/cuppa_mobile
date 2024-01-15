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

import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/dialogs.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/presets.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/about_page.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/stats_page.dart';
import 'package:cuppa_mobile/widgets/tea_settings_card.dart';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Cuppa Preferences page
class PrefsWidget extends StatelessWidget {
  const PrefsWidget({super.key});

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
        child: Row(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Teas section header
                  _prefsHeader(context, AppString.teas_title.translate()),
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
                      margin: bodyPadding,
                      child: Row(
                        children: [
                          Expanded(child: _addTeaButton()),
                          smallSpacerWidget,
                          _removeAllButton(context),
                        ],
                      ),
                    ),
                  ),
                  // Other settings inline
                  SliverToBoxAdapter(
                    child: Visibility(
                      visible: !layoutColumns,
                      child: _otherSettingsList(context),
                    ),
                  ),
                ],
              ),
            ),
            // Other settings in second column with header
            Visibility(
              visible: layoutColumns,
              child: Expanded(
                child: CustomScrollView(
                  slivers: [
                    _prefsHeader(
                      context,
                      AppString.settings_title.translate(),
                    ),
                    SliverToBoxAdapter(child: _otherSettingsList(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Prefs page column header
  Widget _prefsHeader(BuildContext context, String title) {
    return SliverAppBar(
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
          title,
          style: textStyleHeader.copyWith(
            color: Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
      ),
    );
  }

  // Reoderable list of tea settings cards
  Widget _teaSettingsList() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) => SliverReorderableList(
        itemBuilder: _teaSettingsListItem,
        itemCount: provider.teaList.length,
        proxyDecorator: _draggableFeedback,
        onReorder: (int oldIndex, int newIndex) {
          // Reorder the tea list
          provider.reorderTeas(oldIndex, newIndex);
        },
      ),
    );
  }

  // Custom draggable feedback for reorderable list
  Widget _draggableFeedback(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shadowColor,
            blurRadius: 14.0,
          ),
        ],
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
          TeaSettingsCard(
              tea: tea,
            )
          :
          // Deleteable
          Dismissible(
              key: Key('dismiss${tea.name}${tea.id}'),
              onDismissed: (direction) {
                // Provide an undo option
                int? teaIndex =
                    provider.teaList.indexWhere((item) => item.id == tea.id);
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
              secondaryBackground:
                  _dismissibleBackground(context, Alignment.centerRight),
              resizeDuration: longAnimationDuration,
              child: TeaSettingsCard(
                tea: tea,
              ),
            ),
    );
  }

  // Dismissible delete warning background
  Widget _dismissibleBackground(BuildContext context, Alignment alignment) {
    return Container(
      color: Theme.of(context).colorScheme.error,
      margin: bodyPadding,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Align(
          alignment: alignment,
          child: getPlatformRemoveIcon(
            Theme.of(context).colorScheme.onError,
          ),
        ),
      ),
    );
  }

  // Add tea button
  Widget _addTeaButton() {
    return Selector<AppProvider, int>(
      selector: (_, provider) => provider.teaCount,
      builder: (context, count, child) => SizedBox(
        height: 64.0,
        child: Card(
          margin: noPadding,
          shadowColor: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            child: TextButton.icon(
              label: Text(
                AppString.add_tea_button.translate(),
                style: textStyleButton,
              ),
              icon: addIcon,
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              // Disable adding teas if there are maximum teas
              onPressed: count < teasMaxCount
                  ? () => openPlatformAdaptiveSelectList(
                        context: context,
                        titleText: AppString.add_tea_button.translate(),
                        buttonTextCancel: AppString.cancel_button.translate(),
                        itemList: Presets.presetList,
                        itemBuilder: _teaPresetItem,
                        separatorBuilder: _separatorBuilder,
                      )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  // Tea preset option
  Widget _teaPresetItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    Preset preset = Presets.presetList[index];
    Color presetColor = preset.getColor();

    return ListTile(
      contentPadding: noPadding,
      // Preset tea icon
      leading: SizedBox.square(
        dimension: 48.0,
        child: preset.isCustom
            ? customPresetIcon(color: presetColor)
            : Icon(
                preset.getIcon(),
                color: presetColor,
                size: 24.0,
              ),
      ),
      // Preset tea brew time and temperature
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            preset.localizedName,
            style: textStyleSetting.copyWith(
              color: presetColor,
            ),
          ),
          Container(
            child: preset.isCustom
                ? null
                : Row(
                    children: [
                      Text(
                        formatTimer(preset.brewTime),
                        style: textStyleSettingSeconday.copyWith(
                          color: presetColor,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 6.0,
                          maxWidth: 30.0,
                        ),
                        child: Container(),
                      ),
                      Text(
                        preset.tempDisplay(provider.useCelsius),
                        style: textStyleSettingSeconday.copyWith(
                          color: presetColor,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                        ),
                        child: Container(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      // Add selected tea
      onTap: () {
        provider.addTea(preset.createTea(useCelsius: provider.useCelsius));
        Navigator.of(context).pop(true);
      },
    );
  }

  // Remove all teas button
  Widget _removeAllButton(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return (provider.teaCount > 0 && provider.activeTeas.isEmpty)
        ? SizedBox(
            width: 64.0,
            height: 64.0,
            child: Card(
              margin: noPadding,
              shadowColor: Colors.transparent,
              surfaceTintColor: Theme.of(context).colorScheme.error,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                child: getPlatformRemoveAllIcon(
                  Theme.of(context).colorScheme.error,
                ),
                onTap: () async {
                  AppProvider provider =
                      Provider.of<AppProvider>(context, listen: false);
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
          )
        : const SizedBox.shrink();
  }

  // List of other settings
  Widget _otherSettingsList(BuildContext context) {
    return Column(
      children: [
        // Setting: show extra info on buttons
        _showExtraSetting(context),
        listDivider,
        // Setting: hide timer increment buttons
        _hideIncrementsSetting(context),
        listDivider,
        // Setting: collect timer usage stats
        _collectStatsSetting(context),
        listDivider,
        // Setting: default to Celsius or Fahrenheit
        _useCelsiusSetting(context),
        listDivider,
        // Setting: app theme selection
        _appThemeSetting(context),
        listDivider,
        // Setting: app language selection
        _appLanguageSetting(context),
        listDivider,
        // Notification info
        _notificationLink(),
      ],
    );
  }

  // Setting: show extra info on buttons
  Widget _showExtraSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return Align(
      alignment: Alignment.topLeft,
      child: SwitchListTile.adaptive(
        title: Text(
          AppString.prefs_show_extra.translate(),
          style: textStyleTitle,
        ),
        value: provider.showExtra,
        // Save showExtra setting to prefs
        onChanged: (bool newValue) {
          provider.showExtra = newValue;
        },
        contentPadding: listTilePadding,
        dense: true,
      ),
    );
  }

  // Setting: hide timer increment buttons
  Widget _hideIncrementsSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return Align(
      alignment: Alignment.topLeft,
      child: SwitchListTile.adaptive(
        title: Text(
          AppString.prefs_hide_increments.translate(),
          style: textStyleTitle,
        ),
        subtitle: provider.hideIncrements
            ? Text(
                AppString.prefs_hide_increments_info.translate(),
                style: textStyleSubtitle,
              )
            : null,
        value: provider.hideIncrements,
        // Save hideIncrements setting to prefs
        onChanged: (bool newValue) {
          provider.hideIncrements = newValue;
        },
        contentPadding: listTilePadding,
        dense: true,
      ),
    );
  }

  // Setting: collect timer usage stats
  Widget _collectStatsSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return Align(
      alignment: Alignment.topLeft,
      child: SwitchListTile.adaptive(
        title: Text(
          AppString.stats_enable.translate(),
          style: textStyleTitle,
        ),
        value: provider.collectStats,
        // Save collectStats setting to prefs
        onChanged: (bool newValue) async {
          AppProvider provider =
              Provider.of<AppProvider>(context, listen: false);

          // Show a prompt with more information
          if (await showConfirmDialog(
            context: context,
            body: Text(
              provider.collectStats
                  ? AppString.stats_confirm_disable.translate()
                  : AppString.stats_confirm_enable.translate(),
            ),
            bodyExtra: Text(AppString.confirm_continue.translate()),
          )) {
            // Update setting
            provider.collectStats = newValue;

            // Clear usage data if collection gets disabled
            if (!provider.collectStats) {
              Stats.clearStats();
            }
          }
        },
        contentPadding: listTilePadding,
        dense: true,
      ),
    );
  }

  // Setting: default to Celsius or Fahrenheit
  Widget _useCelsiusSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return Align(
      alignment: Alignment.topLeft,
      child: SwitchListTile.adaptive(
        title: Text(
          AppString.prefs_use_celsius.translate(),
          style: textStyleTitle,
        ),
        value: provider.useCelsius,
        // Save useCelsius setting to prefs
        onChanged: (bool newValue) {
          provider.useCelsius = newValue;
        },
        contentPadding: listTilePadding,
        dense: true,
      ),
    );
  }

  // Setting: app theme selection
  Widget _appThemeSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return Align(
      alignment: Alignment.topLeft,
      child: ListTile(
        title: Text(
          AppString.prefs_app_theme.translate(),
          style: textStyleTitle,
        ),
        trailing: Text(
          provider.appTheme.localizedName,
          style: textStyleTitle.copyWith(
            color: Theme.of(context).textTheme.bodySmall!.color!,
          ),
        ),
        // Open app theme dialog
        onTap: () => openPlatformAdaptiveSelectList(
          context: context,
          titleText: AppString.prefs_app_theme.translate(),
          buttonTextCancel: AppString.cancel_button.translate(),
          itemList: AppTheme.values,
          itemBuilder: _appThemeItem,
          separatorBuilder: _separatorDummy,
        ),
        contentPadding: listTilePadding,
        dense: true,
      ),
    );
  }

  // App theme option
  Widget _appThemeItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    AppTheme value = AppTheme.values.elementAt(index);

    return RadioListTile.adaptive(
      contentPadding: radioTilePadding,
      dense: true,
      useCupertinoCheckmarkStyle: true,
      value: value,
      groupValue: provider.appTheme,
      // Theme name
      title: Text(
        value.localizedName,
        style: textStyleTitle,
      ),
      // Save appTheme to prefs
      onChanged: (_) {
        provider.appTheme = value;
        Navigator.of(context).pop(true);
      },
    );
  }

  // Setting: app language selection
  Widget _appLanguageSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return Align(
      alignment: Alignment.topLeft,
      child: ListTile(
        title:
            Text(AppString.prefs_language.translate(), style: textStyleTitle),
        trailing: Text(
          provider.appLanguage != followSystemLanguage &&
                  supportedLocales
                      .containsKey(parseLocaleString(provider.appLanguage))
              ? supportedLocales[parseLocaleString(provider.appLanguage)]!
              : AppString.theme_system.translate(),
          style: textStyleTitle.copyWith(
            color: Theme.of(context).textTheme.bodySmall!.color!,
          ),
        ),
        // Open app language dialog
        onTap: () => openPlatformAdaptiveSelectList(
          context: context,
          titleText: AppString.prefs_language.translate(),
          buttonTextCancel: AppString.cancel_button.translate(),
          itemList: languageOptions,
          itemBuilder: _appLanguageItem,
          separatorBuilder: _separatorDummy,
        ),
        contentPadding: listTilePadding,
        dense: true,
      ),
    );
  }

  // App language option
  Widget _appLanguageItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    String value = languageOptions[index];

    return RadioListTile.adaptive(
      contentPadding: radioTilePadding,
      dense: true,
      useCupertinoCheckmarkStyle: true,
      value: value,
      groupValue: provider.appLanguage,
      // Language name
      title: Text(
        value != followSystemLanguage &&
                supportedLocales.containsKey(parseLocaleString(value))
            ? supportedLocales[parseLocaleString(value)]!
            : AppString.theme_system.translate(),
        style: textStyleTitle,
      ),
      // Save appLanguage to prefs
      onChanged: (_) {
        provider.appLanguage = value;
        Navigator.of(context).pop(true);
      },
    );
  }

  // Select list separator
  Widget _separatorBuilder(BuildContext context, int index) {
    return listDivider;
  }

  // Placeholder list separator
  Widget _separatorDummy(BuildContext context, int index) {
    return Container();
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
