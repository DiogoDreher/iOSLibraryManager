//
//  StaffModel.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 17/03/2021.
//

import UIKit

struct StaffModel {
    let id: String
    let name: String
    let email: String
    let password: String
    let address: String
    let phone: String
    let isActive: Bool
    var imageUrl: String
    let image: UIImage
    let dateAdded: String
    let role: String
    
    
    var completeImgUrl: String {
        var url = imageUrl
        url.remove(at: url.startIndex)
        return url
    }
}
