//
//  Player.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import UIKit

let defaultPlayer = Player.init(id: UUID.init().uuidString, firstName: "firstName", lastName: "LastName", userImage: nil, userCreationDate: Date.init(), userImageEndpoint: "nil", createdGames: [], joinedGames: [], age: "age", gender: "undisclosed", sportsmanship: "nil", skills: [:])

class Player {

    private let kFirstName = "FirstName"
    private let kLastName = "LastName"
    private let kJoinedGames = "UserJoinedGames"
    private let kUserImage = "UserImage"
    private let kUserImageEndPoint = "UserImageEndpoint"
    private let kAge = "Age"
    private let kGender = "Gender"
    private let kSportsmanship = "Sportsmanship"
    private let kSkills = "Skills"
    private let kUserCreationDate = "UserCreationDate"
    private let kCreatedGames = "CreatedGames"
    
    let id: String
    let firstName: String
    let lastName: String
    var userImage: UIImage?
    var userImageEndpoint: String
    var createdGames: [Game]
    var joinedGames: [Game]
    let userCreationDate: Date
    let age: String
    let gender: String
    var sportsmanship: String
    var skills: [String: Any]
    
    init(id: String, firstName: String, lastName: String, userImage: UIImage?, userCreationDate: Date, userImageEndpoint: String, createdGames: [Game], joinedGames: [Game], age: String, gender: String, sportsmanship: String, skills: [String: Any]) {
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
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
        let lastName = dictionary[kLastName] as? String,
        let userImageEndpoint = dictionary[kUserImage] as? String,
        let joinedGames = dictionary[kJoinedGames] as? [Game],
        let createdGames = dictionary[kCreatedGames] as? [Game],
        let userCreationDate = dictionary[kUserCreationDate] as? Date,
        let age = dictionary[kAge] as? String,
        let gender = dictionary[kGender] as? String,
        let sportsmanship = dictionary[kSportsmanship] as? String,
        let skills = dictionary[kSkills] as? [String: Any]
            
        else { return nil }
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.userImageEndpoint = userImageEndpoint
        self.joinedGames = joinedGames
        self.createdGames = createdGames
        self.userCreationDate = userCreationDate
        self.age = age
        self.gender = gender
        self.sportsmanship = sportsmanship
        self.skills = skills
        ImageController.imageForURL(url: userImageEndpoint) { (image) in
            self.userImage = image
        }
    }
}
