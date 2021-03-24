//
//  CustomerData.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 17/03/2021.
//

import Foundation

struct CustomerData : Codable {
    let id: String
    let name: String
    let email: String
    let address: String
    let phone: String
    let isActive: Bool
    let dateAdded: String?
    let imageUrl: String
}
