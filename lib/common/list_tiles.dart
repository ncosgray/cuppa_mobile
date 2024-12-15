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
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/common/separators.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Setting switch
Widget settingSwitch({
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
  Image? selectedItemImage,
  required List<dynamic> itemList,
  required Widget Function(BuildContext, int) itemBuilder,
}) {
  double maxWidth = getDeviceSize(context).width - 24.0;
  if (getDeviceSize(context).isLargeDevice) {
    maxWidth /= 2.0;
  }

  return AnimatedSize(
    duration: shortAnimationDuration,
    child: ListTile(
      title: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth * 0.6),
        child: Text(
          title,
          style: textStyleTitle,
        ),
      ),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth * 0.4),
        child: settingListTitle(
          title: selectedItem,
          color: Theme.of(context).textTheme.bodySmall!.color!,
          image: selectedItemImage,
          alignEnd: true,
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
    ),
  );
}

// Setting list item
Widget settingListItem(
  BuildContext context, {
  required String title,
  Image? titleImage,
  required dynamic value,
  required dynamic groupValue,
  required Function() onChanged,
}) {
  return adaptiveSelectListAction(
    action: RadioListTile.adaptive(
      contentPadding: radioTilePadding,
      dense: true,
      useCupertinoCheckmarkStyle: true,
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).listTileTheme.iconColor,
      ),
      title: settingListTitle(
        title: title,
        color: Theme.of(context).textTheme.bodyLarge!.color!,
        image: titleImage,
      ),
      value: value,
      groupValue: groupValue,
      onChanged: null, // Handled by select list action tap
    ),
    onTap: onChanged,
  );
}

// Setting list title with optional image
Widget settingListTitle({
  required String title,
  required Color color,
  Image? image,
  bool alignEnd = false,
}) {
  // Build title row
  List<Widget> titleWidgets = [
    Flexible(
      child: Text(
        title,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: textStyleTitle.copyWith(color: color),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ];
  if (image != null) {
    titleWidgets.add(
      SizedBox(
        width: 28,
        height: 28,
        child: image,
      ),
    );
  }

  return Row(
    mainAxisAlignment:
        alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
    spacing: smallSpacing,
    children: titleWidgets,
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
