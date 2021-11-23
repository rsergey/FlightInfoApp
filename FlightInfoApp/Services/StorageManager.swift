//
//  StorageManager.swift
//  FlightInfoApp
//
//  Created by Sergey on 25.08.2021.
//

import CoreData

class StorageManager {
    // MARK: - Static Properties
    static let shared = StorageManager()
    
    // MARK: - Private Properties
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FlightInfoApp")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private let viewContext: NSManagedObjectContext
    
    // MARK: - Initialization
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    // MARK: - Public Methods
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Fetch / Save / Clear
    
    // Airports
    func fetchAirports(completion: (Result<[AirportsCoreDataEntity], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<AirportsCoreDataEntity> = AirportsCoreDataEntity.fetchRequest()
        do {
            let airports = try viewContext.fetch(fetchRequest)
            completion(.success(airports))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func saveAirports(airports: [Airports]) {
        for airport in airports {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: "AirportsCoreDataEntity", in: viewContext) else { return }
            guard let airportEntity = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? AirportsCoreDataEntity else { return }
            airportEntity.airportName = airport.airportName
            airportEntity.cityIataCode = airport.cityIataCode
            airportEntity.countryName = airport.countryName
            airportEntity.iataCode = airport.iataCode
            airportEntity.id = airport.id
            airportEntity.latitude = airport.latitude
            airportEntity.longitude = airport.longitude
            saveContext()
        }
    }
    
    func clearAirports() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AirportsCoreDataEntity")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // Flights
    func fetchFlights(completion: (Result<[FlightsCoreDataEntity], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<FlightsCoreDataEntity> = FlightsCoreDataEntity.fetchRequest()
        do {
            let flights = try viewContext.fetch(fetchRequest)
            completion(.success(flights))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func saveFlights(flights: [Flights]) {
        for flight in flights {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: "FlightsCoreDataEntity", in: viewContext) else { return }
            guard let flightsEntity = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? FlightsCoreDataEntity else { return }
            flightsEntity.flightStatus = flight.flightStatus
            flightsEntity.departure?.airport = flight.departure?.airport
            flightsEntity.departure?.iata = flight.departure?.iata
            flightsEntity.departure?.scheduled = flight.departure?.scheduled
            flightsEntity.arrival?.airport = flight.arrival?.airport
            flightsEntity.arrival?.iata = flight.arrival?.iata
            flightsEntity.arrival?.scheduled = flight.arrival?.scheduled
            flightsEntity.airline?.name = flight.airline?.name
            flightsEntity.flight?.iata = flight.flight?.iata
            saveContext()
        }
    }
    
    func clearFlights() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FlightsCoreDataEntity")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
