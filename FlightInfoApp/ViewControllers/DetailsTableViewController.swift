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

    override func viewLayoutMarginsDidChange() {
        tableView.reloadData()
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
        let headerView = UITableViewHeaderFooterView()
        let backgroundView = UIView()
        backgroundView.backgroundColor = .secondarySystemBackground
        headerView.backgroundView = backgroundView
        
        let label = UILabel(frame: CGRect(x: tableView.safeAreaInsets.left + 50,
                                          y: 0,
                                          width: tableView.frame.width - 60,
                                          height: 40))
        label.text = flightData[section].title
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        headerView.addSubview(label)

        let button = UIButton(frame: CGRect(x: tableView.safeAreaInsets.left + 10,
                                            y: 0,
                                            width: 40,
                                            height: 40))
        if flightData[section].isHidden {
            button.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "chevron.up.circle"), for: .normal)
        }
        button.tag = section
        button.addTarget(self, action: #selector(toggleFlightMenu), for: .touchUpInside)
        headerView.addSubview(button)
        
        return headerView
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        flightData[section].isHidden ? 0 : flightData[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flightDetailsCell", for: indexPath)
        cell.textLabel?.text = flightData[indexPath.section].items[indexPath.row]
        return cell
    }
    
    // MARK: - Private Methods
    private func prepareFlightData() {
        flightData = [FlightMenu(title: "Flight Status",
                                 items: [flight.flightStatus?.capitalized ?? "-"],
                                 isHidden: false),
                     FlightMenu(title: "Departure",
                                items: [flight.departure?.airport ?? "-",
                                        flight.departure?.iata ?? "-",
                                        prepareDateForText(date: flight.departure?.scheduled)],
                                isHidden: false),
                     FlightMenu(title: "Arrival",
                                items: [flight.arrival?.airport ?? "-",
                                        flight.arrival?.iata ?? "-",
                                        prepareDateForText(date: flight.arrival?.scheduled)],
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
    
    private func prepareDateForText(date: String?) -> String {
        if let dateString = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let dateDate = dateFormatter.date(from: dateString) ?? Date()
            dateFormatter.dateFormat = "dd-MM-yyy HH:mm:ss"
            return dateFormatter.string(from: dateDate)
        } else {
            return "-"
        }
    }
    
}
