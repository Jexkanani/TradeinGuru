
//  BuyerNotiDetailViewController.swift
//  TradeInGurus
//
//  Created by Admin on 13/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

class cellNoti : UITableViewCell {
    @IBOutlet var lblNum : UILabel!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblAdd : UILabel!
    @IBOutlet var btnPushNoti : UIButton!
}


class BuyerNotiDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tblData : UITableView!
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var lblNavTitle : UILabel!
    @IBOutlet var viewError404 : UIView!

    var arrDic : NSDictionary = NSDictionary()
    var arrData : NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        arrDic
        lblNavTitle.text = "\(arrDic.value(forKey: "v_year") as? String ?? "") \(arrDic.value(forKey: "v_make") as? String ?? "") \(arrDic.value(forKey: "v_model") as? String ?? "")"
        self.getVehicleRequest()
        viewError404.isHidden = true
        lblTitle.text = "\(arrDic.value(forKey: "totarequests") as? String ?? "0") CUSTOMERS ARE REQUESTED "
        tblData.estimatedRowHeight = 216
        tblData.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: - All Button Action Methods -
    

    @IBAction func clkBack(sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func clkPush(sender : UIButton)
    {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.isFromBuyerNoti = true
        chatVC.dictChatUser = NSMutableDictionary(dictionary: arrData.object(at: sender.tag) as! NSDictionary)
        self.navigationController?.pushViewController(chatVC, animated: true)
        
        /*
        let dic : NSDictionary = arrData.object(at: sender.tag) as! NSDictionary
        
        let vid = dic.value(forKey: "vid") as? String ?? ""
        let userId = dic.value(forKey: "user_id") as? String ?? ""
        
        AppApi.sharedInstance.sendPushNoti(vid: vid, userID: userId, isOffer: false)*/
    }


    //MARK: - Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic : NSDictionary = arrData.object(at: indexPath.row) as! NSDictionary
        let cell : cellNoti = tableView.dequeueReusableCell(withIdentifier: "cellNoti") as! cellNoti
        cell.lblAdd.text = dic["address"] as? String ?? ""
//        cell.lblNum.text = "#\(indexPath.row + 1)"
        cell.lblNum.text = " • "
        cell.lblName.text = dic["fullname"] as? String ?? ""
        cell.btnPushNoti.tag = indexPath.row
        return cell
    }
    
    func getVehicleRequest()
    {
        self.view.endEditing(true)
        
        //AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "GetVehicleRequests",
            "request" : [
                "vid": arrDic.value(forKey: "vid")!],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                
                //AppUtilities.sharedInstance.hideLoader()
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
                                   self.arrData = NSMutableArray.init(array: arr)
                                   self.tblData.reloadData()
                                }
                            }
                            else{
//                                if let errorMsg = responseDic.value(forKey: "msg") as? String{
//                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
//                                }
                            }
                            
                            self.tblData.isHidden = false

                            if self.arrData.count == 0{
                                self.viewError404.isHidden = false
                                self.tblData.isHidden = true

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

    
    
}
