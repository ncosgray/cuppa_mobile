/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_button.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea timer button

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widget defining a tea brew start button
class TeaButton extends StatelessWidget {
  const TeaButton({
    Key? key,
    required this.tea,
    required this.fade,
    required this.onPressed,
  }) : super(key: key);

  final Tea tea;
  final bool fade;
  final ValueChanged<bool> onPressed;

  void _handleTap() {
    onPressed(!tea.isActive);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: AnimatedOpacity(
          opacity: fade ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 400),
          child: Card(
            color: tea.isActive ? tea.getThemeColor(context) : null,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                constraints: const BoxConstraints(
                    minWidth: 80.0, maxWidth: double.infinity),
                margin: const EdgeInsets.all(8.0),
                // Timer icon with tea name
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tea.teaIcon,
                      color: tea.isActive
                          ? Colors.white
                          : tea.getThemeColor(context),
                      size: 64.0,
                    ),
                    Text(
                      tea.buttonName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: tea.isActive
                            ? Colors.white
                            : tea.getThemeColor(context),
                      ),
                    ),
                    // Optional extra info: brew time and temp display
                    Selector<AppProvider, bool>(
                        selector: (_, provider) => provider.showExtra,
                        builder: (context, showExtra, child) => Visibility(
                            visible: showExtra,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Brew time
                                  Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          4.0, 2.0, 4.0, 0.0),
                                      child: Text(
                                        formatTimer(tea.brewTime),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0,
                                          color: tea.isActive
                                              ? Colors.white
                                              : tea.getThemeColor(context),
                                        ),
                                      )),
                                  // Brew temperature
                                  Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          4.0, 2.0, 4.0, 0.0),
                                      child: Text(
                                        tea.tempDisplay,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0,
                                          color: tea.isActive
                                              ? Colors.white
                                              : tea.getThemeColor(context),
                                        ),
                                      ))
                                ]))),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
