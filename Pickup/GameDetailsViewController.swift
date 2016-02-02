//
//  GameDetailsViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/1/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import Parse
import MapKit

class GameDetailsViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var gameMap: MKMapView!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblSlotsAvailable: UILabel!
    var game:PFObject!
    let ANNOTATION_ID = "Pin"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let username = game?["owner"]["username"] as? String {
            lblOwner.text = username
        }
        
        if let slotsAvailable = game?["slotsAvailable"] as? Int {
            if let totalSlots = game?["totalSlots"] as? Int {
                lblSlotsAvailable.text = "\(slotsAvailable) / \(totalSlots) slots"
            }
        }
        
        if let latitude:CLLocationDegrees = game?["location"].latitude {
            if let longitude:CLLocationDegrees = game?["location"].longitude {
                let latDelta:CLLocationDegrees = 0.01
                let longDelta:CLLocationDegrees = 0.01
                let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
                
                let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                
                gameMap.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                annotation.title = "Hello"
                
                gameMap.addAnnotation(annotation)
            }
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
    


}
