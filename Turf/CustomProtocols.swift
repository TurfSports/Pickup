//
//  CustomProtocols.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/29/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

protocol NewGameTableViewDelegate {
    func setGameLocationCoordinate(_ coordinate: CLLocationCoordinate2D)
    func setGameAddress(_ address: String)
    func setGameLocationName(_ locationName: String)
}

protocol MyGamesTableViewDelegate {
    func removeGame(_ game: Game)
}

protocol GameDetailsViewDelegate {
    func setGameAddress(_ address: String)
    func setGame(_ game: Game)
    func cancelGame(_ game: Game)
}

protocol MainSettingsDelegate {
    func update(settings: Settings)
}


//http://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
protocol HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

//https://sectionfive.net/blog/2015/10/23/a-swift-solution-to-view-dismissal/

protocol DismissalDelegate {
    func finishedShowing(_ viewController: UIViewController);
    func setNewGame(_ game: Game)
}

protocol Dismissable {
    var dismissalDelegate : DismissalDelegate? { get set }
}




