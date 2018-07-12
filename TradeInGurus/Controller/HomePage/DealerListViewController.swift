//
//  DealerListViewController.swift
//  TradeInGurus
//
//  Created by Admin on 12/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

class DealerListTableViewCell:UITableViewCell
{
    @IBOutlet weak var lblDealerName: UILabel!
    @IBOutlet weak var lblDealerNumber: UILabel!
    @IBOutlet weak var lblDealerMobile: UILabel!
    @IBOutlet weak var lblDealerAddress: UILabel!
}


class DealerListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tblViewDealear: UITableView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearchByLocation: UITextField!
    @IBOutlet weak var txtSearchByZipcode: UITextField!
    @IBOutlet weak var viewSearchByLocation: UIView!
    @IBOutlet weak var viewSearchByDealer: UIView!
    @IBOutlet weak var viewSearchByZipcode: UIView!
    
    @IBOutlet weak var txtSearchByDealer: UITextField!
    @IBOutlet var spinner : UIActivityIndicatorView!
    
    var arrDealers = NSMutableArray()
    var PageInd : Int = 1
    var isAPICalled = true
    var srchLatitude = ""
    var srchLongtiude = ""
    var isSearch = false
    var isSelect = false
    //MARK: - UIView Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tblViewDealear.rowHeight = UITableViewAutomaticDimension
        tblViewDealear.estimatedRowHeight = 30
        setCorner(viewSearchByLocation)
        setCorner(viewSearchByDealer)
        setCorner(viewSearchByZipcode)
        self.txtSearchByDealer.addTarget(self, action: #selector(didChange(textFiled:)), for: .editingChanged)
        self.txtSearchByZipcode.addTarget(self, action: #selector(didChange(textFiled:)), for: .editingChanged)
        self.txtSearchByLocation.addTarget(self, action: #selector(didChange(textFiled:)), for: .editingChanged)
        txtSearchByLocation.clearButtonMode = .unlessEditing
        AppUtilities.sharedInstance.showLoader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "IsLocation") {
            UserDefaults.standard.set(false, forKey: "IsLocation")
            txtSearchByLocation.text = UserDefaults.standard.value(forKey: "Location") as? String
            srchLatitude = UserDefaults.standard.value(forKey: "Latitude") as! String
            
            srchLongtiude = UserDefaults.standard.value(forKey: "Longitude") as! String
            arrDealers.removeAllObjects()
            searchDealer(text: txtSearchByDealer.text!)
            PageInd = 1
        }
        else {
            txtSearchByDealer.text = ""
            txtSearchByZipcode.text = ""
            txtSearchByLocation.text = ""
            PageInd = 1
            isSearch = false
            arrDealers.removeAllObjects()
            self.lblTitle.text = "TOTAL DEALERS - \(self.arrDealers.count)"
            tblViewDealear.reloadData()
            srchLatitude = "\(GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.latitude ?? 00)"
            
            srchLongtiude =  "\(GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.longitude ?? 00)"
            nearDealer()
        }
    }
    
    
    
    //MARK: - Text Filed Delegate -
    
    func didChange(textFiled: UITextField)
    {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchByDealer), object: nil)
        self.perform(#selector(searchByDealer), with: nil, afterDelay: 0.5)
    }
    
    func searchByDealer()
    {
        arrDealers.removeAllObjects()
        tblViewDealear.reloadData()
        self.lblTitle.text = "TOTAL DEALERS - \(self.arrDealers.count)"
        if txtSearchByDealer.text != "" || txtSearchByZipcode.text != "" {
            isSearch = true
            searchDealer(text: txtSearchByDealer.text!)
        }
        else {
            isSearch = false
            PageInd = 1
            nearDealer()
        }
    }
    
    
    //MARK: - All UIButton actions -
    @IBAction func btnBackPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLocationClk(_ sender: UIButton) {
        let check = self.storyboard?.instantiateViewController(withIdentifier: "CheckinpageViewController") as! CheckinpageViewController
        self.navigationController?.pushViewController(check, animated: true)
    }
    
    @IBAction func btnSelectDelear (_ sender: UIButton) {
        
        
        
    }
    
    //MARK: - Other
    
    
    func setCorner(_ viewC : UIView)
    {
        viewC.layer.cornerRadius = 5.0
        viewC.clipsToBounds = true
    }
    
    
    //MARK:- API -
    
    func nearDealer()
    {
        self.view.endEditing(true)
        isAPICalled = true
        
        let dictionaryParams : NSDictionary = [
            "service": "NearDealer",
            "request" : [
                "data": [
                    "user_lat":srchLatitude,
                    "user_long": srchLongtiude,
                    "username":txtSearchByDealer.text!,
                    "distance": 1000,
                    "pageindex":PageInd
                ]],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                AppUtilities.sharedInstance.hideLoader()
                self.tblViewDealear.tableFooterView = nil
                
                if self.spinner != nil{
                    self.spinner.stopAnimating()
                    
                }
                
                if let object = object as? NSDictionary
                {
                    if  (object.value(forKey: "success") as? Bool) != nil
                    {
                        self.isAPICalled = false
                        
                        let responseDic = object
                        //                        debugPrint(responseDic)
                        if let status = responseDic.value(forKey: "success") as? Int
                        {
                            if(status == 1)
                            {
                                
                                if let arr = responseDic.value(forKey: "data") as? NSArray
                                {
                                    //                                    if arr.count == 0 || arr.count < 10{
                                    //                                        self.isAPICalled = true
                                    //                                    }
                                    self.arrDealers.addObjects(from: NSMutableArray(array: arr) as! [Any])
                                    self.tblViewDealear.reloadData()
                                    self.lblTitle.text = "TOTAL DEALERS - \(self.arrDealers.count)"
                                }
                            }
                            else{
                                self.isAPICalled = true
                                
                                //                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                //                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                //                                }
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
    
    func searchDealer(text: String)
    {
        isAPICalled = true
        //AppUtilities.sharedInstance.showLoader()
        
        var lat = ""
        var long = ""
        
        if txtSearchByLocation.text != "" {
            lat = srchLatitude
            long = srchLongtiude
        }
        
        
        let dictionaryParams : NSDictionary = [
            "service": "Searchdealer",
            "request" : [
                "data": [
                    "user_lat":lat,
                    "user_long":long,
                    "search_text":text,
                    "distance": 1000,
                    "zipcode" : txtSearchByZipcode.text!
                ]],
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                AppUtilities.sharedInstance.hideLoader()
                self.tblViewDealear.tableFooterView = nil
                
                if self.spinner != nil{
                    self.spinner.stopAnimating()
                }
                
                if let object = object as? NSDictionary
                {
                    if  (object.value(forKey: "success") as? Bool) != nil
                    {
                        self.isAPICalled = false
                        
                        let responseDic = object
                        //                        debugPrint(responseDic)
                        if let status = responseDic.value(forKey: "success") as? Int
                        {
                            if(status == 1)
                            {
                                if let arr = responseDic.value(forKey: "data") as? NSArray
                                {
                                    //                                    if arr.count == 0 || arr.count < 10{
                                    self.isAPICalled = true
                                    //                                    }
                                    self.arrDealers = NSMutableArray(array: arr)
                                    self.tblViewDealear.reloadData()
                                    self.lblTitle.text = "TOTAL DEALERS - \(self.arrDealers.count)"
                                    if self.arrDealers.count > 0 {
                                        self.tblViewDealear.isHidden = false
                                    }
                                    else {
                                        self.tblViewDealear.isHidden = true
                                    }
                                }
                                else {
                                }
                            }
                            else{
                                self.isAPICalled = true
                                self.tblViewDealear.isHidden = true
                                //                                AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: "\(object.value(forKey: "message") as? String ?? "" )" as NSString)
                                // Jignesh
                                //                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                //                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                //                                }
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
    
    //MARK: - Table View Method -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrDealers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellDealer") as! DealerListTableViewCell
        setCorner(tableViewCell)
        
        let dictDealer = arrDealers.object(at: indexPath.section) as? NSDictionary
        tableViewCell.lblDealerName.text = dictDealer?.value(forKey: "fullname") as? String ?? ""
        tableViewCell.lblDealerMobile.text = "Mo : " + "\(dictDealer?.value(forKey: "mobile") as? String ?? "")"
        tableViewCell.lblDealerAddress.text = dictDealer?.value(forKey: "address") as? String ?? ""
        tableViewCell.lblDealerNumber.text = " • "
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
        let dictConsumer = arrDealers.object(at: indexPath.section) as! NSDictionary
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        /*if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "DealersDetailViewController") as? DealersDetailViewController{
         vc.dict = dictConsumer
         self.navigationController?.pushViewController(vc, animated: true)
         }*/
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "DealerInfoViewController") as? DealerInfoViewController{
            vc.dictData = dictConsumer
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
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
                if isSearch == false {
                    nearDealer()
                }
            }
        }
    }
    
    //MARK: - Text Field Delegate Method -
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        if textField == txtSearchByLocation {
            txtSearchByLocation.text = ""
            self.PageInd = 1
            srchLatitude = "\(GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.latitude ?? 00)"
            
            srchLongtiude =  "\(GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.longitude ?? 00)"
            nearDealer()
        }
        return false
    }
    
    
    //MARK: - Memory Managememt -
    
    
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

