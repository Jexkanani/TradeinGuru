//
//  DealerInfoViewController.swift
//  TradeInGurus
//
//  Created by Admin on 20/04/18.
//  Copyright © 2018 cearsinfotech. All rights reserved.
//

import UIKit

class DealerInfoTableViewCell:UITableViewCell
{
    @IBOutlet weak var lblDealerImg: UIImageView!
    @IBOutlet weak var lblDealerName: UILabel!
    @IBOutlet weak var lblDealerMobile: UILabel!
    @IBOutlet weak var lblDealerEmail: UILabel!
    @IBOutlet weak var lblDealerAddress: UILabel!
    @IBOutlet weak var lblDealerCity: UILabel!
    @IBOutlet weak var lblDealerState: UILabel!
    @IBOutlet weak var lblDealerCountry: UILabel!
    @IBOutlet weak var lblDealerPincode: UILabel!
    @IBOutlet weak var btnEditHeight : NSLayoutConstraint!
    @IBOutlet weak var btnDeleteHeight : NSLayoutConstraint!
}

class DealerInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tblViewDealear: UITableView!
    @IBOutlet var spinner : UIActivityIndicatorView!
//    var arrDealers = NSMutableArray()
    var dictData = NSDictionary()
    var arrOffers = NSMutableArray()
    var PageInd : Int = 1
    var isAPICalled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblViewDealear.rowHeight = UITableViewAutomaticDimension
        tblViewDealear.estimatedRowHeight = 290
        getDealerOffer()
        AppUtilities.sharedInstance.AppEvents(view: self)
    }

    //MARK: - All UIButton actions -
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Table View Method -
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "DealerInfoTableViewCell") as! DealerInfoTableViewCell
            
            let linkImage = self.dictData.value(forKey: "profilepic") as? String ?? ""
            tableViewCell.lblDealerImg.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: "placeholder"))
            tableViewCell.lblDealerName.text = self.dictData.value(forKey: "fullname") as? String ?? "Not Available"
            tableViewCell.lblDealerMobile.text = self.dictData.value(forKey: "mobile") as? String ?? "Not Available"
            tableViewCell.lblDealerEmail.text = self.dictData.value(forKey: "email") as? String ?? "Not Available"
            tableViewCell.lblDealerAddress.text = self.dictData.value(forKey: "address") as? String ?? "Not Available"
            tableViewCell.lblDealerCity.text = self.dictData.value(forKey: "city") as? String ?? "Not Available"
            tableViewCell.lblDealerState.text = self.dictData.value(forKey: "statename") as? String ?? "Not Available"
            tableViewCell.lblDealerCountry.text = self.dictData.value(forKey: "county") as? String ?? "Not Available"
            tableViewCell.lblDealerPincode.text = self.dictData.value(forKey: "pincode") as? String ?? "Not Available"
            return tableViewCell
        } else {
            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellOffer1") as! OffersListTableViewCell
            setCorner(tableViewCell)
            
            let dictDealer = arrOffers.object(at: indexPath.row) as?NSDictionary
            tableViewCell.lblOfferName.text = dictDealer?["v_name"] as? String ?? ""
            tableViewCell.lblOfferMobile.text =  "Make : " + "\(dictDealer?["v_model"] as? String ?? "")" //make
            tableViewCell.lblOfferAddress.text = "Address : " + "\(dictDealer?["address"] as? String ?? "")"
            tableViewCell.lblOfferdatetime.text = "Date : " + "\(dictDealer?["creation_datetime"] as? String ?? "")"
//            tableViewCell.lblOfferNumber.text = " • "
            
            if let arrImages = dictDealer?["vimages"] as? NSArray
            {
                if arrImages.count>0 {
                    let linkImage = arrImages[0] as? String ?? ""
                    tableViewCell.img.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: "default_tig_pic"))
                } else {
                    let linkImage = ""
                    tableViewCell.img.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: "default_tig_pic"))
                }
            }
            
            tableViewCell.lblClosed.isHidden = true
            tableViewCell.lblOpen.isHidden = true
            if dictDealer?.value(forKey: "is_open") as? String == "1" {
                tableViewCell.lblClosed.isHidden = false
            }
            else{
                tableViewCell.lblOpen.isHidden = false
            }
            tableViewCell.btnEdit.tag = indexPath.section
            tableViewCell.btnDelete.tag = indexPath.section
            tableViewCell.btnEdit.isHidden = true
//            tableViewCell.btnEdit.
            tableViewCell.btnDelete.isHidden = true
            return tableViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return arrOffers.count
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        if indexPath.section == 0 {
//            return 290.0
//        } else {
//            return 190.0
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        viewFooter.backgroundColor = UIColor.clear
        return viewFooter
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dictConsumer : NSDictionary = NSDictionary()
        dictConsumer = (arrOffers.object(at: indexPath.row) as? NSDictionary)!
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "VehicleDetailViewController") as? VehicleDetailViewController
        {
            vc.dictVehicle = dictConsumer
            vc.bDealerProfile = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {

    }
    
    //MARK:- API -
    func getDealerOffer()
    {
        
        self.view.endEditing(true)
        self.isAPICalled = true
        
        AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "GetOfferDealer",
            "request" : [
                "pageindex":PageInd,
                "dealer_id":self.dictData.object(forKey: "deal_id") as! String
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
                self.tblViewDealear.tableFooterView = nil
                
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
                                    
                                    if self.PageInd > 1 {
                                        self.arrOffers.addObjects(from: arr  as! [Any])
                                    }
                                    else {
                                        self.arrOffers = NSMutableArray(array: arr)
                                        
                                    }
                                    debugPrint(self.arrOffers)
                                    self.tblViewDealear.reloadData()
                                    
                                }
                            }
                            else{
                                self.isAPICalled = true
                                //                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                //                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                //                                }
                            }
                            
//                            self.tblViewOFfer.isHidden = false
//                            self.viewError.isHidden = true
                            
                            if self.arrOffers.count == 0{
//                                self.viewError.isHidden = false
//                                self.tblViewDealear.isHidden = true
                                
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
    
    //MARK: - Other
    
    
    func setCorner(_ viewC : UIView)
    {
        viewC.layer.cornerRadius = 5.0
        viewC.clipsToBounds = true
    }
}
