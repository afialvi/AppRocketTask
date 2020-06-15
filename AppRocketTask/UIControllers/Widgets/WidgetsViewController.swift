//
//  WidgetsViewController.swift
//  AppRocketTask
//
//  Created by Muhammad Alvi on 15/06/2020.
//  Copyright © 2020 Muhammad Alvi. All rights reserved.
//

import UIKit

class WidgetsViewController: UIViewController {

    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var latestMsgLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var calendarNextEventTime: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var calendarNextEventTitle: UILabel!
    
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var temperatureInDegreeCentigradeLbl: UILabel!
    
    @IBOutlet weak var topValue: UILabel!
    
    @IBOutlet weak var bottomValueLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func refresh(_ sender: Any) {
    }
    @IBAction func viewInbox(_ sender: Any) {
    }
    
}
