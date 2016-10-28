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
    var locationManager = CLLocationManager()
    var latitude = ""
    var longitude = ""
    var myLocation = CLLocation()
    var lastLocationTimeStamp = NSDate()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftMenuVC = slideMenuController()?.leftViewController as? LeftMenuViewController
        leftMenuVC?.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //determineUserLocation()
        //loadGoogleMap()
    }
    
    func loadGoogleMap() {
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        //mapView.isMyLocationEnabled = true
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    
    }
    
    //MARK: Left Slide Menu delegate methods
    func sanFrancisoButtonPressed() {
        slideMenuController()?.closeLeft()
        print("San Francisco")
    }
    
    func newYorkButtonPressed() {
        slideMenuController()?.closeLeft()
        print("New York")
    }
    
    func fromSFtoNYButtonPressed() {
        slideMenuController()?.closeLeft()
        print("from NY to SF")
    }
    
    //MARK: CoreLocation delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        latitude = "\(locationObj.coordinate.latitude)"
        longitude = "\(locationObj.coordinate.longitude)"
        lastLocationTimeStamp = locationObj.timestamp as NSDate
        
        print(latitude)
        print(longitude)
        
        view.hideToastActivity() // Remove activity indicator
        myLocation = CLLocation(latitude: locationObj.coordinate.latitude, longitude: locationObj.coordinate.longitude)
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
        case .denied:
            print("Location Denied")
            let alertController = UIAlertController(title: "Cannot Obtain Location", message: "Location share has been denied. To enable, please go to your phone SETTINGS and enable location usage for this app", preferredStyle: .alert)
            let bringToSettings = UIAlertAction(title: "Bring me to Settings", style: .default, handler: { (_) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                }
            })
            alertController.addAction(bringToSettings)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
            break
        case .restricted:
            print("Location use has been restricted")
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
