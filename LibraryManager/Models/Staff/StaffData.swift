//
//  StaffData.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 16/03/2021.
//

import Foundation

struct StaffData: Codable {
    let id: String
    let name: String
    let email: String
    let password: String
    let address: String
    let phone: String
    let isActive: Bool
    var imageUrl: String
    let dateAdded: String?
    let role: String
}

