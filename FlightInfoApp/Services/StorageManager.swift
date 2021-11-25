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
    func fetchFlights(flightType: FlightType, completion: (Result<[FlightsCoreDataEntity], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<FlightsCoreDataEntity> = FlightsCoreDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "flightType = %@", flightType.rawValue)
        do {
            let flights = try viewContext.fetch(fetchRequest)
            completion(.success(flights))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func saveFlights(flights: [Flights], flightType: FlightType) {
        for flight in flights {
            
            let departureEntity = DepartureAirportCoreDataEntity(context: viewContext)
            departureEntity.airport = flight.departure?.airport
            departureEntity.iata = flight.departure?.iata
            departureEntity.scheduled = flight.departure?.scheduled
            
            let arrivalEntity = ArrivalAirportCoreDataEntity(context: viewContext)
            arrivalEntity.airport = flight.arrival?.airport
            arrivalEntity.iata = flight.arrival?.iata
            arrivalEntity.scheduled = flight.arrival?.scheduled
            
            let airlineEntity = AirlineCoreDataEntity(context: viewContext)
            airlineEntity.name = flight.airline?.name
            
            let flightEntity = FlightCoreDataEntity(context: viewContext)
            flightEntity.iata = flight.flight?.iata
            
            let flightsEntity = FlightsCoreDataEntity(context: viewContext)
            flightsEntity.flightType = flightType.rawValue
            flightsEntity.flightStatus = flight.flightStatus
            flightsEntity.departure = departureEntity
            flightsEntity.arrival = arrivalEntity
            flightsEntity.airline = airlineEntity
            flightsEntity.flight = flightEntity
            
            saveContext()
        }
    }
    
    func clearFlights(flightType: FlightType) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FlightsCoreDataEntity")
        fetchRequest.predicate = NSPredicate(format: "flightType = %@", flightType.rawValue)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
