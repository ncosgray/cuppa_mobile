// Cuppa main.dart
// Author: Nathan Cosgray | https://www.nathanatos.com

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'platform_adaptive.dart';
import 'timer.dart';

// Cuppa: a simple tea timer app for Android and iOS

void main() {
  runApp(new CuppaApp());
}

class CuppaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Cuppa',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      darkTheme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSDarkTheme
          : kDarkTheme,
      home: new Scaffold(
          appBar: new PlatformAdaptiveAppBar(
            title: new Text('  Cuppa  '),
            platform: Theme.of(context).platform,
          ),
          body: new TimerWidget()),
    );
  }
}
