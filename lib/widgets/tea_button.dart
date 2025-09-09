/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_button.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea timer button

import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Widget defining a tea brew start button
class TeaButton extends StatelessWidget {
  const TeaButton({
    super.key,
    required this.tea,
    required this.fade,
    this.onPressed,
  });

  final Tea tea;
  final bool fade;
  final Function()? onPressed;

  void _handleTap() {
    if (onPressed != null) {
      HapticFeedback.lightImpact();
      onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    Color textColor = tea.isActive ? timerActiveColor : tea.getColor();

    return Card(
      margin: largeDefaultPadding,
      elevation: tea.isActive ? 0.0 : 1.0,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(color: tea.isActive ? tea.getColor() : null),
        child: IgnorePointer(
          ignoring: onPressed == null,
          child: InkWell(
            onTap: _handleTap,
            child: AnimatedOpacity(
              opacity: fade ? fadeOpacity : noOpacity,
              duration: longAnimationDuration,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: teaButtonHeight,
                  minWidth: teaButtonWidth,
                ),
                margin: largeDefaultPadding,
                // Timer icon with tea name
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tea.teaIcon, color: textColor, size: 64),
                    Text(
                      tea.name,
                      style: textStyleButton.copyWith(color: textColor),
                    ),
                    // Optional extra info: brew time, temp, and ratio display
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Brew time
                            _extraInfoItem(
                              infoType: ExtraInfo.brewTime,
                              text: formatTimer(tea.brewTime),
                              color: textColor,
                            ),
                            // Brew temperature
                            _extraInfoItem(
                              infoType: ExtraInfo.brewTemp,
                              text: tea.brewTemp > roomTemp
                                  ? tea.getTempDisplay(
                                      useCelsius: provider.useCelsius,
                                    )
                                  : '',
                              color: textColor,
                            ),
                          ],
                        ),
                        // Brew ratio
                        _extraInfoItem(
                          infoType: ExtraInfo.brewRatio,
                          text: tea.brewRatio.ratioString,
                          color: textColor,
                          isEnabled: provider.useBrewRatios,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Text widget for extra info item
  Widget _extraInfoItem({
    required ExtraInfo infoType,
    required String text,
    required Color color,
    bool isEnabled = true,
  }) {
    return Selector<AppProvider, bool>(
      selector: (_, provider) =>
          isEnabled && provider.showExtraList.contains(infoType),
      builder: (context, isVisible, child) => Visibility(
        visible: isVisible,
        child: Container(
          padding: rowPadding,
          child: Text(
            text,
            style: textStyleButtonTertiary.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}
