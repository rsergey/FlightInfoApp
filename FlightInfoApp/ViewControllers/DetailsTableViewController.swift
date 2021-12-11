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
    
    // MARK: - Private Properties
    private var flightData: [FlightMenu] {
        [FlightMenu(title: "Flight Status",
                    items: [flight.flightStatus ?? "-"],
                    isHidden: false),
        FlightMenu(title: "Departure Airport",
                   items: [flight.departure?.airport ?? "-",
                           flight.departure?.iata ?? "-",
                           flight.departure?.scheduled ?? "-"],
                   isHidden: false),
        FlightMenu(title: "Arrival Airport",
                   items: [flight.arrival?.airport ?? "-",
                           flight.arrival?.iata ?? "-",
                           flight.arrival?.scheduled ?? "-"],
                   isHidden: false),
        FlightMenu(title: "Airline",
                   items: [flight.airline?.name ?? "-"],
                   isHidden: false),
        FlightMenu(title: "Flight Code",
                   items: [flight.flight?.iata ?? "-"],
                   isHidden: false)]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        flightData[section].title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if flightData[indexPath.section].isHidden {
            return 0
        } else {
            return 44
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return flightData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flightData[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flightDetailsCell", for: indexPath)
        cell.textLabel?.text = flightData[indexPath.section].items[indexPath.row]
        return cell
    }

}
