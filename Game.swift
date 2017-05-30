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
    
    private let kGameType:String = "gameType"
    private let kTotalSlots:String = "totalSlots"
    private let kAvailableSlots:String = "availableSlots"
    private let kEventDate:String = "eventDate"
    private let kLocationName:String = "locationName"
    private let kOwnerId:String = "ownerID"
    private let kGameNotes:String = "gameNotes"
    private let kUserJoined:String = "userJoinedBool"
    private let kUserIsOwner:String = "userIsOwnerBool"
    private let kIsCancelled:String = "isCancelledBool"
    private let kLatitude:String = "latitude"
    private let kLongitude:String = "longitude"
    
    var id: String
    var gameType: GameType
    var totalSlots: Int
    var availableSlots: Int
    var eventDate: Date
    var locationName: String
    var ownerId: String
    var gameNotes: String
    lazy var userJoined = false
    lazy var userIsOwner = false
    lazy var isCancelled = false
    lazy var latitude: Double = 0.0
    lazy var longitude: Double = 0.0
    
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
    
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: gameDictionary, options: .prettyPrinted)
    }
    
    var gameDictionary: [String: Any] {
        
        let eventDateString = String(describing: eventDate)
        
        return [id: [kGameType: gameType.dictionaryRep, kTotalSlots: totalSlots, kAvailableSlots: availableSlots, kEventDate: eventDateString, kLocationName: locationName, kOwnerId: ownerId, kGameNotes: gameNotes, kUserJoined: userJoined, kUserIsOwner: userIsOwner, kIsCancelled: isCancelled, kLatitude: latitude, kLongitude: longitude]]
    }
}

