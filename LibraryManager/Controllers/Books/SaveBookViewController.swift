//
//  SaveBookViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 20/03/2021.
//

import UIKit

class SaveBookViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var bookName: UITextField!
    @IBOutlet weak var bookDescription: UITextField!
    @IBOutlet weak var bookAuthor: UITextField!
    @IBOutlet weak var bookGenre: UITextField!
    @IBOutlet weak var bookPublisher: UITextField!
    @IBOutlet weak var bookYear: UITextField!
    @IBOutlet weak var bookImage: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    let bookManager = BookManager()
    
    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !LoginInfo.loginInstance.isLogeegdIn {
            navigationController?.popToRootViewController(animated: true)
        }

        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        bookManager.delegate = self
        
        if id != "" {
            bookManager.fetchOne(id: id)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            bookImage.image = userPickedImage
            
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }

   
    @IBAction func addImagePressed(_ sender: UIButton) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        if  bookName.text != "" &&
            bookDescription.text != "" &&
            bookAuthor.text != "" &&
            bookGenre.text != "" &&
            bookYear.text != "" &&
            bookPublisher.text != "" &&
            bookImage.image != nil {
            
            if id == "" {
                let book = BookModel(id: "", name: bookName.text!, description: bookDescription.text!, author: bookAuthor.text!, genre: bookGenre.text!, year: Int(bookYear.text!)!, publisher: bookPublisher.text!, isActive: true, loadDate: "", imageUrl: "", image: bookImage.image!)
                bookManager.createBook(with: book)
            }
            else{
                let book = BookModel(id: id, name: bookName.text!, description: bookDescription.text!, author: bookAuthor.text!, genre: bookGenre.text!, year: Int(bookYear.text!)!, publisher: bookPublisher.text!, isActive: true, loadDate: "", imageUrl: "", image: bookImage.image!)
                bookManager.updateBook(with: book)
            }
            
            
        } else {
            print("Error")
        }
    }
    
    
    func updateUI(book: BookModel) {
        bookName.text = book.name
        bookDescription.text = book.description
        bookAuthor.text = book.author
        bookGenre.text = book.genre
        bookYear.text = "\(book.year)"
        bookPublisher.text = book.publisher
        
        let completeUrl = K.photoUrl + book.completeImgUrl
        
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
}

//MARK: - URLSessionDelegate
extension SaveBookViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           //Trust the certificate even if not valid
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

           completionHandler(.useCredential, urlCredential)
        }
}

//MARK: - Book Manager Delegate

extension SaveBookViewController : BookManagerDelegate {
    func didDeleteBook(_ bookManager: BookManager, status: Int) {
        
    }
    
    func didCreateBook(_ bookManager: BookManager, status: Int) {
        
        if status == 201 || status == 200 {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    func didUpdateBook(_ bookManager: BookManager, book: [BookModel]) {
        DispatchQueue.main.async {
            self.updateUI(book: book[0])
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
    
    
}
