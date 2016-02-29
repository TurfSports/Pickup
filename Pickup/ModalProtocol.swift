//
//  ModalProtocol.swift
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
}
