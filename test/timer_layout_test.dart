/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    timer_layout_test.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa widget tests: Timer page layout
// - Lays the Timer page out across a range of devices and settings, then checks
//   general layout health with no timer, one timer, and two timers running

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/pages/timer_page.dart';
import 'package:cuppa_mobile/widgets/quick_timer_button.dart';
import 'package:cuppa_mobile/widgets/tea_button.dart';
import 'package:cuppa_mobile/widgets/tea_button_list.dart';
import 'package:cuppa_mobile/widgets/timer_countdown.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import 'tea_test.dart' show makeTea;
import 'test_setup.dart';

// Sub-pixel slack allowed when comparing laid out geometry
const double _tolerance = 0.5;

// Device profile: logical screen size and safe area insets
class _Device {
  const _Device(
    this.name,
    this.size,
    this.pixelRatio,
    this.topInset,
    this.bottomInset,
  );

  final String name;
  final Size size;
  final double pixelRatio;
  final double topInset;
  final double bottomInset;
}

const _devices = <_Device>[
  _Device('a tiny phone', Size(320, 568), 2, 24, 0),
  _Device('a phone with a home indicator', Size(402, 874), 3, 59, 34),
  _Device('a tall phone', Size(412, 923), 2.625, 24, 24),
  _Device('a tablet', Size(834, 1194), 2, 24, 20),
  _Device('a phone in landscape', Size(874, 402), 3, 0, 21),
];

// A Timer page configuration to lay out and inspect
class _Scenario {
  const _Scenario(
    this.name, {
    this.teaCount = 3,
    this.teaName = 'Tea',
    this.buttonSize = .medium,
    this.textScale = 1,
    this.extras = false,
    this.stackedView = false,
    this.hideCup = false,
    this.infusions = 1,
    this.rightToLeft = false,
  });

  final String name;
  final int teaCount;
  final String teaName;
  final ButtonSize buttonSize;
  final double textScale;
  final bool extras;
  final bool stackedView;
  final bool hideCup;
  final int infusions;
  final bool rightToLeft;
}

const _scenarios = <_Scenario>[
  _Scenario('default settings'),
  _Scenario('an empty tea list', teaCount: 0),
  _Scenario('a single tea', teaCount: 1),
  _Scenario('many teas', teaCount: 8),
  _Scenario('the maximum number of teas', teaCount: teasMaxCount),
  _Scenario('stacked view', teaCount: 8, stackedView: true),
  _Scenario('no teacup', teaCount: 8, hideCup: true),
  _Scenario('small buttons', buttonSize: .small),
  _Scenario('large buttons with extra info', buttonSize: .large, extras: true),
  _Scenario('doubled text size', textScale: 2, extras: true),
  _Scenario(
    'the longest tea names',
    teaName: 'Breakfast Blend Tea',
    extras: true,
  ),
  _Scenario('multiple infusions', infusions: numInfusionsMax),
  _Scenario('a right to left language', rightToLeft: true),
];

void main() {
  setUp(() async {
    await setUpTestEnvironment();
    ShowcaseView.register();
    skipNotify = true;
  });

  for (final scenario in _scenarios) {
    testWidgets('Timer page layout with ${scenario.name}', (tester) async {
      addTearDown(tester.view.reset);

      for (final device in _devices) {
        await _checkLayout(tester, device, scenario);
      }
    });
  }
}

// Lay out the Timer page on one device, then check it as timers are started
Future<void> _checkLayout(
  WidgetTester tester,
  _Device device,
  _Scenario scenario,
) async {
  tester.view
    ..physicalSize = device.size * device.pixelRatio
    ..devicePixelRatio = device.pixelRatio
    ..padding = FakeViewPadding(
      top: device.topInset * device.pixelRatio,
      bottom: device.bottomInset * device.pixelRatio,
    )
    ..viewPadding = FakeViewPadding(
      top: device.topInset * device.pixelRatio,
      bottom: device.bottomInset * device.pixelRatio,
    );

  AppProvider provider = AppProvider()
    ..buttonSize = scenario.buttonSize
    ..showExtraList = scenario.extras
        ? ExtraInfo.values.toList()
        : <ExtraInfo>[]
    ..useBrewRatios = scenario.extras
    ..stackedView = scenario.stackedView
    ..cupStyle = scenario.hideCup ? .none : .classic
    ..teaList = <Tea>[
      for (int i = 1; i <= scenario.teaCount; i++)
        makeTea(
          id: i,
          name: _teaName(scenario.teaName, i),
          numInfusions: scenario.infusions,
          currentInfusion: scenario.infusions,
        ),
    ];

  await tester.pumpWidget(
    ChangeNotifierProvider<AppProvider>.value(
      value: provider,
      child: MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scenario.textScale)),
            child: scenario.rightToLeft
                ? const Directionality(
                    textDirection: .rtl,
                    child: TimerWidget(),
                  )
                : const TimerWidget(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Check the page idle, then again as each timer slot is filled
  int timerCount = scenario.teaCount < timersMaxCount
      ? scenario.teaCount
      : timersMaxCount;
  for (int running = 0; running <= timerCount; running++) {
    if (running > 0) {
      provider
        ..activateTea(provider.teaList[running - 1], running - 1, false)
        ..notifyTimerTick();
      await tester.pumpAndSettle();
    }

    String where =
        '${scenario.name} on ${device.name}, $running timer(s) running';
    _expectNoLayoutErrors(tester, where);
    _expectOnScreen(tester, device, where);
    _expectClearOfSafeArea(tester, device, where);
    _expectNoOverlap(tester, where);
    await _expectTeaButtonsReachable(tester, device, where);
  }
}

// Regions of the page that are laid out alongside each other, when present
Map<String, Rect> _regions(WidgetTester tester) {
  Finder cupImage = find.byType(Image);

  return <String, Rect>{
    'the Quick Timer button': tester.getRect(find.byType(QuickTimerButton)),
    'the Preferences button': tester.getRect(
      find.byIcon(platformSettingsIcon.icon!),
    ),
    'the countdown': tester.getRect(find.byType(TimerCountdownWidget)),
    // The teacup is absent when the cup style is set to none, and its box is
    // padded well away from the floating buttons that overlay the page
    if (cupImage.evaluate().isNotEmpty)
      'the teacup': _inset(
        tester.getRect(
          find
              .ancestor(of: cupImage.first, matching: find.byType(Container))
              .first,
        ),
        timerLayoutPadding.resolve(.ltr),
      ),
    'the tea buttons': tester.getRect(find.byType(TeaButtonList)),
  };
}

// Tea name as the app would store it, within the length it allows
String _teaName(String name, int index) {
  String teaName = '$name $index';
  return teaName.length > teaNameMaxLength
      ? teaName.substring(0, teaNameMaxLength)
      : teaName;
}

// A region shrunk by the padding around it
Rect _inset(Rect region, EdgeInsets padding) {
  return Rect.fromLTRB(
    region.left + padding.left,
    region.top + padding.top,
    region.right - padding.right,
    region.bottom - padding.bottom,
  );
}

// True if a region sits inside the given bounds
bool _isWithin(Rect region, Rect bounds) {
  return region.left >= bounds.left - _tolerance &&
      region.top >= bounds.top - _tolerance &&
      region.right <= bounds.right + _tolerance &&
      region.bottom <= bounds.bottom + _tolerance;
}

// Laying out the page must not overflow or throw
void _expectNoLayoutErrors(WidgetTester tester, String where) {
  expect(
    tester.takeException(),
    isNull,
    reason: 'laying out the page reported an error: $where',
  );
}

// Every region of the page must be on screen
void _expectOnScreen(WidgetTester tester, _Device device, String where) {
  Rect screen = Offset.zero & device.size;
  _regions(tester).forEach((String name, Rect region) {
    expect(
      _isWithin(region, screen),
      isTrue,
      reason: '$name at $region is not within the screen $screen: $where',
    );
  });
}

// Page content must not hide behind a notch or a home indicator
void _expectClearOfSafeArea(WidgetTester tester, _Device device, String where) {
  Rect notch = Rect.fromLTRB(
    0,
    0,
    device.size.width,
    device.topInset - _tolerance,
  );
  Rect homeIndicator = Rect.fromLTRB(
    0,
    device.size.height - device.bottomInset + _tolerance,
    device.size.width,
    device.size.height,
  );

  // The tea button list scrolls its rows through the bottom inset by design,
  // so its buttons are checked once scrolled into view instead
  Map<String, Rect>.of(_regions(tester))
    ..remove('the tea buttons')
    ..forEach((String name, Rect region) {
      expect(
        region.overlaps(notch),
        isFalse,
        reason: '$name at $region is behind the notch: $where',
      );
      expect(
        region.overlaps(homeIndicator),
        isFalse,
        reason: '$name at $region is behind the home indicator: $where',
      );
    });
}

// Regions of the page must not cover one another
void _expectNoOverlap(WidgetTester tester, String where) {
  List<MapEntry<String, Rect>> regions = _regions(tester).entries.toList();
  for (int i = 0; i < regions.length; i++) {
    for (int j = i + 1; j < regions.length; j++) {
      Rect first = regions[i].value.deflate(_tolerance);
      Rect second = regions[j].value.deflate(_tolerance);
      expect(
        first.overlaps(second),
        isFalse,
        reason:
            '${regions[i].key} at $first overlaps '
            '${regions[j].key} at $second: $where',
      );
    }
  }
}

// Every tea button must be reachable, scrolling to it if needed, and must
// land clear of the notch and the home indicator once it is
Future<void> _expectTeaButtonsReachable(
  WidgetTester tester,
  _Device device,
  String where,
) async {
  Rect visible = Rect.fromLTRB(
    0,
    device.topInset,
    device.size.width,
    device.size.height - device.bottomInset,
  );
  Finder buttons = find.byType(TeaButton);
  int count = buttons.evaluate().length;

  for (int i = 0; i < count; i++) {
    await tester.ensureVisible(buttons.at(i));
    await tester.pumpAndSettle();

    Rect button = tester.getRect(buttons.at(i));
    expect(
      button.top >= visible.top - _tolerance &&
          button.bottom <= visible.bottom + _tolerance,
      isTrue,
      reason:
          'tea button $i at $button cannot be scrolled clear of the notch '
          'and home indicator in $visible: $where',
    );

    // A long tea name can make a button wider than the screen, in which case
    // it need only fill the width rather than fit within it
    bool fitsAcross = button.width <= visible.width + _tolerance
        ? button.left >= visible.left - _tolerance &&
              button.right <= visible.right + _tolerance
        : button.left <= visible.left + _tolerance &&
              button.right >= visible.right - _tolerance;
    expect(
      fitsAcross,
      isTrue,
      reason:
          'tea button $i at $button cannot be scrolled across $visible: '
          '$where',
    );
  }

  // Leave the list where it started for the next check
  if (count > 0) {
    await tester.ensureVisible(buttons.first);
    await tester.pumpAndSettle();
  }
}
