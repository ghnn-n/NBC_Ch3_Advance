//
//  FavoriteBook+CoreDataProperties.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/14/25.
//
//

import Foundation
import CoreData


extension FavoriteBook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteBook> {
        return NSFetchRequest<FavoriteBook>(entityName: "FavoriteBook")
    }

    @NSManaged public var title: String?
    @NSManaged public var price: Int64
    @NSManaged public var authors: String?
    @NSManaged public var contents: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var isbn: String?

}

extension FavoriteBook : Identifiable {

}
