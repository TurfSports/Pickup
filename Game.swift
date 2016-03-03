//
//  Game.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import CoreLocation



class Game {
    
    let id:String
    var gameType:GameType
    var totalSlots:Int
    var availableSlots:Int
    var eventDate:NSDate
    var locationName:String
    var ownerId:String
    var gameNotes:String
    lazy var userJoined = false
    lazy var userIsOwner = false
    lazy var latitude:Double = 0.0
    lazy var longitude:Double = 0.0
    
    init (id: String, gameType: GameType, totalSlots: Int,
        availableSlots: Int, eventDate: NSDate, locationName: String,
        ownerId: String, gameNotes: String) {
        self.id = id
        self.gameType = gameType
        self.totalSlots = totalSlots
        self.availableSlots = availableSlots
        self.eventDate = eventDate
        self.locationName = locationName
        self.ownerId = ownerId
        self.gameNotes = gameNotes
    }
    
    func setCoordinates (latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
}