//
//  VehicleDetailViewController.swift
//  TradeInGurus
//
//  Created by Admin on 12/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit



class VehicleDetailTableViewCell: UITableViewCell, AACarouselDelegate {
    
    //require method
    func downloadImages(_ url: String, _ index:Int) {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: URL(string: url)!, placeholder: UIImage.init(named: "default_tig_pic"), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: { (downloadImage, error, cacheType, url) in
            self.carouselView1.images[index] = downloadImage!
        })
    }
    //optional method (show first image faster during downloading of all images)
    func callBackFirstDisplayView(_ imageView: UIImageView, _ url: [String], _ index: Int) {
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: URL(string: url[index]), placeholder: UIImage.init(named: "default_tig_pic"), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
    }
    func startAutoScroll() {
        //optional method
        carouselView1.startScrollImageView()
    }
    func stopAutoScroll() {
        //optional method
        carouselView1.stopScrollImageView()
    }
    
    @IBOutlet weak var imageVehicle: UIImageView!
    @IBOutlet weak var lblYear: UILabel!
    
    @IBOutlet weak var lblZipcode: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblVehicleName: UILabel!
    
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblDealerEmail: UILabel!
    @IBOutlet weak var lblVehicleMileage: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDealerName: UILabel!
    @IBOutlet weak var lblVehicleNumber: UILabel!
    @IBOutlet weak var lblDealerPhone: UILabel!
    @IBOutlet weak var lblVehicleModel: UILabel!
    @IBOutlet var lblPrice : UILabel!
    
    @IBOutlet weak var lblVehicleYear: UILabel!
    
    @IBOutlet var btnSendRequest : UIButton!
    @IBOutlet weak var carouselView1: AACarousel!
    
}

class VehicleDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    
    @IBOutlet weak var imageVehicle: UIImageView!
    @IBOutlet weak var lblYear: UILabel!
    
    @IBOutlet weak var lblZipcode: UILabel!
    @IBOutlet weak var lblVehicleName: UILabel!
    
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblDealerEmail: UILabel!
    @IBOutlet weak var lblVehicleMileage: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDealerName: UILabel!
    @IBOutlet weak var lblVehicleNumber: UILabel!
    @IBOutlet weak var lblDealerPhone: UILabel!
    @IBOutlet weak var lblVehicleModel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var dictVehicle = NSDictionary()
    var dictCustInterest = NSDictionary()
    //MARK: - UIView Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 630
        debugPrint(dictVehicle)
        
        //        var pathArray = NSArray()
        //        if let arrImgVechiles = dictVehicle["vimages"] as? NSArray {
        //            pathArray = arrImgVechiles
        //        } else {
        //            pathArray = dictVehicle["images"] as! NSArray
        //        }
        //        carouselView1.delegate = self
        //        carouselView1.setCarouselData(paths: pathArray as! [String],  describedTitle: [], isAutoScroll: true, timer: 5.0, defaultImage: "default_tig_pic")
        //        carouselView1.setCarouselLayout(displayStyle: 0, pageIndicatorPositon: 2, pageIndicatorColor: nil, describedTitleColor: nil, layerColor: nil)
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        //        tap.delegate = self as? UIGestureRecognizerDelegate
        //        carouselView1.addGestureRecognizer(tap)
        
        
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        
        let dictionaryParams : NSDictionary = [
            "service": "GetCustomerInterestChat",
            "request" : [
                "data": [
                    "cust_id": AppUtilities.sharedInstance.getLoginUserId(),
                    "vid": dictVehicle.value(forKey: "vid")!
                ]
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
                                let arr = (responseDic.value(forKey: "data") as! NSArray)
                                if (arr.count > 0) {
                                    self.dictCustInterest = arr.object(at: 0) as! NSDictionary
                                    self.tableView.reloadData()
                                    debugPrint(self.dictCustInterest)
                                }
                            }
                            else{
                                if let errorMsg = responseDic.value(forKey: "msg") as? String{
                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
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
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        let tableViewCell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! VehicleDetailTableViewCell
        let ImgZoom = self.storyboard?.instantiateViewController(withIdentifier: "ImageZoomViewController") as! ImageZoomViewController
        ImgZoom.userDic = self.dictVehicle
        //        ImgZoom.currentIndex = tableViewCell.carouselView1.GetCurrentIndex() // jex
        self.navigationController?.pushViewController(ImgZoom, animated: true)
    }
    
    //MARK: - API -
    func sendRequest(isCancel : Bool){
        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        var dictionaryParams = NSDictionary()
        if isCancel == false {
            dictionaryParams = [
                "service": "add_customer_interest",
                "request" : [
                    "data" : [
                        "vid":dictVehicle.value(forKey: "vid") as? String ?? "0",
                        "dealer_id":dictVehicle.value(forKey: "deal_id") as? String ?? "0"
                    ]
                ],
                "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                         "token": AppUtilities.sharedInstance.getLoginUserToken()]
                ]  as NSDictionary
        } else {
            dictionaryParams = [
                "service": "remove_customer_interest",
                "request" : [
                    "data" : [
                        "vid":dictVehicle.value(forKey: "vid") as? String ?? "0",
                        "dealerid":dictVehicle.value(forKey: "deal_id") as? String ?? "0"
                    ]
                ],
                "auth": ["id":AppUtilities.sharedInstance.getLoginUserId(),
                         "token": AppUtilities.sharedInstance.getLoginUserToken()]
                ]  as NSDictionary
        }
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
                                let msg = responseDic.value(forKey: "message") as? String ?? ""
                                AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: msg as NSString)
                                
                                var info  = NSMutableDictionary()
                                info = NSMutableDictionary(dictionary: self.dictVehicle)
                                
                                if msg as String == "Interest removed successfully" {
                                    //                                    self.dictVehicle.value(forKey:  "isrequested") = "0"
                                    info["isrequested"] = "0"
                                    //                                    isCancel = !isCancel
                                } else if msg as String == "Request sent successfully" {
                                    info["isrequested"] = "1"
                                    //                                    self.dictVehicle.value(forKey:  "isrequested") = "1"
                                    //                                    isCancel = !isCancel
                                }
                                self.dictVehicle = info
                                print(self.dictVehicle)
                                self.tableView.reloadData()
                            }
                            else{
                                if let errorMsg = responseDic.value(forKey: "message") as? String{
                                    AppUtilities.sharedInstance.showAlert(title: APP_Title as NSString, msg: errorMsg as NSString)
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
    
    
    //MARK: - all UIButton actions -
    
    @IBAction func btnSendRequestPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "Cancel Request" {
            sendRequest(isCancel: true)
        } else if sender.titleLabel?.text == "Chat" {
            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            chatVC.isFromBuyerNoti = false
            chatVC.dictChatUser = NSMutableDictionary(dictionary: dictVehicle)
            self.navigationController?.pushViewController(chatVC, animated: true)
        } else {
            sendRequest(isCancel: false)
        }
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - all UIButton actions -
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.layer.cornerRadius = 5.0
        tableView.clipsToBounds = true
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! VehicleDetailTableViewCell
        tableViewCell.lblVehicleName.text = "\(dictVehicle["v_name"] as? String ?? "Not Available")"
        tableViewCell.lblAddress.text = ": " + "\(dictVehicle["address"] as? String ?? AppUtilities.sharedInstance.getLoginAddress())"
        tableViewCell.lblVehicleMileage.text = ": " + "\(dictVehicle["mileage"] as? String ?? "Not Available")"
        tableViewCell.lblYear.text = "\(dictVehicle["v_year"] as? String ?? "Not Available")"
        tableViewCell.lblDealerName.text = ": " +  "\(dictVehicle["fullname"] as? String ?? "Not Available")"
        tableViewCell.lblDealerEmail.text = ": " + "\(dictVehicle["email"] as? String ?? "Not Available")"
        tableViewCell.lblDealerPhone.text = ": " + "\(dictVehicle["mobile"] as? String ?? "Not Available")"
        tableViewCell.lblZipcode.text = ": " + "\(dictVehicle["zipcode"] as? String ?? AppUtilities.sharedInstance.getLoginPincode())"
        tableViewCell.lblDate.text = ": " + "\(dictVehicle["creation_datetime"] as? String ?? "Not Available")"
        tableViewCell.lblCity.text = ": " + "\(dictVehicle["city"] as? String ?? AppUtilities.sharedInstance.getLoginCity())"
        tableViewCell.lblVehicleModel.text = ": " + "\(dictVehicle["v_model"] as? String ?? "Not Available")"
        tableViewCell.lblVehicleNumber.text = ": " + "\(dictVehicle["v_number"] as? String ?? "Not Available")"
        tableViewCell.lblVehicleYear.text = ": " + "\(dictVehicle["v_year"] as? String ?? "Not Available")"
        tableViewCell.lblPrice.text = ": " + "\(dictVehicle["v_price"] as? String ?? "Not Available")"
        
        var pathArray = NSArray()
        if (tableViewCell.lblVehicleNumber.text == "") {
            tableViewCell.lblVehicleNumber.text = "Not Available"
        }
        if let arrImages = dictVehicle.value(forKey: "vimages") as? NSArray
        {
            if arrImages.count>0 {
                let linkImage = arrImages[0] as? String ?? ""
                tableViewCell.imageVehicle.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: "placeholder"))
                pathArray = arrImages
            }
        }
        else if let arrImages = dictVehicle.value(forKey: "images") as? NSArray {
            if arrImages.count>0{
                let linkImage = arrImages[0] as? String ?? ""
                tableViewCell.imageVehicle.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: "placeholder"))
                pathArray = arrImages
            }
        }
        else {
            if let strImage = dictVehicle.value(forKey: "vimages") as? String {
                let arrImage = strImage.components(separatedBy: ",")
                let linkImg = "http://app.tradeingurus.com/uploads/vehicles/\(arrImage[0])"
                tableViewCell.imageVehicle.sd_setImage(with: URL(string: linkImg), placeholderImage: UIImage(named: "placeholder"))
            }
        }
        tableViewCell.carouselView1.delegate = tableViewCell
        tableViewCell.carouselView1.setCarouselData(paths: pathArray as! [String],  describedTitle: [], isAutoScroll: true, timer: 5.0, defaultImage: "default_tig_pic")
        tableViewCell.carouselView1.setCarouselLayout(displayStyle: 0, pageIndicatorPositon: 2, pageIndicatorColor: nil, describedTitleColor: nil, layerColor: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self as? UIGestureRecognizerDelegate
        tableViewCell.carouselView1.addGestureRecognizer(tap)
        
        if dictVehicle.value(forKey:  "isrequested") as? String == "1" || dictVehicle.value(forKey: "deal_id") as? String == AppUtilities.sharedInstance.getLoginUserId()  {
            tableViewCell.btnSendRequest.backgroundColor = UIColor(red: 216/255, green: 117/255, blue: 62/255, alpha: 1.0)
            tableViewCell.btnSendRequest.setTitle("Cancel Request", for: .normal)
        }
        else {
            tableViewCell.btnSendRequest.backgroundColor = UIColor(red: 216/255, green: 117/255, blue: 62/255, alpha: 1.0)
            if dictVehicle.value(forKey: "nt_type") as? String == "dealer_offer_response" {
                tableViewCell.btnSendRequest.setTitle("Cancel Request", for: .normal)
            } else {
                tableViewCell.btnSendRequest.setTitle("Send Request", for: .normal) // Jex
                tableViewCell.btnSendRequest.isEnabled = true
            }
        }
        
        if (self.dictCustInterest.value(forKey: "ischat") != nil) {
            if self.dictCustInterest.value(forKey: "ischat") as! String == "1" {
                tableViewCell.btnSendRequest.setTitle("Chat", for: .normal)
            }
        }
        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

