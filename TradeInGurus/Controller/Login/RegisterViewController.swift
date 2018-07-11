//
//  RegisterViewController.swift
//  TradeInGurus
//
//  Created by Admin on 8/28/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate, SBPickerSelectorDelegate
{

    @IBOutlet var btnDealer : UIButton!
    @IBOutlet var btnCustomer : UIButton!
    @IBOutlet var txtUserName : ACFloatingTextfield!
    @IBOutlet var txtFullName : ACFloatingTextfield!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDealer.isSelected = true
        btnCustomer.isSelected = false
        self.GetStates()
//        txtFullName.text = "Son Doe"
//        txtPhoneNumber.text = "1235345345"
//        txtEmail.text = "son@yopmail.com"
//        txtPassword.text = "123456"
//        txtUserName.text = "SONDOE"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                            else{
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
        var deviceToken = "ABCDEFGHIJKLMNO"
        
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
        let dictionaryParams : NSDictionary = [
            "service": "signup",
            
            "request" : [
                "data": ["username":txtUserName.text!.trim(),
                         "password":txtPassword.text!.trim(),
                         "fullname":txtFullName.text!.trim(),
                         "email":txtEmail.text!.trim(),
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
                         "pincode" : txtZipcode.text!.trim()],
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
