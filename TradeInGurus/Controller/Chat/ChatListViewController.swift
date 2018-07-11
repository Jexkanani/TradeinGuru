//
//  ChatListViewController.swift
//  TradeInGurus
//
//  Created by Admin on 28/11/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

class ChatListCell : UITableViewCell {
    
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblLastMsg : UILabel!
    @IBOutlet var lblChatTime : UILabel!
    @IBOutlet var lblNewMsgCount : UILabel!
    
}

class ChatListViewController: UIViewController {
    
    //MARK: - All Outlets -
    @IBOutlet var tblChatList : UITableView!
    @IBOutlet var viewError404 : UIView!
    
    //MARK: - Intilize Varriable -
    var arrChatList = NSMutableArray()
    
    
    //MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewError404.isHidden = true
        tblChatList.estimatedRowHeight = 60
        tblChatList.rowHeight = UITableViewAutomaticDimension
        AppUtilities.sharedInstance.showLoader()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getChatList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - All Button Action -
    
    @IBAction func btnMenuClk(_ sender: UIButton) {
        self.revealViewController().revealToggle(sender)
    }
    
    //MARK: - API CALL -
    
    func getChatList() {
        self.view.endEditing(true)
        
        
        let dictionaryParams : NSDictionary = [
            "service": "getMessagelist",
            "request" : [
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
                                
                                self.arrChatList = NSMutableArray(array: responseDic.value(forKey: "data") as! NSArray)
                                self.tblChatList.reloadData()
                                self.tblChatList.isHidden = false
                                self.viewError404.isHidden = true
                                
                            }
                            else {
                                self.tblChatList.isHidden = true
                                self.viewError404.isHidden = false
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//MARK : - Table View Delegate Method -

extension ChatListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrChatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatCell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        
        let dictChat = arrChatList.object(at: indexPath.row) as? NSDictionary
        
        if let imgURL = dictChat?.value(forKey: "profilepic") as? String {
            chatCell.imgUser.layer.cornerRadius = chatCell.imgUser.frame.size.height / 2
            chatCell.imgUser.clipsToBounds = true
            chatCell.imgUser.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "username_ic"))
        }
        
        chatCell.lblUserName.text = dictChat?.value(forKey: "fullname") as? String ?? ""
        chatCell.lblLastMsg.text = dictChat?.value(forKey: "message") as? String ?? ""
        
        let totalUnread = dictChat?.value(forKey: "totalunread") as? String
        
        if totalUnread != "0" {
            chatCell.lblNewMsgCount.isHidden = false
            chatCell.lblNewMsgCount.layer.cornerRadius =  chatCell.lblNewMsgCount.frame.size.height / 2
            chatCell.lblNewMsgCount.text = totalUnread
            chatCell.lblNewMsgCount.clipsToBounds = true
        } else {
            chatCell.lblNewMsgCount.isHidden = true
        }
        debugPrint(dictChat!)
        debugPrint(indexPath.row)
        let date2 = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date1 = dateFormatter.date(from: dictChat?.value(forKey: "create_date") as? String ?? "") // according to date format your date string
        debugPrint(date1, date2)
        if compareDate(date1: date1! as NSDate, date2: date2 as NSDate) {
            let calendar1 = Calendar.current
            
            let hour = calendar1.component(.hour, from: date1!)
            let minutes = calendar1.component(.minute, from: date1!)
            let seconds = calendar1.component(.second, from: date1!)
            print("hours = \(hour):\(minutes):\(seconds)")
            chatCell.lblChatTime?.text = "\(hour):\(minutes)"
        } else {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date1!)

            let month = components.month
            let day = components.day
            chatCell.lblChatTime?.text = "\(month!)/\(day!)"
        }
        return chatCell
    }
    
    func compareDate(date1:NSDate, date2:NSDate) -> Bool {
    let order = NSCalendar.current.compare(date1 as Date, to: date2 as Date, toGranularity: .day)
    //        let order = NSCalendar.currentCalendar.compareDate(date1, toDate: date2,
//                                                             toUnitGranularity: .Day)
        switch order {
        case .orderedSame:
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dictChat = arrChatList.object(at: indexPath.row) as? NSDictionary
        
        let chatVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVc.dictChatUser = NSMutableDictionary(dictionary: dictChat!)
        chatVc.isChatList = true
        self.navigationController?.pushViewController(chatVc, animated: true)
    }
}
