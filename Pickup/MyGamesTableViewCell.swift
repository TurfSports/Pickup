//
//  MyGamesTableViewCell.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/2/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

class MyGamesTableViewCell: UITableViewCell {

    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblGameDate: UILabel!
    @IBOutlet weak var imgGameType: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imgGameType?.layer.cornerRadius = Theme.GAME_TYPE_CELL_HEIGHT / 3 + 2
        self.imgGameType?.layer.masksToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
