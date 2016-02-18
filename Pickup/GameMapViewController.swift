//
//  GameMapViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/13/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import MapKit

class GameMapViewController: UIViewController, MKMapViewDelegate, UITabBarControllerDelegate {

    let SEGUE_SHOW_GAME_DETAILS = "showGameDetailsViewController"
    let SEGUE_SHOW_GAMES_LIST = "showGamesList"
    
    @IBOutlet weak var gameMap: MKMapView!
    @IBOutlet weak var tabBar: UITabBar!
    
    
    let ANNOTATION_ID = "Pin"
    let MAX_LATLON = 180.0
    let MIN_LATLON = -180.0
    
    var games:[Game]!
    var selectedGameType:GameType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        computeViewSettings()
        
        tabBar.selectedItem = tabBar.items![1] as UITabBarItem
        tabBar.items![0].tag = 0
        tabBar.items![1].tag = 1
        
        for game in games {
            let location = setLocationOnMap(game.latitude, longitude: game.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = game.locationName
            annotation.subtitle = dateStringForAnnotation(game.eventDate)
            annotation.setValue(game, forKey: "game")
            gameMap.addAnnotation(annotation)
        }
        
    }
    
    //MARK: - Tab bar controller delegate
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print(item.tag)
        if item.tag == 0 {
            performSegueWithIdentifier(SEGUE_SHOW_GAMES_LIST, sender: self)
        }
    }
    

    // MARK: - Map view delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(ANNOTATION_ID) as? MKPinAnnotationView
        
        if pinView == nil {
            //println("Pinview was nil")
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOTATION_ID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        
        let button = UIButton(type: UIButtonType.DetailDisclosure) as UIButton // button with info sign in it
        pinView?.rightCalloutAccessoryView = button
        
        
        return pinView
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // NEEDSWORK: begin editing suggestion for this geoplace
        print("Tapped yo")
        if control == view.rightCalloutAccessoryView {
//            performSegueWithIdentifier("toTheMoon", sender: view)
        }
    }
    
    // MARK: - Private functions
    
    private func setLocationOnMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> CLLocationCoordinate2D {
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        return location
    }
    
    //This method was adapted from Steven Liddle's scripture map app
    func computeViewSettings() {
        if games.count > 0 {
            if games.count == 1 {
                
                let game = games.first!
                
                let latDelta:CLLocationDegrees = 0.01
                let longDelta:CLLocationDegrees = 0.01
                
                let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
                let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(game.latitude, game.longitude)
                
                let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                gameMap.setRegion(region, animated: true)
                
            } else {
                var minLatitude = MAX_LATLON
                var minLongitude = MAX_LATLON
                var maxLatitude = MIN_LATLON
                var maxLongitude = MIN_LATLON
                
                for game in games {
                    if game.latitude < minLatitude { minLatitude = game.latitude }
                    if game.latitude > maxLatitude { maxLatitude = game.latitude }
                    if game.longitude < minLongitude { minLongitude = game.longitude }
                    if game.longitude > maxLongitude { maxLongitude = game.longitude }
                }
                
                let span = MKCoordinateSpanMake( (maxLatitude - minLatitude) * 2,
                    (maxLongitude - minLongitude) * 2 )
                let location = CLLocationCoordinate2D( latitude: (minLatitude + maxLatitude) / 2,
                    longitude: (minLongitude + maxLongitude) / 2 )

                
                let region:MKCoordinateRegion = MKCoordinateRegionMake(location,span)
                gameMap.setRegion(region, animated: true)
            }
        }
    }
    
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            let gameDetailsViewController = segue.destinationViewController as! GameDetailsViewController
//            if let indexPath = tableGameList.indexPathForSelectedRow {
//                gameDetailsViewController.game = games[indexPath.row]
//            }
            gameDetailsViewController.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == SEGUE_SHOW_GAMES_LIST {
            let gameListViewController = segue.destinationViewController as! GameListViewController
            gameListViewController.games = self.games
            gameListViewController.selectedGameType = self.selectedGameType
        }
        
    }
    
    //MARK: - Date functions
    func dateStringForAnnotation(date: NSDate) -> String {
        
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM d - h a"
        
        return dayTimePeriodFormatter.stringFromDate(date)
    }
    
    

}
