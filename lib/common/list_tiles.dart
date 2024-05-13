/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    list_tiles.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa list tiles

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/separators.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Setting switch
Widget settingSwitch(
  BuildContext context, {
  required String title,
  String? subtitle,
  required bool value,
  required Function(bool) onChanged,
}) {
  return AnimatedSize(
    duration: shortAnimationDuration,
    child: SwitchListTile.adaptive(
      title: Text(
        title,
        style: textStyleTitle,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: textStyleSubtitle,
            )
          : null,
      value: value,
      onChanged: onChanged,
      contentPadding: listTilePadding,
      dense: true,
    ),
  );
}

// Setting list
Widget settingList(
  BuildContext context, {
  required String title,
  required String selectedItem,
  required List<dynamic> itemList,
  required Widget Function(BuildContext, int) itemBuilder,
}) {
  double maxWidth = (getDeviceSize(context).width / 2.0) - 12.0;

  return AnimatedSize(
    duration: shortAnimationDuration,
    child: ListTile(
      title: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Text(
          title,
          style: textStyleTitle,
        ),
      ),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Text(
          selectedItem,
          textAlign: TextAlign.end,
          style: textStyleTitle.copyWith(
            color: Theme.of(context).textTheme.bodySmall!.color!,
          ),
        ),
      ),
      onTap: () => openPlatformAdaptiveSelectList(
        context: context,
        titleText: title,
        buttonTextCancel: AppString.cancel_button.translate(),
        itemList: itemList,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorDummy,
      ),
      contentPadding: listTilePadding,
      dense: true,
    ),
  );
}

// Setting list item
Widget settingListItem(
  BuildContext context, {
  required String title,
  required dynamic value,
  required dynamic groupValue,
  required Function(dynamic)? onChanged,
}) {
  return RadioListTile.adaptive(
    contentPadding: radioTilePadding,
    dense: true,
    useCupertinoCheckmarkStyle: true,
    title: Text(
      title,
      style: textStyleTitle,
    ),
    value: value,
    groupValue: groupValue,
    onChanged: onChanged,
  );
}

// About link
Widget aboutLink({
  required String title,
  String? subtitle,
  String? url,
  Function()? onTap,
}) {
  return InkWell(
    child: ListTile(
      title: Text(title, style: textStyleTitle),
      subtitle:
          subtitle != null ? Text(subtitle, style: textStyleSubtitle) : null,
      trailing: url != null ? launchIcon : null,
      onTap: url != null
          ? () =>
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)
          : onTap,
      contentPadding: listTilePadding,
      dense: true,
    ),
  );
}
