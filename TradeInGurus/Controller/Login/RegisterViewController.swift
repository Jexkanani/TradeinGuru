//
//  RegisterViewController.swift
//  TradeInGurus
//
//  Created by Admin on 8/28/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class RegisterViewController: UIViewController, UITextFieldDelegate, SBPickerSelectorDelegate, registerProtocolDelegate {

    @IBOutlet var btnDealer : UIButton!
    @IBOutlet var btnCustomer : UIButton!
    @IBOutlet var txtUserName : ACFloatingTextfield!
    @IBOutlet var txtFullName :ACFloatingTextfield!
    @IBOutlet var txtPassword : ACFloatingTextfield!
    @IBOutlet var txtEmail : ACFloatingTextfield!
    @IBOutlet var txtPhoneNumber : ACFloatingTextfield!
    @IBOutlet var txtConfirmPassword : ACFloatingTextfield!
    @IBOutlet var txtAddress : ACFloatingTextfield!
    @IBOutlet var txtCity : ACFloatingTextfield!
    @IBOutlet var txtZipcode : ACFloatingTextfield!
    @IBOutlet var txtStates : ACFloatingTextfield!
    @IBOutlet var txtCounty : ACFloatingTextfield!
    var ArrCounty = NSArray()
    var StrStateID = String()
    var logintype  = "email"
    let dicFb : NSMutableDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDealer.isSelected = true
        btnCustomer.isSelected = false
        AppUtilities.sharedInstance.AppEvents(view: self)
        
//        self.GetStates()
//        txtFullName.text = "Son Doe"
//        txtPhoneNumber.text = "1235345345"
//        txtEmail.text = "son@yopmail.com"
//        txtPassword.text = "123456"
//        txtUserName.text = "SONDOE"
        // Do any additional setup after loading the view.
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

    @IBAction func btnSignUpPressed(_ sender: Any) {
        if isCredentialValid(){
            signUp()
        }
    }
    
    
    @IBAction func btnLoginClk(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Facebook methods
    @IBAction func btnSignUpFb(_ sender: Any) {
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
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "FbDataPopUp") as? FbDataPopUp
                vc?.view.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width-30, height: 220.0)
                
                if (resultDic.value(forKey:"name") != nil)
                {
                    let userName = resultDic.value(forKey:"name")! as! String as NSString?
                    self.dicFb.setValue(userName, forKey: "name")
                }
                self.dicFb.setValue(((resultDic.value(forKey:"picture") as! NSDictionary).value(forKey: "data") as! NSDictionary).value(forKey: "url") as! String, forKey: "fbid")
                if (resultDic.value(forKey:"email") != nil)
                {
                    let userEmail = resultDic.value(forKey:"email")! as! String as NSString?
                    self.dicFb.setValue(userEmail, forKey: "email")
                    vc?.email = userEmail! as String
                }
                self.dicFb.setValue(resultDic.value(forKey:"id"), forKey: "fbid")
                vc?.dic = self.dicFb
                vc?.delegate = self
                self.presentPopupViewController(vc, animationType: MJPopupViewAnimationSlideBottomTop)
            }
        })
    }
    
    //MARK: - Textfield delegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Register Delegate Methods
    func clkDone(Email : String, Zipcode : String) {
        debugPrint(Email)
        debugPrint(Zipcode)
        if (Email != "") {
            self.dicFb.setValue(Email , forKey: "email")
        }

        self.dicFb.setValue(Zipcode , forKey: "zipcode")
        self.signUp()
        self.dismissPopupViewControllerWithanimationType(MJPopupViewAnimationSlideTopBottom)
    }
    
    func clkClose() {
        self.dismissPopupViewControllerWithanimationType(MJPopupViewAnimationSlideTopBottom)
    }
    
    //MARK: - Validation -
    func isCredentialValid() -> Bool {
        let is_valid  = true
        
        if (txtFullName.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter fullname")
            return false
        }
        else if (txtEmail.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter email")
            return false
        }
        else if !AppUtilities.sharedInstance.isValidEmail(testStr: txtEmail.text!){
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter valid email")
            return false
        }
            /*else if (txtUserName.text?.isEmptyOrWhitespace())!{
             
             AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter username")
             return false
             }*/
        else if (txtPassword.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter password")
            return false
        }
        else if (txtPassword.text?.characters.count)! < 6 {
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter atleast 6 digits password")
            return false
        }
        else if txtPassword.text != txtConfirmPassword.text {
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Password does not match")
            return false
        }
        else if (txtPhoneNumber.text?.isEmptyOrWhitespace())! == false {
            if !AppUtilities.sharedInstance.isValidPhone(phone: txtPhoneNumber.text!){
                AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "please enter valid mobile number")
                return false
            }
//            } else {
//                AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter phone number")
//                return false
//            }
        }
            /*else if (txtAddress.text?.isEmptyOrWhitespace())!{
             
             AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter address")
             return false
             }
             else if (txtCity.text?.isEmptyOrWhitespace())!{
             
             AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter city")
             return false
             }*/
        else if (txtZipcode.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter zipcode")
            return false
        }
        
        
        return is_valid
    }
    
    
    //MARK:- API Methods -
    func GetStates() {
        AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "getAllState",
            
            "request" : [
                "data": [
                ],
            ]
            ] as NSDictionary
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                AppUtilities.sharedInstance.hideLoader()
                
                AppUtilities.sharedInstance.hideLoader()
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
                                debugPrint(responseDic)
                                self.ArrCounty = responseDic["data"] as! NSArray
                                print(self.ArrCounty)
                            }
                            else {
                                if let errorMsg = responseDic.value(forKey: "message") as? String{
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
    
    func signUp()
    {
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        var deviceToken = "dd8714bdbcc11076888df23d910c5bbf158cdd09e7c81ffd43dc11804a96bfcb"
        
        if let deviceTc = UserDefaults.standard.value(forKey: "DeviceToken") as? String{
            deviceToken = deviceTc
        }
        /*
        var type = "dealer"
        if btnCustomer.isSelected
        {
            type = "customer"
        }
        */
        var email = String()
        var fbid = String()
//        var picture = String()
        var zipcode = String()
        var name = String()
        if (logintype == "email") {
            email = txtEmail.text!.trim()
            fbid = ""
//            picture = ""
            zipcode = txtZipcode.text!.trim()
            name = txtFullName.text!.trim()
        } else {
            if (dicFb["email"] != nil) {
                email = dicFb.value(forKey: "email") as! String
            }
            zipcode = dicFb.value(forKey: "zipcode") as! String
            fbid = dicFb.value(forKey: "fbid") as! String
            name = dicFb.value(forKey: "name") as! String
//            picture = dicFb.value(forKey: "picture") as! String
        }
        
        let dictionaryParams : NSDictionary = [
            "service": "signup",
            "request" : [
                "data": ["username":txtUserName.text!.trim(),
                         "password":txtPassword.text!.trim(),
                         "fullname":name,
                         "email":email,
                         "mobile":txtPhoneNumber.text!.trim(),
                         "stateid" : StrStateID,
                         "country" : txtCounty.text!.trim(),
                         "type":"customer",
                         "platform":"ios",
                         "device_id": deviceToken,
                         "lat": GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.latitude ?? 00, //?? 21.170240,
                         "lng": GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.longitude ?? 00,
                         "address" : txtAddress.text!.trim(),
                         "city" : txtCity.text!.trim(),
                         "pincode" : zipcode,
                         "fbid" : fbid,
                         //"url" : picture,
                         "logintype":logintype]
            ]
            ] as NSDictionary
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                AppUtilities.sharedInstance.hideLoader()
                
                AppUtilities.sharedInstance.hideLoader()
                if let object = object as? NSDictionary
                {
                    if  (object.value(forKey: "success") as? Bool) != nil
                    {
                        
                        let responseDic = object
                        debugPrint(responseDic)
                        if let status = responseDic.object(forKey: "success") as? Int
                        {
                            if(status == 1)
                            {
                                
                                let respnseData = NSKeyedArchiver.archivedData(withRootObject: responseDic.value(forKey: "data") ?? "")
                                UserDefaults.standard.set(respnseData, forKey: "LoginResponse")
                                UserDefaults.standard.set(responseDic.value(forKey: "token"), forKey: "Token")
                                UserDefaults.standard.set(responseDic.value(forKey: "secret_log_id"), forKey: "SecretLogID")

                                
                                UserDefaults.standard.set(true, forKey: "IsUserLoggedIn")
                                UserDefaults.standard.synchronize()
                                self.navigationController?.popViewController(animated: true)
                                AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "You are registered successfully. Please login" as NSString)

                            }
                            else{
                                if let errorMsg = responseDic.value(forKey: "message") as? String{ //jignesh     message = "Sorry, that is not valid input. You missed pincode parameters";
                                    let str = responseDic.value(forKey: "message") as? String
//                                    let aString = "This is my string"
                                    let newString = str?.replacingOccurrences(of: "pincode", with: "zipcode", options: .literal, range: nil)
                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: newString! as NSString)
                                    /*if str?.range(of: "pincode") != nil { //} range("pincode") != nil {
                                        let newString = str.replacingOccurrences(of: "pincode", with: "zipcode", options: .literal, range: nil)
//                                        println("exists")
                                    } else {
                                        AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                    }*/
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
    
    
    @IBAction func Btn_StateTFTouch(_ sender: Any) {
        self.view.endEditing(true)
        let picker = SBPickerSelector.picker()
        picker.pickerData = ArrCounty.value(forKey: "statename") as! [Any] //picker content
        picker.delegate = self
        picker.pickerType = SBPickerSelectorType.text
        picker.doneButtonTitle = "Done"
        picker.cancelButtonTitle = "Cancel"
        let point: CGPoint = view.convert(txtCounty.frame.origin, from: txtCounty.superview)
        var frame: CGRect = txtCounty.frame
        frame.origin = point
        picker.showPickerOver(self)
    }
    
    func pickerSelector(_ selector: SBPickerSelector, selectedValue value: String, index idx: Int) {
        print(idx)
        StrStateID =  ((ArrCounty.object(at: idx) as! NSDictionary).value(forKey: "id")) as! String
        txtStates.text = value
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
