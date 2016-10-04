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
    
    var id:String
    var gameType:GameType
    var totalSlots:Int
    var availableSlots:Int
    var eventDate:Date
    var locationName:String
    var ownerId:String
    var gameNotes:String
    lazy var userJoined = false
    lazy var userIsOwner = false
    lazy var isCancelled = false
    lazy var latitude:Double = 0.0
    lazy var longitude:Double = 0.0
    
    init (id: String, gameType: GameType, totalSlots: Int,
        availableSlots: Int, eventDate: Date, locationName: String,
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
    
    func setCoordinates (_ latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
}
