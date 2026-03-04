import Flutter
import UIKit
import UserNotifications
import AppIntents
import intelligence

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Setup for flutter_local_notifications plugin
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    // Setup badge count method channel
    let controller = window?.rootViewController as! FlutterViewController
    let badgeChannel = FlutterMethodChannel(
      name: "com.nathanatos.Cuppa/badge",
      binaryMessenger: controller.binaryMessenger
    )
    badgeChannel.setMethodCallHandler { (call, result) in
      if call.method == "setBadge" {
        let count = call.arguments as? Int ?? 0
        if #available(iOS 16.0, *) {
          UNUserNotificationCenter.current().setBadgeCount(count)
        } else {
          application.applicationIconBadgeNumber = count
        }
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Setup for intelligence plugin
    IntelligencePlugin.storage.attachListener {
      AppShortcuts.updateAppShortcutParameters()
    }
    if #available(iOS 18.0, *) {
      IntelligencePlugin.spotlightCore.attachEntityMapper() { item in
        return TeaEntity(
          id: item.id,
          representation: item.representation
        )
      }
    }
  }
}
