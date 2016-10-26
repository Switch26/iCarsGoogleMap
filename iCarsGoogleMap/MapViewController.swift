//
//  MapViewController.swift
//  iCarsGoogleMap
//
//  Created by Serguei Vinnitskii on 10/26/16.
//  Copyright © 2016 Serguei Vinnitskii. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift


class MapViewController: UIViewController, LeftMenuDelegate {
    
    var leftMenuVC: LeftMenuViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftMenuVC = slideMenuController()?.leftViewController as? LeftMenuViewController
        leftMenuVC?.delegate = self
        
    }
    
    //Mark: Left Slide Menu delegate methods
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

}
