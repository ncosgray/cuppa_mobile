import Flutter
import UIKit
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

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    CuppaLiveActivityPlugin.register(
      with: engineBridge.pluginRegistry.registrar(forPlugin: "CuppaLiveActivityPlugin")!,
    )

    // Notification settings that can keep timer alerts from being heard
    let notifyChannel = FlutterMethodChannel(
      name: "cuppa_notifications",
      binaryMessenger: engineBridge.pluginRegistry.registrar(forPlugin: "CuppaNotifications")!.messenger(),
    )
    notifyChannel.setMethodCallHandler { call, result in
      guard call.method == "getNotificationSettings" else {
        result(FlutterMethodNotImplemented)
        return
      }
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        let status: String
        switch settings.authorizationStatus {
        case .notDetermined: status = "notDetermined"
        case .denied: status = "denied"
        default: status = "authorized"
        }
        DispatchQueue.main.async {
          result([
            "status": status,
            "soundEnabled": settings.soundSetting != .disabled,
            "timeSensitiveEnabled": settings.timeSensitiveSetting != .disabled,
          ])
        }
      }
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
  }
}
