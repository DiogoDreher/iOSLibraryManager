//
//  DetailsViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 14/03/2021.
//

import UIKit

class BookDetailsViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookDescription: UITextView!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookGenre: UILabel!
    @IBOutlet weak var bookPublisher: UILabel!
    @IBOutlet weak var bookYear: UILabel!
    @IBOutlet weak var bookStatus: UILabel!
    
    var selectedOption: String = ""
    
    var id: String = ""
    
    let manager = BookManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !LoginInfo.loginInstance.isLogeegdIn {
            navigationController?.popToRootViewController(animated: true)
        }
        
        title = selectedOption
        
        image.layer.cornerRadius = 10
        
        //declarar dois managers como globais, fazer switch e ativar o necessário
       
            manager.delegate = self
        
            manager.fetchOne(id: id)
            

        // Do any additional setup after loading the view.
        
    }
     

    func updateUI(book: BookModel) {
        bookTitle.text = book.name
        bookDescription.text = book.description
        bookAuthor.text = book.author
        bookGenre.text = book.genre
        bookPublisher.text = book.publisher
        bookYear.text = String(book.year)
        bookStatus.text = (book.isActive) ? "Available" : "On Loan"
    
        let completeUrl = K.photoUrl + book.completeImgUrl
        
        if let url = URL(string: completeUrl) {
            let task = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    self.image.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
    }

}

//MARK: - URLSessionDelegate
extension BookDetailsViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           //Trust the certificate even if not valid
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

           completionHandler(.useCredential, urlCredential)
        }
}

//MARK: - ManagerDelegates



extension BookDetailsViewController : BookManagerDelegate {
    func didDeleteBook(_ bookManager: BookManager, status: Int) {
        
    }
    
    func didCreateBook(_ bookManager: BookManager, status: Int) {
        
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
    
    func didUpdateBook(_ bookManager: BookManager, book: [BookModel]) {
        DispatchQueue.main.async {
            self.updateUI(book: book[0])
        }
    }
    
}

