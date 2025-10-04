/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    constants.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa constants
// - App info, defaults, prefs keys, settings limits

// App info
const appName = 'Cuppa';
const appIcon = 'images/Cuppa_icon.png';
const aboutCopyright = '\u00a9 Nathan Cosgray';
const aboutURL = 'https://nathanatos.com';

// About list item link URLs
const versionsURL = 'https://github.com/ncosgray/cuppa_mobile/releases';
const licenseURL =
    'https://github.com/ncosgray/cuppa_mobile/blob/master/LICENSE.txt';
const sourceURL = 'https://github.com/ncosgray/cuppa_mobile';
const translateURL = 'https://hosted.weblate.org/engage/cuppa/';
const issuesURL = 'https://github.com/ncosgray/cuppa_mobile/issues';
const privacyURL = 'https://www.nathanatos.com/privacy/';
const supportURL =
    'https://github.com/ncosgray/cuppa_mobile?tab=readme-ov-file#support-the-project';

// Cup images
const cupImageClassic = 'images/Cuppa_hires_default.png';
const cupImageMug = 'images/Cuppa_hires_mug.png';
const cupImageFloral = 'images/Cuppa_hires_floral.png';
const cupImageChinese = 'images/Cuppa_hires_chinese.png';
const cupImageBag = 'images/Cuppa_hires_bag.png';
const cupImageTea = 'images/Cuppa_hires_tea.png';

// Limits
const teaNameMaxLength = 20;
const teaBrewTimeMaxMinutes = 60;
const teaBrewTimeMaxHours = 24;
const teasMaxCount = 15;
const timersMaxCount = 2;
const stackedViewTeaCount = 3;

// Defaults
const unknownString = '?';
const defaultBrewTime = 240;
const defaultTeaColorValue = 0;
const defaultTeaIconValue = 0;
const double defaultBrewRatioNumeratorG = 3;
const double defaultBrewRatioNumeratorTsp = 1;
const defaultBrewRatioDenominatorMl = 250;
const defaultBrewRatioDenominatorOz = 8;

// Temperatures
const boilDegreesC = 100;
const boilDegreesF = 212;
const minDegreesC = 45;
const minDegreesF = 102;
const roomTemp = 0;
const roomTempDegreesC = 20;
const roomTempDegreesF = 68;

// Brewing ratios
const double brewRatioNumeratorMin = 0;
const double brewRatioNumeratorMax = 20;
const double brewRatioNumeratorStep = 0.5;

// UI sizing thresholds
const largeDeviceSize = 550;

// Widget sizes
const double teaButtonHeight = 106;
const double teaButtonWidth = 88;
const double cancelButtonHeight = 34;

// Notifications
const notifyID1 = 0;
const notifyID2 = 1;
const notifyChannel = 'Cuppa_timer_channel';
const notifyChannelSilent = 'Cuppa_silent_channel';
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
const prefShowExtraList = 'Cuppa_show_extra_list';
const prefHideIncrements = 'Cuppa_hide_increments';
const prefSilentDefault = 'Cuppa_silent_default';
const prefStackedView = 'Cuppa_stacked_view';
const prefCollectStats = 'Cuppa_collect_stats';
const prefUseCelsius = 'Cuppa_use_celsius';
const prefUseBrewRatios = 'Cuppa_use_brew_ratios';
const prefCupStyle = 'Cuppa_cup_style';
const prefAppTheme = 'Cuppa_app_theme';
const prefAppLanguage = 'Cuppa_app_language';
const prefSkipTutorial = 'Cuppa_skip_tutorial';
const prefReviewPromptCounter = 'Cuppa_review_prompt_counter';
const prefMigratedPrefs = 'Cuppa_migrated_prefs';

// JSON keys
const jsonKeySettings = 'settings';
const jsonKeyNextTeaID = 'nextTeaID';
const jsonKeyShowExtra = 'showExtra';
const jsonKeyShowExtraList = 'showExtraList';
const jsonKeyHideIncrements = 'hideIncrements';
const jsonKeySilentDefault = 'silentDefault';
const jsonKeyStackedView = 'stackedView';
const jsonKeyUseCelsius = 'useCelsius';
const jsonKeyUseBrewRatios = 'useBrewRatios';
const jsonKeyCupStyle = 'cupStyle';
const jsonKeyAppTheme = 'appTheme';
const jsonKeyAppLanguage = 'appLanguage';
const jsonKeyCollectStats = 'collectStats';
const jsonKeyTeas = 'teaList';
const jsonKeyID = 'id';
const jsonKeyName = 'name';
const jsonKeyBrewTime = 'brewTime';
const jsonKeyBrewTemp = 'brewTemp';
const jsonKeyBrewRatio = 'brewRatio';
const jsonKeyBrewRatioNumerator = 'brewRatioNumerator';
const jsonKeyBrewRatioDenominator = 'brewRatioDenominator';
const jsonKeyBrewRatioMetricNumerator = 'brewRatioMetricNumerator';
const jsonKeyBrewRatioMetricDenominator = 'brewRatioMetricDenominator';
const jsonKeyColor = 'color';
const jsonKeyColorShadeRed = 'colorShadeRed';
const jsonKeyColorShadeGreen = 'colorShadeGreen';
const jsonKeyColorShadeBlue = 'colorShadeBlue';
const jsonKeyIcon = 'icon';
const jsonKeyIsFavorite = 'isFavorite';
const jsonKeyIsActive = 'isActive';
const jsonKeyIsSilent = 'isSilent';
const jsonKeyTimerEndTime = 'timerEndTime';
const jsonKeyTimerNotifyID = 'timerNotifyID';
const jsonKeyStats = 'stats';
const jsonKeyTimerStartTime = 'timerStartTime';
const jsonKeyBrewAmount = 'brewAmount';
const jsonKeyBrewAmountMetric = 'brewAmountMetric';

// Export file
const exportFileName = 'CuppaData';
const exportFileExtension = 'json';

// Localization
const followSystemLanguage = '';

// Animation durations
const shortAnimationDuration = Duration(milliseconds: 100);
const longAnimationDuration = Duration(milliseconds: 200);

// Timer adjustments
const incrementSeconds = 10;
const hideTimerAdjustmentsDelay = 5;

// Temperature index increments
const brewTempIncrement = 5;

// App store review prompt
const reviewPromptAtCount = 30;
const promptDelayDuration = Duration(milliseconds: 500);

// Stats data
const statsDatabase = 'Cuppa_stats.db';
const statsTable = 'statsData';
const statsColumnId = 'id';
const statsColumnName = 'name';
const statsColumnBrewTime = 'brewTime';
const statsColumnBrewTemp = 'brewTemp';
const statsColumnBrewAmount = 'brewAmount';
const statsColumnBrewAmountMetric = 'brewAmountMetric';
const statsColumnColorShadeRed = 'colorShadeRed';
const statsColumnColorShadeGreen = 'colorShadeGreen';
const statsColumnColorShadeBlue = 'colorShadeBlue';
const statsColumnIconValue = 'iconValue';
const statsColumnIsFavorite = 'isFavorite';
const statsColumnTimerStartTime = 'timerStartTime';
const statsColumnCount = 'count';
const statsColumnMetric = 'metric';
const statsColumnString = 'string';

// Opacities
const noOpacity = 1.0;
const fadeOpacity = 0.4;
const fullOpacity = 0.0;

// Symbols
const starSymbol = '\u2605';
const degreeSymbol = '\u00b0';
const hairSpace = '\u200a';
const emDash = '\u2014';
