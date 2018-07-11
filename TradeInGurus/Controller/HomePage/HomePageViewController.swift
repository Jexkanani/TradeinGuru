//
//  HomePageViewController.swift
//  TradeInGurus
//
//  Created by Admin on 8/28/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit
import SDWebImage
import Crashlytics
class CustomerTableViewCell: UITableViewCell
{
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblBy: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imageVehicle: UIImageView!
}

class RecTableViewCell: UITableViewCell
{
    @IBOutlet var lblYear : UILabel!
}
class DealerTableViewCell: UITableViewCell
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

class HomePageViewController: UIViewController,SWRevealViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate {
    
    //Consumer
    
    @IBOutlet weak var viewPostNew: UIView!
    @IBOutlet weak var viewAllDealers: UIView!
    @IBOutlet weak var viewOffers: UIView!
    @IBOutlet weak var viewMyInterests: UIView!
    @IBOutlet weak var tblViewConsumer: UITableView!
    @IBOutlet weak var viewCustomers: UIView!
    @IBOutlet weak var lblBuyerNotification: UILabel!
    
    
    
    @IBOutlet var searchBar_De: UISearchBar!
    @IBOutlet var searchBar_cu: UISearchBar!
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
    let refreshControlCustomer = UIRefreshControl()
    
    var isAPICalled = true
    
    var is_searching : Bool = false
    var arrSearchedVehical : NSMutableArray = NSMutableArray()
    
    
    //MARK: - UIView Life Cycle-
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Crashlytics.sharedInstance().crash()
        
//        if isBackground == false {
//            AppApi.sharedInstance.notifiCount()
//
//        }
        
        let dict = AppUtilities.sharedInstance.getLoginDict()
        debugPrint(dict)
        GetCurrentLocation.sharedObject.updateCurrentLocation()
        viewDelears.isHidden = true
        viewCustomers.isHidden = false
        lblBuyerNotification.isHidden = true
        setCorner(viewOffers)
        setCorner(viewPostNew)
        setCorner(viewDPostNew)
        setCorner(viewAllDealers)
        setCorner(viewMyInterests)
        setCorner(viewReceivedRequests)
        tblViewDealear.addSubview(refreshControlDealer)
        tblViewConsumer.addSubview(refreshControlCustomer)
        refreshControlDealer.addTarget(self, action: #selector(refreshDealerData), for: .valueChanged)
        
        refreshControlCustomer.addTarget(self, action: #selector(refreshCustomerData), for: .valueChanged)
        if userType == "dealer"{
            viewDelears.isHidden = false
            viewCustomers.isHidden = true
            lblBuyerNotification.isHidden = false
            getDealersVehicle()
            searchBar_De.isHidden = false
        }
        else{
            viewDelears.isHidden = true
            viewCustomers.isHidden = false
            lblBuyerNotification.isHidden = true
            nearVehicle()
            searchBar_De.isHidden = true
        }
        self.revealViewController().panGestureRecognizer()
        self.revealViewController().tapGestureRecognizer()
        self.revealViewController().delegate = self
        
        
        isBackground = false
        
    }
    
    func refreshCustomerData()   {
        refreshControlCustomer.beginRefreshing()
        self.view.endEditing(true)
        nearVehicle()
        
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
        
        if UserDefaults.standard.bool(forKey: "IsRefresh"){
            UserDefaults.standard.set(false, forKey: "IsRefresh")
            PageInd = 1
            if userType == "dealer"{
                self.arrVehicle.removeAllObjects()
                getDealersVehicle()
            }
            else{
                nearVehicle()
            }
        } else {
            self.PageInd = 1
            if userType == "dealer"{
                self.arrVehicle.removeAllObjects()
                self.tblViewDealear.reloadData()
                getDealersVehicle()
            } else {
                nearVehicle()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(chatNotification(Noti:)), name: NSNotification.Name(rawValue: "newTapMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getCustomerRequest(Noti:)), name: NSNotification.Name(rawValue: "customer_request"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(getDelearAcceptOffer(Noti:)), name: NSNotification.Name(rawValue: "dealer_offer_response"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    func chatNotification(Noti: NSNotification) {
        debugPrint(Noti)
        if let dict = Noti.value(forKey: "userInfo") as? NSDictionary {
            let dictAps = dict.value(forKey: "aps") as? NSDictionary
            var dictAlert = NSDictionary()
            var titleName = String()
            if let strAlert = dictAps?.object(forKey: "alert") as? String {
                let arrSperate = strAlert.components(separatedBy: " ")
                titleName = arrSperate[0] as? String ?? ""
            } else {
                 dictAlert = dictAps?.object(forKey: "alert") as! NSDictionary
                 titleName = dictAlert.object(forKey: "title") as? String ?? ""
            }
            let dictData = dictAps?.value(forKey: "data") as? NSDictionary
            let dictTemp : NSMutableDictionary = NSMutableDictionary(dictionary: dictData!)
            dictTemp.setValue(titleName, forKey: "fullname")
            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            chatVC.dictChatUser = dictTemp
            chatVC.isChatList = true
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newTapMessage"), object: nil)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    func getCustomerRequest(Noti: NSNotification) {
        if let dict = Noti.value(forKey: "userInfo") as? NSDictionary {
            let dictAps = dict.value(forKey: "aps") as? NSDictionary
            let dictData = dictAps?.value(forKey: "data") as? NSDictionary
            let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "VehicleDetailsController") as! VehicleDetailsController
             detailsVC.userDic = dictData!
             //detailsVC.isNotific = true
             NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "customer_request"), object: nil)
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
    func getDelearAcceptOffer(Noti: NSNotification) {
        if let dict = Noti.value(forKey: "userInfo") as? NSDictionary {
            let dictAps = dict.value(forKey: "aps") as? NSDictionary
            let dictData = dictAps?.value(forKey: "data") as? NSDictionary
             let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "VehicleDetailViewController") as! VehicleDetailViewController
              detailsVC.dictVehicle = dictData!
           // detailsVC.isNotific = true
              NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dealer_offer_response"), object: nil)
             self.navigationController?.pushViewController(detailsVC, animated: true)
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
//        print(arrVehicle.count)
//        return arrVehicle.count
        
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
            let vc : VehicleDetailsController = self.storyboard?.instantiateViewController(withIdentifier: "VehicleDetailsController") as! VehicleDetailsController
//            vc.userDic = arrData.object(at: indexPath.row) as! NSDictionary
            
//            var dictConsumer : NSDictionary = NSDictionary()
            if is_searching
            {
                vc.userDic = arrSearchedVehical.object(at: indexPath.section) as! NSDictionary
            }
            else
            {
                vc.userDic = arrVehicle.object(at: indexPath.section) as! NSDictionary
            }
            self.navigationController?.pushViewController(vc, animated: true)
            /*let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            
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
            }*/
        }
        else
        {
            var dictConsumer : NSDictionary = NSDictionary()
            if is_searching
            {
                dictConsumer = arrSearchedVehical.object(at: indexPath.section) as! NSDictionary
            }
            else
            {
                dictConsumer = arrVehicle.object(at: indexPath.section) as! NSDictionary
            }
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "VehicleDetailViewController") as? VehicleDetailViewController
            {
                vc.dictVehicle = dictConsumer
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell
    {
        if userType == "dealer"
        {
//            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellDealer") as! DealerTableViewCell
//            setCorner(tableViewCell)
            /*
             
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
            */
//            return tableViewCell
            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellConsumer") as! CustomerTableViewCell
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
            if let arrImages = dictConsumer.value(forKey: "vimages") as? NSArray
            {
                if arrImages.count>0{
                    let linkImage = arrImages[0] as? String ?? ""
                    tableViewCell.imageVehicle.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: ""))
                }
            }
            tableViewCell.lblYear.text = dictConsumer["v_year"] as? String ?? ""
            tableViewCell.lblTitle.text = dictConsumer["make"] as? String ?? ""
            tableViewCell.lblDistance.text = dictConsumer["mileage"] as? String ?? ""
            if dictConsumer["v_price"] as? String == "0" {
                tableViewCell.lblPrice.text = "Not Available"
            } else {
                tableViewCell.lblPrice.text = dictConsumer["v_price"] as? String ?? "Not Available"
            }
            
            tableViewCell.lblLocation.text = dictConsumer["pincode"] as? String ?? "Not Available"
            tableViewCell.lblBy.text = "by \(dictConsumer["fullname"] as? String ?? "")"
            tableViewCell.lblDate.text = dictConsumer["modification_datetime"] as? String ?? "Not Available"
            return tableViewCell
        }
        else
        {
            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellConsumer") as! CustomerTableViewCell
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
            
            if let arrImages = dictConsumer.value(forKey: "vimages") as? NSArray
            {
                if arrImages.count>0{
                    let linkImage = arrImages[0] as? String ?? ""
                    tableViewCell.imageVehicle.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: ""))
                }
            }
            tableViewCell.lblYear.text = dictConsumer["v_year"] as? String ?? ""
            tableViewCell.lblTitle.text = dictConsumer["v_make"] as? String ?? ""
            tableViewCell.lblDistance.text = dictConsumer["mileage"] as? String ?? ""
            tableViewCell.lblPrice.text = dictConsumer["v_price"] as? String ?? ""
            tableViewCell.lblLocation.text = dictConsumer["address"] as? String ?? ""
            tableViewCell.lblBy.text = "by \(dictConsumer["fullname"] as? String ?? "")"
            tableViewCell.lblDate.text = dictConsumer["modification_datetime"] as? String ?? ""
            
            return tableViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 120
        return 126
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        viewFooter.backgroundColor = UIColor.clear
        return viewFooter
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if userType == "dealer" && !is_searching
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
        else if !is_searching
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
                    nearVehicle()
                }
            }
        }
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
    /*
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
    }*/
    
    func getDealersVehicle()
    {
        if !is_searching {
            self.view.endEditing(true)
        }
        isAPICalled = true
        //AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "GetCustomerOffer",
            "request" : [
                "pageindex": PageInd
            ],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        /*let dictionaryParams : NSDictionary = [
            "service": "GetDealersVehicle",
            "request" : [
                
                "dealerid": AppUtilities.sharedInstance.getLoginUserId(),
                "pageindex": PageInd
                
            ],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary*/
        
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
                                    self.arrVehicle.addObjects(from: arr as! [Any])
                                    self.tblViewDealear.reloadData()
                                }
                                debugPrint(responseDic.value(forKey: "data") as? NSArray ?? "")
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
    
    func nearVehicle()
    {
        //self.view.endEditing(true)
        self.isAPICalled = true
        //AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "NearVehicle",
            "request" : [
                "data": [
                    "user_lat":GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.latitude ?? 21.170240,
                    "user_long": GetCurrentLocation.sharedObject.currentGeoLocation?.coordinate.longitude ?? 72.831062,
                    "distance": 1000,
                    "pageindex":PageInd
                    
                ]],
            
            "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                     "token": AppUtilities.sharedInstance.getLoginUserToken()]
            
            ]  as NSDictionary
        
        debugPrint(dictionaryParams)
        
        AppUtilities.sharedInstance.dataTaskLocal(method: "POST", params: dictionaryParams,strMethod: "", completion: { (success, object) in
            DispatchQueue.main.async( execute: {
                self.isAPICalled = false
                self.refreshControlDealer.endRefreshing()
                self.refreshControlCustomer.endRefreshing()
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
                                
                                
                                if let arr = responseDic.value(forKey: "data") as? NSArray
                                {
                                    if arr.count == 0 ||  arr.count < 10{
                                        self.isAPICalled = true
                                    }
                                    
                                    if self.PageInd == 1 {
                                        self.arrVehicle = NSMutableArray(array: arr)
                                    }
                                    else {
                                        self.arrVehicle.addObjects(from: arr as! [Any])
                                    }
                                    
                                    self.tblViewConsumer.reloadData()
                                    
                                }
                                
                            }
                            else{
                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                    //AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
                                }
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
    
    
    //MARK: - Memory Management -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - All Button Action -
    @IBAction func btnHomePressed(_ sender: Any) {
        self.view.endEditing(true)
        self.revealViewController().revealToggle(sender)
    }
    
    @IBAction func btnOfferPressed(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "OffersListViewController") as? OffersListViewController{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnNotificationPressed(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "NotificationViewController") as? NotificationVC{
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    
    @IBAction func btnPostNewDealerPressed(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "NewDealerPostViewController") as? NewDealerPostViewController{
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @IBAction func btnPostNewCustomerPressed(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "OfferRequestViewController") as? OfferRequestViewController{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnReceivedRequestPressed(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        /*if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "OfferReqReceivedController") as? OfferReqReceivedController{
            self.navigationController?.pushViewController(vc, animated: true)
            //jignesh
        }*/
        
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "Listings") as? Listings{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func btnInterestPressed(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "MyInterestViewController") as? MyInterestViewController{
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    
    @IBAction func btnDealearsPressed(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "DealerListViewController") as? DealerListViewController{
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    
    //MARK:- UISearchBar Method
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        searchCustomer(searchtext: searchBar.text!)
        if userType == "dealer" {
            searchCustomer(searchtext: searchBar_De.text!)
        } else {
            searchCustomer(searchtext: searchBar_cu.text!)
        }
    }
    
    func searchCustomer(searchtext: String)
    {
        if (searchtext.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count) > 0
        {
            is_searching = true
            arrSearchedVehical.removeAllObjects()
            
            for index in 0..<arrVehicle.count
            {
                let dictData = arrVehicle.object(at: index) as! NSDictionary
                var v_make = String()
                if userType == "dealer" {
//                    v_make = dictData.value(forKey: "make") as? String
                    v_make = (dictData.value(forKey: "make") as? String)!
                } else {
                    v_make = (dictData.value(forKey: "v_make") as? String)!
                }
                if v_make.lowercased().range(of: (searchtext.lowercased()), options:.regularExpression) != nil
                {
                    arrSearchedVehical.add(dictData)
                }
            }
        }
        else
        {
            is_searching = false
        }
        
        if userType == "dealer"
        {
            print("========")
            print(arrSearchedVehical)
            tblViewDealear.reloadData()
//            tblViewConsumer.reloadData()
        }
        else
        {
            tblViewConsumer.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if userType == "dealer"
        {
            if !tblViewDealear.isDecelerating {
                view.endEditing(true)
            }
        }
        else
        {
            if !tblViewConsumer.isDecelerating {
                view.endEditing(true)
            }
        }
        
        
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
