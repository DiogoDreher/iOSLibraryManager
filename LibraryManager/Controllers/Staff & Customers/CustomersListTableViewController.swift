//
//  CustomersListTableViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 18/03/2021.
//

import UIKit

class CustomersListTableViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var id = ""

    var selectedOption: String = ""
    
    var manager = CustomerManager()
    
    var itemArray: [CustomerModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !LoginInfo.loginInstance.isLogeegdIn {
            navigationController?.popToRootViewController(animated: true)
        }
        
        title = selectedOption
        
        manager.delegate = self
        searchBar.delegate = self
        
        tableView.register(UINib(nibName: K.customerCell, bundle: nil), forCellReuseIdentifier: K.customerCell)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControl.Event.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        itemArray = []
        tableView.reloadData()
        manager.fetchAll(sort: "desc", pageNumber: "1", pageSize: "10")
    }
    
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {
        manager.fetchAll(sort: "desc", pageNumber: "1", pageSize: "10")
        self.tableView.reloadData()
        refreshControl.endRefreshing()
      }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.customerCell, for: indexPath) as! CustomerCell
        
        cell.customerName.text = itemArray[indexPath.row].name
        cell.customerPhone.text = itemArray[indexPath.row].phone
        
        let completeUrlString = K.photoUrl + itemArray[indexPath.row].completeImgUrl
        
        if itemArray.count > 0 {
            if let url = URL(string: completeUrlString) {
                let task = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    DispatchQueue.main.async { /// execute on main thread
                        cell.customerImage.image = UIImage(data: data)
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
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "CustomerToAdd", sender: self)
    }
    

    private func handleEdit() {
        performSegue(withIdentifier: "CustomerToAdd", sender: self)
    }

    private func handleDelete() {
        let alert = UIAlertController(title: "Delete Customer", message: "Are you sure you want to delete this customer?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { (action) in
            self.manager.deleteCustomer(id: self.id)
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    private func handleDetails() {
        performSegue(withIdentifier: K.customersToDetails, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.customersToDetails {
            let customerDetailVC = segue.destination as! PersonDetailsViewController
            customerDetailVC.selectedOption = selectedOption
            customerDetailVC.id = id
            id = ""
        }
        
        if segue.identifier == "CustomerToAdd" {
            let updateCustomer = segue.destination as! SavePersonViewController
            updateCustomer.isStaff = false
            if id != "" {
                updateCustomer.id = id
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
extension CustomersListTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Perform request using the text and reload the list with the returned items
        manager.fetchSearch(name: searchBar.text!)
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            manager.fetchAll(sort: "desc", pageNumber: "1", pageSize: "10")
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    
    
}

//MARK: - URLSessionDelegate
extension CustomersListTableViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           //Trust the certificate even if not valid
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

           completionHandler(.useCredential, urlCredential)
        }
}

//MARK: - ManagerDelegates

extension CustomersListTableViewController : CustomerManagerDelegate {
    func didCreateCustomer(_ customerManager: CustomerManager, status: Int) {
        
    }
    
    func didDeleteCustomer(_ customerManager: CustomerManager, status: Int) {
        DispatchQueue.main.async {
            if status == 200 {
                self.id = ""
                self.manager.fetchAll(sort: "desc", pageNumber: "1", pageSize: "10")
                self.tableView.reloadData()
            }
        }
    }
    
    func didUpdateCustomer(_ customerManager: CustomerManager, customer: [CustomerModel]) {
        DispatchQueue.main.async {
            self.itemArray = customer
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
    
}
