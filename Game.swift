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
    
    private let kGameID: String = "uid"
    private let kGameType: String = "gameType"
    private let kTotalSlots: String = "totalSlots"
    private let kAvailableSlots: String = "slotsAvailable"
    private let kEventDate: String = "date"
    private let kLocationName: String = "locationName"
    private let kOwnerId: String = "ownerUid"
    private let kGameNotes: String = "notes"
    private let kIsCancelled: String = "isCancelled"
    private let kLatitude: String = "latitude"
    private let kLongitude: String = "longitude"
    private let kUserIDs: String = "playerIDs"
    
    var id: String = UUID.init().uuidString
    var userIDs: [String]
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
    
    init(id: String, gameType: GameType, totalSlots: Int,
        availableSlots: Int, eventDate: Date, locationName: String,
        ownerId: String, userIDs: ([String]), gameNotes: String) {
        self.id = id
        self.gameType = gameType
        self.totalSlots = totalSlots
        self.availableSlots = availableSlots
        self.eventDate = eventDate
        self.locationName = locationName
        self.ownerId = ownerId
        self.gameNotes = gameNotes
        self.userIDs = [ownerId]
    }
    
    init?(gameDictionary: [String: Any]) {
        
        guard let id = gameDictionary[kGameID] as? String,
        let gameTypeValue = gameDictionary[kGameType] as? [String: Any],
        let gameType = GameType.init(dictionary: gameTypeValue),
        let totalSlots = gameDictionary[kTotalSlots] as? Int,
        let availableSlots = gameDictionary[kAvailableSlots] as? Int,
        let locationName = gameDictionary[kLocationName] as? String,
        let ownerId = gameDictionary[kOwnerId] as? String,
        let gameNotes = gameDictionary[kGameNotes] as? String,
        let isCancelled = gameDictionary[kIsCancelled] as? Bool,
        let latitude = gameDictionary[kLatitude] as? Double,
        let longitude = gameDictionary[kLongitude] as? Double,
        let eventDate = gameDictionary[kEventDate] as? String,
        let userIDs = gameDictionary[kUserIDs] as? [String]
        
        else { return nil }
        
        self.userIDs = userIDs
        self.id = id
        self.gameType = gameType
        self.totalSlots = totalSlots
        self.availableSlots = availableSlots
        self.eventDate = DateUtilities.dateFrom(eventDate, dateFormat: "")
        self.locationName = locationName
        self.ownerId = ownerId
        self.gameNotes = gameNotes
        self.isCancelled = isCancelled
        self.latitude = latitude
        self.longitude = longitude
        if userIDs.contains(currentPlayer.id) {
            self.userJoined = true
        }
        if currentPlayer.id == ownerId {
            self.userIsOwner = true
        } else {
            self.userIsOwner = false
        }
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
        
        return [kGameID: id, kGameType: gameType.dictionaryRep, kTotalSlots: totalSlots, kAvailableSlots: availableSlots, kEventDate: eventDateString, kLocationName: locationName, kOwnerId: ownerId, kGameNotes: gameNotes, kIsCancelled: isCancelled, kLatitude: latitude, kLongitude: longitude, kUserIDs: userIDs]
    }
}

