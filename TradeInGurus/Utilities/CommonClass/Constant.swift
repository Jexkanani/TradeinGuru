//
//  Constant.swift
//  Blueapron
//
//  Created by Admin on 12/12/16.
//  Copyright © 2016 CS-23. All rights reserved.
//

import UIKit

class Constant: NSObject
{
    var is_Done = Bool()
    
    class var sharedInstance :Constant  {
        struct Singleton {
            static let instance = Constant()
        }
        return Singleton.instance
    }

}

let UserData = "UserData"
//let BASE_URL = "http://nile.cearsinfotech.in/WebService/service"
//let request = NSMutableURLRequest(url: NSURL(string: BASE_URL)! as URL)
let App_Title = "TradeInGurus"
let COLOR_MAIN = UIColor(red: 68/255, green: 207/255, blue: 147/255, alpha: 1.0)
var quesCount = ""
var followCount = ""
var noticCount = ""
var Language = ""
var isBackground = false


let BoldFont = "Ubuntu-Bold"
let RegularFont = "Ubuntu"
let MediumFont = "Ubuntu-Medium"
let LightFont = "Ubuntu-Light"
