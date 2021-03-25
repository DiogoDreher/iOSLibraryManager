//
//  SaveLoanViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 23/03/2021.
//

import UIKit

class SaveLoanViewController: UIViewController {
    @IBOutlet weak var loanBook: UIPickerView!
    @IBOutlet weak var loanCustomer: UIPickerView!
    @IBOutlet weak var loanStaff: UIPickerView!
    @IBOutlet weak var loanDate: UIDatePicker!
    @IBOutlet weak var loanReturnDate: UIDatePicker!
    
    @IBOutlet weak var addLoanStack: UIStackView!
    @IBOutlet weak var returnLoanStack: UIStackView!
    
    var id: String = ""
    
    let bookManager = BookManager()
    let staffManager = StaffManager()
    let customerManager = CustomerManager()
    let loanManager = LoanManager()
    
    var bookArray: [BookModel] = []
    var staffArray: [StaffModel] = []
    var customerArray: [CustomerModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !LoginInfo.loginInstance.isLogeegdIn {
            navigationController?.popToRootViewController(animated: true)
        }
 
        bookManager.delegate = self
        staffManager.delegate = self
        customerManager.delegate = self
        loanManager.delegate = self       
        
        
        
        if id == "" {
            returnLoanStack.removeFromSuperview()
            
            loanBook.delegate = self
            loanBook.dataSource = self
            loanBook.tag = 0
            bookManager.fetchAvailable()
            
            loanCustomer.delegate = self
            loanCustomer.dataSource = self
            loanCustomer.tag = 1
            customerManager.fetchAll(sort: "desc", pageNumber: "1", pageSize: "1000")
            
            loanStaff.delegate = self
            loanStaff.dataSource = self
            loanStaff.tag = 2
            staffManager.fetchAll(sort: "desc", pageNumber: "1", pageSize: "1000")
        }
        else
        {
            addLoanStack.removeFromSuperview()
        }
        
    }
    

    @IBAction func saveLoanPressed(_ sender: UIBarButtonItem) {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if id == "" {
            let pickedBook = loanBook.selectedRow(inComponent: 0)
            let pickedCustomer = loanCustomer.selectedRow(inComponent: 0)
            let pickedStaff = loanStaff.selectedRow(inComponent: 0)
            
            let loan = LoanModel(id: "", customerName: customerArray[pickedCustomer].name, customerId: customerArray[pickedCustomer].id, staffName: staffArray[pickedStaff].name, staffId: staffArray[pickedStaff].id, bookName: bookArray[pickedBook].name, bookImage: bookArray[pickedBook].imageUrl, bookId: bookArray[pickedBook].id, isActive: true, loanDate: dateFormatterPrint.string(from: loanDate.date), returnDate: "")
            loanManager.createLoan(with: loan)
        }
        else
        {
            let returnDate = dateFormatterPrint.string(from: loanReturnDate.date)
            loanManager.returnLoan(id: id, returnDate: returnDate)
        }
        
        
    }
    
}

//MARK: - Manager Delegates

extension SaveLoanViewController : BookManagerDelegate {
    func didUpdateBook(_ bookManager: BookManager, book: [BookModel]) {
        DispatchQueue.main.async {
            self.bookArray = book
            self.loanBook.reloadAllComponents()
        }
    }
    
    func didCreateBook(_ bookManager: BookManager, status: Int) {
        
    }
    
    func didDeleteBook(_ bookManager: BookManager, status: Int) {
        
    }
    
    func didFailWithError(_ error: Error) {
        
    }
    
}

extension SaveLoanViewController : StaffManagerDelegate {
    func didUpdateStaff(_ staffManager: StaffManager, staff: [StaffModel]) {
        DispatchQueue.main.async {
            self.staffArray = staff
            self.loanStaff.reloadAllComponents()
        }
    }
    
    func didCreateStaff(_ staffManager: StaffManager, status: Int) {
        
    }
    
    func didDeleteStaff(_ staffManager: StaffManager, status: Int) {
        
    }
        
}

extension SaveLoanViewController : CustomerManagerDelegate {
    func didUpdateCustomer(_ customerManager: CustomerManager, customer: [CustomerModel]) {
        DispatchQueue.main.async {
            self.customerArray = customer
            self.loanCustomer.reloadAllComponents()
        }
    }
    
    func didCreateCustomer(_ customerManager: CustomerManager, status: Int) {
        
    }
    
    func didDeleteCustomer(_ customerManager: CustomerManager, status: Int) {
        
    }
}

extension SaveLoanViewController : LoanManagerDelegate {
    func didCreateLoan(_ loanManager: LoanManager, status: Int) {
        if status == 201 || status == 200 {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didReturnLoan(_ loanManager: LoanManager, status: Int) {
        if status == 200 {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didDeleteLoan(_ loanManager: LoanManager, status: Int) {
        
    }
    
    func didUpdateLoan(_ loanManager: LoanManager, loan: [LoanModel]) {
        
    }
}

//MARK: - PickerViewDelegate

extension SaveLoanViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return bookArray.count
        }
        else if pickerView.tag == 1 {
            return customerArray.count
        }
        else {
            return staffArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return bookArray[row].name
        }
        else if pickerView.tag == 1 {
            return customerArray[row].name
        }
        else {
            return staffArray[row].name
        }
    }
    
}
