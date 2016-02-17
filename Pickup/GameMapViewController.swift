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

    @IBOutlet weak var gameMap: MKMapView!
    
    
    let ANNOTATION_ID = "Pin"
    let MAX_LATLON = 180.0
    let MIN_LATLON = -180.0
    
    var games:[Game]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        computeViewSettings()
        
        for game in games {
            let location = setLocationOnMap(game.latitude, longitude: game.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = game.locationName
            gameMap.addAnnotation(annotation)
        }
        

        // Do any additional setup after loading the view.
    }
    

    // MARK: - Map view delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOTATION_ID)
        view.canShowCallout = true
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // NEEDSWORK: begin editing suggestion for this geoplace
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
