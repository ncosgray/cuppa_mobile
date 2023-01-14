/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    prefs_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa Preferences page
// - Build prefs interface and interactivity

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/presets.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/widgets/about_page.dart';
import 'package:cuppa_mobile/widgets/common.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/tea_settings_card.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

// Cuppa Preferences page
class PrefsWidget extends StatelessWidget {
  const PrefsWidget({Key? key}) : super(key: key);

  // Build Prefs page
  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveScaffold(
        platform: appPlatform,
        isPoppable: true,
        textScaleFactor: appTextScale,
        title: AppString.prefs_title.translate(),
        // Button to navigate to About page
        actionIcon: getPlatformAboutIcon(appPlatform),
        actionRoute: const AboutWidget(),
        body: SafeArea(
            child: Container(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                automaticallyImplyLeading: false,
                leading: Container(
                    margin: const EdgeInsets.fromLTRB(6.0, 18.0, 6.0, 12.0),
                    child:
                        // Section: Teas
                        Text(AppString.teas_title.translate(),
                            style: textStyleHeader.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color!,
                            ))),
              ),
              SliverToBoxAdapter(
                  child:
                      // Prefs header info text
                      Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(
                                  6.0, 0.0, 6.0, 12.0),
                              child: Text(AppString.prefs_header.translate(),
                                  style: textStyleSubtitle)))),
              // Tea settings cards
              Consumer<AppProvider>(
                  builder: (context, provider, child) => ReorderableSliverList(
                      buildDraggableFeedback: draggableFeedback,
                      onReorder: (int oldIndex, int newIndex) {
                        // Reorder the tea list
                        provider.reorderTeas(oldIndex, newIndex);
                      },
                      delegate: ReorderableSliverChildListDelegate(
                          provider.teaList.map<Widget>((tea) {
                        if (tea.isActive) {
                          // Don't allow deleting if timer is active
                          return IgnorePointer(
                              // Disable editing actively brewing tea
                              ignoring: tea.isActive,
                              child: Opacity(
                                  opacity: tea.isActive ? 0.4 : 1.0,
                                  child: Container(
                                      key: Key(tea.id.toString()),
                                      child: TeaSettingsCard(
                                        tea: tea,
                                      ))));
                        } else {
                          // Deleteable
                          return Dismissible(
                            key: Key(tea.id.toString()),
                            onDismissed: (direction) {
                              // Delete this from the tea list
                              provider.deleteTea(tea);
                            },
                            // Dismissible delete warning background
                            background:
                                dismissibleBackground(Alignment.centerLeft),
                            secondaryBackground:
                                dismissibleBackground(Alignment.centerRight),
                            child: TeaSettingsCard(
                              tea: tea,
                            ),
                          );
                        }
                      }).toList()))),
              SliverToBoxAdapter(
                child: Column(children: [
                  Row(children: [
                    // Add tea button
                    Expanded(
                        child: Selector<AppProvider, int>(
                            selector: (_, provider) => provider.teaCount,
                            builder: (context, count, child) => Card(
                                child: ListTile(
                                    title: TextButton.icon(
                                        label: Text(
                                            AppString.add_tea_button
                                                .translate()
                                                .toUpperCase(),
                                            style: textStyleButton),
                                        icon: const Icon(Icons.add_circle,
                                            size: 20.0),
                                        onPressed:
                                            // Disable adding teas if there are maximum teas
                                            count < teasMaxCount
                                                ? () {
                                                    // Open add tea dialog
                                                    _displayAddTeaDialog(
                                                        context);
                                                  }
                                                : null))))),
                    // Remove all teas button
                    (Provider.of<AppProvider>(context).teaCount > 0 &&
                            Provider.of<AppProvider>(context).activeTea == null)
                        ? IntrinsicWidth(
                            child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints.tightForFinite(),
                                child: Card(
                                    child: ListTile(
                                        title: IconButton(
                                            icon: const Icon(
                                                Icons.delete_sweep_outlined,
                                                color: Colors.red),
                                            onPressed: () async {
                                              if (await _confirmDelete(
                                                  context)) {
                                                // Clear tea list
                                                Provider.of<AppProvider>(
                                                        context,
                                                        listen: false)
                                                    .clearTeaList();
                                              }
                                            })))))
                        : const SizedBox.shrink()
                  ]),
                  // Setting: show extra info on buttons
                  Align(
                      alignment: Alignment.topLeft,
                      child: SwitchListTile.adaptive(
                        title: Text(AppString.prefs_show_extra.translate(),
                            style: textStyleTitle),
                        value: Provider.of<AppProvider>(context).showExtra,
                        // Save showExtra setting to prefs
                        onChanged: (bool newValue) {
                          Provider.of<AppProvider>(context, listen: false)
                              .showExtra = newValue;
                        },
                        contentPadding:
                            const EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 6.0),
                        dense: true,
                      )),
                  listDivider,
                  // Setting: default to Celsius or Fahrenheit
                  Align(
                      alignment: Alignment.topLeft,
                      child: SwitchListTile.adaptive(
                        title: Text(AppString.prefs_use_celsius.translate(),
                            style: textStyleTitle),
                        value: Provider.of<AppProvider>(context).useCelsius,
                        // Save useCelsius setting to prefs
                        onChanged: (bool newValue) {
                          Provider.of<AppProvider>(context, listen: false)
                              .useCelsius = newValue;
                        },
                        contentPadding: const EdgeInsets.all(6.0),
                        dense: true,
                      )),
                  listDivider,
                  // Setting: app theme selection
                  Align(
                      alignment: Alignment.topLeft,
                      child: ListTile(
                        title: Text(AppString.prefs_app_theme.translate(),
                            style: textStyleTitle),
                        trailing: Text(
                          Provider.of<AppProvider>(context)
                              .appTheme
                              .localizedName,
                          style: textStyleTitle.copyWith(
                              color:
                                  Theme.of(context).textTheme.caption!.color!),
                        ),
                        onTap: () {
                          // Open app theme dialog
                          _displayAppThemeDialog(context);
                        },
                        contentPadding: const EdgeInsets.all(6.0),
                        dense: true,
                      )),
                  listDivider,
                  // Setting: app language selection
                  Align(
                      alignment: Alignment.topLeft,
                      child: ListTile(
                        title: Text(AppString.prefs_language.translate(),
                            style: textStyleTitle),
                        trailing: Text(
                            Provider.of<AppProvider>(context).appLanguage == ''
                                ? AppString.theme_system.translate()
                                : '${supportedLanguages[Provider.of<AppProvider>(context).appLanguage]!} (${Provider.of<AppProvider>(context).appLanguage})',
                            style: textStyleTitle.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .color!)),
                        onTap: () {
                          // Open app language dialog
                          _displayAppLanguageDialog(context);
                        },
                        contentPadding: const EdgeInsets.all(6.0),
                        dense: true,
                      )),
                  listDivider,
                  // Notification settings info text and link
                  InkWell(
                      child: ListTile(
                    minLeadingWidth: 30.0,
                    leading: const SizedBox(
                        height: double.infinity,
                        child: Icon(
                          Icons.info,
                          size: 20.0,
                        )),
                    horizontalTitleGap: 0.0,
                    title: Text(AppString.prefs_notifications.translate(),
                        style: textStyleSubtitle),
                    trailing: const SizedBox(
                        height: double.infinity, child: launchIcon),
                    onTap: () => AppSettings.openNotificationSettings(),
                    contentPadding:
                        const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 18.0),
                    dense: true,
                  )),
                ]),
              ),
            ],
          ),
        )));
  }

  // Display an add tea selection dialog box
  Future<bool?> _displayAddTeaDialog(BuildContext context) async {
    double deviceHeight = MediaQuery.of(context).size.height;

    return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return PlatformAdaptiveDialog(
              platform: appPlatform,
              title: Text(AppString.add_tea_button.translate()),
              content: SizedBox(
                  width: 120.0,
                  height: deviceHeight * 0.6,
                  child: Card(
                      margin: const EdgeInsets.only(top: 12.0),
                      color: Colors.transparent,
                      elevation: 0,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(0.0),
                          shrinkWrap: true,
                          itemCount: Presets.presetList.length,
                          // Tea name button
                          itemBuilder: (BuildContext context, int index) {
                            AppProvider provider = Provider.of<AppProvider>(
                                context,
                                listen: false);
                            Preset preset = Presets.presetList[index];

                            return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.all(0.0),
                                // Preset tea icon
                                leading: SizedBox(
                                    width: 24.0,
                                    height: double.infinity,
                                    child: Icon(
                                      preset.isCustom
                                          ? Icons.add_circle
                                          : preset.getIcon(),
                                      color: preset.getThemeColor(context),
                                      size: preset.isCustom ? 20.0 : 24.0,
                                    )),
                                // Localized preset tea name
                                title: Text(
                                  preset.localizedName,
                                  style: textStyleSetting.copyWith(
                                      color: preset.getThemeColor(context)),
                                ),
                                // Preset tea brew time and temperature
                                subtitle: preset.isCustom
                                    ? null
                                    : Row(children: [
                                        Text(
                                          formatTimer(preset.brewTime),
                                          style:
                                              textStyleSettingSeconday.copyWith(
                                                  color: preset
                                                      .getThemeColor(context)),
                                        ),
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                minWidth: 6.0, maxWidth: 30.0),
                                            child: Container()),
                                        Text(
                                          preset
                                              .tempDisplay(provider.useCelsius),
                                          style:
                                              textStyleSettingSeconday.copyWith(
                                                  color: preset
                                                      .getThemeColor(context)),
                                        ),
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: double.infinity),
                                            child: Container()),
                                      ]),
                                onTap: () {
                                  // Add selected tea
                                  provider.addTea(preset.createTea(
                                      useCelsius: provider.useCelsius));
                                  Navigator.of(context).pop(true);
                                });
                          },
                          separatorBuilder: (context, index) {
                            return listDivider;
                          },
                        ),
                      ))),
              buttonTextFalse: AppString.cancel_button.translate());
        });
  }

  // Display an app theme selection dialog box
  Future<bool?> _displayAppThemeDialog(BuildContext context) async {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return PlatformAdaptiveDialog(
              platform: appPlatform,
              title: Text(AppString.prefs_app_theme.translate()),
              content: Card(
                  margin: const EdgeInsets.only(top: 12.0),
                  color: Colors.transparent,
                  elevation: 0,
                  child: SizedBox(
                    width: double.maxFinite,
                    height: AppTheme.values.length * 46,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(0.0),
                      shrinkWrap: true,
                      itemCount: AppTheme.values.length,
                      // App theme button
                      itemBuilder: (BuildContext context, int index) {
                        AppProvider provider =
                            Provider.of<AppProvider>(context, listen: false);
                        AppTheme value = AppTheme.values.elementAt(index);

                        return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.all(0.0),
                            title: Row(children: [
                              Container(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: value == provider.appTheme
                                      ? getPlatformRadioOnIcon(appPlatform)
                                      : getPlatformRadioOffIcon(appPlatform)),
                              Expanded(
                                  child: Text(
                                value.localizedName,
                                style: textStyleTitle,
                              )),
                            ]),
                            onTap: () {
                              // Save appTheme to prefs
                              provider.appTheme = value;
                              Navigator.of(context).pop(true);
                            });
                      },
                    ),
                  )),
              buttonTextFalse: AppString.cancel_button.translate());
        });
  }

  // Display an app language selection dialog box
  Future<bool?> _displayAppLanguageDialog(BuildContext context) async {
    double deviceHeight = MediaQuery.of(context).size.height;
    final List<String> languageOptions =
        [''] + supportedLanguages.keys.toList();

    return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return PlatformAdaptiveDialog(
              platform: appPlatform,
              title: Text(AppString.prefs_language.translate()),
              content: Card(
                  margin: const EdgeInsets.only(top: 12.0),
                  color: Colors.transparent,
                  elevation: 0,
                  child: SizedBox(
                    width: double.maxFinite,
                    height: deviceHeight * 0.6,
                    child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(0.0),
                          shrinkWrap: true,
                          itemCount: languageOptions.length,
                          // App language button
                          itemBuilder: (BuildContext context, int index) {
                            AppProvider provider = Provider.of<AppProvider>(
                                context,
                                listen: false);
                            String value = languageOptions[index];

                            return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.all(0.0),
                                title: Row(children: [
                                  Container(
                                      padding:
                                          const EdgeInsets.only(right: 12.0),
                                      child: value == provider.appLanguage
                                          ? getPlatformRadioOnIcon(appPlatform)
                                          : getPlatformRadioOffIcon(
                                              appPlatform)),
                                  Expanded(
                                      child: Text(
                                    value == ''
                                        ? AppString.theme_system.translate()
                                        : '${supportedLanguages[value]!} ($value)',
                                    style: textStyleTitle,
                                  )),
                                ]),
                                onTap: () {
                                  // Save appLanguage to prefs
                                  provider.appLanguage = value;
                                  Navigator.of(context).pop(true);
                                });
                          },
                        )),
                  )),
              buttonTextFalse: AppString.cancel_button.translate());
        });
  }

  // Delete confirmation dialog
  Future _confirmDelete(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PlatformAdaptiveDialog(
            platform: appPlatform,
            title: Text(AppString.confirm_title.translate()),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(AppString.confirm_delete.translate()),
                ],
              ),
            ),
            buttonTextTrue: AppString.yes_button.translate(),
            buttonTextFalse: AppString.no_button.translate(),
          );
        });
  }
}
