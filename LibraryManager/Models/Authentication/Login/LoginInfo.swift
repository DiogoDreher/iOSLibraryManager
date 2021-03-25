//
//  LoginInfo.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 25/03/2021.
//

import Foundation

class LoginInfo {
    var isLogeegdIn: Bool = false
    var userName: String = ""
    var userId: String = ""
    var userToken: String = ""
    var userRole: String = ""
    
    static let loginInstance = LoginInfo()
    
    init() {
        
    }
}
