//
//  LeftMenuViewController.swift
//  iCarsGoogleMap
//
//  Created by Serguei Vinnitskii on 10/26/16.
//  Copyright © 2016 Serguei Vinnitskii. All rights reserved.
//

import UIKit

enum LeftMenuButtons {
    case sanFrancisco
    case newYork
    case fromSFtoNY
}

protocol LeftMenuDelegate {
    func sanFrancisoButtonPressed()
    func newYorkButtonPressed()
    func fromSFtoNYButtonPressed()
}

class LeftMenuViewController: UIViewController {
    
    var delegate: LeftMenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sanFranciscoButtonPressed(_ sender: UIButton) {
        delegate?.sanFrancisoButtonPressed()
    }

    @IBAction func newYorkButtonPressed(_ sender: UIButton) {
        delegate?.newYorkButtonPressed()
    }
    
    @IBAction func fromSFtoNYButtonPressed(_ sender: UIButton) {
        delegate?.fromSFtoNYButtonPressed()
    }

}
