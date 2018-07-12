//
//  VehicleDetailVC.swift
//  TradeInGurus
//
//  Created by Admin on 22/03/18.
//  Copyright © 2018 cearsinfotech. All rights reserved.
//

import UIKit

class detail_cell: UITableViewCell {
    
    @IBOutlet weak var carouselView: AACarousel!
    
    @IBOutlet var lblYear : UILabel!
    @IBOutlet var lblModel : UILabel!
    @IBOutlet var lblMileage : UILabel!
    @IBOutlet var lblVIN : UILabel!
    @IBOutlet var lblDescription : UILabel!
    @IBOutlet var lbl_V_Name: UILabel!
    @IBOutlet var chat_Btn: UIButton!
    
}

class VehicleDetailVC: UIViewController, UITableViewDelegate , UITableViewDataSource , AACarouselDelegate {
    
    var userDic : NSDictionary = NSDictionary()
    var userInfo = NSDictionary()
    var isNotific = false
    let cell = detail_cell()
    @IBOutlet var tbl_detail: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tbl_detail.estimatedRowHeight = 475
        self.tbl_detail.rowHeight = UITableViewAutomaticDimension
        
        debugPrint(userDic)
        
        if !isNotific
        {
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Tableview Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifire = "cell_detail"
        let cell : detail_cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifire, for: indexPath) as! detail_cell
        
        cell.lbl_V_Name.text = userDic["v_name"] as? String ?? ""
        cell.lblYear.text = userDic["v_year"] as? String ?? ""
        cell.lblModel.text = userDic["v_model"] as? String ?? ""
        cell.lblMileage.text = userDic["mileage"] as? String ?? ""
        cell.lblVIN.text = userDic["v_number"] as? String ?? "Not Available"
        cell.lblDescription.text = userDic.value(forKey: "description") as? String ?? "Not Available"
        if cell.lblDescription.text == "" {
            cell.lblDescription.text = "Not Available"
        }
        if cell.lblVIN.text == "" {
            cell.lblVIN.text = "Not Available"
        }
        cell.chat_Btn.addTarget(self, action: #selector(btn_chatClicked), for: .touchUpInside)
        
        var pathArray = NSArray()
        
        if let arrImgVechiles = userDic["vimages"] as? NSArray {
            pathArray = arrImgVechiles
        } else {
            pathArray = userDic["images"] as! NSArray
        }
        
        cell.carouselView.delegate = self
        
        if pathArray.count == 0 {
            pathArray = ["http://app.tradeingurus.com/uploads/profile_pic"] // Dealer -> Notification -> Tap -> Vehicle image come with full path
        }
        
        cell.carouselView.setCarouselData(paths: pathArray as! [String],  describedTitle: [], isAutoScroll: true, timer: 5.0, defaultImage: "default_tig_pic")
        
        
        cell.carouselView.setCarouselLayout(displayStyle: 0, pageIndicatorPositon: 2, pageIndicatorColor: nil, describedTitleColor: nil, layerColor: nil)
        
        return cell
    }
    
    //MARK: - Button Action
    
    @IBAction func btn_back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func btn_chatClicked() {
        
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.dictChatUser = NSMutableDictionary(dictionary: userDic)
        if isNotific == true {
            chatVC.isResquest = true
        }
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    //require method
    func downloadImages(_ url: String, _ index:Int) {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: URL(string: url)!, placeholder: UIImage.init(named: "default_tig_pic"), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: { (downloadImage, error, cacheType, url) in
            //self.cell.carouselView.images[index] = downloadImage!
        })
    }
    
    //optional method (show first image faster during downloading of all images)
    func callBackFirstDisplayView(_ imageView: UIImageView, _ url: [String], _ index: Int) {
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: URL(string: url[index]), placeholder: UIImage.init(named: "default_tig_pic"), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
        
    }
    
    func startAutoScroll() {
        //optional method
        cell.carouselView.startScrollImageView()
    }
    
    func stopAutoScroll() {
        //optional method
        cell.carouselView.stopScrollImageView()
    }
    
}

