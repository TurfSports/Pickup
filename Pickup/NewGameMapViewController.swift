//
//  NewGameMapViewController.swift
//  Pickup
//
//  Created by Nathan Dudley on 2/25/16.
//  Copyright © 2016 Pickup. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NewGameMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    let ANNOTATION_ID = "Pin"
    
    @IBOutlet weak var newGameMap: MKMapView!
    
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation? {
        didSet {
            computeViewSettings()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUsersCurrentLocation()
    }

    //MARK: - Location Manager Delegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        if currentLocation != nil {
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
    
    func setUsersCurrentLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func computeViewSettings() {
        
        let latDelta:CLLocationDegrees = 0.01
        let longDelta:CLLocationDegrees = 0.01
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake((currentLocation?.coordinate.latitude)!, (currentLocation?.coordinate.longitude)!)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        newGameMap.setRegion(region, animated: false)
        
    }
    
    //MARK: - Map View Delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(ANNOTATION_ID) as? MKPinAnnotationView
        
        if pinView == nil {
            //println("Pinview was nil")
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOTATION_ID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        //TODO: - Consider adding a custom color
        //http://stackoverflow.com/questions/2370567/custon-mkpinannotationcolor
        
        return pinView
        
    }
    

    


}
