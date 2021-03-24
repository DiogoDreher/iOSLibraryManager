//
//  LoanModel.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 17/03/2021.
//

import Foundation

struct LoanModel {
        
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
    let returnDate: String
    
    var loanDateFormatted: Date? {
        return DateFormatter().date(from: loanDate)
    }
    
    var returnDateFormatted: Date? {
        return DateFormatter().date(from: returnDate)
    }
    
    var completeImgUrl: String {
        var url = bookImage
        url.remove(at: url.startIndex)
        return url
    }
    
    var isLate: Bool {
        if isActive {
            let dateDiff = Calendar.current.dateComponents([.day], from: loanDateFormatted ?? Date(), to: Date())
            
            if let diff = dateDiff.day {
                if diff > 30 {
                    return true
                }
                else
                {
                    return false
                }
            }
            return false
        }
        else
        {
            return false
        }
        
    }
}


