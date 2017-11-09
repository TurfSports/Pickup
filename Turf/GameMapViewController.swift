//
//  GameMapViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/13/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import MapKit

class GameMapViewController: UIViewController, MKMapViewDelegate {

    let SEGUE_SHOW_GAME_DETAILS = "showGameDetailsViewController"
    
    @IBOutlet weak var gameMap: MKMapView!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var lblNoGamesToday: UILabel!
    
    let ANNOTATION_ID = "Pin"
    let MAX_LATLON = 180.0
    let MIN_LATLON = -180.0
    
    var games:[Game]!
    var selectedGameType:GameType!
    var selectedGame:Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.title = "Today's Games"
        
        computeViewSettings()
        var todayGameCount = 0
        
        for game in games {
            
            gameMap.showsUserLocation = true
            
            if (Calendar.current as NSCalendar).compare(game.eventDate as Date, to: Date(), toUnitGranularity: .day) == ComparisonResult.orderedSame {
                let location = setLocationOnMap(game.latitude, longitude: game.longitude)
                
                let annotation = GamePointAnnotation()
                annotation.coordinate = location
                annotation.title = game.locationName
                annotation.subtitle = DateUtilities.dateString(game.eventDate,
                    dateFormat: "\(DateFormatter.TWELVE_HOUR_TIME.rawValue)")
                annotation.game = game
                gameMap.addAnnotation(annotation)
                todayGameCount += 1
            }
        }
        
        if todayGameCount == 0 {
            blur.isHidden = false
            lblNoGamesToday.isHidden = false
        }
        
    }

    // MARK: - Map view delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if annotation.isMember(of: MKUserLocation.self) {
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: ANNOTATION_ID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOTATION_ID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        
        let button = UIButton(type: UIButtonType.detailDisclosure) as UIButton // button with info sign in it
        pinView?.rightCalloutAccessoryView = button
        
        //TODO: - Consider adding a custom color 
        //http://stackoverflow.com/questions/2370567/custon-mkpinannotationcolor
        
        return pinView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if let annotation = view.annotation as? GamePointAnnotation {
            self.selectedGame = annotation.game
            if control == view.rightCalloutAccessoryView {
                performSegue(withIdentifier: SEGUE_SHOW_GAME_DETAILS, sender: view)
            }
        }
    }
    
    // MARK: - Private functions
    
    fileprivate func setLocationOnMap(_ latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> CLLocationCoordinate2D {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SEGUE_SHOW_GAME_DETAILS {
            
            let gameDetailsViewController = segue.destination as! GameDetailsViewController
            gameDetailsViewController.game = self.selectedGame
            
            if self.selectedGame.userJoined == true {
                gameDetailsViewController.userStatus = .user_JOINED
            } else {
                gameDetailsViewController.userStatus = .user_NOT_JOINED
            }
            
            gameDetailsViewController.navigationItem.leftItemsSupplementBackButton = true
            
        }
    }

}
