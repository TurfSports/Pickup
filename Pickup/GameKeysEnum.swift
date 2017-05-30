//
//  GameKeysEnum.swift
//  Pickup
//
//  Created by Justin Carver on 5/26/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import Foundation

enum GameKeys {
    
    case kGameType
    case kTotalSlots
    case kAvailableSlots
    case kEventDate
    case kLocationName
    case kOwnerId
    case kGameNotes
    case kUserJoined
    case kUserIsOwner
    case kIsCancelled
    case kLatitude
    case kLongitude
    
    func key() -> String {
        switch self {
        case .kGameType:
            return "gameType"
        case .kTotalSlots:
            return "totalSlots"
        case .kAvailableSlots:
            return "availableSlots"
        case .kEventDate:
            return "eventDate"
        case .kLocationName:
            return "locationName"
        case .kOwnerId:
            return "ownerID"
        case .kGameNotes:
            return "gameNotes"
        case .kUserJoined:
            return "userJoinedBool"
        case .kUserIsOwner:
            return "userIsOwnerBool"
        case .kIsCancelled:
            return "isCancelledBool"
        case .kLatitude:
            return "latitude"
        case .kLongitude:
            return "longitude"
        }
    }
}
