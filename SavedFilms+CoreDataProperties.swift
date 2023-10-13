//
//  SavedFilms+CoreDataProperties.swift
//  M19
//
//  Created by Александра Угольнова on 12.10.2023.
//
//

import Foundation
import CoreData


extension SavedFilms {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedFilms> {
        return NSFetchRequest<SavedFilms>(entityName: "SavedFilms")
    }

    @NSManaged public var nameRU: String?
    @NSManaged public var nameOr: String?
    @NSManaged public var ratKino: String?
    @NSManaged public var ratIMBD: String?
    @NSManaged public var year: String?
    @NSManaged public var length: String?
    @NSManaged public var descript: String?
    @NSManaged public var image: String?
    @NSManaged public var uniqueIdentifier: String?

}

extension SavedFilms : Identifiable {

}
