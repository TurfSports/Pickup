//
//  GameController.swift
//  Pickup
//
//  Created by Justin Carver on 5/23/17.
//  Copyright © 2017 Pickup. All rights reserved.
//

import Foundation
import Firebase

class GameController {
    
    static let shared = GameController()
    
    let ref = Database.database().reference().child("Games")
    let endURL = URL(string: "https://turf-sports.firebaseio.com/Games")
    let tempURL = URL(string: "")
    
    //==========================================================================
    //  MARK: - Put Methods
    //==========================================================================
    
    // Put with firebase
    
    func put(game: Game, with UUIDString: String, success: @escaping (_ success: Bool) -> Void) {
        ref.child(game.gameType.name).child(UUIDString).setValue(game.gameDictionary)
        success(true)
        return
    }
    
    // Put to url
    
    func put(game: Game, with UUIDString: String, to url: URL?, success: @escaping (_ success: Bool) -> Void) {
        
        let newUrl: URL
        
        if url == nil {
            newUrl = endURL!
        } else {
            newUrl = url!
        }
        
        let urlWithUUID = newUrl.appendingPathComponent(game.gameType.name).appendingPathComponent(UUIDString).appendingPathExtension("json")
        
        NetworkController.performRequest(for: urlWithUUID, httpMethod: .put, body: game.jsonData) { (data, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    success(false)
                    return
                } else {
                    success(true)
                    print("Put Game Info")
                    return
                }
            }
        }
    }
    
    //==========================================================================
    //  MARK: - Load Game Methods
    //==========================================================================
    
    // Load with firebase
    
    func loadGames(of gameType: GameType, completion: @escaping (_ games: [Game]) -> Void) {
        var arrayOfGameType: [Game] = []
        
        ref.child(gameType.name).observeSingleEvent(of: .value, with: { (snapShot) in
            DispatchQueue.main.async {
                guard let jsonObject = snapShot.value as? [String: [String: Any]] else { completion([]); print("Fuck") ; return }
                
                var gameNumber = 0
                var loadedGames = 0
                
                for game in jsonObject {
                    gameNumber += 1
                    guard let game = Game(gameDictionary: game.value) else { completion([]); print("Game #\(gameNumber) can't initialize"); continue }
                    loadedGames += 1
                    arrayOfGameType.append(game)
                }
                gameType.gameCount = loadedGames
                completion(arrayOfGameType)
            }
        })
    }
    
    func loadGames(completion: @escaping (_ games: [Game]) -> Void) {
        
        var gameArray: [Game] = []
        
        ref.observeSingleEvent(of: .value, with: { (snapShot) in
            DispatchQueue.main.async {
                guard let jsonObject = snapShot.value as? [String: [String: Any]] else { completion([]); print("Fuck") ; return }
                
                var jsonGameTypes: [[String: Any]] = []
                
                for jsonGameTypeDictionary in jsonObject {
                    jsonGameTypes.append(jsonGameTypeDictionary.value)
                }
                
                var gameNumber = 0
                
                for arrayOfGames in jsonGameTypes {
                    gameNumber += 1
                    for games in arrayOfGames {
                        guard let value = games.value as? [String: Any] else { print("Game #\(gameNumber) can't initialize"); continue }
                        guard let game = Game(gameDictionary: value) else { print("Game #\(gameNumber) can't initialize"); continue }
                        gameArray.append(game)
                    }
                }
                completion(gameArray)
            }
        })
    }
    
    // load from url
    
    func loadGames(from url: URL, of gameType: GameType, completion: @escaping (_ games: [Game]) -> Void) {
        
        var arrayOfGameType: [Game] = []
        guard let url = self.endURL?.appendingPathComponent(gameType.name).appendingPathComponent("json") else { completion([]); return }
        
        NetworkController.performRequest(for: url, httpMethod: .get, urlParameters: nil, body: nil) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else { completion([]); return }
                guard let jsonObject = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: [String: Any]] else { completion([]); print("Fuck") ; return }
                
                var gameNumber = 0
                var loadedGames = 0
                
                for game in jsonObject {
                    gameNumber += 1
                    guard let game = Game(gameDictionary: game.value) else { completion([]); print("Game #\(gameNumber) can't initialize"); continue }
                    loadedGames += 1
                    arrayOfGameType.append(game)
                }
                gameType.gameCount = loadedGames
                completion(arrayOfGameType)
            }
        }
    }
    
    func loadGames(from url: URL, completion: @escaping (_ games: [Game]) -> Void) {
        
        var gameArray: [Game] = []
        guard let url = self.endURL?.appendingPathExtension("json") else { completion([]); return }
        
        NetworkController.performRequest(for: url, httpMethod: .get, urlParameters: nil, body: nil) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else { completion([]); return }
                guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: [String: Any]] else { completion([]); print("Fuck") ; return }
                
                var jsonGameTypes: [[String: Any]] = []
                
                for jsonGameTypeDictionary in jsonDictionary {
                    jsonGameTypes.append(jsonGameTypeDictionary.value)
                }
                
                var gameNumber = 0
                
                for arrayOfGames in jsonGameTypes {
                    for games in arrayOfGames {
                        gameNumber += 1
                        guard let value = games.value as? [String: Any] else { print("Game #\(gameNumber) can't initialize"); continue }
                        guard let game = Game(gameDictionary: value) else { print("Game #\(gameNumber) can't initialize"); continue }
                        game.gameType.gameCount += 1
                        gameArray.append(game)
                    }
                }
                completion(gameArray)
            }
        }
    }
}
