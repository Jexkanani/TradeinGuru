//
//  ChatViewController.swift
//  TradeInGurus
//
//  Created by Admin on 28/11/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire

class ChatViewController: UIViewController, UITextViewDelegate, UNUserNotificationCenterDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK: - All Outlets -
    
    @IBOutlet var tblChat : UITableView!
    @IBOutlet var txtViewMessage : IQTextView!
    @IBOutlet var btnSend : UIButton!
    @IBOutlet var btnAttach : UIButton!
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var viewNavigationBar : UIView!
    @IBOutlet var viewScroll : UIScrollView!
    
    @IBOutlet var constrainViewSendMsgHeight : NSLayoutConstraint!
    @IBOutlet var constrainTableViewTop : NSLayoutConstraint!
    @IBOutlet var constrainTableViewHeight : NSLayoutConstraint!
    
    @IBOutlet var viewSendMsg: UIView!
    @IBOutlet var viewTbl: UIView!
    //MARK: - Intilize Varriable -
    var dictChatUser = NSMutableDictionary()
    var arrChat = NSMutableArray()
    var toUserId = ""
    var pageIndex = 1
    var isFinish = false
    var isChatList = false
    var isResquest = false
    var isFromBuyerNoti = false
    
    var arrHeader = NSMutableArray()
    
    var imgPro : UIImage = UIImage()
    var imgStr : String = String()
    
    //MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        btnSend.isSelected = false
        txtViewMessage.placeholder = "Type Message..."
        txtViewMessage.layer.cornerRadius = 7.5
        txtViewMessage.clipsToBounds = true
        txtViewMessage.layer.borderColor = UIColor.lightGray.cgColor
        txtViewMessage.layer.borderWidth = 1.0
        tblChat.estimatedRowHeight = 50
        tblChat.rowHeight = UITableViewAutomaticDimension
        AppUtilities.sharedInstance.AppEvents(view: self)
        //self.view.bringSubview(toFront: viewNavigationBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.constrainTableViewHeight.constant = self.view.frame.size.height - 108
        self.constrainTableViewTop.constant = 0
        self.lblUserName.text = dictChatUser.value(forKey: "fullname") as? String ?? ""
        
        if isFromBuyerNoti
        {
            if (dictChatUser.value(forKey: "user_id") != nil) {
                self.toUserId = dictChatUser.value(forKey: "user_id") as! String
            } else {
                return
            }
        }
        else
        {
            if isChatList == false {
                
                if isResquest == true {
                    if let user_id = dictChatUser.value(forKey: "user_id") as? String {
                        self.toUserId = user_id
                    } else if let user_id = dictChatUser.value(forKey: "userid") as? String {
                        self.toUserId = user_id
                    }
                } else {
                    if let user_id = dictChatUser.value(forKey: "nt_cust_id") as? String {
                        self.toUserId = user_id
                    } else  if let userid = dictChatUser.value(forKey: "userid") as? String {
                        self.toUserId = userid
                    } else if let userid = dictChatUser.value(forKey: "deal_id") as? String {
                        self.toUserId = userid
                    }
                }
                
                
            } else {
                if let toID = dictChatUser.value(forKey: "deal_id") as? String {
                    self.toUserId = toID
                } else {
                    if let userID = dictChatUser.value(forKey: "fromId") as? String {
                        if userID == AppUtilities.sharedInstance.getLoginUserId() {
                            self.toUserId = dictChatUser.value(forKey: "toId") as? String ?? ""
                            
                        } else {
                            self.toUserId = dictChatUser.value(forKey: "fromId") as? String ?? ""
                            
                        }
                    } else {
                        self.toUserId = dictChatUser.value(forKey: "toId") as? String ?? ""
                    }
                }
            }
        }
        
        AppUtilities.sharedInstance.isInChatScreen = true
        AppUtilities.sharedInstance.strOppUserId = self.toUserId
        NotificationCenter.default.addObserver(self, selector: #selector(getReciveNewMessage(Noti:)), name: NSNotification.Name(rawValue: "newMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(anotification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(anitification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.getChatConversion()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtilities.sharedInstance.isInChatScreen = false
        AppUtilities.sharedInstance.strOppUserId = "0"
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessage"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWasShown(anotification : NSNotification)  {
        let info = anotification.userInfo;
        let kbSize = ((info![UIKeyboardFrameBeginUserInfoKey])! as AnyObject).cgRectValue.size
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.constrainTableViewHeight.constant = self.view.frame.size.height - kbSize.height - 108;
            self.constrainTableViewTop.constant = kbSize.height
            if self.arrChat.count != 0 {
                let indexPath = IndexPath(row: self.arrChat.count - 1, section: 0)
                self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    func keyboardWillBeHidden(anitification : NSNotification)  {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.constrainTableViewHeight.constant = self.view.frame.size.height - 108
            self.constrainTableViewTop.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    //MARK: - Notification Observer -
    
    func getReciveNewMessage(Noti: NSNotification) {
        debugPrint(Noti)
        if let dict = Noti.value(forKey: "userInfo") as? NSDictionary {
            let dictAps = dict.value(forKey: "aps") as? NSDictionary
            let dictData = dictAps?.value(forKey: "data") as? NSDictionary
            self.arrChat.add(dictData!)
            self.tblChat.reloadData()
            let indexPath = IndexPath(row: self.arrChat.count - 1, section: 0)
            self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: false)
            
        }
        
    }
    
    //MARK: - All Button Action -
    
    @IBAction func btnBackClk(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAttachClk(_ sender: UIButton) {
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
    
    @IBAction func btnSendMsg(_ sender: UIButton) {
        if txtViewMessage.text.trim() != "" {
            self.btnSend.isEnabled = false
            self.sendMessage()
        }
    }
    
    
    //MARK: - UITextView Delegate Method -
    
    func textViewDidChange(_ textView: UITextView) {
        let widthMax:CGFloat = 95
        
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: 500.0))
        if size.height > 46.0 && size.height < widthMax {
            if size.height < widthMax {
                constrainViewSendMsgHeight.constant = size.height + 10
                self.view.layoutIfNeeded()
            }
            else
            {
                constrainViewSendMsgHeight.constant = widthMax
                self.view.layoutIfNeeded()
            }
            
        }
        else if size.height >= widthMax
        {
            constrainViewSendMsgHeight.constant = widthMax
            self.view.layoutIfNeeded()
        }
        else{
            constrainViewSendMsgHeight.constant = 45
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.view.bringSubview(toFront: viewNavigationBar)
        if textView.text?.characters.count == 0{
            btnSend.isSelected = false
            btnSend.isEnabled = false
        }else{
            btnSend.isSelected = true
            btnSend.isEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == ""{
            if textView.text?.characters.count == 1{
                btnSend.isSelected = false
                btnSend.isEnabled = false
            }
            return true
        }
        
        if ((textView.text?.characters.count)! + text.characters.count) > 0{
            btnSend.isSelected = true
            btnSend.isEnabled = true
        }else{
            btnSend.isSelected = false
            btnSend.isEnabled = false
        }
        
        return true
    }
    
    //MARK: - Api Call -
    
    func getChatConversion() {
        
        let dictionaryParams : NSDictionary = [
            "service": "getconversation",
            "request" : [
                "data" : ["toId" : self.toUserId,
                          "index" : "\(pageIndex)"
                ],
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
                                self.isFinish = true
                                
                                if let arrChatConversion = responseDic.value(forKey: "data") as? NSArray {
                                    
                                    if self.pageIndex == 1
                                    {
                                        self.arrChat.removeAllObjects()
                                    }
                                    
                                    if arrChatConversion.count < 10{
                                        
                                        self.tblChat.isHidden = false
                                        self.isFinish = false
                                    }
                                    
                                    if self.arrChat.count > 0 {
                                        let lastMessageID = (self.arrChat.object(at: 0) as? NSDictionary)?.value(forKey: "id") as? String
                                        
                                        
                                        debugPrint(self.arrChat.object(at: 0))
                                        self.arrChat = NSMutableArray(array: self.arrChat.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
                                        //debugPrint( self.arrayChatData);
                                        for i in 0..<Int((arrChatConversion.count))
                                        {
                                            self.arrChat.add(arrChatConversion[i])
                                        }
                                        
                                        self.arrChat = NSMutableArray(array: self.arrChat.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
                                        
                                        let lastindex : Int = (self.arrChat.value(forKey: "id") as! NSArray).index(of: lastMessageID ?? 10)
                                        let lastIndex = IndexPath(row: lastindex, section: 0)
                                        self.tblChat.reloadData()
                                        self.tblChat.scrollToRow(at: lastIndex, at: .top, animated: false)
                                    } else {
                                        
                                        if arrChatConversion.count != 0 {
                                            self.arrChat = NSMutableArray(array: responseDic.value(forKey: "data") as! NSArray)
                                            self.arrChat = NSMutableArray(array: self.arrChat.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
                                            self.tblChat.reloadData()
                                            let indexPath = IndexPath(row: self.arrChat.count - 1, section: 0)
                                            self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: false)
                                        }
                                    }
                                }
                            }
                            else {
                                
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
    
    func sendMessage() {
        
        let dictionaryParams : NSDictionary = [
            "service": "sendmessage",
            "request" : [
                "data" : ["toId" : self.toUserId,
                          "message" : self.txtViewMessage.text!
                ],
            ],
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                
                if let object = object as? NSDictionary
                {
                    if  (object.value(forKey: "success") as? Bool) != nil
                    {
                        self.txtViewMessage.text = ""
                        self.btnSend.isSelected = false
                        self.btnSend.isEnabled = false
                        let responseDic = object
                        debugPrint(responseDic)
                        if let status = responseDic.value(forKey: "success") as? Int
                        {
                            if(status == 1)
                            {
                                
                                self.arrChat.add(responseDic.value(forKey: "data") as! NSDictionary)
                                self.tblChat.reloadData()
                                let indexPath = IndexPath(row: self.arrChat.count - 1, section: 0)
                                self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: false)
                                self.textViewDidChange(self.txtViewMessage)
                                
                            }
                            else {
                                let msg = responseDic.value(forKey: "message") as? String ?? ""
                                AppUtilities.sharedInstance.showAlert(title: App_Title as NSString, msg: msg as NSString)
                            }
                        }
                        else
                        {
                            
                        }
                    }
                    else
                    {
                        self.btnSend.isSelected = true
                        self.btnSend.isEnabled = true
                        AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "\(object.value(forKey: "message") as? String ?? "" )" as NSString)
                        
                    }
                }
                else
                {
                    self.btnSend.isSelected = true
                    self.btnSend.isEnabled = true
                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: (NSLocalizedString("Server is temporary down !! Plz try after sometime", comment: "Server is temporary down !! Plz try after sometime") as NSString))
                }
                
            })
        })
    }
    
    func sendAttachment() {
        
        let dictionaryParams : NSDictionary = [
            "service": "sendmessage",
            "request" : [
                "data" : ["toId" : self.toUserId,
                          "message" : "",//self.txtViewMessage.text!,
                    "attachment" : self.imgStr
                ],
            ],
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                
                if let object = object as? NSDictionary
                {
                    if  (object.value(forKey: "success") as? Bool) != nil
                    {
                        self.txtViewMessage.text = ""
                        self.btnSend.isSelected = false
                        self.btnSend.isEnabled = false
                        let responseDic = object
                        debugPrint(responseDic)
                        if let status = responseDic.value(forKey: "success") as? Int
                        {
                            if(status == 1)
                            {
                                self.imgStr = ""
                                self.arrChat.add(responseDic.value(forKey: "data") as! NSDictionary)
                                self.tblChat.reloadData()
                                let indexPath = IndexPath(row: self.arrChat.count - 1, section: 0)
                                self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: false)
                                self.textViewDidChange(self.txtViewMessage)
                                
                            }
                            else {
                                let msg = responseDic.value(forKey: "message") as? String ?? ""
                                AppUtilities.sharedInstance.showAlert(title: App_Title as NSString, msg: msg as NSString)
                            }
                        }
                        else
                        {
                            
                        }
                    }
                    else
                    {
                        self.btnSend.isSelected = true
                        self.btnSend.isEnabled = true
                        AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "\(object.value(forKey: "message") as? String ?? "" )" as NSString)
                        
                    }
                }
                else
                {
                    self.btnSend.isSelected = true
                    self.btnSend.isEnabled = true
                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: (NSLocalizedString("Server is temporary down !! Plz try after sometime", comment: "Server is temporary down !! Plz try after sometime") as NSString))
                }
                
            })
        })
    }
    
    //MARK:- UIImagePickerController Delegate -
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var img1 = UIImage()
        img1 = info[UIImagePickerControllerEditedImage] as! UIImage
        //        imgProfile.image = img1
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
            self.sendAttachment()
        }) { (failure) in
            debugPrint(failure)
        }
    }
    
    func uploadImageWithAlamofire(Parameters params : [String : AnyObject]?,ImageParameters imgparams :  [NSObject : AnyObject]?,Action action : NSString, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void)
    {
        
        let URLName = "http://app.tradeingurus.com/upload/uploadattachment"
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//MARK: - Table View Delegate Place -

extension ChatViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrChat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictChatConversion = arrChat.object(at: indexPath.row) as? NSDictionary
        let userID = dictChatConversion?.value(forKey: "fromId") as? String ?? ""
        debugPrint(dictChatConversion?.value(forKey: "attachmenturl") as? String)
        if userID == AppUtilities.sharedInstance.getLoginUserId() {
            var identifier = String()
            if (!((dictChatConversion?.value(forKey: "attachmenturl") as? String)?.isEmpty)!) {
                identifier = "SenderImg"
            } else {
                identifier = "SenderCell"
            }
            let senderCell = tableView.dequeueReusableCell(withIdentifier: identifier)  as! SenderCell
            if (!((dictChatConversion?.value(forKey: "attachmenturl") as? String)?.isEmpty)!) {
                if let imgURL = dictChatConversion?.value(forKey: "attachmenturl") as? String {
                    senderCell.ImgSenderImg.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "default_tig_pic"))
                }
            } else {
                senderCell.lblSenderMsg.text = dictChatConversion?.value(forKey: "message") as? String ?? "hello"
                senderCell.viewSenderMsgBackgroung.layer.cornerRadius = 17
                senderCell.viewSenderMsgBackgroung.clipsToBounds = true
            }
            
            if let imgURL = dictChatConversion?.value(forKey: "fromprofile") as? String {
                senderCell.imgSenderUser.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "username_ic"))
            }
            
            /// TIMESTAMP Added : HP ///
            var isoDate = dictChatConversion?.value(forKey: "create_date") as! String
            isoDate = self.UTCToLocal(date: isoDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd h:mm:ss"
            let date = dateFormatter.date(from: isoDate)
            
            let startDate = dateFormatter.string(from: Date())
            let strDT = dateFormatter.date(from: startDate)
            
            let dateRangeStart = date
            let dateRangeEnd = strDT
            
            let components = Calendar.current.dateComponents([.second, .minute, .hour, .day], from: dateRangeStart!, to: dateRangeEnd!)
            
            if (components.hour!) >= 1
            {
                senderCell.lbl_sender_timeStamp.text = "\(components.hour ?? 0) hour ago"
            }else if (components.minute!) >= 1
            {
                senderCell.lbl_sender_timeStamp.text = "\(components.minute ?? 0) min ago"
            }
            else
            {
                senderCell.lbl_sender_timeStamp.text = "Just Now"
            }
            ///////////////////////////
            
            return senderCell
        } else {
            var identifier = String()
            if (!((dictChatConversion?.value(forKey: "attachmenturl") as? String)?.isEmpty)!) {
                identifier = "ReciverImg"
            } else {
                identifier = "ReciverCell"
            }
            let reciverCell = tableView.dequeueReusableCell(withIdentifier: identifier)  as! ReciverCell
            if (!((dictChatConversion?.value(forKey: "attachmenturl") as? String)?.isEmpty)!) {
                if let imgURL = dictChatConversion?.value(forKey: "attachmenturl") as? String {
                    reciverCell.ImgReciverImg.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "default_tig_pic"))
                }
            } else {
                reciverCell.lblReciverMsg.text = dictChatConversion?.value(forKey: "message") as? String ?? "hello"
                reciverCell.viewReciverMsgBackgroung.layer.cornerRadius = 17
                reciverCell.viewReciverMsgBackgroung.clipsToBounds = true
            }
            
            if let imgURL = dictChatConversion?.value(forKey: "fromprofile") as? String {
                reciverCell.imgReciverUser.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "username_ic"))
            }
            
            /// TIMESTAMP Added : HP ///
            var isoDate = dictChatConversion?.value(forKey: "create_date") as? String
            isoDate = self.UTCToLocal(date: isoDate!)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd h:mm:ss"
            let date = dateFormatter.date(from: isoDate!)
            
            let startDate = dateFormatter.string(from: Date())
            let strDT = dateFormatter.date(from: startDate)
            
            let dateRangeStart = date
            let dateRangeEnd = strDT
            
            let components = Calendar.current.dateComponents([.second, .minute, .hour, .day], from: dateRangeStart!, to: dateRangeEnd!)
            
            if (components.hour!) >= 1
            {
                reciverCell.lbl_timeStamp.text = "\(components.hour ?? 0) hour ago"
            }else if (components.minute!) >= 1
            {
                reciverCell.lbl_timeStamp.text = "\(components.minute ?? 0) min ago"
            }
            else
            {
                reciverCell.lbl_timeStamp.text = "Just Now"
            }
            ///////////////////////////
            
            return reciverCell
        }
        
    }
    
    func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm:ss"
        
        return dateFormatter.string(from: dt!)
    }
    
}

//MARK: - Scroll View Delegate -

extension ChatViewController {
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let contentYoffset = scrollView.contentOffset.y
        
        if contentYoffset > 5 {
            tblChat.keyboardDismissMode = .onDrag
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        
        let contentYoffset = scrollView.contentOffset.y
        
        if contentYoffset < 10
        {
            if self.isFinish
            {
                self.isFinish = false
                self.pageIndex += 1
                self.getChatConversion()
            }
        }
    }
}

