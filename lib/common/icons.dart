/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    icons.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa icons

import 'package:cuppa_mobile/common/colors.dart';

import 'package:flutter/material.dart';

// Icons
const Icon navBarTeasIcon = Icon(Icons.timer_outlined, size: 28);

const Icon navBarSettingsIcon = Icon(Icons.list_alt, size: 28);

const Icon mutedIcon = Icon(
  Icons.volume_off,
  color: timerForegroundColor,
  size: 32,
);

const Icon unmutedIcon = Icon(
  Icons.volume_up,
  color: timerForegroundColor,
  size: 32,
);

const Icon dropdownArrow = Icon(Icons.arrow_drop_down, size: 24);

const Icon launchIcon = Icon(Icons.launch, size: 16);

const Icon dragHandle = Icon(Icons.drag_handle, size: 20);

const Icon clearIcon = Icon(
  Icons.cancel_outlined,
  size: 14,
  color: clearIconColor,
);

const Icon addIcon = Icon(Icons.add_circle, size: 20);

const Icon favoriteStarIcon = Icon(Icons.star, color: favoriteIconColor);

const Icon nonFavoriteStarIcon = Icon(Icons.star);

const Icon disabledStarIcon = Icon(Icons.star_border_outlined);

const Icon infoIcon = Icon(Icons.info, size: 20);

// Variable color icons
Icon customPresetIcon({required Color color}) {
  return Icon(Icons.add_circle, color: color, size: 20);
}

Icon cancelIcon({required Color color}) {
  return Icon(Icons.cancel, color: color, size: 14);
}

Icon navigateIcon({required Color color}) {
  return Icon(Icons.arrow_circle_right, size: 28, color: color);
}

Icon forwardIcon({required Color color}) {
  return Icon(Icons.arrow_forward, color: color);
}

// Icon data for increment buttons
const IconData incrementUpIcon = Icons.keyboard_arrow_up;
const IconData incrementDownIcon = Icons.keyboard_arrow_down;
const IconData incrementPlusIcon = Icons.add_circle_outline;
const IconData incrementMinusIcon = Icons.remove_circle_outline;
