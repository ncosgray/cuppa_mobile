/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    notify_issue_test.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa unit tests: notification issue checks
// - No iOS warning before permission has been requested
// - No Android warning before permission has been requested
// - Silent default suppressing the muted channel warning on Android

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/local_notifications.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

const MethodChannel _notifyChannel = MethodChannel('cuppa_notifications');

void main() {
  setUp(() async {
    await setUpTestEnvironment();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_notifyChannel, null);
  });

  test('no iOS warning before permission has been requested', () async {
    // Sound and Time Sensitive read as unsupported until permission is asked
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _notifyChannel,
          (MethodCall call) async => {
            'status': 'notDetermined',
            'soundEnabled': false,
            'timeSensitiveEnabled': false,
          },
        );
    expect(await checkNotifyIssueIOS(), isNull);
  });

  test('no Android warning before permission has been requested', () {
    // Android 13+ reports notifications disabled until permission is asked
    expect(notifyIssueAndroid(enabled: false, channels: []), isNull);
  });

  test('silent default ignores Android muted channel but not disabled', () {
    const AndroidNotificationChannel mutedChannel = .new(
      notifyChannel,
      'Timer notifications',
      playSound: false,
    );
    expect(
      notifyIssueAndroid(enabled: true, channels: [mutedChannel], silent: true),
      isNull,
    );
    expect(
      notifyIssueAndroid(
        enabled: false,
        channels: [mutedChannel],
        silent: true,
      ),
      NotifyIssue.disabled,
    );
  });
}
