//
//  StaffListTableViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 18/03/2021.
//

import UIKit

class StaffListTableViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var id = ""

    var selectedOption: String = ""
    
    var manager = StaffManager()
    
    var itemArray: [StaffModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedOption
        
        manager.delegate = self
        
        searchBar.delegate = self
        
        tableView.register(UINib(nibName: K.staffCell, bundle: nil), forCellReuseIdentifier: K.staffCell)
        
        manager.fetchAll(sort: "desc", pageNumber: "1", pageSize: "10")
        
    }
    
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.staffCell, for: indexPath) as! StaffCell
        
        cell.staffName.text = itemArray[indexPath.row].name
        cell.staffRole.text = itemArray[indexPath.row].role
        
        let completeUrlString = K.photoUrl + itemArray[indexPath.row].completeImgUrl
        
        if itemArray.count > 0 {
            if let url = URL(string: completeUrlString) {
                let task = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    DispatchQueue.main.async { /// execute on main thread
                        cell.staffImage.image = UIImage(data: data)
                    }
                }
                
                task.resume()
            }
        }
               
        //cell.bookImage.image = UIImage(named: bookArray[indexPath.row].image)
        
        if !itemArray[indexPath.row].isActive {
            cell.accessoryType = .none
        }
        
        
        return cell
    }
    
    @IBAction func addStaffPressed(_ sender: UIBarButtonItem) {
            performSegue(withIdentifier: "StaffToAdd", sender: self)
        }

    private func handleEdit() {
        performSegue(withIdentifier: "StaffToAdd", sender: self)
    }

    private func handleDelete() {
        let alert = UIAlertController(title: "Delete Staff", message: "Are you sure you want to delete this staff member?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { (action) in
            self.manager.deleteStaff(id: self.id)
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }

    private func handleDetails() {
        performSegue(withIdentifier: K.staffToDetails, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.staffToDetails {
            let staffDetailVC = segue.destination as! PersonDetailsViewController
            staffDetailVC.selectedOption = selectedOption
            staffDetailVC.id = id
            id = ""
        }
        
        if segue.identifier == "StaffToAdd" {
            if id != "" {
                let updateStaff = segue.destination as! SavePersonViewController
                updateStaff.id = id
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
extension StaffListTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Perform request using the text and reload the list with the returned items
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
extension StaffListTableViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           //Trust the certificate even if not valid
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

           completionHandler(.useCredential, urlCredential)
        }
}

//MARK: - ManagerDelegates

extension StaffListTableViewController : StaffManagerDelegate {
    func didCreateStaff(_ staffManager: StaffManager, status: Int) {
        
    }
    
    func didDeleteStaff(_ staffManager: StaffManager, status: Int) {
        DispatchQueue.main.async {
            if status == 200 {
                self.id = ""
                self.manager.fetchAll(sort: "desc", pageNumber: "1", pageSize: "10")
                self.tableView.reloadData()
            }
        }
    }
    
    func didUpdateStaff(_ staffManager: StaffManager, staff: [StaffModel]) {
        DispatchQueue.main.async {
            self.itemArray = staff
            self.tableView.reloadData()
        }
        
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
    
}

