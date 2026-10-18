/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    localization_test.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa unit tests: translation files
// - Default language has every string, since others fall back to it
// - Every language parses, uses known keys, and keeps placeholders intact

import 'package:cuppa_mobile/data/localization.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final RegExp _placeholder = RegExp(r'{{\w+}}');

Map<String, dynamic> _load(File file) =>
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

Set<String> _placeholders(String text) =>
    _placeholder.allMatches(text).map((match) => match[0]!).toSet();

void main() {
  final Set<String> keys = AppString.values.map((string) => string.key).toSet();
  final Map<String, dynamic> defaults = _load(
    File('langs/${localeString(defaultLocale)}.json'),
  );
  final List<File> files =
      Directory('langs').listSync().whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('default language has every string', () {
    expect(keys.difference(defaults.keys.toSet()), isEmpty);
  });

  for (final File file in files) {
    test('${file.uri.pathSegments.last} is well formed', () {
      final Map<String, dynamic> strings = _load(file);
      expect(strings.keys.toSet().difference(keys), isEmpty);
      for (final MapEntry<String, dynamic> entry in strings.entries) {
        expect(entry.value, isA<String>(), reason: entry.key);
        // A string missing from the default language is reported above
        if (defaults[entry.key] is String) {
          expect(
            _placeholders(entry.value),
            _placeholders(defaults[entry.key]),
            reason: entry.key,
          );
        }
      }
    });
  }
}
