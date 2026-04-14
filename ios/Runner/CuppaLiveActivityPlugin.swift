/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    CuppaLiveActivityPlugin.swift
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa Live Activity Flutter plugin (iOS only)

import ActivityKit
import Flutter
import UIKit

/// Flutter MethodChannel plugin that manages iOS Live Activity lifecycle for
/// the Cuppa tea timer. Handles create/update/end operations via ActivityKit
/// and writes timer data to shared UserDefaults for the widget extension to read.
class CuppaLiveActivityPlugin: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "cuppa_live_activity",
            binaryMessenger: registrar.messenger(),
        )
        registrar.addMethodCallDelegate(CuppaLiveActivityPlugin(), channel: channel)
    }

    // Tracked activities keyed by UUID string (stored as Any to avoid availability constraints)
    private var activities: [String: Any] = [:]
    private var appGroupId: String = ""

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            if let args = call.arguments as? [String: Any],
               let groupId = args["appGroupId"] as? String
            {
                appGroupId = groupId
            }
            if #available(iOS 16.2, *) {
                Task { @MainActor in
                    await self.endAllActivities()
                    result(nil)
                }
            } else {
                result(nil)
            }

        case "areActivitiesEnabled":
            if #available(iOS 16.1, *) {
                result(ActivityAuthorizationInfo().areActivitiesEnabled)
            } else {
                result(false)
            }

        case "createActivity":
            guard let args = call.arguments as? [String: Any],
                  let data = args["data"] as? [String: Any]
            else {
                result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
                return
            }
            if #available(iOS 16.2, *) {
                let id = UUID()
                writeUserDefaults(id: id, data: data)
                let attrs = LiveActivitiesAppAttributes(id: id)
                Task { @MainActor in
                    do {
                        let activity = try Activity.request(
                            attributes: attrs,
                            content: ActivityContent(state: .init(), staleDate: nil),
                        )
                        self.activities[id.uuidString] = activity
                        result(id.uuidString)
                    } catch {
                        result(FlutterError(
                            code: "CREATE_FAILED",
                            message: error.localizedDescription,
                            details: nil,
                        ))
                    }
                }
            } else {
                result(nil)
            }

        case "updateActivity":
            guard let args = call.arguments as? [String: Any],
                  let activityId = args["activityId"] as? String,
                  let data = args["data"] as? [String: Any],
                  let uuid = UUID(uuidString: activityId)
            else {
                result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
                return
            }
            if #available(iOS 16.2, *) {
                writeUserDefaults(id: uuid, data: data)
                if let activity = activities[activityId] as? Activity<LiveActivitiesAppAttributes> {
                    Task { @MainActor in
                        await activity.update(
                            ActivityContent(state: .init(), staleDate: nil),
                        )
                        result(nil)
                    }
                } else {
                    result(nil)
                }
            } else {
                result(nil)
            }

        case "endActivity":
            guard let args = call.arguments as? [String: Any],
                  let activityId = args["activityId"] as? String
            else {
                result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
                return
            }
            if #available(iOS 16.2, *) {
                if let activity = activities.removeValue(forKey: activityId) as? Activity<LiveActivitiesAppAttributes> {
                    Task { @MainActor in
                        await activity.end(
                            ActivityContent(state: .init(), staleDate: nil),
                            dismissalPolicy: .immediate,
                        )
                        result(nil)
                    }
                } else {
                    result(nil)
                }
            } else {
                result(nil)
            }

        case "endAllActivities":
            if #available(iOS 16.2, *) {
                Task { @MainActor in
                    await self.endAllActivities()
                    result(nil)
                }
            } else {
                result(nil)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    @available(iOS 16.2, *)
    @MainActor
    private func endAllActivities() async {
        for activity in Activity<LiveActivitiesAppAttributes>.activities {
            await activity.end(
                ActivityContent(state: .init(), staleDate: nil),
                dismissalPolicy: .immediate,
            )
        }
        activities.removeAll()
    }

    private func writeUserDefaults(id: UUID, data: [String: Any]) {
        guard let defaults = UserDefaults(suiteName: appGroupId) else { return }
        let prefix = id.uuidString
        for (key, value) in data {
            defaults.set(value, forKey: "\(prefix)_\(key)")
        }
        defaults.synchronize()
    }
}
