//
//  LoanData.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 17/03/2021.
//

import Foundation

struct LoanData : Codable {
    let id: String
    let customerName: String
    let customerId: String
    let staffName: String
    let staffId: String
    let bookName: String
    let bookImage: String
    let bookId: String
    let isActive: Bool
    let loanDate: String
    let returnDate: String?
    
}
