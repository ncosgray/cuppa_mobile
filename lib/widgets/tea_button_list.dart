/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_button_list.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

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
import 'package:cuppa_mobile/pages/prefs_page.dart';
import 'package:cuppa_mobile/widgets/tea_button.dart';
import 'package:cuppa_mobile/widgets/tea_settings_card.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'dart:async';
import 'dart:math' show max;
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// List or grid of TeaButtons
class TeaButtonList extends StatefulWidget {
  const TeaButtonList({super.key});

  @override
  State<TeaButtonList> createState() => _TeaButtonListState();
}

class _TeaButtonListState extends State<TeaButtonList> {
  // State variables
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _buttonKeys = {};
  BuildContext? _settingsDialogContext;

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
          startTutorial();
          Prefs.setSkipTutorial();
        }
      }

      // Manage timers
      _checkNextTimer();
      ShortcutHandler.listen(_handleShortcut);
    });
  }

  @override
  void dispose() {
    _closeTeaSettings();
    super.dispose();
  }

  // Build timer button list
  @override
  Widget build(BuildContext context) {
    // List/grid of available tea buttons
    return Selector<
      AppProvider,
      ({
        List<Tea> teaList,
        bool stackedView,
        bool hideCup,
        ButtonSize buttonSize,
      })
    >(
      selector: (_, provider) => (
        teaList: provider.teaList,
        stackedView: provider.stackedView,
        hideCup: provider.cupStyle == CupStyle.none,
        buttonSize: provider.buttonSize,
      ),
      builder: (context, buttonData, child) {
        List<Widget> teaButtonRows = [];
        double buttonScale = buttonData.buttonSize.scale;

        if (buttonData.teaList.isNotEmpty) {
          if (buttonData.stackedView || buttonData.hideCup) {
            // Calculate optimum number of buttons for screen width
            int rowLength = max(
              teaButtonRowMinLength,
              (getDeviceSize(context).width / buttonScale / 128.0).floor(),
            );
            // Arrange into multiple rows for stacked view
            for (final teaRow in buttonData.teaList.slices(rowLength)) {
              teaButtonRows.add(_teaButtonRow(teaRow, buttonScale));
            }
          } else {
            // Single row of tea buttons
            teaButtonRows.add(_teaButtonRow(buttonData.teaList, buttonScale));
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
              height: buttonData.hideCup
                  ? getDeviceSize(context).height * .65
                  : (teaButtonRows.length > 1
                        ? getDeviceSize(context).height * .4
                        : null),
              alignment: .center,
              child: tutorialTooltip(
                context: context,
                key: tutorialKey3,
                child: tutorialTooltip(
                  context: context,
                  key: tutorialKey4,
                  child: SingleChildScrollView(
                    scrollDirection: .vertical,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: buttonColumnPadding,
                      child: Padding(
                        padding: .only(
                          bottom: MediaQuery.viewPaddingOf(context).bottom,
                        ),
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
                          begin: .topCenter,
                          end: .bottomCenter,
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

  // Generate unique key for a tea button
  Key _teaKey(Tea tea) => _buttonKeys.putIfAbsent(tea.id, () => GlobalKey());

  // Horizontally scrollable list of tea buttons
  Widget _teaButtonRow(List<Tea> teas, double buttonScale) {
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: .none,
      controller: _scrollController,
      child: Padding(
        padding: buttonRowPadding,
        child: Row(
          crossAxisAlignment: .start,
          children: [
            ...teas.map<Widget>(
              (Tea tea) => TeaButton(
                key: _teaKey(tea),
                tea: tea,
                fade: !(activeTimerCount < timersMaxCount || tea.isActive),
                scale: buttonScale,
                onPressed: activeTimerCount < timersMaxCount && !tea.isActive
                    ? () => _setTimer(tea)
                    : null,
                onLongPress: () => _openTeaSettings(tea),
                onCancelPressed: () => _cancelTimerForTea(tea),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add button linking to Prefs page
  Widget _addButton() {
    return Card(
      clipBehavior: .antiAlias,
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
            mainAxisAlignment: .center,
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
    );
  }

  // Open tea settings as a floating card above the button
  void _openTeaSettings(Tea tea) {
    _closeTeaSettings();

    final key = _buttonKeys[tea.id];
    if (key?.currentContext == null) return;

    final RenderBox box = key!.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonTopCenter = box.localToGlobal(
      Offset(box.size.width / 2, 0),
    );

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, _) {
        _settingsDialogContext = dialogContext;
        return _TeaSettingsFloatingCard(
          tea: tea,
          buttonTopCenter: buttonTopCenter,
          onClose: _closeTeaSettings,
        );
      },
    ).whenComplete(() => _settingsDialogContext = null);
  }

  void _closeTeaSettings() {
    final dialogContext = _settingsDialogContext;
    _settingsDialogContext = null;
    if (dialogContext != null && dialogContext.mounted) {
      Navigator.of(dialogContext).pop();
    }
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
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);

      // Scroll to the tea button after the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final BuildContext? target = _buttonKeys[tea.id]?.currentContext;
        if (target != null) {
          Scrollable.ensureVisible(target);
        }
      });
    }

    // Check if we should prompt for a review
    checkReviewPrompt();
  }

  // Cancel a timer
  Future<void> _cancelTimer(TeaTimer timer) async {
    timer.reset();
    await notify.cancel(id: timer.notifyID);
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

// Floating overlay that shows a tea settings card
class _TeaSettingsFloatingCard extends StatefulWidget {
  const _TeaSettingsFloatingCard({
    required this.tea,
    required this.buttonTopCenter,
    required this.onClose,
  });

  final Tea tea;
  final Offset buttonTopCenter;
  final VoidCallback onClose;

  @override
  State<_TeaSettingsFloatingCard> createState() =>
      _TeaSettingsFloatingCardState();
}

class _TeaSettingsFloatingCardState extends State<_TeaSettingsFloatingCard> {
  final ValueNotifier<bool> _subDialogOpen = ValueNotifier(false);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tap-to-dismiss barrier (disabled while a sub-dialog is open)
        Positioned.fill(
          child: ValueListenableBuilder<bool>(
            valueListenable: _subDialogOpen,
            builder: (context, isSubDialogOpen, child) =>
                IgnorePointer(ignoring: isSubDialogOpen, child: child),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onClose,
            ),
          ),
        ),
        // Floating settings card centered horizontally above the button
        CustomSingleChildLayout(
          delegate: _FloatingCardLayout(
            buttonTopCenter: widget.buttonTopCenter,
            safeAreaInsets: MediaQuery.of(context).padding,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Card with drop shadow, dimmed while a sub-dialog is open
              ValueListenableBuilder<bool>(
                valueListenable: _subDialogOpen,
                builder: (context, isSubDialogOpen, child) {
                  return AbsorbPointer(
                    absorbing: isSubDialogOpen,
                    child: child,
                  );
                },
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Consumer<AppProvider>(
                    builder: (context, provider, _) {
                      final editTea = provider.teaList.firstWhere(
                        (t) => t.id == widget.tea.id,
                        orElse: () => widget.tea,
                      );
                      return MediaQuery.removePadding(
                        context: context,
                        removeLeft: true,
                        removeRight: true,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 380),
                          child: TeaSettingsCard(
                            tea: editTea,
                            showDragHandle: false,
                            subDialogNotifier: _subDialogOpen,
                            forcePortraitLayout: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Close button at top-right corner of card
              Positioned(
                top: -5,
                right: 0,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Layout delegate to position settings card centered above tea button
class _FloatingCardLayout extends SingleChildLayoutDelegate {
  const _FloatingCardLayout({
    required this.buttonTopCenter,
    required this.safeAreaInsets,
  });

  final Offset buttonTopCenter;
  final EdgeInsets safeAreaInsets;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Center card horizontally over the button, clamped within safe area insets
    double left = buttonTopCenter.dx - childSize.width / 2;
    left = left.clamp(
      safeAreaInsets.left,
      max(
        safeAreaInsets.left,
        size.width - childSize.width - safeAreaInsets.right,
      ),
    );
    // Position bottom of card at top of button
    double top = buttonTopCenter.dy - childSize.height;
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_FloatingCardLayout oldDelegate) {
    return oldDelegate.buttonTopCenter != buttonTopCenter ||
        oldDelegate.safeAreaInsets != safeAreaInsets;
  }
}
