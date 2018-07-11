//
//  DealersDetailViewController.swift
//  TradeInGurus
//
//  Created by Admin on 13/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

class DealersDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var imageVehicle: UIImageView!
    
    
}

class DealersDetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewError404: UIView!
    @IBOutlet weak var tblViewDealerDetail: UITableView!
    @IBOutlet var spinner : UIActivityIndicatorView!
    
    var arrDealers = NSMutableArray()
    var dict = NSDictionary()
    var PageInd : Int = 1
    var isAPICalled = true
    var isInterset = false
   

    //MARK: - UIView Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text =  dict["fullname"] as? String ?? ""
        viewError404.isHidden = true
        getDealersVehicle()
    }
    
    
    //MARK: - UIButton Action Methods -
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    //MARK: - Other
    
    
    func setCorner(_ viewC : UIView)
    {
        viewC.layer.cornerRadius = 5.0
        viewC.clipsToBounds = true
    }
    
    //MARK: - UITableView Datasource Delegate -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrDealers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellDealer") as! DealersDetailTableViewCell
        setCorner(tableViewCell)
        let dictConsumer = arrDealers.object(at: indexPath.section) as! NSDictionary
        tableViewCell.lblName.text = dictConsumer["v_name"] as? String ?? ""
        tableViewCell.lblAddress.text = dictConsumer["address"] as? String ?? ""
        tableViewCell.lblPrice.text = dictConsumer["v_price"] as? String ?? ""
        tableViewCell.lblDistance.text = dictConsumer["mileage"] as? String ?? ""
        tableViewCell.lblYear.text = dictConsumer["v_year"] as? String ?? ""
        
        if let arrImages = dictConsumer.value(forKey: "vimages") as? NSArray
        {
            if arrImages.count>0{
                let linkImage = arrImages[0] as? String ?? ""
                tableViewCell.imageVehicle.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: ""))
            }
        }
        
        return tableViewCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        viewFooter.backgroundColor = UIColor.clear
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dictConsumer = arrDealers.object(at: indexPath.section) as! NSDictionary
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "VehicleDetailViewController") as? VehicleDetailViewController
        {
            vc.dictVehicle = dictConsumer
            self.navigationController?.pushViewController(vc, animated: true)
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
                getDealersVehicle()
            }
        }
        
        
        
        
    }
    
    
    
    func getDealersVehicle()
    {
        self.view.endEditing(true)
        isAPICalled = true
        AppUtilities.sharedInstance.showLoader()
       
        debugPrint(dict)
        var dealerID = String()
        if isInterset == true {
            dealerID = dict.value(forKey: "deal_id") as? String ?? "0"
        } else {
             dealerID = dict.value(forKey: "user_id") as? String ?? "0"
        }
        
        
        let dictionaryParams : NSDictionary = [
            "service": "GetDealersVehicle",
            "request" : [
                
                    "dealerid": dealerID,
                    "pageindex": PageInd
                    
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
                self.tblViewDealerDetail.tableFooterView = nil

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
                                    if arr.count == 0 ||  arr.count < 10{
                                        self.isAPICalled = true
                                    }
                                    self.arrDealers.addObjects(from: NSMutableArray(array: arr) as! [Any])
                                    self.tblViewDealerDetail.reloadData()
                                    
                                }
                                
                            }
                            else{
//                                if let errorMsg = responseDic.value(forKey: "message") as? String{
//                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
//                                }
                            }
                            
                            self.tblViewDealerDetail.isHidden = false

                            if self.arrDealers.count == 0{
                                self.viewError404.isHidden = false
                                self.tblViewDealerDetail.isHidden = true

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
