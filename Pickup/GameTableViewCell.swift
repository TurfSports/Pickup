//
//  GameTableViewCell.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/10/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblGameDate: UILabel!
    @IBOutlet weak var imgCheckCircle: UIImageView!
    @IBOutlet weak var lblJoined: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
