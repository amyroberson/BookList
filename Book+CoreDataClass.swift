//
//  Book+CoreDataClass.swift
//  BookList
//
//  Created by Amy Roberson on 2/1/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Book)
public class Book: NSManagedObject {
    var image: UIImage?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        setPrimitiveValue(UUID().uuidString,  forKey:"imageKey")
    }
    
    static var entityName: String {
        return "Book"
    }

}
