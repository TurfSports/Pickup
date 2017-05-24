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
     
        
        let id = gameObject.objectId!
        let gameType = selectedGameType
        let availableSlots = dictionary[GameKeys.kAvailableSlots] as! Int
        let totalSlots = dictionary[GameKeys.kTotalSlots] as! Int
        let eventDate = dictionary[GameKeys.kEventDate] as! Date
        let locationName = dictionary[GameKeys.kLocationName] as! String
        let owner = (dictionary[GameKeys.kOwnerId] as AnyObject).objectId!
        let gameNotes = dictionary[GameKeys.kGameNotes] as! String
        let latitude =  (dictionary[GameKeys.kLatitude]! as AnyObject).latitude
        let longitude = (gameObject[GameKeys.kLongitude]! as AnyObject).longitude
        let game = Game.init(id: id, gameType: gameType, totalSlots: totalSlots, availableSlots: availableSlots, eventDate: eventDate, locationName: locationName, ownerId: owner!, gameNotes: gameNotes)
        
        game.setCoordinates(latitude!, longitude: longitude!)
        
        return game
    }
    
}
