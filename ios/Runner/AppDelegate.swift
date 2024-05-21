import UIKit
import Flutter
import netmera_flutter_sdk

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, NetmeraPushDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        //For triggering onPushReceive when app is killed and push clicked by user
        let notification = launchOptions?[.remoteNotification]
        if notification != nil {
            self.application(application, didReceiveRemoteNotification: notification as! [AnyHashable : Any])
        }

        let netmeraApiKey = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { 
            FNetmera.logging(true)
            FNetmera.initNetmera(netmeraApiKey)
            FNetmera.setPushDelegate(self)
        })
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FNetmeraService.handleWork(ON_PUSH_REGISTER, dict: ["pushToken": deviceToken])
    }

    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if UIApplication.shared.applicationState == .active {
            FNetmeraService.handleWork(ON_PUSH_RECEIVE, dict:["userInfo" : userInfo])
        } else {
            FNetmeraService.handleWork(ON_PUSH_RECEIVE_BACKGROUND, dict:["userInfo" : userInfo])
        }
    }

    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
        @escaping () -> Void) {
        if response.notification.request.content.userInfo.keys.contains("_nm") {
            if response.actionIdentifier == UNNotificationDismissActionIdentifier {
                    FNetmeraService.handleWork(ON_PUSH_DISMISS,dict:["userInfo" : response.notification.request.content.userInfo])
            }
            else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
                    FNetmeraService.handleWork(ON_PUSH_OPEN, dict:["userInfo" : response.notification.request.content.userInfo])
            }
            completionHandler()
        } else {
            super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
        }
    }
}
