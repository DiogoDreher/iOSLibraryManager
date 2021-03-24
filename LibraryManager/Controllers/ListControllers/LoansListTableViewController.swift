//
//  LoansListTableViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 18/03/2021.
//

import UIKit

class LoansListTableViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var id: String = ""

    var selectedOption: String = ""
    
    var manager = LoanManager()
    
    var itemArray: [LoanModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedOption
        
        manager.delegate = self
        searchBar.delegate = self
        
        tableView.register(UINib(nibName: "LoanCell", bundle: nil), forCellReuseIdentifier: "LoanCell")
        
        manager.fetchAll(sort: "desc", state: true, pageNumber: "1", pageSize: "10")
        
    }
        
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoanCell", for: indexPath) as! LoanCell
        
        cell.customerName.text = itemArray[indexPath.row].customerName
        cell.bookName.text = itemArray[indexPath.row].bookName
        //cell.loanDate.text = String(itemArray[indexPath.row].loanDate.prefix(10))
        
               
        
        return cell
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "LoansToAdd", sender: self)
    }
    

    private func handleReturn() {
        performSegue(withIdentifier: "LoansToAdd", sender: self)
    }

    private func handleDelete() {
        let alert = UIAlertController(title: "Delete Loan", message: "Are you sure you want to delete this loan?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { (action) in
            self.manager.deleteLoan(id: self.id)
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func handleDetails() {
        performSegue(withIdentifier: K.loansToDetails, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.loansToDetails {
            let loanDetailVC = segue.destination as! LoanDetailsViewController
            loanDetailVC.id = id
            id = ""
        }
        
        if segue.identifier == "LoansToAdd" {
            if id != "" {
                let updateLoanVC = segue.destination as! SaveLoanViewController
                updateLoanVC.id = id
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
        let returnLoan = UIContextualAction(style: .normal,
                                       title: "Return") { [weak self] (action, view, completionHandler) in
            self!.id = self!.itemArray[indexPath.row].id
                                        self?.handleReturn()
                                        completionHandler(true)
        }
        returnLoan.backgroundColor = .systemYellow
        
        // Trash action
        let delete = UIContextualAction(style: .destructive,
                                       title: "Delete") { [weak self] (action, view, completionHandler) in
            self!.id = self!.itemArray[indexPath.row].id
                                        self?.handleDelete()
                                        completionHandler(true)
        }
        delete.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [delete, returnLoan, details])

        return configuration
    }
    
}


//MARK: - UISearchBar Delegate
extension LoansListTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Perform request using the text and reload the list with the returned items
        manager.fetchSearch(name: searchBar.text!, active: true)
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            manager.fetchAll(sort: "desc", state: true, pageNumber: "1", pageSize: "10")
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    
    
}

//MARK: - URLSessionDelegate
extension LoansListTableViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           //Trust the certificate even if not valid
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

           completionHandler(.useCredential, urlCredential)
        }
}

//MARK: - ManagerDelegates

extension LoansListTableViewController : LoanManagerDelegate {
    func didCreateLoan(_ loanManager: LoanManager, status: Int) {
        
    }
    
    func didReturnLoan(_ loanManager: LoanManager, status: Int) {
        
    }
    
    func didDeleteLoan(_ loanManager: LoanManager, status: Int) {
        DispatchQueue.main.async {
            if status == 200 {
                self.id = ""
                self.manager.fetchAll(sort: "desc", state: true, pageNumber: "1", pageSize: "10")
                self.tableView.reloadData()
            }
        }
    }
    
    func didUpdateLoan(_ loanManager: LoanManager, loan: [LoanModel]) {
        DispatchQueue.main.async {
            self.itemArray = loan
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
    
 
}
