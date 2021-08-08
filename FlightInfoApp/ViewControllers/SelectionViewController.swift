//
//  SelectionViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 07.08.2021.
//

import UIKit

class SelectionViewController: UIViewController {
    
    // MARK: - Private Properties
    let accessKey = "bf9f1644f60ea683c4a27c95035f65ab"
    var airportIata = ""

    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tabBarController = segue.destination as? UITabBarController else { return }
        guard let viewControllers = tabBarController.viewControllers else { return }
        for viewController in viewControllers {
            if let arrivalVC = viewController as? ArrivalTableViewController {
                arrivalVC.accessKey = accessKey
                arrivalVC.airportIata = airportIata
            }
            if let departureVC = viewController as? DepartureTableViewController {
                departureVC.accessKey = accessKey
                departureVC.airportIata = airportIata
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func airportSelectionButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            airportIata = "LED"
        case 1:
            airportIata = "SVO"
        case 2:
            airportIata = "DME"
        default:
            airportIata = "VKO"
        }
        performSegue(withIdentifier: "showFlightsSegue", sender: nil)
    }
    
}

