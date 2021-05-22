//
//  Airport.swift
//  Enroute
//
//  Created by Frank Bara on 5/8/21.
//

import CoreData
import Combine

extension Airport {
    static func withICAO(_ icao: String, context: NSManagedObjectContext) -> Airport {
        // look up icao in CoreData
        let request = fetchRequst(NSPredicate(format: "icao_ = %@", icao))
        let airports = (try? context.fetch(request)) ?? []
        if let airport = airports.first {
            // if found, return it
            return airport
        } else {
            // if not, create one and fetch from FlightAware
            let airport = Airport(context: context)
            airport.icao = icao
            AirportInfoRequest.fetch(icao) { airportInfo in
                //asynchronous return so we'll just pass back a mostly blank 'airport'
                self.update(from: airportInfo, context: context)
            }
            return airport
        }
    }
    
    static func update(from info: AirportInfo, context: NSManagedObjectContext) {
        // this will take some time to do, it will return later
        if let icao = info.icao {
            let airport = self.withICAO(icao, context: context)
            airport.latitude = info.latitude
            airport.longitude = info.longitude
            airport.name = info.name
            airport.location = info.location
            airport.timezone = info.timezone
            // save to core data
            airport.objectWillChange.send()
            airport.flightTo.forEach { $0.objectWillChange.send() }
            airport.flightFrom.forEach { $0.objectWillChange.send() }
            try? context.save()
        }
    }
    
    var flightTo: Set<Flight> {
        get { (flightsTo_ as? Set<Flight>) ?? [] }
        set { flightsTo_ = newValue as NSSet }
    }
    var flightFrom: Set<Flight> {
        get { (flightsFrom_ as? Set<Flight>) ?? [] }
        set { flightsFrom_ = newValue as NSSet }
    }
}

extension Airport: Comparable {
    var icao: String {
        get { icao_! }
        set { icao_ = newValue }
    }
    
    var friendlyName: String {
        let friendly = AirportInfo.friendlyName(name: self.name ?? "", location: self.location ?? "")
        return friendly.isEmpty ? icao : friendly
    }
    
    public var id: String { icao }
    
    public static func < (lhs: Airport, rhs: Airport) -> Bool {
        lhs.location ?? lhs.friendlyName < rhs.location ?? rhs.friendlyName
    }
}

extension Airport {
    static func fetchRequst(_ predicate: NSPredicate) -> NSFetchRequest<Airport> {
        let request = NSFetchRequest<Airport>(entityName: "Airport")
        request.sortDescriptors = [NSSortDescriptor(key: "location", ascending: true)]
        request.predicate = predicate
        return request
    }
}
