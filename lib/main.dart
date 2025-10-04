/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    main.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa: a simple tea timer app for Android and iOS

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/cuppa_app.dart';
import 'package:cuppa_mobile/data/prefs.dart';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

void main() async {
  await initializeApp();
  enableCheckReviewPrompt();
  runApp(const CuppaApp());
}

// Enable app store review prompt function
void enableCheckReviewPrompt() {
  // Check if we should ask user to submit an app store review
  checkReviewPrompt = () async {
    // Activity count determines when to prompt
    int counter = Prefs.reviewPromptCounter;
    if (counter <= reviewPromptAtCount) {
      Prefs.incrementReviewPromptCounter();

      // Prompt for review
      if (counter == reviewPromptAtCount) {
        final InAppReview inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          Future.delayed(promptDelayDuration, () {
            inAppReview.requestReview();
          });
        }
      }
    }
  };
}
