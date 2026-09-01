/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    about_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// About Cuppa page
// - Version and build number
// - Links to GitHub, Weblate, etc.

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/list_tiles.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/common/separators.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/pages/stats_page.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'dart:io' show Platform;

import 'package:material_ui/material_ui.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// About Cuppa page
class AboutWidget extends StatefulWidget {
  const AboutWidget({super.key});

  @override
  State<AboutWidget> createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<AboutWidget> {
  // Fades the nav bar title in as the page header scrolls away. Only iOS shows
  // a fading title, and only iOS should pay for driving one.
  final GlassLargeTitleController? _titleController = Platform.isIOS
      ? GlassLargeTitleController(collapseTitleHeight: kToolbarHeight)
      : null;

  @override
  void dispose() {
    _titleController?.dispose();
    super.dispose();
  }

  // Build About page
  @override
  Widget build(BuildContext context) {
    final Widget scaffold = adaptiveScaffold(
      appBar: PlatformAdaptiveNavBar(
        isPoppable: true,
        title: AppString.about_title.translate(),
        buttonTextDone: AppString.done_button.translate(),
        previousPageTitle: AppString.prefs_title.translate(),
        largeTitleController: _titleController,
      ),
      body: CustomScrollView(
        slivers: [
          adaptivePageHeader(
            context,
            // Teacup icon
            leading: Container(
              padding: largeDefaultPadding,
              child: Image.asset(appIcon, fit: .scaleDown),
            ),
            // Cuppa version and build
            title:
                '$appName ${packageInfo.version} (${packageInfo.buildNumber})',
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  // Tutorial
                  aboutLink(
                    title: AppString.tutorial.translate(),
                    subtitle: AppString.tutorial_info.translate(),
                    onTap: () {
                      // Restart tutorial on Timer page
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      startTutorial();
                    },
                  ),
                  listDivider,
                  // Display timer usage stats, if enabled
                  Selector<AppProvider, bool>(
                    selector: (_, provider) => provider.collectStats,
                    builder: (context, collectStats, child) => Visibility(
                      visible: collectStats,
                      child: aboutLink(
                        title: AppString.stats_header.translate(),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StatsWidget(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Selector<AppProvider, bool>(
                    selector: (_, provider) => provider.collectStats,
                    builder: (context, collectStats, child) =>
                        Visibility(visible: collectStats, child: listDivider),
                  ),
                  // How to report issues
                  aboutLink(
                    title: AppString.issues.translate(),
                    subtitle: AppString.issues_info.translate(),
                    url: issuesURL,
                  ),
                  listDivider,
                  // App localization info
                  aboutLink(
                    title: AppString.help_translate.translate(),
                    subtitle: AppString.help_translate_info.translate(),
                    url: translateURL,
                  ),
                  listDivider,
                  // Support the project
                  aboutLink(
                    title: AppString.support_the_project.translate(),
                    url: supportURL,
                  ),
                  listDivider,
                  // Changelog
                  aboutLink(
                    title: AppString.version_history.translate(),
                    url: versionsURL,
                  ),
                  listDivider,
                  // Link to app source code
                  aboutLink(
                    title: AppString.source_code.translate(),
                    subtitle: AppString.source_code_info.translate(),
                    url: sourceURL,
                  ),
                  listDivider,
                  // App license info
                  aboutLink(
                    title: AppString.about_license.translate(),
                    url: licenseURL,
                  ),
                  listDivider,
                  // Privacy policy
                  aboutLink(
                    title: AppString.privacy_policy.translate(),
                    url: privacyURL,
                  ),
                  listDivider,
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: SafeArea(
              left: false,
              top: false,
              right: false,
              child: Align(
                alignment: .bottomLeft,
                // About text linking to app website
                child: _aboutText(),
              ),
            ),
          ),
        ],
      ),
    );

    // Overriding the primary controller rather than passing the scroll view a
    // controller keeps the status bar tap-to-top gesture working, which reads
    // PrimaryScrollController from above the scaffold
    return _titleController == null
        ? scaffold
        : PrimaryScrollController(
            controller: _titleController.scrollController,
            child: scaffold,
          );
  }

  // About text linking to app website
  Widget _aboutText() {
    return InkWell(
      child: Container(
        padding: bottomSliverPadding,
        child: Column(
          crossAxisAlignment: .center,
          mainAxisSize: .min,
          children: [
            Text(AppString.about_app.translate(), style: textStyleFooter),
            const Row(
              mainAxisAlignment: .center,
              children: [
                Text(aboutCopyright, style: textStyleFooter),
                VerticalDivider(),
                Text(aboutURL, style: textStyleFooterLink),
              ],
            ),
          ],
        ),
      ),
      onTap: () => launchUrl(Uri.parse(aboutURL), mode: .externalApplication),
    );
  }
}
