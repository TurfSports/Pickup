//
//  ParseDataController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/9/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import Parse

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
        loadGameTypesFromParse()
        return gameTypes
    }
    
    
    //TODO: Build out data class
    
    //Perhaps this class can control retrieval of all data from Parse
    
    fileprivate func loadGameTypesFromParse() {
        var gameTypes:[GameType] = []
        let gameTypeQuery = PFQuery(className: "GameType")
        
        gameTypeQuery.findObjectsInBackground { (objects, error) -> Void in
            
            if let gameTypeObjects = objects {
                
                gameTypes.removeAll(keepingCapacity: true)
                
                for gameTypeObject in gameTypeObjects {
                    let gameType = GameTypeConverter.convertParseObject(gameTypeObject)
                    gameTypes.append(gameType)
                    self.gameTypesLoaded = true
                }
            }
            

        }
    }
    
    

    
    
    
}
