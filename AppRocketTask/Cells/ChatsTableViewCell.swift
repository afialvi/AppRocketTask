//
//  ChatsTableViewCell.swift
//  AppRocketTask
//
//  Created by Muhammad Alvi on 16/06/2020.
//  Copyright © 2020 Muhammad Alvi. All rights reserved.
//

import UIKit

class ChatsTableViewCell: UITableViewCell {

    @IBOutlet weak var msgTextLbl: UILabel!
    @IBOutlet weak var contactEmailLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(contact: String, msg: String){
        self.contactEmailLbl.text = contact
        self.msgTextLbl.text = msg
    }
}
