//
//  StaffManager.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 17/03/2021.
//

import UIKit

protocol StaffManagerDelegate {
    func didUpdateStaff(_ staffManager: StaffManager, staff: [StaffModel])
    func didCreateStaff(_ staffManager: StaffManager, status: Int)
    func didDeleteStaff(_ staffManager: StaffManager, status: Int)
    func didFailWithError(_ error: Error)
}

class StaffManager : LibraryManager {
    
        
    var delegate: StaffManagerDelegate?
    
    //MARK: - GET
    
    func fetchAll(sort: String?, pageNumber: String?, pageSize: String?) {
        let currentSort = sort ?? "desc"
        let currentPageNumber = pageNumber ?? "1"
        let currentPageSize = pageSize ?? "10"
        
        let urlString = "\(libraryUrl)staffs/AllStaffs?sort=\(currentSort)&pageNumber=\(currentPageNumber)&pageSize=\(currentPageSize)"
        performRequest(with: urlString)
    }
    
    func fetchOne(id: String) {
        
        let urlString = "\(libraryUrl)staffs/StaffDetail/\(id)"
        performRequest(with: urlString)
    }

    func fetchSearch(name: String) {
        let urlString = "\(libraryUrl)staffs/FindStaff?staffName=\(name)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        
        //1. Create URL
        if let url = URL(string: urlString){
            
            //2. Create a URLSession
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("bearer \(LoginInfo.loginInstance.userToken)", forHTTPHeaderField: "Authorization")
            
            //3. Give the session a task
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data {
                    if let staffData = self.parseJSON(safeData) {
                        self.delegate?.didUpdateStaff(self, staff: staffData)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
            
        }
    }
    
    //MARK: - POST
    
    func createStaff(with staff: StaffModel) {
        let urlString = "\(libraryUrl)staffs/Register"
        performPost(urlString: urlString, staff: staff)
    }
    
    func performPost(urlString: String, staff: StaffModel) {
        
        let imageData = staff.image.jpegData(compressionQuality: 0.8)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Powered by Swift!", forHTTPHeaderField: "X-Powered-By")
            request.setValue("bearer \(LoginInfo.loginInstance.userToken)", forHTTPHeaderField: "Authorization")
            
            let httpBody = NSMutableData()
            httpBody.appendString(convertFormField(named: "Name", value: staff.name, using: boundary))
            httpBody.appendString(convertFormField(named: "Email", value: staff.email, using: boundary))
            httpBody.appendString(convertFormField(named: "Password", value: staff.password, using: boundary))
            httpBody.appendString(convertFormField(named: "Address", value: staff.address, using: boundary))
            httpBody.appendString(convertFormField(named: "Phone", value: staff.phone, using: boundary))
            
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
                    self.delegate?.didCreateStaff(self, status: safeResponse.statusCode)
                }
            }.resume()
        }

        
    }
    
    //MARK: - PUT
    
    func updateStaff(with staff: StaffModel, oldPsw: String){
        let urlString = "\(libraryUrl)staffs/\(staff.id)"
        performPut(urlString: urlString, staff: staff, oldPsw: oldPsw)
    }
    
    func performPut(urlString: String, staff: StaffModel, oldPsw: String) {
        let imageData = staff.image.jpegData(compressionQuality: 0.8)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var password = ""
        
        if staff.password == "[Edit to change Password]" {
            password = oldPsw
        }
        else
        {
            password = staff.password
        }
                
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Powered by Swift!", forHTTPHeaderField: "X-Powered-By")
            request.setValue("bearer \(LoginInfo.loginInstance.userToken)", forHTTPHeaderField: "Authorization")

            let httpBody = NSMutableData()
            httpBody.appendString(convertFormField(named: "Name", value: staff.name, using: boundary))
            httpBody.appendString(convertFormField(named: "Email", value: staff.email, using: boundary))
            httpBody.appendString(convertFormField(named: "Password", value: password, using: boundary))
            httpBody.appendString(convertFormField(named: "Address", value: staff.address, using: boundary))
            httpBody.appendString(convertFormField(named: "Phone", value: staff.phone, using: boundary))
            httpBody.appendString(convertFormField(named: "Role", value: staff.role, using: boundary))
            httpBody.appendString(convertFormField(named: "IsActive", value: staff.isActive, using: boundary))

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
                    self.delegate?.didCreateStaff(self, status: safeResponse.statusCode)
                }
            }.resume()
        }
    }
    
    //MARK: - DELETE
    
    func deleteStaff(id: String) {
        let urlString = "\(libraryUrl)staffs/\(id)"
        performDelete(urlString: urlString)
    }
    
    func performDelete(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("bearer \(LoginInfo.loginInstance.userToken)", forHTTPHeaderField: "Authorization")
            
            session.dataTask(with: request) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeResponse = response as? HTTPURLResponse {
                    self.delegate?.didDeleteStaff(self, status: safeResponse.statusCode)
                }
            }.resume()
        }
    }
    
    //MARK: - Formatting and Parsing Methods
    
    func parseJSON(_ staffData: Data) -> [StaffModel]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([StaffData].self, from: staffData)
            
            var staffArray: [StaffModel] = []
            
            decodedData.forEach { (staff) in
                let staffObj = StaffModel(id: staff.id, name: staff.name, email: staff.email, password: staff.password, address: staff.address, phone: staff.phone, isActive: staff.isActive, imageUrl: staff.imageUrl, image: UIImage(named: "hpphilosopher")!, dateAdded: staff.dateAdded ?? "", role: staff.role)
                staffArray.append(staffObj)
            }
            
            return staffArray
        } catch {
            print(error)
            return nil
        }
    }
    
    func convertFormField(named name: String, value: Any, using boundary: String) -> String {
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
}


//extension NSMutableData {
//  func appendString(_ string: String) {
//    if let data = string.data(using: .utf8) {
//      self.append(data)
//    }
//  }
//}
