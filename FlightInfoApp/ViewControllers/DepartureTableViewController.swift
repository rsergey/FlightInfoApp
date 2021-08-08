//
//  DepartureTableViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 07.08.2021.
//

import UIKit

class DepartureTableViewController: UITableViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public Properties
    var accessKey = ""
    var airportIata = ""
    
    // MARK: - Private Properties
    private var departureFlights: [Flights] = []
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "Today flights from " + airportIata
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        fecthFlights()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        departureFlights.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "departureFlightCell", for: indexPath)
        let departureFlight = departureFlights[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = prepareDataForText(departureFlight: departureFlight)
        content.secondaryText = prepareDataForSecondaryText(departureFlight: departureFlight)
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Private Methods
    private func prepareDataForText(departureFlight: Flights) -> String {
        var time = ""
        let flightIata = departureFlight.flight?.iata ?? ""
        let arrivalAirport = departureFlight.arrival?.airport ?? "unknown airport"
        let arrivalAirportIata = departureFlight.arrival?.iata ?? ""
        
        if let departuteTime = departureFlight.departure?.scheduled {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let startTime = dateFormatter.date(from: departuteTime)
            dateFormatter.dateFormat = "HH:mm:ss"
            time += " ↖︎ " + dateFormatter.string(from: startTime ?? Date())
        }
        
        return time + "\t ✈︎ " + flightIata + "\n" + arrivalAirport + " (" + arrivalAirportIata + ")"
    }
    
    private func prepareDataForSecondaryText(departureFlight: Flights) -> String {
        guard var airline = departureFlight.airline?.name else { return "" }
        if airline == "empty" {
            airline = "private flight"
        }
        return airline
    }
    
    private func networkFailedAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Network request failed!",
                                          message: "Please try again.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }

}

// MARK: - Networking
extension DepartureTableViewController {
    private func fecthFlights() {
        let urlAdress = "http://api.aviationstack.com/v1/flights?access_key=" + accessKey + "&dep_iata=" + airportIata
        guard let url = URL(string: urlAdress) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else {
                self.networkFailedAlert()
                return
            }
            do {
                let flight = try JSONDecoder().decode(ResponseFlights.self, from: data)
                guard let departureFlights = flight.data else { return }
                self.departureFlights = departureFlights
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }.resume()
    }
}
