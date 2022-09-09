/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    constants.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa constants
// - App info, prefs keys, settings limits

// App info
const appName = 'Cuppa';
const appIcon = 'images/Cuppa_icon.png';
const aboutCopyright = '\u00a9 Nathan Cosgray';
const aboutURL = 'https://nathanatos.com';

// Routes
const routeAbout = '/about';
const routePrefs = '/prefs';
const routeTimer = '/';

// About list item link URLs
const versionsURL = 'https://github.com/ncosgray/cuppa_mobile/releases';
const licenseURL =
    'https://github.com/ncosgray/cuppa_mobile/blob/master/LICENSE.txt';
const sourceURL = 'https://github.com/ncosgray/cuppa_mobile';
const translateURL = 'https://hosted.weblate.org/engage/cuppa/';
const issuesURL = 'https://github.com/ncosgray/cuppa_mobile/issues';

// Cup images
const cupImageDefault = 'images/Cuppa_hires_default.png';
const cupImageBag = 'images/Cuppa_hires_bag.png';
const cupImageTea = 'images/Cuppa_hires_tea.png';

// Limits
const teaNameMaxLength = 16;
const teasMinCount = 3;
const teasMaxCount = 15;

// UI sizing thresholds
const maxTextScale = 1.4;
const largeDeviceSize = 550;

// Notifications
const notifyID = 0;
const notifyChannel = 'Cuppa_timer_channel';
const notifyIcon = 'ic_stat_name';
const notifySound = 'spoon';
const notifySoundIOS = 'sound/spoon.aiff';

// Quick actions
const favoritesMaxCount = 4; // iOS limitation
const shortcutPrefix = 'shortcutTea';
const shortcutIconIOS = 'QuickAction';
const shortcutIconRed = 'shortcut_red';
const shortcutIconOrange = 'shortcut_orange';
const shortcutIconGreen = 'shortcut_green';
const shortcutIconBlue = 'shortcut_blue';
const shortcutIconPurple = 'shortcut_purple';
const shortcutIconBrown = 'shortcut_brown';
const shortcutIconPink = 'shortcut_pink';
const shortcutIconAmber = 'shortcut_amber';
const shortcutIconTeal = 'shortcut_teal';
const shortcutIconCyan = 'shortcut_cyan';
const shortcutIconLavender = 'shortcut_lavender';
const shortcutIconBlack = 'shortcut_black';

// Shared prefs keys for tea definitions
const prefTea1Name = 'Cuppa_tea1_name';
const prefTea1BrewTime = 'Cuppa_tea1_brew_time';
const prefTea1BrewTemp = 'Cuppa_tea1_brew_temp';
const prefTea1Color = 'Cuppa_tea1_color';
const prefTea1IsFavorite = 'Cuppa_tea1_is_favorite';
const prefTea1IsActive = 'Cuppa_tea1_is_active';
const prefTea2Name = 'Cuppa_tea2_name';
const prefTea2BrewTime = 'Cuppa_tea2_brew_time';
const prefTea2BrewTemp = 'Cuppa_tea2_brew_temp';
const prefTea2Color = 'Cuppa_tea2_color';
const prefTea2IsFavorite = 'Cuppa_tea2_is_favorite';
const prefTea2IsActive = 'Cuppa_tea2_is_active';
const prefTea3Name = 'Cuppa_tea3_name';
const prefTea3BrewTime = 'Cuppa_tea3_brew_time';
const prefTea3BrewTemp = 'Cuppa_tea3_brew_temp';
const prefTea3Color = 'Cuppa_tea3_color';
const prefTea3IsFavorite = 'Cuppa_tea3_is_favorite';
const prefTea3IsActive = 'Cuppa_tea3_is_active';
const prefMoreTeas = 'Cuppa_tea_list';

// Shared prefs keys for other settings
const prefShowExtra = 'Cuppa_show_extra';
const prefUseCelsius = 'Cuppa_use_celsius';
const prefAppTheme = 'Cuppa_app_theme';
const prefAppLanguage = 'Cuppa_app_language';

// Shared prefs keys for next alarm info
const prefNextAlarm = 'Cuppa_next_alarm_time';

// More teas JSON keys
const jsonKeyName = 'name';
const jsonKeyBrewTime = 'brewTime';
const jsonKeyBrewTemp = 'brewTemp';
const jsonKeyColor = 'color';
const jsonKeyIsFavorite = 'isFavorite';
const jsonKeyIsActive = 'isActive';
