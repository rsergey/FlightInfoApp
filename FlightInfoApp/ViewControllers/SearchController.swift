//
//  SearchViewController.swift
//  FlightInfoApp
//
//  Created by Sergey Rumyantsev on 07.03.2022.
//

import UIKit

class SearchController: UISearchController {
    // MARK: - Public Properties
    override var searchResultsController: UIViewController? {
        isArrivalTabSelected ? ArrivalTableViewController() : DepartureTableViewController()
    }
    
    // MARK: - Private Properties
    private var isArrivalTabSelected = true
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
    }
    
}

extension SearchController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("UITabBarControllerDelegate")
        if viewController is ArrivalTableViewController {
            isArrivalTabSelected = true
            print("Arrival")
        }
        if viewController is DepartureTableViewController {
            isArrivalTabSelected = false
            print("Departure")
        }
    }
}
