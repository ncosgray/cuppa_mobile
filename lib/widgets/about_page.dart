/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    about_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// About Cuppa page
// - Version and build number
// - Links to GitHub, Weblate, etc.

import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// About Cuppa page
class AboutWidget extends StatelessWidget {
  const AboutWidget({Key? key}) : super(key: key);

  // Build About page
  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveScaffold(
        platform: appPlatform,
        isPoppable: true,
        title: AppString.about_title.translate(),
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.fromLTRB(12.0, 18.0, 12.0, 0.0),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      elevation: 0,
                      backgroundColor: Theme.of(context).canvasColor,
                      leading:
                          // Teacup icon
                          Container(
                              padding: const EdgeInsets.all(4.0),
                              child:
                                  Image.asset(appIcon, fit: BoxFit.scaleDown)),
                      title:
                          // Cuppa version and build
                          Text(
                              appName +
                                  ' ' +
                                  packageInfo.version +
                                  ' (' +
                                  packageInfo.buildNumber +
                                  ')',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color!,
                              )),
                    ),
                    SliverToBoxAdapter(
                        child: Column(children: [
                      // Changelog
                      _listItem(AppString.version_history.translate(), null,
                          versionsURL),
                      _divider(),
                      // App license info
                      _listItem(AppString.about_license.translate(), null,
                          licenseURL),
                      _divider(),
                      // Link to app source code
                      _listItem(AppString.source_code.translate(),
                          AppString.source_code_info.translate(), sourceURL),
                      _divider(),
                      // App localization info
                      _listItem(
                          AppString.help_translate.translate(),
                          AppString.help_translate_info.translate(),
                          translateURL),
                      _divider(),
                      // How to report issues
                      _listItem(AppString.issues.translate(),
                          AppString.issues_info.translate(), issuesURL),
                      _divider(),
                    ])),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          margin:
                              const EdgeInsets.fromLTRB(6.0, 36.0, 6.0, 18.0),
                          // About text linking to app website
                          child: aboutText(),
                        ),
                      ),
                    )
                  ],
                ))));
  }

  // About list item
  Widget _listItem(String title, String? subtitle, String url) {
    return InkWell(
        child: ListTile(
      title: Text(title,
          style: TextStyle(
            fontSize: 16.0,
          )),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(
                fontSize: 14.0,
              ))
          : null,
      trailing: const Icon(Icons.launch, size: 16.0),
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      contentPadding: const EdgeInsets.all(6.0),
      dense: true,
    ));
  }

  // About list divider
  Widget _divider() {
    return const Divider(
      thickness: 1.0,
      indent: 6.0,
      endIndent: 6.0,
    );
  }
}

// About text linking to app website
Widget aboutText() {
  return InkWell(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppString.about_app.translate(),
                style: TextStyle(
                  fontSize: 12.0,
                )),
            Row(children: [
              Text(aboutCopyright,
                  style: TextStyle(
                    fontSize: 12.0,
                  )),
              VerticalDivider(),
              Text(aboutURL,
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.blue,
                      decoration: TextDecoration.underline))
            ])
          ]),
      onTap: () =>
          launchUrl(Uri.parse(aboutURL), mode: LaunchMode.externalApplication));
}
