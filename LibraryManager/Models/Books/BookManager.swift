//
//  BookManager.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 17/03/2021.
//

import UIKit

protocol BookManagerDelegate {
    func didUpdateBook(_ bookManager: BookManager, book: [BookModel])
    func didCreateBook(_ bookManager: BookManager, status: Int)
    func didDeleteBook(_ bookManager: BookManager, status: Int, message: String)
    func didFailWithError(_ error: Error)
}

class BookManager: LibraryManager {
    
    var delegate: BookManagerDelegate?
    
    
    //MARK: - GET
    
    func fetchAll(sort: String?, pageNumber: String?, pageSize: String?) {
        
        let currentSort = sort ?? "desc"
        let currentPageNumber = pageNumber ?? "1"
        let currentPageSize = pageSize ?? "10"
        
        let urlString = "\(libraryUrl)books/AllBooks?sort=\(currentSort)&pageNumber=\(currentPageNumber)&pageSize=\(currentPageSize)"
        performRequest(with: urlString)
        
    }
    
    func fetchAvailable() {
        let urlString = "\(libraryUrl)books/AvailableBooks"
        performRequest(with: urlString)
    }
    
    
    func fetchOne(id: String) {
        
        let urlString = "\(libraryUrl)books/BookDetail/\(id)"
        performRequest(with: urlString)
    }
    
    func fetchSearch(name: String) {
        let urlString = "\(libraryUrl)books/FindBooks?bookName=\(name)"
        performRequest(with: urlString)
    }
    
    
    func performRequest(with urlString: String){
        
        //1. Create URL
        if let url = URL(string: urlString){
            
            //2. Create a URLSession
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data {
                    if let bookData = self.parseJSON(safeData) {
                        self.delegate?.didUpdateBook(self, book: bookData)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
            
        }
    }
    
    //MARK: - POST
    
    func createBook(with book: BookModel) {
        let urlString = "\(libraryUrl)books/"
        performPost(urlString: urlString, book: book)
    }
    
    func performPost(urlString: String, book: BookModel) {
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        //let jsonData = try! JSONSerialization.data(withJSONObject: book, options: [])
        let imageData = book.image.jpegData(compressionQuality: 0.8)
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Powered by Swift!", forHTTPHeaderField: "X-Powered-By")
            
            let httpBody = NSMutableData()
            httpBody.appendString(convertFormField(named: "Name", value: book.name, using: boundary))
            httpBody.appendString(convertFormField(named: "Description", value: book.description, using: boundary))
            httpBody.appendString(convertFormField(named: "Author", value: book.author, using: boundary))
            httpBody.appendString(convertFormField(named: "Genre", value: book.genre, using: boundary))
            httpBody.appendString("--\(boundary)\r\nContent-Disposition: form-data; name=\"Year\"\r\n\r\n\(book.year)\r\n")
            httpBody.appendString(convertFormField(named: "Publisher", value: book.publisher, using: boundary))
            
            httpBody.append(convertFileData(fieldName: "Image", fileName: "image.jpeg", mimeType: "image/jpeg", fileData: imageData!, using: boundary))
            
            httpBody.appendString("--\(boundary)--")
            
            print(httpBody)

            request.httpBody = httpBody as Data
            
            session.dataTask(with: request) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeResponse = response as? HTTPURLResponse {
                    self.delegate?.didCreateBook(self, status: safeResponse.statusCode)
                }
            }.resume()
        }
    }
    
    //MARK: - PUT
    
    func updateBook(with book: BookModel) {
        let urlString = "\(libraryUrl)books/\(book.id)"
        performPut(urlString: urlString, book: book)
    }
    
    func performPut(urlString: String, book: BookModel) {
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        //let jsonData = try! JSONSerialization.data(withJSONObject: book, options: [])
        let imageData = book.image.jpegData(compressionQuality: 0.8)
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Powered by Swift!", forHTTPHeaderField: "X-Powered-By")
            
            let httpBody = NSMutableData()
            httpBody.appendString(convertFormField(named: "Name", value: book.name, using: boundary))
            httpBody.appendString(convertFormField(named: "Description", value: book.description, using: boundary))
            httpBody.appendString(convertFormField(named: "Author", value: book.author, using: boundary))
            httpBody.appendString(convertFormField(named: "Genre", value: book.genre, using: boundary))
            httpBody.appendString("--\(boundary)\r\nContent-Disposition: form-data; name=\"Year\"\r\n\r\n\(book.year)\r\n")
            httpBody.appendString(convertFormField(named: "LoanDate", value: book.loadDate!, using: boundary))
            httpBody.appendString(convertFormField(named: "Publisher", value: book.publisher, using: boundary))
            
            httpBody.append(convertFileData(fieldName: "Image", fileName: "image.jpeg", mimeType: "image/jpeg", fileData: imageData!, using: boundary))
            
            httpBody.appendString("--\(boundary)--")
            
            print(httpBody)

            request.httpBody = httpBody as Data
            
            session.dataTask(with: request) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeResponse = response as? HTTPURLResponse {
                    self.delegate?.didCreateBook(self, status: safeResponse.statusCode)
                }
            }.resume()
        }
    }
    
    //MARK: - DELETE
    
    func deleteBook(id: String) {
        let urlString = "\(libraryUrl)books/\(id)"
        performDelete(urlString: urlString)
    }
    
    func performDelete(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            
            session.dataTask(with: request) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeResponse = response as? HTTPURLResponse {
                    if let safeData = data {
                        let message = String(data: safeData, encoding: String.Encoding.utf8)!
                        if safeResponse.statusCode == 200 {
                            self.delegate?.didDeleteBook(self, status: safeResponse.statusCode, message: message)
                        }
                        else{
                            self.delegate?.didDeleteBook(self, status: safeResponse.statusCode, message: message)
                        }
                        
                    }
                    
                }
            }.resume()
        }
    }
    
    //MARK: - Formatting and Parsing Methods
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
      var fieldString = "--\(boundary)\r\n"
      fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
      fieldString += "\r\n"
      fieldString += "\(value)\r\n"

      return fieldString
    }
    
    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
      let data = NSMutableData()

      data.appendString("--\(boundary)\r\n")
      data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
      data.appendString("Content-Type: \(mimeType)\r\n\r\n")
      data.append(fileData)
      data.appendString("\r\n")

      return data as Data
    }
    
    func parseJSON(_ libraryData: Data) -> [BookModel]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([BookData].self, from: libraryData)
            
            var bookArray: [BookModel] = []
            
            decodedData.forEach { (bookData) in
                let bookObj = BookModel(id: bookData.id, name: bookData.name, description: bookData.description ?? "", author: bookData.author, genre: bookData.genre, year: bookData.year, publisher: bookData.publisher, isActive: bookData.isAvailable, loadDate: bookData.loanDate, imageUrl: bookData.imageUrl, image: UIImage(named: "hpphilosopher")! )
                bookArray.append(bookObj)
            }
            
            return bookArray
        } catch {
            print(error)
            return nil
        }
    }

}

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
