//
//  MyBookViewModel.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/13/25.
//

import UIKit
import CoreData

class FavoriteBookManager {
    static let shared = FavoriteBookManager()
    
    private var container: NSPersistentContainer!
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
    }
    
    func create(data: Book) throws {
        guard checkSameContent(data: data) else { throw CoreDataError.haveSameBook }
        
        guard let entity = NSEntityDescription.entity(forEntityName: FavoriteBook.entityName, in: self.container.viewContext) else { return }
        let newBook = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
        
        var authors = ""
        if data.authors.count > 1 {
            authors = data.authors.joined(separator: ", ")
        } else if data.authors.count > 0 {
            authors = data.authors[0]
        } else {
            authors = "unknown"
        }
        
        newBook.setValue(data.title, forKey: FavoriteBook.Key.title)
        newBook.setValue(authors, forKey: FavoriteBook.Key.authors)
        newBook.setValue(data.thumbnail, forKey: FavoriteBook.Key.thumbnail)
        newBook.setValue(data.price, forKey: FavoriteBook.Key.price)
        newBook.setValue(data.contents, forKey: FavoriteBook.Key.contents)
        newBook.setValue(data.isbn, forKey: FavoriteBook.Key.isbn)
        
        do {
            try self.container.viewContext.save()
        } catch {
            print(CoreDataError.saveFailed)
            return
        }
    }
    
    func fetch() -> [FavoriteBook] {
        do {
            return try self.container.viewContext.fetch(FavoriteBook.fetchRequest())
        } catch {
            print(CoreDataError.fetchFailed)
            return [FavoriteBook]()
        }
    }
    
    func deleteOne(item: String?) {
        guard let item else { return }
        
        let fetch = FavoriteBook.fetchRequest()
        fetch.predicate = NSPredicate(format: "isbn == %@", item)
        
        do {
            let item = try self.container.viewContext.fetch(fetch)
            
            for data in item as [NSManagedObject] {
                self.container.viewContext.delete(data)
            }
            
            try self.container.viewContext.save()
        } catch {
            print(CoreDataError.deleteFailed)
            return
        }
    }
    
    func deleteAll() {
        do {
            let fetch = try self.container.viewContext.fetch(FavoriteBook.fetchRequest())
            
            for data in fetch as [NSManagedObject] {
                self.container.viewContext.delete(data)
            }
            
            try self.container.viewContext.save()
        } catch {
            print(CoreDataError.deleteFailed)
            return
        }
    }
    
    private func checkSameContent(data: Book) -> Bool {
        do {
            let fetch = try self.container.viewContext.fetch(FavoriteBook.fetchRequest())
            
            for i in fetch {
                if i.isbn == data.isbn {
                    return false
                }
            }
            
            return true
        } catch {
            print(CoreDataError.fetchFailed)
            return false
        }
    }
}

enum CoreDataError: Error {
    case saveFailed, fetchFailed, haveSameBook, deleteFailed
}
