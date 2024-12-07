import UIKit
import Flutter
import AppIntents
import intelligence

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Setup for flutter_local_notifications plugin
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

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

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
