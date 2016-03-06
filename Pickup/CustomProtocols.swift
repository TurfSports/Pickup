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
    func cancelGame(game: Game)
}

//https://sectionfive.net/blog/2015/10/23/a-swift-solution-to-view-dismissal/

protocol DismissalDelegate {
    func finishedShowing(viewController: UIViewController);
    func setNewGame(game: Game)
}

protocol Dismissable {
    var dismissalDelegate : DismissalDelegate? { get set }
}

//extension DismissalDelegate where Self: UIViewController
//{
//    
//    func finishedShowing(viewController: UIViewController) {
//        
//            self.dismissViewControllerAnimated(true, completion: nil)
//            performSegueWithIdentifier("showGameDetailsViewController", sender: self)
//        
//            return
////        }
//        
////        self.navigationController?.popViewControllerAnimated(true)
//    }
//}
