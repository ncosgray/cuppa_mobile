/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    about_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// About Cuppa page
// - Version and build number
// - Links to GitHub, Weblate, etc.

import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/widgets/common.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

// About Cuppa page
class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  // Build About page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlatformAdaptiveNavBar(
        isPoppable: true,
        textScaleFactor: appTextScale,
        title: AppString.about_title.translate(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 1,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
              shadowColor: Theme.of(context).shadowColor,
              // Teacup icon
              leading: Container(
                padding: const EdgeInsets.only(left: 8.0),
                child: Image.asset(appIcon, fit: BoxFit.scaleDown),
              ),
              // Cuppa version and build
              title: Text(
                '$appName ${packageInfo.version} (${packageInfo.buildNumber})',
                style: textStyleHeader.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Changelog
                  _listItem(
                    title: AppString.version_history.translate(),
                    url: versionsURL,
                  ),
                  listDivider,
                  // App license info
                  _listItem(
                    title: AppString.about_license.translate(),
                    url: licenseURL,
                  ),
                  listDivider,
                  // Link to app source code
                  _listItem(
                    title: AppString.source_code.translate(),
                    subtitle: AppString.source_code_info.translate(),
                    url: sourceURL,
                  ),
                  listDivider,
                  // App localization info
                  _listItem(
                    title: AppString.help_translate.translate(),
                    subtitle: AppString.help_translate_info.translate(),
                    url: translateURL,
                  ),
                  listDivider,
                  // How to report issues
                  _listItem(
                    title: AppString.issues.translate(),
                    subtitle: AppString.issues_info.translate(),
                    url: issuesURL,
                  ),
                  listDivider,
                  // Privacy policy
                  _listItem(
                    title: AppString.privacy_policy.translate(),
                    url: privacyURL,
                  ),
                  listDivider,
                  // Tutorial
                  _listItem(
                    title: AppString.tutorial.translate(),
                    subtitle: AppString.tutorial_info.translate(),
                    onTap: () {
                      // Restart tutorial on Timer page
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      ShowCaseWidget.of(context)
                          .startShowCase(tutorialSteps.keys.toList());
                    },
                  ),
                  listDivider,
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 12.0),
                  // About text linking to app website
                  child: aboutText(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // About list item
  Widget _listItem({
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        dense: true,
      ),
    );
  }
}
