//
//  MainMovie+CoreDataProperties.swift
//  MovieTest
//
//  Created by Rydus on 20/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//
//

import Foundation
import CoreData


extension MainMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MainMovie> {
        return NSFetchRequest<MainMovie>(entityName: "MainMovie")
    }

    @NSManaged public var json: NSObject

}
