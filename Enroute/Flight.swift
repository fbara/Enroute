//
//  Flight.swift
//  Enroute
//
//  Created by Frank Bara on 5/8/21.
//

import CoreData
import Combine

extension Flight {
    
    var arrival: Date {
        get { arrival_ ?? Date(timeIntervalSinceReferenceDate: 0) }
        set { arrival_ = newValue }
    }
    
    var ident: String {
        get { ident_ ?? "Unknown" }
        set { ident_ = newValue }
    }
    
    var destination: Airport {
        get { destination_! }
        set { destination_ = newValue }
    }
    
    var origin: Airport {
        get { origin_! }
        set { origin_ = newValue }
    }
    
    var airline: Airline {
        get { airline_! }
        set { airline_ = newValue }
    }
    
    var number: Int {
        Int(String(ident.drop(while: { !$0.isNumber }))) ?? 0
    }
}

extension Flight {
    static func fetchRequst(_ predicate: NSPredicate) -> NSFetchRequest<Flight> {
        let request = NSFetchRequest<Flight>(entityName: "Flight")
        request.sortDescriptors = [NSSortDescriptor(key: "arrival_", ascending: true)]
        request.predicate = predicate
        return request
    }
}
