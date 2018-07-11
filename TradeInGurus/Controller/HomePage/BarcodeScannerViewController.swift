//
//  BarcodeScannerViewController.swift
//  TradeInGurus
//
//  Created by Admin on 02/10/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit
import MTBBarcodeScanner
protocol BarcodeDelegate {
    func btnGetCode(_ strCode : String);
}
class BarcodeScannerViewController: UIViewController {
    
    @IBOutlet var previewView: UIView!
    var scanner: MTBBarcodeScanner?
    var barcodeDelegate : BarcodeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        scanner = MTBBarcodeScanner(previewView: previewView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                do {
                    try self.scanner?.startScanning(resultBlock: { codes in
                        if let codes = codes {
                           

                            for code in codes {
                                let stringValue = code.stringValue!
                                debugPrint("Found code: \(stringValue)")
                                self.barcodeDelegate?.btnGetCode(stringValue)
                                self.dismiss(animated: true) {
                                }
                                self.scanner?.stopScanning()
                                return
                            }
                          }
                    })
                } catch {
                    NSLog("Unable to start scanning")
                }
            } else {
                UIAlertView(title: "Scanning Unavailable", message: "This app does not have permission to access the camera", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Ok").show()
            }
        })
        
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton){
        
        self.dismiss(animated: true) { 
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.scanner?.stopScanning()
        
        super.viewWillDisappear(animated)
    }
}
