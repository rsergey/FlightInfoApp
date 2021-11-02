//
//  SettingsViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 23.10.2021.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - IBActions
    @IBAction func webButtonTapped() {
        if let url = URL(string: "http://aviationstack.com") {
            UIApplication.shared.open(url)
            }
    }
}
