/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    about.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// About Cuppa
// - Version and build number
// - Links to GitHub, Weblate, etc.

import 'localization.dart';
import 'main.dart';
import 'platform_adaptive.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// About page
class AboutWidget extends StatelessWidget {
  const AboutWidget({Key? key}) : super(key: key);

  // About list item link URLs
  static final String versionsURL =
      'https://github.com/ncosgray/cuppa_mobile/releases';
  static final String licenseURL =
      'https://github.com/ncosgray/cuppa_mobile/blob/master/LICENSE.txt';
  static final String sourceURL = 'https://github.com/ncosgray/cuppa_mobile';
  static final String translateURL = 'https://hosted.weblate.org/engage/cuppa/';
  static final String issuesURL =
      'https://github.com/ncosgray/cuppa_mobile/issues';

  // Build About page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new PlatformAdaptiveAppBar(
          title: new Text(AppLocalizations.translate('about_title')
              .replaceAll('{{app_name}}', appName)),
          platform: appPlatform,
        ),
        body: new SafeArea(
            child: new Container(
                padding: const EdgeInsets.fromLTRB(12.0, 18.0, 12.0, 0.0),
                child: new CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    new SliverAppBar(
                      elevation: 0,
                      backgroundColor: Theme.of(context).canvasColor,
                      leading:
                          // Teacup icon
                          new Container(
                              padding: const EdgeInsets.all(4.0),
                              child:
                                  Image.asset(appIcon, fit: BoxFit.scaleDown)),
                      title:
                          // Cuppa version and build
                          new Text(
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
                    new SliverToBoxAdapter(
                        child: new Column(children: [
                      // Changelog
                      _listItem(AppLocalizations.translate('version_history'),
                          null, versionsURL),
                      _divider(),
                      // App license info
                      _listItem(AppLocalizations.translate('about_license'),
                          null, licenseURL),
                      _divider(),
                      // Link to app source code
                      _listItem(
                          AppLocalizations.translate('source_code'),
                          AppLocalizations.translate('source_code_info'),
                          sourceURL),
                      _divider(),
                      // App localization info
                      _listItem(
                          AppLocalizations.translate('help_translate')
                              .replaceAll('{{app_name}}', appName),
                          AppLocalizations.translate('help_translate_info'),
                          translateURL),
                      _divider(),
                      // How to report issues
                      _listItem(AppLocalizations.translate('issues'),
                          AppLocalizations.translate('issues_info'), issuesURL),
                      _divider(),
                    ])),
                    new SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: new Align(
                        alignment: Alignment.bottomLeft,
                        child: new Container(
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
    return new InkWell(
        child: ListTile(
      title: new Text(title,
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
      onTap: () => launch(url),
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
  return new InkWell(
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            new Text(
                AppLocalizations.translate('about_app')
                    .replaceAll('{{app_name}}', appName),
                style: TextStyle(
                  fontSize: 12.0,
                )),
            new Row(children: [
              new Text(aboutCopyright,
                  style: TextStyle(
                    fontSize: 12.0,
                  )),
              new VerticalDivider(),
              new Text(aboutURL,
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.blue,
                      decoration: TextDecoration.underline))
            ])
          ]),
      onTap: () => launch(aboutURL));
}
