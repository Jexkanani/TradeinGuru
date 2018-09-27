//
//  OfferReqReceivedController.swift
//  TradeInGurus
//
//  Created by Admin on 12/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

class Reqcell: UITableViewCell {
    @IBOutlet var lblYear : UILabel!
    @IBOutlet var lblModelName : UILabel!
    @IBOutlet var lblKm : UILabel!
    @IBOutlet var lblAdd : UILabel!
    @IBOutlet var lblRupees : UILabel!
    @IBOutlet var lblOwner : UILabel!
    @IBOutlet var lblDate : UILabel!
    @IBOutlet var imgView : UIImageView!
}

class OfferReqReceivedController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var spinner : UIActivityIndicatorView!
    @IBOutlet var tblData : UITableView!
    var arrData : NSMutableArray = NSMutableArray()
    @IBOutlet var viewError404 : UIView!
    var pageInd : Int = 1
    var isAPICalled = true

    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.viewError404.isHidden = true
        tblData.estimatedRowHeight = 126
        tblData.rowHeight = UITableViewAutomaticDimension
        
        self.getOfferRequest()
        AppUtilities.sharedInstance.AppEvents(view: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic : NSDictionary = arrData.object(at: indexPath.row) as! NSDictionary
        let cell : Reqcell = tableView.dequeueReusableCell(withIdentifier: "Reqcell") as! Reqcell
        cell.lblAdd.text = dic["pincode"] as? String ?? ""
        cell.lblKm.text = dic["mileage"] as? String ?? ""
        cell.lblYear.text = dic["v_year"] as? String ?? ""
        cell.lblOwner.text = "By \(dic["fullname"] as? String ?? "")"
//        cell.lblRupees.text = "0"
        cell.lblRupees.text = dic["v_price"] as? String ?? "Not Available"
//        cell.lblModelName.text = dic["v_name"] as? String ?? ""
        cell.lblModelName.text = "\(dic["make"] as? String ?? "") \(dic["v_model"] as? String ?? "")"
        cell.lblDate.text = dic["creation_datetime"] as? String ?? ""
        if let arrImages = dic.value(forKey: "vimages") as? NSArray
        {
            if arrImages.count>0{
                let linkImage = arrImages[0] as? String ?? ""
                cell.imgView.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: ""))
            }
        }
      //  cell.imgView.sd_setImage(with: URL.init(string: dic["profilepic"] as! String), placeholderImage:UIImage.init(named: "default_tig_pic"))

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc : VehicleDetailsController = self.storyboard?.instantiateViewController(withIdentifier: "VehicleDetailsController") as! VehicleDetailsController
        vc.userDic = arrData.object(at: indexPath.row) as! NSDictionary
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if isAPICalled == false{
            let lastRow = tableView.numberOfRows(inSection: 0)

        if indexPath.row == lastRow - 1 {
            spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            tableView.tableFooterView = spinner
            tableView.tableFooterView?.isHidden = false
            pageInd = pageInd + 1
            self.getOfferRequest()
        }
        }
    }
    
   
    
    //MARK: - Button All Action
    
    @IBAction func clkBack(sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Get Offer Request
    func getOfferRequest()
    {
        self.isAPICalled = true

        self.view.endEditing(true)
        
        //AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "GetCustomerOffer",
            "request" : [
                "pageindex": pageInd
            ],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                self.isAPICalled = false
                if self.spinner != nil{
                    self.spinner.stopAnimating()
                    
                }

                //AppUtilities.sharedInstance.hideLoader()
                self.tblData.tableFooterView = nil
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
                                    if arr.count == 0 ||  arr.count < 10 {
                                        self.isAPICalled = true
                                    }
                                    self.arrData.addObjects(from: (responseDic.value(forKey: "data") as! NSArray) as! [Any])
                                    self.tblData.reloadData()
                                }
                            }
                            else{
//                                if let errorMsg = responseDic.value(forKey: "msg") as? String{
//                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
//                                }
                            }
                            self.tblData.isHidden = false
                            
                            if self.arrData.count == 0 {
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
//                        AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "\(object.value(forKey: "message") as? String ?? "" )" as NSString)
                        
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
