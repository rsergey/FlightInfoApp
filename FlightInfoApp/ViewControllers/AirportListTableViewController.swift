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
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        setupRefreshControl()
        fetchAirports()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
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
        if isFiltering {
            airport = filteredAirports[indexPath.row]
        } else {
            airport = airports[indexPath.row]
        }
        var content = cell.defaultContentConfiguration()
        content.text = prepareDataForText(airport: airport)
        content.secondaryText = prepareDataForSecondaryText(airport: airport)
        cell.contentConfiguration = content
        return cell
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - IBAction
    @IBAction func refreshAirportList(_ sender: UIBarButtonItem) {
        fetchAirports()
    }
    
    // MARK: - Private Methods
    private func prepareDataForText(airport: Airports) -> String {
        var text = " → " + (airport.airportName ?? "-")
        text += " (" + (airport.iataCode ?? "-") + ")"
        return text
    }
    
    private func prepareDataForSecondaryText(airport: Airports) -> String {
        (airport.countryName ?? "-") + " (city iata: " + (airport.cityIataCode ?? "-") + ")"
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
    
    private func stopUpdateAnimation() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            if self.refreshControl != nil {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc private func fetchAirports() {
        NetworkManager.shared.fetchAirports(from: .airportsUrl,
                                            key: .accessKey) { (result) in
            switch result {
            case .success(let airports):
                self.airports = airports
                self.stopUpdateAnimation()
                self.tableView.reloadData()
            case .failure(_):
                self.stopUpdateAnimation()
                self.networkFailedAlert()
            }
        }
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(fetchAirports), for: .valueChanged)
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
