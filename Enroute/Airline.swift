//
//  Airline.swift
//  Enroute
//
//  Created by Frank Bara on 5/8/21.
//

import CoreData
import Combine

extension Airline: Comparable {
    var code: String {
        get { code_! }
        set { code_ = newValue }
    }
    
    var name: String {
        get { name_ ?? code }
        set { name_ = newValue }
    }
    
    var shortname: String {
        get { (shortname_ ?? "").isEmpty ? name : shortname_! }
        set { shortname_ = newValue }
    }
    
    var flights: Set<Flight> {
        get { (flights_ as? Set<Flight>) ?? [] }
        set { flights_ = newValue as NSSet }
    }
    
    var friendlyName: String { shortname.isEmpty ? name : shortname }
    
    public var id: String { code }
    
    public static func < (lhs: Airline, rhs: Airline) -> Bool {
        lhs.name < rhs.name
    }
}

extension Airline {
    static func fetchRequst(_ predicate: NSPredicate) -> NSFetchRequest<Airline> {
        let request = NSFetchRequest<Airline>(entityName: "Airline")
        request.sortDescriptors = [NSSortDescriptor(key: "name_", ascending: true)]
        request.predicate = predicate
        return request
    }
}

extension Airline {
    static func withCode(_ code: String, in context: NSManagedObjectContext) -> Airline {
        let request = fetchRequst(NSPredicate(format: "code_ = %@", code))
        let results = (try? context.fetch(request)) ?? []
        
        if let airline = results.first  {
            return airline
        } else {
            let airline = Airline(context: context)
            airline.code = code
            
            AirlineInfoRequest.fetch(code) { info in
                let airline = self.withCode(code, in: context)
                airline.name = info.name
                airline.shortname = info.shortname
                airline.objectWillChange.send()
                airline.flights.forEach { $0.objectWillChange.send() }
                try? context.save()
            }
            return airline
        }
    }
}
