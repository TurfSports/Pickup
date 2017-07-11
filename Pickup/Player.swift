//
//  Player.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import UIKit

class Player {
    
    private let kUserName = "name"
    private let kJoinedGames = "joinedGames"
    private let kUserImage = "userJoined"
    
    let id: String
    var userName: String
    var userImage: UIImage?
    var userImageEndpoint: String
    var joinedGames: [Game]
    
    init(id:String, username: String, userImage: UIImage?, joinedGames: [Game], userImageEndpoint: String) {
        self.id = id
        self.userName = username
        self.userImage = userImage
        self.joinedGames = joinedGames
        self.userImageEndpoint = userImageEndpoint
    }
    
    init?(dictionary: [String: Any]) {
        
        guard let id = dictionary.first?.key,
        let userName = dictionary[kUserName] as? String,
        let joinedGames = dictionary[kJoinedGames] as? [Game],
        let userImageEndpoint = dictionary[kUserImage] as? String
            
        else { return nil }
        
        self.id = id
        self.userName = userName
        self.joinedGames = joinedGames
        self.userImageEndpoint = userImageEndpoint
        ImageController.imageForURL(url: userImageEndpoint) { (image) in
            self.userImage = image
        }
    }
}
