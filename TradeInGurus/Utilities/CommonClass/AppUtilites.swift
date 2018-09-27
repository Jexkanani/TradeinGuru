//
//  AppUtilites.swift
//  Nile
//
//  Created by Admin on 7/12/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import MessageUI
import MobileCoreServices//tradeingurus.com
import FBSDKCoreKit
import Firebase

//let Base_URL = "http://tradeingurus.com/WebService/service"
let Base_URL = "https://app.tradeingurus.com/WebService/service"
//let Base_URL = "http://www.app.tradeingurus.com/WebService/service"

let Local_URL = Base_URL
let APP_Title = NSLocalizedString("TradeInGurus", comment: "comm")

extension NSObject {
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
    
    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}

class AppUtilities
{
    //MARK: - Golbal Contstant -
    var dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
    class GlobalConstant: NSObject
    {
        struct ColorConstants
        {
            static let purpleColor = UIColor(red: 132.0/255.0, green: 92.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            static let inactiveColor = UIColor(red: 208.0/255.0, green: 194.0/255.0, blue: 253.0/255.0, alpha: 1.0)
            static let deacivteColor = UIColor(red: 207/255.0, green: 201/255.0, blue: 224.0/255.0, alpha: 1.0)
            static let offWhiteColor = UIColor(red: 246.0/255.0, green: 245.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        }
        struct FontConstants
        {
            static let BoldFont = "Ubuntu-Bold"
            static let RegularFont = "Ubuntu"
            static let MediumFont = "Ubuntu-Medium"
            static let LightFont = "Ubuntu-Light"
            static let LightItalicFont = "Ubuntu-LightItalic"
            static let BoldItalicFont = "Ubuntu-BoldItalic"
            static let MediumItalicFont = "Ubuntu-MediumItalic"
        }
    }
    
    //MARK: - Intilize Varriable -
    
    var isInChatScreen : Bool = false
    var strOppUserId : String = "0"

    class var sharedInstance :AppUtilities {
        struct Singleton {
            static let instance = AppUtilities()
        }
        return Singleton.instance
    }
    
    // FB Events
    func AppEvents(view : UIViewController) {
        let strClassname = String(describing: view.self.className)
        debugPrint("strClassname: \(strClassname)")
        FBSDKAppEvents.logEvent(strClassname)
        
        Analytics.setScreenName(strClassname, screenClass: strClassname)
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(strClassname)",
            AnalyticsParameterItemName: strClassname,
            AnalyticsParameterContentType: "Screen Name"
            ])
        
        dataLayer.push(["event": "OpenScreen", "screenName": strClassname])
//        dataLayer.push(["event": "openScreen", "screenName": "Main Screen1"])
    }
    
    //MARK:- Get User Details -
    func getLoginDict()->NSDictionary
    {
        let dictData = UserDefaults.standard.data(forKey: "LoginResponse")
        let dict = NSKeyedUnarchiver.unarchiveObject(with: dictData!)
        return dict as! NSDictionary
    }
    
    func getLoginUserType()->String
    {
        let dict = getLoginDict()
        let user_type = dict.value(forKey: "type") as! String
        return user_type
    }
    
    
    func getLoginUserName()->String
    {
        let dict = getLoginDict()
        let username = dict.value(forKey: "username") as! String
        return username
    }
    
    func getLoginUserMobile()->String
    {
        let dict = getLoginDict()
        let mobile = dict.value(forKey: "mobile") as! String
        return mobile
    }
    
    func getLoginUserProfile()->String
    {
        let dict = getLoginDict()
        let profilepic = dict.value(forKey: "profilepic") as! String
        return profilepic
    }
    
    func getLoginUserEmail()->String
    {
        let dict = getLoginDict()
        let email = dict.value(forKey: "email") as! String
        return email
    }
    
    
    func getLoginUserId()->String
    {
        let dict = getLoginDict()
        let user_id = dict.value(forKey: "user_id") as! String
        return user_id
    }
    
    
    func getSecretUserId()->String
    {
        if let token = UserDefaults.standard.value(forKey: "SecretLogID") as? Int
        {
            return "\(token)"
        }
        return "0"
    }
    
    
    func getLoginUserToken()->String
    {
        if let token = UserDefaults.standard.value(forKey: "Token") as? String
        {
            return token
        }
        return "0"
    }
    
    func getLoginUserSecretId()->Int
    {
        if let secret_log_id = UserDefaults.standard.value(forKey: "secret_log_id") as? Int
        {
            return secret_log_id
        }
        return 0
    }
    
    func getLoginAddress()->String
    {
        let dict = getLoginDict()
        let address = dict.value(forKey: "address") as! String
        return address
    }
    
    func getLoginCity()->String
    {
        let dict = getLoginDict()
        let city = dict.value(forKey: "city") as! String
        return city
    }

    func getLoginPincode()->String
    {
        let dict = getLoginDict()
        let pincode = dict.value(forKey: "pincode") as! String
        return pincode
    }

    func getLoginCountry()->String
    {
        let dict = getLoginDict()
        let country = dict.value(forKey: "county") as! String
        return country
    }
    
    func getLoginStateId()->String
    {
        let dict = getLoginDict()
        let stateid = dict.value(forKey: "stateid") as! String
        return stateid
    }
    
    /*=======================================================
     Function Name: isValidEmail
     Function Param : - String
     Function Return Type : - bool
     Function purpose :- check for valid Email ID
     ========================================================*/
    
    func isValidEmail(testStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }

    /*=======================================================
     Function Name: validatePhone
     Function Param : - String
     Function Return Type : - bool
     Function purpose :- check for valid phone Number
     ========================================================*/
    
    func isValidPhone(phone: String) -> Bool
    {
        //        ^\\d{3}-\\d{3}-\\d{4}$
        //        "^[a-z]{1,10}$
        let PHONE_REGEX = "^[0-9]{6,}$" //"^\\+?\\d{3}\\d{3}\\d{4}{}$" //"+[0-9]{8,11}"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: phone)
        return result
        
    }
    
    
    // check internet connectivity
    class func isConnectedToNetwork() -> Bool
    {
        
        let reachability = Reachability.forInternetConnection()
        let status : NetworkStatus = reachability!.currentReachabilityStatus()
        if status == NotReachable
        {
            AppUtilities.sharedInstance.showAlert(title: App_Title as NSString, msg: "Check your internet connection.")
            return false
        }
        else
        {
            return true
        }
    }
    
    func isNetworkRechable() -> Bool
    {
        return AppUtilities.isConnectedToNetwork()
    }

    func compressImage(image:UIImage) -> NSData
    {
        var compression:CGFloat!
        let maxCompression:CGFloat!
        compression = 0.9;
        maxCompression = 0.1;
        var imageData = UIImageJPEGRepresentation(image, compression)! as NSData
        while (imageData.length > 10 && compression > maxCompression)
        {
            compression = compression - 0.10;
            imageData = UIImageJPEGRepresentation(image, compression)! as NSData
        }
        return imageData
    }
    
    
    /*=======================================================
     Function Name: dataTask
     Function Param : - URL,Strig,String,Block
     Function Return Type : -
     Function purpose :- Global Class For API Calling.
     ========================================================*/
    
    //MARK: - API Method
    
    func dataTaskLocal(method: String,params:NSDictionary, strMethod: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ())  {
        
        debugPrint(strMethod)
        debugPrint(method)
        let strurl = Local_URL.appending(strMethod)
        debugPrint(strurl)
        let request = NSMutableURLRequest(url: NSURL(string: strurl)! as URL)
        request.httpMethod = method
        let paramdata = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        //let paramdata = NSKeyedArchiver.archivedData(withRootObject: params)
        debugPrint(paramdata!)
        let convertedString = String(data: paramdata!, encoding: String.Encoding.utf8) // the data will be converted to the string
        debugPrint(convertedString!)
        if paramdata != nil {
            request.httpBody = paramdata
            
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil
            {
                debugPrint(error.debugDescription)
            }
            if let data = data {
                let returnData = String(data: data, encoding: .utf8)
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode
                {
                    completion(true, json as AnyObject?)
                }
                else
                {
                    completion(false, json as AnyObject?)
                }
            }
            }.resume()
    }
    
    
    func dataTaskTest(request: NSMutableURLRequest, method: String,params:NSString, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        
        request.httpMethod = method
        request.httpBody = params.data(using: String.Encoding.utf8.rawValue)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    completion(true, json as AnyObject?)
                } else {
                    completion(false, json as AnyObject?)
                }
            }
            }.resume()
    }
    
    
    func dataTaskNew(request: NSMutableURLRequest, method: String,params:NSString, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        
        print(params)
        request.httpMethod = method
        request.httpBody = params.data(using: String.Encoding.utf8.rawValue)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if let data = data {
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    completion(true, json as AnyObject?)
                } else {
                    completion(false, json as AnyObject?)
                }
            }
            }.resume()
    }
    
    func dataTask(method: String,params:NSDictionary, strMethod: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ())  {
        
        debugPrint(strMethod)
        debugPrint(method)
        let strurl = Base_URL.appending(strMethod)
        debugPrint(strurl)
        let request = NSMutableURLRequest(url: NSURL(string: strurl)! as URL)
        request.httpMethod = method
        request.timeoutInterval = 60.0
        let paramdata = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        //let paramdata = NSKeyedArchiver.archivedData(withRootObject: params)
        debugPrint(paramdata!)
        let convertedString = String(data: paramdata!, encoding: String.Encoding.utf8) // the data will be converted to the string
        debugPrint(convertedString!) // <-- here is ur string
        
        if paramdata != nil {
            request.httpBody = paramdata
            
        }
        
        debugPrint(request)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil
            {
                debugPrint(error.debugDescription)
                completion(false, error as AnyObject?)
            }
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
//                let response as? HTTPURLResponse ?? "" //jex
                
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode
                {
                    completion(true, json as AnyObject?)
                }
                else
                {
                    completion(false, json as AnyObject?)
                    
                }
            }
            }.resume()
    }
    
    func post(params:NSDictionary,strMethod: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()){
        dataTask(method: "POST", params: params, strMethod: strMethod, completion: completion)
    }
    
    func put(params:NSDictionary,strMethod: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(method: "PUT", params: params, strMethod: strMethod, completion: completion)
        
    }
    
    func get(params:NSDictionary,strMethod: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask( method: "GET", params: params, strMethod: strMethod, completion: completion)
        
    }
    
    
//    func dataTaskWithImage(request: NSURLRequest,method: String,strMethod: String,params:NSMutableDictionary, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
//        let session = URLSession(configuration: URLSessionConfiguration.default)
//        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
//            if let data = data {
//                let json = try? JSONSerialization.jsonObject(with: data, options: [])
//                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
//                    completion(true, json as AnyObject?)
//                } else {
//                    completion(false, json as AnyObject?)
//                }
//            }
//            }.resume()
//    }
//    
//    func postwithImage(request: NSURLRequest,method: String,strMethod: String,params:NSMutableDictionary, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
//        dataTaskWithImage(request: request,method:method,strMethod: strMethod, params: params, completion: completion)
//        
//    }
    
    
    
    /*=======================================================
     Function Name: showAlert
     Function Param : - String
     Function Return Type : -
     Function purpose :- Show Alert With specific Message
     ========================================================*/
    
    func showAlert(title : NSString, msg : NSString)
    {
        let alert = UIAlertView(title: title as String, message: msg as String, delegate: nil, cancelButtonTitle: "OK")
        DispatchQueue.main.async {
            alert.show()
        }
       
    }
    
    /*=======================================================
     Function Name: showLoader
     Function Param : -
     Function Return Type : -
     Function purpose :- Show Loader
     ========================================================*/
    
    
    func showLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 120
        config.backgroundColor = UIColor.white
        config.spinnerColor = UIColor.black
        config.titleTextColor = UIColor.black
        config.spinnerLineWidth = 1.5
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.3
        //        config.titleTextFont = UIFont.init(name: "Montserrat-Regular", size: 15.0)!
        config.titleTextFont = UIFont.systemFont(ofSize: 15.0)
        
        SwiftLoader.setConfig(config)
        SwiftLoader.show("\(NSLocalizedString("Loading", comment: "cmm")) ..", animated: true)
    }
    
    func hideLoader()
    {
        DispatchQueue.main.async {
            SwiftLoader.hide()
        }
    }
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBodyWithParameters(parameters: NSMutableDictionary?,boundary: String) -> NSData {
        let body = NSMutableData()
        if parameters != nil {
            
            if (parameters?["video"] as! String).characters.count > 0 {
                
                let filename = "video1.mp4" //"image\(i).png"
                
                //                let outputPath = "\(NSTemporaryDirectory())output1.mov"
                //                let uploadUrl = URL(fileURLWithPath: outputPath as String)
                //
                //                self.compressVideo(inputURL: URL(string: (parameters?["video"] as! String))!, outputURL: uploadUrl, handler: { (handler) in
                //
                //                    if handler.status == AVAssetExportSessionStatus.completed {
                //                        debugPrint("completedd")
                //                    }
                //                })
                
                let data = NSData(contentsOf: URL(string: (parameters?["video"] as! String))!)
                let mimetype = "video/mp4"
                
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                
                body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
                
                body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append(data! as Data)
                body.append("\r\n".data(using: String.Encoding.utf8)!)
            }
            else {
                let filename = "image1.png" //"image\(i).png"
                let data = UIImageJPEGRepresentation(parameters?["image"] as! UIImage,1);
                let mimetype = mimeTypeForPath(path: filename)
                
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                
                body.append("Content-Disposition:form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
                
                body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append(data!)
                body.append("\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        return body
    }
    
    func mimeTypeForPath(path: String) -> String {
        
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    
    func jsonToString(json: AnyObject) -> String{
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            debugPrint(convertedString!) // <-- here is ur string
            return convertedString!
        } catch let myJSONError {
            debugPrint(myJSONError)
            return ""
        }
        
    }
    //
    
    //MARK: - No Data Lable Function - 
    
    func setNoDataLabel(text:String, view:UIViewController)
    {
       
            let noDataLabel = UILabel()
            noDataLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 25)
            noDataLabel.text = text
            noDataLabel.numberOfLines = 0
            noDataLabel.font = UIFont(name: AppUtilities.GlobalConstant.FontConstants.RegularFont, size: 12)
            noDataLabel.textColor = UIColor .black
            noDataLabel.textAlignment = NSTextAlignment.center

    }

    //MARK: - Date Formatter -

    func get_time_from_UTC_time(string : NSString, createformatter: String, modifiedformatter: String) -> NSString {
        
        let dateformattor = DateFormatter()
        dateformattor.dateFormat = createformatter
        dateformattor.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        let dt = string
        let dt1 = dateformattor.date(from: dt as String)
        dateformattor.dateFormat = modifiedformatter
        dateformattor.timeZone = NSTimeZone.local
        return dateformattor.string(from: dt1!) as NSString
        
    }
    
}



//TextField Inset//

class MyTextField: UITextField
{
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}

class ButtonIconRight: UIButton
{
    override func imageRect(forContentRect contentRect:CGRect) -> CGRect
    {
        var imageFrame = super.imageRect(forContentRect: contentRect)
        imageFrame.origin.x = super.titleRect(forContentRect: contentRect).maxX - imageFrame.width + 10
        return imageFrame
    }
    
    override func titleRect(forContentRect contentRect:CGRect) -> CGRect
    {
        var titleFrame = super.titleRect(forContentRect: contentRect)
        if (self.currentImage != nil) {
            titleFrame.origin.x = super.imageRect(forContentRect: contentRect).minX
        }
        return titleFrame
    }
}

extension String
{
    func isEmptyOrWhitespace() -> Bool
    {
        
        if(self.isEmpty)
        {
            return true
        }
        
        return (self.trimmingCharacters(in : CharacterSet.whitespaces) == "")
    }
    
    func trim() -> String
    {
        return self.trimmingCharacters(in : CharacterSet.whitespacesAndNewlines)
    }


}

//MARK: - Comman Api Class -

class AppApi : NSObject
{
    class var sharedInstance :AppApi  {
        struct Singleton {
            static let instance = AppApi()
        }
        return Singleton.instance
    }
    
    func sendPushNoti(vid: String, userID : String, isOffer : Bool)
    {
        //AppUtilities.sharedInstance.showLoader()
        var dictionaryParams = NSDictionary()
        if isOffer == true {
            dictionaryParams = [
                "service": "SendNotification_offer",
                "request" : [
                    "data" :[
                        "id": vid,
                        "userid": userID]],                
                "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                         "token": AppUtilities.sharedInstance.getLoginUserToken()]
                ]  as NSDictionary
        }
        else {
             dictionaryParams  = [
                "service": "SendNotification_interest",
                "request" : [
                    "data" :[
                        "vid": vid,
                        "userid": userID]],
                
                "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                         "token": AppUtilities.sharedInstance.getLoginUserToken()]
                
                ]  as NSDictionary
        }
        
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                
                //AppUtilities.sharedInstance.hideLoader()
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
                                if let msg = responseDic.value(forKey: "message") as? String{
                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: msg as NSString)
                                }
                            }
                            else{
                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                }
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

    func notifiCount()
    {
        //AppUtilities.sharedInstance.showLoader()
        var dictionaryParams = NSDictionary()
        dictionaryParams = [
            "service": "GetNotificationCount",
            "request" : [
            ],
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                
                //AppUtilities.sharedInstance.hideLoader()
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
                                noticCount = responseDic.value(forKey: "totalunread") as? String ?? "0"
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Notification"), object: responseDic.value(forKey: "totalunread") as? NSDictionary)
                            }
                            else{
                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                }
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

    
    
    

}


