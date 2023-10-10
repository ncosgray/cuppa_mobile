/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    constants.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

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
const unknownString = '?';

// About list item link URLs
const versionsURL = 'https://github.com/ncosgray/cuppa_mobile/releases';
const licenseURL =
    'https://github.com/ncosgray/cuppa_mobile/blob/master/LICENSE.txt';
const sourceURL = 'https://github.com/ncosgray/cuppa_mobile';
const translateURL = 'https://hosted.weblate.org/engage/cuppa/';
const issuesURL = 'https://github.com/ncosgray/cuppa_mobile/issues';
const privacyURL = 'https://www.nathanatos.com/privacy/';

// Cup images
const cupImageDefault = 'images/Cuppa_hires_default.png';
const cupImageBorder = 'images/Cuppa_hires_border.png';
const cupImageBag = 'images/Cuppa_hires_bag.png';
const cupImageTea = 'images/Cuppa_hires_tea.png';

// Limits
const teaNameMaxLength = 20;
const teaBrewTimeMaxMinutes = 60;
const teaBrewTimeMaxHours = 24;
const teasMaxCount = 15;
const timersMaxCount = 2;

// UI sizing thresholds
const maxTextScale = 1.4;
const largeDeviceSize = 550;

// Notifications
const notifyID1 = 0;
const notifyID2 = 1;
const notifyChannel = 'Cuppa_timer_channel';
const notifyIcon = 'ic_stat_name';
const notifySound = 'spoon';
const notifySoundIOS = 'sound/spoon.aiff';

// Quick actions
const favoritesMaxCount = 4; // iOS limitation
const shortcutPrefix = 'shortcutTea';
const shortcutPrefixID = 'shortcutID';
const shortcutIconIOS = 'QuickAction';
const shortcutIconIOSCup = 'QuickActionCup';
const shortcutIconIOSFlower = 'QuickActionFlower';
const shortcutIconRed = 'ic_shortcut_red';
const shortcutIconOrange = 'ic_shortcut_orange';
const shortcutIconGreen = 'ic_shortcut_green';
const shortcutIconBlue = 'ic_shortcut_blue';
const shortcutIconPurple = 'ic_shortcut_purple';
const shortcutIconBrown = 'ic_shortcut_brown';
const shortcutIconPink = 'ic_shortcut_pink';
const shortcutIconAmber = 'ic_shortcut_amber';
const shortcutIconTeal = 'ic_shortcut_teal';
const shortcutIconCyan = 'ic_shortcut_cyan';
const shortcutIconLavender = 'ic_shortcut_lavender';
const shortcutIconBlack = 'ic_shortcut_black';
const shortcutIconCupRed = 'ic_shortcut_cup_red';
const shortcutIconCupOrange = 'ic_shortcut_cup_orange';
const shortcutIconCupGreen = 'ic_shortcut_cup_green';
const shortcutIconCupBlue = 'ic_shortcut_cup_blue';
const shortcutIconCupPurple = 'ic_shortcut_cup_purple';
const shortcutIconCupBrown = 'ic_shortcut_cup_brown';
const shortcutIconCupPink = 'ic_shortcut_cup_pink';
const shortcutIconCupAmber = 'ic_shortcut_cup_amber';
const shortcutIconCupTeal = 'ic_shortcut_cup_teal';
const shortcutIconCupCyan = 'ic_shortcut_cup_cyan';
const shortcutIconCupLavender = 'ic_shortcut_cup_lavender';
const shortcutIconCupBlack = 'ic_shortcut_cup_black';
const shortcutIconFlowerRed = 'ic_shortcut_flower_red';
const shortcutIconFlowerOrange = 'ic_shortcut_flower_orange';
const shortcutIconFlowerGreen = 'ic_shortcut_flower_green';
const shortcutIconFlowerBlue = 'ic_shortcut_flower_blue';
const shortcutIconFlowerPurple = 'ic_shortcut_flower_purple';
const shortcutIconFlowerBrown = 'ic_shortcut_flower_brown';
const shortcutIconFlowerPink = 'ic_shortcut_flower_pink';
const shortcutIconFlowerAmber = 'ic_shortcut_flower_amber';
const shortcutIconFlowerTeal = 'ic_shortcut_flower_teal';
const shortcutIconFlowerCyan = 'ic_shortcut_flower_cyan';
const shortcutIconFlowerLavender = 'ic_shortcut_flower_lavender';
const shortcutIconFlowerBlack = 'ic_shortcut_flower_black';

// Shared prefs keys for tea definitions
const prefTea1Name = 'Cuppa_tea1_name';
const prefTea1BrewTime = 'Cuppa_tea1_brew_time';
const prefTea1BrewTemp = 'Cuppa_tea1_brew_temp';
const prefTea1Color = 'Cuppa_tea1_color';
const prefTea1Icon = 'Cuppa_tea1_icon';
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
const prefTeaList = 'Cuppa_tea_list';

// Shared prefs keys for other settings
const prefNextTeaID = 'Cuppa_next_tea_id';
const prefShowExtra = 'Cuppa_show_extra';
const prefUseCelsius = 'Cuppa_use_celsius';
const prefAppTheme = 'Cuppa_app_theme';
const prefAppLanguage = 'Cuppa_app_language';
const prefSkipTutorial = 'Cuppa_skip_tutorial';
const prefShowIncrementsAlways = 'Cuppa_show_increments_always';

// More teas JSON keys
const jsonKeyID = 'id';
const jsonKeyName = 'name';
const jsonKeyBrewTime = 'brewTime';
const jsonKeyBrewTemp = 'brewTemp';
const jsonKeyColor = 'color';
const jsonKeyColorShadeRed = 'colorShadeRed';
const jsonKeyColorShadeGreen = 'colorShadeGreen';
const jsonKeyColorShadeBlue = 'colorShadeBlue';
const jsonKeyIcon = 'icon';
const jsonKeyIsFavorite = 'isFavorite';
const jsonKeyIsActive = 'isActive';
const jsonKeyTimerEndTime = 'timerEndTime';
const jsonKeyTimerNotifyID = 'timerNotifyID';

// Localization
const defaultLanguage = 'en';
const followSystemLanguage = '';

// Animation durations
const shortAnimationDuration = Duration(milliseconds: 100);
const longAnimationDuration = Duration(milliseconds: 200);

// Timer increments
const incrementSeconds = 10;
const hideTimerIncrementsDelay = 5;
