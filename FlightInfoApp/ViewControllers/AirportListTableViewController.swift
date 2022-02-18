//
//  AirportListTableViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 25.08.2021.
//

import UIKit

class AirportListTableViewController: UITableViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private var airports: [Airports] = []
    private var filteredAirports: [Airports] = []
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        setupRefreshControl()
        getAirports()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search airport"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredAirports.count
        }
        return airports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectionAirportCell", for: indexPath)
        var airport: Airports
        airport = isFiltering ? filteredAirports[indexPath.row] : airports[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = prepareDataForText(airport: airport)
        content.secondaryText = prepareDataForSecondaryText(airport: airport)
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFlightsSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let airport: Airports
                if isFiltering {
                    airport = filteredAirports[indexPath.row]
                } else {
                    airport = airports[indexPath.row]
                }
                
                DataManager.defaultAirportIata = airport.iataCode
                
                guard let tabBarController = segue.destination as? UITabBarController else { return }
                tabBarController.navigationItem.title = "Airport • " + (airport.iataCode ?? "")
                guard let viewControllers = tabBarController.viewControllers else { return }
                
                viewControllers.forEach {
                    if let arrivalVC = $0 as? ArrivalTableViewController {
                        arrivalVC.airportIata = airport.iataCode ?? ""
                    } else if let departureVC = $0 as? DepartureTableViewController {
                        departureVC.airportIata = airport.iataCode ?? ""
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    // Interface
    private func prepareDataForText(airport: Airports) -> String {
        var text = " → " + (airport.airportName ?? "-")
        text += " (" + (airport.iataCode ?? "-") + ")"
        return text
    }
    
    private func prepareDataForSecondaryText(airport: Airports) -> String {
        (airport.countryName ?? "-") + " (city iata: " + (airport.cityIataCode ?? "-") + ")"
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Update airports list")
        refreshControl?.addTarget(self, action: #selector(fetchDataFromNetwork), for: .valueChanged)
    }
    
    private func stopUpdateAnimation() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            if self.refreshControl != nil {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    // Get data
    private func getAirports() {
        activityIndicator.startAnimating()
        fetchAirportsFromStorage()
        if airports.isEmpty {
            fetchAirportsFromNetwork()
        }
    }
    
    // Storage
    private func fetchAirportsFromStorage() {
        StorageManager.shared.fetchAirports { result in
            switch result {
            case .success(let airports):
                self.airports = []
                for airport in airports {
                    self.airports.append(Airports(id: airport.id,
                                                  iataCode: airport.iataCode,
                                                  cityIataCode: airport.cityIataCode,
                                                  latitude: airport.latitude,
                                                  longitude: airport.longitude,
                                                  airportName: airport.airportName,
                                                  countryName: airport.countryName))
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        self.stopUpdateAnimation()
        tableView.reloadData()
    }
    
    // Network
    @objc private func fetchDataFromNetwork() {
        if !airports.isEmpty {
            warningNewRequestAlert()
        }
    }
    
    private func fetchAirportsFromNetwork() {
        guard let key = KeychainManager.shared.readData(service: kSecAttributes.service.rawValue,
                                                        account: kSecAttributes.account.rawValue) else {
            self.stopUpdateAnimation()
            keychainFailedAlert()
            return
        }
        
        NetworkManager.shared.fetchAirports(from: .airportsUrl,
                                            key: key) { (result) in
            switch result {
            case .success(let airports):
                self.airports = airports
                self.stopUpdateAnimation()
                self.tableView.reloadData()
                StorageManager.shared.clearAirports()
                StorageManager.shared.saveAirports(airports: airports)
            case .failure(_):
                self.stopUpdateAnimation()
                self.networkFailedAlert()
            }
        }
    }
    
    // Alerts
    private func keychainFailedAlert() {
        let alert = UIAlertController(title: "No API key found!",
                                      message: "Please save your API key in the app settings.",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    private func warningNewRequestAlert() {
        let alert = UIAlertController(title: "Updating airports list from network.",
                                      message: "The full list of airports rarely changes. Are you sure you want to update the data?",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Update",
                                     style: .default) { _ in
            self.fetchAirportsFromNetwork()
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { _ in
            self.stopUpdateAnimation()
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
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

// MARK: - Extensions
extension AirportListTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterAirports(searchController.searchBar.text ?? "")
    }
    
    private func filterAirports(_ searchText: String) {
        filteredAirports = airports.filter({ (airport: Airports) -> Bool in
            return (airport.airportName?.lowercased().contains(searchText.lowercased()) ?? false)
        })
        tableView.reloadData()
    }
}
