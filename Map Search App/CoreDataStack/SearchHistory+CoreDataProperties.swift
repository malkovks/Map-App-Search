//
//  SearchHistory+CoreDataProperties.swift
//  
//
//  Created by Константин Малков on 29.01.2023.
//
//

import Foundation
import CoreData


extension SearchHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchHistory> {
        return NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
    }

    @NSManaged public var langitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var nameCategory: String?

}
