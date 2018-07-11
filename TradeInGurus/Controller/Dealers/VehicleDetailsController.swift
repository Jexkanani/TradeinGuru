//
//  VehicleDetailsController.swift
//  TradeInGurus
//
//  Created by Admin on 12/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

class VehicleDetailsController: UIViewController,AACarouselDelegate {
    
    @IBOutlet weak var carouselView: AACarousel!
    
    @IBOutlet var lblYear : UILabel!
    @IBOutlet var lblModel : UILabel!
    @IBOutlet var lblMileage : UILabel!
    @IBOutlet var lblVIN : UILabel!
//    @IBOutlet var lblDealerName : UILabel!
//    @IBOutlet var lblDealerPhone : UILabel!
//    @IBOutlet var lblDealerEmail : UILabel!
//    @IBOutlet var lblAddress : UILabel!
//    @IBOutlet var lblCity : UILabel!
//    @IBOutlet var lblZipCode : UILabel!
    @IBOutlet var lblDescription : UILabel!
  //  @IBOutlet var lblPrice : UILabel!
//    @IBOutlet var lblCustName : UILabel!
//    @IBOutlet var lblCustAdd : UILabel!

    @IBOutlet var lbl_V_Name: UILabel!
    
    var userDic : NSDictionary = NSDictionary()
    var userInfo = NSDictionary()
    var isNotific = false
    var isFrom : String = String()
    let userType = AppUtilities.sharedInstance.getLoginUserType()
//    var isFrom : String
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfo = AppUtilities.sharedInstance.getLoginDict()
        
//        if userDic["v_name"] as? String == "" == "" {
//            lbl_V_Name.text = "\(userDic["v_make"] as? String ?? "Not Available")"
//        } else {
            lbl_V_Name.text = "\(userDic["v_name"] as? String ?? "Not Available")"
//        }
        
        lblYear.text = ": \(userDic["v_year"] as? String ?? "Not Available")"
        lblModel.text = ": \(userDic["v_model"] as? String ?? "Not Available")"
        lblMileage.text = ": \(userDic["mileage"] as? String ?? "Not Available")"
        
        if userDic["v_number"] as? String == "" {
            lblVIN.text = ": Not Available"
        } else {
            lblVIN.text = ": \(userDic["v_number"] as? String ?? "Not Available")"
        }
//        lblDealerName.text = userInfo.value(forKey: "fullname") as? String ?? ""
//        lblDealerPhone.text = userInfo.value(forKey: "mobile") as? String ?? ""
//        lblDealerEmail.text = userInfo.value(forKey: "email") as? String ?? ""
//        lblAddress.text = AppUtilities.sharedInstance.getLoginAddress() //userDic["address"] as? String ??
//        lblCity.text = AppUtilities.sharedInstance.getLoginCity() //userDic["city"] as? String ??
//        lblZipCode.text = AppUtilities.sharedInstance.getLoginPincode() //userDic["pincode"] as? String ??
//        lblCustName.text = userDic["fullname"] as? String ?? ""
//        lblCustAdd.text = userDic["address"] as? String ?? ""
        
        lblDescription.text = ": \(userDic.value(forKey: "description") as? String ?? "Not Available")"
        if lblDescription.text == "" {
            lblDescription.text = ": \("Not Available")"
        }
        if lblVIN.text == "" {
            lblVIN.text = ": \("Not Available")"
        }
//        lblDescription.numberOfLines = 5
//        lblDescription.sizeToFit()
       // lblPrice.text = userDic["v_price"] as? String ?? ""
        debugPrint(userDic)
        var pathArray = NSArray()
        
        if let arrImgVechiles = userDic["vimages"] as? NSArray {
            pathArray = arrImgVechiles
        } else {
            pathArray = userDic["images"] as! NSArray
        }
        carouselView.delegate = self
        
        carouselView.setCarouselData(paths: pathArray as! [String],  describedTitle: [], isAutoScroll: true, timer: 5.0, defaultImage: "default_tig_pic")
        
        carouselView.setCarouselLayout(displayStyle: 0, pageIndicatorPositon: 2, pageIndicatorColor: nil, describedTitleColor: nil, layerColor: nil)
        
//        if self.isFrom == "delearNoti" {
//            lbl_V_Name.text = "\(userDic["v_make"] as? String ?? "Not Available")"
//        }
        if !isNotific
        {
            
        } else {
//            lbl_V_Name.text = "\(userDic["make"] as? String ?? "Not Available")"
        }
        
    }
    
    /*extension String {
        func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            
            return ceil(boundingBox.height)
        }
        
        func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
            let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            
            return ceil(boundingBox.width)
        }
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //require method
    func downloadImages(_ url: String, _ index:Int) {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: URL(string: url)!, placeholder: UIImage.init(named: "default_tig_pic"), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: { (downloadImage, error, cacheType, url) in
            self.carouselView.images[index] = downloadImage!
        })
        
    }
    
    
    //optional method (show first image faster during downloading of all images)
    func callBackFirstDisplayView(_ imageView: UIImageView, _ url: [String], _ index: Int) {
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: URL(string: url[index]), placeholder: UIImage.init(named: "default_tig_pic"), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
        
    }
    
    func startAutoScroll() {
        //optional method
        carouselView.startScrollImageView()
        
    }
    
    func stopAutoScroll() {
        //optional method
        carouselView.stopScrollImageView()
    }
    
    
    //MARK: - All Button Action Methods
    
    
    @IBAction func clkBack(sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clkPush(sender : UIButton){
        var vid = ""
        var userId = ""
        
        if isNotific == true {
            vid = userDic.value(forKey: "id") as? String ?? ""
            userId = userDic.value(forKey: "userid") as? String ?? ""
            
        }
        else {
            vid = userDic.value(forKey: "vid") as? String ?? ""
            if let userID = userDic.object(forKey: "user_id") as? String {
                userId = userID
            } else {
                userId = userDic.value(forKey: "nt_cust_id") as? String ?? ""
            }
        }
        
        if let userID = userDic.object(forKey: "user_id") as? String {
            AppApi.sharedInstance.sendPushNoti(vid: vid, userID: userId, isOffer: true)
        } else {
            AppApi.sharedInstance.sendPushNoti(vid: vid, userID: userId, isOffer: isNotific)
        }
    }
    
    @IBAction func btnChatClk(_ sender: UIButton) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.dictChatUser = NSMutableDictionary(dictionary: userDic)
        if isNotific == true {
            chatVC.isResquest = true
        }
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
}
