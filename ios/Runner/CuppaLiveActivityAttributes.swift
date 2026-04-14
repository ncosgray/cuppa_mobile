/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    CuppaLiveActivityAttributes.swift
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa Live Activity attributes (iOS only)

import ActivityKit

/// Attributes struct for the Cuppa tea timer Live Activity.
/// The name and shape must match the definition in
/// CuppaLiveActivity/CuppaLiveActivityLiveActivity.swift.
/// ActivityKit matches activities across app and extension boundaries using
/// the struct name, so the two definitions do not need to share a module.
@available(iOS 16.2, *)
struct LiveActivitiesAppAttributes: ActivityAttributes {
    /// Empty content state — all dynamic data is passed via shared UserDefaults
    /// rather than through ActivityKit's push-based content state mechanism.
    public struct ContentState: Codable, Hashable {}

    var id = UUID()
}
