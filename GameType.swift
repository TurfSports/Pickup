//
//  GameType.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/21/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class GameType {
    
    let id:String
    let name:String
    let displayName:String
    var sortOrder:Int
    let imageName:String
    
    init (id: String, name: String, displayName: String, sortOrder: Int, imageName: String) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.sortOrder = sortOrder
        self.imageName = imageName
    }
    
}