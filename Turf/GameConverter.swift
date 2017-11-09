//
//  GameConverter.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/8/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class GameConverter {
    
    static func convert(_ dictionary: [String: Any], to selectedGameType: GameType) -> Game {
     
        
        let id = dictionary.first?.key
        let gameType = selectedGameType
        let availableSlots = dictionary[GameKeys.kAvailableSlots.key()] as! Int
        let totalSlots = dictionary[GameKeys.kTotalSlots.key()] as! Int
        let eventDate = dictionary[GameKeys.kEventDate.key()] as! Date
        let locationName = dictionary[GameKeys.kLocationName.key()] as! String
        let owner = (dictionary[GameKeys.kOwnerId.key()] as! String)
        let gameNotes = dictionary[GameKeys.kGameNotes.key()] as! String
        let latitude =  (dictionary[GameKeys.kLatitude.key()]! as! Double)
        let longitude = (dictionary[GameKeys.kLongitude.key()]! as! Double)
        let userIDs = (dictionary[GameKeys.kUserIDs.key()]! as! [String])
        let game = Game.init(id: id!, gameType: gameType, totalSlots: totalSlots, availableSlots: availableSlots, eventDate: eventDate, locationName: locationName, ownerId: owner, userIDs: userIDs, gameNotes: gameNotes)
        
        game.setCoordinates(latitude, longitude: longitude)
        
        return game
    }
    
}
