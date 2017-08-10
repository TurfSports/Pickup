//
//  Player.swift
//  Pickup
//
//  Created by Nathan Dudley on 1/22/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import UIKit

var currentPlayer = Player.init(id: UUID.init().uuidString, email: "", firstName: "firstName", lastName: "LastName", userImage: nil, userCreationDate: Date.init(), userImageEndpoint: "nil", createdGames: [], joinedGames: [], age: "age", gender: "Undisclosed", sportsmanship: "nil", skills: [:])

class Player {

    private let kEmail = "Email"
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
    private let kPassword = "Password"
    
    var id: String
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    var userImage: UIImage?
    var userImageEndpoint: String
    var createdGames: [Game]
    var joinedGames: [Game]
    var userCreationDate: Date
    var age: String
    var gender: String
    var sportsmanship: String
    var skills: [String: Any]
    
    init(id: String, email: String, password: String = "", firstName: String, lastName: String, userImage: UIImage?, userCreationDate: Date, userImageEndpoint: String, createdGames: [Game], joinedGames: [Game], age: String, gender: String, sportsmanship: String, skills: [String: Any]) {
        
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
        self.email = email
        self.password = password
    }
    
    init?(dictionary: [String: Any]) {
        
        guard let id = dictionary.first?.key,
        let email = dictionary[kEmail] as? String,
        let password = dictionary[kPassword] as? String,
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
        self.email = email
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
        self.password = password
        ImageController.imageForURL(url: userImageEndpoint) { (image) in
            self.userImage = image
        }
    }
}
