//
//  PersonDetailsViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 19/03/2021.
//

import UIKit

class PersonDetailsViewController: UIViewController {
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var personEmail: UILabel!
    @IBOutlet weak var personAddress: UILabel!
    @IBOutlet weak var personPhone: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var personRole: UILabel!
    @IBOutlet weak var personState: UILabel!
    
    var selectedOption: String = ""
    
    var id: String = ""
    
    let staffManager = StaffManager()
    let customerManager = CustomerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !LoginInfo.loginInstance.isLogeegdIn {
            navigationController?.popToRootViewController(animated: true)
        }
        
        personImage.layer.cornerRadius = 10

        if selectedOption == "Staff" {
            staffManager.delegate = self
            staffManager.fetchOne(id: id)
        }
        else
        {
            customerManager.delegate = self
            customerManager.fetchOne(id: id)
        }
    }
    
    func updateUIStaff(with staff: StaffModel) {
        personName.text = staff.name
        personEmail.text = staff.email
        personAddress.text = staff.address
        personPhone.text = staff.phone
        personRole.text = staff.role
        personState.text = (staff.isActive) ? "Active" : "Inactive"
        
        let completeUrl = K.photoUrl + staff.completeImgUrl
        insertImage(url: completeUrl)
        
    }
    
    func updateUICustomer(with customer: CustomerModel) {
        personName.text = customer.name
        personEmail.text = customer.email
        personAddress.text = customer.address
        personPhone.text = customer.phone
        roleLabel.removeFromSuperview()
        personRole.removeFromSuperview()
        personState.text = (customer.isActive) ? "Active" : "Inactive"
        
        let completeUrl = K.photoUrl + customer.completeImgUrl
        insertImage(url: completeUrl)
        
    }
    
    func insertImage(url: String) {
        if let url = URL(string: url) {
            let task = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    self.personImage.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
    }

    @IBAction func editPressed(_ sender: UIBarButtonItem) {
    }
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
    }
}

//MARK: - URLSessionDelegate

extension PersonDetailsViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           //Trust the certificate even if not valid
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

           completionHandler(.useCredential, urlCredential)
        }
}

//MARK: - ManagerDelegates

extension PersonDetailsViewController : StaffManagerDelegate {
    func didCreateStaff(_ staffManager: StaffManager, status: Int) {
        
    }
    
    func didDeleteStaff(_ staffManager: StaffManager, status: Int) {
        
    }
    
    func didUpdateStaff(_ staffManager: StaffManager, staff: [StaffModel]) {
        DispatchQueue.main.async {
            self.updateUIStaff(with: staff[0])
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
    
}

extension PersonDetailsViewController : CustomerManagerDelegate {
    func didCreateCustomer(_ customerManager: CustomerManager, status: Int) {
        
    }
    
    func didDeleteCustomer(_ customerManager: CustomerManager, status: Int) {
        
    }
    
    func didUpdateCustomer(_ customerManager: CustomerManager, customer: [CustomerModel]) {
        DispatchQueue.main.async {
            self.updateUICustomer(with: customer[0])
        }
    }
    
}
