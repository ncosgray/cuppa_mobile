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
  indent: 12.0,
  endIndent: 12.0,
);

// About text linking to app website
Widget aboutText() {
  return InkWell(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
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
    ),
    onTap: () =>
        launchUrl(Uri.parse(aboutURL), mode: LaunchMode.externalApplication),
  );
}

// Dismissible delete warning background
Widget dismissibleBackground(BuildContext context, Alignment alignment) {
  return Container(
    color: Theme.of(context).colorScheme.error,
    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
    child: Padding(
      padding: const EdgeInsets.all(14.0),
      child: Align(
        alignment: alignment,
        child: getPlatformRemoveIcon(
          Theme.of(context).colorScheme.onError,
        ),
      ),
    ),
  );
}

// Custom draggable feedback for reorderable list
Widget draggableFeedback(
  Widget child,
  int index,
  Animation<double> animation,
) {
  return Container(
    decoration: const BoxDecoration(
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.grey,
          blurRadius: 14.0,
        ),
      ],
    ),
    child: child,
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

const Widget clearIcon = Icon(
  Icons.cancel_outlined,
  size: 14.0,
  color: Colors.grey,
);
