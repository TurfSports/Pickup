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
    
    var gameCountLoaded: Bool = false
    var gameTypeImagesLoaded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgSport?.layer.cornerRadius = Theme.GAME_TYPE_CELL_HEIGHT / 2 - 4
        self.imgSport?.layer.masksToBounds = true
    }
    
    func updateWith(image: UIImage, label: String, and avalibleGames: Int) {
        imgSport.image = image
        lblSport.text = label
        lblAvailableGames.text = "\(avalibleGames)"
    }
    
    func updateWith(image: UIImage) {
        imgSport.image = image
    }
    
    func updateCellWith(gameType: GameType, and image: UIImage?) {
        
        lblSport.text = gameType.displayName
        
        if self.gameCountLoaded {
            if gameType.gameCount > 0 {
                lblAvailableGames.text = "\(gameType.gameCount) games"
            } else {
                lblAvailableGames.text = "No games"
            }
        } else {
            lblAvailableGames.text = ""
        }
        
        if let image = image {
            updateWith(image: image)
        } else if gameTypeImagesLoaded && image == nil {
            let imageName = gameType.imageName.lowercased()
            let realChars = imageName.dropLast(4)
            let iconChar = String.init(realChars) + "Icon"
            imgSport.image = UIImage(named: iconChar)
        } else {
            imgSport.image = nil
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
