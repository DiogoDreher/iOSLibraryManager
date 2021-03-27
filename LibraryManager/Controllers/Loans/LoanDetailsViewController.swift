//
//  LoanDetailsViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 19/03/2021.
//

import UIKit

class LoanDetailsViewController: UIViewController {
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var staffName: UILabel!
    @IBOutlet weak var loanDate: UILabel!
    @IBOutlet weak var returnDate: UILabel!
    @IBOutlet weak var returnDateStack: UIStackView!
    @IBOutlet weak var returnDateLabel: UILabel!
    
    var id: String = ""
    
    let manager = LoanManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !LoginInfo.loginInstance.isLogeegdIn {
            navigationController?.popToRootViewController(animated: true)
        }
        
        bookImage.layer.cornerRadius = 10

        manager.delegate = self
        manager.fetchOne(id: id)
    }
    
    func updateUI(with loan: LoanModel) {
        bookName.text = loan.bookName
        customerName.text = loan.customerName
        staffName.text = loan.staffName
        loanDate.text = loan.loanDate
        
        if !loan.isActive {
            returnDate.text = "\(loan.returnDate)"
        }
        else{
            if loan.isLate {
                returnDateLabel.text = "Status:"
                returnDate.text = "Late"
            } else {
                returnDateStack.removeFromSuperview()
            }
        }
        
        let completeUrl = K.photoUrl + loan.completeImgUrl
        
        if let url = URL(string: completeUrl) {
            let task = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    self.bookImage.image = UIImage(data: data)
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
extension LoanDetailsViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           //Trust the certificate even if not valid
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

           completionHandler(.useCredential, urlCredential)
        }
}

//MARK: - ManagerDelegate

extension LoanDetailsViewController : LoanManagerDelegate {
    func didCreateLoan(_ loanManager: LoanManager, status: Int, message: String) {
        
    }
    
    func didReturnLoan(_ loanManager: LoanManager, status: Int) {
        
    }
    
    func didDeleteLoan(_ loanManager: LoanManager, status: Int) {
        
    }
    
    func didUpdateLoan(_ loanManager: LoanManager, loan: [LoanModel]) {
        DispatchQueue.main.async {
            self.updateUI(with: loan[0])
        }
        
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
    
    
}
