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
// (must match the definition in the live_activities plugin)
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable { }

    var id = UUID()
}

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}

let sharedDefault = UserDefaults(suiteName: "group.com.nathanatos.Cuppa")!

// MARK: - Live Activity Widget

struct CuppaLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
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
                teaIconImage(context: context, index: 1)
                    .frame(width: 20, height: 20)
            }
        }
    }
}

// MARK: - Lock Screen View

struct LockScreenView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>

    var body: some View {
        let count = timerCount(context: context)

        if count >= 2 {
            HStack(spacing: 12) {
                timerRow(context: context, index: 1)
                Divider()
                    .frame(height: 40)
                timerRow(context: context, index: 2, mirrorLayout: true)
            }
            .padding(16)
            .activityBackgroundTint(.black.opacity(0.7))
        } else {
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

func timerCount(context: ActivityViewContext<LiveActivitiesAppAttributes>) -> Int {
    return sharedDefault.integer(forKey: context.attributes.prefixedKey("timerCount"))
}

func teaName(context: ActivityViewContext<LiveActivitiesAppAttributes>, index: Int) -> String {
    return sharedDefault.string(forKey: context.attributes.prefixedKey("tea\(index)Name")) ?? ""
}

func endDate(context: ActivityViewContext<LiveActivitiesAppAttributes>, index: Int) -> Date {
    let endTime = sharedDefault.double(forKey: context.attributes.prefixedKey("tea\(index)EndTime"))
    return Date(timeIntervalSince1970: endTime)
}

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

func teaIconName(context: ActivityViewContext<LiveActivitiesAppAttributes>, index: Int) -> String {
    let iconValue = sharedDefault.integer(forKey: context.attributes.prefixedKey("tea\(index)Icon"))
    switch iconValue {
    case 1: return "TeaIconCup"
    case 2: return "TeaIconFlower"
    default: return "TeaIconTimer"
    }
}

@ViewBuilder
func teaIconImage(context: ActivityViewContext<LiveActivitiesAppAttributes>, index: Int) -> some View {
    Image(teaIconName(context: context, index: index))
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(teaColor(context: context, index: index))
}
