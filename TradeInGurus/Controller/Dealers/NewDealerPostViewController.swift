
//
//  NewDealerPostViewController.swift
//  TradeInGurus
//
//  Created by Admin on 13/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import RSBarcodes

class NewDealerPostViewController:  UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,BarcodeDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var tblViewOffer: UITableView!
    @IBOutlet weak var viewOffer: UIView!
    @IBOutlet weak var tblViewMakeModelYear: UITableView!
    @IBOutlet weak var lblViewMakeModelYear: UILabel!
    var dictDealer = NSMutableDictionary()
    var strImages = ""
    var ImageParam : NSMutableArray = NSMutableArray()
    var arrNewImg : NSMutableArray = NSMutableArray()
    var arrDeletedImg : NSMutableArray = NSMutableArray()
    var arrDeletedImage : NSMutableArray = NSMutableArray()
    
    var arrayCommon = NSMutableArray()
    var arrayMake = NSMutableArray()
    var arrayModel =  NSMutableArray()
    var arrayYear =  NSMutableArray()
    var strMakeID = "1"
    var strModelID = "1"
    var strYearID = "1"
    var strCommon = "make"
    var index = 1
    var isScanOn = false
    var dictEdit = NSDictionary()
    var isEditDealer : String = "0"
    var strLat = "0"
    var strLng = "0"
    var strZipCode = ""
    var strAddress = ""
    var strCity = ""
    let locationManager = CLLocationManager()
    
    //MARK:- UIView Life Cycle -
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if isEditDealer == "0"
        {
            dictDealer = ["VIN":"",
                          "year":"",
                          "make":"",
                          "model":"",
                          "mileage":"",
//                          "name":"",
                          "price":"",
                          "images":[UIImage(named:"placeholder"),UIImage(named:"placeholder"),UIImage(named:"placeholder")]
            ]
        }
        else
        {
            let arrImages : NSMutableArray = ["","",""]
            let arrTemp  = dictEdit["vimages"] as! NSArray
            for i in 0..<arrTemp.count
            {
                let strImageURL : String = (arrTemp.object(at: i) as? String)!
                arrImages.replaceObject(at: i, with: strImageURL)
            }
            
            dictDealer = ["VIN":(dictEdit.object(forKey: "v_number") as? String)!,
                          "year":(dictEdit.object(forKey: "v_year") as? String)!,
                          "make":(dictEdit.object(forKey: "v_make") as? String)!,
                          "model":(dictEdit.object(forKey: "v_model") as? String)!,
                          "mileage":(dictEdit.object(forKey: "mileage") as? String)!,
                          "name":(dictEdit.object(forKey: "v_name") as? String)!,
                          "price":(dictEdit.object(forKey: "v_price") as? String)!,
                          "images":arrImages
            ]
        }
        AppUtilities.sharedInstance.AppEvents(view: self)
//        getMake()
        getYear()
        tblViewMakeModelYear.tableFooterView = UIView(frame: CGRect.zero)
        tblViewOffer.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(test), name:NSNotification.Name(rawValue: "TestNotification"), object: nil)
    }
    
    func test() {
        
        Constant.sharedInstance.is_Done = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        locationManager.stopUpdatingLocation()
    }
    
    func btnGetCode(_ strCode: String) {
        AppUtilities.sharedInstance.showLoader()
        var newVIN = strCode
        dictDealer.setValue(strCode, forKey: "VIN")
        
        if strCode.characters.count > 17{
            debugPrint(strCode.characters.dropFirst())
            newVIN = String(strCode.characters.dropFirst())
        }
        //let strURL = "https://api.edmunds.com/v1/api/toolsrepository/vindecoder?vin=\(newVIN)&fmt=json&api_key=edb2rmzgmrff3fa3ycp7puhu"
        let strURL = "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValuesExtended/\(newVIN)?format=json"
        debugPrint(dictDealer)
        tblViewOffer.reloadData()
        //let strEncodeUrl = strURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let request = NSMutableURLRequest(url: NSURL(string: strURL)! as URL)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            DispatchQueue.main.async( execute: {
                AppUtilities.sharedInstance.hideLoader()
                
                let jsonWithObjectRoot = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let dictionary = jsonWithObjectRoot as? [String: Any] {
                    debugPrint(dictionary)
                    
                        if let attributeGroups = dictionary["Results"] as? NSArray {
                        if let dict = attributeGroups.object(at: 0)  as? NSDictionary {
                            self.isScanOn = true
                            if let year = dict.value(forKey: "ModelYear")  as? String {
                                self.dictDealer.setValue("\(year)", forKey: "year")
                                
                            }
                            if let makeName = dict.value(forKey: "Make")  as? String {
                                self.dictDealer.setValue(makeName, forKey: "make")
                                
                            }
                            if let modelName = dict.value(forKey: "Model")  as? String {
                                self.dictDealer.setValue(modelName, forKey: "model")
                                
                            }
                            if let attributeGroups = dict.value(forKey: "attributeGroups")  as? NSDictionary {
                                if let MAIN = attributeGroups.value(forKey: "MAIN")  as? NSDictionary {
                                    if let attributes = MAIN.value(forKey: "attributes")  as? NSDictionary {
                                        if let NAME = attributes.value(forKey: "NAME")  as? NSDictionary {
                                            if let name = NAME.value(forKey: "value")  as? String {
                                                self.dictDealer.setValue("\(name)", forKey: "name")
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                }
                            }
                            
                            self.tblViewOffer.reloadData()
                            
                        }
                    }
                    else {
                        let msg = dictionary["message"] as? String
                        
                        AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: msg! as NSString)
                        
                    }
                    
                }
            })
            // onCompletion(jsonWithObjectRoot, error)
        })
        task.resume()
    }
    
    
    //MARK: - UIButton Action Methods -
    @IBAction func btnBarcodeScannerPressed(_ sender: Any) {
        self.view.endEditing(true)
        var isAlredyFind = false
        let vc : RSScannerViewController =  RSScannerViewController(cornerView: true, controlView: true, barcodesHandler: { (barcodeObjects) in
            
            if isAlredyFind{
                return
            }
            if (barcodeObjects?.count)! > 0 {
                isAlredyFind = true
                
                let strCode = barcodeObjects?[0] as! AVMetadataMachineReadableCodeObject
                var code = strCode.stringValue
                if code?.characters.first == "I" {
                    code?.remove(at: (code?.startIndex)!)
                }
                self.btnGetCode(code!)
            }
            self.dismiss(animated: true, completion: nil)
        }, preferredCameraPosition: .back)
        self.present(vc, animated: true) {
            
        }
        
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func btnBackViewPressed(_ sender: Any) {
        
        /*if strCommon == "make"
        {
            removeSubviewFromWindow()
        }
        else if strCommon == "model"
        {
            arrayCommon = arrayMake
            strCommon = "make"
            lblViewMakeModelYear.text = "Make"
            tblViewMakeModelYear.reloadData()
        }
        else{
            arrayCommon = arrayModel
            strCommon = "model"
            lblViewMakeModelYear.text = "Model"
            tblViewMakeModelYear.reloadData()
        }*/
        
        if strCommon == "year"
        {
            removeSubviewFromWindow()
        }
        else if strCommon == "make"
        {
            arrayCommon = arrayYear
            strCommon = "year"
            lblViewMakeModelYear.text = "Year"
            tblViewMakeModelYear.reloadData()
        }
        else {
            arrayCommon = arrayMake
            strCommon = "make"
            lblViewMakeModelYear.text = "Make"
            tblViewMakeModelYear.reloadData()
        }
    }
    
    @IBAction func btnDeleteImagePressed(_ sender: UIButton) {
        
        if isEditDealer == "1"
        {
            let arrImages = (dictDealer["images"] as! NSArray).mutableCopy() as! NSMutableArray
            var linkImage : String? = nil
            
            if sender.tag == 11
            {
                linkImage = arrImages[0] as? String
                arrImages.removeObject(at: 0)
            }
            else if sender.tag == 21
            {
                linkImage = arrImages[1] as? String
                arrImages.removeObject(at: 1)
            }
            else if sender.tag == 31
            {
                linkImage = arrImages[2] as? String
                arrImages.removeObject(at: 2)
            }
            
            if linkImage != nil && (linkImage?.characters.count)! > 0
            {
                arrDeletedImg.add(linkImage!)
            }
            
            debugPrint(arrDeletedImg)
            
            arrImages.insert("", at: arrImages.count)
            debugPrint(arrImages)
            dictDealer.setValue(arrImages.copy(), forKey: "images")
        }
        else
        {
            var arrImages = dictDealer["images"] as? [UIImage]
            
            dictDealer.setValue(arrImages, forKey: "images")
            
            if sender.tag == 11{
                arrImages?.remove(at: 0)
                
            }
            else if sender.tag == 21{
                arrImages?.remove(at: 1)
                
            }
            else if sender.tag == 31{
                arrImages?.remove(at: 2)
                
            }
            
            arrImages?.insert(UIImage(named:"placeholder")!, at: index)
            var arrI = [UIImage]()
            
            for i in 0..<arrImages!.count
            {
                let imageTemp = arrImages?[i]
                if imageTemp != UIImage(named:"placeholder"){
                    arrI.append(imageTemp!)
                }
            }
            for i in 0..<arrImages!.count
            {
                if i < arrI.count
                {
                    arrImages?.remove(at: i)
                    arrImages?.insert(arrI[i], at: i)
                }
                else
                {
                    arrImages?.remove(at: i)
                    arrImages?.insert(UIImage(named:"placeholder")!, at: i)
                }
            }
            dictDealer.setValue(arrImages, forKey: "images")
        }
        tblViewOffer.reloadData()
    }
    
    @IBAction func btnUploadPressed(_ sender: Any)
    {
        if isEditDealer == "1"
        {
            let arrImages = dictDealer["images"] as! NSArray
            
            var k : Int = 0
            for i in 0..<arrImages.count
            {
                let linkImage = arrImages[i] as? String
                if linkImage == nil || (linkImage?.characters.count)! > 0
                {
                    k += 1
                }
            }
            
            if k >= 3
            {
                AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg:"Sorry! You can add maximum 3 profile images.")
            }
            else
            {
                for i in 0..<arrImages.count
                {
                    let linkImage = arrImages[i] as? String
                    if linkImage != nil && (linkImage?.characters.count)! <= 0
                    {
                        index = i
                        break
                    }
                }
                
                openImagePicker()
            }
        }
        else
        {
            let arrImages  = dictDealer["images"] as? [UIImage]
            if arrImages != nil
            {
                for i in 0..<arrImages!.count
                {
                    let imageTemp = arrImages?[i]
                    if imageTemp == UIImage(named:"placeholder")
                    {
                        index = i
                        break
                    }
                }
            }
            
            if arrImages?.count == 3
            {
                openImagePicker()
            }
            else
            {
                AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg:"Sorry! You can add maximum 3 profile images.")
            }
        }
    }
    
    @IBAction func btnCarDetailsClk(_ sender: UIButton) {
        
        /*if sender.tag == 0
        {
            strCommon = "make"
            arrayCommon = arrayMake
            tblViewMakeModelYear.reloadData()
            addSubviewToWidow()
        }
        else if sender.tag == 1
        {
            if strMakeID == "1" {
                strCommon = "make"
                arrayCommon = arrayMake
                tblViewMakeModelYear.reloadData()
            }
            else if strModelID != "1" {
                strCommon = "model"
                arrayCommon = arrayModel
                tblViewMakeModelYear.reloadData()
            }
            else{
                strCommon = "model"
                getModel()
            }
            addSubviewToWidow()
        }
        else
        {
            if strMakeID != "1" && strModelID != "" {
                getYear()
                strCommon = "year"
            }
            else if strMakeID == "1" {
                strCommon = "make"
                arrayCommon = arrayMake
                tblViewMakeModelYear.reloadData()
            }
            else if strModelID == "1" {
                strCommon = "model"
                getModel()
            }
            addSubviewToWidow()
        }*/
        
        if sender.tag == 0
        {
            strCommon = "year"
            arrayCommon = arrayYear
            tblViewMakeModelYear.reloadData()
            addSubviewToWidow()
        }
        else if sender.tag == 1
        {
            if strYearID == "1" {
                strCommon = "year"
                arrayCommon = arrayYear
                tblViewMakeModelYear.reloadData()
            }
            else if strMakeID != "1" {
                strCommon = "make"
                arrayCommon = arrayMake
                tblViewMakeModelYear.reloadData()
            }
            else{
                strCommon = "make"
                getMake()
            }
            addSubviewToWidow()
        }
        else
        {
            if strYearID != "1" && strMakeID != "" {
                getModel()
                strCommon = "model"
            }
            else if strYearID == "1" {
                strCommon = "year"
                arrayCommon = arrayYear
                tblViewMakeModelYear.reloadData()
            }
            else if strMakeID == "1" {
                strCommon = "make"
                getMake()
            }
            addSubviewToWidow()
        }
    }
    
    
    func openImagePicker()
    {
        let Action = UIAlertController(title: "Add Pic", message: "Choose from Gallery ", preferredStyle: UIAlertControllerStyle.actionSheet)
        Action.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        Action.addAction(UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.default, handler: ({
            action in
            let imgpicker = UIImagePickerController()
            imgpicker.sourceType = UIImagePickerControllerSourceType.camera
            imgpicker.cameraDevice = UIImagePickerControllerCameraDevice.rear
            imgpicker.delegate = self
            imgpicker.allowsEditing = true
            self.present(imgpicker, animated: true, completion: nil)
        })))
        
        Action.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default, handler: ({
            action in
            
            
            let imgpicker = UIImagePickerController()
            imgpicker.allowsEditing = true
            imgpicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imgpicker.delegate = self
            self.present(imgpicker, animated: true, completion: nil)
            
        })))
        
        self.present(Action, animated: true, completion: nil)
    }
    
    
    
    //MARK: - Other
    func  isValidall()->Bool{
        for (key,value) in dictDealer
        {
            debugPrint(key)
            if let valuedd = value as? String{
                if valuedd == "" {
                    if key as! String != "VIN" && key as! String != "name" {
                        AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please insert \(key) value." as NSString)
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    func setCorner(_ viewC : UITextField)
    {
        viewC.layer.cornerRadius = 5.0
        viewC.layer.borderWidth = 1.0
        viewC.layer.borderColor = UIColor.white.cgColor
        viewC.clipsToBounds = true
        viewC.setLeftPaddingPoints(10)
    }
    
    func setCornerL(_ viewC : UILabel)
    {
        viewC.layer.cornerRadius = 5.0
        viewC.layer.borderWidth = 1.0
        viewC.layer.borderColor = UIColor.white.cgColor
        viewC.clipsToBounds = true
    }
    
    func setCornerView(_ viewC : UIView)
    {
        viewC.layer.cornerRadius = 5.0
        viewC.clipsToBounds = true
    }
    func getMake()
    {
        lblViewMakeModelYear.text = "Make"
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
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
//                                    self.lblViewMakeModelYear.text = "make"
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
//                "model":strModelID
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
    
    
    
    
    //MARK: - UITableView Delegate and Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
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
        else
        {
            if indexPath.section == 0
            {
                let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellVehicle")!
                
                if let tfVIN = tableViewCell.viewWithTag(10) as? UITextField
                {
                    tfVIN.text = dictDealer["VIN"] as? String ?? ""
                    setCorner(tfVIN)
                    tfVIN.attributedPlaceholder = NSAttributedString(string: "VIN Number",
                                                                     attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                }
                
                if let tfyear = tableViewCell.viewWithTag(15) as? UITextField
                {
                    tfyear.text = dictDealer["model"] as? String ?? ""
                    setCorner(tfyear)
                    tfyear.attributedPlaceholder = NSAttributedString(string: "Model",
                                                                      attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                }
                if let tfmake = tableViewCell.viewWithTag(20) as? UITextField
                {
                    tfmake.text = dictDealer["year"] as? String ?? ""
                    setCorner(tfmake)
                    tfmake.attributedPlaceholder = NSAttributedString(string: "Year",
                                                                      attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                }
                if let tfmodel = tableViewCell.viewWithTag(25) as? UITextField
                {
                    tfmodel.text = dictDealer["make"] as? String ?? ""
                    setCorner(tfmodel)
                    tfmodel.attributedPlaceholder = NSAttributedString(string: "Make",
                                                                       attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                }
                if let tfmileage = tableViewCell.viewWithTag(30) as? UITextField
                {
                    tfmileage.text = dictDealer["mileage"] as? String ?? ""
                    setCorner(tfmileage)
                    tfmileage.attributedPlaceholder = NSAttributedString(string: "Mileage",
                                                                         attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                }
                if let tfname = tableViewCell.viewWithTag(35) as? UITextField
                {
                    tfname.text = dictDealer["name"] as? String ?? ""
                    setCorner(tfname)
                    tfname.attributedPlaceholder = NSAttributedString(string: "Vehicle Name",
                                                                      attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                }
                if let tfprice = tableViewCell.viewWithTag(40) as? UITextField
                {
                    tfprice.text = dictDealer["price"] as? String ?? ""
                    setCorner(tfprice)
                    tfprice.attributedPlaceholder = NSAttributedString(string: "Price",
                                                                       attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                }
                
                if let btnUpload = tableViewCell.viewWithTag(70) as? UIButton
                {
                    //tfzipcode.text = dictDealer["zipcode"] as? String ?? ""
                    btnUpload.layer.cornerRadius = 15
                    btnUpload.clipsToBounds = true
                }
                
                let arrImages = dictDealer["images"] as! NSArray
                
                if let image1 = tableViewCell.viewWithTag(55) as? UIImageView
                {
                    if isEditDealer == "1"
                    {
                        let linkImage = arrImages[0] as? String
                        if linkImage == nil
                        {
                            image1.image = arrImages[0] as? UIImage
                        }
                        else
                        {
                            image1.sd_setImage(with: URL(string: linkImage!), placeholderImage: UIImage(named: "placeholder"))
                        }
                        
                        
                        if let btn1 = tableViewCell.viewWithTag(11) as? UIButton
                        {
                            if linkImage == nil
                            {
                                btn1.isHidden = false
                            }
                            else
                            {
                                if (linkImage?.characters.count)! > 0
                                {
                                    btn1.isHidden = false
                                }
                                else
                                {
                                    btn1.isHidden = true
                                }
                            }
                            
                        }
                    }
                    else
                    {
                        image1.image = arrImages[0] as? UIImage
                        
                        if let btn1 = tableViewCell.viewWithTag(11) as? UIButton
                        {
                            if image1.image == UIImage(named:"placeholder")
                            {
                                btn1.isHidden = true
                            }
                            else
                            {
                                btn1.isHidden = false
                                
                            }
                        }
                    }
                }
                if let image2 = tableViewCell.viewWithTag(60) as? UIImageView
                {
                    if isEditDealer == "1"
                    {
                        let linkImage = arrImages[1] as? String
                        if linkImage == nil
                        {
                            image2.image = arrImages[1] as? UIImage
                        }
                        else
                        {
                            image2.sd_setImage(with: URL(string: linkImage!), placeholderImage: UIImage(named: "placeholder"))
                        }
                        
                        if let btn1 = tableViewCell.viewWithTag(21) as? UIButton
                        {
                            if linkImage == nil
                            {
                                btn1.isHidden = false
                            }
                            else
                            {
                                if (linkImage?.characters.count)! > 0
                                {
                                    btn1.isHidden = false
                                }
                                else
                                {
                                    btn1.isHidden = true
                                }
                            }
                        }
                    }
                    else
                    {
                        image2.image = arrImages[1] as? UIImage
                        
                        if let btn1 = tableViewCell.viewWithTag(21) as? UIButton
                        {
                            if image2.image == UIImage(named:"placeholder"){
                                btn1.isHidden = true
                            }
                            else{
                                btn1.isHidden = false
                                
                            }
                        }
                    }
                }
                if let image3 = tableViewCell.viewWithTag(65) as? UIImageView
                {
                    if isEditDealer == "1"
                    {
                        let linkImage = arrImages[2] as? String
                        if linkImage == nil
                        {
                            image3.image = arrImages[2] as? UIImage
                        }
                        else
                        {
                            image3.sd_setImage(with: URL(string: linkImage!), placeholderImage: UIImage(named: "placeholder"))
                        }
                        
                        if let btn1 = tableViewCell.viewWithTag(31) as? UIButton
                        {
                            if linkImage == nil
                            {
                                btn1.isHidden = false
                            }
                            else
                            {
                                if (linkImage?.characters.count)! > 0
                                {
                                    btn1.isHidden = false
                                }
                                else
                                {
                                    btn1.isHidden = true
                                }
                            }
                        }
                    }
                    else
                    {
                        image3.image = arrImages[2] as? UIImage
                        
                        if let btn1 = tableViewCell.viewWithTag(31) as? UIButton
                        {
                            if image3.image == UIImage(named:"placeholder"){
                                btn1.isHidden = true
                            }
                            else{
                                btn1.isHidden = false
                                
                            }
                        }
                    }
                }
                
                return tableViewCell
            }
            else if indexPath.section == 1
            {
                let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellCustomerDetail")!
                if let lblVIN = tableViewCell.viewWithTag(10) as? UILabel
                {
                    lblVIN.text = "   " + AppUtilities.sharedInstance.getLoginUserName()
                    setCornerL(lblVIN)
                }
                if let lblmobile = tableViewCell.viewWithTag(20) as? UILabel
                {
                    lblmobile.text = "   " + AppUtilities.sharedInstance.getLoginUserMobile()
                    setCornerL(lblmobile)
                }
                if let lblEmail = tableViewCell.viewWithTag(30) as? UILabel
                {
                    lblEmail.text = "   " + AppUtilities.sharedInstance.getLoginUserEmail()
                    setCornerL(lblEmail)
                }
                
                return tableViewCell
            }
            else
            {
                let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellAreaDetail")!
                if let lblVIN = tableViewCell.viewWithTag(10) as? UILabel
                {
                    lblVIN.text = "\(indexPath.row+1) Dealer"
                }
                
                return tableViewCell
            }
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection: Int) -> CGFloat
    {
        
        if tableView == tblViewMakeModelYear{
            return 0
            
        }
        else{
            return 50
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 50))
        let btnHeader = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 80, y: 0, width:50, height: 50))
        btnHeader.setImage(UIImage(named:"detail_arro"), for: .normal)
        
        let lblHeader =  UILabel(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 30, height: 50))
        lblHeader.font = UIFont(name: "Ubuntu", size: 17.0)
        lblHeader.textColor = UIColor.orange
        if section == 0{
            lblHeader.text = "Vehicle Details"
            
        }
        else if section == 0{
            lblHeader.text = "Customer Details"
            
        }
        else{
            lblHeader.text = "Area Details"
            
        }
        viewHeader.addSubview(btnHeader)
        viewHeader.addSubview(lblHeader)
        viewHeader.backgroundColor = UIColor.white
        setCornerView(viewHeader)
        return viewHeader
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 2{
            
            let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
            viewFooter.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            let btnHeader = UIButton(frame: CGRect(x: 5, y: 8, width:UIScreen.main.bounds.width - 40, height: 45))
            btnHeader.titleLabel?.font = UIFont(name: "Ubuntu-Medium", size: 18.0)
            btnHeader.setTitle("Submit", for: .normal)
            btnHeader.backgroundColor = UIColor.orange
            btnHeader.addTarget(self, action: #selector(self.clkSubmit(sender:)), for: .touchUpInside)
            setCornerView(btnHeader)
            btnHeader.setTitleColor(UIColor.white, for: .normal)
            viewFooter.addSubview(btnHeader)
            return viewFooter
            
        }
        
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        viewFooter.backgroundColor = UIColor.clear
        return viewFooter
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        
        /*if tableView == tblViewMakeModelYear{
            
            let dict = arrayCommon.object(at: indexPath.row) as! NSDictionary
            if strCommon == "make"{
                strCommon = "model"
                strMakeID =  dict.value(forKey: "make") as? String ?? "1"
                dictDealer.setValue(dict.value(forKey: "make") as? String ?? "1", forKey: "make")
                
                getModel()
                
            }
            else if strCommon == "year"{
                
                dictDealer.setValue(dict.value(forKey: "year") as? String ?? "1", forKey: "year")
                removeSubviewFromWindow()
                
            }
            else{
                strCommon = "year"
                
                dictDealer.setValue(dict.value(forKey: "model") as? String ?? "1", forKey: "model")
                strModelID = dict.value(forKey: "model") as? String ?? "1"
                
                getYear()
                
            }
            tblViewOffer.reloadData()
        }*/
        //make model year
        // year make model
        if tableView == tblViewMakeModelYear{
            
            let dict = arrayCommon.object(at: indexPath.row) as! NSDictionary
            if strCommon == "year"{
                strCommon = "make"
                strYearID =  dict.value(forKey: "year") as? String ?? "1"
                dictDealer.setValue(dict.value(forKey: "year") as? String ?? "1", forKey: "year")
                
                getMake()
                
            }
            else if strCommon == "model"{
                
                dictDealer.setValue(dict.value(forKey: "model") as? String ?? "1", forKey: "model")
                removeSubviewFromWindow()
                
            }
            else{
                strCommon = "model"
                
                dictDealer.setValue(dict.value(forKey: "make") as? String ?? "1", forKey: "make")
                strMakeID = dict.value(forKey: "make") as? String ?? "1"
                
                getModel()
                
            }
            tblViewOffer.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if tableView == tblViewMakeModelYear{
            return 40
        }
        else{
            
            if indexPath.section == 0{
                return 555
            }
            else if indexPath.section == 1{
                return 140
            }
            else{
                return 50
            }
        }
    }
    
    //MARK: - Add subview to Window -
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
    
    
    //MARK: - UITextField Delegate Methods -
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 15 || textField.tag == 20 || textField.tag == 25{
            //            if isScanOn{
            //                return false
            //            }
            self.view.endEditing(true)
            if textField.tag == 15
            {
                
            }
            else if textField.tag == 20
            {
                
                
            }
            else{
                
            }
            //addSubviewToWidow()
            return false
        }
        else{
            return true
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        if textField.tag == 10{
            debugPrint(dictDealer)
            dictDealer.setValue(newText, forKey: "VIN")
            
        }
        else if textField.tag == 15{
            dictDealer.setValue(newText, forKey: "year")
        }
        else if textField.tag == 20{
            dictDealer.setValue(newText, forKey: "make")
        }
        else if textField.tag == 25{
            dictDealer.setValue(newText, forKey: "model")
        }
        else if textField.tag == 30{
            dictDealer.setValue(newText, forKey: "mileage")
        }
        else if textField.tag == 35{
            dictDealer.setValue(newText, forKey: "name")
        }
        else if textField.tag == 40{
            dictDealer.setValue(newText, forKey: "price")
        }
        else if textField.tag == 45{
            dictDealer.setValue(newText, forKey: "email")
        }
        else if textField.tag == 50{
            dictDealer.setValue(newText, forKey: "zipcode")
        }
        
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 10{
            debugPrint(dictDealer)
            if (textField.text?.characters.count)! > 16 {
                self.btnGetCode(textField.text!)
            }
            else {
                
                if Constant.sharedInstance.is_Done == true {
                    Constant.sharedInstance.is_Done = false
                    let alertAction = UIAlertController(title: APP_Title, message: "Please enter 17 digit VIN Number", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertAction.addAction(ok)
                    self.present(alertAction, animated: true, completion: nil)
                    
                }
                else {
                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter 17 digit VIN Number")
                }
                
                
            }
            
        }
        
    }
    
    
    
    func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
    
    
    //MARK:- UIImagePickerController Delegate -
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var img1 = UIImage()
        img1 = info[UIImagePickerControllerEditedImage] as! UIImage
        
        if isEditDealer == "1"
        {
            let arrImages = (dictDealer["images"] as! NSArray).mutableCopy() as! NSMutableArray
            debugPrint(arrImages)
            arrImages.replaceObject(at: index, with: img1)
            debugPrint(arrImages)
            dictDealer.setValue(arrImages.copy(), forKey: "images")
        }
        else
        {
            var arrImages = dictDealer["images"] as? [UIImage]
            if arrImages == nil
            {
                arrImages?.append(img1)
            }
            else
            {
                arrImages?.remove(at: index)
                arrImages?.insert(img1, at: index)
            }
            dictDealer.setValue(arrImages, forKey: "images")
        }
        
        
        tblViewOffer.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func clkSubmit(sender : UIButton){
        
        if isValidall(){
            self.view.endEditing(true)
            self.uploadImages()
        }
    }
    
    
    func uploadImages()
    {
        if isEditDealer == "1"
        {
            let arrImages = dictDealer["images"] as! NSArray
            var k : Int = 0
            for i in 0..<arrImages.count
            {
                let linkImage = arrImages[i] as? String
                if linkImage == nil || (linkImage?.characters.count)! > 0
                {
                    k += 1
                    break
                }
            }
            if k == 0
            {
                AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please upload one image" as NSString)
                return
            }
        }
        else
        {
            var idx = -1
            let arrImages  = dictDealer["images"] as? [UIImage]
            if arrImages != nil
            {
                for i in 0..<arrImages!.count
                {
                    let imageTemp = arrImages?[i]
                    if imageTemp == UIImage(named:"placeholder"){
                        idx = i
                        break
                    }
                }
            }
            /*if idx == 0 {
                AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please upload one image" as NSString)
                return
            }*/
        }
        
        AppUtilities.sharedInstance.showLoader()
        let urlString = "http://app.tradeingurus.com/upload/uploadVehicalImage"
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            if self.isEditDealer == "1"
            {
                let arrImages = self.dictDealer["images"] as! NSArray
                for i in 0..<arrImages.count
                {
                    let linkImage = arrImages[i] as? String
                    if linkImage == nil
                    {
                        let imageTemp = arrImages[i]
                        let imageData = UIImagePNGRepresentation(imageTemp as! UIImage)
                        multipartFormData.append(imageData!, withName: "images[]", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                    }
                }
            }
            else
            {
                let arrImages  = self.dictDealer["images"] as? [UIImage]
                for i in 0..<arrImages!.count
                {
                    let imageTemp = arrImages?[i]
                    if imageTemp != UIImage(named:"placeholder"){
                        let imageData = UIImagePNGRepresentation(imageTemp!)
                        multipartFormData.append(imageData!, withName: "images[]", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                    }
                }
            }
            
        }, to: urlString,
           
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                    AppUtilities.sharedInstance.hideLoader()
                    
                    if let dict = response.result.value as? NSDictionary{
                        self.strImages =  dict.value(forKey: "data") as! String
                        self.nextSaveData()
                        
                    }
                }
            case .failure(let error):
                debugPrint(error)
            }
            
        })
    }
    
    func nextSaveData()
    {
        
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        
        debugPrint(dictDealer)
        
        let dictData : NSMutableDictionary = [
            "v_year":dictDealer.value(forKey: "year")!,
            "v_number":dictDealer.value(forKey: "VIN")!,
            "v_make":dictDealer.value(forKey: "make")!,
            "v_model":dictDealer.value(forKey: "model")!,
            "vimages":strImages,
            "mileage":dictDealer.value(forKey: "mileage")!,
            //"v_name":dictDealer.value(forKey: "name")!,
            "v_price":dictDealer.value(forKey: "price")!,
            "zipcode":AppUtilities.sharedInstance.getLoginPincode(),
            "lat":strLat,
            "lng":strLng,
            "address":AppUtilities.sharedInstance.getLoginAddress(),
            "city":AppUtilities.sharedInstance.getLoginCity(),
            ]
        
        if isEditDealer == "1"
        {
            let strDeletedImages = arrDeletedImg.componentsJoined(by: ",")
            dictData.setObject(dictEdit.object(forKey: "vid") as! String, forKey: "vid" as NSCopying)
            dictData.setObject(strDeletedImages, forKey: "deletedimages" as NSCopying)
        }
        
        let dictionaryParams : NSDictionary = [
            "service": "AddVehicle",
            "request" : [
                "data": dictData.copy()
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
                    if (object.value(forKey: "success") as? Bool) != nil
                    {
                        let responseDic = object
                        debugPrint(responseDic)
                        if let status = responseDic.value(forKey: "success") as? Int
                        {
                            if(status == 1)
                            {
                                UserDefaults.standard.set(true, forKey: "IsRefresh")
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
    
    
    //MARK: - Convert To Dictionary
    
    func convertToDictionary(text: String) -> NSDictionary {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        return NSDictionary()
    }
    
    //MARK: - CLLocationManager delegate method
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let currentloc:CLLocation = manager.location!
        strLat = "\(currentloc.coordinate.latitude)"
        strLng = "\(currentloc.coordinate.longitude)"
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentloc)
        {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            if placeArray != nil{
                if (placeArray?.count)! > 0
                {
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    
                    if let street = placeMark.addressDictionary?["Thoroughfare"] as? String
                    {
                        self.strAddress = street
                    }
                    if let city = placeMark.addressDictionary?["City"] as? String
                    {
                        self.strCity = city
                    }
                    if let zip = placeMark.addressDictionary?["ZIP"] as? String
                    {
                        self.strZipCode = zip
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.startUpdatingLocation()
    }
    
}
