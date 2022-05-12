import UIKit
import Flutter
import UserNotificationsUI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    TalkingDataAppAnalyticsPlugin.pluginSessionStart("016127D4E3C844CCAB7BF4EE55D88CFE", withChannelId: "AppStore")
    WXApi.registerApp("wx5fd9da0bd24efe83", universalLink: "https://file.tianjiemedia.com/")
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (accepted, error) in
        if !accepted {
            
        }
    }
    
    AppScore.register(with: self.registrar(forPlugin: "AppScore")!)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return YQResonseHandler.handleOpenUniversalLink(userActivity)
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if AppScore.handleOpen(url) {
            return true
        }
        
        return YQResonseHandler.handleOpen(url)
    }
    
}
