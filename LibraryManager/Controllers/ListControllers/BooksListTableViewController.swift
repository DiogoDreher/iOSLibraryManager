//
//  BooksListTableViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 13/03/2021.
//

import UIKit

class BooksListTableViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var id = ""
    
    var selectedOption: String = ""
    
    var manager = BookManager()
    
    var itemArray: [BookModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedOption
        
        manager.delegate = self
        
        tableView.register(UINib(nibName: K.booksCell, bundle: nil), forCellReuseIdentifier: K.booksCell)
        
        manager.fetchAll(sort: "desc", pageNumber: "1", pageSize: "10")
        
    }
        
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.booksCell, for: indexPath) as! BookCell
        
        cell.bookName.text = itemArray[indexPath.row].name
        cell.bookYear.text = "\(itemArray[indexPath.row].year)"
        
        let completeUrlString = K.photoUrl + itemArray[indexPath.row].completeImgUrl
        
        if itemArray.count > 0 {
            if let url = URL(string: completeUrlString) {
                let task = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    DispatchQueue.main.async { /// execute on main thread
                        cell.bookImage.image = UIImage(data: data)
                    }
                }
                
                task.resume()
            }
        }
               
        
        if !itemArray[indexPath.row].isActive {
            cell.accessoryType = .none
        }
        
        
        return cell
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "BooksToAdd", sender: self)
    }
    

    private func handleEdit() {
        performSegue(withIdentifier: "BooksToAdd", sender: self)
    }

    private func handleDelete() {
        
        let alert = UIAlertController(title: "Delete Book", message: "Are you sure you want to delete this book from the catalogue?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { (action) in
            self.manager.deleteBook(id: self.id)
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }

    private func handleDetails() {
        performSegue(withIdentifier: K.booksToDetails, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.booksToDetails {
            let bookDetailVC = segue.destination as! BookDetailsViewController
            bookDetailVC.selectedOption = selectedOption
            bookDetailVC.id = id
            id = ""
        }
        
        if segue.identifier == "BooksToAdd" {
            if id != "" {
                let updateBookVC = segue.destination as! SaveBookViewController
                updateBookVC.id =  id
                id = ""
            }
        }
        
    }
    
    
    
    //MARK: - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Archive action
        let details = UIContextualAction(style: .normal,
                                         title: "Details") { [weak self] (action, view, completionHandler) in
            self!.id = self!.itemArray[indexPath.row].id
                                            self?.handleDetails()
                                            completionHandler(true)
        }
        details.backgroundColor = .systemGray

        // Unread action
        let edit = UIContextualAction(style: .normal,
                                       title: "Edit") { [weak self] (action, view, completionHandler) in
            self!.id = self!.itemArray[indexPath.row].id
                                        self?.handleEdit()
                                        completionHandler(true)
        }
        edit.backgroundColor = .systemYellow
        
        // Trash action
        let delete = UIContextualAction(style: .destructive,
                                       title: "Delete") { [weak self] (action, view, completionHandler) in
            self!.id = self!.itemArray[indexPath.row].id
                                        self?.handleDelete()
                                        completionHandler(true)
        }
        delete.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [delete, edit, details])

        return configuration
    }
    
}


//MARK: - UISearchBar Delegate
extension BooksListTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Perform request using the text and reload the list with the returned items
        print(searchBar.text!)
        manager.fetchSearch(name: searchBar.text!)
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //perform the ALL endpoit and update the tableview
            manager.fetchAll(sort: "desc", pageNumber: "1", pageSize: "10")
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    
    
}

//MARK: - URLSessionDelegate
extension BooksListTableViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           //Trust the certificate even if not valid
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

           completionHandler(.useCredential, urlCredential)
        }
}

//MARK: - ManagerDelegates

extension BooksListTableViewController : BookManagerDelegate {
    func didDeleteBook(_ bookManager: BookManager, status: Int) {
        DispatchQueue.main.async {
            if status == 200 {
                self.id = ""
                self.manager.fetchAll(sort: "desc", pageNumber: "1", pageSize: "10")
                self.tableView.reloadData()
            }
        }
    }
    
    func didCreateBook(_ bookManager: BookManager, status: Int) {
        
    }
    
    func didUpdateBook(_ bookManager: BookManager, book: [BookModel]) {
        DispatchQueue.main.async {
            self.itemArray = book
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
    
    
}






