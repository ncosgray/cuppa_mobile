/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    about_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// About Cuppa page
// - Version and build number
// - Links to GitHub, Weblate, etc.

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/dialogs.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/list_tiles.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/common/separators.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/export.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/pages/stats_page.dart';
import 'package:cuppa_mobile/widgets/page_header.dart';
import 'package:cuppa_mobile/widgets/tutorial.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        title: AppString.about_title.translate(),
        buttonTextDone: AppString.done_button.translate(),
        previousPageTitle: AppString.prefs_title.translate(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            pageHeader(
              context,
              // Teacup icon
              leading: Container(
                padding: largeDefaultPadding,
                child: Image.asset(appIcon, fit: BoxFit.scaleDown),
              ),
              // Cuppa version and build
              title:
                  '$appName ${packageInfo.version} (${packageInfo.buildNumber})',
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Tutorial
                  aboutLink(
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
                    builder: (context, collectStats, child) => Visibility(
                      visible: collectStats,
                      child: listDivider,
                    ),
                  ),
                  // Tools: export/import data
                  _exportImportTools(context),
                  listDivider,
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
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Align(
                alignment: Alignment.bottomLeft,
                // About text linking to app website
                child: _aboutText(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tools: export/import data
  Widget _exportImportTools(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return Align(
      alignment: Alignment.topLeft,
      child: IgnorePointer(
        // Disable export/import while timer is active
        ignoring: provider.activeTeas.isNotEmpty,
        child: Opacity(
          opacity: provider.activeTeas.isNotEmpty ? fadeOpacity : noOpacity,
          child: ListTile(
            iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
            title: Text(
              AppString.export_import.translate(),
              style: textStyleTitle,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _exportButton(context),
                const VerticalDivider(),
                _importButton(context),
              ],
            ),
            contentPadding: listTilePadding,
            dense: true,
          ),
        ),
      ),
    );
  }

  // Export button
  Widget _exportButton(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: exportIcon,
          onPressed: () {
            // Render location for share sheet on iPad
            RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            Rect sharePositionOrigin =
                (renderBox?.localToGlobal(Offset.zero) ?? Offset.zero) &
                    (renderBox?.size ?? const Size(4.0, 4.0));

            // Attempt to save an export file and report if failed
            Export.create(
              provider,
              share: true,
              sharePositionOrigin: sharePositionOrigin,
            ).then(
              (exported) {
                if (!exported) {
                  showInfoDialog(
                    context: context,
                    message: AppString.export_failure.translate(),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // Import button
  Widget _importButton(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return IconButton(
      icon: importIcon,
      onPressed: () async {
        // Show a prompt with more information
        if (await showConfirmDialog(
          context: context,
          body: Text(AppString.confirm_import.translate()),
          bodyExtra: Text(AppString.confirm_continue.translate()),
        )) {
          // Attempt to load an export file and report the result
          Export.load(provider).then(
            (imported) => showInfoDialog(
              context: context,
              message: imported
                  ? AppString.import_sucess.translate()
                  : AppString.import_failure.translate(),
            ),
          );
        }
      },
    );
  }

  // About text linking to app website
  Widget _aboutText() {
    return InkWell(
      child: Container(
        padding: bottomSliverPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppString.about_app.translate(), style: textStyleFooter),
            const Row(
              children: [
                Text(aboutCopyright, style: textStyleFooter),
                VerticalDivider(),
                Text(aboutURL, style: textStyleFooterLink),
              ],
            ),
          ],
        ),
      ),
      onTap: () =>
          launchUrl(Uri.parse(aboutURL), mode: LaunchMode.externalApplication),
    );
  }
}
