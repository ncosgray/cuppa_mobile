// Taken from https://github.com/efortuna/memechat with modifications:
// - For Android buttons include text as well as icon
// - Change theme colors
// - Add dark themes for Android and iOS

// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

final ThemeData kIOSTheme = new ThemeData(
  primaryColor: Colors.grey[100],
  buttonColor: Colors.black54,
  brightness: Brightness.light,
);

final ThemeData kIOSDarkTheme = new ThemeData(
  primaryColor: Colors.grey[900],
  buttonColor: Colors.grey,
  brightness: Brightness.dark,
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.blueAccent[400],
  buttonColor: Colors.black54,
  brightness: Brightness.light,
);

final ThemeData kDarkTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.blueAccent[400],
  buttonColor: Colors.grey,
  brightness: Brightness.dark,
);

/// App bar that uses iOS styling on iOS
class PlatformAdaptiveAppBar extends AppBar {
  PlatformAdaptiveAppBar({
    Key key,
    TargetPlatform platform,
    List<Widget> actions,
    Widget title,
    Widget body,
  })
      : super(
          key: key,
          elevation: platform == TargetPlatform.iOS ? 0.0 : 4.0,
          title: title,
          actions: actions,
        );
}

/// Button that is Material on Android and Cupertino on iOS
/// On Android an icon button with text; on iOS, only text is used
class PlatformAdaptiveButton extends StatelessWidget {
  PlatformAdaptiveButton({Key key, this.child, this.icon, this.onPressed})
      : super(key: key);
  final Widget child;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return new CupertinoButton(
        child: child,
        onPressed: onPressed,
      );
    } else {
      return new IconButton(
        padding: const EdgeInsets.all(0.0),
        icon: new Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [icon, child]),
        onPressed: onPressed,
      );
    }
  }
}

class PlatformAdaptiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;

  PlatformAdaptiveContainer({Key key, this.child, this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: child,
      margin: margin,
      decoration: Theme.of(context).platform == TargetPlatform.iOS
          ? new BoxDecoration(
              border: new Border(top: new BorderSide(color: Colors.grey[200])))
          : null,
    );
  }
}

class PlatformChooser extends StatelessWidget {
  PlatformChooser({Key key, this.iosChild, this.defaultChild});
  final Widget iosChild;
  final Widget defaultChild;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) return iosChild;
    return defaultChild;
  }
}
