//
//  SearchViewController.swift
//  FlightInfoApp
//
//  Created by Sergey Rumyantsev on 07.03.2022.
//

import UIKit

class SearchViewController: UISearchController {
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

extension SearchViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is ArrivalTableViewController {
            isArrivalTabSelected = true
        }
        if viewController is DepartureTableViewController {
            isArrivalTabSelected = false
        }
    }
}
