//
//  APIKeys.swift
//  iCarsGoogleMap
//
//  Created by Serguei Vinnitskii on 10/27/16.
//  Copyright © 2016 Serguei Vinnitskii. All rights reserved.
//

import Foundation

func valueForKey(named keyname:String) -> String {
    let filePath = Bundle.main.path(forResource: "API_KEYS", ofType: "plist")
    let plist = NSDictionary(contentsOfFile:filePath!)
    let value = plist?.object(forKey: keyname) as! String
    return value
}
