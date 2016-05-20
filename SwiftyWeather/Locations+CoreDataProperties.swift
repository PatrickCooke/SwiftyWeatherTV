//
//  Locations+CoreDataProperties.swift
//  SwiftyWeather
//
//  Created by Patrick Cooke on 5/17/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Locations {

    @NSManaged var locLat: String?
    @NSManaged var locLon: String?
    @NSManaged var locDescription: String?
    @NSManaged var dateEntered: NSDate?

}
