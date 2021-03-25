//
//  LoginManager.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 17/03/2021.
//

import UIKit

protocol LoginManagerDelegate {
    func didPerformLogin(_ loginManager: LoginManager, statusCode: Int, loginData: LoginModel)
    func didFailWithError(_ error: Error)
}

class LoginManager: LibraryManager {
    
    var delegate: LoginManagerDelegate?
    
    //MARK: - POST
    
    func login(email: String, password: String){
        let urlString = "\(libraryUrl)staffs/Login"
        performLogin(urlString: urlString, email: email, password: password)
    }
    
    func performLogin(urlString: String, email: String, password: String){
        let parameters: [String : Any] = ["Email" : "\(email)", "Password" : "\(password)"]
        
        let loginData = try? JSONSerialization.data(withJSONObject: parameters)
        
        var request = URLRequest(url: URL(string: urlString)!, timeoutInterval: Double.infinity)
        request.httpMethod = "POST"
        
        //Headers
        request.setValue("\(String(describing: loginData?.count))", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = loginData
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                self.delegate?.didFailWithError(error!)
                return
            }
            
            if let safeResponse = response as? HTTPURLResponse {
                if let safeData = data {
                    if let loginData = self.parseJSON(safeData) {
                        self.delegate?.didPerformLogin(self, statusCode: safeResponse.statusCode, loginData: loginData)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    //MARK: - Formatting and Parsing Methods
    
    func parseJSON(_ loginData: Data) -> LoginModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(LoginData.self, from: loginData)
            
            let login = LoginModel(Token: decodedData.access_token, Id: decodedData.staff_id, Name: decodedData.staff_name, Role: decodedData.staff_role)
            
            return login
            
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}
