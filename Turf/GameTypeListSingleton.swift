//
//  GameTypeListSingleton.swift
//  Pickup
//
//  Created by Nathan Dudley on 3/8/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class GameTypeList {
    
    static let shared = GameTypeList()
    
    var gameTypeList: [GameType] = []
    
    func setGameTypeList(_ gameTypeList: [GameType]) {
        self.gameTypeList = gameTypeList
    }
    
    func getGameTypeBy(name: String) -> GameType? {
        
        for gameType in self.gameTypeList {
            if gameType.name == name {
                return gameType
            }
        }
        
        return nil
        
    }
    
    
    
}
