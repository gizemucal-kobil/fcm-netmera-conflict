import UIKit
import Flutter
import netmera_flutter_sdk

//This function is needed for sending messages to the dart side. (Setting the callback function)
func registerPlugins(registry: FlutterPluginRegistry) {
    NetmeraFlutterSdkPlugin.register(
    with: registry.registrar(forPlugin: "netmera_flutter_sdk")!)
}

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

        NetmeraFlutterSdkPlugin.setPluginRegistrantCallback(registerPlugins)
        FNetmera.logging(true)
        FNetmera.initNetmera(netmeraApiKey)
        FNetmera.setPushDelegate(self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FNetmeraService.handleWork(ON_PUSH_REGISTER, dict: ["pushToken": deviceToken])
    }

    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        FNetmeraService.handleWork(ON_PUSH_RECEIVE, dict:["userInfo" : userInfo])
    }

    /// official netmera setup https://developer.netmera.com/en/flutter/quick-start
    /// it conflicts with local notifications plugin and causes duplicated foreground message.
    /*
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
        @escaping () -> Void) {

        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            FNetmeraService.handleWork(ON_PUSH_DISMISS,dict:["userInfo" : response.notification.request.content.userInfo])
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            FNetmeraService.handleWork(ON_PUSH_OPEN, dict:["userInfo" : response.notification.request.content.userInfo])
        }
        completionHandler()
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([UNNotificationPresentationOptions.alert])
    }
    */

    // recommended by netmera support team as a solution to local notifications duplicated foreground issue
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
        } else {
            super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
        }
        completionHandler()
    }

    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        super.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
}

