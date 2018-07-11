//
//  TermsConditions.swift
//  TradeInGurus
//
//  Created by Admin on 14/10/17.
//  Copyright © 2017 cearsinfotech. All rights reserved.
//

import UIKit

class TermsCell: UITableViewCell
{
    @IBOutlet var lblNumber : UILabel!
    @IBOutlet var lblDescription : UILabel!
}

class TermsConditions: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tblTermsCond: UITableView!
    var arrTerms : NSMutableArray = NSMutableArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tblTermsCond.estimatedRowHeight = 40
        self.tblTermsCond.rowHeight = UITableViewAutomaticDimension
        setData()
    }
    
    //MARK: - Table View Delegate And DataSource Method
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arrTerms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : TermsCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TermsCell
        cell.lblNumber.text = "\(indexPath.row+1)"
        cell.lblDescription.text = arrTerms.object(at: indexPath.row) as? String
        return cell
    }

    @IBAction func btnBack(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setData()
    {
        arrTerms.add("The Intellectual Property disclosure will inform users that the contents, logo and other visual media you created is your property and is protected by copyright laws.")
        arrTerms.add("A Termination clause will inform that users’ accounts on your website and mobile app or users’ access to your website and mobile (if users can’t have an account with you) can be terminated in case of abuses or at your sole discretion.")
        arrTerms.add("A Governing Law will inform users which laws govern the agreement. This should the country in which your company is headquartered or the country from which you operate your website and mobile app.")
        arrTerms.add("A Links To Other Web Sites clause will inform users that you are not responsible for any third party websites that you link to. This kind of clause will generally inform users that they are responsible for reading and agreeing (or disagreeing) with the Terms and Conditions or Privacy Policies of these third parties.")
        arrTerms.add("If your website or mobile app allows users to create content and make that content public to other users, a Content section will " +         "inform users that they own the rights to the content they have created.\n" +         "The “Content” clause usually mentions that users must give you (the website or mobile app developer) a license so that you can " +         "share this content on your website/mobile app and to make it available to other users.")
        arrTerms.add("All copyright, trade marks, design rights, patents and other intellectual property rights (registered and unregistered) in and on BBC Online Services and BBC Content belong to the BBC and/or third parties (which may include you or other users.) The BBC reserves all of its rights in BBC Content and BBC Online Services. Nothing in the Terms grants you a right or license to use any trade mark, design right or copyright owned or controlled by the BBC or any other third party except as expressly provided in the Terms.")
        arrTerms.add("Copyright in the content of our publications and this website is owned by The List, or under agreement from a copyright owning partner, or under other rights you have granted us. All rights are reserved and are protected by copyright, database, design and other rights. The content (“Our Content”) of our publications, apps and websites include editorial and listings, advertising and comments, reviews, photos, videos, sound, data and any other material that users of the services or readers of our publications contribute. You may not modify, publish, transmit, participate in the transfer or sale of, create derivative works, or in any way exploit any of Our Content in whole or in part without the prior written agreement of The List. All permitted copying, redistribution or publication of Our Content, shall require the user to agree that there shall be no changes in or deletion of author attribution, trademark legend, copyright or other rights notice and shall include links to this website.")
        arrTerms.add("Our data includes business email addresses. These are provided solely for the purpose of assisting consumers with customer service matters and other activities as indicated. You agree not to compile any email lists nor to use such addresses for marketing any product or service.")
        arrTerms.add("The List provides the content in good faith but no guarantee or representation is given that the content is accurate, complete or up-to-date. Use of content on the website is at your own risk.")
        arrTerms.add("These terms and conditions may be modified from time to time. Continued access or use of the Service by you will constitute your acceptance of any changes or revisions to these terms and conditions.")
    }

}
