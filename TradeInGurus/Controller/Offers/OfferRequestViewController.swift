//
//  OfferRequestViewController.swift
//  TradeInGurus
//
//  Created by Admin on 13/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import RSBarcodes

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
class OfferRequestViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,BarcodeDelegate, UITextViewDelegate {
    
    @IBOutlet weak var viewOffer: UIView!
    @IBOutlet weak var tblViewOffer: UITableView!
    @IBOutlet weak var tblViewMakeModelYear: UITableView!
    @IBOutlet weak var lblViewMakeModelYear: UILabel!
    var arrayNewImages = [UIImage]()
    var dictDealer = [//"VIN":"",
        "year":"",
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
    var arrayRemoveLinks = [String]()
    var dictDealerChat = NSDictionary()
    var arrDealers = NSMutableArray()
    var index = 0
    var strImages = ""
    var arrDealID = NSMutableArray()
    var arrayCommon = NSMutableArray()
    var arrayMake = NSMutableArray()
    var arrayModel =  NSMutableArray()
    var arrayYear =  NSMutableArray()
    var strMakeID = "1"
    var strModelID = "1"
    var strYearID = "1"
    var strCommon = "make"
    var isScanOn = false
    var isEdit = false
    var isViewInfo = "1"
    var PageInd : Int = 1
    var isAPICalled = true
    var srchLatitude = ""
    var srchLongtiude = ""
    var isSearch = false
    var isScan = false
    //MARK:- UIView Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isEdit == true {
            
            let arrDealerID = self.dictDealer.value(forKey: "dealersdata") as? NSArray ?? []
            
            for i in 0..<arrDealerID.count {
                
                let dict = arrDealerID[i] as? NSDictionary
                self.arrDealID.add(dict!)
                
            }
        }
        nearDealer()
//        getMake()
        getYear()
        setTableFooterView()
        NotificationCenter.default.addObserver(self, selector: #selector(test), name:NSNotification.Name(rawValue: "TestNotification"), object: nil)
        AppUtilities.sharedInstance.AppEvents(view: self)
    }
    
    func test() {
        
        Constant.sharedInstance.is_Done = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "IsLocation") {
            UserDefaults.standard.set(false, forKey: "IsLocation")
            
            let dictData = UserDefaults.standard.data(forKey: "dictDealerData")
            dictDealer = NSKeyedUnarchiver.unarchiveObject(with: dictData!) as! NSMutableDictionary
            
            dictDealer.setValue(UserDefaults.standard.value(forKey: "Location") as? String, forKey: "srchlocation")
            srchLatitude = UserDefaults.standard.value(forKey: "Latitude") as! String
            
            srchLongtiude = UserDefaults.standard.value(forKey: "Longitude") as! String
            arrDealers.removeAllObjects()
            self.tblViewOffer.reloadData()
            searchDealer(text: dictDealer.value(forKey: "srchtext") as? String ?? "")
            
        }
        
    }
    
    
    func setTableFooterView(){
        
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        viewFooter.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        let btnHeader = UIButton(frame: CGRect(x: 15, y: 8, width:UIScreen.main.bounds.width - 50, height: 45))
        btnHeader.titleLabel?.font = UIFont(name: "Ubuntu-Medium", size: 18.0)
        btnHeader.setTitle("Submit", for: .normal)
        btnHeader.backgroundColor = UIColor.orange
        btnHeader.addTarget(self, action: #selector(self.btnSubmitPressed(_:)), for: .touchUpInside)
        setCornerView(btnHeader)
        btnHeader.setTitleColor(UIColor.white, for: .normal)
        viewFooter.addSubview(btnHeader)
        tblViewOffer.tableFooterView = viewFooter
    }
    
    
    //MARK:- API -
    func  isValidall()->Bool{
        for (key,value) in dictDealer
        {
            
            if let valuedd = value as? String, let valuek = key as? String{
                if valuedd == ""{
                    if valuek != "phone" && valuek != "email" && valuek != "srchtext" && valuek != "srchlocation" && valuek != "description" && valuek != "name" && valuek != "VIN" {
                        AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please insert \(valuek) value." as NSString)
                        return false
                    }
                }
            }
            
            if let valuek = key as? String,let valuedd = value as? String{
                if valuedd != "" {
                    if valuek == "email"{
                        if !AppUtilities.sharedInstance.isValidEmail(testStr: valuedd){
                            
                            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter valid email")
                            return false
                        }
                    }
                }
            }
        }
        
        
        return true
    }
    
    
    func uploadImages(){
        var  idx = -1
        let arrImages  = dictDealer["images"] as? [UIImage]
        if arrImages != nil{
            for i in arrImages!.indices
            {
                let imageTemp = arrImages?[i]
                let isPlaceHolder : Bool = isItPlaceHolder(image1: imageTemp!)
                if isPlaceHolder{
                    idx = i
                    break
                }
                
            }
            
        }
        //        if idx == 0 {
        //            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please upload one image" as NSString)
        //            return
        //
        //        }
        //        if idx == 0 {
        //            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please upload one image" as NSString)
        //            return
        //
        //        }
        //
        //        if arrDealID.count == 0 {
        //            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please select one dealer" as NSString)
        //            return
        //
        //        }
        
        AppUtilities.sharedInstance.showLoader()
        // let arrImages  = self.dictDealer["images"] as? [UIImage]
        if arrImages != nil{
            let urlString = "http://app.tradeingurus.com/upload/uploadVehicalImage"
            Alamofire.upload(multipartFormData: { multipartFormData in
                // import image to request
                for i in 0..<self.arrayNewImages.count
                {
                    let imageTemp = self.arrayNewImages[i]
                    
                    let isPlaceHolder : Bool = self.isItPlaceHolder(image1: imageTemp)
                    
                    if !isPlaceHolder{
                        let imageData = UIImagePNGRepresentation(imageTemp)
                        multipartFormData.append(imageData!, withName: "images[]", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
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
        else{
            self.nextSaveData()
        }
    }
    
    func nextSaveData()
    {
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        let arrID = NSMutableArray()
        
        for i in 0..<arrDealID.count {
            
            let dict = arrDealID.object(at: i) as? NSDictionary
            
            arrID.add(dict?.value(forKey: "deal_id") as? String ?? "")
        }
        
        let dealID = arrID.componentsJoined(by: ",")
        debugPrint(dealID)
        var descReplaceStr = String()
        var newString = String()
        if dictDealer.value(forKey: "description") as? String != nil {
            descReplaceStr = dictDealer.value(forKey: "description") as! String
            newString = descReplaceStr.replacingOccurrences(of: "\n", with: "\\n",
                                                            options: NSString.CompareOptions.literal, range:nil)
        }
        
        print(newString)
        
        let dictData = [
            "v_year":dictDealer.value(forKey: "year") as? String ?? "",
            "v_number":dictDealer.value(forKey: "VIN") as? String ?? "",
            "make":dictDealer.value(forKey: "make") as? String ?? "",
            "v_model":dictDealer.value(forKey: "model") as? String ?? "",
            "images":strImages,
            "mileage":dictDealer.value(forKey: "mileage") as? String ?? "",

            //            "v_name":dictDealer.value(forKey: "name"),
//            "phone":dictDealer.value(forKey: "phone"),
//            "email":dictDealer.value(forKey: "email"),
//            "zipcode":dictDealer.value(forKey: "zipcode"),
//            "v_price":dictDealer.value(forKey: "v_price"),
            "deal_id":dealID,
            "description":newString
        ]
        
        let dictD = NSMutableDictionary(dictionary:dictData)
        
        if isEdit {
            dictD.setValue(dictDealer.value(forKey: "vid"), forKey: "offerid")
            dictD.setValue(dictDealer.value(forKey: "is_open"), forKey: "is_open")
            dictD.setValue(arrayRemoveLinks.joined(separator: ","), forKey: "deletedimages")
        }
        let dictionaryParams : NSDictionary = [
            "service": "AddCustomerOffer",
            "request" : [
                "data":dictD
            ],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary

        
        debugPrint(dictionaryParams)
        
        // start
       /*
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Postman-Token": "ef8d3c8b-a846-4cae-b200-da1ceb6e98e1"
        ]
        let parameters = [
            "auth": [
                "id": 1911,
                "token": "jZxGctd7QoT-Bf0e0Iaj9DsP5F68Z9fQN"
            ],
            "request": ["data": [
                "deal_id": "1901",
                "description": "",
                "images": "",
                "make": "HUMMER ",
                "mileage": "120",
                "v_model": "H2",
                "v_number": "5GRGN23U13H134854",
                "v_year": "2003"
                ]],
            "service": "AddCustomerOffer"
            ] as [String : Any]
        
        let paramdata = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//        let postData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        let request = NSMutableURLRequest(url: NSURL(string: "http://tradeingurus.com/WebService/service")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
//        request.httpBody = postData as Data
        debugPrint(paramdata!)
        let convertedString = String(data: paramdata!, encoding: String.Encoding.utf8) // the data will be converted to the string
        debugPrint(convertedString!)
        if paramdata != nil {
            request.httpBody = paramdata
            
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
//                debugPrint(let json = try? JSONSerialization.jsonObject(with: data, options: []))
                if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode
                    {
//                        completion(true, json as AnyObject?)
                        let object = json as? String
//                        let object = json as? NSDictionary
                    }
                    else
                    {
//                        completion(false, json as AnyObject?)
                        let object = json as? NSDictionary
                    }
                }
            }
        })
        
        dataTask.resume()*/
        // end
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams, strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                AppUtilities.sharedInstance.hideLoader()
//                debugPrint(object as? NSString ?? "")
//                let object = object as? NSDictionary
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
                                UserDefaults.standard.set(true, forKey: "isAddUpdate")
                                
                                if self.isEdit
                                {
                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Request updated successfully" as NSString)
                                }
                                else{
                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Request added successfully" as NSString)
                                }
                                
                                self.navigationController?.popViewController(animated: true)
                            }
                            else{
                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                    if dealID == ""
                                    {
                                        AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please Select Dealer" as NSString)
                                    }
                                    else
                                    {
                                        AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                    }
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
    
    
    func btnGetCode(_ strCode: String) {
        
        AppUtilities.sharedInstance.showLoader()
        var newVIN = strCode
        dictDealer.setValue(strCode, forKey: "VIN")
        
        if strCode.characters.count > 17 {
            debugPrint(strCode.characters.dropFirst())
            newVIN = String(strCode.characters.dropFirst())
        }
        //let strURL = "https://api.edmunds.com/v1/api/toolsrepository/vindecoder?vin=\(newVIN)&fmt=json&api_key=edb2rmzgmrff3fa3ycp7puhu"
        //let strURL = "https://api.edmunds.com/v1/api/toolsrepository/vindecoder?vin=\(newVIN)&fmt=json&api_key=94tyghf85jdhshwge334"
        //let strURL = "http://api.edmunds.com/api/v1/vehicle/vin/\(newVIN)/configuration?api_key=edb2rmzgmrff3fa3ycp7puhu"
        let strURL = "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValuesExtended/\(newVIN)?format=json"
        
        
        
        //let strEncodeUrl = strURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        debugPrint(dictDealer)
        
        tblViewOffer.reloadData()
        
        let request = NSMutableURLRequest(url: NSURL(string: strURL)! as URL)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            DispatchQueue.main.async( execute: {
                AppUtilities.sharedInstance.hideLoader()
                
                //                if data == nil{
                //                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Data not found.")
                //
                //                } else {
                do {
                    let jsonWithObjectRoot = try JSONSerialization.jsonObject(with: data!, options: [])
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
                    
                }
                catch {
                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Data not found")
                }
                
            })
            // onCompletion(jsonWithObjectRoot, error)
        })
        task.resume()
    }
    
    func nearDealer()
    {
        
        self.view.endEditing(true)
        self.isAPICalled = true
        AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "NearDealer",
            "request" : [
                "data": [
                    "user_lat":GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.latitude ?? 21.170240,
                    "user_long": GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.longitude ?? 72.831062,
                    "username":"",
                    "distance": 1000,
                    "pageindex":PageInd
                    
                ]],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                AppUtilities.sharedInstance.hideLoader()
                self.isAPICalled = false
                
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
                                    if self.PageInd == 1 {
                                        self.arrDealers.removeAllObjects()
                                    }
                                    if arr.count == 0 ||  arr.count < 10 {
                                        self.isAPICalled = true
                                    }
                                    self.arrDealers.addObjects(from: (responseDic.value(forKey: "data") as! NSArray) as! [Any])
                                    
                                    
                                    self.tblViewOffer.reloadData()
                                    
                                }
                            }
                            else{
                                self.isAPICalled = true
                                
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
    
    func searchDealer(text: String)
    {
        isAPICalled = true
        //AppUtilities.sharedInstance.showLoader()
        
        var lat = ""
        var long = ""
        
        if dictDealer.value(forKey: "srchlocation") as? String != "" {
            lat = srchLatitude
            long = srchLongtiude
            
        }
        else {
            lat = "\(GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.latitude ?? 21.170240)"
            long = "\(GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.longitude ?? 72.831062)"
        }
        
        
        let dictionaryParams : NSDictionary = [
            "service": "Searchdealer",
            "request" : [
                "data": [
                    "user_lat":lat,
                    "user_long":long,
                    "search_text":text,
                    "distance": 1000,
                    
                ]],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                //AppUtilities.sharedInstance.hideLoader()
                
                //                if self.spinner != nil{
                //                    self.spinner.stopAnimating()
                //
                //                }
                
                if let object = object as? NSDictionary
                {
                    if  (object.value(forKey: "success") as? Bool) != nil
                    {
                        self.isAPICalled = false
                        
                        let responseDic = object
                        debugPrint(responseDic)
                        if let status = responseDic.value(forKey: "success") as? Int
                        {
                            if(status == 1)
                            {
                                
                                if let arr = responseDic.value(forKey: "data") as? NSArray
                                {
                                    if arr.count == 0 || arr.count < 10{
                                        self.isAPICalled = true
                                        
                                    }
                                    self.arrDealers = NSMutableArray(array: arr)
                                    self.tblViewOffer.reloadSections(NSIndexSet(index: 2) as IndexSet, with: .none)
                                    
                                }
                                else {
                                    
                                    
                                }
                            }
                            else{
                                self.isAPICalled = true
                                if let arr = responseDic.value(forKey: "data") as? NSArray
                                {
                                    if arr.count == 0 || arr.count < 10{
                                        self.isAPICalled = true
                                        
                                    }
                                    self.arrDealers = NSMutableArray(array: arr)
                                    self.tblViewOffer.reloadSections(NSIndexSet(index: 2) as IndexSet, with: .none)
                                }
                                //self.tblViewOffer.isHidden = true
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
    
    
    //MARK: - UIButton Action Methods -
    
    @IBAction func btnBarcodeScannerPressed() {
        var isResult = false
        let vc : RSScannerViewController =  RSScannerViewController(cornerView: true, controlView: true, barcodesHandler: { (barcodeObjects) in
            if isResult == false {
                if (barcodeObjects?.count)! > 0 {
                    if (barcodeObjects?.count)! > 0 {
                        isResult = true
                        let strCode = barcodeObjects?[0] as! AVMetadataMachineReadableCodeObject
                        var code = strCode.stringValue
                        if code?.characters.first == "I" {
                            code?.remove(at: (code?.startIndex)!)
                        }
                        self.btnGetCode(code!)
                    }
                }
            }
            self.dismiss(animated: true, completion: {
                
            })
            
        }, preferredCameraPosition: .back)
        self.present(vc, animated: true) {
            
        }
        
    }
    
    
    @IBAction func btnStatusPressed(_ sender: UIButton) {
        dictDealer.setValue("1", forKey: "is_open")
        
        if sender.tag == 22
        {
            dictDealer.setValue("0", forKey: "is_open")
        }
        dictDealer.setValue("0", forKey: "is_pop_open")
        
        tblViewOffer.reloadData()
    }
    
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func btnBackViewPressed(_ sender: Any) {
        
        
       /* if strCommon == "make"
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
    
    
    @IBAction func btnBarcodePressed(_ sender: UIButton) {
        isScan = true
        self.view.endEditing(true)
        self.btnBarcodeScannerPressed()
    }
    
    @IBAction func btnSubmitPressed(_ sender: Any) {
        
        if  isValidall(){
            uploadImages()
            
        }
        
    }
    
    @IBAction func btnDeleteImagePressed(_ sender: UIButton) {
        debugPrint(arrayNewImages)
        
        
        var arrImages  = dictDealer["images"] as? [UIImage]
        
        if isEdit{
            var arrImagesL  = dictDealer["imagesL"] as? [String]
            
            
            
            if sender.tag == 11{
                arrayRemoveLinks.append((arrImagesL?[0])!)
                
                arrImagesL?.remove(at: 0)
            }
            else if sender.tag == 21{
                arrayRemoveLinks.append((arrImagesL?[1])!)
                
                arrImagesL?.remove(at: 1)
            }
            else if sender.tag == 31{
                arrayRemoveLinks.append((arrImagesL?[2])!)
                
                arrImagesL?.remove(at: 2)
            }
            arrImagesL?.insert("", at: index)
            
            var arrL = [String]()
            
            for i in 0..<arrImagesL!.count
            {
                let imageTemp = arrImagesL?[i]
                if imageTemp != ""{
                    arrL.append(imageTemp!)
                }
            }
            for i in 0..<arrImagesL!.count
            {
                if i < arrL.count
                {
                    arrImagesL?.remove(at: i)
                    arrImagesL?.insert(arrL[i], at: i)
                }
                else{
                    arrImagesL?.remove(at: i)
                    arrImagesL?.insert("", at: i)
                    
                }
            }
            
            
            dictDealer.setValue(arrImagesL, forKey: "imagesL")
        }
        dictDealer.setValue(arrImages, forKey: "images")
        
        if sender.tag == 11{
            var idx = -1
            for im in 0..<arrayNewImages.count{
                let imag = arrayNewImages[im]
                if imag == arrImages?[0]{
                    idx = im
                    break
                }
            }
            if idx != -1{
                arrayNewImages.remove(at: idx)
            }
            
            arrImages?.remove(at: 0)
            
            
        }
        else if sender.tag == 21{
            var idx = -1
            for im in 0..<arrayNewImages.count{
                let imag = arrayNewImages[im]
                if imag == arrImages?[1]{
                    idx = im
                    break
                }
            }
            if idx != -1{
                arrayNewImages.remove(at: idx)
            }
            arrImages?.remove(at: 1)
        }
        else if sender.tag == 31{
            var idx = -1
            for im in 0..<arrayNewImages.count{
                let imag = arrayNewImages[im]
                if imag == arrImages?[2]{
                    idx = im
                    break
                }
            }
            if idx != -1{
                arrayNewImages.remove(at: idx)
            }
            arrImages?.remove(at: 2)
        }
        
        arrImages?.insert(UIImage(named:"placeholder")!, at: index)
        var arrI = [UIImage]()
        
        for i in 0..<arrImages!.count
        {
            let imageTemp = arrImages?[i]
            let isPlaceHolder : Bool = self.isItPlaceHolder(image1: imageTemp!)
            if !isPlaceHolder{
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
            else{
                arrImages?.remove(at: i)
                arrImages?.insert(UIImage(named:"placeholder")!, at: i)
                
            }
        }
        dictDealer.setValue(arrImages, forKey: "images")
        tblViewOffer.reloadData()
    }
    
    
    @IBAction func btnUploadPressed(_ sender: Any) {
        print(dictDealer["images"] as? [UIImage] ?? "not fund")
        let arrImages = dictDealer["images"] as? [UIImage]
        print("arrImages: ", arrImages ?? "", arrImages!.count)
        var iCheck = 0
        if arrImages != nil
        {
            for i in 0..<arrImages!.count
            {
                let imageTemp = arrImages?[i]
                let isPlaceHolder : Bool = isItPlaceHolder(image1: imageTemp!)
                if isPlaceHolder
                {
                    index = i
                    iCheck = index + 1
                    break
                }
            }
        }
        
        
        
        if arrImages?.count == 3 && iCheck != 0{
            
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
        else{
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg:"Sorry! You can add maximum 3 profile images.")
            
        }
        
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
    
    
    @IBAction func btnCarDetailsClk(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            /*strCommon = "make"
            arrayCommon = arrayMake
            tblViewMakeModelYear.reloadData()
            addSubviewToWidow()*/
            
            strCommon = "year"
            arrayCommon = arrayYear
            tblViewMakeModelYear.reloadData()
            
            addSubviewToWidow()
        }
        else if sender.tag == 1 {
            
            /*if strMakeID == "1" {
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
            addSubviewToWidow() */
            
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
           /* if strMakeID != "1" && strModelID != "" {
                getYear() make,model, year
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
            addSubviewToWidow()*/
            
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
    
    @IBAction func btnLocationClk(_ sender: UIButton) {
        let respnseData = NSKeyedArchiver.archivedData(withRootObject: dictDealer)
        UserDefaults.standard.set(respnseData, forKey: "dictDealerData")
        let check = self.storyboard?.instantiateViewController(withIdentifier: "CheckinpageViewController") as! CheckinpageViewController
        check.isOffer = true
        self.present(check, animated: true, completion: nil)
        
    }
    
    
    //MARK: - Other
    
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
    
    func setTxtVwCorner(_ viewC : IQTextView)
    {
        viewC.layer.cornerRadius = 5.0
        viewC.layer.borderWidth = 1.0
        viewC.layer.borderColor = UIColor.white.cgColor
        viewC.clipsToBounds = true
        //viewC.setLeftPaddingPoints(10)
    }
    
    
    
    //MARK: - UITableView Delegate and Datasource -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView == tblViewMakeModelYear{
            return 1
        }
        else{
            return 3
        }
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
        else{
            
            if indexPath.section == 0 {
                
                var tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellVehicle")!
                
                if isEdit{
                    tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellVehicleEdit")!
                }
                if self.isViewInfo == "3" {
                    tableViewCell.isUserInteractionEnabled = false
                }
                
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
                    tfname.attributedPlaceholder = NSAttributedString(string: "Name",
                                                                      attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                    tfname.frame.size.height = 0
                    tfname.isHidden = true
                }
                if let tfphone = tableViewCell.viewWithTag(40) as? UITextField
                {
                    tfphone.text = dictDealer["phone"] as? String ?? ""
                    setCorner(tfphone)
                    tfphone.attributedPlaceholder = NSAttributedString(string: "Phone Number",
                                                                       attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                    tfphone.frame.size.height = 0
                    tfphone.isHidden = true
                }
                if let tfemail = tableViewCell.viewWithTag(45) as? UITextField
                {
                    tfemail.text = dictDealer["email"] as? String ?? ""
                    setCorner(tfemail)
                    tfemail.attributedPlaceholder = NSAttributedString(string: "Email Address",
                                                                       attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                    tfemail.frame.size.height = 0
                    tfemail.isHidden = true
                }
                if let tfzipcode = tableViewCell.viewWithTag(50) as? UITextField
                {
                    tfzipcode.text = dictDealer["zipcode"] as? String ?? ""
                    setCorner(tfzipcode)
                    tfzipcode.attributedPlaceholder = NSAttributedString(string: "Zipcode",
                                                                         attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                    tfzipcode.frame.size.height = 0
                    tfzipcode.isHidden = true
                }
                
                if let tfPrice = tableViewCell.viewWithTag(75) as? UITextField {
                    
                    tfPrice.text = dictDealer["v_price"] as? String ?? ""
                    setCorner(tfPrice)
                    tfPrice.attributedPlaceholder = NSAttributedString(string: "Price",
                                                                       attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                    
                    tfPrice.frame.size.height = 0
                    tfPrice.isHidden = true
                }
                
                if let txtVwdesc = tableViewCell.viewWithTag(501) as? IQTextView
                {
                    txtVwdesc.text = dictDealer["description"] as? String ?? ""
                    setTxtVwCorner(txtVwdesc)
                    txtVwdesc.placeholder = "Description"
                }
                
                
                if let viewPopOpen = tableViewCell.viewWithTag(12)
                {
                    viewPopOpen.isHidden = true
                    if let is_pop_open = dictDealer["is_pop_open"] as? String {
                        if is_pop_open == "1"{
                            viewPopOpen.isHidden = false
                            
                        }
                    }
                }
                if let imgviewBarcode = tableViewCell.viewWithTag(1001) as? UIImageView
                {
                    let tap = UITapGestureRecognizer(target: self, action: #selector(btnBarcodePressed(_:)))
                    //                tap.delegate = self
                    imgviewBarcode.addGestureRecognizer(tap)
                }
                
                if let btnBarcode = tableViewCell.viewWithTag(5001) as? UIButton
                {
                    debugPrint(btnBarcode)
                    
                }
                if let tfStatus = tableViewCell.viewWithTag(100) as? UITextField
                {
                    let status = dictDealer["is_open"] as? String ?? ""
                    
                    if status == "1"{
                        
                        tfStatus.text = "Close"
                    }
                    else
                    {
                        tfStatus.text = "Open"
                        
                    }
                    setCorner(tfStatus)
                    tfStatus.attributedPlaceholder = NSAttributedString(string: "Status",
                                                                        attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                }
                if let btnUpload = tableViewCell.viewWithTag(70) as? UIButton
                {
                    //tfzipcode.text = dictDealer["zipcode"] as? String ?? ""
                    btnUpload.layer.cornerRadius = 15
                    btnUpload.clipsToBounds = true
                }
                
                if isEdit
                {
                    let arrImagesL  = dictDealer["imagesL"] as? [String]
                    let arrImages  = dictDealer["images"] as? [UIImage]
                    if let image1 = tableViewCell.viewWithTag(55) as? UIImageView
                    {
                        image1.sd_setImage(with: URL(string:(arrImagesL?[0])!), placeholderImage:  arrImages?[0], options: .progressiveDownload, completed: { (imageP, error, type, url) in
                            if imageP != nil{
                                var arrImages  = self.dictDealer["images"] as? [UIImage]
                                if arrImages == nil{
                                    arrImages?.append(imageP!)
                                }
                                else{
                                    arrImages?.remove(at: 0)
                                    arrImages?.insert(imageP!, at: 0)
                                }
                                self.dictDealer.setValue(arrImages, forKey: "images")
                                // self.tblViewOffer.reloadData()
                            }
                        })
                        
                        if let btn1 = tableViewCell.viewWithTag(11) as? UIButton
                        {
                            let isPlaceHolder : Bool = isItPlaceHolder(image1: image1.image!)
                            if isPlaceHolder
                            {
                                btn1.isHidden = true
                            }
                            else{
                                btn1.isHidden = false
                                
                            }
                        }
                    }
                    if let image2 = tableViewCell.viewWithTag(60) as? UIImageView
                    {
                        image2.sd_setImage(with: URL(string:(arrImagesL?[1])!), placeholderImage:  arrImages?[1], options: .progressiveDownload, completed: { (imageP, error, type, url) in
                            if imageP != nil{
                                var arrImages  = self.dictDealer["images"] as? [UIImage]
                                if arrImages == nil{
                                    arrImages?.append(imageP!)
                                }
                                else{
                                    arrImages?.remove(at: 1)
                                    arrImages?.insert(imageP!, at: 1)
                                }
                                self.dictDealer.setValue(arrImages, forKey: "images")
                                //    self.tblViewOffer.reloadData()
                            }
                        })
                        
                        if let btn1 = tableViewCell.viewWithTag(21) as? UIButton
                        {
                            let isPlaceHolder : Bool = isItPlaceHolder(image1: image2.image!)
                            if isPlaceHolder
                            {
                                btn1.isHidden = true
                            }
                            else{
                                btn1.isHidden = false
                                
                            }
                        }
                        
                    }
                    if let image3 = tableViewCell.viewWithTag(65) as? UIImageView
                    {
                        image3.sd_setImage(with: URL(string:(arrImagesL?[2])!), placeholderImage:  arrImages?[2], options: .progressiveDownload, completed: { (imageP, error, type, url) in
                            if imageP != nil{
                                var arrImages  = self.dictDealer["images"] as? [UIImage]
                                if arrImages == nil{
                                    arrImages?.append(imageP!)
                                }
                                else{
                                    arrImages?.remove(at: 2)
                                    arrImages?.insert(imageP!, at: 2)
                                }
                                self.dictDealer.setValue(arrImages, forKey: "images")
                                //  self.tblViewOffer.reloadData()
                            }
                        })
                        
                        if let btn1 = tableViewCell.viewWithTag(31) as? UIButton
                        {
                            let isPlaceHolder : Bool = isItPlaceHolder(image1: image3.image!)
                            if isPlaceHolder
                            {
                                btn1.isHidden = true
                            }
                            else{
                                btn1.isHidden = false
                                
                            }
                        }
                    }
                    
                }
                else{
                    
                    let arrImages  = dictDealer["images"] as? [UIImage]
                    
                    if let image1 = tableViewCell.viewWithTag(55) as? UIImageView
                    {
                        image1.image = arrImages?[0]
                        if let btn1 = tableViewCell.viewWithTag(11) as? UIButton
                        {
                            let isPlaceHolder : Bool = isItPlaceHolder(image1: image1.image!)
                            if isPlaceHolder{
                                btn1.isHidden = true
                            }
                            else{
                                btn1.isHidden = false
                            }
                        }
                    }
                    if let image2 = tableViewCell.viewWithTag(60) as? UIImageView
                    {
                        image2.image = arrImages?[1]
                        if let btn1 = tableViewCell.viewWithTag(21) as? UIButton
                        {
                            let isPlaceHolder : Bool = isItPlaceHolder(image1: image2.image!)
                            if isPlaceHolder{
                                btn1.isHidden = true
                            }
                            else{
                                btn1.isHidden = false
                                
                            }
                        }
                        
                    }
                    if let image3 = tableViewCell.viewWithTag(65) as? UIImageView
                    {
                        image3.image = arrImages?[2]
                        if let btn1 = tableViewCell.viewWithTag(31) as? UIButton
                        {
                            let isPlaceHolder : Bool = isItPlaceHolder(image1: image3.image!)
                            if isPlaceHolder{
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
            else if indexPath.section == 1 {
                
                let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "SearchCell")!
                
                if let tfSrchName = tableViewCell.viewWithTag(105) as? UITextField
                {
                    tfSrchName.text = dictDealer["srchtext"] as? String ?? ""
                    setCorner(tfSrchName)
                    tfSrchName.attributedPlaceholder = NSAttributedString(string: "Search by dealer name",
                                                                          attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                    
                }
                
                if let tfSrchLoct = tableViewCell.viewWithTag(110) as? UITextField
                {
                    tfSrchLoct.text = dictDealer["srchlocation"] as? String ?? ""
                    setCorner(tfSrchLoct)
                    tfSrchLoct.attributedPlaceholder = NSAttributedString(string: "Search by dealer location",
                                                                          attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
                    tfSrchLoct.clearButtonMode = .unlessEditing
                }
                if self.isViewInfo == "3" {
                    tableViewCell.isUserInteractionEnabled = false
                }
                
                return tableViewCell
                
            }
            else {
                let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellAreaDetail")!
                let dictDealer = arrDealers.object(at: indexPath.row) as? NSDictionary
                let fullName = dictDealer?["fullname"] as? String ?? ""
                let user_id = dictDealer?["user_id"] as? String ?? ""
                
                if let lblVIN = tableViewCell.viewWithTag(10) as? UILabel
                {
                    lblVIN.text = fullName
                }
//                {
//                    lblVIN.text = fullName
//                }
                
                
                let perdicate = NSPredicate(format: "deal_id == %@", dictDealer?.value(forKey: "deal_id") as? String ?? "")
                
                let arrResult = self.arrDealID.filtered(using: perdicate)
                
                let imgChat = tableViewCell.viewWithTag(56) as? UIImageView
                if arrResult.count > 0 {
                    
                    tableViewCell.accessoryType = .checkmark
                    if self.isViewInfo == "3" {
                        imgChat?.isHidden = false
                    } else {
                        imgChat?.isHidden = true
                    }
                }
                else{
                    tableViewCell.accessoryType = .none
                    imgChat?.isHidden = true
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
            if section == 2{
                if arrDealID.count == 0 {
                    return arrDealers.count
                } else {
                    
                    for i in 0..<arrDealID.count
                    {
                        let dictDealer = arrDealID.object(at: i) as? NSDictionary
                        
                        if isEdit == true {
                            let perdicate = NSPredicate(format: "deal_id == %@", dictDealer?.value(forKey: "deal_id") as? String ?? "")
                            let arrResult = self.arrDealers.filtered(using: perdicate) as NSArray
                            
                            if arrResult.count != 0 {
                                let dictData : NSDictionary = arrResult.object(at: 0) as! NSDictionary
                                arrDealers.remove(dictData)
                                arrDealers.insert(dictData, at: 0)
                            } else {
                                arrDealers.insert(dictDealer!, at: 0)
                            }
                            
                        } else {
                            if arrDealers.contains(dictDealer!)
                            {
                                arrDealers.remove(dictDealer!)
                            }
                            arrDealers.insert(dictDealer!, at: 0)
                        }
                        
                    }
                    
                    return arrDealers.count
                }
                
            }
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
        if tableView == tblViewMakeModelYear{
            return 0
        }
        else{
            if section == 2{
                
                return 0
            }
            return 10
            
        }
        
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
        else if section == 1{
            lblHeader.text = "Search dealer"
        }
        else{
            lblHeader.text = "Dealer Details"
            
        }
        viewHeader.addSubview(btnHeader)
        viewHeader.addSubview(lblHeader)
        viewHeader.backgroundColor = UIColor.white
        setCornerView(viewHeader)
        return viewHeader
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 2{
            
            let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
            //            viewFooter.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            //            let btnHeader = UIButton(frame: CGRect(x: 15, y: 8, width:UIScreen.main.bounds.width - 50, height: 45))
            //            btnHeader.titleLabel?.font = UIFont(name: "Ubuntu-Medium", size: 18.0)
            //            btnHeader.setTitle("Submit", for: .normal)
            //            btnHeader.backgroundColor = UIColor.orange
            //            setCornerView(btnHeader)
            //            btnHeader.setTitleColor(UIColor.white, for: .normal)
            //            viewFooter.addSubview(btnHeader)
            return viewFooter
            
        }
        
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        viewFooter.backgroundColor = UIColor.clear
        return viewFooter
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        
        if tableView == tblViewMakeModelYear{
            
            /*let dict = arrayCommon.object(at: indexPath.row) as! NSDictionary
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
            tblViewOffer.reloadData()*/
            let dict = arrayCommon.object(at: indexPath.row) as! NSDictionary
            if strCommon == "year" {
                strCommon = "make"
                strYearID =  dict.value(forKey: "year") as? String ?? "1"
                
                dictDealer.setValue(dict.value(forKey: "year") as? String ?? "1", forKey: "year")
                
//                // Reset
//                dictDealer.setValue(dict.value(forKey: "make") as? String ?? "1", forKey: "make")
//                dictDealer.setValue(dict.value(forKey: "model") as? String ?? "1", forKey: "model")
                getMake()
            } else if strCommon == "model" {
                dictDealer.setValue(dict.value(forKey: "model") as? String ?? "1", forKey: "model")
                
                // Reset
//                dictDealer.setValue(dict.value(forKey: "make") as? String ?? "1", forKey: "make")
//                dictDealer.setValue(dict.value(forKey: "model") as? String ?? "1", forKey: "model")
                removeSubviewFromWindow()
            } else {
                strCommon = "model"
                dictDealer.setValue(dict.value(forKey: "make") as? String ?? "1", forKey: "make")
                strMakeID = dict.value(forKey: "make") as? String ?? "1"
                
                getModel()
            }
            self.tblViewOffer.reloadData()
        }
        else{
            if self.isViewInfo == "3" {

//                let dictOffer = NSMutableDictionary()
//                let arrDealerID = self.dictDealer.value(forKey: "dealersdata") as? NSArray
//                let data = arrDealerID?.object(at: 0) ?? "" as? NSDictionary
//                print(arrDealerID?.object(at: 0) ?? "")
//                dictOffer.setValue(arrDealerID, forKey: "dealersdata")
//                var data = self.dictDealer as Array
//
                let dictDealer = arrDealers.object(at: indexPath.row) as? NSDictionary
                let perdicate = NSPredicate(format: "deal_id == %@", dictDealer?.value(forKey: "deal_id") as? String ?? "")
                let arrResult = self.arrDealID.filtered(using: perdicate)
                if arrResult.count > 0 {
                    if self.isViewInfo == "3" {
                        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
//                        chatVC.dictChatUser = NSMutableDictionary(dictionary: dictDealerChat)
                        chatVC.dictChatUser = NSMutableDictionary(dictionary: dictDealer!)
                        self.navigationController?.pushViewController(chatVC, animated: true)
                    }
                }
                
                
                
//                if isNotific == true {
//                    chatVC.isResquest = true
//                }
//                
                
            } else {
                if indexPath.section == 2 {
                    let dictDealer = arrDealers.object(at: indexPath.row) as? NSDictionary
                    
                    if arrDealID.count < 5 {
                        if (tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark){
                            
                            arrDealID.remove(arrDealers.object(at: indexPath.row) as! NSDictionary)
                            
                        }
                        else {
                            arrDealID.add(dictDealer!)
                        }
                    }
                    else {
                        AppUtilities.sharedInstance.showAlert(title: App_Title as NSString, msg: "Choose only 5 dealer")
                    }
                    debugPrint(arrDealID)
                    
                    self.tblViewOffer.reloadSections(NSIndexSet(index: 2) as IndexSet, with: .none)
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if tableView == tblViewMakeModelYear{
            return 40
        }
        else{
            
            if indexPath.section == 0{
                if isEdit
                {
//                    return 730
                    return 553
                }
                return 480
            }
            else if indexPath.section == 1{
                return 100
            }
            else{
                return 50
            }
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRow = tableView.numberOfRows(inSection: 0)
        
        if isAPICalled == false{
            if indexPath.row == lastRow - 1 {
                tableView.tableFooterView?.isHidden = false
                PageInd = PageInd + 1
                if isSearch == false {
                    nearDealer()
                }
            }
        }
    }
    
    
    //MARK: - UITextField delegate -
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        dictDealer.setValue("0", forKey: "is_pop_open")
        
        if textField.tag == 100{
            
            self.view.endEditing(true)
            if textField.tag == 100{
                dictDealer.setValue("1", forKey: "is_pop_open")
                tblViewOffer.reloadData()
            }
            else{
                
            }
            return false
        }
        else if textField.tag == 110{
            let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                // Your code with delay
                let respnseData = NSKeyedArchiver.archivedData(withRootObject: self.dictDealer)
                UserDefaults.standard.set(respnseData, forKey: "dictDealerData")
                let check = self.storyboard?.instantiateViewController(withIdentifier: "CheckinpageViewController") as! CheckinpageViewController
                check.isOffer = true
                self.present(check, animated: true, completion: nil)
            }
            
            return true
        }
        else {
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
            dictDealer.setValue(newText, forKey: "phone")
        }
        else if textField.tag == 45{
            dictDealer.setValue(newText, forKey: "email")
        }
        else if textField.tag == 50{
            dictDealer.setValue(newText, forKey: "zipcode")
        }
        else if textField.tag == 75 {
            dictDealer.setValue(newText, forKey: "v_price")
        }
        else if textField.tag == 105 {
            let when = DispatchTime.now() + 0 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.dictDealer.setValue(newText, forKey: "srchtext")
                self.arrDealers.removeAllObjects()
                self.tblViewOffer.reloadSections(NSIndexSet(index: 2) as IndexSet, with: .none)
                if newText != "" {
                    self.isSearch = true
                    self.searchDealer(text: newText)
                }
                else {
                    self.isSearch = false
                    self.PageInd = 1
                    self.nearDealer()
                }
                
            }
            
            
        }
        else if textField.tag == 110 {
            dictDealer.setValue(newText, forKey: "srchlocation")
        }
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if isScan == false {
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
        else {
            isScan = false
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        
        if textField.tag == 110{
            textField.resignFirstResponder()
            textField.text = ""
            searchDealer(text: dictDealer.value(forKey: "srchtext") as? String ?? "")
        }
        
        return false
    }
    
    //MARK: - TextView Delegate Methd -
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = NSString(string: textView.text!).replacingCharacters(in: range, with: text)
        
        if textView.tag == 501 {
            dictDealer.setValue(newText, forKey: "description")
        }
        
        return true
    }
    
    
    //MARK:- UIImagePickerController Delegate -
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var img1 = UIImage()
        img1 = info[UIImagePickerControllerEditedImage] as! UIImage
        arrayNewImages.append(img1)
        var arrImages  = dictDealer["images"] as? [UIImage]
        if arrImages == nil{
            arrImages?.append(img1)
        }
        else{
            arrImages?.remove(at: index)
            arrImages?.insert(img1, at: index)
        }
        dictDealer.setValue(arrImages, forKey: "images")
        tblViewOffer.reloadData()
        self.dismiss(animated: true, completion: nil)
        debugPrint(arrayNewImages)
        
    }
    
    func isItPlaceHolder(image1:UIImage) -> Bool
    {
        var isPlaceholder : Bool = false
        
        let image2 : UIImage = UIImage(named:"placeholder")!
        let data1 = AppUtilities.sharedInstance.compressImage(image: image1) as Data
        let data2 = AppUtilities.sharedInstance.compressImage(image: image2) as Data
        if data1 == data2
        {
            isPlaceholder = true
        }
        
        return isPlaceholder
    }
    
    
    //MARK:- Memory Life Cycle -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
