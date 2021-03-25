//
//  LoginData.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 17/03/2021.
//

import Foundation

struct LoginData: Codable {
    let access_token: String
    let staff_id: String
    let staff_name: String
    let staff_role: String
}
