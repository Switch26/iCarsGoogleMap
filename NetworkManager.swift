//
//  NetworkManager.swift
//  iCarsGoogleMap
//
//  Created by Serguei Vinnitskii on 10/28/16.
//  Copyright © 2016 Serguei Vinnitskii. All rights reserved.
//

import Foundation
import CoreLocation

struct NetworkManager {
    
    static func getDrivingRoutePointsBetween(origin: String, destination: String, stopPoints: String, completionHandler: @escaping ((_ encodedPoints:String?, _ arrayOfPoints: [CLLocationCoordinate2D]?) -> Void)) {
        
        //let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&waypoints=\(stopPoints)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)"
        
        
        let formatedString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let formatedURL = URL(string: formatedString)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: formatedURL) { (data: Data?, _, error: Error?) in
            
            DispatchQueue.main.async { // requred to make API calls on the MAIN thread by Google. Otherwise "GMSThreadException" is thrown

                if error == nil { // success

                        let parsedData = try? JSONSerialization.jsonObject(with: data!) as! [String:Any]
                        if let validData = parsedData {
                            let status = validData["status"] as! String
                            
                            if status == "OK" {
                                
                                let routes = validData["routes"] as! [[String: Any]]
                                
                                //print(routes)
                                
                                let legs = routes.first?["legs"] as? [Any]
                                
                                let firstLeg = legs?.first as? [String: Any]
                                let legsSteps = firstLeg?["steps"] as? [Any]

                                var arrayOfCoordinates = [CLLocationCoordinate2D]()
                                var totalDistance = 0
                                
                                for step in legsSteps! {
                                    let castedStep = step as? [String: Any]
                                    
                                    let distance = castedStep?["distance"] as? [String: Any]
                                    let distanceValue = distance?["value"] as? Int
                                    
                                    totalDistance += distanceValue!
                                    
                                    if (totalDistance > 100000) {
                                        let endLocation = castedStep?["end_location"] as? [String: Any]
                                        let latitude = endLocation?["lat"] as? CLLocationDegrees
                                        let longitude = endLocation?["lng"] as? CLLocationDegrees
                                        
                                        let coordinateToAdd = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                                        arrayOfCoordinates.append(coordinateToAdd)
                                        totalDistance = 0
                                    }
                                }
                                
                                print(arrayOfCoordinates)
                                
                                
                                let overviewPolylineRoute = routes.first?["overview_polyline"] as? [String: Any]
                                let points = overviewPolylineRoute?["points"] as? String
                                
                                
                                completionHandler(points, arrayOfCoordinates)
                                
                                
                            }
                        }
                } else { // network error
                    print("Error: \(error?.localizedDescription)")
                    completionHandler(nil, nil)
                }
            }
        }
        
        task.resume()
    }
    
    
    
    

}
