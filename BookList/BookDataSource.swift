//
//  BookDataSource.swift
//  BookList
//
//  Created by Amy Roberson on 2/1/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import UIKit

class BookDataSource: NSObject, UITableViewDataSource{
    var books: [Book] = []
    
    internal static let standardCellIdentifier = "BookCell"
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = BookDataSource.standardCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! BookCell
        let book = books[indexPath.row]
        guard let titleLabel = cell.titleLabel,
            let authorLabel = cell.authorLabel else {
                fatalError("cell did not get set up properly")
        }
        
        titleLabel.text = book.title
        titleLabel.numberOfLines = 0
        authorLabel.text = book.author
        return cell
    }
}
