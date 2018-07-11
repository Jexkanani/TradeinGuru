//
//  NotificationViewController.swift
//  TradeInGurus
//
//  Created by Admin on 14/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit
class NotificationTableViewCell: UITableViewCell
{
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var imgNotification: UIImageView!
}

class NotificationVC: UIViewController  ,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tblViewNotifications: UITableView!
    @IBOutlet weak var viewError404: UIView!
    
    var arrNotifications = NSMutableArray()
    var PageInd : Int = 1
    var isAPICalled = true
    @IBOutlet var spinner : UIActivityIndicatorView!
    
    //MARK:- UIView Life cycle -
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getMyNotifications()
        tblViewNotifications.rowHeight = UITableViewAutomaticDimension
        tblViewNotifications.estimatedRowHeight = 60
        viewError404.isHidden = true
    }
    
    //MARK: - All UIButton actions -
    @IBAction func varBackPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMenuClk(_ sender: UIButton) {
        self.revealViewController().revealToggle(sender)
    }
    
    //MARK: - Other
    func setCorner(_ viewC : UIView)
    {
        viewC.layer.cornerRadius = 5.0
        viewC.clipsToBounds = true
    }
    
    //MARK:- API -
    func getMyNotifications()
    {
        self.isAPICalled = true
        
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "get_user_notification",
            "request" : [
                "pageindex":PageInd
            ],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                AppUtilities.sharedInstance.hideLoader()
                self.isAPICalled = false
                if self.spinner != nil{
                    self.spinner.stopAnimating()
                    
                }
                self.tblViewNotifications.tableFooterView = nil
                
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
                                    AppApi.sharedInstance.notifiCount()
                                    if arr.count == 0 ||  arr.count < 10{
                                        self.isAPICalled = true
                                    }
                                    self.arrNotifications.addObjects(from: arr as! [Any])
                                    self.tblViewNotifications.reloadData()
                                }
                            }
                            else{
                                //                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                //                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                //                                }
                            }
                            self.tblViewNotifications.isHidden = false
                            if self.arrNotifications.count == 0{
                                self.viewError404.isHidden = false
                                self.tblViewNotifications.isHidden = true
                                
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
    
    //MARK: - Table View Delegate Method -
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellNotification") as! NotificationTableViewCell
        setCorner(tableViewCell)
        
        let dictDealer = arrNotifications.object(at: indexPath.section) as! NSDictionary
        
        let attrs1 = [ NSForegroundColorAttributeName : UIColor.orange,  NSFontAttributeName : UIFont(name:"Ubuntu-Bold",size:16.0)! ] as [String : Any]
        
        
        let attrs2 = [ NSForegroundColorAttributeName : UIColor.darkGray,  NSFontAttributeName : UIFont(name:"Ubuntu",size:16.0)! ] as [String : Any]
        let fullname = dictDealer["fullname"] as? String ?? ""
        let nt_message = dictDealer["nt_message"] as? String ?? ""
        
        let attributedString1 = NSMutableAttributedString(string:"\(fullname) ", attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:nt_message, attributes:attrs2)
        attributedString1.append(attributedString2)
        
        tableViewCell.lblNotification.attributedText = attributedString1
        tableViewCell.imgNotification.layer.cornerRadius = 22.5
        tableViewCell.imgNotification.clipsToBounds = true
        tableViewCell.imgNotification.sd_setImage(with: URL(string: dictDealer["profilepic"] as? String ?? ""), placeholderImage: UIImage(named:"placeholder"))
        return tableViewCell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        viewFooter.backgroundColor = UIColor.clear
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let dictConsumer = arrNotifications.object(at: indexPath.section) as! NSDictionary
        
        if AppUtilities.sharedInstance.getLoginUserType() == "customer" {
            
            let message = dictConsumer.value(forKey: "nt_message") as? String ?? ""
            
            if message == " wants to contact with you" {
                let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                chatVC.dictChatUser = NSMutableDictionary(dictionary: dictConsumer)
                self.navigationController?.pushViewController(chatVC, animated: true)
                
            } else {
                let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "VehicleDetailViewController") as? VehicleDetailViewController {
                    vc.dictVehicle = dictConsumer
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
            }
            
        }
        else {
//            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//            if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "VehicleDetailsController") as? VehicleDetailsController {
//                vc.userDic = dictConsumer
//                
//                let custRequest = dictConsumer.value(forKey: "nt_type") as? String ?? ""
//                if custRequest == "customer_request"  {
//                    vc.isNotific = false
//                }
//                else {
//                    vc.isNotific = true
//                }
//                self.navigationController?.pushViewController(vc, animated: true)
//                
//            }
            if let vc : VehicleDetailsController = self.storyboard?.instantiateViewController(withIdentifier: "VehicleDetailsController") as! VehicleDetailsController {
//            if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "VehicleDetailVC") as? VehicleDetailVC {
                vc.userDic = dictConsumer
                
                let custRequest = dictConsumer.value(forKey: "nt_type") as? String ?? ""
                if custRequest == "customer_request"  {
                    vc.isNotific = false
                }
                else {
                    vc.isNotific = true
//                    vc.isFrom = "delearNoti"
                }
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastRow = tableView.numberOfRows(inSection: 0)
        if isAPICalled == false
        {
            if indexPath.row == lastRow - 1 {
                spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                tableView.tableFooterView = spinner
                tableView.tableFooterView?.isHidden = false
                
                
                PageInd = PageInd + 1
                getMyNotifications()
            }
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
