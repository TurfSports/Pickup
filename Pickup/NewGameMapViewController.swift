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

class NewGameMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIBarPositioningDelegate {

    let ANNOTATION_ID = "Pin"
    let SEGUE_NEW_GAME = "showNewGameTableViewController"
    
    var newGameTableViewDelegate: NewGameTableViewDelegate?
    
    var address = ""
    var locationName = ""
    var gameLocation: CLLocationCoordinate2D?
    
    
    @IBOutlet weak var newGameMap: MKMapView!
    @IBOutlet weak var btnSaveLocation: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var lblTapTip: UILabel!
    
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation? {
        didSet {
            computeViewSettings()
        }
    }

    @IBAction func cancelModal(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveLocation(sender: UIBarButtonItem) {
        
        if address == "" {
            //TODO: Make an alert that no location was selected
        } else {
            newGameTableViewDelegate?.setGameLocationCoordinate(self.gameLocation!)
            newGameTableViewDelegate?.setGameAddress(self.address)
            newGameTableViewDelegate?.setGameLocationName(self.locationName)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnCancel.tintColor = Theme.PRIMARY_LIGHT_COLOR
        btnSaveLocation.tintColor = Theme.ACCENT_COLOR
        
        if self.gameLocation != nil {
            btnSaveLocation.title = "Change Location"
            //TODO: Drop geo point of currently selected location
        }
        
        setGestureRecognizer()
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
//        print("error:: \(error)")
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
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOTATION_ID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        //TODO: - Consider adding a custom color
        //http://stackoverflow.com/questions/2370567/custon-mkpinannotationcolor
        
        return pinView
        
    }
    
    //MARK: - Gesture recognizer
    func setGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "action:")
        newGameMap.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func action(gestureRecognizer: UIGestureRecognizer) {
        
        let touchPoint = gestureRecognizer.locationInView(self.newGameMap)
        let coordinate: CLLocationCoordinate2D = newGameMap.convertPoint(touchPoint, toCoordinateFromView: self.newGameMap)
        
        lblTapTip.hidden = true
        removePreviousAnnotation()
        setAnnotation(coordinate)
        
        self.gameLocation = coordinate
        buildAddressString(coordinate)
    }
    
    func setAnnotation(coordinate: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        self.newGameMap.addAnnotation(annotation)
        
    }
    
    func removePreviousAnnotation() {
        let annotations = self.newGameMap.annotations
        self.newGameMap.removeAnnotations(annotations)
    }
    
    func buildAddressString(coordinate: CLLocationCoordinate2D) {
        
        let geoCoder = CLGeocoder()
        let gameLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(gameLocation, completionHandler: { (placemarks, error) -> Void in
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            self.address = ""
            
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                self.address = self.address + "\(locationName)"
                self.locationName = locationName as String
            }
            
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                self.address = self.address + "\n\(city)"
                
            }
            
            if let state = placeMark.addressDictionary!["State"] as? NSString {
                self.address = self.address + ", \(state)"
                
            }
            
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                self.address = self.address + " \(zip)"
            }
            
        })
        
    }
    
    //MARK: - Bar Positioning Delegate
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    
    
    
    
    

    


}
