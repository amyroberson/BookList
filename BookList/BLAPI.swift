//
//  BLAPI.swift
//  BookList
//
//  Created by Amy Roberson on 2/1/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

class BLAPI {
    enum Error: Swift.Error {
        case invalidJSONData
    }
    
    internal static let booksURL : URL = URL(string: "http://calm-mountain-87063.herokuapp.com/books.json")!
    
    
    class func booksFromJSONData(_ data: Data, inContext context: NSManagedObjectContext) -> BookResult{
        
        do {
            guard let jsonObject: [[String: Any]] = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                return .failure(Error.invalidJSONData)
            }
            var actualBooks: [Book] = []
            for bookJSON in jsonObject{
                if let book = bookFromJsonObject(bookJSON, inContext: context) {
                    actualBooks.append(book)
                }
                
                if actualBooks.count == 0 && jsonObject.count > 0{
                    return .failure(Error.invalidJSONData)
                }
            }
            return .success(actualBooks)
        } catch let error {
            return .failure(error)
        }
    }
    
    fileprivate class func bookFromJsonObject(_ json: [String: Any], inContext context: NSManagedObjectContext) -> Book? {
        guard let title = json["title"] as? String else {return nil}
        //if there was noe title we cannot create a book
        
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Book.entityName)
        let predicate = NSPredicate(format: "title == \(title)") // not sure about this line
        fetchRequest.predicate = predicate
        
        let fetchedBooks: [Book] = {
            var books: [Book]!
            context.performAndWait() {
                books = try! context.fetch(fetchRequest) as! [Book]
            }
            
            return books
        }()
        
        if let firstBook = fetchedBooks.first {
            return firstBook
        }
        
        
        var book: Book!
        context.performAndWait({ () -> Void in
            book = NSEntityDescription.insertNewObject(forEntityName: Book.entityName, into: context) as! Book
            book.title = title
        })
        return book
    }
    
    
}



