//
//  DummyDataController.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation

class DummyDataController {
    
    lazy var games:[String: Game] = [:]
    lazy var players:[String: Player] = [:]
    lazy var gameType:[String: GameType] = [:]
    
    init () {
        let player1:Player = Player.init(username: "ndudley")
        let player2:Player = Player.init(username: "jcarlson")
        let player3:Player = Player.init(username: "johnnyk")
        let player4:Player = Player.init(username: "cougarfan")
        let player5:Player = Player.init(username: "cschow3")
        let player6:Player = Player.init(username: "malik")
        
        
        players["\(player1.username)"] = player1
        players["\(player2.username)"] = player2
        players["\(player3.username)"] = player3
        players["\(player4.username)"] = player4
        players["\(player5.username)"] = player5
        players["\(player6.username)"] = player6

    
        let basketball:GameType = GameType.init(id: "1", name: "basketball", displayName: "Basketball", sortOrder: 1, imageName: "basketballIcon")
        let soccer:GameType = GameType.init(id: "2", name: "soccer", displayName: "Soccer", sortOrder: 2, imageName: "soccerIcon")
        let baseball:GameType = GameType.init(id: "3", name: "baseball", displayName: "Baseball", sortOrder: 3, imageName: "baseballIcon")
        
        gameType["\(basketball.id)"] = basketball
        gameType["\(soccer.id)"] = soccer
        gameType["\(baseball.id)"] = baseball
        
        
        let game1: Game = Game.init(id: "100", gameType: soccer, gameSizeInPlayers: 10, availableSlots: 3, eventDate: NSDate(), owner: player1, location: 5)
        let game2: Game = Game.init(id: "200", gameType: soccer,  gameSizeInPlayers: 20, availableSlots: 6, eventDate: NSDate(), owner: player2, location: 7)
        let game3: Game = Game.init(id: "300", gameType: soccer,  gameSizeInPlayers: 30, availableSlots: 9, eventDate: NSDate(), owner: player2, location: 8)
        let game4: Game = Game.init(id: "400", gameType: basketball,  gameSizeInPlayers: 5, availableSlots: 4, eventDate: NSDate(), owner: player2, location: 9)
        let game5: Game = Game.init(id: "500", gameType: basketball,  gameSizeInPlayers: 15, availableSlots: 8, eventDate: NSDate(), owner: player2, location: 10)
        let game6: Game = Game.init(id: "600", gameType: basketball,  gameSizeInPlayers: 25, availableSlots: 12, eventDate: NSDate(), owner: player2, location: 11)
        let game7: Game = Game.init(id: "700", gameType: baseball,  gameSizeInPlayers: 8, availableSlots: 5, eventDate: NSDate(), owner: player2, location: 12)
        let game8: Game = Game.init(id: "800", gameType: baseball,  gameSizeInPlayers: 16, availableSlots: 10, eventDate: NSDate(), owner: player2, location: 13)
        let game9: Game = Game.init(id: "900", gameType: baseball,  gameSizeInPlayers: 24, availableSlots: 15, eventDate: NSDate(), owner: player2, location: 14)
        
        games[game1.id] = game1
        games[game2.id] = game2
        games[game3.id] = game3
        games[game4.id] = game4
        games[game5.id] = game5
        games[game6.id] = game6
        games[game7.id] = game7
        games[game8.id] = game8
        games[game9.id] = game9
        
        
    }
    
}