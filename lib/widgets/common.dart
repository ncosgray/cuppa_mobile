/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    common.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa utility widgets

import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// List divider
const Widget listDivider = Divider(
  thickness: 1.0,
  indent: 6.0,
  endIndent: 6.0,
);

// About text linking to app website
Widget aboutText() {
  return InkWell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(AppString.about_app.translate(), style: textStyleFooter),
        const Row(
          children: [
            Text(aboutCopyright, style: textStyleFooter),
            VerticalDivider(),
            Text(aboutURL, style: textStyleFooterLink),
          ],
        ),
      ],
    ),
    onTap: () =>
        launchUrl(Uri.parse(aboutURL), mode: LaunchMode.externalApplication),
  );
}

// Dismissible delete warning background
Widget dismissibleBackground(BuildContext context, Alignment alignment) {
  return Container(
    padding: const EdgeInsets.all(5.0),
    child: Container(
      color: Theme.of(context).colorScheme.error,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Align(
          alignment: alignment,
          child: getPlatformRemoveIcon(
            Theme.of(context).colorScheme.onError,
          ),
        ),
      ),
    ),
  );
}

// Custom draggable feedback for reorderable list
Widget draggableFeedback(
  BuildContext context,
  BoxConstraints constraints,
  Widget child,
) {
  return Transform(
    transform: Matrix4.rotationZ(0),
    alignment: FractionalOffset.topLeft,
    child: Container(
      decoration: const BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey,
            blurRadius: 7.0,
            offset: Offset(0.0, 0.75),
          ),
        ],
      ),
      child: ConstrainedBox(constraints: constraints, child: child),
    ),
  );
}

// Preview of a tea button with color and theme
Widget miniTeaButton({
  required Color? color,
  required IconData icon,
  bool isActive = false,
  bool darkTheme = false,
}) {
  return Theme(
    data: darkTheme ? ThemeData.dark() : ThemeData.light(),
    child: Card(
      elevation: 1.0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(color: isActive ? color : null),
        child: Container(
          margin: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: isActive ? Colors.white : color,
            size: 28.0,
          ),
        ),
      ),
    ),
  );
}

// Icons
const Widget dropdownArrow = Icon(
  Icons.arrow_drop_down,
  size: 24.0,
);

const Widget launchIcon = Icon(
  Icons.launch,
  size: 16.0,
);

const Widget dragHandle = Icon(
  Icons.drag_handle,
  size: 20.0,
);
