//
//  EditProfileViewController.swift
//  TradeInGurus
//
//  Created by Admin on 14/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire

class EditProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, SBPickerSelectorDelegate {

    //MARK: - All Outlets -
    
    @IBOutlet weak var txtMobileNumber: ACFloatingTextfield!
    @IBOutlet weak var txtEmailAddress: ACFloatingTextfield!
    @IBOutlet weak var txtFullName: ACFloatingTextfield!
    @IBOutlet var txtAddress : ACFloatingTextfield!
    @IBOutlet var txtState : ACFloatingTextfield!
    @IBOutlet var txtCountry : ACFloatingTextfield!
    @IBOutlet var txtCity : ACFloatingTextfield!
    @IBOutlet var txtZipcode : ACFloatingTextfield!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var imgProfile: UIImageView!

    //MARK: - Intilize Varriable -
    
    var imgPro : UIImage = UIImage()
    var imgStr : String = String()
    var arrCountry = NSMutableArray()
    var strStateID = ""
    
    //MARK:- View Life Cycle -
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setData()
        getAllState()
    }
    
    //MARK: - Set Value -
    
    func setData() {
        txtFullName.text = AppUtilities.sharedInstance.getLoginUserName()
        txtEmailAddress.text =  AppUtilities.sharedInstance.getLoginUserEmail()
        txtMobileNumber.text =  AppUtilities.sharedInstance.getLoginUserMobile()
        imgProfile.sd_setImage(with: URL(string: AppUtilities.sharedInstance.getLoginUserProfile()), placeholderImage: UIImage(named:"placeholder"))
        txtAddress.text = AppUtilities.sharedInstance.getLoginAddress()
        txtCity.text = AppUtilities.sharedInstance.getLoginCity()
        strStateID = AppUtilities.sharedInstance.getLoginStateId()
        txtZipcode.text = AppUtilities.sharedInstance.getLoginPincode()
        txtCountry.text = AppUtilities.sharedInstance.getLoginCountry()
        viewProfile.layer.cornerRadius = 52.5
        viewProfile.clipsToBounds = true
    }

    
    //MARK: - All Button Action -
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveProfilePressed(_ sender: Any) {
        self.setProfileData()
        
    }
    
    @IBAction func btnUploadPicPressed(_ sender: Any) {
        
        let Action = UIAlertController(title: "Add Pic", message: "Choose from gallery", preferredStyle: UIAlertControllerStyle.actionSheet)
        Action.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        Action.addAction(UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.default, handler: ({
            action in
            let imgpicker = UIImagePickerController()
            imgpicker.sourceType = UIImagePickerControllerSourceType.camera
            imgpicker.cameraDevice = UIImagePickerControllerCameraDevice.front
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
    
    @IBAction func btnStateClk(_ sender: Any) {
        
        self.view.endEditing(true)
        let picker = SBPickerSelector.picker()
        picker.pickerData = arrCountry.value(forKey: "statename") as! [Any] //picker content
        picker.delegate = self
        picker.pickerType = SBPickerSelectorType.text
        picker.doneButtonTitle = "Done"
        picker.cancelButtonTitle = "Cancel"
        let point: CGPoint = view.convert(txtState.frame.origin, from: txtState.superview)
        var frame: CGRect = txtState.frame
        frame.origin = point
        picker.showPickerOver(self)
        
    }
    
    //MARK: - PickerView Delegate -
    func pickerSelector(_ selector: SBPickerSelector, selectedValue value: String, index idx: Int) {
        print(idx)
        
        strStateID =  ((arrCountry.object(at: idx) as! NSDictionary).value(forKey: "id")) as! String
        txtState.text = value
    }
    



    //MARK: -  Validation -
    func isCredentialValid() -> Bool {
        let is_valid  = true
        
        if (txtFullName.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter fullname")
            return false
        }
       else if (txtMobileNumber.text?.isEmptyOrWhitespace())!{
            
            AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "Please enter mobile number")
            return false
        }
        return is_valid
    }
    
    
    
    //MARK:- UIImagePickerController Delegate -
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var img1 = UIImage()
        img1 = info[UIImagePickerControllerEditedImage] as! UIImage
        imgProfile.image = img1
        imgPro = img1
        self.dismiss(animated: true, completion: nil)
        self.uploadImageAndData()
    }
    

    //MARK: - Upload Image Methods
    
    
    func uploadImageAndData(){
        
        let str : NSString = NSString()
        AppUtilities.sharedInstance.showLoader()
        self.uploadImageWithAlamofire(Parameters: [:], ImageParameters: [:], Action: str, success: { (response) in
            debugPrint(response)
            let res : NSDictionary = self.convertToDictionary(text: response as! String)
            self.imgStr = res.value(forKey: "data") as? String ?? ""
            AppUtilities.sharedInstance.hideLoader()
        }) { (failure) in
            debugPrint(failure)
        }
    }
    
    

    func uploadImageWithAlamofire(Parameters params : [String : AnyObject]?,ImageParameters imgparams :  [NSObject : AnyObject]?,Action action : NSString, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void)
    {
        
        let URLName = "http://app.tradeingurus.com/upload/uploadprofilepic"
        
        let headers:[String:String] = [
            "Accept": "multipart/form-data",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            
            if let imageData = UIImageJPEGRepresentation(self.imgPro, 0.7) {
                        multipartFormData.append(imageData, withName: "image", fileName: "\(NSDate().timeIntervalSince1970 * 1000)).jpg", mimeType: "image/jpg")
            }
            
            if params != nil{
                for (key, value) in params! {
                    
                    if value is String || value is Int {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                    }
                }
            }
            
            
        }, to: URLName, method: .post, headers: headers,
           encodingCompletion: { encodingResult in
            switch encodingResult {
                
            case .success(let upload, _, _):
                upload.uploadProgress { progress in
                    debugPrint(progress.fractionCompleted)
                }
                upload.response { [weak self] response in
                    guard self != nil else {
                        return
                    }
                    let responseString = String(data: response.data!, encoding: String.Encoding.utf8)
                    DispatchQueue.main.async {
                        return success(responseString as AnyObject)
                    }
                    
                    
                }
            case .failure(let encodingError):
                debugPrint("error:\(encodingError)")
                return failure(encodingError as AnyObject)
            }
        })
        
    }

    
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
    
    
    //MARK:- Register User Method
    
    func setProfileData()
    {
        if self.isCredentialValid() == false {
            return
        }
        
        if AppUtilities.sharedInstance.isNetworkRechable() == false {
            AppUtilities.sharedInstance.showAlert(title: App_Title as NSString, msg: NSLocalizedString("No Internet Connection", comment: "Comm") as NSString)
            return
        }
        
        AppUtilities.sharedInstance.showLoader()
        
        let param : NSDictionary = [
            "service" : "update_user",
            "request" : [
                "data":[
                    "fullname":txtFullName.text!,
                    "profilepic":imgStr,
                    "mobile":txtMobileNumber.text!,
                    "address" : txtAddress.text!,
                    "pincode" : txtZipcode.text!,
                    "city" : txtCity.text!,
                    "county" : txtCountry.text!,
                    "stateid" : strStateID
                ]
            ],
            "auth": [
                "id" : AppUtilities.sharedInstance.getLoginUserId(),
                "token": AppUtilities.sharedInstance.getLoginUserToken()
            ]
        ]

        
        let URLName = Base_URL
        
        let headers:[String:String] = [
            "Accept" : "application/json"
        ]
        
        Alamofire.request(URLName,method: .post, parameters: param as?  [String : Any], encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    
                    let dic : NSDictionary = response.result.value as! NSDictionary
                    
                    if dic.value(forKey: "success") as! Bool == true{
                        let respnseData = NSKeyedArchiver.archivedData(withRootObject: dic.value(forKey: "data") ?? "")
                        UserDefaults.standard.set(respnseData, forKey: "LoginResponse")
                        AppUtilities.sharedInstance.hideLoader()
                        AppUtilities.sharedInstance.showAlert(title: App_Title as NSString, msg: NSLocalizedString(dic.value(forKey: "message") as! String, comment: "") as NSString)
                    }else{
                        let error : NSDictionary = dic.value(forKey: "errors") as! NSDictionary
                        AppUtilities.sharedInstance.showAlert(title: App_Title as NSString, msg: error.value(forKey: error.allKeys.first as! String) as! NSString)
                        AppUtilities.sharedInstance.hideLoader()
                    }
                }
                break
                
            case .failure(_):
                AppUtilities.sharedInstance.hideLoader()
                AppUtilities.sharedInstance.showAlert(title: App_Title as NSString, msg: NSLocalizedString("Something going wrong", comment: "ccomm") as NSString)
                break
                
            }
        }
        
    }
    
    func getAllState() {
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
                                self.arrCountry = NSMutableArray(array: responseDic.object(forKey: "data") as! NSArray)
                                let resultPredicate : NSPredicate = NSPredicate(format: "id == %@", self.strStateID)
                                let searchResults = self.arrCountry.filtered(using: resultPredicate)
                                if searchResults.count != 0{
                                    let dic = searchResults[0] as! NSDictionary
                                    let strStateName = dic.value(forKey: "statename") as! String
                                    self.txtState.text = strStateName
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
    
    
}
