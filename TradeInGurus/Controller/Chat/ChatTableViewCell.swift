//
//  ChatTableViewCell.swift
//  TradeInGurus
//
//  Created by Admin on 28/11/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import Foundation

class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

class SenderCell : UITableViewCell {
    
    @IBOutlet var imgSenderUser : RoundedImageView!
    @IBOutlet var lblSenderMsg : UILabel!
    @IBOutlet var viewSenderMsgBackgroung : UIView!
    @IBOutlet var lbl_sender_timeStamp: UILabel!
    @IBOutlet var ImgSenderImg : UIImageView!
}

class ReciverCell : UITableViewCell {
    @IBOutlet var imgReciverUser : RoundedImageView!
    @IBOutlet var lblReciverMsg : UILabel!
    @IBOutlet var viewReciverMsgBackgroung : UIView!
    @IBOutlet var lbl_timeStamp: UILabel!
    @IBOutlet var ImgReciverImg : UIImageView!
}

