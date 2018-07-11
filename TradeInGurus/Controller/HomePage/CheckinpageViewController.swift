//
//  CheckinpageViewController.swift
//  HeavenPlus
//
//  Created by Admin on 1/30/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import MapKit
class CheckinTableViewCell : UITableViewCell{
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lab1: UILabel!
    @IBOutlet weak var lab2: UILabel!
    @IBOutlet weak var lab3: UILabel!
}

class CheckinpageViewController: UIViewController, UITableViewDataSource,UITableViewDelegate ,UITextFieldDelegate{
    
    
    //MARK:- Outlets, Variable -
    
    var Mainlocation = ["RahulRajMall","Surat","Navsari"]
    var Sublocation = ["Ghod dhod Road,Ghod dhod RoadGhod dhod RoadGhod dhod RoadGhod dhod RoadGhod dhod RoadGhod dhod Road , surat","Surat","ShantadeviRoad"]
    var checkin = ["302Checkin","302Checkin","20Checkin"]
    var img1 = "checkin_def_icon"
    @IBOutlet weak var tblViewCheckIn: UITableView!
    @IBOutlet weak var txtSearch: UITextField!

    var searchQuery = SPGooglePlacesAutocompleteQuery()
    var searchResultPlaces = NSArray()
    var shouldBeginEditing = false
    var isOffer = false
    //MARK:- UIView Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Dynamic Cell
        tblViewCheckIn.rowHeight = UITableViewAutomaticDimension
        tblViewCheckIn.estimatedRowHeight = 51
        tblViewCheckIn.tableFooterView = UIView(frame: CGRect.zero)
        searchQuery.radius = 100.0
        shouldBeginEditing = true
        txtSearch.becomeFirstResponder()
    }
    
    //MARK:- UIButton Action Methods -
    @IBAction func BackUploadPage(_ sender: Any) {
        if isOffer == false {
            _  = self.navigationController?.popViewController(animated: true)
            
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    
    //MARK:- Memory Management -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- UITableView datasource Methods -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultPlaces.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! CheckinTableViewCell
        
        let dict = searchResultPlaces.object(at: indexPath.row) as! SPGooglePlacesAutocompletePlace
        debugPrint(dict)
        
        
        cell.lab1.text = dict.name
        cell.lab2.text = dict.name
        cell.img.image = UIImage(named: img1)
        cell.img.layer.cornerRadius = (cell.img.frame.size.height) / 2
        cell.img.clipsToBounds = true
        
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = searchResultPlaces.object(at: indexPath.row)
        debugPrint(dict)
        self.view.endEditing(true)

        self.view.endEditing(true)
        AppUtilities.sharedInstance.showLoader()
        let location: String = (dict as AnyObject).name
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if ((placemarks?.count)! > 0) {
                debugPrint(placemarks!)
                let  placemark = placemarks![0]
                let latitude = "\(placemark.location!.coordinate.latitude)"
                let longitude = "\(placemark.location!.coordinate.longitude)"
                
                UserDefaults.standard.set(latitude, forKey: "Latitude")
                UserDefaults.standard.set(longitude, forKey: "Longitude")
                UserDefaults.standard.set(location, forKey: "Location")
                let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?markers=color:blue|\(latitude),\(longitude)&zoom=13&size=320x320&sensor=true"
                let mapUrl: NSURL = NSURL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
                
             
                UserDefaults.standard.set(true, forKey: "IsLocation")
                UserDefaults.standard.synchronize()
                AppUtilities.sharedInstance.hideLoader()
                if self.isOffer == false {
                    _  = self.navigationController?.popViewController(animated: true)

                }
                else {
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
            
        }
        
    }
    //MARK:- UITextFiled Delegate MEthds
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        searchQuery.input = updatedString
        searchQuery.fetchPlaces { (arryaPlaces, error) in
            if ((error) != nil) {
                
            } else {
                self.searchResultPlaces = NSArray(array: arryaPlaces!)
                self.tblViewCheckIn.reloadData()
            }
        }
        //Return false if you don't want the textfield to be updated
        return true
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
