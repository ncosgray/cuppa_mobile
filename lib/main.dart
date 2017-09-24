// Cuppa: a simple tea timer app for Android and iOS
// By Nathan Cosgray
// www.nathanatos.com/software

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'platform_adaptive.dart';
import 'timer.dart';

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
      home: new Scaffold(
          appBar: new PlatformAdaptiveAppBar(
            title: new Text('  Cuppa  '),
            platform: Theme.of(context).platform,
          ),
          body: new TimerWidget()),
    );
  }
}
