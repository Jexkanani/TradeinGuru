//
//  Preferance.swift
//  TradeInGurus
//
//  Created by Admin on 23/02/18.
//  Copyright © 2018 cearsinfotech. All rights reserved.
//

import UIKit

class PrefTableViewCell:UITableViewCell
{
    @IBOutlet weak var txtYear: UILabel!
    @IBOutlet weak var lblDealerNumber: UILabel!
    @IBOutlet weak var lblDealerMobile: UILabel!
    
}

class Preferance: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UITextViewDelegate {
    
    var strPreferance : String = ""
    var arrDealID = NSMutableArray()
    var arrayCommon = NSMutableArray()
    var arrayMake = NSMutableArray()
    var arrayModel =  NSMutableArray()
    var arrayYear =  NSMutableArray()
    var strMakeID = "1"
    var strModelID = "1"
    var strYearID = "1"
    var strYearToID = "1"
    var strCommon = "make"
    var bYearTo = false
    
    @IBOutlet var txtView: UITextView!
    @IBOutlet weak var tblViewPref: UITableView!
    @IBOutlet var spinner : UIActivityIndicatorView!
    
    @IBOutlet weak var viewOffer: UIView!
    @IBOutlet weak var tblViewOffer: UITableView!
    @IBOutlet weak var tblViewMakeModelYear: UITableView!
    @IBOutlet weak var lblViewMakeModelYear: UILabel!
    
    var dictDealer = [//"VIN":"",
        "year":"",
        "yearto":"",
        "make":"",
        "model":"",
        "mileage":"",
        //                      "name":"",
        //                      "phone":"",
        //                      "email":"",
        //                      "zipcode":"",
        "images":[UIImage(named:"placeholder"),UIImage(named:"placeholder"),UIImage(named:"placeholder")],
        "is_open":"0",
        ] as NSMutableDictionary
    
    //MARK: - Load -
    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtilities.sharedInstance.AppEvents(view: self)
        //        txtView.text = strPreferance
        tblViewOffer.tableHeaderView = nil
        if let object = UserDefaults.standard.value(forKey: "Pref") as? NSDictionary {
            dictDealer.setValue(object.value(forKey: "year")! as? String ?? "1", forKey: "year")
            strYearID = object.value(forKey: "year")! as? String ?? "1"
            dictDealer.setValue(object.value(forKey: "make")! as? String ?? "1", forKey: "make")
            strMakeID = object.value(forKey: "make")! as? String ?? "1"
            dictDealer.setValue(object.value(forKey: "model")! as? String ?? "1", forKey: "model")
            strModelID = object.value(forKey: "model")! as? String ?? "1"
            dictDealer.setValue(object.value(forKey: "yearto")! as? String ?? "1", forKey: "yearto")
            strYearToID = object.value(forKey: "yearto")! as? String ?? "1"
            debugPrint(dictDealer)
        }
        
        getYear()
        //        tblViewOffer.tableHeaderView = UIView(frame: rect)
        
    }
    
    //MARK: - Click Method -
    
    @IBAction func btnBack(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBackViewPressed(_ sender: Any) {
        if strCommon == "year" {
            removeSubviewFromWindow()
        } else if strCommon == "make" {
            arrayCommon = arrayYear
            strCommon = "year"
            lblViewMakeModelYear.text = "Year"
            tblViewMakeModelYear.reloadData()
        } else {
            arrayCommon = arrayMake
            strCommon = "make"
            lblViewMakeModelYear.text = "Make"
            tblViewMakeModelYear.reloadData()
        }
    }
    
    @IBAction func btnCarDetailsClk(_ sender: UIButton) {
        
        if sender.tag == 0 || sender.tag == 3 {
            strCommon = "year"
            arrayCommon = arrayYear
            tblViewMakeModelYear.reloadData()
            
            addSubviewToWidow()
            if sender.tag == 3 {
                bYearTo = true
            }
        }
        else if sender.tag == 1 {
            if strYearID == "1" {
                strCommon = "year"
                arrayCommon = arrayYear
                tblViewMakeModelYear.reloadData()
            } else if strMakeID != "1" {
                strCommon = "make"
                arrayCommon = arrayMake
                tblViewMakeModelYear.reloadData()
            } else {
                strCommon = "make"
                getMake()
            }
            addSubviewToWidow()
        }
        else {
            if strYearID != "1" && strMakeID != "" {
                getModel() // year, make, model
                strCommon = "model"
            } else if strYearID == "1" {
                strCommon = "year"
                arrayCommon = arrayYear
                tblViewMakeModelYear.reloadData()
            } else if strMakeID == "1" {
                strCommon = "make"
                getMake()
            }
            addSubviewToWidow()
        }
    }
    
    @IBAction func btnSubmitClk(_ sender: UIButton) {
        let ToYear : Int = Int(strYearToID)!
        let FromYear : Int = Int(strYearID)!
        
        if strYearID == "1" {
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Select the Year From" as NSString)
            return
        } else if String(strYearToID) == "1" {
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Select the Year To" as NSString)
            return
        } else if strMakeID == "1" {
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Select the Make" as NSString)
            return
        } else if strModelID == "1" {
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Select the Model" as NSString)
            return
        } else if (ToYear < FromYear) {
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "To year must be greter than From year" as NSString)
            return
        }
        AppUtilities.sharedInstance.showLoader()
        let dictionaryParams : NSDictionary = [
            "service": "SavePref",
            "request" : [
                "data": [
                    "year":strYearID,
                    "yearto":strYearToID,
                    "make":strMakeID,
                    "model":strModelID
                ]],
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                AppUtilities.sharedInstance.hideLoader()
                
                if let object = object as? NSDictionary
                {
                    if  (object.value(forKey: "success") as? Bool) != nil
                    {
                        
                        let responseDic = object
                        debugPrint(responseDic)
                        if let status = responseDic.value(forKey: "success") as? Int
                        {
                            UserDefaults.standard.set(responseDic.value(forKey: "data"), forKey: "Pref")
                            debugPrint(UserDefaults.standard.value(forKey: "Pref") ?? "")
                            self.tblViewOffer.reloadData()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table View Method -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //        return arrDealers.count
        if tableView == tblViewMakeModelYear {
            
        } else {
            
        }
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tblViewMakeModelYear{
            
            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            
            let dict = arrayCommon.object(at: indexPath.row) as! NSDictionary
            if strCommon == "make"
            {
                tableViewCell.textLabel?.text = dict.value(forKey: "make") as? String ?? "1"
            }
            else if strCommon == "model"
            {
                tableViewCell.textLabel?.text = dict.value(forKey: "model") as? String ?? "1"
                
            }
            else{
                tableViewCell.textLabel?.text = dict.value(forKey: "year") as? String ?? "1"
                
            }
            
            return tableViewCell
        }
        else {
            var tableViewCell = tableView.dequeueReusableCell(withIdentifier: "PrefTableViewCell")!
            
            if let tfmake = tableViewCell.viewWithTag(20) as? UITextField
            {
                tfmake.text = dictDealer["year"] as? String ?? ""
                setCorner(tfmake)
                tfmake.attributedPlaceholder = NSAttributedString(string: "Year From",
                                                                  attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
            }
            if let tfmodel = tableViewCell.viewWithTag(30) as? UITextField
            {
                tfmodel.text = dictDealer["yearto"] as? String ?? ""
                setCorner(tfmodel)
                tfmodel.attributedPlaceholder = NSAttributedString(string: "Year To",
                                                                   attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
            }
            if let tfmodel = tableViewCell.viewWithTag(25) as? UITextField
            {
                tfmodel.text = dictDealer["make"] as? String ?? ""
                setCorner(tfmodel)
                tfmodel.attributedPlaceholder = NSAttributedString(string: "Make",
                                                                   attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
            }
            if let tfyear = tableViewCell.viewWithTag(15) as? UITextField
            {
                tfyear.text = dictDealer["model"] as? String ?? ""
                setCorner(tfyear)
                tfyear.attributedPlaceholder = NSAttributedString(string: "Model",
                                                                  attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
            }
            
            
            return tableViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if tableView == tblViewMakeModelYear{
            return arrayCommon.count
        }
        else{
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblViewMakeModelYear {
            return 40
        }
        else {
            return 254
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        viewFooter.backgroundColor = UIColor.clear
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblViewMakeModelYear{
            let dict = arrayCommon.object(at: indexPath.row) as! NSDictionary
            if strCommon == "year" {
                if (bYearTo) {
                    bYearTo = false
                    strYearToID =  dict.value(forKey: "year") as? String ?? "1"
                    dictDealer.setValue(dict.value(forKey: "year") as? String ?? "1", forKey: "yearto")
                    
                    self.removeSubviewFromWindow()
                } else {
                    strCommon = "make"
                    strYearID =  dict.value(forKey: "year") as? String ?? "1"
                    
                    dictDealer.setValue(dict.value(forKey: "year") as? String ?? "1", forKey: "year")
                    getMake()
                }
            } else if strCommon == "model" {
                dictDealer.setValue(dict.value(forKey: "model") as? String ?? "1", forKey: "model")
                strModelID = dict.value(forKey: "model") as? String ?? "1"
                removeSubviewFromWindow()
            } else {
                strCommon = "model"
                dictDealer.setValue(dict.value(forKey: "make") as? String ?? "1", forKey: "make")
                strMakeID = dict.value(forKey: "make") as? String ?? "1"
                getModel()
            }
            debugPrint(dictDealer)
            self.tblViewOffer.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection: Int) -> CGFloat
    {
        if tableView == tblViewMakeModelYear{
            return 0
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == tblViewMakeModelYear{
            return 0
        }
        else{
            return 10
        }
    }
    
    func setCorner(_ viewC : UITextField)
    {
        viewC.layer.cornerRadius = 5.0
        viewC.layer.borderWidth = 1.0
        viewC.layer.borderColor = UIColor.white.cgColor
        viewC.clipsToBounds = true
        viewC.setLeftPaddingPoints(10)
    }
    
    func addSubviewToWidow()
    {
        self.view.endEditing(true)
        
        lblViewMakeModelYear.text = self.strCommon
        
        let window = UIApplication.shared.keyWindow!
        viewOffer.frame =  CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
        window.addSubview(viewOffer)
    }
    
    func removeSubviewFromWindow(){
        viewOffer.removeFromSuperview()
    }
    
    //MARK: - API Method -
    func getMake()
    {
        lblViewMakeModelYear.text = "Make"
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            //            "service": "Getmakes",
            "service": "Getmakes",
            //            "request" : [:] as Dictionary ,
            "request" : [
                "year":strYearID
            ],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
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
                                
                                if let arr = responseDic.value(forKey: "data") as? NSArray
                                {
                                    self.arrayMake = NSMutableArray(array: arr)
                                    self.arrayCommon = self.arrayMake
                                    self.lblViewMakeModelYear.text = "make"
                                    
                                    self.tblViewMakeModelYear.reloadData()
                                }
                            }
                            else{
                                //                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                //                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                //                                }
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
    
    func getYear()
    {
        lblViewMakeModelYear.text = "Year"
        
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            //            "service": "Getmodelyears",
            "service": "Getyears",
            //            "request" : [
            ////                "model":strModelID
            //
            //            ],
            "request" : [:] as Dictionary ,
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
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
                                
                                if let arr = responseDic.value(forKey: "data") as? NSArray
                                {
                                    self.arrayYear = NSMutableArray(array: arr)
                                    self.strCommon = "year"
                                    self.arrayCommon = self.arrayYear
                                    self.tblViewMakeModelYear.reloadData()
                                }
                            }
                            else{
                                //                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                //                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                //                                }
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
    
    
    func getModel()
    {
        lblViewMakeModelYear.text = "Model"
        
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "Getmodel",
            "request" : [
                "make":strMakeID,
            ],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
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
                                
                                if let arr = responseDic.value(forKey: "data") as? NSArray
                                {
                                    self.arrayModel = NSMutableArray(array: arr)
                                    self.strCommon = "model"
                                    self.arrayCommon = self.arrayModel
                                    self.tblViewMakeModelYear.reloadData()
                                }
                            }
                            else{
                                //                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                //                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                //                                }
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
    
    //MARK: - UITextField delegate -
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        dictDealer.setValue("0", forKey: "is_pop_open")
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        if textField.tag == 15{
            dictDealer.setValue(newText, forKey: "model")
        }
        else if textField.tag == 20{
            dictDealer.setValue(newText, forKey: "year")
        }
        else if textField.tag == 25{
            dictDealer.setValue(newText, forKey: "make")
        } else if textField.tag == 30 {
            dictDealer.setValue(newText, forKey: "yearto")
        }
        
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return false
    }
    
    //MARK: - TextView Delegate Methd -
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = NSString(string: textView.text!).replacingCharacters(in: range, with: text)
        
        //        if textView.tag == 501 {
        //            dictDealer.setValue(newText, forKey: "description")
        //        }
        
        return true
    }
}

