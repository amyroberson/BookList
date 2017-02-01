//
//  BookStore.swift
//  BookList
//
//  Created by Amy Roberson on 2/1/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum BookResult {
    case success([Book])
    case failure(Error)
}


internal final class BookStore {
    let imageStore = ImageStore<String>()
    let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = CoreDataStack(modelName: "BookListModel")){
        self.coreDataStack = coreDataStack
    }
    
    fileprivate let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
}

extension BookStore {
    
    func processBookRequest(data: Data?, error: NSError?) -> BookResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return BLAPI.booksFromJSONData(jsonData, inContext: self.coreDataStack.privateQueueContext)
    }
    
    internal func fetchMainQueueBooks(predicate: NSPredicate? = nil,
                                      sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Book] {
        
        let fetchRequest = NSFetchRequest<Book>(entityName: "Book")
        fetchRequest.sortDescriptors = sortDescriptors
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueBook: [Book]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait({
            do {
                mainQueueBook = try mainQueueContext.fetch(fetchRequest)
            }
            catch let error {
                fetchRequestError = error
            }
        })
        
        guard let book = mainQueueBook else {
            throw fetchRequestError!
        }
        
        return book
    }
    
    internal func fetchBooks(completion: @escaping (BookResult) -> Void) {
        
        let url = BLAPI.booksURL
        let request = URLRequest(url: url as URL)
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            var result = self.processBookRequest(data: data, error: error as NSError?)
            
            if case let .success(books) = result {
                let privateQueueContext = self.coreDataStack.privateQueueContext
                privateQueueContext.performAndWait({
                    try! privateQueueContext.obtainPermanentIDs(for: books)
                })
                let objectIDs = books.map{ $0.objectID } //what is object id
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                let sortByDateTaken = NSSortDescriptor(key: "createdAt", ascending: false)
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueueBooks = try self.fetchMainQueueBooks(predicate: predicate,
                                                                      sortDescriptors: [sortByDateTaken])
                    result = .success(mainQueueBooks)
                }
                catch let error {
                    result = .failure(error)
                }
            }
            completion(result)
        })
        task.resume()
    }

}

extension BookStore {
    func processImageRequest(data: Data?, error optionalError: NSError?) -> ImageResult {
        
        guard let imageData = data,
            let image = UIImage(data: imageData) else {
                if let error = optionalError {
                    return .systemFailure(error)
                } else {
                    return .systemFailure(ImageResult.Error.imageCreation)
                }
        }
        
        return .success(image)
    }
    
    func fetchImage(_ book: Book, completion: @escaping (ImageResult) -> Void) {
        
        let imageKey = book.imageKey!
        if let image = imageStore.imageForKey(imageKey) {
            completion(.success(image))
            return
        }
        
        if let bookURL = book.image_url{
            let imageURL: URL? = URL(string: bookURL)!
            let request = URLRequest(url: imageURL!)
            
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                
                let result = self.processImageRequest(data: data, error: error as NSError?)
                
                if case let .success(image) = result {
                    book.image = image
                    self.imageStore.setImage(image, forKey: imageKey)
                }
                
                completion(result)
            }) 
            task.resume()
        } else {
           // completion(.systemFailure(.noURL))
        }
        
    }
}


