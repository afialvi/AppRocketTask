//
//  AllUsersTableViewCell.swift
//  AppRocketTask
//
//  Created by Muhammad Alvi on 14/06/2020.
//  Copyright © 2020 Muhammad Alvi. All rights reserved.
//

import UIKit

class AllUsersTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(user: AppRocketUser){
        self.usernameLbl.text = user.username
    }
    
}
