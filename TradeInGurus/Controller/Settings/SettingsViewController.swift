//
//  SettingsViewController.swift
//  TradeInGurus
//
//  Created by Admin on 12/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit
class CustomCell : UITableViewCell {
    @IBOutlet var lbltitle: UILabel!
    @IBOutlet var imgimg1: UIImageView!
    @IBOutlet var btn1: UIButton!
    @IBOutlet var btn2: UIButton!
    @IBOutlet var btn3: UIButton!
}

class SettingsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblSetting: UITableView!
    var arrAll:NSMutableArray!
    var dictSetting = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendGetSettingReq()
    }
    
    func sendGetSettingReq()
    {
        AppUtilities.sharedInstance.showLoader()
        let dictionaryParams : NSDictionary = [
            "service": "getSeting",
            "request" : "",
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]] as NSDictionary
        
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
                                self.dictSetting = responseDic.object(forKey: "data") as! NSDictionary
                                self.tblSetting.reloadData()
                            }
                            else
                            {
                                if let errorMsg = responseDic.value(forKey: "msg") as? String{
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
                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: (NSLocalizedString("Server is temporary down !! Plz try after sometime", comment: "Server is temporary down !! Plz try after sometime") as NSString))
                }
            })
        })
    }
    
    //MARK: - All Button Action -
    @IBAction func btnHomePressed(_ sender: Any) {
        self.revealViewController().revealToggle(sender)
    }
    
    // MARK: - Tableview Methods -
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section==0 {
            return 60
        } else if indexPath.section==1 {
            return 50
        } else if indexPath.section == 2 || indexPath.section == 3{
            return 60
        }
        return 1

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section==0 {
            return 2
        } else if section==1 {
            return 4
        } else if section == 2 || section == 3{
            return 1
        }
        return 1
    }
    /*func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "ACCOUNT SETTINGS"
        } else if (section == 1) {
            return "CONTACT US"
        }
        return ""
    }*/
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 50
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view1 :UIView = UIView()
        let label : UILabel = UILabel()
        label.textColor = UIColor(red: 182.0/255.0, green: 172.0/255.0, blue: 166.0/255.0, alpha: 1.0)
        label.frame = CGRect(x: 15, y: 12, width: Int(self.tblSetting.frame.size.width), height: 20)
        if section == 0 || section == 1 {
            view1.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44)
            if section == 0 {
                label.text="ACCOUNT SETTINGS"
            } else if (section == 1) {
                label.text="CONTACT US"
            }
        } else {
            view1.frame = CGRect(x: 0, y: 0, width: self.tblSetting.frame.size.width, height: 10)
        }
        label.font = UIFont(name: "Ubuntu", size: 14.0)
        view1.addSubview(label)
        return view1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var identifier = "CustomCell1"
        if ((indexPath.section==1 && indexPath.row==0) || (indexPath.section==1 && indexPath.row==1) || (indexPath.section==1 && indexPath.row==2)) {
            identifier = "CustomCell2"
        } else if (indexPath.section == 1 && indexPath.row == 3) {
            identifier = "CustomCell3"
        }
        
        let Cell: CustomCell! = tableView.dequeueReusableCell(withIdentifier: identifier ) as? CustomCell
        
        if (indexPath.section==0 && indexPath.row==0) {
            Cell.lbltitle.text = "Edit Profile";
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            Cell.lbltitle.text = "Change Password";
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            Cell.lbltitle.text = "Loading..."
            if (dictSetting.object(forKey: "contactno") != nil)
            {
                Cell.lbltitle.text = dictSetting.object(forKey: "contactno") as? String
            }
            Cell.imgimg1.image = UIImage(named:"phone_cont")
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            Cell.lbltitle.text = "Loading..."
            if (dictSetting.object(forKey: "email") != nil)
            {
                Cell.lbltitle.text = dictSetting.object(forKey: "email") as? String
            }
            Cell.imgimg1.image = UIImage(named:"mail_cont")
            
        } else if (indexPath.section == 1 && indexPath.row == 2) {
            Cell.lbltitle.text = "Loading..."
            if (dictSetting.object(forKey: "weburl") != nil)
            {
                Cell.lbltitle.text = dictSetting.object(forKey: "weburl") as? String
            }
            Cell.imgimg1.image = UIImage(named:"website_cont")

        } else if (indexPath.section == 1 && indexPath.row == 3) {
//            Cell.lbltitle.text = "";
            Cell.btn1.addTarget(self, action: #selector(self.Clk_Facebook), for: .touchUpInside)
            Cell.btn2.addTarget(self, action: #selector(self.Clk_Twitter), for: .touchUpInside)
            Cell.btn3.addTarget(self, action: #selector(self.Clk_Googleplus), for: .touchUpInside)
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            Cell.lbltitle.text = "Preference";
        } else if (indexPath.section == 3 && indexPath.row == 0) {
            Cell.lbltitle.text = "Terms & Condition";
        }
        
        return Cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)

        if (indexPath.section==0 && indexPath.row==0)
        {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController{
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if (indexPath.section == 0 && indexPath.row == 1)
        {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as? ChangePasswordViewController{
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if (indexPath.section == 1 && indexPath.row == 0)
        {
            let url:NSURL = NSURL(string: "telprompt://0796114272")!
            UIApplication.shared.openURL(url as URL)
        }
        else if (indexPath.section == 1 && indexPath.row == 1)
        {
            let url = URL(string: "mailto:shadi@gmail.com")
            self.socialShare(sharingURL: url as NSURL?)
        }
        else if (indexPath.section == 1 && indexPath.row == 2)
        {
            if let url = URL(string: "https://www.google.com") {
                UIApplication.shared.openURL(url as URL)
            }
        }
        else if (indexPath.section == 1 && indexPath.row == 3)
        {
            let textToShare: String = "Look at this awesome app for aspiring iOS Developers!"
            var myWebsite = URL(string: "")
            if (dictSetting.object(forKey: "weburl") != nil)
            {
                myWebsite = URL(string: dictSetting.object(forKey: "weburl") as! String)
            }
            let objectsToShare: [Any] = [textToShare, myWebsite ?? ""]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            present(activityVC, animated: true) { _ in }
        }
        else if (indexPath.section==2 && indexPath.row==0)
        {
            if (dictSetting.object(forKey: "preference") != nil)
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Preferance") as? Preferance
                vc?.strPreferance = dictSetting.object(forKey: "preference") as! String
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
        else if (indexPath.section==3 && indexPath.row==0)
        {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "TermsConditions") as? TermsConditions{
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func Clk_Facebook(){
        // dictSetting.object(forKey: "fblink") as? String
        if UIApplication.shared.canOpenURL((NSURL(string: (dictSetting.object(forKey: "fblink") as! String))! as URL)) {
            UIApplication.shared.openURL(NSURL(string: (dictSetting.object(forKey: "fblink") as! String))! as URL)
        }
    }
    func Clk_Twitter(){
        // dictSetting.object(forKey: "twitterlink") as? String
        if UIApplication.shared.canOpenURL((NSURL(string: (dictSetting.object(forKey: "twitterlink") as! String))! as URL)) {
            UIApplication.shared.openURL(NSURL(string: (dictSetting.object(forKey: "twitterlink") as! String))! as URL)
        }
    }
    func Clk_Googleplus(){
        // dictSetting.object(forKey: "gpluslink") as? String
        if UIApplication.shared.canOpenURL((NSURL(string: (dictSetting.object(forKey: "gpluslink") as! String))! as URL)) {
            UIApplication.shared.openURL(NSURL(string: (dictSetting.object(forKey: "gpluslink") as! String))! as URL)
        }
    }
    
    
    func socialShare(sharingURL: NSURL?) {
        var sharingItems = [AnyObject]()
        
        if let url = sharingURL {
            sharingItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.copyToPasteboard,UIActivityType.airDrop,UIActivityType.addToReadingList,UIActivityType.assignToContact,UIActivityType.postToTencentWeibo,UIActivityType.postToVimeo,UIActivityType.print,UIActivityType.saveToCameraRoll,UIActivityType.postToWeibo]
        self.present(activityViewController, animated: true, completion: nil)
    }
}
