//
//  FbDataPopUp.swift
//  TradeInGurus
//
//  Created by Admin on 18/09/18.
//  Copyright © 2018 cearsinfotech. All rights reserved.
//

import UIKit
protocol registerProtocolDelegate {
    func clkDone(Email : String, Zipcode : String)
    func clkClose()
}

class FbDataPopUp: UIViewController {
    var delegate : registerProtocolDelegate?
    @IBOutlet var btnCustomer : UIButton!
    @IBOutlet var txtEmail : ACFloatingTextfield!
    @IBOutlet var txtZipcode : ACFloatingTextfield!
    var email : String = ""
    var dic = NSMutableDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint(email)
        debugPrint("hsdfdsf dsf sdf")
        if (email != "") {
            txtEmail.text = email
            txtEmail.isEnabled = false
        }
        if (dic["email"] != nil) {
            txtEmail.text = dic["email"] as? String
            txtEmail.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (dic["email"] != nil) {
            txtEmail.text = dic["email"] as? String
            txtEmail.isEnabled = false
        }
    }
    // MARK: - ClkMethods
    @IBAction func clkDone(sender : UIButton) {
        var isValid = true
        if (txtEmail.text?.isEmptyOrWhitespace())!{
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter email")
            isValid = false
        }
        else if !AppUtilities.sharedInstance.isValidEmail(testStr: txtEmail.text!){
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter valid email")
            isValid = false
        }
        else if (txtZipcode.text?.isEmptyOrWhitespace())!{
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter zipcode")
            isValid = false
        }
        if (isValid) {
            self.delegate?.clkDone(Email: (txtEmail.text?.trim())!, Zipcode: (txtZipcode.text?.trim())!)
        }
    }
    
    @IBAction func clkclose(sender : UIButton) {
        self.delegate?.clkClose()
    }
}
