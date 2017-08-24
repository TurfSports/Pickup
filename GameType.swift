//
//  GameType.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/21/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class GameType {
    
    private let kName = "name"
    private let kDisplayName = "displayName"
    private let kSortOrder = "sortOrder"
    private let kImageName = "imageName"
    
    var name: String = ""
    var displayName: String = ""
    var sortOrder: Int = 0
    var imageName: String = ""
    
    var gameCount: Int = 0
    
    init(name: String, displayName: String, sortOrder: Int, imageName: String) {
        self.name = name
        self.displayName = displayName
        self.sortOrder = sortOrder
        self.imageName = imageName
        self.gameCount = 0
    }
    
    func setGameCount(_ count: Int) {
        gameCount = count
    }
    
    func increaseGameCount(_ count: Int) {
        gameCount += count
    }

    init?(dictionary: [String: Any]) {
        guard let name = dictionary[kName] as? String,
        let displayName = dictionary[kDisplayName] as? String,
        let imageName = dictionary[kImageName] as? String,
        let sortOrder = dictionary[kSortOrder] as? Int
        else { return }
    
        self.name = name
        self.displayName = displayName
        self.imageName = imageName
        self.sortOrder = sortOrder
    }
    
    var dictionaryRep: [String: Any] {
        return [kName: name, kSortOrder: sortOrder, kImageName: imageName, kDisplayName: displayName]
    }
    
}
