//
//  Listings.swift
//  TradeInGurus
//
//  Created by Admin on 02/05/18.
//  Copyright © 2018 cearsinfotech. All rights reserved.
//

import UIKit
import SDWebImage
import Crashlytics

class ListTableViewCell: UITableViewCell
{
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblInterseted: UILabel!
    @IBOutlet weak var lblBy: UILabel!
    @IBOutlet weak var imageVehicle: UIImageView!
    @IBOutlet var btnMore: UIButton!
    
}

class Listings: UIViewController,SWRevealViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate  {

    //Dealer
    
    @IBOutlet weak var viewDPostNew: UIView!
    @IBOutlet weak var viewReceivedRequests: UIView!
    @IBOutlet weak var tblViewDealear: UITableView!
    @IBOutlet weak var viewDelears: UIView!
    var arrVehicle = NSMutableArray()
    let userType = AppUtilities.sharedInstance.getLoginUserType()
    var PageInd : Int = 1
    @IBOutlet var spinner : UIActivityIndicatorView!
    let refreshControlDealer = UIRefreshControl()
    
    var isAPICalled = true
    
    var is_searching : Bool = false
    var arrSearchedVehical : NSMutableArray = NSMutableArray()
    
    //MARK: - UIView Life Cycle-
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Crashlytics.sharedInstance().crash()
        
        if isBackground == false {
            AppApi.sharedInstance.notifiCount()
            
        }
        
        let dict = AppUtilities.sharedInstance.getLoginDict()
        debugPrint(dict)
        GetCurrentLocation.sharedObject.updateCurrentLocation()
//        viewDelears.isHidden = true
//        viewCustomers.isHidden = false
//        lblBuyerNotification.isHidden = true
//        setCorner(viewOffers)
//        setCorner(viewPostNew)
//        setCorner(viewDPostNew)
//        setCorner(viewAllDealers)
//        setCorner(viewMyInterests)
//        setCorner(viewReceivedRequests)
        tblViewDealear.addSubview(refreshControlDealer)
//        tblViewConsumer.addSubview(refreshControlCustomer)
        refreshControlDealer.addTarget(self, action: #selector(refreshDealerData), for: .valueChanged)
        

        if userType == "dealer"{
//            viewDelears.isHidden = false
//            viewCustomers.isHidden = true
//            lblBuyerNotification.isHidden = false
            getDealersVehicle()
//            searchBar_De.isHidden = false
        }
        
//        self.revealViewController().panGestureRecognizer()
//        self.revealViewController().tapGestureRecognizer()
//        self.revealViewController().delegate = self
        isBackground = false
        
    }
    
    func refreshDealerData()   {
        refreshControlDealer.beginRefreshing()
        PageInd = 1
        if userType == "dealer"{
            getDealersVehicle()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblViewDealear.isHidden = true
        if UserDefaults.standard.bool(forKey: "IsRefresh"){
            UserDefaults.standard.set(false, forKey: "IsRefresh")
            PageInd = 1
            if userType == "dealer"{
                self.arrVehicle.removeAllObjects()
                getDealersVehicle()
            }
        } else {
            self.PageInd = 1
            if userType == "dealer"{
                self.arrVehicle.removeAllObjects()
                self.tblViewDealear.reloadData()
                getDealersVehicle()
            }
        }
    }
    
    //MARK: - Other
    
    func setCorner(_ viewC : UIView)
    {
        viewC.layer.cornerRadius = 5.0
        viewC.clipsToBounds = true
    }
    
    //MARK: - UITableView Datasource Delegate -
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if is_searching{
            return arrSearchedVehical.count
        } else {
            return arrVehicle.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if userType == "dealer"
        {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            
            var dictConsumer : NSDictionary = NSDictionary()
            if is_searching
            {
                dictConsumer = arrSearchedVehical.object(at: indexPath.section) as! NSDictionary
            }
            else
            {
                dictConsumer = arrVehicle.object(at: indexPath.section) as! NSDictionary
            }
            
            if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "BuyerNotiDetailViewController") as? BuyerNotiDetailViewController{
                if let interestCustomer = dictConsumer.value(forKey: "totarequests") as? String{
                    if interestCustomer != "0"
                    {
                        vc.arrDic = dictConsumer
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else
                {
                    vc.arrDic = dictConsumer
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
//        else
//        {
//            var dictConsumer : NSDictionary = NSDictionary()
//            if is_searching
//            {
//                dictConsumer = arrSearchedVehical.object(at: indexPath.section) as! NSDictionary
//            }
//            else
//            {
//                dictConsumer = arrVehicle.object(at: indexPath.section) as! NSDictionary
//            }
//            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//            if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "VehicleDetailViewController") as? VehicleDetailViewController
//            {
//                vc.dictVehicle = dictConsumer
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell
    {
//        if userType == "dealer"
//        {
            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell") as! ListTableViewCell
            setCorner(tableViewCell)
            
            var dictConsumer : NSDictionary = NSDictionary()
            if is_searching
            {
                dictConsumer = arrSearchedVehical.object(at: indexPath.section) as! NSDictionary
            }
            else
            {
                dictConsumer = arrVehicle.object(at: indexPath.section) as! NSDictionary
            }
            
            tableViewCell.lblTitle.text = dictConsumer["v_make"] as? String ?? ""
            tableViewCell.lblPrice.text = dictConsumer["v_price"] as? String ?? ""
            tableViewCell.lblDistance.text = dictConsumer["mileage"] as? String ?? ""
            tableViewCell.lblYear.text = dictConsumer["v_year"] as? String ?? ""
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
            let underlineAttributedString = NSAttributedString(string: "\(dictConsumer["totarequests"] as? String ?? "0") Customer Are Interested", attributes: underlineAttribute)
            tableViewCell.lblInterseted.attributedText = underlineAttributedString
            
            if let arrImages = dictConsumer.value(forKey: "vimages") as? NSArray
            {
                if arrImages.count>0
                {
                    let linkImage = arrImages[0] as? String ?? ""
                    tableViewCell.imageVehicle.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: ""))
                }
            }
            
            tableViewCell.btnMore.addTarget(self, action: #selector(self.btnMore(sender:)), for: .touchUpInside)
            
            return tableViewCell
            
//        }
//        else
//        {
//            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellConsumer") as! CustomerTableViewCell
//            setCorner(tableViewCell)
//
//            var dictConsumer : NSDictionary = NSDictionary()
//            if is_searching
//            {
//                dictConsumer = arrSearchedVehical.object(at: indexPath.section) as! NSDictionary
//            }
//            else
//            {
//                dictConsumer = arrVehicle.object(at: indexPath.section) as! NSDictionary
//            }
//
//            tableViewCell.lblTitle.text = dictConsumer["v_make"] as? String ?? ""
//            tableViewCell.lblLocation.text = dictConsumer["address"] as? String ?? ""
//            tableViewCell.lblPrice.text = dictConsumer["v_price"] as? String ?? ""
//            tableViewCell.lblDistance.text = dictConsumer["mileage"] as? String ?? ""
//            tableViewCell.lblYear.text = dictConsumer["v_year"] as? String ?? ""
//            tableViewCell.lblBy.text = "by \(dictConsumer["fullname"] as? String ?? "")"
//
//            if let arrImages = dictConsumer.value(forKey: "vimages") as? NSArray
//            {
//                if arrImages.count>0{
//                    let linkImage = arrImages[0] as? String ?? ""
//                    tableViewCell.imageVehicle.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: ""))
//                }
//            }
//
//            return tableViewCell
//        }
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
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if userType == "dealer"
        {
            let lastRow = tableView.numberOfRows(inSection: 0)
            if isAPICalled == false
            {
                if indexPath.row == lastRow - 1
                {
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
//        else {
//
//            let lastRow = tableView.numberOfRows(inSection: 0)
//            if isAPICalled == false
//            {
//                if indexPath.row == lastRow - 1
//                {
//                    spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
//                    spinner.startAnimating()
//                    spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
//                    tableView.tableFooterView = spinner
//                    tableView.tableFooterView?.isHidden = false
//                    PageInd = PageInd + 1
//                    nearVehicle()
//
//                }
//            }
//
//
//        }
    }
    
    //MARK: - Button All Action
    
    @IBAction func clkBack(sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func btnMore(sender:UIButton)
    {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tblViewDealear)
        let indexPath = self.tblViewDealear.indexPathForRow(at: buttonPosition)
        
        var dictDealer : NSDictionary = NSDictionary()
        if is_searching
        {
            dictDealer = arrSearchedVehical.object(at: (indexPath?.section)!) as! NSDictionary
        }
        else
        {
            dictDealer = arrVehicle.object(at: (indexPath?.section)!) as! NSDictionary
        }
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            debugPrint(dictDealer)
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "NewDealerPostViewController") as? NewDealerPostViewController{
                vc.isEditDealer = "1"
                vc.dictEdit = dictDealer
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            if self.is_searching
            {
                self.arrSearchedVehical.removeObject(at: (indexPath?.section)!)
            }
            else
            {
                self.arrVehicle.removeObject(at: (indexPath?.section)!)
            }
            
            self.tblViewDealear.reloadData()
            let strVID : String = (dictDealer.object(forKey: "vid") as? String)!
            self.sendDeleteVehicalReq(strVID: strVID)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(editAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    //MARK:- API -
    func getDealersVehicle()
    {
        self.view.endEditing(true)
        isAPICalled = true
        //AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "GetDealersVehicle",
            "request" : [
                
                "dealerid": AppUtilities.sharedInstance.getLoginUserId(),
                "pageindex": PageInd
                
            ],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                self.isAPICalled = false
                self.refreshControlDealer.endRefreshing()
                if self.spinner != nil{
                    self.spinner.stopAnimating()
                    
                }
                //AppUtilities.sharedInstance.hideLoader()
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
                                
                                if self.PageInd == 1{
                                    self.arrVehicle.removeAllObjects()
                                    
                                }
                                if let arr = responseDic.value(forKey: "data") as? NSArray
                                {
                                    if arr.count == 0 ||  arr.count < 10{
                                        self.isAPICalled = true
                                    }
                                    if arr.count > 0
                                    {
                                        self.tblViewDealear.isHidden = false
                                    }
                                    self.arrVehicle.addObjects(from: arr as! [Any])
                                    self.tblViewDealear.reloadData()
                                }
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
    
    func sendDeleteVehicalReq(strVID:String)
    {
        let dictionaryParams : NSDictionary = [
            "service": "deleteVehicle",
            "request" : [
                "vid": strVID
            ],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                
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
}
