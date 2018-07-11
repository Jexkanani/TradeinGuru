//
//  OffersListViewController.swift
//  TradeInGurus
//
//  Created by Admin on 13/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

extension UIImageView{
    
    func setImageFromURl(stringImageUrl url: String){
        
        if let url = NSURL(string: url) {
            if let data = NSData(contentsOf: url as URL) {
                self.image = UIImage(data: data as Data)
            }
        }
    }
}



extension UIButton {
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 1.0
        pulse.fromValue = 0.9
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 500
        pulse.initialVelocity = 0
        pulse.speed = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
}
class OffersListTableViewCell:UITableViewCell
{
    @IBOutlet weak var lblOfferName: UILabel!
    @IBOutlet weak var lblOfferNumber: UILabel!
    @IBOutlet weak var lblOfferMobile: UILabel!
    @IBOutlet weak var lblOfferAddress: UILabel!
    @IBOutlet weak var lblOfferdatetime: UILabel!
    @IBOutlet weak var lblOpen: UILabel!
    @IBOutlet weak var lblClosed: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!


}

class OffersListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tblViewOFfer: UITableView!
    var arrOffers = NSMutableArray()
    @IBOutlet weak var viewError: UIView!
    @IBOutlet weak var btnAdd: UIButton!
    var PageInd : Int = 1
    var isAPICalled = true
    @IBOutlet var spinner : UIActivityIndicatorView!

    
    //MARK: - UIView Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()

        getCustomerOffer()
        tblViewOFfer.rowHeight = UITableViewAutomaticDimension
        tblViewOFfer.estimatedRowHeight = 90
        viewError.isHidden = true
        btnAdd.pulsate()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "isAddUpdate"){
                PageInd = 1
                arrOffers.removeAllObjects()
                self.tblViewOFfer.reloadData()
                UserDefaults.standard.set(false, forKey: "isAddUpdate")
                getCustomerOffer()

        }
    }
    //MARK: - Other
    
    
    func setCorner(_ viewC : UIView)
    {
        viewC.layer.cornerRadius = 5.0
        viewC.clipsToBounds = true
    }
    
    
    //MARK:- API -
    
    func getCustomerOffer()
    {
        
        self.view.endEditing(true)
        self.isAPICalled = true

        AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "GetMYOffer",
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
                self.tblViewOFfer.tableFooterView = nil

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
                                    self.tblViewOFfer.reloadData()
                                    
                                }
                            }
                            else{
                                self.isAPICalled = true
//                                if let errorMsg = responseDic.value(forKey: "message") as? String{
//                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
//                                }
                            }
                            
                            self.tblViewOFfer.isHidden = false
                            self.viewError.isHidden = true
                            
                            if self.arrOffers.count == 0{
                                self.viewError.isHidden = false
                                self.tblViewOFfer.isHidden = true
                                
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
    
    func deleteCustomerOffer(_ index: Int)
    {
       
        
        let dictDealer = arrOffers.object(at: index) as! NSDictionary
        let deal_id = dictDealer.value(forKey: "id") as? String ?? "1"
        
        self.view.endEditing(true)
        
        AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "deleteOffer",
            "request" : [
                "offerid":deal_id
                
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
                                    self.arrOffers.removeObject(at: index)
                                    self.tblViewOFfer.reloadData()
                            }
                            else{
                                //                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                //                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                //                                }
                            }
                            
                            self.tblViewOFfer.isHidden = false
                            self.viewError.isHidden = true
                            
                            if self.arrOffers.count == 0{
                                self.viewError.isHidden = false
                                self.tblViewOFfer.isHidden = true
                                
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
    

    
    //MARK:- UITableview Delegate Methods -
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrOffers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellOffer") as! OffersListTableViewCell
        setCorner(tableViewCell)
        
        let dictDealer = arrOffers.object(at: indexPath.section) as?
        NSDictionary
        tableViewCell.lblOfferName.text = dictDealer?["v_name"] as? String ?? ""
//        tableViewCell.lblOfferMobile.text = "Mo : " + "\(dictDealer?["phone"] as? String ?? "")"
        tableViewCell.lblOfferMobile.text = "Make : " + "\(dictDealer?["make"] as? String ?? "")"
        tableViewCell.lblOfferAddress.text = dictDealer?["address"] as? String ?? ""
        tableViewCell.lblOfferdatetime.text = "Date : " + "\(dictDealer?["creation_datetime"] as? String ?? "")"
//        tableViewCell.lblOfferNumber.text = "#\(indexPath.section + 1)"
        tableViewCell.lblOfferNumber.text = " • "
        tableViewCell.lblClosed.isHidden = true
        tableViewCell.lblOpen.isHidden = true
        if dictDealer?.value(forKey: "is_open") as? String == "1"{
            tableViewCell.lblClosed.isHidden = false

        }
        else{
            tableViewCell.lblOpen.isHidden = false

        }
        tableViewCell.btnEdit.tag = indexPath.section
        tableViewCell.btnDelete.tag = indexPath.section
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
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        /*let dictConsumer = arrOffers.object(at: indexPath.section) as! NSDictionary
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "DealersDetailViewController") as? DealersDetailViewController{
            vc.dict = dictConsumer
            self.navigationController?.pushViewController(vc, animated: true)
            
        }*/
        
        let dictDealer = arrOffers.object(at: indexPath.section) as! NSDictionary
        var arrLinks = ["","",""]
        if let arrImages = dictDealer.value(forKey: "images") as? NSArray{
            if arrImages.count > 3 {
                for i in 0..<arrLinks.count
                {
                    let strLink = arrImages[i] as! String
                    arrLinks.remove(at: i)
                    arrLinks.insert(strLink, at: i)
                }
                
            }
            else {
                for i in 0..<arrImages.count
                {
                    let strLink = arrImages[i] as! String
                    arrLinks.remove(at: i)
                    arrLinks.insert(strLink, at: i)
                }
                
            }
        }
        debugPrint(arrLinks)
        let dictOffer = NSMutableDictionary()
        let mileage = dictDealer.value(forKey: "mileage") as? String ?? "1"
        let make = dictDealer.value(forKey: "make") as? String ?? "1"
        let v_model = dictDealer.value(forKey: "v_model") as? String ?? "1"
        let v_name = dictDealer.value(forKey: "v_name") as? String ?? "1"
        let vin = dictDealer.value(forKey: "v_number") as? String ?? "1"
        let v_year = dictDealer.value(forKey: "v_year") as? String ?? "1"
        let pincode = dictDealer.value(forKey: "zipcode") as? String ?? "1"
        let phone1 = dictDealer.value(forKey: "phone") as? String ?? "1"
        let email = dictDealer.value(forKey: "email") as? String ?? "1"
        let is_open = dictDealer.value(forKey: "is_open") as? String ?? "0"
        let vid = dictDealer.value(forKey: "id") as? String ?? "0"
        let vPrice = dictDealer.value(forKey: "v_price") as? String ?? "0"
        let arrDealerID = dictDealer.value(forKey: "dealersdata") as? NSArray
        let desc = dictDealer.value(forKey: "description") as? String ?? ""
        
        dictOffer.setValue([UIImage(named:"placeholder"),UIImage(named:"placeholder"),UIImage(named:"placeholder")], forKey: "images")
        
        dictOffer.setValue(arrLinks, forKey: "imagesL")
        dictOffer.setValue(vin, forKey: "VIN")
        dictOffer.setValue(v_year, forKey: "year")
        dictOffer.setValue(make, forKey: "make")
        dictOffer.setValue(v_model, forKey: "model")
        dictOffer.setValue(mileage, forKey: "mileage")
        dictOffer.setValue(v_name, forKey: "name")
        dictOffer.setValue(phone1, forKey: "phone")
        dictOffer.setValue(email, forKey: "email")
        dictOffer.setValue(pincode, forKey: "zipcode")
        dictOffer.setValue(is_open, forKey: "is_open")
        dictOffer.setValue("0", forKey: "is_pop_open")
        dictOffer.setValue(vid, forKey: "vid")
        dictOffer.setValue(arrDealerID, forKey: "dealersdata")
        dictOffer.setValue(desc, forKey: "description")
        dictOffer.setValue(vPrice, forKey: "v_price")
        debugPrint(dictOffer)
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "OfferRequestViewController") as? OfferRequestViewController {
            vc.dictDealer = dictOffer
            vc.dictDealerChat = ((arrDealerID)?.object(at: 0)) as! NSDictionary
            vc.isEdit = true
            vc.isViewInfo = "3"
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
                getCustomerOffer()
            }
        }
        
    }
    //MARK: - UIButton Action Methods -

    @IBAction func btnEditPressed(_ sender: UIButton) {
        
       
        let dictDealer = arrOffers.object(at: sender.tag) as! NSDictionary
        var arrLinks = ["","",""]
        if let arrImages = dictDealer.value(forKey: "images") as? NSArray{
            if arrImages.count > 3 {
                for i in 0..<arrLinks.count
                {
                    let strLink = arrImages[i] as! String
                    arrLinks.remove(at: i)
                    arrLinks.insert(strLink, at: i)
                }

            }
            else {
                for i in 0..<arrImages.count
                {
                    let strLink = arrImages[i] as! String
                    arrLinks.remove(at: i)
                    arrLinks.insert(strLink, at: i)
                }
            }
        }
        debugPrint(arrLinks)
        let dictOffer = NSMutableDictionary()
        let mileage = dictDealer.value(forKey: "mileage") as? String ?? "1"
        let make = dictDealer.value(forKey: "make") as? String ?? "1"
        let v_model = dictDealer.value(forKey: "v_model") as? String ?? "1"
        let v_name = dictDealer.value(forKey: "v_name") as? String ?? "1"
        let vin = dictDealer.value(forKey: "v_number") as? String ?? "1"
        let v_year = dictDealer.value(forKey: "v_year") as? String ?? "1"
        let pincode = dictDealer.value(forKey: "zipcode") as? String ?? "1"
        let phone1 = dictDealer.value(forKey: "phone") as? String ?? "1"
        let email = dictDealer.value(forKey: "email") as? String ?? "1"
        let is_open = dictDealer.value(forKey: "is_open") as? String ?? "0"
        let vid = dictDealer.value(forKey: "id") as? String ?? "0"
        let vPrice = dictDealer.value(forKey: "v_price") as? String ?? "0"
        let arrDealerID = dictDealer.value(forKey: "dealersdata") as? NSArray
        let desc = dictDealer.value(forKey: "description") as? String ?? ""
        
        dictOffer.setValue([UIImage(named:"placeholder"),UIImage(named:"placeholder"),UIImage(named:"placeholder")], forKey: "images")

        dictOffer.setValue(arrLinks, forKey: "imagesL")
        dictOffer.setValue(vin, forKey: "VIN")
        dictOffer.setValue(v_year, forKey: "year")
        dictOffer.setValue(make, forKey: "make")
        dictOffer.setValue(v_model, forKey: "model")
        dictOffer.setValue(mileage, forKey: "mileage")
        dictOffer.setValue(v_name, forKey: "name")
        dictOffer.setValue(phone1, forKey: "phone")
        dictOffer.setValue(email, forKey: "email")
        dictOffer.setValue(pincode, forKey: "zipcode")
        dictOffer.setValue(is_open, forKey: "is_open")
        dictOffer.setValue("0", forKey: "is_pop_open")
        dictOffer.setValue(vid, forKey: "vid")
        dictOffer.setValue(arrDealerID, forKey: "dealersdata")
        dictOffer.setValue(desc, forKey: "description")
        dictOffer.setValue(vPrice, forKey: "v_price")
        debugPrint(dictOffer)
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "OfferRequestViewController") as? OfferRequestViewController{
            vc.dictDealer = dictOffer
            vc.isEdit = true

            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @IBAction func btnDeletePressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure that you want to delete offer?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.deleteCustomerOffer(sender.tag)
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func btnAddPressed(_ sender: Any) {
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "OfferRequestViewController") as? OfferRequestViewController{
            self.navigationController?.pushViewController(vc, animated: true)
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
