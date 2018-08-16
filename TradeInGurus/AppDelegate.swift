//
//  AppDelegate.swift
//  TradeInGurus
//
//  Created by Admin on 8/26/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit
import CoreLocation
import Fabric
import Crashlytics
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    
    var userlocation : CLLocation? = nil
    let userLogin = UserDefaults.standard.bool(forKey: "IsUserLoggedIn")
    var window: UIWindow?
    var responseInfo = NSDictionary()
    var isActive = false
    var txtNotifiMsg = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if launchOptions != nil {
            let dictNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
            self.perform(#selector(getLauncing(dictNotif:)), with: dictNotification, afterDelay: 1.0)
        }
        
        if userLogin {
            isBackground = true
            AppApi.sharedInstance.notifiCount()
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            //customeNotification()
        } else {
            // Fallback on earlier versions
        }
        let types: UIUserNotificationType = [.alert,.sound,.badge]
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        GetCurrentLocation.sharedObject.updateCurrentLocation()
        application.applicationIconBadgeNumber = 0
        let language  = NSLocale.preferredLanguages[0]
        let arrLanguage = language.components(separatedBy: "-")
        if arrLanguage[0] == "en"
        {
            Language = "EN"
        }
        else  if arrLanguage[0] == "ar"
        {
            Language = "AR"
        }
        
        
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics()])
        //Crashlytics.sharedInstance().crash()
        // abort()
        
        IQKeyboardManager.shared().isEnabled = true
        return true
    }
    
    func getLauncing(dictNotif: NSDictionary) {
        getNotification(notificInfo: dictNotif, identifire: "")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        sendmakeBadgezeroReq()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        let language  = NSLocale.preferredLanguages[0]
        let arrLanguage = language.components(separatedBy: "-")
        if arrLanguage[0] == "en"
        {
            Language = "EN"
        }
        else  if arrLanguage[0] == "ar"
        {
            Language = "AR"
        }
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        if userLogin {
            isActive = true
        }
        sendmakeBadgezeroReq()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        debugPrint("Devicetoken: \(token)")
        UserDefaults.standard.set(token, forKey: "DeviceToken")
        UserDefaults.standard.synchronize()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        debugPrint(userInfo)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        let user_Info = userInfo as? NSDictionary
        self.responseInfo = responseInfo as! NSDictionary
        getNotification(notificInfo: user_Info!, identifire: identifier!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            completionHandler()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let user_Info = userInfo as? NSDictionary
        getNotification(notificInfo: user_Info!, identifire: "")
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint(notification.request.content.userInfo)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        debugPrint(response.notification.request.content.userInfo)
        let user_Info = response.notification.request.content.userInfo as? NSDictionary
        let txt = response as? UNTextInputNotificationResponse
        self.txtNotifiMsg = txt?.userText ?? ""
        getNotification(notificInfo: user_Info!, identifire: response.actionIdentifier)
        completionHandler()
    }
    
    
    //MARK: - Notification Navigation -
    
    func getNotification(notificInfo : NSDictionary, identifire: String) {
        
        if let dict = notificInfo["aps"] as? NSDictionary {
            let dictData = dict.value(forKey: "data") as? NSDictionary
            
            let fromID = dictData?.value(forKey: "fromId") as? String ?? ""
            let type = dictData?.value(forKey: "nt_type") as? String
            var txtMessage = ""
            
            txtMessage = self.responseInfo.object(forKey: "UIUserNotificationActionResponseTypedTextKey") as? String ?? "not send"
            if type == "message" {
                if AppUtilities.sharedInstance.isInChatScreen && AppUtilities.sharedInstance.strOppUserId == fromID {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newMessage"), object: nil, userInfo: notificInfo as? [AnyHashable : Any])
                } else {
                    if  txtMessage  == "not send" {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newTapMessage"), object: nil, userInfo: notificInfo as? [AnyHashable : Any])
                    }
                }
            } else if type == "customer_request" {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "customer_request"), object: nil, userInfo: notificInfo as? [AnyHashable : Any])
            } else if type == "dealer_offer_response" {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dealer_offer_response"), object: nil, userInfo: notificInfo as? [AnyHashable : Any])
            } else if type == "dealer_req_response" {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newTapMessage"), object: nil, userInfo: notificInfo as? [AnyHashable : Any])
            }
            
            if identifire == "comment" {
                txtMessage = ""
                if self.txtNotifiMsg == "" {
                    txtMessage = self.responseInfo.object(forKey: "UIUserNotificationActionResponseTypedTextKey") as? String ?? "not send"
                } else {
                    txtMessage = self.txtNotifiMsg
                    self.txtNotifiMsg = ""
                }
                self.sendMessage(txtComment: txtMessage, fromID: fromID)
            }
        }
    }
    
    
    func sendMessage(txtComment: String, fromID: String) {
        
        let dictionaryParams : NSDictionary = [
            "service": "sendmessage",
            "request" : [
                "data" : ["toId" : fromID,
                          "message" : txtComment
                ],
            ],
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                
                if let object = object as? NSDictionary
                {
                    if  (object.value(forKey: "success") as? Bool) != nil
                    {
                        
                        let responseDic = object
                        debugPrint(responseDic)
                        if let status = responseDic.value(forKey: "success") as? Int
                        {
                            if(status == 1)
                            {
                                
                            }
                            else {
                                
                            }
                        }
                        else
                        {
                            
                        }
                    }
                    else
                    {
                        AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "\(object.value(forKey: "message") as? String ?? "" )" as NSString)
                        
                    }
                }
                else
                {
                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: (NSLocalizedString("Server is temporary down !! Plz try after sometime", comment: "Server is temporary down !! Plz try after sometime") as NSString))
                }
                
            })
        })
    }
    
    func sendmakeBadgezeroReq()
    {
        let isUserLogin = UserDefaults.standard.bool(forKey: "IsUserLoggedIn")
        if !isUserLogin { return }
        let dictionaryParams : NSDictionary = [
            "service": "makeBadgezero",
            "request" : [],
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            ]  as NSDictionary
        print(AppUtilities.sharedInstance.jsonToString(json: dictionaryParams))
        AppUtilities.sharedInstance.dataTask(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                if let object = object as? NSDictionary
                {
                    print(object)
                }
            })
        })
    }
}

