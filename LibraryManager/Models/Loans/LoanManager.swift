//
//  LoanManager.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 17/03/2021.
//

import Foundation

protocol LoanManagerDelegate {
    func didUpdateLoan(_ loanManager: LoanManager, loan: [LoanModel])
    func didCreateLoan(_ loanManager: LoanManager, status: Int)
    func didReturnLoan(_ loanManager: LoanManager, status: Int)
    func didDeleteLoan(_ loanManager: LoanManager, status: Int)
    func didFailWithError(_ error: Error)
}

class LoanManager: LibraryManager {
    
    var delegate: LoanManagerDelegate?
    
    
    //MARK: -  GET
    func fetchAll(sort: String?, state: Bool, pageNumber: String?, pageSize: String?) {
        let currentSort = sort ?? "desc"
        let currentPageNumber = pageNumber ?? "1"
        let currentPageSize = pageSize ?? "10"
        
        let urlString = "\(libraryUrl)loans/AllLoans?sort=\(currentSort)&state=\(state)&pageNumber=\(currentPageNumber)&pageSize=\(currentPageSize)"
        performRequest(with: urlString)
    }
    
    func fetchOne(id: String) {
        
        let urlString = "\(libraryUrl)loans/LoanDetail/\(id)"
        performRequest(with: urlString)
    }
    
    func fetchSearch(name: String, active: Bool) {
        let urlString = "\(libraryUrl)loans/FindLoans?name=\(name)&active=\(active)"
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
                    if let loanData = self.parseJSON(safeData) {
                        self.delegate?.didUpdateLoan(self, loan: loanData)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
            
        }
    }
    
    //MARK: - POST
    
    func createLoan(with loan: LoanModel) {
        let urlString = "\(libraryUrl)loans"
        performPost(urlString: urlString, loan: loan)
    }
    
    func performPost(urlString: String, loan: LoanModel) {
        let parameters: [String: Any] = ["CustomerId" : "\(loan.customerId)", "StaffId" : "\(loan.staffId)", "BookId" : "\(loan.bookId)",  "LoanDate" : "\(loan.loanDate)"]
        
        let postData = try? JSONSerialization.data(withJSONObject: parameters)

        var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: Double.infinity)
        request.httpMethod = "POST"
        
        //HTTP Headers
        request.setValue("\(String(describing: postData?.count))", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData

        let task = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: request) { data, response, error in
            if error != nil {
                self.delegate?.didFailWithError(error!)
                return
            }
            
            if let safeResponse = response as? HTTPURLResponse {
                self.delegate?.didCreateLoan(self, status: safeResponse.statusCode)
            }
        }

        task.resume()
    }
    
    //MARK: - PUT
        
    func returnLoan(id: String, returnDate: String) {
        let urlString = "\(libraryUrl)loans/Return/\(id)"
        performReturn(urlString: urlString, returnDate: returnDate)
    }
    
    func performReturn(urlString: String, returnDate: String) {
        let parameters: [String: Any] = ["ReturnDate": "\(returnDate)"]
        let postData = try? JSONSerialization.data(withJSONObject: parameters)
        
        var request = URLRequest(url: URL(string: urlString)!, timeoutInterval: Double.infinity)
        request.httpMethod = "PUT"
        
        //HTTP Headers
        request.setValue("\(String(describing: postData?.count))", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        let task = URLSession(configuration: .default, delegate: self, delegateQueue: nil).dataTask(with: request) { data, response, error in
            if error != nil {
                self.delegate?.didFailWithError(error!)
                return
            }
            
            if let safeResponse = response as? HTTPURLResponse {
                self.delegate?.didReturnLoan(self, status: safeResponse.statusCode)
            }
        }

        task.resume()
    }
    
    //MARK: - DELETE
    
    func deleteLoan(id: String) {
        let urlString = "\(libraryUrl)loans/\(id)"
        performDelete(urlString: urlString)
    }
    
    func performDelete(urlString: String) {
        print(urlString)
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
                    print(safeResponse.statusCode)
                    self.delegate?.didDeleteLoan(self, status: safeResponse.statusCode)
                }
            }.resume()
        }
    }
    
    func parseJSON(_ loanData: Data) -> [LoanModel]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([LoanData].self, from: loanData)
            
            var loanArray: [LoanModel] = []
            
            decodedData.forEach { (loan) in
                let loanObj = LoanModel(id: loan.id, customerName: loan.customerName, customerId: loan.customerId, staffName: loan.staffName, staffId: loan.staffId, bookName: loan.bookName, bookImage: loan.bookImage, bookId: loan.bookId, isActive: loan.isActive, loanDate: loan.loanDate, returnDate: loan.returnDate ?? "")
                loanArray.append(loanObj)
            }
            
            return loanArray
        } catch {
            print(error)
            return nil
        }
    }
    
}
