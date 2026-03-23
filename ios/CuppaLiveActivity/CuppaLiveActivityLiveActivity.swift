//
//  CuppaLiveActivityLiveActivity.swift
//  CuppaLiveActivity
//
//  Created by Nathan Cosgray on 3/21/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

// Widget extensions run in a separate process and cannot access the main app's
// plugin types, so we redefine LiveActivitiesAppAttributes here
// (must match the definition in the live_activities plugin).
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    // Empty content state — all dynamic data is passed via shared UserDefaults
    // rather than through ActivityKit's push-based content state mechanism.
    public struct ContentState: Codable, Hashable { }

    var id = UUID()
}

extension LiveActivitiesAppAttributes {
    /// Build a UserDefaults key prefixed with this activity's unique ID,
    /// ensuring multiple activities don't collide in shared storage.
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}

/// Shared UserDefaults container used to pass timer data from the Flutter app
/// (via the live_activities plugin) to this widget extension.
let sharedDefault = UserDefaults(suiteName: "group.com.nathanatos.Cuppa")!

// MARK: - Live Activity Widget

/// Main widget that provides both the lock screen banner and Dynamic Island
/// presentations for active tea timers. Supports displaying 1 or 2 concurrent
/// timers with live countdowns, tea names, icons, and colors.
struct CuppaLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Lock screen / notification banner presentation
            LockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island presentation (iPhone 14 Pro and later)
            DynamicIsland {
                // Expanded view: tea icons in leading/trailing, countdowns in bottom
                DynamicIslandExpandedRegion(.leading) {
                    teaIconImage(context: context, index: 1)
                        .frame(width: 32, height: 32)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if timerCount(context: context) >= 2 {
                        teaIconImage(context: context, index: 2)
                            .frame(width: 32, height: 32)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 16) {
                        timerColumn(context: context, index: 1)
                        if timerCount(context: context) >= 2 {
                            timerColumn(context: context, index: 2)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                // Compact pill: leading side shows countdown for timer 1 (if 2 timers)
                // or the tea icon (if 1 timer)
                if timerCount(context: context) >= 2 {
                    Text(
                        timerInterval: Date()...endDate(context: context, index: 1),
                        countsDown: true
                    )
                    .monospacedDigit()
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(teaColor(context: context, index: 1))
                    .frame(width: 50)
                } else {
                    teaIconImage(context: context, index: 1)
                        .frame(width: 20, height: 20)
                }
            } compactTrailing: {
                // Compact pill: trailing side shows countdown for timer 2 (if 2 timers)
                // or the countdown for timer 1 (if 1 timer)
                if timerCount(context: context) >= 2 {
                    Text(
                        timerInterval: Date()...endDate(context: context, index: 2),
                        countsDown: true
                    )
                    .monospacedDigit()
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(teaColor(context: context, index: 2))
                    .frame(width: 50, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                } else {
                    Text(
                        timerInterval: Date()...endDate(context: context, index: 1),
                        countsDown: true
                    )
                    .monospacedDigit()
                    .fontWeight(.bold)
                    .foregroundColor(teaColor(context: context, index: 1))
                    .frame(width: 50, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                }
            } minimal: {
                // Minimal view: shown when multiple Live Activities compete for space
                teaIconImage(context: context, index: 1)
                    .frame(width: 20, height: 20)
            }
        }
    }
}

// MARK: - Lock Screen View

/// Lock screen and notification banner view for the Live Activity.
/// Adapts layout based on the number of active timers:
/// - 1 timer: icon on the left, tea name and countdown on the right.
/// - 2 timers: side-by-side layout with a divider, second timer mirrored.
struct LockScreenView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>

    var body: some View {
        let count = timerCount(context: context)

        if count >= 2 {
            // Two-timer layout: timers side by side with a vertical divider
            HStack(spacing: 12) {
                timerRow(context: context, index: 1)
                Divider()
                    .frame(height: 40)
                timerRow(context: context, index: 2, mirrorLayout: true)
            }
            .padding(16)
            .activityBackgroundTint(.black.opacity(0.7))
        } else {
            // Single-timer layout: icon left, name and countdown right
            HStack {
                teaIconImage(context: context, index: 1)
                    .frame(width: 36, height: 36)
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(teaName(context: context, index: 1))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(teaColor(context: context, index: 1))
                        .lineLimit(1)
                    Text(
                        timerInterval: Date()...endDate(context: context, index: 1),
                        countsDown: true
                    )
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundColor(teaColor(context: context, index: 1))
                    .multilineTextAlignment(.trailing)
                }
                .layoutPriority(1)
            }
            .padding(16)
            .activityBackgroundTint(.black.opacity(0.7))
        }
    }
}

// MARK: - Subviews

/// A horizontal timer row used in the lock screen view.
/// Shows a tea icon, name, and live countdown. When `mirrorLayout` is true,
/// the icon appears on the right and text aligns to the trailing edge
/// (used for the second timer in the two-timer layout).
@ViewBuilder
func timerRow(context: ActivityViewContext<LiveActivitiesAppAttributes>, index: Int, mirrorLayout: Bool = false) -> some View {
    let end = endDate(context: context, index: index)
    let color = teaColor(context: context, index: index)

    HStack(spacing: 8) {
        if mirrorLayout { Spacer() }
        if !mirrorLayout {
            teaIconImage(context: context, index: index)
                .frame(width: 28, height: 28)
        }
        VStack(alignment: mirrorLayout ? .trailing : .leading, spacing: 2) {
            Text(teaName(context: context, index: index))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .lineLimit(1)
            Text(
                timerInterval: Date()...end,
                countsDown: true
            )
            .font(.title2)
            .fontWeight(.bold)
            .monospacedDigit()
            .multilineTextAlignment(mirrorLayout ? .trailing : .leading)
            .foregroundColor(color)
        }
        if mirrorLayout {
            teaIconImage(context: context, index: index)
                .frame(width: 28, height: 28)
        }
        if !mirrorLayout { Spacer() }
    }
}

/// A vertical timer column used in the Dynamic Island expanded view.
/// Displays the tea name above the countdown timer.
@ViewBuilder
func timerColumn(context: ActivityViewContext<LiveActivitiesAppAttributes>, index: Int) -> some View {
    let end = endDate(context: context, index: index)
    let color = teaColor(context: context, index: index)

    VStack(spacing: 2) {
        Text(teaName(context: context, index: index))
            .font(.caption2)
            .foregroundColor(color)
            .lineLimit(1)
        Text(
            timerInterval: Date()...end,
            countsDown: true
        )
        .font(.body)
        .fontWeight(.bold)
        .monospacedDigit()
        .foregroundColor(color)
    }
    .frame(maxWidth: .infinity)
}

// MARK: - Data Helpers
// These functions read timer data from shared UserDefaults, where each key is
// prefixed with the activity's UUID to avoid collisions. The Flutter app writes
// these values via the live_activities plugin (see live_activity_service.dart).

/// Get the number of currently active tea timers (1 or 2).
func timerCount(context: ActivityViewContext<LiveActivitiesAppAttributes>) -> Int {
    return sharedDefault.integer(forKey: context.attributes.prefixedKey("timerCount"))
}

/// Get the display name for a tea timer at the given index (1-based).
func teaName(context: ActivityViewContext<LiveActivitiesAppAttributes>, index: Int) -> String {
    return sharedDefault.string(forKey: context.attributes.prefixedKey("tea\(index)Name")) ?? ""
}

/// Get the end time for a tea timer as a Date, converted from epoch seconds.
func endDate(context: ActivityViewContext<LiveActivitiesAppAttributes>, index: Int) -> Date {
    let endTime = sharedDefault.double(forKey: context.attributes.prefixedKey("tea\(index)EndTime"))
    return Date(timeIntervalSince1970: endTime)
}

/// Get the tea color from its RGB components stored in shared UserDefaults.
/// Falls back to gray if no color has been set (all components are zero).
func teaColor(context: ActivityViewContext<LiveActivitiesAppAttributes>, index: Int) -> Color {
    let r = sharedDefault.double(forKey: context.attributes.prefixedKey("tea\(index)ColorRed"))
    let g = sharedDefault.double(forKey: context.attributes.prefixedKey("tea\(index)ColorGreen"))
    let b = sharedDefault.double(forKey: context.attributes.prefixedKey("tea\(index)ColorBlue"))
    // Default to gray if no color is set
    if r == 0 && g == 0 && b == 0 {
        return Color(red: 0.5, green: 0.5, blue: 0.5)
    }
    return Color(red: r, green: g, blue: b)
}

/// Map a tea icon integer value to its corresponding asset name.
/// Values must match the TeaIcon enum in the Flutter app (see tea.dart).
func teaIconName(context: ActivityViewContext<LiveActivitiesAppAttributes>, index: Int) -> String {
    let iconValue = sharedDefault.integer(forKey: context.attributes.prefixedKey("tea\(index)Icon"))
    switch iconValue {
    case 1: return "TeaIconCup"
    case 2: return "TeaIconFlower"
    default: return "TeaIconTimer"
    }
}

/// Build a resizable, color-tinted tea icon image for display in the Live Activity.
@ViewBuilder
func teaIconImage(context: ActivityViewContext<LiveActivitiesAppAttributes>, index: Int) -> some View {
    Image(teaIconName(context: context, index: index))
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(teaColor(context: context, index: index))
}
