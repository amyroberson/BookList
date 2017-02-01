//
//  Book+CoreDataProperties.swift
//  BookList
//
//  Created by Amy Roberson on 2/1/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book");
    }

    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var image_url: String?
    @NSManaged public var imageKey: String?

}
