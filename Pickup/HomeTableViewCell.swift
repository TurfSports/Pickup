//
//  HomeTableViewCell.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/1/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import ParseUI

class HomeTableViewCell: PFTableViewCell {

    
    @IBOutlet weak var imgSport: UIImageView!
    @IBOutlet weak var lblSport: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imgSport?.layer.cornerRadius = Theme.GAME_TYPE_CELL_HEIGHT / 2 - 4
//        print("Height: \(self.imgSport.bounds.height), Width \(self.imgSport.bounds.width)")
        self.imgSport?.layer.masksToBounds = true
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
