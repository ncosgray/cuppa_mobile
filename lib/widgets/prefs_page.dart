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
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/about_page.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

// Cuppa Preferences page
class PrefsWidget extends StatelessWidget {
  const PrefsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveScaffold(
        platform: appPlatform,
        isPoppable: true,
        textScaleFactor: appTextScale,
        title: AppString.prefs_title.translate(),
        // Button to navigate to About page
        actionIcon: getPlatformAboutIcon(appPlatform),
        actionRoute: routeAbout,
        body: SafeArea(
            child: Container(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0,
                backgroundColor: Theme.of(context).canvasColor,
                automaticallyImplyLeading: false,
                leading: Container(
                    margin: const EdgeInsets.fromLTRB(6.0, 18.0, 6.0, 12.0),
                    child:
                        // Section: Teas
                        Text(AppString.teas_title.translate(),
                            style: TextStyle(
                              fontSize: 18.0,
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
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ))))),
              // Tea settings cards
              Consumer<AppProvider>(
                  builder: (context, provider, child) => ReorderableSliverList(
                      buildDraggableFeedback: _draggableFeedback,
                      onReorder: (int oldIndex, int newIndex) {
                        // Reorder the tea list
                        provider.reorderTeas(oldIndex, newIndex);
                      },
                      delegate: ReorderableSliverChildListDelegate(
                          provider.teaList.map<Widget>((tea) {
                        if ((provider.teaCount <= teasMinCount) ||
                            tea.isActive) {
                          // Don't allow deleting if there are minimum teas or timer is active
                          return IgnorePointer(
                              // Disable editing actively brewing tea
                              ignoring: tea.isActive,
                              child: Opacity(
                                  opacity: tea.isActive ? 0.4 : 1.0,
                                  child: Container(
                                      key: Key(tea.id.toString()),
                                      child: PrefsTeaRow(
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
                                _dismissibleBackground(Alignment.centerLeft),
                            secondaryBackground:
                                _dismissibleBackground(Alignment.centerRight),
                            child: PrefsTeaRow(
                              tea: tea,
                            ),
                          );
                        }
                      }).toList()))),
              SliverToBoxAdapter(
                child: Column(children: [
                  // Add tea button
                  Selector<AppProvider, int>(
                      selector: (_, provider) => provider.teaCount,
                      builder: (context, count, child) => Card(
                          child: ListTile(
                              title: TextButton.icon(
                                  label: Text(
                                      AppString.add_tea_button
                                          .translate()
                                          .toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: count < teasMaxCount
                                              ? Colors.blue
                                              : Colors.grey)),
                                  icon: Icon(Icons.add_circle,
                                      color: count < teasMaxCount
                                          ? Colors.blue
                                          : Colors.grey,
                                      size: 20.0),
                                  onPressed:
                                      // Disable adding teas if there are maximum teas
                                      count < teasMaxCount
                                          ? () {
                                              // Open add tea dialog
                                              _displayAddTeaDialog(context);
                                            }
                                          : null)))),
                  // Setting: show extra info on buttons
                  Align(
                      alignment: Alignment.topLeft,
                      child: SwitchListTile.adaptive(
                        title: Text(AppString.prefs_show_extra.translate(),
                            style: const TextStyle(
                              fontSize: 16.0,
                            )),
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
                  _divider(),
                  // Setting: default to Celsius or Fahrenheit
                  Align(
                      alignment: Alignment.topLeft,
                      child: SwitchListTile.adaptive(
                        title: Text(AppString.prefs_use_celsius.translate(),
                            style: const TextStyle(
                              fontSize: 16.0,
                            )),
                        value: Provider.of<AppProvider>(context).useCelsius,
                        // Save useCelsius setting to prefs
                        onChanged: (bool newValue) {
                          Provider.of<AppProvider>(context, listen: false)
                              .useCelsius = newValue;
                        },
                        contentPadding: const EdgeInsets.all(6.0),
                        dense: true,
                      )),
                  _divider(),
                  // Setting: app theme selection
                  Align(
                      alignment: Alignment.topLeft,
                      child: ListTile(
                        title: Text(AppString.prefs_app_theme.translate(),
                            style: const TextStyle(
                              fontSize: 16.0,
                            )),
                        trailing: Text(
                            Provider.of<AppProvider>(context)
                                .appTheme
                                .localizedName,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.caption!.color!,
                              fontSize: 16.0,
                            )),
                        onTap: () {
                          // Open app theme dialog
                          _displayAppThemeDialog(context);
                        },
                        contentPadding: const EdgeInsets.all(6.0),
                        dense: true,
                      )),
                  _divider(),
                  // Setting: app language selection
                  Align(
                      alignment: Alignment.topLeft,
                      child: ListTile(
                        title: Text(AppString.prefs_language.translate(),
                            style: const TextStyle(
                              fontSize: 16.0,
                            )),
                        trailing: Text(
                            Provider.of<AppProvider>(context).appLanguage == ''
                                ? AppString.theme_system.translate()
                                : '${supportedLanguages[Provider.of<AppProvider>(context).appLanguage]!} (${Provider.of<AppProvider>(context).appLanguage})',
                            style: TextStyle(
                              fontSize: 16.0,
                              color:
                                  Theme.of(context).textTheme.caption!.color!,
                            )),
                        onTap: () {
                          // Open app language dialog
                          _displayAppLanguageDialog(context);
                        },
                        contentPadding: const EdgeInsets.all(6.0),
                        dense: true,
                      )),
                  _divider(),
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
                        style: const TextStyle(
                          fontSize: 14.0,
                        )),
                    trailing: const SizedBox(
                        height: double.infinity,
                        child: Icon(
                          Icons.launch,
                          size: 16.0,
                        )),
                    onTap: () => AppSettings.openNotificationSettings(),
                    contentPadding: const EdgeInsets.all(6.0),
                    dense: true,
                  )),
                ]),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                fillOverscroll: true,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(6.0, 36.0, 6.0, 18.0),
                    // About text linking to app website
                    child: aboutText(),
                  ),
                ),
              )
            ],
          ),
        )));
  }
}

// Widget defining a tea settings card
class PrefsTeaRow extends StatefulWidget {
  const PrefsTeaRow({
    Key? key,
    required this.tea,
  }) : super(key: key);

  final Tea tea;

  @override
  _PrefsTeaRowState createState() => _PrefsTeaRowState(tea: tea);
}

class _PrefsTeaRowState extends State<PrefsTeaRow> {
  _PrefsTeaRowState({
    required this.tea,
  });

  final Tea tea;

  @override
  Widget build(BuildContext context) {
    bool isLargeDevice = MediaQuery.of(context).size.width >= largeDeviceSize;

    return Card(
        child: ListTile(
      horizontalTitleGap: isLargeDevice ? 24.0 : 4.0,
      minLeadingWidth: 0.0,
      leading:
          // Favorite status
          SizedBox(
              height: double.infinity,
              child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 20.0, minHeight: 20.0),
                  splashRadius: 20.0,
                  iconSize: 20.0,
                  icon: tea.isFavorite
                      ? const Icon(Icons.star, color: Colors.amber)
                      : Provider.of<AppProvider>(context, listen: false)
                                  .favoritesList
                                  .length <
                              favoritesMaxCount
                          ? const Icon(Icons.star, color: Colors.grey)
                          : const Icon(Icons.star_border_outlined,
                              color: Colors.grey),
                  // Toggle favorite status if enabled or max not reached
                  onPressed: tea.isFavorite ||
                          Provider.of<AppProvider>(context, listen: false)
                                  .favoritesList
                                  .length <
                              favoritesMaxCount
                      ? () {
                          // Toggle favorite status
                          Provider.of<AppProvider>(context, listen: false)
                              .updateTea(tea, isFavorite: !tea.isFavorite);
                        }
                      : null)),
      title: SizedBox(
          height: isLargeDevice ? 64.0 : 84.0,
          child: Flex(
            // Determine layout by device size
            direction: isLargeDevice ? Axis.horizontal : Axis.vertical,
            children: [
              Flexible(
                child: Container(
                    height: 54.0,
                    padding: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                    child: Row(children: [
                      // Tea name with edit icon
                      TextButton.icon(
                          icon: Text(tea.name,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: tea.getThemeColor(context),
                              )),
                          label: const Icon(
                            Icons.edit,
                            color: Colors.grey,
                            size: 20.0,
                          ),
                          onPressed: () {
                            // Open tea name dialog
                            _displayTeaNameDialog(context, tea.name)
                                .then((newValue) {
                              if (newValue != null) {
                                // Save name to prefs
                                Provider.of<AppProvider>(context, listen: false)
                                    .updateTea(tea, name: newValue);
                              }
                            });
                          }),
                    ])),
              ),
              // Tea settings selection
              Flexible(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(8.0, 2.0, 0.0, 2.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Brew time
                          InkWell(
                              child: SizedBox(
                                  height: double.infinity,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        formatTimer(tea.brewTime),
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        size: 24.0,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  )),
                              onTap: () {
                                // Open tea brew time dialog
                                _displayTeaBrewTimeDialog(
                                        context,
                                        tea.brewTimeMinutes,
                                        tea.brewTimeSeconds)
                                    .then((newValue) {
                                  if (newValue != null) {
                                    // Save brew time to prefs
                                    Provider.of<AppProvider>(context,
                                            listen: false)
                                        .updateTea(tea, brewTime: newValue);
                                  }
                                });
                              }),
                          _flexibleSpacer(),
                          // Brew temperature
                          InkWell(
                              child: SizedBox(
                                  height: double.infinity,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        formatTemp(tea.brewTemp),
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        size: 24.0,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  )),
                              onTap: () {
                                // Open tea brew temp dialog
                                _displayTeaBrewTempDialog(context, tea.brewTemp)
                                    .then((newValue) {
                                  if (newValue != null) {
                                    // Save brew temp to prefs
                                    Provider.of<AppProvider>(context,
                                            listen: false)
                                        .updateTea(tea, brewTemp: newValue);
                                  }
                                });
                              }),
                          _flexibleSpacer(),
                          Align(
                              alignment: Alignment.centerRight,
                              child: Row(children: [
                                // Tea color selection
                                InkWell(
                                    child: SizedBox(
                                        height: double.infinity,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              width: 18.0,
                                              height: 18.0,
                                              color: tea.getThemeColor(context),
                                            ),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              size: 24.0,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        )),
                                    onTap: () {
                                      // Open tea color dialog
                                      _displayColorDialog(tea, context);
                                    }),
                                SizedBox(width: isLargeDevice ? 30.0 : 5.0),
                                // Icon selection
                                InkWell(
                                    child: SizedBox(
                                        height: double.infinity,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                                width: 18.0,
                                                child: Icon(tea.teaIcon,
                                                    color: tea.getThemeColor(
                                                        context))),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              size: 24.0,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        )),
                                    onTap: () {
                                      // Open tea icon dialog
                                      _displayIconDialog(tea, context);
                                    }),
                              ])),
                        ])),
              ),
            ],
          )),
      trailing: const SizedBox(
          height: double.infinity,
          child: Icon(
            Icons.drag_handle,
            size: 20.0,
            color: Colors.grey,
          )),
    ));
  }

  // Tea settings spacer
  Widget _flexibleSpacer() {
    return Flexible(
        child: ConstrainedBox(
            constraints:
                const BoxConstraints(minWidth: 5.0, maxWidth: double.infinity),
            child: Container()));
  }
}

// Display a tea name entry dialog box
Future<String?> _displayTeaNameDialog(
    BuildContext context, String currentTeaName) async {
  return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PlatformAdaptiveTextFormDialog(
            platform: appPlatform,
            initialValue: currentTeaName,
            validator: (String? newValue) {
              if (newValue == null || newValue.isEmpty) {
                return AppString.error_name_missing.translate();
              } else if (newValue.characters.length > teaNameMaxLength) {
                return AppString.error_name_long.translate();
              }
              return null;
            },
            buttonTextCancel: AppString.cancel_button.translate(),
            buttonTextOK: AppString.ok_button.translate());
      });
}

// Display a tea brew time entry dialog box
Future<int?> _displayTeaBrewTimeDialog(
    BuildContext context, int currentMinutes, int currentSeconds) async {
  return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PlatformAdaptiveTimePickerDialog(
            platform: appPlatform,
            initialMinutes: currentMinutes,
            minuteOptions: brewTimeMinuteOptions,
            initialSeconds: currentSeconds,
            secondOptions: brewTimeSecondOptions,
            buttonTextCancel: AppString.cancel_button.translate(),
            buttonTextOK: AppString.ok_button.translate());
      });
}

// Display a tea brew temperature entry dialog box
Future<int?> _displayTeaBrewTempDialog(
    BuildContext context, int currentTemp) async {
  return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PlatformAdaptiveTempPickerDialog(
            platform: appPlatform,
            initialTemp: currentTemp,
            tempFOptions: brewTempFOptions,
            tempCOptions: brewTempCOptions,
            buttonTextCancel: AppString.cancel_button.translate(),
            buttonTextOK: AppString.ok_button.translate());
      });
}

// Display a tea icon selection dialog box
Future<bool?> _displayIconDialog(Tea tea, BuildContext context) async {
  return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PlatformAdaptiveDialog(
            platform: appPlatform,
            title: Container(),
            content: SizedBox(
              width: TeaIcon.values.length * 12,
              height: TeaIcon.values.length * 12,
              child: Card(
                  margin: const EdgeInsets.all(0.0),
                  color: Colors.transparent,
                  elevation: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // Tea icon buttons
                    children: List.generate(TeaIcon.values.length, (index) {
                      TeaIcon value = TeaIcon.values[index];
                      return InkWell(
                          child: Icon(
                            value.getIcon(),
                            size: 36.0,
                            color: value == tea.icon
                                ? tea.getThemeColor(context)
                                : null,
                          ),
                          onTap: () {
                            // Set selected icon
                            Provider.of<AppProvider>(context, listen: false)
                                .updateTea(tea, icon: value);
                            Navigator.of(context).pop(true);
                          });
                    }),
                  )),
            ),
            buttonTextFalse: AppString.cancel_button.translate());
      });
}

// Display a tea color selection dialog box
Future<bool?> _displayColorDialog(Tea tea, BuildContext context) async {
  return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PlatformAdaptiveDialog(
            platform: appPlatform,
            title: Container(),
            content: SizedBox(
              width: TeaColor.values.length * 24,
              height: TeaColor.values.length * 24,
              child: Card(
                  margin: const EdgeInsets.all(0.0),
                  color: Colors.transparent,
                  elevation: 0,
                  child: Scrollbar(
                      thumbVisibility: true,
                      child: GridView.builder(
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                        shrinkWrap: true,
                        itemCount: TeaColor.values.length,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 90.0,
                                childAspectRatio: 1,
                                crossAxisSpacing: 12.0,
                                mainAxisSpacing: 12.0),
                        // Tea color button
                        itemBuilder: (BuildContext context, int index) {
                          TeaColor value = TeaColor.values[index];
                          return InkWell(
                              child: Container(
                                  constraints: const BoxConstraints.expand(),
                                  color: value.getThemeColor(context),
                                  child: value == tea.color
                                      ?
                                      // Timer icon indicates current color
                                      Icon(
                                          tea.teaIcon,
                                          size: 32.0,
                                          color: Colors.white,
                                        )
                                      : Container()),
                              onTap: () {
                                // Set selected color
                                Provider.of<AppProvider>(context, listen: false)
                                    .updateTea(tea, color: value);
                                Navigator.of(context).pop(true);
                              });
                        },
                      ))),
            ),
            buttonTextFalse: AppString.cancel_button.translate());
      });
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
                          AppProvider provider =
                              Provider.of<AppProvider>(context, listen: false);
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: preset.getThemeColor(context)),
                              ),
                              // Preset tea brew time and temperature
                              subtitle: preset.isCustom
                                  ? null
                                  : Row(children: [
                                      Text(
                                        formatTimer(preset.brewTime),
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color:
                                                preset.getThemeColor(context)),
                                      ),
                                      ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              minWidth: 6.0, maxWidth: 30.0),
                                          child: Container()),
                                      Text(
                                        preset.tempDisplay(provider.useCelsius),
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color:
                                                preset.getThemeColor(context)),
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
                          return _divider();
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
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
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
  final List<String> languageOptions = [''] + supportedLanguages.keys.toList();

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
                          AppProvider provider =
                              Provider.of<AppProvider>(context, listen: false);
                          String value = languageOptions[index];

                          return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.all(0.0),
                              title: Row(children: [
                                Container(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: value == provider.appLanguage
                                        ? getPlatformRadioOnIcon(appPlatform)
                                        : getPlatformRadioOffIcon(appPlatform)),
                                Expanded(
                                    child: Text(
                                  value == ''
                                      ? AppString.theme_system.translate()
                                      : '${supportedLanguages[value]!} ($value)',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                  ),
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

// Prefs settings list divider
Widget _divider() {
  return const Divider(
    thickness: 1.0,
    indent: 6.0,
    endIndent: 6.0,
  );
}

// Dismissible delete warning background
Widget _dismissibleBackground(Alignment alignment) {
  return Container(
      padding: const EdgeInsets.all(5.0),
      child: Container(
          color: Colors.red,
          child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                  alignment: alignment,
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 28.0)))));
}

// Custom draggable feedback for reorderable list
Widget _draggableFeedback(
    BuildContext context, BoxConstraints constraints, Widget child) {
  return Transform(
    transform: Matrix4.rotationZ(0),
    alignment: FractionalOffset.topLeft,
    child: Container(
      decoration: const BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.black26, blurRadius: 7.0, offset: Offset(0.0, 0.75))
      ]),
      child: ConstrainedBox(constraints: constraints, child: child),
    ),
  );
}
