//
//  Player.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import UIKit

var currentPlayer = Player.init(id: UUID.init().uuidString, firstName: "firstName", lastName: "LastName", userImage: nil, userCreationDate: Date.init(), userImageEndpoint: "nil", createdGames: [], joinedGames: [], age: "age", gender: "Undisclosed", sportsmanship: "nil", skills: [:])

class Player {

    private let kFirstName = "firstName"
    private let kLastInitials = "lastName"
    private let kJoinedGames = "userJoinedGames"
    private let kUserImage = "userImage"
    private let kUserImageEndPoint = "userImageEndpoint"
    private let kAge = "age"
    private let kGender = "gender"
    private let kSportsmanship = "sportsmanship"
    private let kSkills = "skills"
    private let kUserCreationDate = "creationDate"
    private let kCreatedGames = "createdGames"
    
    var id: String
    var firstName: String
    var lastInitials: String
    var userImage: UIImage?
    var userImageEndpoint: String
    var createdGames: [Game]
    var joinedGames: [Game]
    var userCreationDate: Date
    var age: String
    var gender: String
    var sportsmanship: String
    var skills: [String: Any]
    
    init(id: String, firstName: String, lastName: String, userImage: UIImage?, userCreationDate: Date, userImageEndpoint: String, createdGames: [Game], joinedGames: [Game], age: String, gender: String, sportsmanship: String, skills: [String: Any]) {
        
        self.id = id
        self.firstName = firstName
        self.lastInitials = lastName
        self.userImage = userImage
        self.userImageEndpoint = userImageEndpoint
        self.createdGames = createdGames
        self.joinedGames = joinedGames
        self.userCreationDate = userCreationDate
        self.age = age
        self.gender = gender
        self.sportsmanship = sportsmanship
        self.skills = skills
    }
    
    init?(dictionary: [String: Any]) {
        
        guard let id = dictionary.first?.key,
        let firstName = dictionary[kFirstName] as? String,
        let lastName = dictionary[kLastInitials] as? String,
        let userImageEndpoint = dictionary[kUserImage] as? String,
        let joinedGames = dictionary[kJoinedGames] as? [Game],
        let createdGames = dictionary[kCreatedGames] as? [Game],
        let userCreationDate = dictionary[kUserCreationDate] as? Date,
        let age = dictionary[kAge] as? String,
        let gender = dictionary[kGender] as? String
            
        else { return nil }
        
        if let sportsmanship = dictionary[kSportsmanship] as? String {
            self.sportsmanship = sportsmanship
        } else {
            self.sportsmanship = ""
        }
        
        if let skills = dictionary[kSkills] as? [String: Any] {
            self.skills = skills
        } else {
            self.skills = [:]
        }
        
        self.id = id
        self.firstName = firstName
        self.lastInitials = lastName
        self.userImageEndpoint = userImageEndpoint
        self.joinedGames = joinedGames
        self.createdGames = createdGames
        self.userCreationDate = userCreationDate
        self.age = age
        self.gender = gender
        if userImageEndpoint != "" {
            ImageController.imageForURL(url: userImageEndpoint) { (image) in
                self.userImage = image
            }
        }
    }
    
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
    }

    var jsonDictionary: [String: [String: Any]] {
        
        let userCreationDateString = String(describing: userCreationDate)
        
        return [id: [kFirstName: firstName, kLastInitials: lastInitials, kAge: age, kGender: gender, kUserCreationDate: userCreationDateString, kUserImageEndPoint: userImageEndpoint, kJoinedGames: joinedGames, kCreatedGames: createdGames]]
    }
}
