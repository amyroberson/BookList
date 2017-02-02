//
//  ViewController.swift
//  BookList
//
//  Created by Amy Roberson on 2/1/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

class TheViewController: UITableViewController {
    
    
    
    
    let store = BookStore()
    lazy var datasource = BookDataSource()
    
    fileprivate func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = datasource
        tableView.allowsSelection = false
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(TheViewController.refreshTableView), for: .valueChanged)
    }
    
    @objc func refreshTableView() {
        store.fetchBooks(completion: {
            (bookResult) -> Void in
            OperationQueue.main.addOperation() {
                switch bookResult {
                case .success(let books):
                    self.datasource.books = books
                case .failure(let error):
                    self.datasource.books.removeAll()
                    print("Error fetching Books \(error)")
                }
                self.tableView.reloadSections(IndexSet(integer:0), with: .automatic)
                self.refreshControl?.endRefreshing()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        refreshTableView()
    }
}

extension TheViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let book = datasource.books[indexPath.row]
        
        let bookCell = cell as! BookCell
        
        bookCell.bookID = book.title
        store.fetchImage(book, completion: {
            (result) -> Void in
            OperationQueue.main.addOperation(){
                if bookCell.bookID == book.title {
                    bookCell.update(result)
                }
            }
        })
    }
}
