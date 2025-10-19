/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_button_list.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa timer button list
// - Start, confirm, cancel timers

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/dialogs.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/local_notifications.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/shortcut_handler.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/data/tea_timer.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/widgets/cancel_button.dart';
import 'package:cuppa_mobile/pages/prefs_page.dart';
import 'package:cuppa_mobile/widgets/tea_button.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

// List or grid of TeaButtons
class TeaButtonList extends StatefulWidget {
  const TeaButtonList({super.key});

  @override
  State<TeaButtonList> createState() => _TeaButtonListState();
}

class _TeaButtonListState extends State<TeaButtonList> {
  // State variables
  final ScrollController _scrollController = ScrollController();

  // Timer button list state
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppProvider provider = Provider.of<AppProvider>(context, listen: false);

      // Set default brew temp units based on locale
      // ignore: cascade_invocations
      provider.useCelsius = Prefs.loadUseCelsius() ?? deviceUsesCelsius();

      // Add default presets if no custom teas have been set
      if (provider.teaCount == 0 && !Prefs.teaPrefsExist()) {
        provider.loadDefaults();

        // Start a tutorial for new users
        if (Prefs.showTutorial) {
          ShowcaseView.get().startShowCase(tutorialSteps.keys.toList());
          Prefs.setSkipTutorial();
        }
      }

      // Manage timers
      _checkNextTimer();
      ShortcutHandler.listen(_handleShortcut);
    });
  }

  // Build timer button list
  @override
  Widget build(BuildContext context) {
    // Determine layout based on device orientation
    bool layoutPortrait = getDeviceSize(context).isPortrait;

    // List/grid of available tea buttons
    return Selector<AppProvider, ({List<Tea> teaList, bool stackedView})>(
      selector: (_, provider) =>
          (teaList: provider.teaList, stackedView: provider.stackedView),
      builder: (context, buttonData, child) {
        List<Widget> teaButtonRows = [];

        if (buttonData.teaList.isNotEmpty) {
          if (buttonData.stackedView && getDeviceSize(context).isLargeDevice) {
            // Arrange into two rows of tea buttons for large screens
            int topRowLength = (buttonData.teaList.length / 2).floor();
            teaButtonRows
              ..add(_teaButtonRow(buttonData.teaList.sublist(0, topRowLength)))
              ..add(_teaButtonRow(buttonData.teaList.sublist(topRowLength)));
          } else if (buttonData.stackedView && layoutPortrait) {
            // Arrange into multiple rows for small screens
            for (final teaRow in buttonData.teaList.slices(
              stackedViewTeaCount,
            )) {
              teaButtonRows.add(_teaButtonRow(teaRow));
            }
          } else {
            // Single row of tea buttons
            teaButtonRows.add(_teaButtonRow(buttonData.teaList));
          }
        } else {
          // Add button if tea list is empty
          teaButtonRows.add(_addButton());
        }

        // Build tea button list/grid container
        return Stack(
          children: [
            // Tea buttons
            Container(
              padding: noPadding,
              height: teaButtonRows.length > 1 ? 376.0 : null,
              alignment: Alignment.center,
              child: tutorialTooltip(
                context: context,
                key: tutorialKey3,
                child: tutorialTooltip(
                  context: context,
                  key: tutorialKey4,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: buttonColumnPadding,
                      child: SafeArea(
                        left: false,
                        top: false,
                        right: false,
                        child: Column(children: [...teaButtonRows]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Blur effect at top of stacked button list
            teaButtonRows.length > 1
                ? Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: largeSpacing,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).scaffoldBackgroundColor,
                            Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        );
      },
    );
  }

  // Horizontally scrollable list of tea buttons
  Widget _teaButtonRow(List<Tea> teas) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      controller: _scrollController,
      child: Padding(
        padding: buttonRowPadding,
        child: Row(
          children: [...teas.map<Widget>((Tea tea) => _teaButton(tea))],
        ),
      ),
    );
  }

  // Tea button paired with cancel button
  Widget _teaButton(Tea tea) {
    return Column(
      children: [
        // Start brewing button
        TeaButton(
          key: GlobalObjectKey(tea.id),
          tea: tea,
          fade: !(activeTimerCount < timersMaxCount || tea.isActive),
          onPressed: activeTimerCount < timersMaxCount && !tea.isActive
              ? () => _setTimer(tea)
              : null,
        ),
        // Cancel brewing button
        Container(
          constraints: const BoxConstraints(minHeight: cancelButtonHeight),
          child: Visibility(
            visible: tea.isActive,
            child: cancelButton(
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _cancelTimerForTea(tea),
            ),
          ),
        ),
      ],
    );
  }

  // Add button linking to Prefs page
  Widget _addButton() {
    return Column(
      children: [
        // Add tea button
        Card(
          clipBehavior: Clip.antiAlias,
          margin: largeDefaultPadding,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PrefsWidget(launchAddTea: true),
              ),
            ),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: teaButtonHeight,
                minWidth: teaButtonWidth,
              ),
              margin: largeDefaultPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppString.add_tea_button.translate(),
                    style: textStyleButton.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  navigateIcon(color: Theme.of(context).colorScheme.error),
                ],
              ),
            ),
          ),
        ),
        // Placeholder to align with tea button layout
        Container(
          constraints: const BoxConstraints(minHeight: cancelButtonHeight),
        ),
      ],
    );
  }

  // Ticker handler for a TeaTimer
  void Function(Timer? ticker) _handleTick(TeaTimer timer) {
    return (ticker) {
      if (timer.isActive) {
        int timerSeconds = timer.timerSeconds;
        if (timerSeconds > 0) {
          timer.decrement();
          if (timer.timerSeconds != timerSeconds) {
            // Only update UI if the timer countdown changed
            Provider.of<AppProvider>(context, listen: false).notify();
          }
        } else {
          // Brewing complete
          if (timer.tea != null) {
            Provider.of<AppProvider>(
              context,
              listen: false,
            ).deactivateTea(timer.tea!);
          }
          timer.stop();
        }
      }
    };
  }

  // Start a new brewing timer
  void _setTimer(Tea tea, {bool resume = false, bool autoScroll = false}) {
    // Determine next available timer
    TeaTimer timer = !timer1.isActive ? timer1 : timer2;

    if (!resume) {
      AppProvider provider = Provider.of<AppProvider>(context, listen: false);

      // Start a new timer
      provider.activateTea(tea, timer.notifyID, provider.silentDefault);
      sendNotification(
        tea.brewTime,
        AppString.notification_title.translate(),
        AppString.notification_text.translate(teaName: tea.name),
        timer.notifyID,
        silent: provider.silentDefault,
      );

      // Update timer stats, if enabled
      if (provider.collectStats) {
        Stats.insertStat(Stat(tea: tea));
      }
    } else if (tea.timerNotifyID != null) {
      // Resume with same timer ID
      timer = tea.timerNotifyID == timer1.notifyID ? timer1 : timer2;
    }

    // Set up timer state
    timer.start(tea, _handleTick(timer));

    if (autoScroll) {
      // Ensure we are on the home screen (timer page)
      Navigator.of(context).popUntil((route) => route.isFirst);

      // Autoscroll tea button list to this tea
      BuildContext? target = GlobalObjectKey(tea.id).currentContext;
      if (target != null) {
        Scrollable.ensureVisible(target);
      }
    }

    // Check if we should prompt for a review
    checkReviewPrompt();
  }

  // Cancel a timer
  Future<void> _cancelTimer(TeaTimer timer) async {
    timer.reset();
    await notify.cancel(timer.notifyID);
  }

  // Cancel timer for a given tea
  void _cancelTimerForTea(Tea tea) {
    for (final timer in timerList) {
      if (timer.tea == tea) {
        _cancelTimer(timer);
      }
    }
  }

  // Force cancel and reset all timers
  void _cancelAllTimers() {
    for (final timer in timerList) {
      _cancelTimer(timer);
    }
    Provider.of<AppProvider>(context, listen: false).clearActiveTea();
  }

  // Start timer from stored prefs
  void _checkNextTimer() {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);

    // Load saved brewing timer info from prefs
    for (final tea in provider.activeTeas) {
      if (tea.brewTimeRemaining > 0) {
        // Resume timer from stored prefs
        _setTimer(tea, resume: true, autoScroll: true);
      } else {
        provider.deactivateTea(tea);
      }
    }
  }

  // Start a timer from shortcut selection
  Future<void> _handleShortcut(String shortcutType) async {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    int? teaID = int.tryParse(shortcutType.replaceAll(shortcutPrefixID, ''));
    int? teaIndex = int.tryParse(shortcutType.replaceAll(shortcutPrefix, ''));
    if (teaID != null) {
      // Prefer lookup by tea ID
      teaIndex = provider.teaList.indexWhere((tea) => tea.id == teaID);
    }
    if (teaIndex != null) {
      if (teaIndex >= 0 && teaIndex < provider.teaCount) {
        Tea tea = provider.teaList[teaIndex];
        if (!tea.isActive) {
          if (activeTimerCount >= timersMaxCount) {
            // Ask to cancel and free a timer slot if needed
            if (await showConfirmDialog(
              context: context,
              body: Text(AppString.confirm_message_line1.translate()),
              bodyExtra: Text(AppString.confirm_message_line2.translate()),
            )) {
              _cancelAllTimers();
            } else {
              return;
            }
          }

          // Start timer from shortcut
          _setTimer(tea, autoScroll: true);
        }
      }
    }
  }
}
