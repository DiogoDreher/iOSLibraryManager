//
//  BookData.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 17/03/2021.
//

import Foundation

struct BookData: Codable {
    let id: String
    let name: String
    let description: String?
    let author: String
    let genre: String
    let year: Int
    let publisher: String
    let isAvailable: Bool
    let loanDate: String?
    let imageUrl: String
}

