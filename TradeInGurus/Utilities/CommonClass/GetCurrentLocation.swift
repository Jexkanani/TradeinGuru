//
//  GetCurrentLocation.swift

//
//  Created by utkarsh kumar mishra on 12/6/16.
//  Copyright © 2016 utkarsh kumar mishra. All rights reserved.
//

import Foundation
import CoreLocation

class GetCurrentLocation:NSObject, CLLocationManagerDelegate{
    static let sharedObject = GetCurrentLocation()
    
    var currentGeoLocation:CLLocation? = nil
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
    }
    
    func updateCurrentLocation() -> CLLocation?
    {
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        return self.currentGeoLocation
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            self.currentGeoLocation = locations.last
            manager.stopUpdatingLocation()
            //debugPrint("GetCurrentLocation lat::\(self.currentGeoLocation?.coordinate.latitude)")
            //debugPrint("GetCurrentLocation lang::\(self.currentGeoLocation?.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("CurrentLocation Error:  \(error.localizedDescription)")
    }
    
    
    
    
}
