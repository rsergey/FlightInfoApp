//
//  DetailsTableViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 08.12.2021.
//

import UIKit

class DetailsTableViewController: UITableViewController {
    
    // MARK: - Public Properties
    var flight: Flights!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flightDetailsCell", for: indexPath)
        return cell
    }

}
