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
    
    func fetchAirports(completion: (Result<[Airport], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Airport> = Airport.fetchRequest()
        do {
            let airports = try viewContext.fetch(fetchRequest)
            completion(.success(airports))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func saveAirports(airports: [Airports]) {
        for airport in airports {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: "Airport", in: viewContext) else { return }
            guard let airportEntity = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? Airport else { return }
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Airport")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
