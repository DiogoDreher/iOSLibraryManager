//
//  SavePersonViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 22/03/2021.
//

import UIKit

class SavePersonViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    @IBOutlet weak var personName: UITextField!
    @IBOutlet weak var personEmail: UITextField!
    @IBOutlet weak var personPassword: UITextField!
    @IBOutlet weak var personAddress: UITextField!
    @IBOutlet weak var personPhone: UITextField!
    @IBOutlet weak var personRole: UIPickerView!
    @IBOutlet weak var personState: UISwitch!
    @IBOutlet weak var personImage: UIImageView!
    
    @IBOutlet weak var passwordStack: UIStackView!
    @IBOutlet weak var roleStack: UIStackView!
    @IBOutlet weak var statusStack: UIStackView!
    
    let imagePicker = UIImagePickerController()
    
    let staffManager = StaffManager()
    
    let customerManager = CustomerManager()
    
    var isStaff: Bool = true
    
    var pickedImageURL = ""
    
    var id: String = ""
    
    var oldPassword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        personRole.delegate = self
        
        staffManager.delegate = self
        customerManager.delegate = self
        
        if isStaff {
            if id == "" {
                roleStack.removeFromSuperview()
                statusStack.removeFromSuperview()
            }
            else
            {
                staffManager.fetchOne(id: id)
            }
        }
        else
        {
            passwordStack.removeFromSuperview()
            roleStack.removeFromSuperview()
            
            if id == "" {
                statusStack.removeFromSuperview()
            }
            else{
                customerManager.fetchOne(id: id)
            }
        }
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
       
            
            if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                
                    
                personImage.image = userPickedImage
                
                imagePicker.dismiss(animated: true, completion: nil)
            }
        
                
        
    }
    


    @IBAction func addImagePressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        if  personName.text != "" &&
            personEmail.text != "" &&
            personAddress.text != "" &&
            personPhone.text != "" &&
            personImage.image != nil {
            
            if isStaff && personPassword.text != "" {
                if id == "" {
                    let staff = StaffModel(id: "", name: personName.text!, email: personEmail.text!, password: personPassword.text!, address: personAddress.text!, phone: personPhone.text!, isActive: true, imageUrl: pickedImageURL, image: personImage.image!, dateAdded: "", role: "")
                    staffManager.createStaff(with: staff)
                }
                else
                {
                    var role = ""
                    
                    if personRole.selectedRow(inComponent: 0) == 0 {
                        role = "Staff"
                    }
                    else {
                        role = "Admin"
                    }
                    let staff = StaffModel(id: id, name: personName.text!, email: personEmail.text!, password: personPassword.text!, address: personAddress.text!, phone: personPhone.text!, isActive: personState.isOn, imageUrl: pickedImageURL, image: personImage.image!, dateAdded: "", role: role)
                    staffManager.updateStaff(with: staff, oldPsw: oldPassword)
                }
            }
            else
            {
                if !isStaff {
                    if id == "" {
                        let customer = CustomerModel(id: "", name: personName.text!, email: personEmail.text!, address: personAddress.text!, phone: personPhone.text!, isActive: true, dateAdded: "", imageUrl: pickedImageURL, image: personImage.image!)
                        customerManager.createCustomer(with: customer)
                    }
                    else
                    {
                        let customer = CustomerModel(id: id, name: personName.text!, email: personEmail.text!, address: personAddress.text!, phone: personPhone.text!, isActive: personState.isOn, dateAdded: "", imageUrl: pickedImageURL, image: personImage.image!)
                        customerManager.updateCustomer(with: customer)
                    }
                }
                else
                {
                    print("Error")
                }
            }

            
        }
        else {
            print("Error")
        }
    }
    
    func updateUIStaff(staff: StaffModel) {
        personName.text = staff.name
        personEmail.text = staff.email
        personPassword.text = "[Edit to change Password]"
        personAddress.text = staff.address
        personPhone.text = staff.phone
        personRole.selectRow((staff.role == "Staff") ? 0 : 1, inComponent: 0, animated: true)
        personState.isOn = staff.isActive
        
        oldPassword = staff.password
        
        let completeUrl = K.photoUrl + staff.completeImgUrl
        
        if let url = URL(string: completeUrl) {
            let task = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    self.personImage.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
    }
    
    func updateUICustomer(customer: CustomerModel) {
        personName.text = customer.name
        personEmail.text = customer.email
        personAddress.text = customer.address
        personPhone.text = customer.phone
        personState.isOn = customer.isActive
        
        let completeUrl = K.photoUrl + customer.completeImgUrl
        
        if let url = URL(string: completeUrl) {
            let task = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    self.personImage.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
    }
}

//MARK: - URLSessionDelegate
extension SavePersonViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           //Trust the certificate even if not valid
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

           completionHandler(.useCredential, urlCredential)
        }
}

//MARK: - PickerViewDelegate

extension SavePersonViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Staff"
        } else {
            return "Admin"
        }
       
    }
    
}

//MARK: - Manager Delegates

extension SavePersonViewController : StaffManagerDelegate {
    func didUpdateStaff(_ staffManager: StaffManager, staff: [StaffModel]) {
        DispatchQueue.main.async {
            self.updateUIStaff(staff: staff[0])
        }
    }
    
    func didCreateStaff(_ staffManager: StaffManager, status: Int) {
        if status == 201 || status == 200 {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didDeleteStaff(_ staffManager: StaffManager, status: Int) {
    }
    
    func didFailWithError(_ error: Error) {
        
    }
    
}

extension SavePersonViewController : CustomerManagerDelegate {
    func didCreateCustomer(_ customerManager: CustomerManager, status: Int) {
        if status == 201 || status == 200 {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didDeleteCustomer(_ customerManager: CustomerManager, status: Int) {
        
    }
    
    func didUpdateCustomer(_ customerManager: CustomerManager, customer: [CustomerModel]) {
        DispatchQueue.main.async {
            self.updateUICustomer(customer: customer[0])
        }
    }
    
    
}
