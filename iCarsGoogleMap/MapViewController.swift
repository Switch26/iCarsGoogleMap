//
//  MapViewController.swift
//  iCarsGoogleMap
//
//  Created by Serguei Vinnitskii on 10/26/16.
//  Copyright © 2016 Serguei Vinnitskii. All rights reserved.
//

import UIKit
import CoreLocation
import SlideMenuControllerSwift
import Toast_Swift
import GoogleMaps



class MapViewController: UIViewController, LeftMenuDelegate, CLLocationManagerDelegate {
    
    var leftMenuVC: LeftMenuViewController?
    var mapView: GMSMapView?
    var locationManager = CLLocationManager()
    var myLocation = CLLocation()
    let sanFranciscoLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    let newYorkLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0059)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftMenuVC = slideMenuController()?.leftViewController as? LeftMenuViewController
        leftMenuVC?.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        enableGoogleMap()
    }
    
    func enableGoogleMap() {
        let camera = GMSCameraPosition.camera(withLatitude: sanFranciscoLocation.latitude, longitude: sanFranciscoLocation.longitude, zoom: 4.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
    }
    
    func updateMapWith(location: CLLocation) { // helper method
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 8.0)
        mapView?.animate(to: camera) // with animation
        //mapView?.camera = camera // no animation
    }
    
    func addMarkerToLocation(location: CLLocationCoordinate2D, withTitle: String, clearPreviousMarkers: Bool) { // helper method
        if clearPreviousMarkers == true {
            mapView?.clear()
        }
        
        let marker = GMSMarker()
        marker.position = location
        marker.title = withTitle
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView
    }
    
    
    //MARK: Left Slide Menu delegate methods
    func sanFrancisoButtonPressed() {
        slideMenuController()?.closeLeft()
        updateMapWith(location: CLLocation(latitude: sanFranciscoLocation.latitude, longitude: sanFranciscoLocation.longitude))
        addMarkerToLocation(location: sanFranciscoLocation, withTitle: "San Francisco", clearPreviousMarkers: true)
    }
    
    func newYorkButtonPressed() {
        slideMenuController()?.closeLeft()
        updateMapWith(location: CLLocation(latitude: newYorkLocation.latitude, longitude: newYorkLocation.longitude))
        addMarkerToLocation(location: newYorkLocation, withTitle: "New York", clearPreviousMarkers:  true)
    }
    
    func fromSFtoNYButtonPressed() {
        slideMenuController()?.closeLeft()
        
        let originString = "\(sanFranciscoLocation.latitude), \(sanFranciscoLocation.longitude)"
        let destinationString = "\(newYorkLocation.latitude), \(newYorkLocation.longitude)"
        view.makeToastActivity(.center) // activity indicator
        
        NetworkManager.getDrivingRoutePointsBetween(origin: originString, destination: destinationString) { (encodedPoints: String?) in
            
            if let encodedPath = encodedPoints {
                
                let path = GMSMutablePath(fromEncodedPath: encodedPath)
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = self.view.tintColor
                polyline.strokeWidth = 3.0
                polyline.map = self.mapView
                
                let bounds = GMSCoordinateBounds(coordinate: self.sanFranciscoLocation, coordinate: self.newYorkLocation)
                let camera = self.mapView?.camera(for: bounds, insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
                if let validCamera = camera {
                    DispatchQueue.main.async {
                        self.mapView?.animate(to: validCamera)
                        self.view.hideToastActivity() // hide activity indicator
                    }
                }
                
                self.addMarkerToLocation(location: self.sanFranciscoLocation, withTitle: "San Francisco", clearPreviousMarkers: false)
                self.addMarkerToLocation(location: self.newYorkLocation, withTitle: "New York", clearPreviousMarkers:  false)
            
            } else { // network problem
                self.showAlert(withTitle: "Error", message: "There was a problem downloading driving route from the Google Server")
            }
        }
    }
    
    
    //MARK: CoreLocation delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        
        view.hideToastActivity() // Remove activity indicator
        myLocation = CLLocation(latitude: locationObj.coordinate.latitude, longitude: locationObj.coordinate.longitude)
        
        // Update Google Map with my location
        mapView?.isMyLocationEnabled = true
        updateMapWith(location: myLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined: // First launch
            print("Location NotDetermined")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse: // Usual case
            print("AuthorizedWhenInUse")
            locationManager.requestLocation()
            view.makeToastActivity(.center) // activity indicator
            view.makeToast("Obtaining location...", duration: 1.0, position: CGPoint(x: view.frame.width/2, y: view.frame.height/2 - 80))
        case .denied:
            print("Location Denied")
            let alertController = UIAlertController(title: "Cannot Obtain Location", message: "Location share has been denied. To enable, please go to your phone SETTINGS and enable location usage for this app", preferredStyle: .alert)
            let bringToSettings = UIAlertAction(title: "Bring me to Settings", style: .default, handler: { (_) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                } else {
                    self.view.makeToast("Oops... coudn't bring you to settings", duration: 2.0, position: .center)
                }
            })
            alertController.addAction(bringToSettings)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
            break
        case .restricted:
            print("Location share has been restricted")
            showAlert(withTitle: "Cannot Obtain Location", message: "Location share has been restricted on this device.")
        case .authorizedAlways: break
        }
    }
    
    // locaionManger error check
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(withTitle: "Cannot Obtiain Location", message: error.localizedDescription)
        
    }
    
    
    //MARK: Alert helper
    func showAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
    }


}
