//
//  FavoriteBook+CoreDataClass.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/13/25.
//
//

import Foundation
import CoreData

@objc(FavoriteBook)
public class FavoriteBook: NSManagedObject {
    
    // 코어데이터 리팩토링
    public static let entityName: String = "FavoriteBook"
    public enum Key {
        static let title = "title"
        static let authors = "authors"
        static let isbn = "isbn"
        static let price = "price"
        static let contents = "contents"
        static let thumbnail = "thumbnail"
    }
}
