//
//  MenuViewController.swift
//  TradeInGurus
//
//  Created by Admin on 12/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var lblMail: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imageProfilePic: UIImageView!
    @IBOutlet var lblNotificCount : UILabel!
    @IBOutlet var lblChatCount : UILabel!
    
    //MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        AppUtilities.sharedInstance.AppEvents(view: self)
        imageProfilePic.layer.cornerRadius = 22.5
        imageProfilePic.clipsToBounds = true
        lblNotificCount.isHidden = true
        lblChatCount.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lblUserName.text = AppUtilities.sharedInstance.getLoginUserName()
        lblMail.text = AppUtilities.sharedInstance.getLoginUserEmail()
        imageProfilePic.sd_setImage(with: URL(string: AppUtilities.sharedInstance.getLoginUserProfile()), placeholderImage: UIImage(named:"placeholder"))
        
        AppApi.sharedInstance.notifiCount()
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCount), name: NSNotification.Name(rawValue: "Notification"), object: nil)
    }
    
    func notificationCount(notification: NSNotification)  {
        debugPrint(notification)
        
        
        if Int((notification.object! as! NSDictionary).value(forKey: "notifications") as! String) != 0 {
            lblNotificCount.isHidden = false
            lblNotificCount.layer.cornerRadius = lblNotificCount.frame.size.height / 2
            lblNotificCount.clipsToBounds = true
            lblNotificCount.text = "\((notification.object! as! NSDictionary).value(forKey: "notifications") as! String)"
        }
        else {
            lblNotificCount.isHidden = true
        }
        
        if Int((notification.object! as! NSDictionary).value(forKey: "chats") as! String) != 0 {
            lblChatCount.isHidden = false
            lblChatCount.layer.cornerRadius = lblChatCount.frame.size.height / 2
            lblChatCount.clipsToBounds = true
            lblChatCount.text = "\((notification.object! as! NSDictionary).value(forKey: "notifications") as! String)"
            lblChatCount.text = "\((notification.object! as! NSDictionary).value(forKey: "chats") as! String)"
        }
        else {
            lblChatCount.isHidden = true
        }
    }
    
    //MARK: - All Button Action -
    @IBAction func btnHomePressed(_ sender: Any) {
        //self.revealViewController().revealToggle(self)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") as! HomePageViewController
        self.revealViewController().pushFrontViewController(vc, animated: true)
    }
    
    @IBAction func btnSettingsPressed(_ sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.revealViewController().pushFrontViewController(vc, animated: true)
    }
    
    @IBAction func btnChatPressed(_ sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
        self.revealViewController().pushFrontViewController(vc, animated: true)
    }
    
    @IBAction func btnNotificationPressed(_ sender: UIButton)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationVC
        self.revealViewController().pushFrontViewController(vc, animated: true)
    }
    
    @IBAction func btnLogoutPressed(_ sender: UIButton)
    {
        
        let alert = UIAlertController(title: "Logout", message: "Are you sure that you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.logout()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- API Methods -
    func logout()
    {
        self.view.endEditing(true)
        
        AppUtilities.sharedInstance.showLoader()
        var deviceToken = "dd8714bdbcc11076888df23d910c5bbf158cdd09e7c81ffd43dc11804a96bfcb"
        if let deviceTc = UserDefaults.standard.value(forKey: "DeviceToken") as? String{
            deviceToken = deviceTc
        }
        let dictionaryParams : NSDictionary = [
            "service": "logout",
            "request" : [
                "secret_log_id": AppUtilities.sharedInstance.getSecretUserId(),
                "device_id": deviceToken],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            ]  as NSDictionary
        
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
                                UserDefaults.standard.set(nil, forKey: "LoginResponse")
                                UserDefaults.standard.set(nil, forKey: "Token")
                                UserDefaults.standard.set(false, forKey: "IsUserLoggedIn")
                                UserDefaults.standard.synchronize()
                                self.navigationController?.popToRootViewController(animated: true)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

