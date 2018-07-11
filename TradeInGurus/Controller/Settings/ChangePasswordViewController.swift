//
//  ChangePasswordViewController.swift
//  TradeInGurus
//
//  Created by Admin on 14/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var txtOldPassword: ACFloatingTextfield!
    @IBOutlet weak var txtNewPassword: ACFloatingTextfield!
    @IBOutlet weak var txtRetypePassword: ACFloatingTextfield!
    
    
    //MARK: - UIView Life Cycle -

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    //MARK: -  Validation -
    func isCredentialValid() -> Bool {
        let is_valid  = true
        
        if (txtOldPassword.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter Old Password")
            return false
        }
        else if (txtNewPassword.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter New Password")
            return false
        }
        else if (txtRetypePassword.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter retype password")
            return false
        }
        else if txtRetypePassword.text != txtNewPassword.text{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Password do not match")
            return false
        }


        return is_valid
    }
    
    
    //MARK:- API Methods -
    
    
    func changePassword()
    {
        
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        
       
        let dictionaryParams : NSDictionary = [
            "service": "changepassword",
            
            "request" : [
                    "oldpassword":txtOldPassword.text!.trim(),
                    
                    "newpassword":txtNewPassword.text!.trim(),
                    
                    "confirmpassword":txtRetypePassword.text!.trim()
                
            ]
            ,
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]

            ]  as NSDictionary
        
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
                                
                                AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Profile edited sucessfully" as NSString)

//                                let respnseData = NSKeyedArchiver.archivedData(withRootObject: responseDic.value(forKey: "data") ?? "")
//                                UserDefaults.standard.set(respnseData, forKey: "LoginResponse")
//                                UserDefaults.standard.synchronize()
                                self.navigationController?.popViewController(animated: true)
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
    

    
    //MARK: - All Button Action -
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnSaveChangesPressed(_ sender: Any) {
        
        if isCredentialValid(){
            changePassword()
        }
    }
    
    
    //MARK: - Memory Management -

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
