//
//  NetworkManager.swift
//  iCarsGoogleMap
//
//  Created by Serguei Vinnitskii on 10/28/16.
//  Copyright © 2016 Serguei Vinnitskii. All rights reserved.
//

import Foundation

struct NetworkManager {
    
    static func getDrivingRoutePointsBetween(origin: String, destination: String, completionHandler: @escaping ((_ encodedPoints:String?,_ success: Bool) -> Void)) {
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)"
        let formatedString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let formatedURL = URL(string: formatedString)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: formatedURL) { (data: Data?, _, error: Error?) in
            if error == nil { // success
        
                let parsedData = try? JSONSerialization.jsonObject(with: data!) as! [String:Any]
                if let validData = parsedData {
                    let status = validData["status"] as! String
                    
                    if status == "OK" {
                        
                        let routes = validData["routes"] as! [[String: Any]]
                        let overviewPolylineRoute = routes.first?["overview_polyline"] as? [String: Any]
                        let points = overviewPolylineRoute?["points"] as? String
                        completionHandler(points, true)
                    }
                }
            } else { // network error
                print("Error: \(error?.localizedDescription)")
                completionHandler(nil, false)
            }
        }
        
        task.resume()
    }

}
