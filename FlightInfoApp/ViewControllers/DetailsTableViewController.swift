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
    private var flightData: [FlightMenu] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFlightData()
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return flightData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let stackView = UIStackView()
        stackView.backgroundColor = UIColor.systemGray5

        let label = UILabel()
        label.text = flightData[section].title
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        stackView.addArrangedSubview(label)

        let button = UIButton()
        if flightData[section].isHidden {
            button.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "chevron.up.circle"), for: .normal)
        }
        button.tag = section
        button.addTarget(self, action: #selector(toggleFlightMenu), for: .touchUpInside)
        stackView.addArrangedSubview(button)

        return stackView
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if flightData[section].isHidden {
            return 0
        } else {
            return flightData[section].items.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flightDetailsCell", for: indexPath)
        cell.textLabel?.text = flightData[indexPath.section].items[indexPath.row]
        return cell
    }
    
    private func prepareFlightData() {
        flightData = [FlightMenu(title: "Flight Status",
                                 items: [flight.flightStatus ?? "-"],
                                 isHidden: false),
                     FlightMenu(title: "Departure",
                                items: [flight.departure?.airport ?? "-",
                                        flight.departure?.iata ?? "-",
                                        flight.departure?.scheduled ?? "-"],
                                isHidden: false),
                     FlightMenu(title: "Arrival",
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
    
    @objc private func toggleFlightMenu(button: UIButton) {
        flightData[button.tag].isHidden.toggle()
        tableView.reloadData()
    }

}
