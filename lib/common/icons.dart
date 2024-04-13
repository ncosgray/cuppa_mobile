/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    icons.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa icons

import 'package:cuppa_mobile/common/colors.dart';

import 'package:flutter/material.dart';

// Icons
const Icon mutedIcon = Icon(
  Icons.volume_off,
  color: timerForegroundColor,
  size: 32.0,
);

const Icon unmutedIcon = Icon(
  Icons.volume_up,
  color: timerForegroundColor,
  size: 32.0,
);

const Icon dropdownArrow = Icon(
  Icons.arrow_drop_down,
  size: 24.0,
);

const Icon launchIcon = Icon(
  Icons.launch,
  size: 16.0,
);

const Icon dragHandle = Icon(
  Icons.drag_handle,
  size: 20.0,
);

const Icon clearIcon = Icon(
  Icons.cancel_outlined,
  size: 14.0,
  color: clearIconColor,
);

const Icon addIcon = Icon(
  Icons.add_circle,
  size: 20.0,
);

const Icon editIcon = Icon(
  Icons.edit,
  size: 20.0,
);

const Icon favoriteStarIcon = Icon(
  Icons.star,
  color: favoriteIconColor,
);

const Icon nonFavoriteStarIcon = Icon(
  Icons.star,
);

const Icon disabledStarIcon = Icon(
  Icons.star_border_outlined,
);

const Icon infoIcon = Icon(
  Icons.info,
  size: 20.0,
);

const Icon exportIcon = Icon(
  Icons.save,
);

const Icon importIcon = Icon(
  Icons.upload_file,
);

// Variable color icons
Icon customPresetIcon({required Color color}) {
  return Icon(
    Icons.add_circle,
    color: color,
    size: 20.0,
  );
}

Icon cancelIcon({required Color color}) {
  return Icon(
    Icons.cancel,
    color: color,
    size: 14.0,
  );
}

Icon navigateIcon({required Color color}) {
  return Icon(
    Icons.arrow_circle_right,
    size: 28.0,
    color: color,
  );
}

// Icon data for increment buttons
const IconData incrementUpIcon = Icons.keyboard_arrow_up;
const IconData incrementDownIcon = Icons.keyboard_arrow_down;
const IconData incrementPlusIcon = Icons.add_circle_outline;
const IconData incrementMinusIcon = Icons.remove_circle_outline;
