import Flutter
import UIKit
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let appGroupId = "group.com.quartex.renewd"
  private let sharedKey = "ShareKey"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register for remote notifications
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    // Set up method channel for share extension data
    let controller = window?.rootViewController as! FlutterViewController
    let shareChannel = FlutterMethodChannel(
      name: "com.quartex.renewd/share",
      binaryMessenger: controller.binaryMessenger
    )
    shareChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "getSharedData":
        let userDefaults = UserDefaults(suiteName: self?.appGroupId)
        let data = userDefaults?.string(forKey: self?.sharedKey ?? "")
        result(data)
      case "clearSharedData":
        let userDefaults = UserDefaults(suiteName: self?.appGroupId)
        userDefaults?.removeObject(forKey: self?.sharedKey ?? "")
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle renewd:// URL scheme (from share extension)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if url.scheme == "renewd" && url.host == "share" {
      // The share data is already in UserDefaults, Flutter will pick it up
      return true
    }
    return super.application(app, open: url, options: options)
  }

  // Forward APNS token to Firebase
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
