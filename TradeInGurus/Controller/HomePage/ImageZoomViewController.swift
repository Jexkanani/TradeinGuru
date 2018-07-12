//
//  ImageZoomViewController.swift
//  TradeInGurus
//
//  Created by Admin on 22/06/18.
//  Copyright © 2018 cearsinfotech. All rights reserved.
//

import UIKit

class ImageZoomViewController: UIViewController, UIScrollViewDelegate, EFImageViewZoomDelegate {
    var userDic : NSDictionary = NSDictionary()
    var currentIndex : NSInteger = 0
    @IBOutlet var img : UIImageView!
    @IBOutlet var ScrollView : UIScrollView!
    @IBOutlet var defaultView : UIView!
    var imageView: UIImageView = UIImageView()
    
    @IBOutlet weak var imageViewZoom: EFImageViewZoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var pathArray = NSArray()
        if let arrImgVechiles = userDic["vimages"] as? NSArray {
            pathArray = arrImgVechiles
        } else {
            pathArray = userDic["images"] as! NSArray
        }
//        ScrollView.minimumZoomScale = 0.5
//        ScrollView.maximumZoomScale = 6.0
//
//        ScrollView.contentSize = self.img.frame.size
        
        
//        ScrollView.delegate = self
        
       /* let vWidth = self.view.frame.width
        let vHeight = self.view.frame.height
        
        
        imageView.frame = CGRect.init(x: 0, y: 0, width: vWidth, height: vHeight)
        
        let scrollImg: UIScrollView = UIScrollView()
        scrollImg.delegate = self
        scrollImg.frame = CGRect.init(x: 0, y: 0, width: vWidth, height: vHeight) //CGRectMake(0, 0, vWidth, vHeight)
        scrollImg.backgroundColor = UIColor(red: 90, green: 90, blue: 90, alpha: 0.90)
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = true
        scrollImg.flashScrollIndicators()
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 10.0
        
        scrollImg.addSubview(imageView)
        defaultView!.addSubview(scrollImg!)
        
        imageView.layer.cornerRadius = 11.0
        imageView.clipsToBounds = false
        scrollImg.addSubview(imageView)*/
        
//        var pinchGesture  = UIPinchGestureRecognizer()
//        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch))
//        defaultView.isUserInteractionEnabled = true
//        defaultView.addGestureRecognizer(pinchGesture)
        self.imageViewZoom._delegate = self
        self.imageViewZoom.image = UIImage(named: "default_tig_pic")
        if pathArray.count>0{
            let linkImage = pathArray.object(at: currentIndex) as? String ?? ""
            
            let url = URL(string:linkImage)
            if let data = try? Data(contentsOf: url!)
            {
                let image: UIImage = UIImage(data: data)!
                self.imageViewZoom.image = image
            }
            
            //self.imageViewZoom.image = Image // sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: "default_tig_pic"))
//            self.imageViewZoom.image = UIImage(named: "14bis.png")
        } else {
            let linkImage = ""
            self.imageViewZoom.image = UIImage(named: "default_tig_pic")
//            img.sd_setImage(with: URL(string: linkImage), placeholderImage: UIImage(named: "default_tig_pic"))
//            self.imageViewZoom.image = UIImage(named: "14bis.png")
        }
        self.imageViewZoom.contentMode = .left
        
    }
  /*  func handlePinch(_ recognizer:UIPinchGestureRecognizer){
//    func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
//        if recognizer.state == .ended {
//            print("======== Scale Applied ===========")
//            if recognizer.scale < 1.0 {
//                recognizer.scale = 1.0
//            }
//            let transform = CGAffineTransform(scaleX: recognizer.scale, y: recognizer.scale)
//            self.img.transform = transform
//        }
        self.view.bringSubview(toFront: defaultView)
        recognizer.view?.transform = (recognizer.view?.transform)!.scaledBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1.0
    }*/
    
    // MARK: - Click Methods
    @IBAction func clkBack(sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
//    // MARK: - Scrollview delegate methods
//    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return self.imageView
//    }
//
//    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return self.imageView
//    }
//
//    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//
//    }
}
