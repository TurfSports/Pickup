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

class NewGameMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIBarPositioningDelegate, UISearchBarDelegate, UITableViewDelegate {

    let ANNOTATION_ID = "Pin"
    let SEGUE_NEW_GAME = "showNewGameTableViewController"
    
    var newGameTableViewDelegate: NewGameTableViewDelegate?
    
    var selectedPin:MKPlacemark? = nil
    var matchingItems:[MKMapItem] = []
    
    var address = ""
    var locationName = ""
    var gameLocation: CLLocationCoordinate2D?
    
    var locationStatus: LocationStatus = .LOCATION_NOT_SET
    let rightNavBarButtonTitle: [LocationStatus: String] = [.LOCATION_NOT_SET: "Set Location", .LOCATION_SET: "Change Location"]
    
    @IBOutlet weak var newGameMap: MKMapView!
    @IBOutlet weak var btnSaveLocation: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var lblTapTip: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewSearchResults: UITableView!
    
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?

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
        
        tableViewSearchResults.hidden = true
        tableViewSearchResults.tableFooterView = UIView(frame: CGRect.zero)
        
        btnCancel.tintColor = Theme.PRIMARY_LIGHT_COLOR
        btnSaveLocation.tintColor = Theme.ACCENT_COLOR
        
        setUsersCurrentLocation()
        setUpMapScreen()
        
    }
    
    private func setUpMapScreen() {
        
        btnSaveLocation.title = rightNavBarButtonTitle[locationStatus]!
        if locationStatus == .LOCATION_SET {
            //TODO: Drop Current Game Location and change button to change location
            //dropGameAnnotation
        } else {
            setGestureRecognizer()
        }
        
    }

    //MARK: - Location Manager Delegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            newGameMap.setRegion(region, animated: true)
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
            locationManager.requestLocation()
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
        
        if pinView == nil && !annotation.isKindOfClass(MKUserLocation) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOTATION_ID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.image = UIImage(named: "annotationIcon")
        }
        
        //TODO: - Consider adding a custom color
        //http://stackoverflow.com/questions/2370567/custon-mkpinannotationcolor
        
        return pinView
        
    }
    
    //MARK: - Search Bar Delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        tableViewSearchResults.hidden = false
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        tableViewSearchResults.hidden = true
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        tableViewSearchResults.hidden = true
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = newGameMap.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableViewSearchResults.reloadData()
        }
    }
    
    //MARK: - Table View Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        
        lblTapTip.hidden = true
        removePreviousAnnotation()
        setAnnotation(selectedItem.coordinate)
        
        self.gameLocation = selectedItem.coordinate
        buildAddressString(selectedItem.coordinate)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(selectedItem.coordinate, span)
        newGameMap.setRegion(region, animated: true)
        
        tableViewSearchResults.hidden = true
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }

    
    //MARK: - Gesture recognizer
    func setGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewGameMapViewController.dropPinOnLocation(_:)))
        newGameMap.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func dropPinOnLocation(gestureRecognizer: UIGestureRecognizer) {
        
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
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
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
