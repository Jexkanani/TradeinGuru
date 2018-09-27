//
//  LoginViewController.swift
//  TradeInGurus
//
//  Created by Admin on 8/26/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit
import UserNotifications
import FBSDKCoreKit
import FBSDKLoginKit

extension String {
    func checkTextSufficientComplexity() -> Bool{
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: self)
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluate(with: self)
        
        let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        
        let specialresult = texttest2.evaluate(with: self)
        
        return capitalresult && numberresult && specialresult && self.characters.count >= 8
    }
}

//struct MyProfileRequest: GraphRequestProtocol {
//    struct Response: GraphResponseProtocol {
//        init(rawResponse: Any?) {
//            // Decode JSON from rawResponse into other properties here.
//        }
//    }
//
//    var graphPath = "/me"
//    var parameters: [String : Any]? = ["fields": "id, email"]
//    var accessToken = AccessToken.current
//    var httpMethod: GraphRequestHTTPMethod = .GET
//    var apiVersion: GraphAPIVersion = .defaultVersion
//}



class LoginViewController: UIViewController, UITextFieldDelegate,UNUserNotificationCenterDelegate
{
    //MARK: - All Outlets -
    @IBOutlet var txtUserName : ACFloatingTextfield!
    @IBOutlet var txtPassword : ACFloatingTextfield!
    @IBOutlet var btnLogin : UIButton!
    @IBOutlet var btnDealer : UIButton!
    @IBOutlet var btnCustomer : UIButton!
    
    var fromUserId  = ""
    var logintype  = "email"
    let dicFb : NSMutableDictionary = NSMutableDictionary()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        btnDealer.isSelected = true
        btnCustomer.isSelected = false
        
        let userLogin = UserDefaults.standard.bool(forKey: "IsUserLoggedIn")
        
        if userLogin{
            self.performSegue(withIdentifier: "Home", sender: self)
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
        } else {
            // Fallback on earlier versions
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert,.sound,.badge],
                completionHandler: { (granted,error) in
                    if granted{
                        
                    } else {
                        let alert = UIAlertController(title: "Notification Access", message: "In order to use this application, turn on notification permissions.", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                        alert.addAction(alertAction)
                        //self.present(alert , animated: true, completion: nil)
                    }
                    self.viewAction()
            })
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    //MARK: - Custome Notification -
    func viewAction(){
        if #available(iOS 10.0, *) {
            let commentAction = UNTextInputNotificationAction(identifier: "comment", title: "Add Comment", options: [], textInputButtonTitle: "Send", textInputPlaceholder: "Add Comment Here")
            let alarmCategory = UNNotificationCategory(identifier: "chat",actions: [commentAction],intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
            
            let content = UNMutableNotificationContent()
            
            content.categoryIdentifier = "chat"
            _ = UNNotificationRequest(identifier: "exampleNotification", content: content, trigger: nil)
            addNotification(content: content, trigger: nil, indentifier: "Alarm")
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    @available(iOS 10.0, *)
    func addNotification(content:UNNotificationContent,trigger:UNNotificationTrigger?, indentifier:String){
        let request = UNNotificationRequest(identifier: indentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {
            (errorObject) in
            if let error = errorObject{
                AppUtilities.sharedInstance.showAlert(title: "App", msg: "Error \(error.localizedDescription) in notification \(indentifier)" as NSString)
                print("Error \(error.localizedDescription) in notification \(indentifier)")
            }
            
        })
    }
    
    
    
    //MARK: - Text Field Delegate -
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .transitionCurlUp, animations: {
        }, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField.text == ""
        {
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .transitionCurlDown, animations: {
            }, completion: nil)
        }
        
    }
    //MARK: - All Button Action -
    
    @IBAction func btnDelarPressed(_ sender: Any) {
        btnDealer.isSelected = true
        btnCustomer.isSelected = false
    }
    
    @IBAction func btnCostomerPresed(_ sender: Any) {
        btnDealer.isSelected = false
        btnCustomer.isSelected = true
    }
    
    @IBAction func btnLoginPressed(_ sender: Any) {
        if isCredentialValid(){
            login()
        }
    }
    
    @IBAction func btnLoginFb(_ sender: Any) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], handler: { (result, error) -> Void in
            
            print("\n\n result: \(result)")
            print("\n\n Error: \(error)")
            
            if (error == nil)
            {
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if(fbloginresult.isCancelled) {
                    self.logintype = "email"
                    // Show Cancel alert
                } else {
//                    if(fbloginresult.grantedPermissions.contains("email")) {
//                        dicFb.setValue(<#T##value: Any?##Any?#>, forKey: "email")
//                    }
                    self.logintype = "fb"
                    self.returnUserData()
                    // fbLoginManager.logOut()
                }// else {
                    // ask for email and then allow to login
                //}
            }
        })
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name,picture,gender"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil)
            {
                self.logintype = "email"
                // Process error
                print("\n\n Error: \(error)")
            }
            else
            {
                let resultDic = result as! NSDictionary
                print("\n\n  fetched user: \(result!)")
                
//                if (resultDic.value(forKey:"name") != nil)
//                {
//                    let userName = resultDic.value(forKey:"name")! as! String as NSString?
//                    print("\n User Name is: \(userName)")
//                    dicFb.setValue(userEmail, forKey: "email")
//                }
//
                self.dicFb.setValue(((resultDic.value(forKey:"picture") as! NSDictionary ).value(forKey: "data") as! NSDictionary).value(forKey: "url") as! String, forKey: "fbid")
                
                if (resultDic.value(forKey:"email") != nil)
                {
                    let userEmail = resultDic.value(forKey:"email")! as! String as NSString?
                    print("\n User Email is: \(userEmail)")
                    self.dicFb.setValue(userEmail, forKey: "email")
                }
                self.dicFb.setValue(resultDic.value(forKey:"id"), forKey: "fbid")
                self.login()
            }
        })
    }
    
    @IBAction func btnSignUpClk(_ sender: UIButton)
    {
        let register_VC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.navigationController?.pushViewController(register_VC, animated: true)
    }
    
    
    @IBAction func btnForgotPassClk(_ sender: UIButton)
    {
        let forgot_VC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(forgot_VC, animated: true)
    }
    
    
    //MARK: -  Validation -
    func isCredentialValid() -> Bool {
        let is_valid  = true
        
        if (txtUserName.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter username")
            return false
        }
        /* else if (txtUserName.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter email")
            return false
        }
        else if !AppUtilities.sharedInstance.isValidEmail(testStr: txtUserName.text!){
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter valid email")
            return false
        }*/
        else if (txtPassword.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter password")
            return false
        }
        return is_valid
    }
    
    //MARK:- API Methods -
    func login() {
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
//        var deviceToken = "5VM99AJr13f-2FbdGgiBJbYAcUgYGF8qy"
        var deviceToken = "dd8714bdbcc11076888df23d910c5bbf158cdd09e7c81ffd43dc11804a96bfcb"
        if let deviceTc = UserDefaults.standard.value(forKey: "DeviceToken") as? String {
            deviceToken = deviceTc
        }
        
        var email = String()
        var fbid = String()
        var picture = String()
        if (logintype == "email") {
            email = txtUserName.text!.trim()
            fbid = ""
            picture = ""
        } else {
            if (dicFb["email"] != nil) {
                email = dicFb.value(forKey: "email") as! String
            }
            fbid = dicFb.value(forKey: "fbid") as! String
//            picture = dicFb.value(forKey: "picture") as! String
        }
        
        var type = "dealer"
        if btnCustomer.isSelected
        {
            type = "customer"
        }
        let dictionaryParams : NSDictionary = [
            "service": "login",
            "request" : [
                "data": ["email":email,
                         "password":txtPassword.text!.trim(),
                         "type":type,
                         "platform":"ios",
                         "device_id": deviceToken,
                         "logintype":logintype,
                         "fbid":fbid]]//,
                         //"picture" : picture]]
            ]  as NSDictionary
        
        print(dictionaryParams)
        AppUtilities.sharedInstance.dataTask(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                AppUtilities.sharedInstance.hideLoader()
                if let object = object as? NSDictionary
                {
                    if  (object.value(forKey: "success") as? Bool) != nil
                    {
                        let responseDic = object
                        print(responseDic)
                        AppUtilities.sharedInstance.AppEvents(view: self)
//                        FBSDKAppEvents.logEvent("Logged_In")
//                        [FBSDKAppEvents
//                            logEvent:@"Applogin"];
//                        
//                        let event = AppEvent(name: "Logged_In")
//                        AppEventsLogger.log(event)
                        
                        if let status = responseDic.value(forKey: "success") as? Int
                        {
                            if(status == 1)
                            {
                                let respnseData = NSKeyedArchiver.archivedData(withRootObject: responseDic.value(forKey: "data") ?? "")
                                UserDefaults.standard.set(respnseData, forKey: "LoginResponse")
                                UserDefaults.standard.set(responseDic.value(forKey: "token"), forKey: "Token")
                                UserDefaults.standard.set(responseDic.value(forKey: "secret_log_id"), forKey: "SecretLogID")
                                UserDefaults.standard.set(true, forKey: "IsUserLoggedIn")
                                UserDefaults.standard.synchronize()
                                self.performSegue(withIdentifier: "Home", sender: self)
                            }
                            else {
                                if let errorMsg = responseDic.value(forKey: "message") as? String {
                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                }
                            }
                        }
                        else
                        {
                            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "\(object.value(forKey: "message") as? String ?? "" )" as NSString)
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
    
    
    
    // MARK: - Memory Life Cycle -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
