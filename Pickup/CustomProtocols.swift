//
//  CustomProtocols.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/29/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import CoreLocation

protocol NewGameTableViewDelegate {
    func setGameLocationCoordinate(coordinate: CLLocationCoordinate2D)
    func setGameAddress(address: String)
    func setGameLocationName(locationName: String)
}

protocol MyGamesTableViewDelegate {
    func removeGame(game: Game)
}

protocol GameDetailsViewDelegate {
    func setGameAddress(address: String)
    func setGame(game: Game)
}
