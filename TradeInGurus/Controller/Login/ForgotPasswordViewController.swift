//
//  ForgotPasswordViewController.swift
//  TradeInGurus
//
//  Created by Admin on 07/11/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    
    //MARK:- Outlet, variable, Constant -

    @IBOutlet var txtEmail : ACFloatingTextfield!

    //MARK:- UIView Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK:- UIButton Action -
    @IBAction func btnForgotPassPressed(_ sender: Any) {
        if isCredentialValid(){
            forgotPassword()
        }
    }
    
    
    @IBAction func btnBackClk(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: -  Validation -
    func isCredentialValid() -> Bool {
        let is_valid  = true
        
       if (txtEmail.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter email")
            return false
        }
        else if !AppUtilities.sharedInstance.isValidEmail(testStr: txtEmail.text!){
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter valid email")
            return false
        }
       return is_valid
    }
    
    
    //MARK:- API Methods -
    func forgotPassword()
    {
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        let dictionaryParams : NSDictionary = [
            "service": "forgotpassword",
            
            "request" : [
                "value": txtEmail.text!.trim()
            ]
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
                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                }

                              //  AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Reset password link sent to your mail id. Set ne password from there." as NSString)
                                
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

    
    //MARK: - Memory management
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
