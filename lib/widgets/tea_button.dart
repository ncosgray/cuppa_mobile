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
                    Icon(
                      tea.teaIcon,
                      color: tea.isActive ? timerActiveColor : tea.getColor(),
                      size: 64,
                    ),
                    Text(
                      tea.name,
                      style: textStyleButton.copyWith(
                        color: tea.isActive ? timerActiveColor : tea.getColor(),
                      ),
                    ),
                    // Optional extra info: brew time, temp, and ratio display
                    Selector<AppProvider, bool>(
                      selector: (_, provider) => provider.showExtra,
                      builder: (context, showExtra, child) => Visibility(
                        visible: showExtra,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Brew time
                                Container(
                                  padding: rowPadding,
                                  child: Text(
                                    formatTimer(tea.brewTime),
                                    style: textStyleButtonTertiary.copyWith(
                                      color: tea.isActive
                                          ? timerActiveColor
                                          : tea.getColor(),
                                    ),
                                  ),
                                ),
                                // Brew temperature
                                Visibility(
                                  visible: tea.brewTemp > roomTemp,
                                  child: Container(
                                    padding: rowPadding,
                                    child: Text(
                                      tea.getTempDisplay(
                                        useCelsius: Provider.of<AppProvider>(
                                          context,
                                          listen: false,
                                        ).useCelsius,
                                      ),
                                      style: textStyleButtonTertiary.copyWith(
                                        color: tea.isActive
                                            ? timerActiveColor
                                            : tea.getColor(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Brew ratio
                            Selector<AppProvider, bool>(
                              selector: (_, provider) => provider.useBrewRatios,
                              builder: (context, useBrewRatios, child) =>
                                  Visibility(
                                    visible: useBrewRatios,
                                    child: Container(
                                      padding: rowPadding,
                                      child: Text(
                                        tea.brewRatio.ratioString,
                                        style: textStyleButtonTertiary.copyWith(
                                          color: tea.isActive
                                              ? timerActiveColor
                                              : tea.getColor(),
                                        ),
                                      ),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
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
}
