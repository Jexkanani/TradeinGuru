//
//  VehicleDetailViewController.swift
//  TradeInGurus
//
//  Created by Admin on 12/09/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit



class VehicleDetailTableViewCell: UITableViewCell {
    
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

}

class VehicleDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

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
    
    //MARK: - UIView Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 630
        debugPrint(dictVehicle)
       
        
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
            tableViewCell.lblVehicleName.text = "\(dictVehicle["v_name"] as? String ?? "")"
            tableViewCell.lblAddress.text = ": " + "\(dictVehicle["address"] as? String ?? AppUtilities.sharedInstance.getLoginAddress())"
            tableViewCell.lblVehicleMileage.text = ": " + "\(dictVehicle["mileage"] as? String ?? "")"
            tableViewCell.lblYear.text = "\(dictVehicle["v_year"] as? String ?? "")"
            tableViewCell.lblDealerName.text = ": " +  "\(dictVehicle["fullname"] as? String ?? "")"
            tableViewCell.lblDealerEmail.text = ": " + "\(dictVehicle["email"] as? String ?? "")"
            tableViewCell.lblDealerPhone.text = ": " + "\(dictVehicle["mobile"] as? String ?? "")"
            tableViewCell.lblZipcode.text = ": " + "\(dictVehicle["zipcode"] as? String ?? AppUtilities.sharedInstance.getLoginPincode())"
            tableViewCell.lblDate.text = ": " + "\(dictVehicle["creation_datetime"] as? String ?? "")"
            tableViewCell.lblCity.text = ": " + "\(dictVehicle["city"] as? String ?? AppUtilities.sharedInstance.getLoginCity())"
            tableViewCell.lblVehicleModel.text = ": " + "\(dictVehicle["v_model"] as? String ?? "")"
            tableViewCell.lblVehicleNumber.text = ": " + "\(dictVehicle["v_number"] as? String ?? "")"
            tableViewCell.lblVehicleYear.text = ": " + "\(dictVehicle["v_year"] as? String ?? "")"
            tableViewCell.lblPrice.text = ": " + "\(dictVehicle["v_price"] as? String ?? "")"

            if let arrImages = dictVehicle.value(forKey: "vimages") as? NSArray
            {
                if arrImages.count>0{
                    let linkImage = arrImages[0] as? String ?? ""
                    tableViewCell.imageVehicle.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: "placeholder"))
                }
            }
            else if let arrImages = dictVehicle.value(forKey: "images") as? NSArray {
                if arrImages.count>0{
                    let linkImage = arrImages[0] as? String ?? ""
                    tableViewCell.imageVehicle.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: "placeholder"))
                }

            }
            else {
                
                if let strImage = dictVehicle.value(forKey: "vimages") as? String {
                    
                    let arrImage = strImage.components(separatedBy: ",")
                    
                    let linkImg = "http://app.tradeingurus.com/uploads/vehicles/\(arrImage[0])"
                    
                     tableViewCell.imageVehicle.sd_setImage(with: URL(string: linkImg), placeholderImage: UIImage(named: "placeholder"))
                    
                }
            }
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
