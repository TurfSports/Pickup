//
//  ParseDataController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/9/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class ParseDataController {
    
    var gameTypes:[GameType] = []
    var games:[Game] = []
    
    var gameTypesLoaded:Bool = false {
        didSet {
            print ("LOADED!!!!")
        }
    }
    
    var gamesLoaded:Bool = false {
        didSet {
            
        }
    }
    
    var gameDetailsLoaded:Bool = false {
        didSet {
          
        }
    }
    
    
    init() {}
    
    func getGameTypes() -> [GameType] {
        return []
    }
    
    
    //TODO: Build out data class
    
    //Perhaps this class can control retrieval of all data from Parse
    
}
