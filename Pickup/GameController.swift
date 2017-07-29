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
    
    var ref = Database.database().reference()
    
    let endUrl = URL.init(string: "https://pickup-a837a.firebaseio.com")
    
    func put(game: Game, with UUID: UUID, success: @escaping (_ success: Bool) -> Void) {
        ref.child("Games").child(UUID.uuidString).setValue(game.gameDictionary)
        success(true)
        return
    }
    
    func put(game: Game, with UUID: UUID, to url: URL, success: @escaping (_ success: Bool) -> Void) {
        let urlWithUUID = endUrl?.appendingPathComponent("Games").appendingPathComponent(game.id.uuidString).appendingPathExtension("json")
        guard let url = urlWithUUID else { success(false); return }
        NetworkController.performRequest(for: url, httpMethod: .put, body: game.jsonData) { (data, error) in
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
    
    let gameURL = URL(string: "https://pickup-a837a.firebaseio.com/Games")
    let tempURL = URL(string: "")
    
    func loadGames(completion: @escaping (_ games: [Game]) -> Void) {
        
        var gameArray: [Game] = []
        
        ref.child("Games").observeSingleEvent(of: .value, with: { (snapShot) in
            DispatchQueue.main.async {
                guard let jsonObject = snapShot.value as? [String: [String: Any]] else { completion([]); print("Fuck") ; return }
                
                var gameNumber = 0
                
                for game in jsonObject {
                    gameNumber += 1
                    guard let game = Game(gameDictionary: game.value) else { completion([]); print("Game #\(gameNumber) can't initialize"); continue }
                    gameArray.append(game)
                }
                completion(gameArray)
            }
        })
    }
    
    func loadGames(from url: URL, completion: @escaping (_ games: [Game]) -> Void) {
        
        var gameArray: [Game] = []
        guard let url = self.gameURL?.appendingPathExtension("json") else { completion([]); return }
        
        NetworkController.performRequest(for: url, httpMethod: .get, urlParameters: nil, body: nil) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else { completion([]); return }
                guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: [String: Any]] else { completion([]); print("Fuck") ; return }
                
                var gameNumber = 0
                
                for game in jsonDictionary {
                    gameNumber += 1
                    guard let game = Game(gameDictionary: game.value) else { completion([]); print("Game #\(gameNumber) can't initialize"); continue }
                    gameArray.append(game)
                }
                completion(gameArray)
            }
        }
    }
}
