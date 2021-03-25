//
//  MainViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 12/03/2021.
//

import UIKit

class MainViewController: UIViewController {
    
    var selection = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !LoginInfo.loginInstance.isLogeegdIn {
            navigationController?.popToRootViewController(animated: true)
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func optionPressed(_ sender: UIButton) {
        selection = sender.currentTitle!
        switch selection {
            case "Staff":
                performSegue(withIdentifier: K.mainToStaff, sender: self)
            case "Customers":
                performSegue(withIdentifier: K.mainToCustomers, sender: self)
            case "Loans":
                performSegue(withIdentifier: K.mainToLoans, sender: self)
            default:
                performSegue(withIdentifier: K.mainToBooks, sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let itemListVC = segue.destination
        
        switch segue.identifier {
            case K.mainToStaff:
                let staffListVC = itemListVC as! StaffListTableViewController
                staffListVC.selectedOption = selection
                
            case K.mainToCustomers:
                let customerListVC = itemListVC as! CustomersListTableViewController
                customerListVC.selectedOption = selection
                
            case K.mainToLoans:
                let itemListVC = segue.destination as! LoansListTableViewController
                itemListVC.selectedOption = selection
                
            default:
                let bookListVC = itemListVC as! BooksListTableViewController
                bookListVC.selectedOption = selection
        }
    }
    
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        LoginInfo.loginInstance.isLogeegdIn = false
        LoginInfo.loginInstance.userId = ""
        LoginInfo.loginInstance.userName = ""
        LoginInfo.loginInstance.userToken = ""
        LoginInfo.loginInstance.userRole = ""
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
