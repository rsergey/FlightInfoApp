//
//  ArrivalTableViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 07.08.2021.
//

import UIKit

class ArrivalTableViewController: UITableViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public Properties
    var accessKey = ""
    var airportIata = ""
    
    // MARK: - Private Properties
    private var arrivalFlights: [Flights] = []
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        fecthFlights()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrivalFlights.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "arrivalFlightCell", for: indexPath)
        let arrivalFlight = arrivalFlights[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = prepareDataForText(arrivalFlight: arrivalFlight)
        content.secondaryText = prepareDataForSecondaryText(arrivalFlight: arrivalFlight)
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Private Methods
    private func prepareDataForText(arrivalFlight: Flights) -> String {
        var time = ""
        let flightIata = arrivalFlight.flight?.iata ?? ""
        let departureAirport = arrivalFlight.departure?.airport ?? "unknown airport"
        let departureAirportIata = arrivalFlight.departure?.iata ?? ""
        
        if let arrivalTime = arrivalFlight.arrival?.scheduled {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let stopTime = dateFormatter.date(from: arrivalTime)
            dateFormatter.dateFormat = "dd-MM-yyy HH:mm:ss"
            time += " ↘︎ " + dateFormatter.string(from: stopTime ?? Date())
        }
        
        return time + "\t ✈︎ " + flightIata + "\n" + departureAirport + " (" + departureAirportIata + ")"
    }
    
    private func prepareDataForSecondaryText(arrivalFlight: Flights) -> String {
        guard var airline = arrivalFlight.airline?.name else { return "" }
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
extension ArrivalTableViewController {
    private func fecthFlights() {
        let urlAdress = "http://api.aviationstack.com/v1/flights?access_key=" + accessKey + "&arr_iata=" + airportIata
        guard let url = URL(string: urlAdress) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else {
                self.networkFailedAlert()
                return
            }
            do {
                let flight = try JSONDecoder().decode(ResponseFlights.self, from: data)
                guard let arrivalFlights = flight.data else { return }
                self.arrivalFlights = arrivalFlights
                self.arrivalFlights.sort { $0.arrival?.scheduled ?? "" < $1.arrival?.scheduled ?? "" }
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
