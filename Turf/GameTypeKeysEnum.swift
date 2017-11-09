//
//  GameTypeKeysEnum.swift
//  Pickup
//
//  Created by Justin Carver on 5/26/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import Foundation

enum GameTypeKeys {
    case kName
    case kdisplayName
    case ksortOrder
    case kimageName
    
    func key() -> String {
        switch self {
        case .kName:
            return "name"
        case .kdisplayName:
            return "displayName"
        case .ksortOrder:
            return "sortOrder"
        case .kimageName:
            return "imageName"
        }
    }
}
