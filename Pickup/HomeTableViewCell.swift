//
//  HomeTableViewCell.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/1/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgSport: UIImageView!
    @IBOutlet weak var lblSport: UILabel!
    @IBOutlet weak var lblAvailableGames: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imgSport?.layer.cornerRadius = Theme.GAME_TYPE_CELL_HEIGHT / 2 - 4
        self.imgSport?.layer.masksToBounds = true
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
